local success
success, Rhodium = pcall(function() return game.CoreGui.RobloxGui.Modules.Rhodium end)
if not success then
	Rhodium = nil
else
	XPath = require(Rhodium.XPath)
	Element = require(Rhodium.Element)
	VirtualInput = require(Rhodium.VirtualInput)
end

local Game = {}
Game.__index = Game

function Game.waitForTopBar()
	XPath.new("game.CoreGui.RobloxLoadingGui.BlackFrame"):waitForDisappear()
end

function Game.clickSettingButton()
	local settingButton = XPath.new("game.CoreGui.RobloxGui.TopBarContainer.Settings.SettingsIcon"):waitForFirstInstance()
	Element.new(settingButton):click()
end

function Game.clickLeaveButton()
	local center = Element.new(game.CoreGui.RobloxGui.SettingsShield.SettingsShield.MenuContainer.PageViewClipper.PageView.PageViewInnerFrame.Players.ButtonsContainer.LeaveButtonButton):getCenter()
	VirtualInput.tap(center)
end

function Game.clickConfirmLeaveButton()
	Element.new("game.CoreGui.RobloxGui.SettingsShield.SettingsShield.MenuContainer.PageViewClipper.PageView.PageViewInnerFrame.LeaveGamePage.LeaveGameText.LeaveButtonContainer.LeaveGameButton"):click()
end

function Game.waitForBlackFrameDisappear()
	XPath.new("game.CoreGui.RobloxLoadingGui.BlackFrame"):waitForDisappear()
end

function Game.quitGame()
	Game.waitForTopBar()
	wait(2)
	Game.clickSettingButton()
	wait(2)
	Game.clickLeaveButton()
	wait(2)
	Game.clickConfirmLeaveButton()
end


return Game