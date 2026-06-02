local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MutationRemotes = {}

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

function MutationRemotes:GetFolder()
	local gameFolder = getOrCreateFolder(ReplicatedStorage, "Game")
	local remotesFolder = getOrCreateFolder(gameFolder, "Remotes")
	return getOrCreateFolder(remotesFolder, "Mutations")
end

function MutationRemotes:GetMutationChangedRemote()
	return getOrCreateRemoteEvent(self:GetFolder(), "MutationChanged")
end

return MutationRemotes
