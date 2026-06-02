local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("PrestigeGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PrestigeGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "Container"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -20, 1, -20)
frame.Size = UDim2.new(0, 320, 0, 170)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 8)
title.Font = Enum.Font.GothamBold
title.Text = "PRESTIGE"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Name = "Info"
info.BackgroundTransparency = 1
info.Size = UDim2.new(1, -20, 0, 60)
info.Position = UDim2.new(0, 10, 0, 48)
info.Font = Enum.Font.Gotham
info.Text = "Reach higher Fridge Levels to Prestige and gain permanent multipliers."
info.TextWrapped = true
info.TextScaled = true
info.TextColor3 = Color3.fromRGB(210,210,210)
info.Parent = frame

local button = Instance.new("TextButton")
button.Name = "PrestigeButton"
button.Size = UDim2.new(1, -20, 0, 42)
button.Position = UDim2.new(0, 10, 1, -52)
button.Font = Enum.Font.GothamBold
button.Text = "PRESTIGE"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
button.TextColor3 = Color3.fromRGB(20,20,20)
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = button

gui.Parent = StarterGui

print("Prestige UI placeholder created.")
