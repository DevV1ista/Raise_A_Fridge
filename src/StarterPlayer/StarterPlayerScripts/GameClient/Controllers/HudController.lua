local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local HudController = {}
local started = false

local NODE_WIDTH = 106
local NODE_HEIGHT = 92
local TREE_CENTER_X = 0.5
local TREE_CENTER_Y = 0.48
local COLUMN_GAP = 92
local ROW_GAP = 82
local BASE_COLUMN = 3
local BASE_ROW = 3

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
	local skillTreeButton = gui:FindFirstChild("SkillTreeButton", true)
	local skillTreeOverlay = gui:FindFirstChild("SkillTreeOverlay", true)
	local skillTreeCanvas = skillTreeOverlay and skillTreeOverlay:FindFirstChild("SkillTreeCanvas", true)
	local skillTreeCloseButton = skillTreeOverlay and skillTreeOverlay:FindFirstChild("SkillTreeCloseButton", true)
	local skillTreeMoneyLabel = skillTreeOverlay and skillTreeOverlay:FindFirstChild("SkillTreeMoneyLabel", true)

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

	local function setSkillTreeOpen(open)
		if skillTreeOverlay and skillTreeOverlay:IsA("GuiObject") then
			skillTreeOverlay.Visible = open
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

	local function getNodeColor(upgrade)
		if upgrade.completed then
			return Color3.fromRGB(255, 214, 80)
		end
		if not upgrade.unlocked then
			return Color3.fromRGB(34, 38, 55)
		end
		if upgrade.branch == "Luck" or upgrade.branch == "Clover" then
			return Color3.fromRGB(40, 165, 255)
		end
		if upgrade.branch == "Income" then
			return Color3.fromRGB(255, 211, 74)
		end
		if upgrade.branch == "Feeding" then
			return Color3.fromRGB(55, 215, 95)
		end
		return Color3.fromRGB(80, 185, 255)
	end

	local function getNodeIcon(upgrade)
		if not upgrade.unlocked then
			return "?"
		end
		if upgrade.effects.unlockRarity then
			return upgrade.effects.unlockRarity:sub(1, 1)
		end
		if upgrade.branch == "Luck" then
			return "🍀"
		end
		if upgrade.branch == "Clover" then
			return "🍀"
		end
		if upgrade.branch == "Income" then
			return "$"
		end
		if upgrade.branch == "Feeding" then
			return "XP"
		end
		return "❄"
	end

	local function getNodeCostText(upgrade)
		if upgrade.completed then
			return "MAX"
		end
		if not upgrade.unlocked then
			return "LOCKED"
		end
		return upgrade.cost and "$" .. Util.formatNumber(upgrade.cost) or "MAX"
	end

	local function getNodeStatusText(upgrade)
		if upgrade.completed then
			return "Done"
		end
		if not upgrade.unlocked then
			return "Need " .. upgrade.requirementText
		end
		return "Open"
	end

	local function getNodePosition(upgrade)
		local xOffset = (upgrade.column - BASE_COLUMN) * COLUMN_GAP
		local yOffset = (upgrade.row - BASE_ROW) * ROW_GAP
		if upgrade.row % 2 == 0 then
			xOffset += COLUMN_GAP * 0.5
		end
		return UDim2.new(TREE_CENTER_X, xOffset - NODE_WIDTH / 2, TREE_CENTER_Y, yOffset - NODE_HEIGHT / 2)
	end

	local function clearSkillTreeCanvas()
		if not skillTreeCanvas then
			return
		end
		for _, child in ipairs(skillTreeCanvas:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
	end

	local function createConnector(fromUpgrade, toUpgrade)
		if not skillTreeCanvas then
			return
		end
		local fromX = (fromUpgrade.column - BASE_COLUMN) * COLUMN_GAP
		local fromY = (fromUpgrade.row - BASE_ROW) * ROW_GAP
		local toX = (toUpgrade.column - BASE_COLUMN) * COLUMN_GAP
		local toY = (toUpgrade.row - BASE_ROW) * ROW_GAP
		if fromUpgrade.row % 2 == 0 then
			fromX += COLUMN_GAP * 0.5
		end
		if toUpgrade.row % 2 == 0 then
			toX += COLUMN_GAP * 0.5
		end
		local midX = (fromX + toX) / 2
		local midY = (fromY + toY) / 2
		local distance = math.sqrt(((toX - fromX) ^ 2) + ((toY - fromY) ^ 2))
		local angle = math.deg(math.atan2(toY - fromY, toX - fromX))

		local connector = Instance.new("Frame")
		connector.Name = fromUpgrade.displayName .. "To" .. toUpgrade.displayName
		connector.AnchorPoint = Vector2.new(0.5, 0.5)
		connector.Size = UDim2.new(0, math.max(distance - 68, 8), 0, 8)
		connector.Position = UDim2.new(TREE_CENTER_X, midX, TREE_CENTER_Y, midY)
		connector.Rotation = angle
		connector.BackgroundColor3 = toUpgrade.unlocked and Color3.fromRGB(35, 180, 255) or Color3.fromRGB(20, 24, 35)
		connector.BorderSizePixel = 0
		connector.ZIndex = 2
		connector.Parent = skillTreeCanvas
	end

	local function createSkillNode(upgradeId, upgrade)
		if not skillTreeCanvas then
			return
		end

		local button = Instance.new("TextButton")
		button.Name = upgradeId .. "Node"
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.Size = UDim2.new(0, NODE_WIDTH, 0, NODE_HEIGHT)
		button.Position = getNodePosition(upgrade)
		button.BackgroundColor3 = getNodeColor(upgrade)
		button.BorderSizePixel = 0
		button.Text = ""
		button.AutoButtonColor = upgrade.unlocked and not upgrade.completed
		button.ZIndex = 5
		button.Parent = skillTreeCanvas

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 18)
		corner.Parent = button

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = upgrade.unlocked and 4 or 3
		stroke.Color = Color3.fromRGB(5, 8, 16)
		stroke.Parent = button

		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(1, -10, 0, 30)
		icon.Position = UDim2.new(0, 5, 0, 4)
		icon.BackgroundTransparency = 1
		icon.Text = getNodeIcon(upgrade)
		icon.TextScaled = true
		icon.TextColor3 = Color3.fromRGB(255, 255, 255)
		icon.TextStrokeTransparency = 0
		icon.Font = Enum.Font.GothamBlack
		icon.ZIndex = 6
		icon.Parent = button

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, -10, 0, 28)
		title.Position = UDim2.new(0, 5, 0, 32)
		title.BackgroundTransparency = 1
		title.Text = upgrade.unlocked and upgrade.displayName or "?"
		title.TextScaled = true
		title.TextWrapped = true
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextStrokeTransparency = 0
		title.Font = Enum.Font.GothamBlack
		title.ZIndex = 6
		title.Parent = button

		local cost = Instance.new("TextLabel")
		cost.Name = "Cost"
		cost.Size = UDim2.new(1, -10, 0, 22)
		cost.Position = UDim2.new(0, 5, 1, -26)
		cost.BackgroundTransparency = 1
		cost.Text = getNodeCostText(upgrade)
		cost.TextScaled = true
		cost.TextColor3 = upgrade.unlocked and Color3.fromRGB(255, 245, 120) or Color3.fromRGB(190, 195, 210)
		cost.TextStrokeTransparency = 0
		cost.Font = Enum.Font.GothamBlack
		cost.ZIndex = 6
		cost.Parent = button

		local levelBadge = Instance.new("TextLabel")
		levelBadge.Name = "LevelBadge"
		levelBadge.Size = UDim2.new(0, 28, 0, 28)
		levelBadge.Position = UDim2.new(1, -22, 0, -10)
		levelBadge.BackgroundColor3 = Color3.fromRGB(230, 25, 65)
		levelBadge.Text = tostring(upgrade.level)
		levelBadge.TextScaled = true
		levelBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		levelBadge.TextStrokeTransparency = 0
		levelBadge.Font = Enum.Font.GothamBlack
		levelBadge.Visible = upgrade.unlocked and upgrade.level > 0 and not upgrade.completed
		levelBadge.ZIndex = 7
		levelBadge.Parent = button

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(1, 0)
		badgeCorner.Parent = levelBadge

		button.Activated:Connect(function()
			if not upgrade.unlocked then
				status.Text = "Locked: needs " .. upgrade.requirementText
				setText("SkillTreeStatusLabel", getNodeStatusText(upgrade))
				return
			end
			if upgrade.completed then
				status.Text = upgrade.displayName .. " is already maxed."
				setText("SkillTreeStatusLabel", upgrade.displayName .. " is maxed.")
				return
			end
			local ok, result = Remotes.PurchaseUpgradeRequested:InvokeServer(upgradeId)
			if ok then
				status.Text = upgrade.displayName .. " upgraded to Lv. " .. result.level
				setText("SkillTreeStatusLabel", upgrade.displayName .. " upgraded!")
			else
				status.Text = tostring(result)
				setText("SkillTreeStatusLabel", tostring(result))
			end
		end)
	end

	local function renderSkillTree()
		if not currentState or not currentState.upgrades then
			return
		end
		if skillTreeMoneyLabel and skillTreeMoneyLabel:IsA("TextLabel") then
			skillTreeMoneyLabel.Text = "🪙 " .. Util.formatNumber(currentState.money)
		end
		clearSkillTreeCanvas()
		local order = currentState.upgradeOrder or UpgradeRegistry.Order

		for _, upgradeId in ipairs(order) do
			local upgrade = currentState.upgrades[upgradeId]
			if upgrade then
				for requiredId in pairs(upgrade.requires or {}) do
					local required = currentState.upgrades[requiredId]
					if required then
						createConnector(required, upgrade)
					end
				end
			end
		end

		for _, upgradeId in ipairs(order) do
			local upgrade = currentState.upgrades[upgradeId]
			if upgrade then
				createSkillNode(upgradeId, upgrade)
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
		renderSkillTree()
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

	if skillTreeButton and skillTreeButton:IsA("TextButton") then
		skillTreeButton.Activated:Connect(function()
			renderSkillTree()
			setSkillTreeOpen(true)
		end)
	end

	if skillTreeCloseButton and skillTreeCloseButton:IsA("TextButton") then
		skillTreeCloseButton.Activated:Connect(function()
			setSkillTreeOpen(false)
		end)
	end

	Remotes.StateChanged.OnClientEvent:Connect(render)
	local initialState = Remotes.GetState:InvokeServer()
	if initialState then
		render(initialState)
	end
	setInventoryCollapsed(false)
	setSkillTreeOpen(false)
end

return HudController
