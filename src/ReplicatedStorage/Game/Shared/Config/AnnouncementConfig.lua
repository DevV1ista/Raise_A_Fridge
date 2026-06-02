local AnnouncementConfig = {}

AnnouncementConfig.MinimumGlobalRarity = "Legendary"

AnnouncementConfig.RarityPriority = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
	Secret = 7,
}

AnnouncementConfig.Definitions = {
	Legendary = {
		DisplayPrefix = "LEGENDARY ROLL",
		Duration = 4,
	},
	Mythic = {
		DisplayPrefix = "MYTHIC ROLL",
		Duration = 5,
	},
	Secret = {
		DisplayPrefix = "SECRET FOUND",
		Duration = 7,
	},
}

function AnnouncementConfig.ShouldAnnounce(rarity)
	local priority = AnnouncementConfig.RarityPriority[rarity] or 0
	local minimum = AnnouncementConfig.RarityPriority[AnnouncementConfig.MinimumGlobalRarity] or math.huge

	return priority >= minimum
end

function AnnouncementConfig.GetDefinition(rarity)
	return AnnouncementConfig.Definitions[rarity]
end

return AnnouncementConfig
