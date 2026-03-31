return function()
	local MoreTable = require(script.Parent.MoreTable)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local AppPage = require(Modules.LuaApp.AppPage)
	local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function createTestItemTable()
		local testItemTable = MorePageSettings.GetItemsInPage(AppPage.More)
		testItemTable[#testItemTable + 1] = MorePageSettings.GetItemsInPage(AppPage.About)
		testItemTable[#testItemTable + 1] = MorePageSettings.GetItemsInPage(AppPage.Settings)
		return testItemTable
	end

	it("should create and destroy without errors when itemTable is empty", function()
		local root = mockServices({
			element = Roact.createElement(MoreTable, {
				itemTable = nil,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when itemTable is an empty table", function()
		local root = mockServices({
			element = Roact.createElement(MoreTable, {
				itemTable = {},
				renderItem = function() end,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when itemTable is not empty", function()
		local root = mockServices({
			element = Roact.createElement(MoreTable, {
				itemTable = createTestItemTable(),
				renderItem = function() end,
				rowHeight = 42,
			}),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)
end