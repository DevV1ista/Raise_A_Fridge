local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local RollFeedbackRemotes = require(ReplicatedStorage.Game.Shared.Remotes.RollFeedbackRemotes)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("RollRevealGui", 30)

if not gui then
	warn("RollRevealGui missing.")
	return
end

local revealFrame = gui:WaitForChild("RevealFrame")
local rarityLabel = revealFrame:WaitForChild("Rarity")
local foodLabel = revealFrame:WaitForChild("FoodName")

local activeRevealId = 0

local function playReveal(data)
	activeRevealId += 1
	local revealId = activeRevealId

	revealFrame.Visible = true
	revealFrame.Size = UDim2.new(0, 420, 0, 140)
	revealFrame.BackgroundTransparency = 0.35

	rarityLabel.Text = string.upper(data.Rarity)
	foodLabel.Text = string.upper(data.FoodName)

	local tween = TweenService:Create(
		revealFrame,
		TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Size = UDim2.new(0, 520, 0, 180),
			BackgroundTransparency = 0.12,
		}
	)

	tween:Play()

	if data.UseBurst then
		foodLabel.Rotation = math.random(-3, 3)
	end

	local endTime = tick() + (data.RevealDuration or 1)

	while tick() < endTime and revealId == activeRevealId do
		local shake = data.ShakeIntensity or 0

		revealFrame.Position = UDim2.new(
			0.5,
			math.random(-100, 100) * shake,
			0.5,
			math.random(-60, 60) * shake
		)

		task.wait(0.03)
	end

	if revealId ~= activeRevealId then
		return
	end

	revealFrame.Visible = false
	revealFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
end

RollFeedbackRemotes:GetRevealRemote().OnClientEvent:Connect(playReveal)
