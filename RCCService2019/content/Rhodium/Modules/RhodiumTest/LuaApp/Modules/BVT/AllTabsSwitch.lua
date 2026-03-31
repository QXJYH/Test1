--to make ScriptAnalyzer Happy
describe = nil
step = nil
expect = nil
include = nil
-------------------------------
local MobileAppElements = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.MobileAppElements)
local PageNavigation = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.PageNavigation)
local Element = require(game.CoreGui.RobloxGui.Modules.Rhodium.Element)
local XPath = require(game.CoreGui.RobloxGui.Modules.Rhodium.XPath)

return function()
	step("Switching pages", function()
		local buttonBar = Element.new(MobileAppElements.bottomBarFrame)
		local children = buttonBar:getRbxInstance():GetChildren()

		-- UIListLayout (and UIPadding)
		local nonButtonNum = 2
		local length = math.max(0, #children - nonButtonNum)
		local expectedLength = 5 
		expect(length).to.equal(expectedLength)

		PageNavigation.gotoGamesPage()
		PageNavigation.gotoAvatarPage()
		PageNavigation.gotoChatPage()
		PageNavigation.gotoMorePage()
		PageNavigation.gotoHomePage()
	end)
end
