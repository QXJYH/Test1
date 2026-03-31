return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local SearchResultPlayerRecommendation = require(Modules.LuaApp.Components.Search.SearchResultPlayerRecommendation)

	local mockProperties = {
		keyword = "Golly Greg",
		layoutOrder = 2,
	}

	local function testComponent()
		local mockStore = Rodux.Store.new(AppReducer, {})

		local element = mockServices({
			recommendation = Roact.createElement(SearchResultPlayerRecommendation, mockProperties)
		}, {
			includeStoreProvider = true,
			store = mockStore,
		})

		local instance = Roact.mount(element)
		-- Force the store to update right away
		mockStore:flush()
		Roact.unmount(instance)
	end

	it("should create and destroy without errors", function()
		testComponent()
	end)
end