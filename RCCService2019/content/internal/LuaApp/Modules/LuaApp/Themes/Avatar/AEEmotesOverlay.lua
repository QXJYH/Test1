local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local AvatarEditorThemeUtil = require(LuaApp.Themes.Avatar.AvatarEditorThemeUtil)

local EmotesOverlayInfo = AvatarEditorThemeUtil.new()
EmotesOverlayInfo.__index = EmotesOverlayInfo

function EmotesOverlayInfo.new()
	local self = {}
	setmetatable(self, EmotesOverlayInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
				OverlayPosition = UDim2.new(1, -475, 0, 60),
				OverlaySize = UDim2.new(0, 200, 0, 200),
            },

			Portrait = {
				OverlayPosition = UDim2.new(0, 10, 0, 20),
				OverlaySize = UDim2.new(1, 0, 0.5, 0),
            },

			Landscape = {
				OverlayPosition = UDim2.new(0, 20, 0, 20),
                OverlaySize = UDim2.new(1, 0, 0.5, 0),
			},
        },

		ColorThemes = {
			DarkTheme = {},

			ClassicTheme = {},

            XboxColorTheme = {},
		},
	}

	return self
end

function EmotesOverlayInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return EmotesOverlayInfo