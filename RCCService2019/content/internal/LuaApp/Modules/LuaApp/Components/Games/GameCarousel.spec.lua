return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)
	local GameSortContents = require(Modules.LuaApp.Models.GameSortContents)
	local GameSort = require(Modules.LuaApp.Models.GameSort)
	local Game = require(Modules.LuaApp.Models.Game)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local GameCarousel = require(Modules.LuaApp.Components.Games.GameCarousel)

	local mockSortName = "Popular"

	local function MockStoreWithGames()
		local gameSortContents = GameSortContents.mock()
		local gameSort = GameSort.mock()
		local gameSortEntry = GameSortEntry.mock()
		local gameModel = Game.mock()
		gameSortContents.entries = { gameSortEntry }

		local store = Rodux.Store.new(AppReducer, {
			GameSorts = { [mockSortName] = gameSort },
			GameSortsContents = { [mockSortName] = gameSortContents },
			Games = { [gameSortEntry.universeId] = gameModel },
			ScreenSize = Vector2.new(100, 200),
			RequestsStatus = {
				GameSortsStatus = {
					[mockSortName] = RetrievalStatus.Done,
				}
			}
		})
		return store
	end

	local function MockStoreWithNoGames(dataStatus)
		local gameSortContents = GameSortContents.new()
		local gameSort = GameSort.mock()

		local store = Rodux.Store.new(AppReducer, {
			GameSorts = { [mockSortName] = gameSort },
			GameSortsContents = { [mockSortName] = gameSortContents },
			RequestsStatus = {
				GameSortsStatus = {
					[mockSortName] = dataStatus or RetrievalStatus.Done,
				}
			}
		})
		return store
	end

	local function MockGameCarousel(store)
		return mockServices({
			GameCarousel = Roact.createElement(GameCarousel, {
				sortName = mockSortName,
				LayoutOrder = 1,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeStyleProvider = true,
		})
	end

	it("should create and destroy without errors when data is complete", function()
		local store = MockStoreWithGames()
		local element = MockGameCarousel(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when data is still fetching", function()
		local store = MockStoreWithNoGames(RetrievalStatus.Fetching)
		local element = MockGameCarousel(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when data fetching has failed", function()
		local store = MockStoreWithNoGames(RetrievalStatus.Failed)
		local element = MockGameCarousel(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end