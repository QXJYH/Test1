return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local ChinaBundleModal = require(Modules.LuaApp.Components.Catalog.China.ChinaBundleModal)

	local dummyItemId = "123"
	local function CustomReducer(state, action)
		state = state or {}

		local dataStore = {
			TopBar = {
				topBarHeight = 0,
				statusBarHeight = 0,
			},
			ScreenSize = Vector2.new(0,0),
			GlobalGuiInset = {
				left = 0,
				right = 0,
				top = 0,
				bottom = 0,
			},
			CatalogAppReducer = {
				Bundles = {
				}
			},
			FetchingStatus = {
			},
			Navigation = {
				history = {
				}
			},
			UserRobux = {
			},
		}

		dataStore.CatalogAppReducer.Bundles[dummyItemId] = {}

		return dataStore
	end

	it("should create and destroy without errors with empty store", function()
		local store = Rodux.Store.new(CustomReducer, {})
		local element = mockServices({
			ChinaBundleModal = Roact.createElement(ChinaBundleModal, {
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
end