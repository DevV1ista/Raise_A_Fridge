local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnnouncementConfig = require(ReplicatedStorage.Game.Shared.Config.AnnouncementConfig)
local AnnouncementRemotes = require(ReplicatedStorage.Game.Shared.Remotes.AnnouncementRemotes)

local AnnouncementService = {}

function AnnouncementService:BroadcastRareRoll(player, foodData)
	if not player or not foodData then
		return
	end

	local rarity = foodData.Rarity or "Common"

	if not AnnouncementConfig.ShouldAnnounce(rarity) then
		return
	end

	local definition = AnnouncementConfig.GetDefinition(rarity)

	if not definition then
		return
	end

	local payload = {
		PlayerName = player.Name,
		FoodName = foodData.Name or "Unknown Food",
		Rarity = rarity,
		DisplayPrefix = definition.DisplayPrefix,
		Duration = definition.Duration,
	}

	AnnouncementRemotes:GetGlobalAnnouncementRemote():FireAllClients(payload)
end

return AnnouncementService
