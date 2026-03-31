return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)

	local GridView = require(Modules.LuaApp.Components.Generic.GridView)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local largeListOfItems = {
		"[",
		"s",
		"u",
		"b",
		"d",
		"e",
		"r",
		"m",
		"a",
		"t",
		"o",
		"g",
		"l",
		"y",
		"p",
		"h",
		"i",
		"c",
		"]",
	}

	local smallListOfItems = {
		"a",
		"b",
	}

	local numberOfRendersOfItemRenderer = 0
	local concatOfRenderedItemTexts = ""

	local function itemRenderer(item, absoluteSize, index)
		numberOfRendersOfItemRenderer = numberOfRendersOfItemRenderer + 1
		concatOfRenderedItemTexts = concatOfRenderedItemTexts .. item

		return Roact.createElement("TextLabel", {
			LayoutOrder = index,
			Text = item,
			Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y),
		})
	end

	local function getNumberOfItemsRendered(container)
		local numberOfItemsRendered = 0
		local contents = container.Test:FindFirstChild("Content", true)
		local contentsChildren = contents:GetChildren()
		for _, entry in pairs(contentsChildren) do
			if entry:IsA("GuiObject") then
				numberOfItemsRendered = numberOfItemsRendered + 1
			end
		end
		return numberOfItemsRendered
	end

	it("should create and destroy without errors", function()
		local element = mockServices({
			GridView = Roact.createElement(GridView, {
				LayoutOrder = 1,
				items = largeListOfItems,
				renderItem = function(...) return itemRenderer(...) end,
				windowAbsoluteSize = Vector2.new(100, 100),
				itemAbsoluteSize = Vector2.new(30, 30),
				cellPaddingOffset = Vector2.new(3, 3),
				numberOfRowsToShow = 5,
			}),
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props are passed down", function()
		local element = mockServices({
			GridView = Roact.createElement(GridView),
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render only the number of rows specified", function()
		local element = mockServices({
			GridView = Roact.createElement(GridView, {
				LayoutOrder = 1,
				items = largeListOfItems,
				renderItem = function(...) return itemRenderer(...) end,
				windowAbsoluteSize = Vector2.new(100, 100),
				itemAbsoluteSize = Vector2.new(30, 30),
				cellPaddingOffset = Vector2.new(3, 3),
				numberOfRowsToShow = 2,
			}),
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		delay(1, function()
			expect(getNumberOfItemsRendered(container)).to.equal(6)

			Roact.unmount(instance)
		end)

	end)

	it("should render all available items but no more when numberOfRowsToShow exceeds total number of rows", function()
		local element = mockServices({
			GridView = Roact.createElement(GridView, {
				LayoutOrder = 1,
				items = smallListOfItems,
				renderItem = function(...) return itemRenderer(...) end,
				windowAbsoluteSize = Vector2.new(100, 100),
				itemAbsoluteSize = Vector2.new(30, 30),
				cellPaddingOffset = Vector2.new(3, 3),
				numberOfRowsToShow = 2,
			}),
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		delay(1, function()
			expect(getNumberOfItemsRendered(container)).to.equal(#smallListOfItems)

			Roact.unmount(instance)
		end)
	end)

end