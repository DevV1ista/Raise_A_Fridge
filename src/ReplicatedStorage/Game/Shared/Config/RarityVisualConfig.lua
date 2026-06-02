local RarityVisualConfig = {}

RarityVisualConfig.Definitions = {
	Common = {
		DisplayName = "Common",
		RevealDuration = 0.65,
		ShakeIntensity = 0,
		UseBurst = false,
	},
	Uncommon = {
		DisplayName = "Uncommon",
		RevealDuration = 0.8,
		ShakeIntensity = 0.05,
		UseBurst = false,
	},
	Rare = {
		DisplayName = "Rare",
		RevealDuration = 1,
		ShakeIntensity = 0.12,
		UseBurst = true,
	},
	Epic = {
		DisplayName = "Epic",
		RevealDuration = 1.2,
		ShakeIntensity = 0.2,
		UseBurst = true,
	},
	Legendary = {
		DisplayName = "Legendary",
		RevealDuration = 1.5,
		ShakeIntensity = 0.32,
		UseBurst = true,
	},
	Mythic = {
		DisplayName = "Mythic",
		RevealDuration = 1.8,
		ShakeIntensity = 0.45,
		UseBurst = true,
	},
	Secret = {
		DisplayName = "Secret",
		RevealDuration = 2.2,
		ShakeIntensity = 0.6,
		UseBurst = true,
	},
}

function RarityVisualConfig.GetDefinition(rarity)
	return RarityVisualConfig.Definitions[rarity] or RarityVisualConfig.Definitions.Common
end

return RarityVisualConfig
