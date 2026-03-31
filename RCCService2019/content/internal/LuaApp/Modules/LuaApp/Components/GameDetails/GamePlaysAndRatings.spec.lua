return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GamePlaysAndRatings = require(Modules.LuaApp.Components.GameDetails.GamePlaysAndRatings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local universeId = "123"

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
		})

		local element = mockServices({
			GamePlaysAndRatings = Roact.createElement(GamePlaysAndRatings, {
				universeId = universeId,
				containerWidth = 400,
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