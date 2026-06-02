local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PrestigeController = {}
local started = false

local function tween(instance, tweenInfo, properties)
	local createdTween = TweenService:Create(instance, tweenInfo, properties)
	createdTween:Play()
	return createdTween
end

function PrestigeController.Start()
	if started then
		return
	end
	started = true

	local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("FridgeHudGui")
	local frame = gui:FindFirstChild("PrestigeFrame", true)
	if not frame or not frame:IsA("Frame") then
		warn("[PrestigeController] Missing PrestigeFrame. Run the Studio command-bar setup script first.")
		return
	end

	local label = frame:FindFirstChild("PrestigeInfoLabel", true)
	local button = frame:FindFirstChild("PrestigeButton", true)
	if not label or not label:IsA("TextLabel") or not button or not button:IsA("TextButton") then
		warn("[PrestigeController] PrestigeFrame must contain PrestigeInfoLabel and PrestigeButton.")
		return
	end

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
