local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local HudController = {}
local started = false

function HudController.Start()
	if started then
		return
	end
	started = true

	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

	local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
	local Util = require(ReplicatedStorage.Game.Shared.Util)
	local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
	local UpgradeRegistry = require(ReplicatedStorage.Game.Shared.Registries.UpgradeRegistry)

	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("FridgeHudGui")

	local rollButton = gui:WaitForChild("RollButton")
	local status = gui:WaitForChild("Status")
	local inventoryPanel = gui:WaitForChild("InventoryPanel")
	local inventoryList = inventoryPanel:WaitForChild("InventoryList")
	local minimizeButton = gui:FindFirstChild("InventoryToggle", true)
	local upgradePanel = gui:FindFirstChild("UpgradePanel", true)
	local upgradeList = upgradePanel and upgradePanel:FindFirstChild("UpgradeList")

	local currentState = nil
	local inventoryCollapsed = false

	local function setText(name, text)
		local label = gui:FindFirstChild(name, true)
		if label and label:IsA("TextLabel") then
			label.Text = text
		end
	end

	local function setInventoryCollapsed(collapsed)
		inventoryCollapsed = collapsed
		inventoryList.Visible = not collapsed
		if minimizeButton and minimizeButton:IsA("TextButton") then
			minimizeButton.Text = collapsed and "+" or "-"
		end
		if inventoryPanel and inventoryPanel:IsA("GuiObject") then
			inventoryPanel.Size = collapsed and UDim2.new(0, 260, 0, 42) or UDim2.new(0, 260, 0, 380)
		end
	end

	local function renderInventory()
		for _, child in ipairs(inventoryList:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if not currentState then
			return
		end
		for index, foodId in ipairs(currentState.inventory) do
			local food = FoodRegistry.getFood(foodId)
			local button = Instance.new("TextButton")
			button.Name = "Food" .. index
			button.Size = UDim2.new(1, -8, 0, 42)
			button.TextScaled = true
			if food then
				button.Text = index .. ". " .. food.displayName .. " | " .. food.rarity .. " | +" .. food.xp .. " XP"
			else
				button.Text = index .. ". " .. foodId
			end
			button.Parent = inventoryList
			button.Activated:Connect(function()
				local ok, result = Remotes.EquipFoodRequested:InvokeServer(index)
				if ok then
					if result.unequipped then
						status.Text = "Food unequipped."
					else
						status.Text = result.displayName .. " is now in your hand. Press your Fridge to feed."
					end
				else
					status.Text = tostring(result)
				end
			end)
		end
	end

	local function getUpgradeLine(upgradeId, upgrade)
		local costText = upgrade.cost and "$" .. Util.formatNumber(upgrade.cost) or "MAX"
		return upgrade.displayName .. " Lv. " .. upgrade.level .. "/" .. upgrade.maxLevel .. " | " .. costText
	end

	local function renderUpgrades()
		if not upgradeList or not currentState or not currentState.upgrades then
			return
		end
		for _, child in ipairs(upgradeList:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, upgradeId in ipairs(UpgradeRegistry.Order) do
			local upgrade = currentState.upgrades[upgradeId]
			if upgrade then
				local button = Instance.new("TextButton")
				button.Name = upgradeId .. "Button"
				button.Size = UDim2.new(1, -8, 0, 54)
				button.TextScaled = true
				button.TextWrapped = true
				button.Text = getUpgradeLine(upgradeId, upgrade)
				button.Parent = upgradeList
				button.Activated:Connect(function()
					local ok, result = Remotes.PurchaseUpgradeRequested:InvokeServer(upgradeId)
					if ok then
						status.Text = upgrade.displayName .. " upgraded to Lv. " .. result.level
					else
						status.Text = tostring(result)
					end
				end)
			end
		end
	end

	local function render(state)
		currentState = state
		setText("MoneyLabel", "$" .. Util.formatNumber(state.money))
		setText("PrestigeLabel", "Prestige " .. state.prestige)
		setText("MpsLabel", "$" .. Util.formatNumber(state.moneyPerSecond) .. "/s")
		if state.multipliers then
			setText(
				"MultiplierLabel",
				"XP x" .. string.format("%.2f", state.multipliers.xp)
					.. " | Luck x" .. string.format("%.2f", state.multipliers.luck)
					.. " | Clover x" .. state.multipliers.cloverCap
			)
		end
		renderInventory()
		renderUpgrades()
	end

	rollButton.Activated:Connect(function()
		local ok, result = Remotes.RollRequested:InvokeServer()
		if not ok then
			if result == "Cooldown" then
				return
			end
			status.Text = tostring(result)
			return
		end
		local chain = result.cloverChain or {}
		if #chain > 0 then
			status.Text = "Clover x"
				.. chain[#chain]
				.. " -> "
				.. result.food.displayName
				.. " ("
				.. result.rarity
				.. ")"
		else
			status.Text = result.food.displayName .. " (" .. result.rarity .. ")"
		end
	end)

	if minimizeButton and minimizeButton:IsA("TextButton") then
		minimizeButton.Activated:Connect(function()
			setInventoryCollapsed(not inventoryCollapsed)
		end)
	end

	Remotes.StateChanged.OnClientEvent:Connect(render)
	local initialState = Remotes.GetState:InvokeServer()
	if initialState then
		render(initialState)
	end
	setInventoryCollapsed(false)
end

return HudController
