local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PrestigeController = {}
local started = false

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 12)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 2
	stroke.Parent = parent
	return stroke
end

local function tween(instance, tweenInfo, properties)
	local createdTween = TweenService:Create(instance, tweenInfo, properties)
	createdTween:Play()
	return createdTween
end

local function getOrCreatePrestigeFrame(gui)
	local existing = gui:FindFirstChild("PrestigeFrame", true)
	if existing and existing:IsA("Frame") then
		return existing
	end

	local frame = Instance.new("Frame")
	frame.Name = "PrestigeFrame"
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -18)
	frame.Size = UDim2.new(0, 370, 0, 78)
	frame.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.Parent = gui
	createCorner(frame, UDim.new(0, 18))
	createStroke(frame, Color3.fromRGB(255, 216, 90), 2)

	local label = Instance.new("TextLabel")
	label.Name = "PrestigeInfoLabel"
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 14, 0, 8)
	label.Size = UDim2.new(1, -28, 0, 26)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.35
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "Prestige unlocks at Fridge Lv. 25"
	label.Parent = frame

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
	button.AutoButtonColor = false
	button.Parent = frame
	createCorner(button, UDim.new(0, 12))

	return frame
end

function PrestigeController.Start()
	if started then
		return
	end
	started = true

	local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("FridgeHudGui")
	local frame = getOrCreatePrestigeFrame(gui)
	local label = frame:WaitForChild("PrestigeInfoLabel")
	local button = frame:WaitForChild("PrestigeButton")
	local busy = false
	local latestState = nil

	local function render(state)
		latestState = state
		local requirement = state.prestigeRequirement or 25
		local nextMultiplier = state.nextPrestigeMultiplier or 1
		local currentPrestige = state.prestige or 0
		local currentLevel = state.fridgeLevel or 1

		label.Text = "Prestige " .. currentPrestige .. " | Need Lv. " .. requirement .. " | Next x" .. string.format("%.2f", nextMultiplier)
		if state.canPrestige then
			button.Text = "PRESTIGE NOW"
			button.BackgroundColor3 = Color3.fromRGB(255, 183, 50)
			button.AutoButtonColor = true
		else
			button.Text = "Prestige locked - Lv. " .. currentLevel .. "/" .. requirement
			button.BackgroundColor3 = Color3.fromRGB(70, 74, 90)
			button.AutoButtonColor = false
		end
	end

	button.Activated:Connect(function()
		if busy then
			return
		end
		if not latestState or not latestState.canPrestige then
			tween(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(120, 60, 65) })
			task.delay(0.18, function()
				if latestState then
					render(latestState)
				end
			end)
			return
		end

		busy = true
		button.Text = "Prestiging..."
		local ok, result = Remotes.PrestigeRequested:InvokeServer()
		busy = false

		if ok then
			button.Text = "Prestige " .. result.prestige .. " unlocked!"
			tween(frame, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 400, 0, 86) })
			task.delay(0.3, function()
				if frame and frame.Parent then
					tween(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 370, 0, 78) })
				end
			end)
		else
			button.Text = tostring(result)
			button.BackgroundColor3 = Color3.fromRGB(150, 60, 70)
		end
	end)

	Remotes.StateChanged.OnClientEvent:Connect(render)
	local initialState = Remotes.GetState:InvokeServer()
	if initialState then
		render(initialState)
	end
end

return PrestigeController
