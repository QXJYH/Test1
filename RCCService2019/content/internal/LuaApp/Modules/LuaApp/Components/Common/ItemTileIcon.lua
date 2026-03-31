local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)

local ItemTileIcon = Roact.PureComponent:extend("ItemTileIcon")

function ItemTileIcon:render()
	local image = self.props.Image
	local renderFunction = function(stylePalette)
		local style = stylePalette
		local theme = style.Theme
		return Roact.createElement(LoadableImage, {
			Size = UDim2.new(1, 0, 1, 0),
			Image = image,
			BackgroundColor3 = theme.PlaceHolder.Color,
			BackgroundTransparency = theme.PlaceHolder.Transparency,
			BorderSizePixel = 0,
			useShimmerAnimationWhileLoading = true,
		})
	end
	return withStyle(renderFunction)
end

return ItemTileIcon
