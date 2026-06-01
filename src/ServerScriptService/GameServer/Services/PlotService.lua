local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Game.Shared.Util)

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

local function ensureFridgeBillboard(fridge)
	local billboard = fridge:FindFirstChild("FridgeBillboard")
	if not billboard then
		billboard = Instance.new("BillboardGui")
		billboard.Name = "FridgeBillboard"
		billboard.Size = UDim2.new(0, 260, 0, 120)
		billboard.StudsOffset = Vector3.new(0, 6.5, 0)
		billboard.AlwaysOnTop = true
		billboard.MaxDistance = 90
		billboard.Parent = fridge

		local holder = Instance.new("Frame")
		holder.Name = "Holder"
		holder.Size = UDim2.fromScale(1, 1)
		holder.BackgroundTransparency = 0.25
		holder.Parent = billboard

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 2)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Parent = holder

		local function makeLabel(name, text)
			local label = Instance.new("TextLabel")
			label.Name = name
			label.Size = UDim2.new(1, -12, 0, 26)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.Text = text
			label.Parent = holder
			return label
		end

		makeLabel("OwnerLabel", "Fridge")
		makeLabel("LevelLabel", "Level 1")
		makeLabel("MpsLabel", "$5/s")
		makeLabel("PrestigeLabel", "Prestige 0")
	end
	return billboard
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
	ensureFridgeBillboard(fridge)

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
		ensureFridgeBillboard(fridge)
	end
end

function PlotService.updateFridgeDisplay(player, state)
	local plot = assigned[player]
	if not plot then
		return
	end
	local fridge = plot:FindFirstChild("Fridge")
	if not fridge then
		return
	end
	local billboard = ensureFridgeBillboard(fridge)
	local holder = billboard:FindFirstChild("Holder")
	if not holder then
		return
	end
	local ownerLabel = holder:FindFirstChild("OwnerLabel")
	local levelLabel = holder:FindFirstChild("LevelLabel")
	local mpsLabel = holder:FindFirstChild("MpsLabel")
	local prestigeLabel = holder:FindFirstChild("PrestigeLabel")
	if ownerLabel then
		ownerLabel.Text = player.Name .. "'s Fridge"
	end
	if levelLabel then
		levelLabel.Text = "Level " .. state.fridgeLevel
	end
	if mpsLabel then
		mpsLabel.Text = "$" .. Util.formatNumber(state.moneyPerSecond) .. "/s"
	end
	if prestigeLabel then
		prestigeLabel.Text = "Prestige " .. state.prestige
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
