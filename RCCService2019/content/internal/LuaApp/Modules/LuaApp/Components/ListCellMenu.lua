local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local ListCell = require(Modules.LuaApp.Components.ListCell)

local DEFAULT_ITEM_HEIGHT = 66
local DEFAULT_VISIBLE_ITEMS = 5.58
local DEFAULT_MAX_HEIGHT = 10000

local BACKGROUND_9S_IMAGE = "LuaApp/buttons/buttonFill"
local BACKGROUND_9S_CENTER = Rect.new(8, 8, 9, 9)

local ListCellMenu = Roact.PureComponent:extend("ListCellMenu")

ListCellMenu.defaultProps = {
	itemHeight = DEFAULT_ITEM_HEIGHT,
	maxHeight = DEFAULT_MAX_HEIGHT,
	visibleItem = DEFAULT_VISIBLE_ITEMS,
}

function ListCellMenu:init()
	self.onCanvasSizeChanged = function(rbx)
		local canvasSizeYOffset = rbx.CanvasSize.Y.Offset
		local maxHeight = self.props.maxHeight
		local formFactor = self.props.formFactor
		local itemHeight = self.props.itemHeight
		local screenHeight = self.props.screenHeight
		local visibleItem = self.props.visibleItem

		if formFactor == FormFactor.COMPACT then
			maxHeight = math.min(maxHeight, visibleItem * itemHeight)
		else
			maxHeight = math.min(maxHeight, screenHeight * 0.5)
		end

		if canvasSizeYOffset <= maxHeight then
			rbx.ScrollingEnabled = false
		else
			rbx.ScrollingEnabled = true
			canvasSizeYOffset = maxHeight
		end

		rbx.Size = UDim2.new(0, self.props.width, 0, canvasSizeYOffset)
	end
end

function ListCellMenu:render()
	local itemList = self.props.items
	local layoutOrder = self.props.layoutOrder
	local size = UDim2.new(0, self.props.width, 0, 0)
	local menuTheme = self._context.AppTheme.ContextualMenu

	-- Build a table of items that the user is able to pick from:
	local listContents = {}
	listContents["Layout"] = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local rowCount = 0
	for position, item in ipairs(itemList) do
		rowCount = rowCount + 1
		listContents["Item_" .. position] = Roact.createElement(ListCell, {
			item = item,
			layoutOrder = rowCount,
		})
		if position < #itemList then
			rowCount = rowCount + 1
			listContents["Divider_" .. position] = Roact.createElement("Frame", {
				BackgroundColor3 = menuTheme.Divider.Color,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				LayoutOrder = rowCount,
				Size = UDim2.new(1, 0, 0, 1),
			})
		end
	end

	return Roact.createElement(FitChildren.FitImageLabel, {
		Position = UDim2.new(0.5, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = BACKGROUND_9S_IMAGE,
		ImageColor3 = menuTheme.Background.Color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = BACKGROUND_9S_CENTER,
		fitAxis = FitChildren.FitAxis.Both,
		LayoutOrder = layoutOrder,
	}, {
		ScrollingFrame = Roact.createElement(FitChildren.FitScrollingFrame, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			Size = size,
			fitFields = {
				CanvasSize = FitChildren.FitAxis.Height,
			},
			[Roact.Change.CanvasSize] = self.onCanvasSizeChanged,
		}, listContents),
	})
end

ListCellMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenWidth = state.ScreenSize.X,
			screenHeight = state.ScreenSize.Y,
		}
	end
)(ListCellMenu)

return ListCellMenu
