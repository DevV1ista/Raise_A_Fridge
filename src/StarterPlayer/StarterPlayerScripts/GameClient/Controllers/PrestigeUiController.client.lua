local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local PrestigeRemotes = require(ReplicatedStorage.Game.Shared.Remotes.PrestigeRemotes)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("PrestigeGui", 30)

if not gui then
	warn("PrestigeGui missing.")
	return
end

local container = gui:WaitForChild("Container")
local info = container:WaitForChild("Info")
local button = container:WaitForChild("PrestigeButton")

local currentState = nil

local function refreshUi()
	if not currentState then
		button.Text = "LOADING"
		button.AutoButtonColor = false
		return
	end

	info.Text = string.format(
		"Prestiges: %d\nFridge Level: %d/%d",
		currentState.PrestigeCount,
		currentState.FridgeLevel,
		currentState.RequiredLevel
	)

	if currentState.CanPrestige then
		button.Text = "PRESTIGE READY"
		button.AutoButtonColor = true
	else
		button.Text = "LEVEL TOO LOW"
		button.AutoButtonColor = false
	end
end

PrestigeRemotes:GetPrestigeStateRemote().OnClientEvent:Connect(function(data)
	currentState = data
	refreshUi()
end)

button.MouseButton1Click:Connect(function()
	if not currentState or not currentState.CanPrestige then
		return
	end

	local success = PrestigeRemotes:GetRequestPrestigeRemote():InvokeServer()

	if success then
		button.Text = "PRESTIGED"
	end
end)

refreshUi()
