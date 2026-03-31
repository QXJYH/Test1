local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)

local AEDarkCover = AvatarEditorThemeUtil.new()
AEDarkCover.__index = AEDarkCover

function AEDarkCover.new()
	local self = {}
	setmetatable(self, AEDarkCover)

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
				Transparency = 0.7,
			},
			ClassicTheme = {
				Transparency = 0.4,
			},
		},
	}

	return self
end

function AEDarkCover:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEDarkCover