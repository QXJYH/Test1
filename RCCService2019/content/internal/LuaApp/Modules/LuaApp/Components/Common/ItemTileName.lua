local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local LoadingSkeleton = require(Modules.LuaApp.Components.LoadingSkeleton)

local ItemTileName = Roact.PureComponent:extend("ItemTileName")

local NAME_LOADING_SKELETON_PADDING = 10
local NAME_LOADING_SKELETON_PANELS = {
	[1] = { Size = UDim2.new(0.8, 0, 0, 16) },
	[2] = { Size = UDim2.new(0.5, 0, 0, 16) },
}

function ItemTileName:init()
	self.createLoadingSkeletonLayout = function()
		return Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, NAME_LOADING_SKELETON_PADDING),
		})
	end
end

function ItemTileName:render()
	local name = self.props.name
	local renderFunction = function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font
		local textSize = font.BaseSize * font.Header2.RelativeSize
		return (name == nil) and Roact.createElement(LoadingSkeleton, {
			Size = UDim2.new(1, 0, 1, 0),
			createLayout = self.createLoadingSkeletonLayout,
			panels = NAME_LOADING_SKELETON_PANELS,
		}) or Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextSize = textSize,
			TextColor3 = theme.TextEmphasis.Color,
			TextTransparency = theme.TextEmphasis.Transparency,
			Font = font.Header2.Font,
			Text = name,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
		})
	end
	return withStyle(renderFunction)
end

return ItemTileName