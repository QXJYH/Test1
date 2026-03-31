local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AEAssetOptionsAndDetailsMenu = AvatarEditorThemeUtil.new()
AEAssetOptionsAndDetailsMenu.__index = AEAssetOptionsAndDetailsMenu

function AEAssetOptionsAndDetailsMenu.new()
	local self = {}
	setmetatable(self, AEAssetOptionsAndDetailsMenu)

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
				AssetOptionsMenu = {
					TextColor = Colors.White,
					BackgroundColor = Colors.Flint,
					SectionDividerColor = Colors.Graphite,
					SubSectionDividerColor = Colors.Graphite,
				},
				AssetDetails = {
					BackgroundColor = Colors.Flint,
					Divider = Colors.Graphite,
					AssetBorder = Colors.Graphite,
					TitleTextColor = Colors.White,
					CreatorTextColor = Colors.Pumice,
					DetailTextColor = Colors.Pumice,
					AssetImageBorder = Colors.Graphite,
					CloseButtonColor = Colors.White,
				},
				Text = {
					Font = Enum.Font.Gotham,
					FontBold = Enum.Font.GothamBold,
				},
			},
			ClassicTheme = {
				AssetOptionsMenu = {
					TextColor = Colors.Black,
					BackgroundColor = Colors.White,
					SectionDividerColor = Colors.Orange,
					SubSectionDividerColor = Colors.Gray3,
				},
				AssetDetails = {
					BackgroundColor = Colors.White,
					Divider = Colors.Gray3,
					AssetBorder = Colors.Black,
					TitleTextColor = Colors.Black,
					CreatorTextColor = Colors.Gray3,
					DetailTextColor = Colors.Black,
					AssetImageBorder = Colors.Black,
					CloseButtonColor = Colors.Gray3,
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

function AEAssetOptionsAndDetailsMenu:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEAssetOptionsAndDetailsMenu
