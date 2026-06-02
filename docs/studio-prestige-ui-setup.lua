local StarterGui = game:GetService("StarterGui")

local screenGui = StarterGui:FindFirstChild("FridgeHudGui")
if not screenGui then
	warn("FridgeHudGui not found in StarterGui")
	return
end

if screenGui:FindFirstChild("PrestigeFrame", true) then
	warn("PrestigeFrame already exists")
	return
end

local frame = Instance.new("Frame")
frame.Name = "PrestigeFrame"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.new(0.5, 0, 1, -18)
frame.Size = UDim2.new(0, 370, 0, 78)
frame.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 18)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(255, 216, 90)
frameStroke.Thickness = 2
frameStroke.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "PrestigeInfoLabel"
infoLabel.BackgroundTransparency = 1
infoLabel.Position = UDim2.new(0, 14, 0, 8)
infoLabel.Size = UDim2.new(1, -28, 0, 26)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextScaled = true
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.TextStrokeTransparency = 0.35
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Text = "Prestige unlocks at Fridge Lv. 25"
infoLabel.Parent = frame

local button = Instance.new("TextButton")
button.Name = "PrestigeButton"
button.Position = UDim2.new(0, 14, 0, 40)
button.Size = UDim2.new(1, -28, 0, 30)
button.BackgroundColor3 = Color3.fromRGB(95, 95, 105)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBlack
button.TextScaled = true
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextStrokeTransparency = 0.15
button.Text = "Prestige locked"
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = button

print("Prestige UI created successfully.")
