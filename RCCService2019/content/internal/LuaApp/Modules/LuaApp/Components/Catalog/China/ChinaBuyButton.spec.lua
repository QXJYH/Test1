return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local ChinaBuyButton = require(Modules.LuaApp.Components.Catalog.China.ChinaBuyButton)

	local dummyItemId = "123"
	local missingItemId = "987"
	local function CustomReducer(state, action)
		state = state or {}

		local dataStore = {
			LocalUserId = "42",
			CatalogAppReducer = {
				Bundles = {
				},
				BundlesStatus = {
				},
			},
			UserRobux = {
			},
			FetchingStatus = {
			},
		}

		dataStore.CatalogAppReducer.Bundles[dummyItemId] = {}
		assert(dataStore.CatalogAppReducer.Bundles[missingItemId] == nil)

		return dataStore
	end

	it("should create and destroy without errors with an empty bundle", function()
		local store = Rodux.Store.new(CustomReducer, {})
		local element = mockServices({
			ChinaBuyButton = Roact.createElement(ChinaBuyButton, {
				itemId = dummyItemId,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors with no bundle", function()
		local store = Rodux.Store.new(CustomReducer, {})
		local element = mockServices({
			ChinaBuyButton = Roact.createElement(ChinaBuyButton, {
				itemId = missingItemId,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end