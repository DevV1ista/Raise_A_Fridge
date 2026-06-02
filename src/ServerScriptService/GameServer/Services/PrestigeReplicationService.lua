local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrestigeRemotes = require(ReplicatedStorage.Game.Shared.Remotes.PrestigeRemotes)
local PrestigeConfig = require(ReplicatedStorage.Game.Shared.Config.PrestigeConfig)

local PrestigeReplicationService = {}

PrestigeReplicationService._services = nil

function PrestigeReplicationService:Init(services)
	self._services = services
end

function PrestigeReplicationService:_getProfile(player)
	local dataService = self._services.DataService

	if not dataService or not dataService.GetProfile then
		return nil
	end

	return dataService:GetProfile(player)
end

function PrestigeReplicationService:_replicateState(player)
	local profile = self:_getProfile(player)

	if not profile then
		return
	end

	PrestigeRemotes:GetPrestigeStateRemote():FireClient(player, {
		PrestigeCount = profile.PrestigeCount or 0,
		FridgeLevel = profile.FridgeLevel or 1,
		RequiredLevel = PrestigeConfig.RequiredFridgeLevel,
		CanPrestige = self._services.PrestigeService:CanPrestige(profile),
	})
end

function PrestigeReplicationService:Start()
	PrestigeRemotes:GetRequestPrestigeRemote().OnServerInvoke = function(player)
		local profile = self:_getProfile(player)

		if not profile then
			return false, "PROFILE_MISSING"
		end

		local success = self._services.PrestigeService:ApplyPrestige(profile)

		if not success then
			return false, "PRESTIGE_REQUIREMENT_NOT_MET"
		end

		self:_replicateState(player)

		return true, {
			PrestigeCount = profile.PrestigeCount,
		}
	end

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self:_replicateState(player)
		end)
	end)
end

return PrestigeReplicationService
