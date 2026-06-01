local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PlotService = {}
local assigned = {}

local function ensureWorld()
	local world = Workspace:FindFirstChild("RaiseAFridgeWorld")
	if not world then
		world = Instance.new("Folder")
		world.Name = "RaiseAFridgeWorld"
		world.Parent = Workspace
	end
	return world
end

local function createPlot(index)
	local world = ensureWorld()
	local plot = Instance.new("Model")
	plot.Name = "Plot" .. index
	plot.Parent = world

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(24, 1, 24)
	base.Position = Vector3.new(math.cos(index * math.pi / 4) * 45, 0.5, math.sin(index * math.pi / 4) * 45)
	base.Anchored = true
	base.Parent = plot

	local fridge = Instance.new("Part")
	fridge.Name = "Fridge"
	fridge.Size = Vector3.new(5, 8, 4)
	fridge.Position = base.Position + Vector3.new(0, 4.5, 0)
	fridge.Anchored = true
	fridge.Parent = plot

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "FeedPrompt"
	prompt.ActionText = "Feed Fridge"
	prompt.ObjectText = "Fridge"
	prompt.HoldDuration = 0
	prompt.Parent = fridge

	return plot
end

local function getAvailablePlot()
	local world = ensureWorld()
	for index = 1, 8 do
		local plot = world:FindFirstChild("Plot" .. index) or createPlot(index)
		local taken = false
		for _, existing in pairs(assigned) do
			if existing == plot then
				taken = true
				break
			end
		end
		if not taken then
			return plot
		end
	end
	return nil
end

function PlotService.getPlot(player)
	return assigned[player]
end

function PlotService.assign(player)
	local plot = getAvailablePlot()
	if not plot then
		return
	end
	assigned[player] = plot
	plot:SetAttribute("OwnerUserId", player.UserId)
	plot:SetAttribute("OwnerName", player.Name)
	local fridge = plot:FindFirstChild("Fridge")
	if fridge then
		fridge:SetAttribute("OwnerName", player.Name)
	end
end

function PlotService.Init()
	Players.PlayerAdded:Connect(function(player)
		PlotService.assign(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		assigned[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		PlotService.assign(player)
	end
end

return PlotService
