local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
local Util = require(ReplicatedStorage.Game.Shared.Util)

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("FridgeHudGui")

local rollButton = gui:WaitForChild("RollButton")
local feedButton = gui:WaitForChild("FeedButton")
local status = gui:WaitForChild("Status")
local inventoryList = gui:WaitForChild("InventoryList")

local currentState = nil
local selectedInventoryIndex = nil

local function setText(name, text)
	local label = gui:FindFirstChild(name, true)
	if label and label:IsA("TextLabel") then
		label.Text = text
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
		local button = Instance.new("TextButton")
		button.Name = "Food" .. index
		button.Size = UDim2.new(1, -8, 0, 32)
		button.Text = index .. ". " .. foodId
		button.Parent = inventoryList
		button.Activated:Connect(function()
			selectedInventoryIndex = index
			status.Text = "Selected " .. foodId .. " for feeding"
		end)
	end
end

local function render(state)
	currentState = state
	setText("MoneyLabel", "$" .. Util.formatNumber(state.money))
	setText("FridgeLabel", "Fridge Lv. " .. state.fridgeLevel .. " | XP " .. math.floor(state.fridgeXp) .. "/" .. state.xpRequired)
	setText("MpsLabel", "$" .. Util.formatNumber(state.moneyPerSecond) .. "/s")
	setText("PrestigeLabel", "Prestige " .. state.prestige)
	renderInventory()
end

rollButton.Activated:Connect(function()
	status.Text = "Rolling..."
	local ok, result = Remotes.RollRequested:InvokeServer()
	if not ok then
		status.Text = tostring(result)
		return
	end
	local chain = result.cloverChain or {}
	if #chain > 0 then
		status.Text = "Clover x" .. chain[#chain] .. " -> " .. result.food.displayName .. " (" .. result.rarity .. ")"
	else
		status.Text = result.food.displayName .. " (" .. result.rarity .. ")"
	end
end)

feedButton.Activated:Connect(function()
	if not selectedInventoryIndex then
		status.Text = "Select food first"
		return
	end
	local ok, result = Remotes.FeedRequested:InvokeServer(selectedInventoryIndex)
	if not ok then
		status.Text = tostring(result)
		return
	end
	status.Text = "Fed fridge"
	selectedInventoryIndex = nil
end)

Remotes.StateChanged.OnClientEvent:Connect(render)
local initialState = Remotes.GetState:InvokeServer()
if initialState then
	render(initialState)
end
