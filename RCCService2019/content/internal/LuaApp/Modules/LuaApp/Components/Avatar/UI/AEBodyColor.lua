local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AESetBodyColors = require(Modules.LuaApp.Actions.AEActions.AESetBodyColors)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AESendAnalytics = require(Modules.LuaApp.Thunks.AEThunks.AESendAnalytics)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AEBodyColor= Roact.PureComponent:extend("AEBodyColor")
local SKIN_COLORS_PER_ROW = 5
local SKIN_COLOR_GRID_PADDING = 12
local View = {
	[DeviceOrientationMode.Portrait] = {
		SKIN_COLOR_EXTRA_VERTICAL_SHIFT = 2,
	},

	[DeviceOrientationMode.Landscape] = {
		SKIN_COLOR_EXTRA_VERTICAL_SHIFT = 0,
	}
}

function AEBodyColor:getImageSelectionObject()
	local image = Instance.new("ImageLabel")
	image.Name = 'Selector'
	image.Image = "rbxasset://textures/ui/Shell/AvatarEditor/color selector/color dot-select.png";
	image.Position = UDim2.new(0, -12, 0, -12)
	image.Size = UDim2.new(1, 24, 1, 24)
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.ZIndex = 4

	self.imageSelectionObject = image
end

function AEBodyColor:getEquippedFrame()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEBodyColors:getThemeInfo(deviceOrientation, themeName)
	local info = AESpriteSheet.getImage("gr-ring-selector")
	local checkMark = themeInfo.OrientationTheme.CheckMark

	if FFlagAvatarEditorEnableThemes then
		info.imageRectOffset = nil
		info.imageRectSize = nil
	end

	local equippedFrame = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
		Position = UDim2.new(-.1, 0, -.1, 0),
		Size = UDim2.new(1.2, 0, 1.2, 0),
		BackgroundTransparency = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Image = FFlagAvatarEditorEnableThemes and themeInfo.OrientationTheme.EquippedFrame.Image or info.image,
		ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.SelectedRing or Color3.fromRGB(255, 255, 255),
		ImageRectOffset = info.imageRectOffset,
		ImageRectSize = info.imageRectSize,
		ZIndex = FFlagAvatarEditorEnableThemes and 2 or 1,
	}, {
		checkMark,
	})

	return equippedFrame
end

function AEBodyColor:init()
	self:getImageSelectionObject()
end

function AEBodyColor:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AEBodyColors:getThemeInfo(deviceOrientation, themeName)
	local setBodyColors = self.props.setBodyColors
	local currentBodyColor = self.props.currentBodyColor
	local buttonSize = self.props.buttonSize
	local brick = self.props.brick
	local index = self.props.index
	local sendAnalytics = self.props.sendAnalytics
	local analytics = self.props.analytics
	local children = {}
	local mask = deviceOrientation == DeviceOrientationMode.Portrait
		and "rbxasset://textures/AvatarEditorImages/Portrait/gr-color-block-mask-phone.png"
		or "rbxasset://textures/AvatarEditorImages/Landscape/gr-color-block-mask-tablet.png"
	local row = math.ceil(index / SKIN_COLORS_PER_ROW)
	local column = ((index - 1) % SKIN_COLORS_PER_ROW) + 1

	local info = {}
	info.position = UDim2.new(0, SKIN_COLOR_GRID_PADDING + (column - 1) * (buttonSize + SKIN_COLOR_GRID_PADDING),
		0, SKIN_COLOR_GRID_PADDING + (row - 1) * (buttonSize + SKIN_COLOR_GRID_PADDING)
		+ View[deviceOrientation].SKIN_COLOR_EXTRA_VERTICAL_SHIFT)
	info.size = UDim2.new(0, buttonSize, 0, buttonSize)
	info.imageColor3 = brick.Color

	local equippedFrame = nil
	--Determine if this color should have the "equipped" frame
	if currentBodyColor == brick.Number then
		if not FFlagAvatarEditorEnableThemes then
			children["SelectedHighlight"] = self:getEquippedFrame()
		else
			equippedFrame = self:getEquippedFrame()
		end
	end

	if not FFlagAvatarEditorEnableThemes then
		return Roact.createElement("ImageButton", {
			Position = info.position,
			Size = info.size,
			BackgroundTransparency = 0,
			BackgroundColor3 = info.imageColor3,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Image = mask,
			ImageColor3 = themeInfo.OrientationTheme.BodyColorImageColor3,
			SelectionImageObject = self.imageSelectionObject,

			-- Update the store when this color has been picked.
			[Roact.Event.Activated] = function(rbx)
				if currentBodyColor ~= brick.Number then
					local bodyColors = {
						["headColorId"] = brick.Number,
						["leftArmColorId"] = brick.Number,
						["leftLegColorId"] = brick.Number,
						["rightArmColorId"] = brick.Number,
						["rightLegColorId"] = brick.Number,
						["torsoColorId"] = brick.Number,
					}
					setBodyColors(bodyColors)
					sendAnalytics(analytics.setBodyColors, bodyColors)
				end
			end
		},
			children
		)
	else
		return Roact.createElement("Frame", {
			Size = info.size,
			Position = info.position,
			BackgroundTransparency = 1,
		}, {
			BodyColor = Roact.createElement(ImageSetButton, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Image = themeInfo.OrientationTheme.ColorBlock.Image,
				ImageColor3 = info.imageColor3,
				SelectionImageObject = self.imageSelectionObject,

				-- Update the store when this color has been picked.
				[Roact.Event.Activated] = function(rbx)
					if currentBodyColor ~= brick.Number then
						local bodyColors = {
							["headColorId"] = brick.Number,
							["leftArmColorId"] = brick.Number,
							["leftLegColorId"] = brick.Number,
							["rightArmColorId"] = brick.Number,
							["rightLegColorId"] = brick.Number,
							["torsoColorId"] = brick.Number,
						}
						setBodyColors(bodyColors)
						sendAnalytics(analytics.setBodyColors, bodyColors)
					end
				end
			}),
			EquippedFrame = equippedFrame,
			Border = Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = themeInfo.OrientationTheme.Border.Image,
				ImageColor3 = themeInfo.ColorTheme.BorderColor,
			})
		})
	end
end

return RoactRodux.UNSTABLE_connect2(
	function() return {} end,
	function(dispatch)
		return {
			setBodyColors = function(bodyColors)
				dispatch(AESetBodyColors(bodyColors))
			end,
			sendAnalytics = function(analyticsFunction, value)
				dispatch(AESendAnalytics(analyticsFunction, value))
			end,
		}
	end
)(AEBodyColor)