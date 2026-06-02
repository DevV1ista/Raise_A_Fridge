local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnnouncementRemotes = {}

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

function AnnouncementRemotes:GetFolder()
	local gameFolder = getOrCreateFolder(ReplicatedStorage, "Game")
	local remotesFolder = getOrCreateFolder(gameFolder, "Remotes")
	return getOrCreateFolder(remotesFolder, "Announcements")
end

function AnnouncementRemotes:GetGlobalAnnouncementRemote()
	return getOrCreateRemoteEvent(self:GetFolder(), "GlobalAnnouncement")
end

return AnnouncementRemotes
