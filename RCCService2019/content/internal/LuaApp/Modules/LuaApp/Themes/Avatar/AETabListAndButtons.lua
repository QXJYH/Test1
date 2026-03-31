local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AETabListAndButtons = AvatarEditorThemeUtil.new()
AETabListAndButtons.__index = AETabListAndButtons

function AETabListAndButtons.new()
	local self = {}
	setmetatable(self, AETabListAndButtons)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {},
			Portrait = {},
			Landscape = {},
		},
		ColorThemes = {
			DarkTheme = {
				TabList = {
					BackgroundColor = Colors.Flint,
					BorderColor = Colors.Flint,
					BorderSize = 0,
				},
				DividerColor = Colors.Graphite,
				TabButton = {
					DefaultBackgroundColor = Colors.Flint,
					SelectedBackgroundColor = Colors.Flint,
					UnusableBackgroundColor = Colors.Gray3,
					SelectedUnusableBackgroundColor = Colors.BrownWarning,
					SelectedImageColor = Colors.White,
					UnselectedImageColor = Colors.Pumice,
					SelectedTextColor = Colors.White,
					UnselectedTextColor = Colors.White,
				},
				IconText = {
					UnselectedImageColor = Colors.Pumice,
					SelectedTextColor = Colors.White,
				},
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				TabList = {
					BackgroundColor = Colors.White,
					BorderColor = Colors.Gray3,
					BorderSize = 1,
				},
				DividerColor = Colors.Gray4,
				TabButton = {
					DefaultBackgroundColor = Colors.White,
					SelectedBackgroundColor = Colors.Orange,
					UnusableBackgroundColor = Colors.Gray3,
					SelectedUnusableBackgroundColor = Colors.BrownWarning,
					SelectedImageColor = Colors.White,
					UnselectedImageColor = Colors.Black,
					SelectedTextColor = Colors.White,
					UnselectedTextColor = Colors.Gray2,
				},
				IconText = {
					UnselectedImageColor = Colors.Black,
					SelectedTextColor = Colors.White,
				},
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
		},
	}

	return self
end

function AETabListAndButtons:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AETabListAndButtons
