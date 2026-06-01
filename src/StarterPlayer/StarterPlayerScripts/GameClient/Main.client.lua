print("Raise A Fridge client booting...")

local controllers = script.Parent:WaitForChild("Controllers")
local hudController = controllers:WaitForChild("HudController")
require(hudController)
