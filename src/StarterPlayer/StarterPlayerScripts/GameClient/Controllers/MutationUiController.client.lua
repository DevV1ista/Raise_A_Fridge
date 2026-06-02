local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local MutationRemotes = require(ReplicatedStorage.Game.Shared.Remotes.MutationRemotes)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("MutationGui", 30)

if not gui then
	warn("MutationGui missing.")
	return
end

local container = gui:WaitForChild("Container")
local titleLabel = container:WaitForChild("MutationTitle")
local timerLabel = container:WaitForChild("MutationTimer")

local activeMutation = nil

local function updateUi()
	if not activeMutation then
		titleLabel.Text = "NO ACTIVE MUTATION"
		timerLabel.Text = "Waiting for mutation..."
		return
	end

	local remaining = math.max(0, activeMutation.EndTime - os.time())
	local minutes = math.floor(remaining / 60)
	local seconds = remaining % 60

	titleLabel.Text = string.upper(activeMutation.DisplayName)
	timerLabel.Text = string.format("%02d:%02d remaining", minutes, seconds)
end

MutationRemotes:GetMutationChangedRemote().OnClientEvent:Connect(function(data)
	activeMutation = data
	updateUi()
end)

task.spawn(function()
	while true do
		task.wait(1)
		updateUi()
	end
end)
