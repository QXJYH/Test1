local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)

local FitChildren = require(Modules.LuaApp.FitChildren)

local ItemListLayout = Roact.PureComponent:extend("ItemListLayout")

local SizeForFitAxis = {
	[FitChildren.FitAxis.Height] = UDim2.new(1, 0, 0, 0),
	[FitChildren.FitAxis.Width] = UDim2.new(0, 0, 1, 0),
	[FitChildren.FitAxis.Both] = UDim2.new(0, 0, 0, 0),
}

local function WrappedItem(props)
	local layoutOrder = props.layoutOrder
	local fitAxis = props.fitAxis
	local size = props.size
	local renderItem = props.renderItem

	return Roact.createElement(FitChildren.FitFrame, {
		Size = size,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		fitAxis = fitAxis,
	}, {
		RenderedItem = renderItem,
	})
end

function ItemListLayout:render()
	local renderItemList = self.props.renderItemList or {}
	local fitAxis = self.props.fitAxis
	local size = self.props.size or SizeForFitAxis[fitAxis]

	local listLayoutProps = Cryo.Dictionary.join(self.props, {
		renderItemList = Cryo.None,
		fitAxis = Cryo.None,
		size = Cryo.None,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local listContents = {
		ListLayout = Roact.createElement("UIListLayout", listLayoutProps)
	}

	for index, renderItem in ipairs(renderItemList) do
		listContents["Item" .. index] = WrappedItem({
			layoutOrder = index,
			fitAxis = fitAxis,
			size = size,
			renderItem = renderItem,
		})
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		fitAxis = fitAxis,
	}, listContents)
end

return ItemListLayout