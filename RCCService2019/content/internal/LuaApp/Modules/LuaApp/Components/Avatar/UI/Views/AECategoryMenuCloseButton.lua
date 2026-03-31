local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESetCategoryMenuOpen = require(Modules.LuaApp.Actions.AEActions.AESetCategoryMenuOpen)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local AECategoryMenuCloseButton = Roact.PureComponent:extend("AECategoryMenuCloseButton")
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

function AECategoryMenuCloseButton:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AECategoryMenuAndButtons:getThemeInfo(nil, themeName) or nil
	local setCategoryMenuClosed = self.props.setCategoryMenuClosed
	local image = AESpriteSheet.getImage("ic-close")

	if FFlagAvatarEditorEnableThemes then
		image.imageRectSize = nil
		image.imageRectOffset = nil
	end

	return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 45),
			Size = UDim2.new(0, 90, 0, 90),

			[Roact.Event.Activated] = function(rbx)
				setCategoryMenuClosed()
			end
		} , {
			ImageInfo = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 45, 0, 45),
				Size = UDim2.new(0, 28, 0, 28),
				Image = FFlagAvatarEditorEnableThemes and 'AE/Icons/ic-close' or image.image,
				ImageColor3 = FFlagAvatarEditorEnableThemes
					and themeInfo.ColorTheme.CloseButton.Color or Color3.fromRGB(255, 255, 255),
				ImageRectSize = image.imageRectSize,
				ImageRectOffset = image.imageRectOffset,
			})
		})
end

return RoactRodux.UNSTABLE_connect2(
	function() return {} end,
	function(dispatch)
		return {
			setCategoryMenuClosed = function()
				dispatch(AESetCategoryMenuOpen(AEConstants.CategoryMenuOpen.CLOSED))
			end,
		}
	end
)(AECategoryMenuCloseButton)