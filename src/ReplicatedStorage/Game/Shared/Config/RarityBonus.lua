local RarityBonus = {}

-- Permanent bonuses are earned when feeding rare late-game food.
-- They persist through prestige and multiply the most important progression systems.
RarityBonus.ByRarity = {
	Mythic = 0.01,
	Secret = 0.025,
}

function RarityBonus.getBonusForRarity(rarity)
	return RarityBonus.ByRarity[rarity] or 0
end

function RarityBonus.getTotalMultiplier(permanentBonus)
	return 1 + math.max(0, permanentBonus or 0)
end

return RarityBonus
