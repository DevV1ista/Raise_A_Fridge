print("Raise A Fridge client booting...")

local controllers = script.Parent:WaitForChild("Controllers")
local hudController = require(controllers:WaitForChild("HudController"))
hudController.Start()
