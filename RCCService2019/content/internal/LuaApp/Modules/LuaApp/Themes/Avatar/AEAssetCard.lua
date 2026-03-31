local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local Colors = require(Modules.LuaApp.Themes.Colors)
local AvatarEditorThemeUtil = require(Modules.LuaApp.Themes.Avatar.AvatarEditorThemeUtil)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AEAssetCardThemeInfo = AvatarEditorThemeUtil.new()
AEAssetCardThemeInfo.__index = AEAssetCardThemeInfo

function AEAssetCardThemeInfo.new()
	local self = {}
	setmetatable(self, AEAssetCardThemeInfo)

	self.lastOrientation = nil
	self.lastTheme = nil

	self.themes = {
		Orientations = {
			Xbox = {
				ButtonsPerRow = 3,
				LeadingOffset = 0,
				GridPadding = 12,
				ButtonBackground = {
					ImageAvailable = "rbxasset://textures/ui/Shell/AvatarEditor/card/item card-available.png",
					ImageUnavailable = "rbxasset://textures/ui/Shell/AvatarEditor/card/item card-unavailable.png",
					BackgroundTransparency = 1,
				},
				SelectionFrame = {
					Image = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-wearing indicator.png",
					ScaleType = Enum.ScaleType.Stretch,
					SliceCenter = Rect.new(2.5, 2.5, 2.5, 2.5),
					BorderSizePixel = 0,
				},
				Corner = {
					Image = "",
				},
				AssetBorderMask = {
					ImageNotOwned = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-item mask-not owned.png",
					ImageOwned = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-item mask.png",
					ImageEquipped = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-wearing indicator.png",
				},
				getAssetCardY = function(index, assetButtonSize)
					local row = math.floor((index - 1) / 3) + 1
					local rowHeight = assetButtonSize + 12
					return (row - 1) * rowHeight + 11
				end,
				Sound = Roact.createElement("Sound", {
					SoundId = "rbxasset://sounds/ui/Shell/MoveSelection.mp3",
					Volume = 0.35,
				}),
			},
			Portrait = {
				ButtonsPerRow = 4,
				LeadingOffset = 0,
				GridPadding = 6,
				ButtonBackground = {
					BackgroundTransparency = 0,
				},
				SelectionFrame = {
					Image = FFlagAvatarEditorEnableThemes and
						'AE/Graphic/gr-item-selector' or "rbxasset://textures/AvatarEditorImages/gr-selection-border.png",
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2.5, 2.5, 2.5, 2.5),
					BorderSizePixel = 1,
				},
				Corner = {
					Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-item-selector-triangle' or
						"rbxasset://textures/AvatarEditorImages/Landscape/gr-selection-corner-tablet.png",
				},
				AssetBorderMask = {},
				getAssetCardY = function(index, assetButtonSize)
					local row = math.floor((index - 1) / 4) + 1
					local rowHeight = assetButtonSize + 6
					return (row - 1) * rowHeight
				end,
				Sound = nil,
			},
			Landscape = {
				LeadingOffset = 11,
				GridPadding = 12,
				ButtonsPerRow = 4,
				ButtonBackground = {
					BackgroundTransparency = 0,
				},
				SelectionFrame = {
					Image = FFlagAvatarEditorEnableThemes and
						'AE/Graphic/gr-item-selector' or "rbxasset://textures/AvatarEditorImages/gr-selection-border.png",
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2.5, 2.5, 2.5, 2.5),
					BorderSizePixel = 1,
				},
				Corner = {
					Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-item-selector-triangle' or
						"rbxasset://textures/AvatarEditorImages/Portrait/gr-selection-corner-phone.png",
				},
				AssetBorderMask = {},
				getAssetCardY = function(index, assetButtonSize)
					local row = math.floor((index - 1) / 4) + 1
					local rowHeight = assetButtonSize + 12
					return (row - 1) * rowHeight + 11
				end,
				Sound = nil,
			},
		},
		ColorThemes = {
			DarkTheme = {
				BackgroundColor = Colors.Graphite,
				EquippedFrameColor = Colors.White,
			},
			ClassicTheme = {
				BackgroundColor = Colors.White,
				EquippedFrameColor = Colors.Green2,
			},
		},
	}

	return self
end

function AEAssetCardThemeInfo:getThemeInfo(orientation, theme)
	return AvatarEditorThemeUtil.getThemeInfo(self, orientation, theme)
end

return AEAssetCardThemeInfo