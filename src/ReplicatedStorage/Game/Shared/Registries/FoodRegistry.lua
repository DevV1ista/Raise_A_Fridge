local FoodRegistry = {}

FoodRegistry.RarityOrder = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" }

FoodRegistry.RarityWeights = {
	Common = 8500,
	Uncommon = 1500,
	Rare = 250,
	Epic = 45,
	Legendary = 7,
	Mythic = 1,
	Secret = 0.1,
}

FoodRegistry.StartingUnlockedRarities = {
	Common = true,
	Uncommon = true,
}

FoodRegistry.Foods = {
	Toast = { displayName = "Toast", rarity = "Common", xp = 2 },
	Apple = { displayName = "Apple", rarity = "Common", xp = 3 },
	Milk = { displayName = "Milk", rarity = "Common", xp = 4 },
	Banana = { displayName = "Banana", rarity = "Common", xp = 3 },
	Bread = { displayName = "Bread", rarity = "Common", xp = 2 },
	Egg = { displayName = "Egg", rarity = "Common", xp = 5 },

	Burger = { displayName = "Burger", rarity = "Uncommon", xp = 12 },
	PizzaSlice = { displayName = "Pizza Slice", rarity = "Uncommon", xp = 15 },
	Donut = { displayName = "Donut", rarity = "Uncommon", xp = 10 },
	Taco = { displayName = "Taco", rarity = "Uncommon", xp = 16 },
	Cheese = { displayName = "Cheese", rarity = "Uncommon", xp = 9 },
	Soda = { displayName = "Soda", rarity = "Uncommon", xp = 8 },

	GoldenApple = { displayName = "Golden Apple", rarity = "Rare", xp = 75 },
	IceCream = { displayName = "Ice Cream", rarity = "Rare", xp = 60 },
	SpicyRamen = { displayName = "Spicy Ramen", rarity = "Rare", xp = 95 },
	Steak = { displayName = "Steak", rarity = "Rare", xp = 120 },
	Pancakes = { displayName = "Pancakes", rarity = "Rare", xp = 70 },
	FrozenPizza = { displayName = "Frozen Pizza", rarity = "Rare", xp = 90 },
}

function FoodRegistry.getFood(foodId)
	return FoodRegistry.Foods[foodId]
end

function FoodRegistry.getFoodsForRarity(rarity)
	local result = {}
	for foodId, food in pairs(FoodRegistry.Foods) do
		if food.rarity == rarity then
			table.insert(result, foodId)
		end
	end
	table.sort(result)
	return result
end

return FoodRegistry
