local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Balance = require(ReplicatedStorage.Game.Shared.Config.Balance)
local Prestige = require(ReplicatedStorage.Game.Shared.Config.Prestige)
local RarityBonus = require(ReplicatedStorage.Game.Shared.Config.RarityBonus)
local Mutations = require(ReplicatedStorage.Game.Shared.Config.Mutations)
local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
local UpgradeRegistry = require(ReplicatedStorage.Game.Shared.Registries.UpgradeRegistry)
local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local PlotService = require(script.Parent.PlotService)

local StateService = {}
local states = {}
local dirty = {}
local lastMutationRoll = os.clock()

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
		permanentBonus = 0,
		inventory = {},
		index = {},
		upgrades = {},
		unlockedRarities = cloneUnlockedRarities(),
		activeMutation = nil,
		mutationExpiresAt = 0,
	}
end

local function refreshUnlockedRarities(state)
	state.unlockedRarities = cloneUnlockedRarities()
	UpgradeRegistry.applyUnlockEffects(state.upgrades, state.unlockedRarities)
end

local function getMutationDefinition(state)
	if not state.activeMutation then
		return nil
	end
	return Mutations.getDefinition(state.activeMutation)
end

function StateService.getPermanentMultiplierFromState(state)
	return RarityBonus.getTotalMultiplier(state.permanentBonus)
end

function StateService.getPrestigeMultiplierFromState(state)
	return Prestige.getRewardMultiplier(state.prestige)
end

function StateService.getMutationMoneyMultiplier(state)
	local mutation = getMutationDefinition(state)
	return mutation and mutation.moneyMultiplier or 1
end

function StateService.getMutationXpMultiplier(state)
	local mutation = getMutationDefinition(state)
	return mutation and mutation.xpMultiplier or 1
end

function StateService.getMoneyPerSecondFromState(state)
	return Balance.getMoneyPerSecond(state.fridgeLevel, {
		prestige = StateService.getPrestigeMultiplierFromState(state),
		permanent = StateService.getPermanentMultiplierFromState(state),
		upgrade = 1 + UpgradeRegistry.getTotalEffect(state.upgrades, "moneyMultiplierPerLevel"),
		mutation = StateService.getMutationMoneyMultiplier(state),
	})
end

function StateService.getXpMultiplierFromState(state)
	return StateService.getPrestigeMultiplierFromState(state)
		* StateService.getPermanentMultiplierFromState(state)
		* (1 + UpgradeRegistry.getTotalEffect(state.upgrades, "xpMultiplierPerLevel"))
		* StateService.getMutationXpMultiplier(state)
end

local function toPublicState(state)
	local mutationDefinition = getMutationDefinition(state)
	return {
		money = state.money,
		fridgeLevel = state.fridgeLevel,
		fridgeXp = state.fridgeXp,
		xpRequired = Balance.getXpRequiredForLevel(state.fridgeLevel),
		moneyPerSecond = StateService.getMoneyPerSecondFromState(state),
		prestige = state.prestige,
		permanentBonus = state.permanentBonus,
		inventory = state.inventory,
		index = state.index,
		upgrades = UpgradeRegistry.getPublicUpgrades(state.upgrades),
		upgradeOrder = UpgradeRegistry.Order,
		upgradeBranches = UpgradeRegistry.Branches,
		unlockedRarities = state.unlockedRarities,
		prestigeRequirement = Prestige.RequiredFridgeLevel,
		canPrestige = state.fridgeLevel >= Prestige.RequiredFridgeLevel,
		activeMutation = mutationDefinition and {
			id = state.activeMutation,
			name = mutationDefinition.displayName,
			description = mutationDefinition.description,
			expiresAt = state.mutationExpiresAt,
		} or nil,
	}
end

function StateService.getPublicState(player)
	local state = states[player]
	return state and toPublicState(state) or nil
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
		return false
	end
	table.insert(state.inventory, foodId)
	state.index[foodId] = (state.index[foodId] or 0) + 1
	dirty[player] = true
	StateService.pushState(player)
	return true
end

function StateService.feedFood(player, inventoryIndex)
	local state = states[player]
	if not state then
		return false, "No state"
	end

	local foodId = state.inventory[inventoryIndex]
	local food = foodId and FoodRegistry.getFood(foodId)
	if not food then
		return false, "Invalid food"
	end

	table.remove(state.inventory, inventoryIndex)
	state.fridgeXp += food.xp * StateService.getXpMultiplierFromState(state)

	local rarityBonus = RarityBonus.getBonusForRarity(food.rarity)
	if rarityBonus > 0 then
		state.permanentBonus += rarityBonus
	end

	while state.fridgeXp >= Balance.getXpRequiredForLevel(state.fridgeLevel) do
		state.fridgeXp -= Balance.getXpRequiredForLevel(state.fridgeLevel)
		state.fridgeLevel += 1
	end

	dirty[player] = true
	StateService.pushState(player)
	return true, { rarity = food.rarity }
end

function StateService.feedEquippedFood(player)
	return false, "Temporarily rebuilding service"
end

function StateService.equipFood(player)
	return true
end

function StateService.purchaseUpgrade(player, upgradeId)
	local state = states[player]
	if not state then
		return false
	end
	state.upgrades[upgradeId] = (state.upgrades[upgradeId] or 0) + 1
	refreshUnlockedRarities(state)
	StateService.pushState(player)
	return true
end

function StateService.prestige(player)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	if state.fridgeLevel < Prestige.RequiredFridgeLevel then
		return false, "Level too low"
	end

	state.prestige += 1
	state.money = 0
	state.fridgeLevel = 1
	state.fridgeXp = 0
	state.inventory = {}
	state.upgrades = {}
	refreshUnlockedRarities(state)

	StateService.pushState(player)
	return true, {
		prestige = state.prestige,
	}
end

function StateService.tickMoney(deltaTime)
	if os.clock() - lastMutationRoll >= Mutations.CheckIntervalSeconds then
		lastMutationRoll = os.clock()
		for player, state in pairs(states) do
			if (not state.activeMutation) and Random.new():NextNumber() <= Mutations.TriggerChance then
				local mutationId = Mutations.roll(Random.new())
				state.activeMutation = mutationId
				state.mutationExpiresAt = os.time() + Mutations.DurationSeconds
				StateService.pushState(player)
			end
		end
	end

	for player, state in pairs(states) do
		if state.activeMutation and os.time() >= state.mutationExpiresAt then
			state.activeMutation = nil
			state.mutationExpiresAt = 0
			StateService.pushState(player)
		end

		local earned = StateService.getMoneyPerSecondFromState(state) * deltaTime
		state.money += earned
		state.totalEarned += earned
	end
end

local function loadPlayer(player)
	local state = createState()
	local data = DataService.Load(player)
	if typeof(data) == "table" then
		for key, value in pairs(data) do
			state[key] = value
		end
		refreshUnlockedRarities(state)
	end
	states[player] = state
	StateService.pushState(player)
end

function StateService.savePlayer(player)
	local state = states[player]
	if state then
		DataService.Save(player, state)
	end
end

function StateService.Init()
	Players.PlayerAdded:Connect(loadPlayer)
	Players.PlayerRemoving:Connect(function(player)
		StateService.savePlayer(player)
		states[player] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		loadPlayer(player)
	end
end

return StateService
