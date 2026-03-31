local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AEScrollingFrameThemeInfo = AvatarEditorThemeUtil.new()
AEScrollingFrameThemeInfo.__index = AEScrollingFrameThemeInfo

function AEScrollingFrameThemeInfo.new()
	local self = {}
	setmetatable(self, AEScrollingFrameThemeInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
				ButtonsPerRow = 3,
				Position = UDim2.new(1, -130, 0, 270),
				Size = UDim2.new(0, 491, 1, -270),
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ExtraVerticalShift = 8,
				BonusYPixels = 28,
				getAssetButtonSize = function(scrollingFrame)
					local availableWidth = scrollingFrame.AbsoluteSize.X + 9
					return (availableWidth / 3) - 14
				end,
			},
			Portrait = {
				ButtonsPerRow = 4,
				Position = UDim2.new(0, 0, 0, 50),
				Size = UDim2.new(1, 0, 1, -50),
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 0,
				BorderSizePixel = 1,
				ExtraVerticalShift = 25,
				BonusYPixels = 8,
				getAssetButtonSize = function(scrollingFrame)
					local availableWidth = scrollingFrame.AbsoluteSize.X
					return (availableWidth / 4) - 6
				end,
			},
			Landscape = {
				ButtonsPerRow = 4,
				Position = UDim2.new(0, 116, 0, 0),
				Size = UDim2.new(1, -128, 1, 0),
				AnchorPoint = Vector2.new(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ExtraVerticalShift = 8,
				BonusYPixels = 28,
				getAssetButtonSize = function(scrollingFrame)
					local availableWidth = scrollingFrame.AbsoluteSize.X + 9
					return (availableWidth / 4) - 14
				end,
			},
		},
		ColorThemes = {
			DarkTheme = {
				BackgroundColor = Colors.Slate,
				BorderSize = 0,
				PageLabelTextColor = Colors.Pumice,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				BackgroundColor = Colors.Gray4,
				BorderSize = 1,
				PageLabelTextColor = Colors.Gray2,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
		},
	}

	return self
end

function AEScrollingFrameThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEScrollingFrameThemeInfo