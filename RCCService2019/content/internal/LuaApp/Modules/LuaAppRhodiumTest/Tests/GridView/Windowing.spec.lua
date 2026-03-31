local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")

local Roact = require(CorePackages.Roact)

local TestWithGridView = require(script.Parent.TestWithGridView)

local ITEM_SIZE = Vector2.new(100, 100)
local ITEM_PADDING = Vector2.new(10, 10)
local WINDOW_SIZE = Vector2.new(320, 150)
local EXPECTED_ITEMS_PER_ROW = 3
local EXPECTED_MINIMUM_ROWS_TO_BE_SEEN = 2
local EXPECTED_MINIMUM_ITEMS_TO_BE_SEEN = EXPECTED_ITEMS_PER_ROW * EXPECTED_MINIMUM_ROWS_TO_BE_SEEN

local largeListOfItems = {}
for i = 1, 26 do
	table.insert(largeListOfItems, tostring(i))
end

return function()
	it("should always render items that should be visible", function()
		local props = {
			items = largeListOfItems,
			renderItem = function(item, itemAbsoluteSize, index)
				return Roact.createElement("TextLabel", {
					LayoutOrder = index,
					Text = item,
					Size = UDim2.new(0, itemAbsoluteSize.X, 0, itemAbsoluteSize.Y),
				})
			end,
			itemAbsoluteSize = ITEM_SIZE,
			cellPaddingOffset = ITEM_PADDING,
			windowAbsoluteSize = WINDOW_SIZE,
		}

		TestWithGridView(function(rootPathStr)
			local rootPath = Rhodium.XPath.new(rootPathStr)
			local gridViewPath = rootPath:cat(Rhodium.XPath.new("GridView"))
			local gridViewContentsPath = gridViewPath:cat(Rhodium.XPath.new("Content"))

			local function checkGridItem(index)
				local itemText = largeListOfItems[index]
				local itemPath = gridViewContentsPath:cat(Rhodium.XPath.new(string.format("*[.Text = %s]", itemText)))
				local itemElement = Rhodium.Element.new(itemPath)
				expect(itemElement:getRbxInstance()).to.be.ok()
				return itemElement
			end

			-- When the Grid is first created, we should see the first few items in the list.
			for i = 1, EXPECTED_MINIMUM_ITEMS_TO_BE_SEEN do
				local itemElement = checkGridItem(i)
				expect(itemElement:getAttribute("LayoutOrder")).to.equal(i)
			end

			-- Now scroll down enough to trigger the windowing logic
			local scrollingFrame = Rhodium.Element.new(rootPath)
			expect(scrollingFrame:getRbxInstance()).to.be.ok()

			local itemHeightWithPadding = ITEM_SIZE.Y + ITEM_PADDING.Y
			local scrollAmount = itemHeightWithPadding + 10
			local canvasPosition
			for _ = 1, 10 do
				if UserInputService.MouseEnabled then
					Rhodium.VirtualInput.mouseWheel(scrollingFrame:getCenter(), 2)
				elseif UserInputService.TouchEnabled then
					Rhodium.VirtualInput.swipe(scrollingFrame:getCenter(),
						scrollingFrame:getCenter() + Vector2.new(0, -scrollAmount), 0.25, false)
				end
				wait(0.1)

				canvasPosition = scrollingFrame:getAttribute("CanvasPosition").Y
				if canvasPosition >= scrollAmount then
					break
				end
			end

			expect(canvasPosition > 0).to.equal(true)

			if canvasPosition >= scrollAmount then
				local canvasPosition = scrollingFrame:getAttribute("CanvasPosition").Y
				local expectedRowStart = math.floor(canvasPosition / itemHeightWithPadding)
				local expectedItemStart = expectedRowStart * EXPECTED_ITEMS_PER_ROW + 1
				local expectedItemEnd = math.min(#largeListOfItems, expectedItemStart + EXPECTED_MINIMUM_ITEMS_TO_BE_SEEN)

				-- There might be more items than just these ones being rendered
				-- so the layoutOrder might not start from 1. We just need to make sure
				-- they're in order.
				local lastLayoutOrder = 0
				for i = expectedItemStart, expectedItemEnd do
					local itemElement = checkGridItem(i)
					local layoutOrder = itemElement:getAttribute("LayoutOrder")

					expect(layoutOrder > lastLayoutOrder).to.equal(true)
					lastLayoutOrder = layoutOrder
				end
			end
		end, props)
	end)
end