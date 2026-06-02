local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrestigeRemotes = {}

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

local function getOrCreateRemoteFunction(parent, name)
	local remote = parent:FindFirstChild(name)

	if remote then
		return remote
	end

	remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = parent

	return remote
end

function PrestigeRemotes:GetFolder()
	local gameFolder = getOrCreateFolder(ReplicatedStorage, "Game")
	local remotesFolder = getOrCreateFolder(gameFolder, "Remotes")
	return getOrCreateFolder(remotesFolder, "Prestige")
end

function PrestigeRemotes:GetPrestigeStateRemote()
	return getOrCreateRemoteEvent(self:GetFolder(), "PrestigeStateChanged")
end

function PrestigeRemotes:GetRequestPrestigeRemote()
	return getOrCreateRemoteFunction(self:GetFolder(), "RequestPrestige")
end

return PrestigeRemotes
