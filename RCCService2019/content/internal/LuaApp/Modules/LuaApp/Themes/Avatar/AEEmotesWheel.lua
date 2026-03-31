local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local AvatarEditorThemeUtil = require(LuaApp.Themes.Avatar.AvatarEditorThemeUtil)

local EmotesWheelThemeInfo = AvatarEditorThemeUtil.new()
EmotesWheelThemeInfo.__index = EmotesWheelThemeInfo

function EmotesWheelThemeInfo.new()
	local self = {}
	setmetatable(self, EmotesWheelThemeInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
                SlotNumberTextSize = 24,
                SlotNumberFont = Enum.Font.Gotham,

                HighlightImage = "rbxasset://textures/ui/Emotes/Editor/TenFoot/OrangeHighlight.png",
                HighlightImageSize = Vector2.new(57, 77),

                CircleImage = "rbxasset://textures/ui/Emotes/Editor/TenFoot/Wheel.png",

                EmotesWheelMinSize = Vector2.new(200, 200),
                EmotesWheelMaxSize = Vector2.new(200, 200),
            },

			Portrait = {
                SlotNumberTextSize = 14,
                SlotNumberFont = Enum.Font.Gotham,

                HighlightImage = "rbxasset://textures/ui/Emotes/Editor/Small/OrangeHighlight.png",
                HighlightImageSize = Vector2.new(33, 45),

                CircleImage = "rbxasset://textures/ui/Emotes/Editor/Small/Wheel.png",

                EmotesWheelMinSize = Vector2.new(116, 116),
                EmotesWheelMaxSize = Vector2.new(116, 116),
            },

			Landscape = {
                SlotNumberTextSize = 18,
                SlotNumberFont = Enum.Font.Gotham,

                HighlightImage = "rbxasset://textures/ui/Emotes/Editor/Large/OrangeHighlight.png",
                HighlightImageSize = Vector2.new(43, 58),

                CircleImage = "rbxasset://textures/ui/Emotes/Editor/Large/Wheel.png",

                EmotesWheelMinSize = Vector2.new(100, 100),
                EmotesWheelMaxSize = Vector2.new(150, 150),
			},
        },

		ColorThemes = {
			DarkTheme = {},

			ClassicTheme = {},
		},
	}

	return self
end

function EmotesWheelThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return EmotesWheelThemeInfo