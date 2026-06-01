local UpgradeRegistry = {}

UpgradeRegistry.Upgrades = {
	UnlockRareFoods = {
		displayName = "Rare Food Unlock",
		description = "Unlocks Rare foods in the roll pool.",
		maxLevel = 1,
		baseCost = 250,
		costGrowth = 1,
		effects = {
			unlockRarity = "Rare",
		},
	},
	LuckyMagnet = {
		displayName = "Lucky Magnet",
		description = "Increases effective luck for rare rolls.",
		maxLevel = 10,
		baseCost = 120,
		costGrowth = 1.85,
		effects = {
			luckBonusPerLevel = 0.12,
		},
	},
	CoolerCompressor = {
		displayName = "Cooler Compressor",
		description = "Increases money earned per second.",
		maxLevel = 10,
		baseCost = 180,
		costGrowth = 1.9,
		effects = {
			moneyMultiplierPerLevel = 0.08,
		},
	},
	FeedingFunnel = {
		displayName = "Feeding Funnel",
		description = "Food gives more Fridge XP when fed.",
		maxLevel = 10,
		baseCost = 160,
		costGrowth = 1.85,
		effects = {
			xpMultiplierPerLevel = 0.10,
		},
	},
	CloverFreezer = {
		displayName = "Clover Freezer",
		description = "Raises maximum Clover luck chain cap.",
		maxLevel = 6,
		baseCost = 300,
		costGrowth = 2.2,
		effects = {
			cloverCapMultiplierPerLevel = 2,
		},
	},
}

UpgradeRegistry.Order = {
	"UnlockRareFoods",
	"LuckyMagnet",
	"CoolerCompressor",
	"FeedingFunnel",
	"CloverFreezer",
}

function UpgradeRegistry.getUpgrade(upgradeId)
	return UpgradeRegistry.Upgrades[upgradeId]
end

function UpgradeRegistry.getCost(upgradeId, currentLevel)
	local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
	if not upgrade then
		return nil
	end
	return math.floor(upgrade.baseCost * (upgrade.costGrowth ^ currentLevel))
end

function UpgradeRegistry.getPublicUpgrades(levels)
	local result = {}
	for _, upgradeId in ipairs(UpgradeRegistry.Order) do
		local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
		local level = levels[upgradeId] or 0
		result[upgradeId] = {
			displayName = upgrade.displayName,
			description = upgrade.description,
			level = level,
			maxLevel = upgrade.maxLevel,
			cost = level >= upgrade.maxLevel and nil or UpgradeRegistry.getCost(upgradeId, level),
			effects = upgrade.effects,
		}
	end
	return result
end

return UpgradeRegistry
