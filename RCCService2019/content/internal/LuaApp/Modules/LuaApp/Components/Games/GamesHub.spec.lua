return function()
	local GamesHub = require(script.Parent.GamesHub)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local SetGamesPageDataStatus = require(Modules.LuaApp.Actions.SetGamesPageDataStatus)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function MockStore(dataStatus)
		local store = Rodux.Store.new(AppReducer, {
			TopBar = {
				topBarHeight = 60,
				statusBarHeight = 20,
			}
		})
		store:dispatch(SetGamesPageDataStatus(dataStatus or RetrievalStatus.Done))
		return store
	end

	local function MockGamesPage(store)
		return mockServices({
			GamesHub = Roact.createElement(GamesHub),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
			includeStyleProvider = true,
		})
	end

	it("should create and destroy without errors", function()
		local store = MockStore()
		local element = MockGamesPage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when data is loading", function()
		local store = MockStore(RetrievalStatus.Fetching)
		local element = MockGamesPage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when there's no data", function()
		local store = MockStore(RetrievalStatus.Failed)
		local element = MockGamesPage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end
