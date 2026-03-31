local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local TestWithGridView = require(script.Parent.TestWithGridView)

return function()
	it("should render a grid of elements with correct layout properties successfully", function()
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
		}

		TestWithGridView(function(rootPathStr)
			local rootPath = Rhodium.XPath.new(rootPathStr)
			-- GridView should be created successfully
			local gridViewPath = rootPath:cat(Rhodium.XPath.new("GridView"))
			local gridViewRoot = Rhodium.Element.new(gridViewPath)
			expect(gridViewRoot:getRbxInstance()).to.be.ok()

			local gridViewContentsPath = gridViewPath:cat(Rhodium.XPath.new("Content"))
			local gridViewContents = Rhodium.Element.new(gridViewContentsPath)
			expect(gridViewContents:getRbxInstance()).to.be.ok()

			-- UIGridLayout element should be created successfully
			local gridLayoutPath = gridViewContentsPath:cat(Rhodium.XPath.new("*[ClassName = UIGridLayout]"))
			local gridLayout = Rhodium.Element.new(gridLayoutPath)
			expect(gridLayout:getRbxInstance()).to.be.ok()
			expect(gridLayout:getAttribute("CellSize")).to.equal(
				UDim2.new(0, props.itemAbsoluteSize.X, 0, props.itemAbsoluteSize.Y))
			expect(gridLayout:getAttribute("CellPadding")).to.equal(
				UDim2.new(0, props.cellPaddingOffset.X, 0, props.cellPaddingOffset.Y))

			-- The items in the grid should be created successfully
			for index, item in ipairs(props.items) do
				local itemPath = gridViewContentsPath:cat(Rhodium.XPath.new(string.format("*[.Text = %s]", item)))
				local itemElement = Rhodium.Element.new(itemPath)
				expect(itemElement:getRbxInstance()).to.be.ok()
				expect(itemElement:getAttribute("AbsoluteSize")).to.equal(props.itemAbsoluteSize)
				expect(itemElement:getAttribute("LayoutOrder")).to.equal(index)
			end
		end, props)
	end)
end