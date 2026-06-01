local UpgradeRegistry = {}

-- Slime-RNG-inspired progression shape: one cheap root, then branches for Luck, Income,
-- Feeding and Clover chain power. UI objects can use row/column to render a real tree later.
UpgradeRegistry.Nodes = {
	FridgeCore = {
		displayName = "Fridge Core",
		description = "Starts the fridge upgrade tree.",
		branch = "Core",
		row = 1,
		column = 3,
		maxLevel = 1,
		baseCost = 75,
		costGrowth = 1,
		requires = {},
		effects = {
			moneyMultiplierPerLevel = 0.05,
			xpMultiplierPerLevel = 0.05,
		},
	},

	LuckyMagnet1 = {
		displayName = "Lucky Magnet I",
		description = "Small luck boost for better rolls.",
		branch = "Luck",
		row = 2,
		column = 2,
		maxLevel = 5,
		baseCost = 120,
		costGrowth = 1.75,
		requires = { FridgeCore = 1 },
		effects = {
			luckBonusPerLevel = 0.08,
		},
	},
	UnlockRareFoods = {
		displayName = "Rare Food Path",
		description = "Unlocks Rare foods in the roll pool.",
		branch = "Luck",
		row = 3,
		column = 2,
		maxLevel = 1,
		baseCost = 450,
		costGrowth = 1,
		requires = { LuckyMagnet1 = 3 },
		effects = {
			unlockRarity = "Rare",
		},
	},
	LuckyMagnet2 = {
		displayName = "Lucky Magnet II",
		description = "Stronger luck boost after unlocking Rare foods.",
		branch = "Luck",
		row = 4,
		column = 2,
		maxLevel = 8,
		baseCost = 900,
		costGrowth = 1.9,
		requires = { UnlockRareFoods = 1 },
		effects = {
			luckBonusPerLevel = 0.12,
		},
	},
	UnlockEpicFoods = {
		displayName = "Epic Food Path",
		description = "Unlocks Epic foods in the roll pool.",
		branch = "Luck",
		row = 5,
		column = 2,
		maxLevel = 1,
		baseCost = 6500,
		costGrowth = 1,
		requires = { LuckyMagnet2 = 5, UnlockRareFoods = 1 },
		effects = {
			unlockRarity = "Epic",
		},
	},

	CoolerCompressor1 = {
		displayName = "Compressor I",
		description = "Increases money earned per second.",
		branch = "Income",
		row = 2,
		column = 3,
		maxLevel = 6,
		baseCost = 160,
		costGrowth = 1.8,
		requires = { FridgeCore = 1 },
		effects = {
			moneyMultiplierPerLevel = 0.07,
		},
	},
	CoinVent = {
		displayName = "Coin Vent",
		description = "More money/sec after building basic income.",
		branch = "Income",
		row = 3,
		column = 3,
		maxLevel = 6,
		baseCost = 600,
		costGrowth = 1.95,
		requires = { CoolerCompressor1 = 3 },
		effects = {
			moneyMultiplierPerLevel = 0.10,
		},
	},
	GoldenMotor = {
		displayName = "Golden Motor",
		description = "Expensive income node for stronger idle scaling.",
		branch = "Income",
		row = 4,
		column = 3,
		maxLevel = 4,
		baseCost = 2500,
		costGrowth = 2.15,
		requires = { CoinVent = 4 },
		effects = {
			moneyMultiplierPerLevel = 0.18,
		},
	},

	FeedingFunnel1 = {
		displayName = "Feeding Funnel I",
		description = "Food gives more Fridge XP when fed.",
		branch = "Feeding",
		row = 2,
		column = 4,
		maxLevel = 6,
		baseCost = 140,
		costGrowth = 1.8,
		requires = { FridgeCore = 1 },
		effects = {
			xpMultiplierPerLevel = 0.09,
		},
	},
	FlavorInjector = {
		displayName = "Flavor Injector",
		description = "Improves XP scaling for faster Fridge levels.",
		branch = "Feeding",
		row = 3,
		column = 4,
		maxLevel = 6,
		baseCost = 520,
		costGrowth = 1.95,
		requires = { FeedingFunnel1 = 3 },
		effects = {
			xpMultiplierPerLevel = 0.13,
		},
	},
	DeepFreezeXP = {
		displayName = "Deep Freeze XP",
		description = "Late feeding node for big XP gains.",
		branch = "Feeding",
		row = 4,
		column = 4,
		maxLevel = 4,
		baseCost = 2200,
		costGrowth = 2.1,
		requires = { FlavorInjector = 4 },
		effects = {
			xpMultiplierPerLevel = 0.22,
		},
	},

	CloverFreezer1 = {
		displayName = "Clover Freezer I",
		description = "Raises maximum Clover luck chain cap.",
		branch = "Clover",
		row = 3,
		column = 1,
		maxLevel = 3,
		baseCost = 800,
		costGrowth = 2.25,
		requires = { LuckyMagnet1 = 2 },
		effects = {
			cloverCapMultiplierPerLevel = 2,
		},
	},
	CloverFreezer2 = {
		displayName = "Clover Freezer II",
		description = "Pushes Clover chains toward huge dopamine rolls.",
		branch = "Clover",
		row = 4,
		column = 1,
		maxLevel = 3,
		baseCost = 4500,
		costGrowth = 2.4,
		requires = { CloverFreezer1 = 3, UnlockRareFoods = 1 },
		effects = {
			cloverCapMultiplierPerLevel = 2,
		},
	},
}

UpgradeRegistry.Order = {
	"FridgeCore",
	"LuckyMagnet1",
	"CoolerCompressor1",
	"FeedingFunnel1",
	"UnlockRareFoods",
	"CloverFreezer1",
	"CoinVent",
	"FlavorInjector",
	"LuckyMagnet2",
	"CloverFreezer2",
	"GoldenMotor",
	"DeepFreezeXP",
	"UnlockEpicFoods",
}

UpgradeRegistry.Branches = {
	"Core",
	"Luck",
	"Clover",
	"Income",
	"Feeding",
}

function UpgradeRegistry.getUpgrade(upgradeId)
	return UpgradeRegistry.Nodes[upgradeId]
end

function UpgradeRegistry.getCost(upgradeId, currentLevel)
	local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
	if not upgrade then
		return nil
	end
	return math.floor(upgrade.baseCost * (upgrade.costGrowth ^ currentLevel))
end

function UpgradeRegistry.areRequirementsMet(upgradeId, levels)
	local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
	if not upgrade then
		return false
	end
	for requiredId, requiredLevel in pairs(upgrade.requires or {}) do
		if (levels[requiredId] or 0) < requiredLevel then
			return false
		end
	end
	return true
end

function UpgradeRegistry.getRequirementText(upgradeId)
	local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
	if not upgrade then
		return ""
	end
	local requirements = {}
	for requiredId, requiredLevel in pairs(upgrade.requires or {}) do
		local required = UpgradeRegistry.getUpgrade(requiredId)
		local name = required and required.displayName or requiredId
		table.insert(requirements, name .. " Lv. " .. requiredLevel)
	end
	table.sort(requirements)
	return table.concat(requirements, ", ")
end

function UpgradeRegistry.getTotalEffect(levels, effectName)
	local total = 0
	for upgradeId, level in pairs(levels) do
		local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
		local value = upgrade and upgrade.effects and upgrade.effects[effectName]
		if value then
			total += value * level
		end
	end
	return total
end

function UpgradeRegistry.getCloverCapMultiplier(levels)
	local multiplier = 1
	for upgradeId, level in pairs(levels) do
		local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
		local value = upgrade and upgrade.effects and upgrade.effects.cloverCapMultiplierPerLevel
		if value then
			for _ = 1, level do
				multiplier *= value
			end
		end
	end
	return multiplier
end

function UpgradeRegistry.applyUnlockEffects(levels, unlockedRarities)
	for upgradeId, level in pairs(levels) do
		if level > 0 then
			local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
			local rarity = upgrade and upgrade.effects and upgrade.effects.unlockRarity
			if rarity then
				unlockedRarities[rarity] = true
			end
		end
	end
end

function UpgradeRegistry.getPublicUpgrades(levels)
	local result = {}
	for _, upgradeId in ipairs(UpgradeRegistry.Order) do
		local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
		local level = levels[upgradeId] or 0
		local requirementsMet = UpgradeRegistry.areRequirementsMet(upgradeId, levels)
		result[upgradeId] = {
			displayName = upgrade.displayName,
			description = upgrade.description,
			branch = upgrade.branch,
			row = upgrade.row,
			column = upgrade.column,
			level = level,
			maxLevel = upgrade.maxLevel,
			cost = level >= upgrade.maxLevel and nil or UpgradeRegistry.getCost(upgradeId, level),
			effects = upgrade.effects,
			requires = upgrade.requires,
			requirementText = UpgradeRegistry.getRequirementText(upgradeId),
			unlocked = requirementsMet,
			completed = level >= upgrade.maxLevel,
		}
	end
	return result
end

return UpgradeRegistry
