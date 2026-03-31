local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local Text = require(CorePackages.AppTempCommon.Common.Text)
--TODO: replace with UIBlox carousel in the future.
local Carousel = require(Modules.LuaApp.Components.Generic.AppCarousel)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local SEE_ALL_ARROw = "LuaApp/icons/navigation_pushRight"
local TEXT_ICON_PADDING = 10
local HEADER_PADDING = 6

local CarouselWidget = Roact.PureComponent:extend("CarouselWidget")

function CarouselWidget:render()
	local layoutOrder = self.props.layoutOrder
	local onSeeAll = self.props.onSeeAll
	local title = self.props.title
	local items = self.props.items

	--TODO: Clean up these temporary carousel props
	local carouselHeight = self.props.carouselHeight
	local canvasWidth = self.props.canvasWidth
	local onChangeCanvasPosition = self.props.onChangeCanvasPosition
	local onRefCallback = self.props.onRefCallback

	local renderFunction = function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font
		local fontSize = font.BaseSize * font.Header1.RelativeSize
		local textboxBounds = Text.GetTextBounds(title, font.Header1.Font, fontSize, Vector2.new(10000, 10000))
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, HEADER_PADDING),
			}),
			HeaderButton = Roact.createElement("TextButton", {
				Size = UDim2.new(0, textboxBounds.X + TEXT_ICON_PADDING + textboxBounds.Y, 0, textboxBounds.Y),
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				[Roact.Event.Activated] = onSeeAll,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, TEXT_ICON_PADDING),
				}),
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.new(0, textboxBounds.X, 0, textboxBounds.Y),
					BackgroundTransparency = 1,
					Font = font.Header1.Font,
					Text = title,
					TextSize = fontSize,
					TextColor3 = theme.TextEmphasis.Color,
					TextTransparency = theme.TextEmphasis.Transparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
				}),
				SeeAllArrow = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, textboxBounds.Y, 0, textboxBounds.Y),
					BackgroundTransparency = 1,
					Image = SEE_ALL_ARROw,
					ImageColor3 = theme.TextEmphasis.Color,
					ImageTransparency = theme.TextEmphasis.Transparency,
					LayoutOrder = 2,
				}),
			}),
			CarouselFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, carouselHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Carousel = Roact.createElement(Carousel, {
					items = items,
					carouselHeight = carouselHeight,
					canvasWidth = canvasWidth,
					onChangeCanvasPosition = onChangeCanvasPosition,
					onRefCallback = onRefCallback,
				}),
			}),
		})
	end
	return withStyle(renderFunction)
end

return CarouselWidget