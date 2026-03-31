local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService('RunService')
local NotificationService = game:GetService("NotificationService")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local AESceneLoader = require(Modules.LuaApp.Components.Avatar.AESceneLoader)
local AECharacterLoader = require(Modules.LuaApp.Components.Avatar.AECharacterLoader)
local AECharacterMover = require(Modules.LuaApp.Components.Avatar.AECharacterMover)
local AECameraManager = require(Modules.LuaApp.Components.Avatar.AECameraManager)
local AESaveManager = require(Modules.LuaApp.Components.Avatar.AESaveManager)
local AEUILoader = require(Modules.LuaApp.Components.Avatar.UI.AEUILoader)
local AppPage = require(Modules.LuaApp.AppPage)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESetResolutionScale = require(Modules.LuaApp.Actions.AEActions.AESetResolutionScale)
local AvatarEditorTheme = require(Modules.LuaApp.Themes.Avatar.AvatarEditorTheme)
local AELoader = Roact.Component:extend("AELoader")

local FFlagLuaRemoveRoactRoduxConnectUsage = game:GetFastFlag("LuaRemoveRoactRoduxConnectUsage")

function AELoader:init()
	self._context.AvatarEditorTheme = AvatarEditorTheme()

	self.startOnInit = false
	self.initialized = false

	-- Because characterLoader waits for child, this should be in a spawn.
	spawn(function()
		local store
		if FFlagLuaRemoveRoactRoduxConnectUsage then
			store = RoactRodux.UNSTABLE_getStore(self)
		else
			store = self.props.store
		end

		self.characterLoader = AECharacterLoader.new(store)
		self.sceneLoader = AESceneLoader.new(store)
		self.cameraManager = AECameraManager.new(store)
		self.characterMover = AECharacterMover.new(store)
		self.saveManager = AESaveManager.new(store)
		self.initialized = true

		if self.startOnInit then
			self:start()
			self.startOnInit = false
		end
	end)
end

function AELoader:willUnmount()
	if self.props.isVisible then
		self:stop()
	end
end

function AELoader:willUpdate(nextProps)
	if (not self.props.isVisible) and (nextProps.isVisible) then
		self:start()
	elseif (self.props.isVisible) and (not nextProps.isVisible) then
		self:stop()
	end
end

function AELoader:render()
	return Roact.createElement(AEUILoader, {
		avatarEditorActive = self.props.isVisible,
	})
end

function AELoader:start()
	-- Wait for initialization before starting.
	if not self.initialized then
		self.startOnInit = true
		return
	end

	-- Temporarily set this to false while this line in App.lua gets figured out.
	RunService:setThrottleFramerateEnabled(false)
	self.characterLoader:start()
	self.sceneLoader:start()
	self.cameraManager:start()
	self.characterMover:start()
	self.saveManager:start()
	-- Staging broadcasting of APP_READY to accomodate for unpredictable
	-- delay on the native side.
	-- Once Lua tab bar is integrated, there will be no use for this
	self.props.guiService:BroadcastNotification(AppPage.AvatarEditor, NotificationType.APP_READY)
	NotificationService:ActionEnabled(Enum.AppShellActionType.AvatarEditorPageLoaded)

	local currentResolutionScale = self.props.guiService:GetResolutionScale()

	if self.props.resolutionScale ~= currentResolutionScale then
		self.props.setResolutionScale(currentResolutionScale)
	end
end

function AELoader:stop()
	RunService:setThrottleFramerateEnabled(true)
	if not self.initialized then
		self.startOnInit = false
		return
	end
	self.characterLoader:stop()
	self.sceneLoader:stop()
	self.cameraManager:stop()
	self.characterMover:stop()
	self.saveManager:stop()
end

AELoader = RoactServices.connect({
	guiService = AppGuiService
})(AELoader)

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			resolutionScale = state.AEAppReducer.AEResolutionScale,
		}
	end,
	function(dispatch)
		return {
			setResolutionScale = function(scale)
				dispatch(AESetResolutionScale(scale))
			end,
		}
	end
)(AELoader)