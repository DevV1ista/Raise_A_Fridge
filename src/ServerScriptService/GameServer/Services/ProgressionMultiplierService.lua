local ProgressionMultiplierService = {}

ProgressionMultiplierService._mutationService = nil

function ProgressionMultiplierService:Init(services)
	self._mutationService = services.MutationService
end

function ProgressionMultiplierService:GetMoneyMultiplier(player)
	local multiplier = 1

	if self._mutationService then
		multiplier *= self._mutationService:GetMoneyMultiplier(player)
	end

	return multiplier
end

function ProgressionMultiplierService:GetXpMultiplier(player)
	local multiplier = 1

	if self._mutationService then
		multiplier *= self._mutationService:GetXpMultiplier(player)
	end

	return multiplier
end

return ProgressionMultiplierService
