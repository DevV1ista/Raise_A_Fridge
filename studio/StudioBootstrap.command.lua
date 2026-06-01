-- Paste this once into Roblox Studio Command Bar, press Enter, save the place.
-- UI/map are intentionally Studio-owned so you can edit them freely.

local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local existing = StarterGui:FindFirstChild("FridgeHudGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FridgeHudGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = StarterGui

local top = Instance.new("Frame")
top.Name = "TopBar"
top.Size = UDim2.new(1, 0, 0, 64)
top.BackgroundTransparency = 0.2
top.Parent = gui

local function label(name, text, x)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = UDim2.new(0, 220, 1, 0)
	l.Position = UDim2.new(0, x, 0, 0)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.Text = text
	l.Parent = top
	return l
end

label("MoneyLabel", "$0", 16)
label("FridgeLabel", "Fridge Lv. 1", 250)
label("MpsLabel", "$5/s", 520)
label("PrestigeLabel", "Prestige 0", 750)

local roll = Instance.new("TextButton")
roll.Name = "RollButton"
roll.Size = UDim2.new(0, 260, 0, 72)
roll.Position = UDim2.new(0.5, -130, 1, -100)
roll.TextScaled = true
roll.Text = "ROLL"
roll.Parent = gui

local feed = Instance.new("TextButton")
feed.Name = "FeedButton"
feed.Size = UDim2.new(0, 180, 0, 56)
feed.Position = UDim2.new(1, -210, 1, -90)
feed.TextScaled = true
feed.Text = "FEED"
feed.Parent = gui

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(0, 520, 0, 48)
status.Position = UDim2.new(0.5, -260, 1, -160)
status.BackgroundTransparency = 0.25
status.TextScaled = true
status.Text = "Ready"
status.Parent = gui

local inv = Instance.new("ScrollingFrame")
inv.Name = "InventoryList"
inv.Size = UDim2.new(0, 260, 0, 340)
inv.Position = UDim2.new(1, -280, 0.5, -170)
inv.CanvasSize = UDim2.new(0, 0, 10, 0)
inv.AutomaticCanvasSize = Enum.AutomaticSize.Y
inv.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = inv

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
