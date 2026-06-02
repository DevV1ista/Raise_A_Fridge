local PrestigeConfig = {}

PrestigeConfig.RequiredFridgeLevel = 25
PrestigeConfig.MoneyResetTo = 0
PrestigeConfig.FridgeLevelResetTo = 1
PrestigeConfig.FridgeXpResetTo = 0

PrestigeConfig.BaseMoneyMultiplierBonus = 0.5
PrestigeConfig.BaseXpMultiplierBonus = 0.5
PrestigeConfig.MaxSinglePrestigeBonus = 1.2
PrestigeConfig.BonusGrowthPerPrestige = 0.1

function PrestigeConfig.GetPrestigeBonus(prestigeCount)
	local bonus = PrestigeConfig.BaseMoneyMultiplierBonus + (prestigeCount * PrestigeConfig.BonusGrowthPerPrestige)
	return math.min(bonus, PrestigeConfig.MaxSinglePrestigeBonus)
end

function PrestigeConfig.GetTotalMoneyMultiplier(prestigeCount)
	if prestigeCount <= 0 then
		return 1
	end

	return 1 + (prestigeCount * PrestigeConfig.GetPrestigeBonus(prestigeCount - 1))
end

function PrestigeConfig.GetTotalXpMultiplier(prestigeCount)
	if prestigeCount <= 0 then
		return 1
	end

	return 1 + (prestigeCount * PrestigeConfig.GetPrestigeBonus(prestigeCount - 1))
end

return PrestigeConfig
