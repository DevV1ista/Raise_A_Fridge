local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Balance = require(ReplicatedStorage.Game.Shared.Config.Balance)
local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)

local PlayerDataService = {}
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

function PlayerDataService.getMoneyPerSecondFromState(state)
	return Balance.getMoneyPerSecond(state.fridgeLevel, {
		prestige = Balance.getPrestigeMultiplier(state.prestige),
		permanent = 1,
		upgrade = 1,
		mutation = 1,
	})
end

local function publicState(state)
	return {
		money = state.money,
		totalEarned = state.totalEarned,
		fridgeLevel = state.fridgeLevel,
		fridgeXp = state.fridgeXp,
		xpRequired = Balance.getXpRequiredForLevel(state.fridgeLevel),
		moneyPerSecond = PlayerDataService.getMoneyPerSecondFromState(state),
		prestige = state.prestige,
		inventory = state.inventory,
		index = state.index,
		unlockedRarities = state.unlockedRarities,
	}
end

function PlayerDataService.getState(player)
	return states[player]
end

function PlayerDataService.getPublicState(player)
	local state = states[player]
	if not state then
		return nil
	end
	return publicState(state)
end

function PlayerDataService.pushState(player)
	local state = PlayerDataService.getPublicState(player)
	if state then
		Remotes.StateChanged:FireClient(player, state)
	end
end

function PlayerDataService.addFood(player, foodId)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	if #state.inventory >= Balance.InventoryLimit then
		return false, "Inventory full"
	end
	table.insert(state.inventory, foodId)
	state.index[foodId] = (state.index[foodId] or 0) + 1
	PlayerDataService.pushState(player)
	return true
end

function PlayerDataService.feedFood(player, inventoryIndex)
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
	PlayerDataService.pushState(player)
	return true
end

function PlayerDataService.tickMoney(deltaTime)
	for player, state in pairs(states) do
		local earned = PlayerDataService.getMoneyPerSecondFromState(state) * deltaTime
		state.money += earned
		state.totalEarned += earned
		PlayerDataService.pushState(player)
	end
end

function PlayerDataService.Init()
	Players.PlayerAdded:Connect(function(player)
		states[player] = createState()
		PlayerDataService.pushState(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		states[player] = createState()
		PlayerDataService.pushState(player)
	end
end

return PlayerDataService
