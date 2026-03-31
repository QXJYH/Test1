local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AECategoryMenuAndButtons = AvatarEditorThemeUtil.new()
AECategoryMenuAndButtons.__index = AECategoryMenuAndButtons

function AECategoryMenuAndButtons.new()
	local self = {}
	setmetatable(self, AECategoryMenuAndButtons)

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
				Background = {
					Fill = Colors.Graphite,
					Border = Colors.Graphite,
					SelectedImageColor = Colors.Graphite,
					UnSelectedImageColor = Colors.White,
				},
				Button = {
					BackgroundUnselected = Colors.White,
					BackgroundSelected = Colors.White,
					Indicator = Colors.Flint,
					IconSelected = Colors.White,
					TextColor = Colors.White,
					SelectedTextColor = Colors.White,
				},
				CloseButton = {
					Color = Colors.White,
				},
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				Background = {
					Fill = Colors.White,
					Border = Colors.Gray3,
					SelectedImageColor = Colors.White,
					UnSelectedImageColor = Colors.Black,
				},
				Button = {
					BackgroundUnselected = Colors.Gray4,
					BackgroundSelected = Colors.Orange,
					Indicator = Colors.Gray4,
					IconSelected = Colors.Black,
					TextColor = Colors.Black,
					SelectedTextColor = Colors.Orange,
				},
				CloseButton = {
					Color = Colors.Gray3,
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

function AECategoryMenuAndButtons:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AECategoryMenuAndButtons
