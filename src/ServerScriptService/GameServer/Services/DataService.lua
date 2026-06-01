local DataStoreService = game:GetService("DataStoreService")

local DataService = {}

local DATA_VERSION = 1
local STORE_NAME = "RaiseAFridge_PlayerData_v2"
local MAX_RETRIES = 3
local store = DataStoreService:GetDataStore(STORE_NAME)

local function getKey(player)
	return "player_" .. player.UserId
end

local function waitBeforeRetry(attempt)
	task.wait(0.5 * attempt)
end

function DataService.Load(player)
	local key = getKey(player)
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return store:GetAsync(key)
		end)
		if ok then
			if typeof(result) ~= "table" then
				print("[DataService] No saved data for", player.UserId)
				return nil
			end
			if result.version ~= DATA_VERSION then
				warn("[DataService] Ignoring unsupported data version for", player.UserId, result.version)
				return nil
			end
			if typeof(result.data) ~= "table" then
				warn("[DataService] Saved envelope has no data table for", player.UserId)
				return nil
			end
			print("[DataService] Loaded data for", player.UserId)
			return result.data
		end
		warn("[DataService] Load attempt failed", attempt, player.UserId, result)
		waitBeforeRetry(attempt)
	end
	return nil
end

function DataService.Save(player, data)
	if typeof(data) ~= "table" then
		return false, "Invalid data"
	end
	local key = getKey(player)
	local envelope = {
		version = DATA_VERSION,
		savedAt = os.time(),
		data = data,
	}
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(function()
			return store:UpdateAsync(key, function()
				return envelope
			end)
		end)
		if ok then
			print(
				"[DataService] Saved data for",
				player.UserId,
				"money",
				math.floor(data.money or 0),
				"level",
				data.fridgeLevel or 1,
				"inventory",
				#(data.inventory or {}),
				"skills",
				data.skillCount or 0
			)
			return true, result
		end
		warn("[DataService] Save attempt failed", attempt, player.UserId, result)
		waitBeforeRetry(attempt)
	end
	return false, "DataStore save failed after retries"
end

return DataService
