local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Balance = require(ReplicatedStorage.Game.Shared.Config.Balance)
local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
local PlotService = require(script.Parent.PlotService)

local StateService = {}
local states = {}

local function cloneUnlockedRarities()
	local unlocked = {}
	for rarity, value in pairs(FoodRegistry.StartingUnlockedRarities) do
		unlocked[rarity] = value
	end
	return unlocked
end

local function createState()
	return {
		money = 0,
		totalEarned = 0,
		fridgeLevel = 1,
		fridgeXp = 0,
		prestige = 0,
		inventory = {},
		index = {},
		unlockedRarities = cloneUnlockedRarities(),
		lastRollAt = 0,
	}
end

local function getEquippedFoodTool(player)
	local character = player.Character
	if not character then
		return nil
	end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("IsFridgeFood") then
		return tool
	end
	return nil
end

local function destroyFoodTools(player)
	local character = player.Character
	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsFridgeFood") then
				child:Destroy()
			end
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsFridgeFood") then
				child:Destroy()
			end
		end
	end
end

local function getFoodModelTemplate(foodId, food)
	local serverFolder = ServerStorage:FindFirstChild("Game")
		and ServerStorage.Game:FindFirstChild("Assets")
		and ServerStorage.Game.Assets:FindFirstChild("FoodModels")
	local replicatedFolder = ReplicatedStorage:FindFirstChild("Game")
		and ReplicatedStorage.Game:FindFirstChild("Assets")
		and ReplicatedStorage.Game.Assets:FindFirstChild("FoodModels")

	if serverFolder then
		local template = serverFolder:FindFirstChild(foodId) or serverFolder:FindFirstChild(food.displayName)
		if template then
			return template
		end
	end
	if replicatedFolder then
		local template = replicatedFolder:FindFirstChild(foodId) or replicatedFolder:FindFirstChild(food.displayName)
		if template then
			return template
		end
	end
	return nil
end

local function prepareDescendant(instance)
	if instance:IsA("BasePart") then
		instance.CanCollide = false
		instance.Massless = true
	end
end

local function attachModelToHandle(model, handle)
	for _, descendant in ipairs(model:GetDescendants()) do
		prepareDescendant(descendant)
	end
	local primary = model:IsA("Model") and model.PrimaryPart or nil
	if not primary then
		primary = model:FindFirstChildWhichIsA("BasePart", true)
	end
	if primary then
		primary.Name = "FoodVisualRoot"
		primary.CFrame = handle.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = primary
		weld.Parent = handle
	end
end

local function createFallbackHandle()
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.4, 1.4, 1.4)
	handle.CanCollide = false
	handle.Massless = true
	return handle
end

local function createFoodTool(foodId, food, inventoryIndex)
	local tool = Instance.new("Tool")
	tool.Name = food.displayName
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("IsFridgeFood", true)
	tool:SetAttribute("FoodId", foodId)
	tool:SetAttribute("InventoryIndex", inventoryIndex)
	tool:SetAttribute("Xp", food.xp)
	tool.ToolTip = food.displayName .. " | " .. food.rarity .. " | +" .. food.xp .. " XP"

	local handle = createFallbackHandle()
	handle.Transparency = 1
	handle.Parent = tool

	local template = getFoodModelTemplate(foodId, food)
	if template then
		local visual = template:Clone()
		visual.Name = "FoodVisual"
		visual.Parent = tool
		attachModelToHandle(visual, handle)
	else
		handle.Transparency = 0
	end

	return tool
end

local function equipToolNow(player, tool)
	local character = player.Character
	if not character then
		return false, "No character"
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false, "No humanoid"
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return false, "No backpack"
	end
	tool.Parent = backpack
	humanoid:EquipTool(tool)
	return true
end

function StateService.getFoodInfo(foodId)
	return FoodRegistry.getFood(foodId)
end

function StateService.getMoneyPerSecondFromState(state)
	return Balance.getMoneyPerSecond(state.fridgeLevel, {
		prestige = Balance.getPrestigeMultiplier(state.prestige),
		permanent = 1,
		upgrade = 1,
		mutation = 1,
	})
end

local function toPublicState(state)
	return {
		money = state.money,
		totalEarned = state.totalEarned,
		fridgeLevel = state.fridgeLevel,
		fridgeXp = state.fridgeXp,
		xpRequired = Balance.getXpRequiredForLevel(state.fridgeLevel),
		moneyPerSecond = StateService.getMoneyPerSecondFromState(state),
		prestige = state.prestige,
		inventory = state.inventory,
		index = state.index,
		unlockedRarities = state.unlockedRarities,
	}
end

function StateService.getState(player)
	return states[player]
end

function StateService.getPublicState(player)
	local state = states[player]
	if not state then
		return nil
	end
	return toPublicState(state)
end

function StateService.pushState(player)
	local publicState = StateService.getPublicState(player)
	if not publicState then
		return
	end
	PlotService.updateFridgeDisplay(player, publicState)
	Remotes.StateChanged:FireClient(player, publicState)
end

function StateService.addFood(player, foodId)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	if #state.inventory >= Balance.InventoryLimit then
		return false, "Inventory full"
	end
	table.insert(state.inventory, foodId)
	state.index[foodId] = (state.index[foodId] or 0) + 1
	StateService.pushState(player)
	return true
end

function StateService.equipFood(player, inventoryIndex)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	local foodId = state.inventory[inventoryIndex]
	if not foodId then
		return false, "Invalid food"
	end
	local equippedTool = getEquippedFoodTool(player)
	if equippedTool
		and equippedTool:GetAttribute("InventoryIndex") == inventoryIndex
		and equippedTool:GetAttribute("FoodId") == foodId then
		equippedTool:Destroy()
		return true, {
			unequipped = true,
			foodId = foodId,
		}
	end
	local food = FoodRegistry.getFood(foodId)
	if not food then
		return false, "Unknown food"
	end
	destroyFoodTools(player)
	local tool = createFoodTool(foodId, food, inventoryIndex)
	local equipped, equipReason = equipToolNow(player, tool)
	if not equipped then
		tool:Destroy()
		return false, equipReason
	end
	return true, {
		foodId = foodId,
		displayName = food.displayName,
		xp = food.xp,
		rarity = food.rarity,
	}
end

function StateService.feedEquippedFood(player)
	local character = player.Character
	if not character then
		return false, "Equip food first"
	end
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or not tool:GetAttribute("IsFridgeFood") then
		return false, "Equip food first"
	end
	local inventoryIndex = tool:GetAttribute("InventoryIndex")
	local state = states[player]
	if not state or not inventoryIndex then
		return false, "Invalid food"
	end
	local foodId = state.inventory[inventoryIndex]
	if foodId ~= tool:GetAttribute("FoodId") then
		return false, "Food changed"
	end
	local ok, result = StateService.feedFood(player, inventoryIndex)
	if ok then
		tool:Destroy()
	end
	return ok, result
end

function StateService.feedFood(player, inventoryIndex)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	local foodId = state.inventory[inventoryIndex]
	if not foodId then
		return false, "Invalid food"
	end
	local food = FoodRegistry.getFood(foodId)
	if not food then
		return false, "Unknown food"
	end
	table.remove(state.inventory, inventoryIndex)
	state.fridgeXp += food.xp
	local required = Balance.getXpRequiredForLevel(state.fridgeLevel)
	while state.fridgeXp >= required do
		state.fridgeXp -= required
		state.fridgeLevel += 1
		required = Balance.getXpRequiredForLevel(state.fridgeLevel)
	end
	StateService.pushState(player)
	return true
end

function StateService.tickMoney(deltaTime)
	for player, state in pairs(states) do
		local earned = StateService.getMoneyPerSecondFromState(state) * deltaTime
		state.money += earned
		state.totalEarned += earned
		StateService.pushState(player)
	end
end

function StateService.Init()
	Players.PlayerAdded:Connect(function(player)
		states[player] = createState()
		StateService.pushState(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		states[player] = createState()
		StateService.pushState(player)
	end
end

return StateService
