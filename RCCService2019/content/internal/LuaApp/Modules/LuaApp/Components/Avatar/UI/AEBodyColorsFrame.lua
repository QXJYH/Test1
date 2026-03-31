local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEBodyColor = require(Modules.LuaApp.Components.Avatar.UI.AEBodyColor)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AECurrentPage = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPage)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AEBodyColorsFrame = Roact.PureComponent:extend("AEBodyColorsFrame")

local SKIN_COLORS_PER_ROW = 5
local SKIN_COLOR_GRID_PADDING = 12

local SKIN_COLORS = {
	'Dark taupe','Brown','Linen','Nougat','Light orange',
	'Dirt brown','Reddish brown','Cork','Burlap','Brick yellow',
	'Sand red','Dusty Rose','Medium red','Pastel orange','Carnation pink',
	'Sand blue','Steel blue','Pastel Blue','Pastel violet','Lilac',
	'Bright bluish green','Shamrock','Moss','Medium green','Br. yellowish orange',
	'Bright yellow','Daisy orange','Dark stone grey','Mid grey','Institutional white',
}

local View = {
	[DeviceOrientationMode.Portrait] = {
		SKIN_COLOR_EXTRA_VERTICAL_SHIFT = 8,
		PAGE_LABEL_SIZE = 31,
	},

	[DeviceOrientationMode.Landscape] = {
		SKIN_COLOR_EXTRA_VERTICAL_SHIFT = 0,
		PAGE_LABEL_SIZE = 0,
	}
}

-- Return the bodyColor value if all parts of the humanoid are using the same color, otherwise return nil
function AEBodyColorsFrame:getSameBodyColor()
	local bodyColors = self.props.bodyColors
	local bodyColor = nil

	for _, value in pairs(bodyColors) do
		if bodyColor == nil then
			bodyColor = value
		elseif bodyColor ~= value then
			return nil
		end
	end

	return bodyColor
end

-- Get the white background frame for the body color tab
function AEBodyColorsFrame:bodyColorBackgroundImage()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEBodyColors:getThemeInfo(deviceOrientation, themeName)
	local scrollingFrameRef = self.props.scrollingFrameRef
	local skinColorList = self.state.skinColorList

	local rows = math.ceil(#skinColorList / SKIN_COLORS_PER_ROW)
	local availibleWidth = scrollingFrameRef.AbsoluteSize.X
	local buttonSize = (availibleWidth - ((SKIN_COLORS_PER_ROW + 1) * SKIN_COLOR_GRID_PADDING)) / SKIN_COLORS_PER_ROW

	local backgroundImage
	if deviceOrientation == DeviceOrientationMode.Landscape then
		backgroundImage = Roact.createElement("ImageLabel", {
			Position = UDim2.new(0, -4, 0, -3),
			Size = UDim2.new(1, 8, 0, rows * buttonSize + (rows + 1) * SKIN_COLOR_GRID_PADDING + 8),
			BackgroundColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BackgroundColor
				or themeInfo.OrientationTheme.BackgroundImageBackgroundColor,
		})
	elseif deviceOrientation == DeviceOrientationMode.Portrait then
		backgroundImage = Roact.createElement("ImageLabel", {
			Position = UDim2.new(0, 2, 0, 4),
			Size = UDim2.new(1, -4, 1, -29),
			BorderSizePixel = 0,
			BackgroundColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.BackgroundColor
				or themeInfo.OrientationTheme.BackgroundImageBackgroundColor,
		})
	end

	return backgroundImage
end

function AEBodyColorsFrame:render()
	local analytics = self.props.analytics
	local scrollingFrameRef = self.props.scrollingFrameRef
	local deviceOrientation = self.props.deviceOrientation
	local skinColorList = self.state.skinColorList
	local availibleWidth = scrollingFrameRef.AbsoluteSize.X
	local buttonSize = (availibleWidth - ((SKIN_COLORS_PER_ROW + 1) * SKIN_COLOR_GRID_PADDING)) / SKIN_COLORS_PER_ROW
	local buttons = {}
	local currentBodyColor = self:getSameBodyColor()

	-- Create a roact element for each body color.
	for index, brick in pairs(skinColorList) do
		buttons["Button-"..index] = Roact.createElement(AEBodyColor, {
			deviceOrientation = deviceOrientation,
			analytics = analytics,
			currentBodyColor = currentBodyColor,
			index = index,
			buttonSize = buttonSize,
			brick = brick,
		})
	end

	local backgroundImage = self:bodyColorBackgroundImage()

	local BodyColorsFrame = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Buttons = Roact.createElement("Frame", {
			[Roact.Ref] = self.bodyColorFrameRef,
		}, buttons),
		BackgroundImage = backgroundImage,
	})

	scrollingFrameRef.CanvasSize = UDim2.new(0, 0, 0,
		math.ceil(#skinColorList / SKIN_COLORS_PER_ROW) * (buttonSize + SKIN_COLOR_GRID_PADDING)
			+ SKIN_COLOR_GRID_PADDING + View[deviceOrientation].PAGE_LABEL_SIZE)

	return BodyColorsFrame
end

function AEBodyColorsFrame:init()
	local scrollingFrameRef = self.props.scrollingFrameRef
	local skinColorList = {}
	self.bodyColorFrameRef = Roact.createRef()

	for i, skinColor in pairs(SKIN_COLORS) do
		skinColorList[i] = BrickColor.new(skinColor)
	end

	scrollingFrameRef.CanvasPosition = Vector2.new(0, 0) -- Reset the position of the canvas when this tab is selected.

	self.state = {
		skinColorList = skinColorList,
	}
end

function AEBodyColorsFrame:willUpdate(nextProps)
	local page = self.props.page

	if AEUtils.gamepadNavigationEnabled() and page.pageType == AEConstants.PageType.BodyColors
		and nextProps.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage
		and nextProps.gamepadNavigationMenuLevel ~= self.props.gamepadNavigationMenuLevel then
		GuiService.SelectedCoreObject = FFlagAvatarEditorEnableThemes and self.bodyColorFrameRef.current["Button-1"].BodyColor
			or self.bodyColorFrameRef.current["Button-1"]
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			bodyColors = state.AEAppReducer.AECharacter.AEBodyColors,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
			page = AECurrentPage(state.AEAppReducer),
		}
	end
)(AEBodyColorsFrame)