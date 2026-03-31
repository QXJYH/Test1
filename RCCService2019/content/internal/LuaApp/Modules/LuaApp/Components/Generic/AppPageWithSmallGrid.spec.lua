return function()
	local AppPageWithSmallGrid = require(script.Parent.AppPageWithSmallGrid)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testAppPage(items, screenSize)
		local store = Rodux.Store.new(AppReducer, {
			ScreenSize = screenSize,
		})

		local element = mockServices({
			Item = Roact.createElement(AppPageWithSmallGrid, {
				items = items,
				noItemText = "CommonUI.Features.Label.Home",
				getHeight = function()
					return 10
				end,
				renderItem = function() end,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors when items is empty", function()
		testAppPage({}, Vector2.new(100, 100))
	end)

	it("should create and destroy without errors when items is not empty", function()
		testAppPage({ "1", "2" }, Vector2.new(100, 100))
	end)

	it("should create and destroy without errors when screenSize is not set", function()
		testAppPage({ "1", "2" }, nil)
	end)
end
