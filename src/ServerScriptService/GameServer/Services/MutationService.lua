local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationConfig = require(ReplicatedStorage.Game.Shared.Config.MutationConfig)

local MutationService = {}

MutationService._playerMutations = {}
MutationService._started = false

local function getWeightedMutation()
	local totalWeight = 0

	for _, definition in pairs(MutationConfig.Definitions) do
		totalWeight += definition.Weight
	end

	local roll = Random.new():NextNumber(0, totalWeight)
	local cursor = 0

	for _, definition in pairs(MutationConfig.Definitions) do
		cursor += definition.Weight

		if roll <= cursor then
			return definition
		end
	end

	return MutationConfig.Definitions.DoubleMoney
end

function MutationService:GetActiveMutation(player)
	local state = self._playerMutations[player]

	if not state then
		return nil
	end

	if os.time() >= state.EndTime then
		self._playerMutations[player] = nil
		return nil
	end

	return state
end

function MutationService:GetMoneyMultiplier(player)
	local active = self:GetActiveMutation(player)

	if not active then
		return 1
	end

	return active.Definition.MoneyMultiplier or 1
end

function MutationService:GetXpMultiplier(player)
	local active = self:GetActiveMutation(player)

	if not active then
		return 1
	end

	return active.Definition.XpMultiplier or 1
end

function MutationService:TryRollMutation(player)
	if Random.new():NextNumber() > MutationConfig.Chance then
		return nil
	end

	local definition = getWeightedMutation()

	local mutationState = {
		Definition = definition,
		StartTime = os.time(),
		EndTime = os.time() + MutationConfig.DurationSeconds,
	}

	self._playerMutations[player] = mutationState

	return mutationState
end

function MutationService:_startPlayerLoop(player)
	task.spawn(function()
		while player.Parent do
			task.wait(MutationConfig.RollIntervalSeconds)

			local active = self:GetActiveMutation(player)

			if not active then
				self:TryRollMutation(player)
			end
		end
	end)
end

function MutationService:Start()
	if self._started then
		return
	end

	self._started = true

	Players.PlayerAdded:Connect(function(player)
		self:_startPlayerLoop(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self._playerMutations[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		self:_startPlayerLoop(player)
	end
end

return MutationService
