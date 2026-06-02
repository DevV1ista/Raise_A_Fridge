local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RollFeedbackRemotes = {}

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)

	if folder then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	return folder
end

local function getOrCreateRemoteEvent(parent, name)
	local remote = parent:FindFirstChild(name)

	if remote then
		return remote
	end

	remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent

	return remote
end

function RollFeedbackRemotes:GetFolder()
	local gameFolder = getOrCreateFolder(ReplicatedStorage, "Game")
	local remotesFolder = getOrCreateFolder(gameFolder, "Remotes")
	return getOrCreateFolder(remotesFolder, "RollFeedback")
end

function RollFeedbackRemotes:GetRevealRemote()
	return getOrCreateRemoteEvent(self:GetFolder(), "FoodReveal")
end

return RollFeedbackRemotes
