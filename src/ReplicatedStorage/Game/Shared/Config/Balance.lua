local Balance = {}

Balance.RollCooldownSeconds = 1.25
Balance.InventoryLimit = 80
Balance.BaseCloverStartChance = 0.05
Balance.BaseCloverContinueChance = 0.20
Balance.StartingCloverCap = 32

function Balance.getXpRequiredForLevel(level)
	return math.floor(25 * (level ^ 1.6))
end

function Balance.getMoneyPerSecond(level, multipliers)
	multipliers = multipliers or {}
	local prestige = multipliers.prestige or 1
	local permanent = multipliers.permanent or 1
	local upgrade = multipliers.upgrade or 1
	local mutation = multipliers.mutation or 1
	return math.floor(5 * (level ^ 1.35) * prestige * permanent * upgrade * mutation)
end

function Balance.getPrestigeMultiplier(prestigeLevel)
	if prestigeLevel <= 0 then
		return 1
	end
	return 1 + prestigeLevel * 0.55 + ((prestigeLevel ^ 1.15) * 0.08)
end

function Balance.getEffectiveLuck(totalLuck)
	return math.max(1, totalLuck ^ 0.75)
end

return Balance
