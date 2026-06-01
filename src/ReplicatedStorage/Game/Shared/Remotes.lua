local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local root = ReplicatedStorage:FindFirstChild("RaiseAFridgeRemotes")
if not root then
	root = Instance.new("Folder")
	root.Name = "RaiseAFridgeRemotes"
	root.Parent = ReplicatedStorage
end

local function getRemoteEvent(name)
	local remote = root:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = root
	end
	return remote
end

local function getRemoteFunction(name)
	local remote = root:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = root
	end
	return remote
end

Remotes.StateChanged = getRemoteEvent("StateChanged")
Remotes.RollRequested = getRemoteFunction("RollRequested")
Remotes.FeedRequested = getRemoteFunction("FeedRequested")
Remotes.GetState = getRemoteFunction("GetState")

return Remotes
