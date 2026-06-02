local MutationConfig = {}

MutationConfig.RollIntervalSeconds = 10 * 60
MutationConfig.Chance = 0.20
MutationConfig.DurationSeconds = 5 * 60

MutationConfig.Definitions = {
	DoubleMoney = {
		Id = "DoubleMoney",
		DisplayName = "Money Surge",
		Description = "Fridge earns 2x money while active.",
		Weight = 45,
		MoneyMultiplier = 2,
		XpMultiplier = 1,
	},
	DoubleXp = {
		Id = "DoubleXp",
		DisplayName = "XP Feast",
		Description = "Food gives 2x Fridge XP while active.",
		Weight = 45,
		MoneyMultiplier = 1,
		XpMultiplier = 2,
	},
	GoldenFrost = {
		Id = "GoldenFrost",
		DisplayName = "Golden Frost",
		Description = "Fridge earns 1.5x money and gains 1.5x XP while active.",
		Weight = 10,
		MoneyMultiplier = 1.5,
		XpMultiplier = 1.5,
	},
}

return MutationConfig
