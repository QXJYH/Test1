local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AEAvatarTypeSwitch = AvatarEditorThemeUtil.new()
AEAvatarTypeSwitch.__index = AEAvatarTypeSwitch

function AEAvatarTypeSwitch.new()
	local self = {}
	setmetatable(self, AEAvatarTypeSwitch)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {},
			Portrait = {
				SliderFrame = {
					PosXScale = 0.1,
					PosXOffset = 0,
					PosY = 70,
				}
			},
			Landscape = {
				SliderFrame = {
					PosXScale = 0,
					PosXOffset = 29,
					PosY = 54,
				}
			},
		},
		ColorThemes = {
			DarkTheme = {
				OuterColor = Colors.Graphite,
				OuterColorSlider = Colors.Graphite,
				InnerColor = Colors.Pumice,
				ActiveTextColor = Colors.White,
				InactiveTextColor = Colors.Pumice,
				InactiveTextColorSlider = Colors.Pumice,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				OuterColor = Colors.White,
				OuterColorSlider = Colors.Gray4,
				InnerColor = Colors.BluePrimary,
				ActiveTextColor = Colors.White,
				InactiveTextColor = Colors.Gray3,
				InactiveTextColorSlider = Colors.Gray3,
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
		},
	}

	return self
end

function AEAvatarTypeSwitch:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEAvatarTypeSwitch
