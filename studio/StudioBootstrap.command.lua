-- TEMPORARY Studio bootstrap. Paste this once into Roblox Studio Command Bar, press Enter, save the place.
-- This is only for initial placeholder UI/map. It can be deleted from the repo after the templates exist in Studio.
-- Food tool visuals are read from ServerStorage.Game.Assets.FoodModels first,
-- then ReplicatedStorage.Game.Assets.FoodModels as fallback.
-- Name each model by FoodId, for example Toast, Apple, PizzaSlice, GoldenApple.

local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local existing = StarterGui:FindFirstChild("FridgeHudGui")
if existing then
	existing:Destroy()
end

local function ensurePath(root, names)
	local current = root
	for _, name in ipairs(names) do
		local child = current:FindFirstChild(name)
		if not child then
			child = Instance.new("Folder")
			child.Name = name
			child.Parent = current
		end
		current = child
	end
	return current
end

ensurePath(ServerStorage, { "Game", "Assets", "FoodModels" })
ensurePath(ReplicatedStorage, { "Game", "Assets", "FoodModels" })

local gui = Instance.new("ScreenGui")
gui.Name = "FridgeHudGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = StarterGui

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 86)
top.BackgroundTransparency = 0.2
top.Parent = gui

local function label(parent, name, text, position, size)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size or UDim2.new(0, 220, 0, 34)
	l.Position = position
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.Text = text
	l.TextColor3 = Color3.fromRGB(255, 255, 255)
	l.TextStrokeTransparency = 0
	l.Font = Enum.Font.GothamBlack
	l.Parent = parent
	return l
end

local function makeButton(parent, name, text, position, size)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.TextScaled = true
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextStrokeTransparency = 0
	button.Font = Enum.Font.GothamBlack
	button.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(5, 8, 16)
	stroke.Thickness = 3
	stroke.Parent = button

	return button
end

label(top, "MoneyLabel", "$0", UDim2.new(0, 16, 0, 0))
label(top, "PrestigeLabel", "Prestige 0", UDim2.new(0, 250, 0, 0))
label(top, "MpsLabel", "$5/s", UDim2.new(0, 500, 0, 0))
label(top, "MultiplierLabel", "XP x1.00 | Luck x1.00 | Clover x32", UDim2.new(0, 16, 0, 42), UDim2.new(0, 620, 0, 34))

makeButton(gui, "SkillTreeButton", "SKILLS", UDim2.new(0.5, 150, 1, -100), UDim2.new(0, 180, 0, 72))

local roll = makeButton(gui, "RollButton", "ROLL", UDim2.new(0.5, -130, 1, -100), UDim2.new(0, 260, 0, 72))
roll.BackgroundColor3 = Color3.fromRGB(255, 185, 35)

local status = label(gui, "Status", "Ready", UDim2.new(0.5, -310, 1, -160), UDim2.new(0, 620, 0, 48))
status.BackgroundTransparency = 0.25
status.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local panel = Instance.new("Frame")
panel.Name = "InventoryPanel"
panel.Size = UDim2.new(0, 260, 0, 380)
panel.Position = UDim2.new(1, -280, 0.5, -190)
panel.BackgroundTransparency = 0.2
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
panel.Parent = gui

local title = label(panel, "InventoryTitle", "Food Inventory", UDim2.new(0, 8, 0, 3), UDim2.new(1, -48, 0, 36))
title.TextStrokeTransparency = 0.2

local toggle = makeButton(panel, "InventoryToggle", "-", UDim2.new(1, -38, 0, 4), UDim2.new(0, 34, 0, 34))
toggle.BackgroundColor3 = Color3.fromRGB(50, 55, 75)

local inv = Instance.new("ScrollingFrame")
inv.Name = "InventoryList"
inv.Size = UDim2.new(1, -12, 1, -48)
inv.Position = UDim2.new(0, 6, 0, 44)
inv.CanvasSize = UDim2.new(0, 0, 10, 0)
inv.AutomaticCanvasSize = Enum.AutomaticSize.Y
inv.BackgroundTransparency = 1
inv.Parent = panel

local invLayout = Instance.new("UIListLayout")
invLayout.Padding = UDim.new(0, 6)
invLayout.Parent = inv

local overlay = Instance.new("Frame")
overlay.Name = "SkillTreeOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.Position = UDim2.fromScale(0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.38
overlay.Visible = false
overlay.ZIndex = 50
overlay.Parent = gui

label(overlay, "SkillTreeMoneyLabel", "🪙 0", UDim2.new(0.5, -260, 0, 40), UDim2.new(0, 240, 0, 56)).ZIndex = 55
label(overlay, "SkillTreeDiceLabel", "🎲 0", UDim2.new(0.5, 20, 0, 40), UDim2.new(0, 220, 0, 56)).ZIndex = 55
local statusLabel = label(overlay, "SkillTreeStatusLabel", "Buy connected skills to unlock new paths", UDim2.new(0.5, -350, 1, -190), UDim2.new(0, 700, 0, 38))
statusLabel.ZIndex = 55
statusLabel.TextScaled = true

local canvas = Instance.new("Frame")
canvas.Name = "SkillTreeCanvas"
canvas.Size = UDim2.fromScale(1, 1)
canvas.BackgroundTransparency = 1
canvas.ZIndex = 51
canvas.Parent = overlay

local close = makeButton(overlay, "SkillTreeCloseButton", "CLOSE", UDim2.new(0.5, -125, 1, -92), UDim2.new(0, 250, 0, 72))
close.BackgroundColor3 = Color3.fromRGB(255, 35, 35)
close.ZIndex = 60

local world = Workspace:FindFirstChild("RaiseAFridgeWorld") or Instance.new("Folder")
world.Name = "RaiseAFridgeWorld"
world.Parent = Workspace

local center = world:FindFirstChild("Center") or Instance.new("Part")
center.Name = "Center"
center.Size = Vector3.new(30, 1, 30)
center.Position = Vector3.new(0, 0, 0)
center.Anchored = true
center.Parent = world

print("Raise A Fridge Studio bootstrap complete. Save the place now.")
