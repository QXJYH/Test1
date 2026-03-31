return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
    local AppReducer = require(Modules.LuaApp.AppReducer)
    local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GameInfoList = require(Modules.LuaApp.Components.GameDetails.GameInfoList)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

    local universeId = "10086"

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			GameDetails = { [universeId] = GameDetail.mock(universeId, "mock game") },
		})
		local element = mockServices({
			GameInfoList = Roact.createElement(GameInfoList, {
                universeId = universeId,
                LayoutOrder = 1,
				leftPadding = 20,
				rightPadding = 0,
			}),
		}, {
			store = store,
			includeStoreProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end