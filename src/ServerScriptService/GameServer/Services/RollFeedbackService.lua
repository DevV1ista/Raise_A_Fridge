local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RollFeedbackRemotes = require(ReplicatedStorage.Game.Shared.Remotes.RollFeedbackRemotes)
local RarityVisualConfig = require(ReplicatedStorage.Game.Shared.Config.RarityVisualConfig)

local RollFeedbackService = {}

function RollFeedbackService:ReplicateReveal(player, foodData)
	if not player or not foodData then
		return
	end

	local rarity = foodData.Rarity or "Common"
	local visualDefinition = RarityVisualConfig.GetDefinition(rarity)

	RollFeedbackRemotes:GetRevealRemote():FireClient(player, {
		FoodName = foodData.Name or "Unknown Food",
		Rarity = rarity,
		RevealDuration = visualDefinition.RevealDuration,
		ShakeIntensity = visualDefinition.ShakeIntensity,
		UseBurst = visualDefinition.UseBurst,
	})
end

return RollFeedbackService
