local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("MutationGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "MutationGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0.04, 0)
frame.Size = UDim2.new(0, 320, 0, 70)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "MutationTitle"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 8)
title.Font = Enum.Font.GothamBold
title.Text = "NO ACTIVE MUTATION"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local timer = Instance.new("TextLabel")
timer.Name = "MutationTimer"
timer.BackgroundTransparency = 1
timer.Size = UDim2.new(1, -20, 0, 20)
timer.Position = UDim2.new(0, 10, 0, 40)
timer.Font = Enum.Font.Gotham
timer.Text = "Waiting for mutation..."
timer.TextScaled = true
timer.TextColor3 = Color3.fromRGB(180, 180, 180)
timer.Parent = frame

gui.Parent = StarterGui

print("Mutation UI placeholder created.")
