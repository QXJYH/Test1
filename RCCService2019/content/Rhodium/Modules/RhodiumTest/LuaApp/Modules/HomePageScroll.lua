--to make ScriptAnalyzer Happy
describe = nil
step = nil
expect = nil
include = nil
-------------------------------
local UserInputService = game:GetService("UserInputService")

local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
local MobileAppElements = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.MobileAppElements)
local VirtualInput = require(game.CoreGui.RobloxGui.Modules.Rhodium.VirtualInput)

return function()
	step("can vertically scroll the content", function()
		local element = Element.new(MobileAppElements.verticalScrollingFrame)
		wait(0.5)
		if UserInputService.MouseEnabled then
			VirtualInput.mouseWheel(element:getCenter(), 2)
		elseif UserInputService.TouchEnabled then
			VirtualInput.swipe(element:getCenter(), element:getCenter() + Vector2.new(0, -100), 0.25, false)
		end
		wait(0.5) -- wait for one frame to update GUIs.
		assert(MobileAppElements.verticalScrollingFrame:waitForFirstInstance().CanvasPosition.Y > 0)
	end)
end