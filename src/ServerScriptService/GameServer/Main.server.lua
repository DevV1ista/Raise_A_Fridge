local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
local StateService = require(script.Parent.Services.StateService)
local RollService = require(script.Parent.Services.RollService)
local PlotService = require(script.Parent.Services.PlotService)

print("Raise A Fridge server booting...")

PlotService.Init()
StateService.Init()

local function getState(player)
	return StateService.getPublicState(player)
end

local function roll(player)
	return RollService.roll(player)
end

local function feed(player, inventoryIndex)
	return StateService.feedFood(player, inventoryIndex)
end

Remotes.GetState.OnServerInvoke = getState
Remotes.RollRequested.OnServerInvoke = roll
Remotes.FeedRequested.OnServerInvoke = feed

local accumulator = 0
RunService.Heartbeat:Connect(function(deltaTime)
	accumulator += deltaTime
	if accumulator >= 1 then
		StateService.tickMoney(accumulator)
		accumulator = 0
	end
end)
