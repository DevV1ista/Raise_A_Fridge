print("Raise A Fridge client booting...")

local controllers = script.Parent:WaitForChild("Controllers")

local hudController = require(controllers:WaitForChild("HudController"))
local prestigeController = require(controllers:WaitForChild("PrestigeController"))

hudController.Start()
prestigeController.Start()
