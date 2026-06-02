local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Balance = require(ReplicatedStorage.Game.Shared.Config.Balance)
local RarityBonus = require(ReplicatedStorage.Game.Shared.Config.RarityBonus)
local FoodRegistry = require(ReplicatedStorage.Game.Shared.Registries.FoodRegistry)
local UpgradeRegistry = require(ReplicatedStorage.Game.Shared.Registries.UpgradeRegistry)
local Remotes = require(ReplicatedStorage.Game.Shared.Remotes)
local DataService = require(script.Parent.DataService)
local PlotService = require(script.Parent.PlotService)

local StateService = {}
local states = {}
local dirty = {}
local saving = {}

local function cloneUnlockedRarities()
	local unlocked = {}
	for rarity, value in pairs(FoodRegistry.StartingUnlockedRarities) do
		unlocked[rarity] = value
	end
	return unlocked
end

local function createState()
	return {
		money = 0,
		totalEarned = 0,
		fridgeLevel = 1,
		fridgeXp = 0,
		prestige = 0,
		permanentBonus = 0,
		inventory = {},
		index = {},
		upgrades = {},
		unlockedRarities = cloneUnlockedRarities(),
		lastRollAt = 0,
	}
end

local function getUpgradeLevel(state, upgradeId)
	return state.upgrades[upgradeId] or 0
end

local function refreshUnlockedRarities(state)
	state.unlockedRarities = cloneUnlockedRarities()
	UpgradeRegistry.applyUnlockEffects(state.upgrades, state.unlockedRarities)
end

local function copyArray(source, limit)
	local result = {}
	if typeof(source) ~= "table" then
		return result
	end
	for _, value in ipairs(source) do
		if typeof(value) == "string" and FoodRegistry.getFood(value) then
			table.insert(result, value)
			if limit and #result >= limit then
				break
			end
		end
	end
	return result
end

local function copyNumberMap(source)
	local result = {}
	if typeof(source) ~= "table" then
		return result
	end
	for key, value in pairs(source) do
		if typeof(key) == "string" and typeof(value) == "number" then
			result[key] = math.max(0, math.floor(value))
		end
	end
	return result
end

local function sanitizeUpgrades(source)
	local result = {}
	if typeof(source) ~= "table" then
		return result
	end
	for upgradeId, value in pairs(source) do
		local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
		if upgrade and typeof(value) == "number" then
			result[upgradeId] = math.clamp(math.floor(value), 0, upgrade.maxLevel)
		end
	end
	return result
end

local function countUpgrades(upgrades)
	local count = 0
	for _, level in pairs(upgrades) do
		if level > 0 then
			count += 1
		end
	end
	return count
end

local function applyLoadedData(state, data)
	if typeof(data) ~= "table" then
		return
	end
	if typeof(data.money) == "number" then
		state.money = math.max(0, data.money)
	end
	if typeof(data.totalEarned) == "number" then
		state.totalEarned = math.max(0, data.totalEarned)
	end
	if typeof(data.fridgeLevel) == "number" then
		state.fridgeLevel = math.max(1, math.floor(data.fridgeLevel))
	end
	if typeof(data.fridgeXp) == "number" then
		state.fridgeXp = math.max(0, data.fridgeXp)
	end
	if typeof(data.prestige) == "number" then
		state.prestige = math.max(0, math.floor(data.prestige))
	end
	if typeof(data.permanentBonus) == "number" then
		state.permanentBonus = math.max(0, data.permanentBonus)
	end
	state.inventory = copyArray(data.inventory, Balance.InventoryLimit)
	state.index = copyNumberMap(data.index)
	state.upgrades = sanitizeUpgrades(data.upgrades)
	refreshUnlockedRarities(state)
end

local function serializeState(state)
	local upgrades = sanitizeUpgrades(state.upgrades)
	return {
		money = state.money,
		totalEarned = state.totalEarned,
		fridgeLevel = state.fridgeLevel,
		fridgeXp = state.fridgeXp,
		prestige = state.prestige,
		permanentBonus = state.permanentBonus,
		inventory = copyArray(state.inventory, Balance.InventoryLimit),
		index = copyNumberMap(state.index),
		upgrades = upgrades,
		skillCount = countUpgrades(upgrades),
	}
end

local function markDirty(player)
	dirty[player] = true
end

local function getEquippedFoodTool(player)
	local character = player.Character
	if not character then
		return nil
	end
	local tool = character:FindFirstChildOfClass("Tool")
	if tool and tool:GetAttribute("IsFridgeFood") then
		return tool
	end
	return nil
end

local function destroyFoodTools(player)
	local character = player.Character
	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsFridgeFood") then
				child:Destroy()
			end
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child:GetAttribute("IsFridgeFood") then
				child:Destroy()
			end
		end
	end
end

local function getFoodModelTemplate(foodId, food)
	local serverFolder = ServerStorage:FindFirstChild("Game")
		and ServerStorage.Game:FindFirstChild("Assets")
		and ServerStorage.Game.Assets:FindFirstChild("FoodModels")
	local replicatedFolder = ReplicatedStorage:FindFirstChild("Game")
		and ReplicatedStorage.Game:FindFirstChild("Assets")
		and ReplicatedStorage.Game.Assets:FindFirstChild("FoodModels")

	if serverFolder then
		local template = serverFolder:FindFirstChild(foodId) or serverFolder:FindFirstChild(food.displayName)
		if template then
			return template
		end
	end
	if replicatedFolder then
		local template = replicatedFolder:FindFirstChild(foodId) or replicatedFolder:FindFirstChild(food.displayName)
		if template then
			return template
		end
	end
	return nil
end

local function prepareDescendant(instance)
	if instance:IsA("BasePart") then
		instance.CanCollide = false
		instance.Massless = true
	end
end

local function attachModelToHandle(model, handle)
	for _, descendant in ipairs(model:GetDescendants()) do
		prepareDescendant(descendant)
	end
	local primary = model:IsA("Model") and model.PrimaryPart or nil
	if not primary then
		primary = model:FindFirstChildWhichIsA("BasePart", true)
	end
	if primary then
		primary.Name = "FoodVisualRoot"
		primary.CFrame = handle.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = primary
		weld.Parent = handle
	end
end

local function createFallbackHandle()
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.4, 1.4, 1.4)
	handle.CanCollide = false
	handle.Massless = true
	return handle
end

local function createFoodTool(foodId, food, inventoryIndex)
	local tool = Instance.new("Tool")
	tool.Name = food.displayName
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool:SetAttribute("IsFridgeFood", true)
	tool:SetAttribute("FoodId", foodId)
	tool:SetAttribute("InventoryIndex", inventoryIndex)
	tool:SetAttribute("Xp", food.xp)
	tool.ToolTip = food.displayName .. " | " .. food.rarity .. " | +" .. food.xp .. " XP"

	local handle = createFallbackHandle()
	handle.Transparency = 1
	handle.Parent = tool

	local template = getFoodModelTemplate(foodId, food)
	if template then
		local visual = template:Clone()
		visual.Name = "FoodVisual"
		visual.Parent = tool
		attachModelToHandle(visual, handle)
	else
		handle.Transparency = 0
	end

	return tool
end

local function equipToolNow(player, tool)
	local character = player.Character
	if not character then
		return false, "No character"
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false, "No humanoid"
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return false, "No backpack"
	end
	tool.Parent = backpack
	humanoid:EquipTool(tool)
	return true
end

function StateService.getFoodInfo(foodId)
	return FoodRegistry.getFood(foodId)
end

function StateService.getPermanentMultiplierFromState(state)
	return RarityBonus.getTotalMultiplier(state.permanentBonus)
end

function StateService.getMoneyMultiplierFromState(state)
	return StateService.getPermanentMultiplierFromState(state) * (1 + UpgradeRegistry.getTotalEffect(state.upgrades, "moneyMultiplierPerLevel"))
end

function StateService.getXpMultiplierFromState(state)
	return StateService.getPermanentMultiplierFromState(state) * (1 + UpgradeRegistry.getTotalEffect(state.upgrades, "xpMultiplierPerLevel"))
end

function StateService.getLuckMultiplierFromState(state)
	return 1 + UpgradeRegistry.getTotalEffect(state.upgrades, "luckBonusPerLevel")
end

function StateService.getCloverCapFromState(state)
	return math.min(Balance.StartingCloverCap * UpgradeRegistry.getCloverCapMultiplier(state.upgrades), 2048)
end

function StateService.getMoneyPerSecondFromState(state)
	return Balance.getMoneyPerSecond(state.fridgeLevel, {
		prestige = Balance.getPrestigeMultiplier(state.prestige),
		permanent = StateService.getPermanentMultiplierFromState(state),
		upgrade = 1 + UpgradeRegistry.getTotalEffect(state.upgrades, "moneyMultiplierPerLevel"),
		mutation = 1,
	})
end

local function toPublicState(state)
	return {
		money = state.money,
		totalEarned = state.totalEarned,
		fridgeLevel = state.fridgeLevel,
		fridgeXp = state.fridgeXp,
		xpRequired = Balance.getXpRequiredForLevel(state.fridgeLevel),
		moneyPerSecond = StateService.getMoneyPerSecondFromState(state),
		prestige = state.prestige,
		permanentBonus = state.permanentBonus,
		inventory = state.inventory,
		index = state.index,
		upgrades = UpgradeRegistry.getPublicUpgrades(state.upgrades),
		upgradeOrder = UpgradeRegistry.Order,
		upgradeBranches = UpgradeRegistry.Branches,
		unlockedRarities = state.unlockedRarities,
		multipliers = {
			money = StateService.getMoneyMultiplierFromState(state),
			xp = StateService.getXpMultiplierFromState(state),
			luck = StateService.getLuckMultiplierFromState(state),
			cloverCap = StateService.getCloverCapFromState(state),
			permanent = StateService.getPermanentMultiplierFromState(state),
		},
	}
end

function StateService.getState(player)
	return states[player]
end

function StateService.getPublicState(player)
	local state = states[player]
	if not state then
		return nil
	end
	return toPublicState(state)
end

function StateService.pushState(player)
	local publicState = StateService.getPublicState(player)
	if not publicState then
		return
	end
	PlotService.updateFridgeDisplay(player, publicState)
	Remotes.StateChanged:FireClient(player, publicState)
end

function StateService.savePlayer(player, force)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	if not force and not dirty[player] then
		return true
	end
	local waited = 0
	while saving[player] and waited < 10 do
		task.wait(0.1)
		waited += 0.1
	end
	if saving[player] then
		warn("[StateService] Save still running while player leaves", player.UserId)
		return false, "Save still running"
	end
	saving[player] = true
	local data = serializeState(state)
	local ok, reason = DataService.Save(player, data)
	saving[player] = nil
	if ok then
		dirty[player] = nil
		print("[StateService] Saved player", player.UserId, "level", state.fridgeLevel, "xp", math.floor(state.fridgeXp), "food", #state.inventory, "skills", data.skillCount, "permanentBonus", state.permanentBonus)
	else
		dirty[player] = true
		warn("[StateService] Save failed for", player.UserId, reason)
	end
	return ok, reason
end

function StateService.addFood(player, foodId)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	if #state.inventory >= Balance.InventoryLimit then
		return false, "Inventory full"
	end
	table.insert(state.inventory, foodId)
	state.index[foodId] = (state.index[foodId] or 0) + 1
	markDirty(player)
	StateService.pushState(player)
	return true
end

function StateService.equipFood(player, inventoryIndex)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	local foodId = state.inventory[inventoryIndex]
	if not foodId then
		return false, "Invalid food"
	end
	local equippedTool = getEquippedFoodTool(player)
	if equippedTool
		and equippedTool:GetAttribute("InventoryIndex") == inventoryIndex
		and equippedTool:GetAttribute("FoodId") == foodId then
		equippedTool:Destroy()
		return true, {
			unequipped = true,
			foodId = foodId,
		}
	end
	local food = FoodRegistry.getFood(foodId)
	if not food then
		return false, "Unknown food"
	end
	destroyFoodTools(player)
	local tool = createFoodTool(foodId, food, inventoryIndex)
	local equipped, equipReason = equipToolNow(player, tool)
	if not equipped then
		tool:Destroy()
		return false, equipReason
	end
	return true, {
		foodId = foodId,
		displayName = food.displayName,
		xp = food.xp,
		rarity = food.rarity,
	}
end

function StateService.feedEquippedFood(player)
	local character = player.Character
	if not character then
		return false, "Equip food first"
	end
	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or not tool:GetAttribute("IsFridgeFood") then
		return false, "Equip food first"
	end
	local inventoryIndex = tool:GetAttribute("InventoryIndex")
	local state = states[player]
	if not state or not inventoryIndex then
		return false, "Invalid food"
	end
	local foodId = state.inventory[inventoryIndex]
	if foodId ~= tool:GetAttribute("FoodId") then
		return false, "Food changed"
	end
	local ok, result = StateService.feedFood(player, inventoryIndex)
	if ok then
		tool:Destroy()
	end
	return ok, result
end

function StateService.feedFood(player, inventoryIndex)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	local foodId = state.inventory[inventoryIndex]
	if not foodId then
		return false, "Invalid food"
	end
	local food = FoodRegistry.getFood(foodId)
	if not food then
		return false, "Unknown food"
	end
	table.remove(state.inventory, inventoryIndex)
	local rarityBonus = RarityBonus.getBonusForRarity(food.rarity)
	if rarityBonus > 0 then
		state.permanentBonus += rarityBonus
	end
	state.fridgeXp += food.xp * StateService.getXpMultiplierFromState(state)
	local required = Balance.getXpRequiredForLevel(state.fridgeLevel)
	while state.fridgeXp >= required do
		state.fridgeXp -= required
		state.fridgeLevel += 1
		required = Balance.getXpRequiredForLevel(state.fridgeLevel)
	end
	markDirty(player)
	StateService.pushState(player)
	return true, {
		foodId = foodId,
		rarity = food.rarity,
		permanentBonusAdded = rarityBonus,
		permanentBonus = state.permanentBonus,
	}
end

function StateService.purchaseUpgrade(player, upgradeId)
	local state = states[player]
	if not state then
		return false, "No state"
	end
	local upgrade = UpgradeRegistry.getUpgrade(upgradeId)
	if not upgrade then
		return false, "Unknown skill"
	end
	if not UpgradeRegistry.areRequirementsMet(upgradeId, state.upgrades) then
		return false, "Locked: needs " .. UpgradeRegistry.getRequirementText(upgradeId)
	end
	local currentLevel = getUpgradeLevel(state, upgradeId)
	if currentLevel >= upgrade.maxLevel then
		return false, "Max level"
	end
	local cost = UpgradeRegistry.getCost(upgradeId, currentLevel)
	if not cost then
		return false, "Invalid skill cost"
	end
	if state.money < cost then
		return false, "Not enough money"
	end
	state.money -= cost
	state.upgrades[upgradeId] = currentLevel + 1
	refreshUnlockedRarities(state)
	markDirty(player)
	StateService.pushState(player)
	return true, {
		upgradeId = upgradeId,
		level = state.upgrades[upgradeId],
	}
end

function StateService.tickMoney(deltaTime)
	for player, state in pairs(states) do
		local earned = StateService.getMoneyPerSecondFromState(state) * deltaTime
		state.money += earned
		state.totalEarned += earned
		markDirty(player)
		StateService.pushState(player)
	end
end

local function loadPlayer(player)
	local state = createState()
	local data = DataService.Load(player)
	if data then
		applyLoadedData(state, data)
		print("[StateService] Loaded player", player.UserId, "level", state.fridgeLevel, "xp", math.floor(state.fridgeXp), "food", #state.inventory, "skills", countUpgrades(state.upgrades), "permanentBonus", state.permanentBonus)
	else
		print("[StateService] Created new state for", player.UserId)
	end
	states[player] = state
	dirty[player] = nil
	StateService.pushState(player)
end

function StateService.Init()
	Players.PlayerAdded:Connect(loadPlayer)
	Players.PlayerRemoving:Connect(function(player)
		StateService.savePlayer(player, true)
		states[player] = nil
		dirty[player] = nil
		saving[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		loadPlayer(player)
	end
	game:BindToClose(function()
		for player in pairs(states) do
			StateService.savePlayer(player, true)
		end
	end)
end

return StateService
