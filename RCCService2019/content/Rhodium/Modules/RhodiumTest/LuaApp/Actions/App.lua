local success
success, Rhodium = pcall(function() return game.CoreGui.RobloxGui.Modules.Rhodium end)
if not success then
	Rhodium = nil
else
	XPath = require(Rhodium.XPath)
	Element = require(Rhodium.Element)
	VirtualInput = require(Rhodium.VirtualInput)
end

local Actions = {}
Actions.__index = Actions

local MobileAppElements = require(game.CoreGui.RobloxGui.Modules.RhodiumTest.Common.MobileAppElements)
local GameDisplayPath = XPath.new("game.CoreGui.App.AppContainer.AppRouter.Home.Contents.Content.LoadingStateWrapper.scrollingFrame.Content.GameDisplay")

function Actions.clickFirstRecentGameCard()
	print("Rhodium Test: click first recent")
	local firstRecent = GameDisplayPath:cat(XPath.new("MyRecent.Content.LoadingStateWrapper.1.GameButton"))
	firstRecent:waitForFirstInstance()
	wait(0.5)
	Element.new(firstRecent):click()

	local HomeGui = game.CoreGui.App.AppContainer.AppRouter.Home
	wait()
	assert(HomeGui.Enabled == false, "Home Gui should be disabled")
end

function Actions.clickRobuxButton()
	print("Rhodium Test: click Robux button")
	local robuxButton = MobileAppElements.robuxButton
	robuxButton:waitForFirstInstance()
	wait(0.5)
	Element.new(robuxButton):click()
end

function Actions.playGame()
	print("Rhodium Test: click Play button")
	local playButton = MobileAppElements.currentGameList:cat(XPath.new("Contents.SafeAreaFrame.GameDetailsCard.Contents.ActionBar.ActionBar.PlayButtonContainer"))
	playButton:waitForFirstInstance()
	wait(0.5)
	Element.new(playButton):click()

end

function Actions.quitGameDetail()
	print("Rhodium Test: quit game details")
	local closeButton = MobileAppElements.currentGameList:cat(XPath.new("Contents.SafeAreaFrame.GameDetailsCard.TopBar.TouchFriendlyNavigationButton"))
	closeButton:waitForFirstInstance()
	wait(0.5)
	Element.new(closeButton):click()
end

return Actions