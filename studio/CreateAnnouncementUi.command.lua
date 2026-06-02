local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("AnnouncementGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "AnnouncementGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "AnnouncementFrame"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, -0.2, 0)
frame.Size = UDim2.new(0, 720, 0, 90)
frame.BackgroundColor3 = Color3.fromRGB(18,18,24)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = frame

local text = Instance.new("TextLabel")
text.Name = "AnnouncementText"
text.BackgroundTransparency = 1
text.Size = UDim2.new(1, -30, 1, 0)
text.Position = UDim2.new(0, 15, 0, 0)
text.Font = Enum.Font.GothamBlack
text.Text = "GLOBAL ANNOUNCEMENT"
text.TextScaled = true
text.TextColor3 = Color3.fromRGB(255,255,255)
text.Parent = frame

gui.Parent = StarterGui

print("Announcement UI placeholder created.")
