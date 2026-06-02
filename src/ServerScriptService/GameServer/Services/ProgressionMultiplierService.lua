local ProgressionMultiplierService = {}

ProgressionMultiplierService._mutationService = nil
ProgressionMultiplierService._prestigeService = nil
ProgressionMultiplierService._dataService = nil

function ProgressionMultiplierService:Init(services)
	self._mutationService = services.MutationService
	self._prestigeService = services.PrestigeService
	self._dataService = services.DataService
end

function ProgressionMultiplierService:_getProfile(player)
	if not self._dataService then
		return nil
	end

	if self._dataService.GetProfile then
		return self._dataService:GetProfile(player)
	end

	return nil
end

function ProgressionMultiplierService:GetMoneyMultiplier(player)
	local multiplier = 1
	local profile = self:_getProfile(player)

	if self._mutationService then
		multiplier *= self._mutationService:GetMoneyMultiplier(player)
	end

	if self._prestigeService and profile then
		multiplier *= self._prestigeService:GetMoneyMultiplier(profile)
	end

	return multiplier
end

function ProgressionMultiplierService:GetXpMultiplier(player)
	local multiplier = 1
	local profile = self:_getProfile(player)

	if self._mutationService then
		multiplier *= self._mutationService:GetXpMultiplier(player)
	end

	if self._prestigeService and profile then
		multiplier *= self._prestigeService:GetXpMultiplier(profile)
	end

	return multiplier
end

return ProgressionMultiplierService
