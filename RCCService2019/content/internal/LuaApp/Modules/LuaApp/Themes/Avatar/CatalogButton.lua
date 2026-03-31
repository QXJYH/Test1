local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")

local CatalogButton = AvatarEditorThemeUtil.new()
CatalogButton.__index = CatalogButton

function CatalogButton.new()
	local self = {}
	setmetatable(self, CatalogButton)

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
                BackgroundColor = Colors.White,
                IconColor = Colors.Black,
                Text = {
                    Font = FFlagAvatarEditorGothamFont and Enum.Font.Gotham or Enum.Font.SourceSans,
                    Color = Colors.Black,
				},
			},
			ClassicTheme = {
				BackgroundColor = Colors.White,
                IconColor = Colors.Black,
                Text = {
                    Font = FFlagAvatarEditorGothamFont and Enum.Font.Gotham or Enum.Font.SourceSans,
                    Color = Colors.Black,
				},
			},
		},
	}

	return self
end

function CatalogButton:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return CatalogButton
