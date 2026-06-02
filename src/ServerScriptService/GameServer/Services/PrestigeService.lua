local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrestigeConfig = require(ReplicatedStorage.Game.Shared.Config.PrestigeConfig)

local PrestigeService = {}

PrestigeService._services = nil

function PrestigeService:Init(services)
	self._services = services
end

function PrestigeService:CanPrestige(profile)
	if not profile then
		return false
	end

	local fridgeLevel = profile.FridgeLevel or 1

	return fridgeLevel >= PrestigeConfig.RequiredFridgeLevel
end

function PrestigeService:GetPrestigeCount(profile)
	return profile.PrestigeCount or 0
end

function PrestigeService:GetMoneyMultiplier(profile)
	return PrestigeConfig.GetTotalMoneyMultiplier(self:GetPrestigeCount(profile))
end

function PrestigeService:GetXpMultiplier(profile)
	return PrestigeConfig.GetTotalXpMultiplier(self:GetPrestigeCount(profile))
end

function PrestigeService:ApplyPrestige(profile)
	if not self:CanPrestige(profile) then
		return false
	end

	profile.PrestigeCount = (profile.PrestigeCount or 0) + 1

	profile.Money = PrestigeConfig.MoneyResetTo
	profile.FridgeLevel = PrestigeConfig.FridgeLevelResetTo
	profile.FridgeXp = PrestigeConfig.FridgeXpResetTo

	return true
end

return PrestigeService
