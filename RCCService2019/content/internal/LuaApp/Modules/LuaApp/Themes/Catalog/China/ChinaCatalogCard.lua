local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local ChinaCatalogThemeInfo = AvatarEditorThemeUtil.new()
ChinaCatalogThemeInfo.__index = ChinaCatalogThemeInfo

function ChinaCatalogThemeInfo.new()
	local self = {}
	setmetatable(self, ChinaCatalogThemeInfo)

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
					Color = Colors.Graphite,
					Transparency = 0.0,
				},
				Footer = {
					Color = Colors.Slate,
					Transparency = 1,
				},
				Title = {
					Font = Enum.Font.SourceSans,
					Color = Colors.White,
				},
				Price = {
					Font = Enum.Font.SourceSans,
					Color = Colors.Smoke,
					Transparency = 0,
				},
			},
			ClassicTheme = {},
		},
	}

	return self
end

function ChinaCatalogThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return ChinaCatalogThemeInfo