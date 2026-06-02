local FoodRegistry = require(script.Parent.FoodRegistry)

local CollectionRegistry = {}

local function getSortedFoodIds()
	local foodIds = {}
	for foodId in pairs(FoodRegistry.Foods) do
		table.insert(foodIds, foodId)
	end
	table.sort(foodIds, function(left, right)
		local leftFood = FoodRegistry.getFood(left)
		local rightFood = FoodRegistry.getFood(right)
		local leftRarityIndex = table.find(FoodRegistry.RarityOrder, leftFood.rarity) or 999
		local rightRarityIndex = table.find(FoodRegistry.RarityOrder, rightFood.rarity) or 999
		if leftRarityIndex ~= rightRarityIndex then
			return leftRarityIndex < rightRarityIndex
		end
		return left < right
	end)
	return foodIds
end

function CollectionRegistry.getTotalFoodCount()
	local total = 0
	for _ in pairs(FoodRegistry.Foods) do
		total += 1
	end
	return total
end

function CollectionRegistry.getDiscoveredCount(index)
	index = index or {}
	local discovered = 0
	for foodId in pairs(FoodRegistry.Foods) do
		if (index[foodId] or 0) > 0 then
			discovered += 1
		end
	end
	return discovered
end

function CollectionRegistry.getCompletion(index)
	local total = CollectionRegistry.getTotalFoodCount()
	local discovered = CollectionRegistry.getDiscoveredCount(index)
	return {
		discovered = discovered,
		total = total,
		percent = total > 0 and discovered / total or 0,
	}
end

function CollectionRegistry.getRarityProgress(index)
	index = index or {}
	local progress = {}
	for _, rarity in ipairs(FoodRegistry.RarityOrder) do
		progress[rarity] = {
			discovered = 0,
			total = 0,
			percent = 0,
		}
	end

	for foodId, food in pairs(FoodRegistry.Foods) do
		local rarityProgress = progress[food.rarity]
		if rarityProgress then
			rarityProgress.total += 1
			if (index[foodId] or 0) > 0 then
				rarityProgress.discovered += 1
			end
		end
	end

	for _, rarityProgress in pairs(progress) do
		if rarityProgress.total > 0 then
			rarityProgress.percent = rarityProgress.discovered / rarityProgress.total
		end
	end

	return progress
end

function CollectionRegistry.getEntries(index)
	index = index or {}
	local entries = {}
	for _, foodId in ipairs(getSortedFoodIds()) do
		local food = FoodRegistry.getFood(foodId)
		local count = index[foodId] or 0
		local discovered = count > 0
		table.insert(entries, {
			foodId = foodId,
			displayName = discovered and food.displayName or "Undiscovered",
			rarity = food.rarity,
			xp = discovered and food.xp or nil,
			discovered = discovered,
			count = count,
		})
	end
	return entries
end

function CollectionRegistry.getPublicCollection(index)
	return {
		completion = CollectionRegistry.getCompletion(index),
		rarityProgress = CollectionRegistry.getRarityProgress(index),
		entries = CollectionRegistry.getEntries(index),
	}
end

return CollectionRegistry
