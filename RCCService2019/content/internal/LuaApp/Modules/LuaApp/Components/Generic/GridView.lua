local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)

local GridView = Roact.PureComponent:extend("GridView")

GridView.defaultProps = {
	items = {},
	cellPaddingOffset = Vector2.new(0, 0),
	windowAbsoluteSize = Vector2.new(1, 1),
	itemAbsoluteSize = Vector2.new(1, 1),
}

function GridView:init()
	self.state = {
		itemsPerRow = 0,
		itemWindowStart = 1,
	}

	self.containerRef = Roact.createRef()

	-- Keeping track of mount state to prevent "setState during Reconciliation" error.
	self.isMounted = false

	self.updateItemWindowBounds = function()
		if not self.containerRef.current then
			return
		end

		local windowAbsoluteSize = self.props.windowAbsoluteSize
		local cellPaddingOffset = self.props.cellPaddingOffset

		-- MOBLUAPP-1220: windowOffset is based on the top of the screen, not at the
		-- top of its parent scrolling frame position. Separate ticked filed to make
		-- this consider grid on a scrolling frame of different size and position.
		local windowOffSet = -self.containerRef.current.AbsolutePosition.Y
		local itemAbsoluteSize = self.props.itemAbsoluteSize

		local newItemsPerRow = math.floor(
			(windowAbsoluteSize.X + cellPaddingOffset.X) / (itemAbsoluteSize.X + cellPaddingOffset.X))

		local topInvisibleRows = math.max(0, math.floor(windowOffSet / (itemAbsoluteSize.Y + cellPaddingOffset.Y)))
		local newItemWindowStart = math.max(1, topInvisibleRows * newItemsPerRow + 1)

		local shouldUpdate = newItemsPerRow ~= self.state.itemsPerRow
			or newItemWindowStart ~= self.state.itemWindowStart

		if shouldUpdate then
			-- MOBLUAPP-1221: QuantumGui bug when using AbsolutePosition to trigger windowing,
			-- elements do not get updated correctly because the windowing is
			-- happening during a UILayout. This can be temporarly fixed by
			-- delaying the windowing for 1 frame.
			delay(0, function()
				if self.isMounted then
					self:setState({
						itemsPerRow = newItemsPerRow,
						itemWindowStart = newItemWindowStart,
					})
				end
			end)
		end
	end
end

function GridView:render()
	local layoutOrder = self.props.layoutOrder
	local items = self.props.items
	local renderItem = self.props.renderItem
	local windowAbsoluteSize = self.props.windowAbsoluteSize
	local cellPaddingOffset = self.props.cellPaddingOffset
	local numberOfRowsToShow = self.props.numberOfRowsToShow
	local itemAbsoluteSize = self.props.itemAbsoluteSize

	local itemsPerRow = self.state.itemsPerRow
	local itemWindowStart = self.state.itemWindowStart

	local numberOfItems = #items

	local totalRows = 0
	if itemsPerRow > 0 then
		totalRows = math.ceil(numberOfItems / itemsPerRow)
	end

	if numberOfRowsToShow ~= nil then
		totalRows = math.min(totalRows, numberOfRowsToShow)
	end

	local totalHeight = math.max(0, itemAbsoluteSize.Y * totalRows + cellPaddingOffset.Y * (totalRows - 1))

	local itemsInWindow = (math.ceil(windowAbsoluteSize.Y / (itemAbsoluteSize.Y + cellPaddingOffset.Y)) + 1) * itemsPerRow
	local itemWindowEnd = math.min(numberOfItems, totalRows * itemsPerRow, itemWindowStart + itemsInWindow - 1)
	local topPadding = (itemWindowStart - 1) / itemsPerRow * (itemAbsoluteSize.Y + cellPaddingOffset.Y)

	local gridContents = nil
	if typeof(renderItem) == "function" then
		gridContents = {
			Layout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.new(0, cellPaddingOffset.X, 0, cellPaddingOffset.Y),
				CellSize = UDim2.new(0, itemAbsoluteSize.X, 0, itemAbsoluteSize.Y),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}

		for index = itemWindowStart, itemWindowEnd do
			local item = items[index]
			local key = index % itemsInWindow

			gridContents[key] = renderItem(item, itemAbsoluteSize, index)
		end
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, totalHeight),
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		[Roact.Ref] = self.containerRef,
		[Roact.Change.AbsolutePosition] = self.updateItemWindowBounds,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, topPadding),
		}),
		Content = gridContents and Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, gridContents),
	})
end

function GridView:didMount()
	self.isMounted = true
	self.updateItemWindowBounds()
end

function GridView:willUnmount()
	self.isMounted = false
end

function GridView:didUpdate(prevProps)
	if self.props.windowAbsoluteSize ~= prevProps.windowAbsoluteSize or
		self.props.itemAbsoluteSize ~= prevProps.itemAbsoluteSize or
		self.props.cellPaddingOffset ~= prevProps.cellPaddingOffset then
		self.updateItemWindowBounds()
	end
end

return GridView