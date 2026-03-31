local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local Constants = require(Modules.LuaApp.Constants)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local getScreenBottomInset = require(Modules.LuaApp.getScreenBottomInset)

local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local SetScreenSize = require(Modules.LuaApp.Actions.SetScreenSize)
local SetDeviceOrientation = require(Modules.LuaApp.Actions.SetDeviceOrientation)
local SetFormFactor = require(Modules.LuaApp.Actions.SetFormFactor)
local SetStatusBarHeight = require(Modules.LuaApp.Actions.SetStatusBarHeight)
local SetGlobalGuiInset = require(Modules.LuaApp.Actions.SetGlobalGuiInset)

local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local AppRunService = require(Modules.LuaApp.Services.AppRunService)
local RoactServices = require(Modules.LuaApp.RoactServices)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local IsLuaBottomBarEnabled = FlagSettings.IsLuaBottomBarEnabled()

local COMPACT_VIEW_MAX_WIDTH = 600

local legacyInputSettingRefactor = settings():GetFFlag("LuaAppLegacyInputSettingRefactor")
local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local ViewportManager = Roact.Component:extend("ViewportManager")

function ViewportManager:init()

	self.updateDeviceOrientation = function(viewportSize)
		local deviceOrientation = viewportSize.x > viewportSize.y and
			DeviceOrientationMode.Landscape or DeviceOrientationMode.Portrait

		if self.props.deviceOrientation ~= deviceOrientation then
			self.props.setDeviceOrientation(deviceOrientation)
		end
	end

	self.updateDeviceFormFactor = function(viewportSize)
		local useWidthBasedRule = self.props.useWidthBasedRule
		local formFactor = FormFactor.WIDE

		if useWidthBasedRule then
			if viewportSize.X < COMPACT_VIEW_MAX_WIDTH then
				formFactor = FormFactor.COMPACT
			end
		else
			if viewportSize.Y > viewportSize.X then
				formFactor = FormFactor.COMPACT
			end
		end

		self.props.setFormFactor(formFactor)
	end

	self.updateViewport = function()
		local viewportSize = Workspace.CurrentCamera.ViewportSize

		-- Hacky code awaits underlying mechanism fix.
		-- Viewport will get a 0,0,1,1 rect before it is properly set.
		if viewportSize.X > 1 and viewportSize.Y > 1 then
			self.props.setScreenSize(viewportSize)
			self.updateDeviceOrientation(viewportSize)
			self.updateDeviceFormFactor(viewportSize)
		end
	end

	self.updateStatusBarHeight = function()
		local newStatusBarHeight = UserInputService.StatusBarSize.Y
		if self.props.statusBarHeight ~= newStatusBarHeight then
			self.props.setStatusBarHeight(newStatusBarHeight)
		end
	end

	-- Android device might still have BottomBarSize when we HIDE_TAB_BAR
	-- Which is for system virtual navigation bar
	-- BottomBarSize might change while app is running depending on the device
	-- iOS device should fall back to safeZoneOffsets.bottom when we HIDE_TAB_BAR
	self.updateGlobalGuiInset = function()
		local x2 = UserInputService.RightBarSize.X

		local screenBottomInset = getScreenBottomInset()
		local policyUseBottomBar = self.props.useBottomBar
		local showBottomBar = IsLuaBottomBarEnabled and self.props.bottomBarVisible and policyUseBottomBar
		local luaBottomBarHeight = showBottomBar and Constants.BOTTOM_BAR_SIZE or 0
		local y2 = luaBottomBarHeight + screenBottomInset

		-- set globalGuiInset in store
		self.props.setGlobalGuiInset(0, 0, x2, y2)
	end
end

function ViewportManager:render()
	local guiService = self.props.guiService

	return Roact.createElement("Folder", {}, {
		viewportSizeListener = Roact.createElement(ExternalEventConnection, {
			event = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),
			callback = self.updateViewport,
		}),
		statusBarSizeListener = Roact.createElement(ExternalEventConnection, {
			event = UserInputService:GetPropertyChangedSignal("StatusBarSize"),
			callback = self.updateStatusBarHeight,
		}),
		bottomBarSizeListener = (not _G.__TESTEZ_RUNNING_TEST__) and Roact.createElement(ExternalEventConnection, {
			event = UserInputService:GetPropertyChangedSignal("BottomBarSize"),
			callback = self.updateGlobalGuiInset,
		}),
		rightBarSizeListener = (not _G.__TESTEZ_RUNNING_TEST__) and Roact.createElement(ExternalEventConnection, {
			event = UserInputService:GetPropertyChangedSignal("RightBarSize"),
			callback = self.updateGlobalGuiInset,
		}),
		safeZoneOffsetsListener = (not _G.__TESTEZ_RUNNING_TEST__) and Roact.createElement(ExternalEventConnection, {
			event = guiService.SafeZoneOffsetsChanged,
			callback = self.updateGlobalGuiInset,
		}),
	})
end

function ViewportManager:didMount()
	local policyUseBottomBar = self.props.useBottomBar
	if IsLuaBottomBarEnabled or not policyUseBottomBar then
		-- Remove this once native support is done: MOBCORE-2047
		self.props.guiService:BroadcastNotification("", NotificationType.HIDE_TAB_BAR)
	end
	if not legacyInputSettingRefactor then
		UserInputService.LegacyInputEventsEnabled = false
	end
	self.updateViewport()
	self.updateStatusBarHeight()
	self.updateGlobalGuiInset()
end

function ViewportManager:didUpdate(prevProps)
	if self.props.bottomBarVisible ~= prevProps.bottomBarVisible then
		self.updateGlobalGuiInset()
	end

	-- set store's GlobalGuiInset to app view
	local globalGuiInset = self.props.globalGuiInset
	if globalGuiInset ~= prevProps.globalGuiInset then
		self.props.guiService:SetGlobalGuiInset(globalGuiInset.left, globalGuiInset.top,
			globalGuiInset.right, globalGuiInset.bottom)
	end

	local hasScreenGuiBlur = self.props.hasScreenGuiBlur
	if FFlagLuaAppEnablePageBlur and
		hasScreenGuiBlur ~= prevProps.hasScreenGuiBlur then
		self.props.runService:SetRobloxGuiFocused(hasScreenGuiBlur)
	end
end

ViewportManager = RoactRodux.UNSTABLE_connect2(
	function(state)
		return {
			statusBarHeight = state.TopBar.statusBarHeight,
			deviceOrientation = state.DeviceOrientation,
			globalGuiInset = state.GlobalGuiInset,
			bottomBarVisible = state.TabBarVisible,
			hasScreenGuiBlur = state.ScreenGuiBlur.hasBlur,
		}
	end,
	function(dispatch)
		return {
			setScreenSize = function(viewportSize)
				dispatch(SetScreenSize(viewportSize))
			end,
			setDeviceOrientation = function(orientation)
				dispatch(SetDeviceOrientation(orientation))
			end,
			setFormFactor = function(formFactor)
				dispatch(SetFormFactor(formFactor))
			end,
			setStatusBarHeight = function(newStatusBarHeight)
				dispatch(SetStatusBarHeight(newStatusBarHeight))
			end,
			setGlobalGuiInset = function(left, top, right, bottom)
				return dispatch(SetGlobalGuiInset(left, top, right, bottom))
			end,
		}
	end
)(ViewportManager)

ViewportManager = RoactServices.connect({
	guiService = AppGuiService,
	runService = AppRunService,
})(ViewportManager)

if FFlagLuaAppPolicyRoactConnector then
	ViewportManager = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			useWidthBasedRule = appPolicy.getUseWidthBasedFormFactorRule(),
			useBottomBar = appPolicy.getUseBottomBar(),
		}
	end)(ViewportManager)
else
	ViewportManager = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			useWidthBasedRule = appPolicy.IsFeatureEnabled(AppFeature.UseWidthBasedFormFactorRule),
			useBottomBar = appPolicy.getUseBottomBar(),
		}
	end)(ViewportManager)
end

return ViewportManager
