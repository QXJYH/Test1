return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GameRatings = require(Modules.LuaApp.Components.GameDetails.GameRatings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local universeId = "123"
	local function testGameRatings(store)
		local element = mockServices({
			GameRatings = Roact.createElement(GameRatings, {
				universeId = universeId,
				width = 200,
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

	it("should create and destroy without errors when votes are present", function()
		testGameRatings(Rodux.Store.new(AppReducer, {
			GameVotes = {
				[universeId] = { upVotes = 90, downVotes = 10 },
			},
			UserGameVotes = {
				[universeId] = { canVote = true, userVote = nil, reasonForNotVoteable = "" },
			},
			GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
		}))
	end)

	it("should create and destroy without errors when votes are nil", function()
		testGameRatings(Rodux.Store.new(AppReducer, {
			GameVotes = {
				[universeId] = {},
			},
			UserGameVotes = {
				[universeId] = {},
			},
			GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
		}))
	end)
end
