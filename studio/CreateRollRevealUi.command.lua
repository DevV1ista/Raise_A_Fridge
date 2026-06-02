local StarterGui = game:GetService("StarterGui")

local existing = StarterGui:FindFirstChild("RollRevealGui")
if existing then
	existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "RollRevealGui"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

local revealFrame = Instance.new("Frame")
revealFrame.Name = "RevealFrame"
revealFrame.AnchorPoint = Vector2.new(0.5, 0.5)
revealFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
revealFrame.Size = UDim2.new(0, 520, 0, 180)
revealFrame.BackgroundTransparency = 0.15
revealFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
revealFrame.Visible = false
revealFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = revealFrame

local rarityLabel = Instance.new("TextLabel")
rarityLabel.Name = "Rarity"
rarityLabel.BackgroundTransparency = 1
rarityLabel.Position = UDim2.new(0, 0, 0, 18)
rarityLabel.Size = UDim2.new(1, 0, 0, 42)
rarityLabel.Font = Enum.Font.GothamBold
rarityLabel.Text = "RARITY"
rarityLabel.TextScaled = true
rarityLabel.TextColor3 = Color3.fromRGB(255,255,255)
rarityLabel.Parent = revealFrame

local foodLabel = Instance.new("TextLabel")
foodLabel.Name = "FoodName"
foodLabel.BackgroundTransparency = 1
foodLabel.Position = UDim2.new(0, 20, 0, 78)
foodLabel.Size = UDim2.new(1, -40, 0, 70)
foodLabel.Font = Enum.Font.GothamBlack
foodLabel.Text = "FOOD"
foodLabel.TextScaled = true
foodLabel.TextColor3 = Color3.fromRGB(255,255,255)
foodLabel.Parent = revealFrame

gui.Parent = StarterGui

print("Roll reveal UI placeholder created.")
