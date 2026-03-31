-- This is a temporary carousel for the app until the UIBlox one is ready for use.
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local AppCarousel = Roact.PureComponent:extend("AppCarousel")

local Constants = require(Modules.LuaApp.Constants)
local CAROUSEL_MARGIN = Constants.GAME_CAROUSEL_PADDING

function AppCarousel:render()
	local carouselHeight  = self.props.carouselHeight
	local canvasWidth = self.props.canvasWidth
	local items = self.props.items
	local onChangeCanvasPosition = self.props.onChangeCanvasPosition
	local onRefCallback = self.props.onRefCallback

	return Roact.createElement("ScrollingFrame", {
		LayoutOrder = 2,
		Size = UDim2.new(1, CAROUSEL_MARGIN, 0, carouselHeight),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		CanvasSize = UDim2.new(0, canvasWidth, 0, carouselHeight),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		[Roact.Change.CanvasPosition] = onChangeCanvasPosition,
		[Roact.Ref] = onRefCallback,
	}, items)
end

return AppCarousel