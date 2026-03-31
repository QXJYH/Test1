local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local Colors = require(Modules.LuaApp.Themes.Colors)

local AEHatSlot = AvatarEditorThemeUtil.new()
AEHatSlot.__index = AEHatSlot

function AEHatSlot.new()
	local self = {}
	setmetatable(self, AEHatSlot)

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
				PlaceHolderImageColor = Colors.Slate,
				Background = Colors.Graphite,
				Outline = Colors.Graphite,
			},
			ClassicTheme = {
				PlaceHolderImageColor = Colors.Gray3,
				Background = Colors.White,
				Outline = Colors.Gray3,
			},
		},
	}

	return self
end

function AEHatSlot:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEHatSlot