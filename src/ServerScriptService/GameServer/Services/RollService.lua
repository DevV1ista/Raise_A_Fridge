local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Balance = require(ReplicatedStorage.Game.Shared.Config.Balance)
local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
local StateService = require(script.Parent.StateService)

local RollService = {}
local rng = Random.new()

local function getUnlockedRarities(state)
	local result = {}
	for _, rarity in ipairs(FoodRegistry.RarityOrder) do
		if state.unlockedRarities[rarity] then
			table.insert(result, rarity)
		end
	end
	return result
end

local function chooseWeightedRarity(state, totalLuck)
	local effectiveLuck = Balance.getEffectiveLuck(totalLuck)
	local unlocked = getUnlockedRarities(state)
	local totalWeight = 0
	local entries = {}
	for _, rarity in ipairs(unlocked) do
		local weight = FoodRegistry.RarityWeights[rarity] or 0
		if rarity ~= "Common" and rarity ~= "Uncommon" then
			weight *= effectiveLuck
		end
		totalWeight += weight
		table.insert(entries, { rarity = rarity, weight = weight })
	end
	local roll = rng:NextNumber(0, totalWeight)
	local running = 0
	for _, entry in ipairs(entries) do
		running += entry.weight
		if roll <= running then
			return entry.rarity
		end
	end
	return "Common"
end

local function chooseFoodFromRarity(rarity)
	local foods = FoodRegistry.getFoodsForRarity(rarity)
	if #foods == 0 then
		return "Toast"
	end
	return foods[rng:NextInteger(1, #foods)]
end

local function rollCloverChain()
	local chain = {}
	local currentMultiplier = 1
	local cap = Balance.StartingCloverCap
	if rng:NextNumber() > Balance.BaseCloverStartChance then
		return chain, currentMultiplier
	end
	currentMultiplier = 2
	table.insert(chain, currentMultiplier)
	while currentMultiplier < cap and rng:NextNumber() <= Balance.BaseCloverContinueChance do
		currentMultiplier *= 2
		table.insert(chain, currentMultiplier)
	end
	return chain, currentMultiplier
end

function RollService.roll(player)
	local state = StateService.getState(player)
	if not state then
		return false, "No state"
	end
	local now = os.clock()
	if now - state.lastRollAt < Balance.RollCooldownSeconds then
		return false, "Cooldown"
	end
	state.lastRollAt = now
	local chain, cloverLuck = rollCloverChain()
	local totalLuck = cloverLuck
	local rarity = chooseWeightedRarity(state, totalLuck)
	local foodId = chooseFoodFromRarity(rarity)
	local added, reason = StateService.addFood(player, foodId)
	if not added then
		return false, reason
	end
	return true, {
		foodId = foodId,
		food = FoodRegistry.getFood(foodId),
		rarity = rarity,
		cloverChain = chain,
		totalLuck = totalLuck,
	}
end

return RollService
