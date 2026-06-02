local Prestige = {}

Prestige.RequiredFridgeLevel = 25

function Prestige.getRewardMultiplier(prestigeLevel)
	local level = math.max(0, prestigeLevel or 0)
	return 1 + level * 0.55 + ((level ^ 1.15) * 0.08)
end

function Prestige.getNextPreview(currentPrestige)
	local nextPrestige = math.max(0, currentPrestige or 0) + 1
	return {
		prestige = nextPrestige,
		multiplier = Prestige.getRewardMultiplier(nextPrestige),
	}
end

return Prestige
