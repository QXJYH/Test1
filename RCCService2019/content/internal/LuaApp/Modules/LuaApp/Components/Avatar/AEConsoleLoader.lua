local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local ShellModules = Modules.Shell
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AppState = require(Modules.Shell.AppState)
local AEConsoleControlsManager = require(Modules.LuaApp.Components.Avatar.AEConsoleControlsManager)
local CameraManager = require(ShellModules.CameraManager)
local AELoader = require(Modules.LuaApp.Components.Avatar.AELoader)
local AvatarEditorScreenWrapper = require(ShellModules.AvatarEditorScreenWrapper)

local AEConsoleLoader = Roact.Component:extend("AEConsoleLoader")

function AEConsoleLoader:init()
	self.consoleControlsManager = AEConsoleControlsManager.new(AppState.store)
end

function AEConsoleLoader:willUnmount()
	self:stop()
end

function AEConsoleLoader:didUpdate(prevProps, prevState)
	-- Start and stop managers if the avatar editor is displayed or not
	if self.props.screenList ~= prevProps.screenList then
		if prevProps.screenList[1] and prevProps.screenList[1].id ~= tostring(AvatarEditorScreenWrapper)
			and self.props.screenList[1] and self.props.screenList[1].id == tostring(AvatarEditorScreenWrapper) then
			self:start()
		elseif prevProps.screenList[1] and prevProps.screenList[1].id == tostring(AvatarEditorScreenWrapper)
			and self.props.screenList[1] and self.props.screenList[1].id ~= tostring(AvatarEditorScreenWrapper) then
			self:stop()
		end
	end
end

function AEConsoleLoader:render()
	local topScreen = self.props.screenList[1]

	return Roact.createElement(AELoader, {
		store = AppState.store,
		isVisible = topScreen.id == tostring(AvatarEditorScreenWrapper),
	})
end

function AEConsoleLoader:start()
	CameraManager:SwitchToAvatarEditor()
	self.consoleControlsManager:start()
end

function AEConsoleLoader:stop()
	CameraManager:SwitchToFlyThrough()
	self.consoleControlsManager:stop()
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenList = state.ScreenList,
		}
	end
)(AEConsoleLoader)