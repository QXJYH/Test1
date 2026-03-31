return function()
	local MoreList = require(script.Parent.MoreList)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function createTestItemList()
		local itemList = {}
		local index = 1
		for _, itemInfo in pairs(MorePageSettings.ItemInfo) do
			itemList[index] = itemInfo
			index = index + 1
		end
		return itemList
	end

	it("should create and destroy without errors when itemList is empty", function()
		local root = mockServices({
			element = Roact.createElement(MoreList, {
				itemList = nil,
				renderItem = function() end,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when itemList is an empty list", function()
		local root = mockServices({
			element = Roact.createElement(MoreList, {
				itemList = {},
				renderItem = function() end,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when itemList is not empty", function()
		local root = mockServices({
			element = Roact.createElement(MoreList, {
				itemList = createTestItemList(),
				renderItem = function() end,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)
end