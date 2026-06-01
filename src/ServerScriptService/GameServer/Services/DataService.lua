local DataStoreService = game:GetService("DataStoreService")

local DataService = {}

local DATA_VERSION = 1
local STORE_NAME = "RaiseAFridge_PlayerData_v1"
local store = DataStoreService:GetDataStore(STORE_NAME)

local function getKey(player)
	return "player_" .. player.UserId
end

function DataService.Load(player)
	local ok, result = pcall(function()
		return store:GetAsync(getKey(player))
	end)
	if not ok then
		warn("[DataService] Failed to load data for", player.UserId, result)
		return nil
	end
	if typeof(result) ~= "table" then
		return nil
	end
	if result.version ~= DATA_VERSION then
		return nil
	end
	if typeof(result.data) ~= "table" then
		return nil
	end
	return result.data
end

function DataService.Save(player, data)
	if typeof(data) ~= "table" then
		return false, "Invalid data"
	end
	local envelope = {
		version = DATA_VERSION,
		savedAt = os.time(),
		data = data,
	}
	local ok, result = pcall(function()
		store:SetAsync(getKey(player), envelope)
	end)
	if not ok then
		warn("[DataService] Failed to save data for", player.UserId, result)
		return false, result
	end
	return true
end

return DataService
