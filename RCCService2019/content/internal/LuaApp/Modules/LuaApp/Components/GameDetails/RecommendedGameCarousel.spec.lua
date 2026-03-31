return function()
	local RecommendedGameCarousel = require(script.Parent.RecommendedGameCarousel)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local Game = require(Modules.LuaApp.Models.Game)
	local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local universeId = "123"

	local function testRecommendedGameCarousel(recommendedGamesFetchingStatus, recommendedGameEntries, games)
		local store = Rodux.Store.new(AppReducer, {
			FetchingStatus = {
				["RecommendedGames"..universeId] = recommendedGamesFetchingStatus,
			},
			RecommendedGameEntries = {
				[universeId] = recommendedGameEntries,
			},
			Games = games,
		})

		local element = mockServices({
			RecommendedGameCarousel = Roact.createElement(RecommendedGameCarousel, {
				universeId = universeId,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors when fetch events not started", function()
		testRecommendedGameCarousel(RetrievalStatus.NotStarted, {})
	end)

	it("should create and destroy without errors when fetch events loading", function()
		testRecommendedGameCarousel(RetrievalStatus.Fetching, {})
	end)

	it("should create and destroy without errors when fetch events succeeds", function()
		testRecommendedGameCarousel(RetrievalStatus.Done, {})
	end)

	it("should create and destroy without errors when fetch events succeeds with returned data", function()
		local entry = GameSortEntry.mock("testId1")
		local games = {
			[entry.universeId] = Game.mock()
		}
		testRecommendedGameCarousel(RetrievalStatus.Done, { entry }, games)
	end)

	it("should create and destroy without errors when fetch events fails", function()
		testRecommendedGameCarousel(RetrievalStatus.Failed, {})
	end)
end