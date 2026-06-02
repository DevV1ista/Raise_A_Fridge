local Mutations = {}

-- Server-side mutation cadence. Keep values here so balancing is not hidden in services.
Mutations.CheckIntervalSeconds = 10 * 60
Mutations.TriggerChance = 0.20
Mutations.DurationSeconds = 5 * 60

Mutations.Definitions = {
	MoneySurge = {
		displayName = "Money Surge",
		description = "The Fridge produces double money for a short time.",
		weight = 50,
		moneyMultiplier = 2,
		xpMultiplier = 1,
	},
	XpFrost = {
		displayName = "XP Frost",
		description = "Food gives double Fridge XP while the mutation is active.",
		weight = 35,
		moneyMultiplier = 1,
		xpMultiplier = 2,
	},
	GoldenFreeze = {
		displayName = "Golden Freeze",
		description = "A rare mutation that boosts both money and XP.",
		weight = 15,
		moneyMultiplier = 1.5,
		xpMultiplier = 1.5,
	},
}

Mutations.Order = {
	"MoneySurge",
	"XpFrost",
	"GoldenFreeze",
}

function Mutations.getDefinition(mutationId)
	return Mutations.Definitions[mutationId]
end

function Mutations.roll(randomGenerator)
	local rng = randomGenerator or Random.new()
	local totalWeight = 0
	for _, mutationId in ipairs(Mutations.Order) do
		local definition = Mutations.getDefinition(mutationId)
		if definition then
			totalWeight += definition.weight
		end
	end
	if totalWeight <= 0 then
		return nil
	end

	local target = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	for _, mutationId in ipairs(Mutations.Order) do
		local definition = Mutations.getDefinition(mutationId)
		if definition then
			cumulative += definition.weight
			if target <= cumulative then
				return mutationId, definition
			end
		end
	end
	return Mutations.Order[#Mutations.Order], Mutations.getDefinition(Mutations.Order[#Mutations.Order])
end

return Mutations
