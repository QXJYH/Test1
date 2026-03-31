local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local TestWithGridView = require(script.Parent.TestWithGridView)

return function()
	it("if numberOfRowsToShow is set, should only render the specified number of rows", function()
		local props = {
			items = {"a", "b", "c", "d"},
			renderItem = function(item, itemAbsoluteSize, index)
				return Roact.createElement("TextLabel", {
					LayoutOrder = index,
					Text = item,
					Size = UDim2.new(0, itemAbsoluteSize.X, 0, itemAbsoluteSize.Y),
				})
			end,
			itemAbsoluteSize = Vector2.new(100, 100),
			cellPaddingOffset = Vector2.new(10, 10),
			windowAbsoluteSize = Vector2.new(320, 150),
			numberOfRowsToShow = 1,
		}

		TestWithGridView(function(rootPathStr)
			local rootPath = Rhodium.XPath.new(rootPathStr)
			local gridViewPath = rootPath:cat(Rhodium.XPath.new("GridView"))
			local gridViewContentsPath = gridViewPath:cat(Rhodium.XPath.new("Content"))
			local expectedItemsShown = 3

			-- These items should be succesfully rendered
			for index = 1, expectedItemsShown do
				local itemText = props.items[index]
				local itemPath = gridViewContentsPath:cat(Rhodium.XPath.new(string.format("*[.Text = %s]", itemText)))
				local itemElement = Rhodium.Element.new(itemPath)
				expect(itemElement:getRbxInstance()).to.be.ok()
				expect(itemElement:getAttribute("AbsoluteSize")).to.equal(props.itemAbsoluteSize)
				expect(itemElement:getAttribute("LayoutOrder")).to.equal(index)
			end

			local gridViewContents = Rhodium.Element.new(gridViewContentsPath)
			local children = gridViewContents:getRbxInstance():GetChildren()
			-- There should exactly be expectedItemsShown + 1 number of items.
			-- (+1 is for UIGridLayout)
			expect(#children).to.equal(expectedItemsShown + 1)
		end, props)
	end)
end