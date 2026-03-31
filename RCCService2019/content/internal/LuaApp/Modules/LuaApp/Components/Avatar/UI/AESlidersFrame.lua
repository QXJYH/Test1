local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESlider = require(Modules.LuaApp.Components.Avatar.UI.AESlider)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AESendAnalytics = require(Modules.LuaApp.Thunks.AEThunks.AESendAnalytics)
local AESetAvatarScales = require(Modules.LuaApp.Actions.AEActions.AESetAvatarScales)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AECurrentPage = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPage)
local AEAvatarTypeSwitch = require(Modules.LuaApp.Components.Avatar.UI.AEAvatarTypeSwitch)
local FIntAvatarEditorNewCatalog = require(CorePackages.AppTempCommon.LuaApp.Flags.AvatarEditorNewCatalogEnabled)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorFixSliderSensitivity = settings():GetFFlag("AvatarEditorFixSliderSensitivity")

local AESlidersFrame = Roact.PureComponent:extend("AESlidersFrame")

local View = {
	[DeviceOrientationMode.Portrait] = {
		EXTRA_VERTICAL_SHIFT = 8,
		SLIDER_POSITION_Y = 70,
		SLIDER_VERTICAL_OFFSET = 70,
		PAGE_LABEL_SIZE = 31,
	},

	[DeviceOrientationMode.Landscape] = {
		EXTRA_VERTICAL_SHIFT = 8,
		SLIDER_POSITION_Y = 56,
		SLIDER_VERTICAL_OFFSET = 67,
		PAGE_LABEL_SIZE = 0,
	}
}

function AESlidersFrame:init()
	self.AvatarEditorNewCatalogButtonFlag = FIntAvatarEditorNewCatalog(self.props.localUserId)
	self.slidersRef = Roact.createRef()
	local setScales = self.props.setScales
	local analytics = self.props.analytics
	local sendAnalytics = self.props.sendAnalytics
	local deviceOrientation = self.props.deviceOrientation
	local scrollingFrameRef = self.props.scrollingFrameRef
	local scalesRules = self.props.scalesRules
	scrollingFrameRef.CanvasPosition = Vector2.new(0, 0)
	local sliderNum = 4
	if self.AvatarEditorNewCatalogButtonFlag then
		View[DeviceOrientationMode.Landscape].SLIDER_VERTICAL_OFFSET = 60
		sliderNum = 5
	end

	scrollingFrameRef.CanvasSize = UDim2.new(0, 0, 0, View[deviceOrientation].SLIDER_POSITION_Y
		+ (View[deviceOrientation].SLIDER_VERTICAL_OFFSET * sliderNum) + (View[deviceOrientation].EXTRA_VERTICAL_SHIFT + 25))

	self.scalesInfo = {
		[1] = {
			property = "height",
			title = 'Feature.Avatar.Label.Height',
			min = scalesRules.height.min,
			max = scalesRules.height.max,
			default = 1.0,
			increment = scalesRules.height.increment,
			setScale = function(scale)
				setScales({height = scale})
				sendAnalytics(analytics.setAvatarHeight, scale)
			end,
		},
		[2] = {
			property = "width",
			title = 'Feature.Avatar.Label.Width',
			min = scalesRules.width.min,
			max = scalesRules.width.max,
			default = 1.0,
			increment = scalesRules.width.increment,
			setScale = function(scale)
				setScales({
					width = scale,
					depth = 0.5 * scale + 0.5,
				})
				sendAnalytics(analytics.setAvatarWidth, scale)
			end,
		},
		[3] = {
			property = "head",
			title = 'Feature.Avatar.Label.Head',
			min = scalesRules.head.min,
			max = scalesRules.head.max,
			default = 1,
			increment = scalesRules.head.increment,
			setScale = function(scale)
				setScales({head = scale})
				sendAnalytics(analytics.setAvatarHeadSize, scale)
			end,
		},
		[4] = {
			property = "bodyType",
			title = 'Feature.Avatar.Label.BodyType',
			min = scalesRules.bodyType.min,
			max = scalesRules.bodyType.max,
			default = 0.00,
			increment = scalesRules.bodyType.increment,
			setScale = function(scale)
				setScales({bodyType = scale})
				sendAnalytics(analytics.setAvatarBodyType, scale)
			end,
		},
		[5] = {
			property = "proportion",
			title = 'Feature.Avatar.Label.Proportions',
			min = scalesRules.proportion.min,
			max = scalesRules.proportion.max,
			default = 0.0,
			increment = scalesRules.proportion.increment,
			setScale = function(scale)
				setScales({proportion = scale})
				sendAnalytics(analytics.setAvatarProportion, scale)
			end,
		}
	}
end

function AESlidersFrame:didUpdate(prevProps)
	local page = self.props.page

	if AEUtils.gamepadNavigationEnabled()
		and page.pageType == AEConstants.PageType.Scale
		and self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage
		and self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel
	then
		if FFlagAvatarEditorFixSliderSensitivity then
			GuiService.SelectedCoreObject = self.slidersRef.current["Slider-1"].DraggerArea.DraggerImage.DraggerButton
		else
			GuiService.SelectedCoreObject = self.slidersRef.current["Slider-1"].Dragger.DraggerButton
		end
	end
end

function AESlidersFrame:render()
	local deviceOrientation = self.props.deviceOrientation
	local analytics = self.props.analytics
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AESliders:getThemeInfo(deviceOrientation, themeName)
	local scrollingFrameRef = self.props.scrollingFrameRef
	local scalesInfo = self.scalesInfo
	local sliders = {}

	-- Create all the sliders
	for index = 1, #scalesInfo do
		sliders["Slider-" ..index] = Roact.createElement(AESlider, {
			index = index,
			deviceOrientation = deviceOrientation,
			scaleInfo = scalesInfo[index],
			scrollingFrameRef = scrollingFrameRef,
		})
	end

	local bgScale = self.AvatarEditorNewCatalogButtonFlag and #scalesInfo + 2 or #scalesInfo + 1
	local backgroundSize = View[deviceOrientation].SLIDER_POSITION_Y * bgScale

	local backgroundImage = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Background or nil
	sliders["BackgroundImage"] = themeInfo.OrientationTheme.BackgroundImage(backgroundSize, backgroundImage)

	if self.AvatarEditorNewCatalogButtonFlag and not AEUtils.gamepadNavigationEnabled() then
		sliders["AEAvatarTypeSwitch"] = Roact.createElement(AEAvatarTypeSwitch, {
			deviceOrientation = deviceOrientation,
			analytics = analytics,
			index = #scalesInfo + 1,
		})
	end

	local SliderFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, backgroundSize),
			BackgroundTransparency = 1,

			[Roact.Ref] = self.slidersRef,
		}, sliders)

	local sliderNum = self.AvatarEditorNewCatalogButtonFlag and #scalesInfo or #scalesInfo - 1

	scrollingFrameRef.CanvasSize = UDim2.new(0, 0, 0, View[deviceOrientation].SLIDER_POSITION_Y
	+ (View[deviceOrientation].SLIDER_VERTICAL_OFFSET * sliderNum)
	+ (View[deviceOrientation].EXTRA_VERTICAL_SHIFT + View[deviceOrientation].PAGE_LABEL_SIZE))

	return SliderFrame
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			scalesRules = state.AEAppReducer.AEAvatarSettings[AEConstants.AvatarSettings.scalesRules],
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
			page = AECurrentPage(state.AEAppReducer),
			--remove localUserId when removing flag FIntAvatarEditorNewCatalog
			localUserId = state.LocalUserId,
		}
	end,
	function(dispatch)
		return {
			setScales = function(scales)
				dispatch(AESetAvatarScales(scales))
			end,
			sendAnalytics = function(analyticsFunction, value)
				dispatch(AESendAnalytics(analyticsFunction, value))
			end,
		}
	end
)(AESlidersFrame)