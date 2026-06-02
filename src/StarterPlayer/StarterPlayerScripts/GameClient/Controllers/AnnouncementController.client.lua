local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local AnnouncementRemotes = require(ReplicatedStorage.Game.Shared.Remotes.AnnouncementRemotes)

local gui = player:WaitForChild("PlayerGui"):WaitForChild("AnnouncementGui", 30)

if not gui then
	warn("AnnouncementGui missing.")
	return
end

local frame = gui:WaitForChild("AnnouncementFrame")
local textLabel = frame:WaitForChild("AnnouncementText")

local activeAnnouncementId = 0

local function showAnnouncement(data)
	activeAnnouncementId += 1
	local id = activeAnnouncementId

	textLabel.Text = string.format(
		"%s • %s rolled %s (%s)",
		data.DisplayPrefix,
		data.PlayerName,
		data.FoodName,
		data.Rarity
	)

	local showTween = TweenService:Create(
		frame,
		TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = UDim2.new(0.5, 0, 0.03, 0)
		}
	)

	showTween:Play()

	task.wait(data.Duration or 4)

	if id ~= activeAnnouncementId then
		return
	end

	local hideTween = TweenService:Create(
		frame,
		TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{
			Position = UDim2.new(0.5, 0, -0.2, 0)
		}
	)

	hideTween:Play()
end

AnnouncementRemotes:GetGlobalAnnouncementRemote().OnClientEvent:Connect(showAnnouncement)
