return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local GameDetailMoreButton = require(Modules.LuaApp.Components.GameDetails.GameDetailMoreButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)

	local universeId = "123456"

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
			ScreenSize = Vector2.new(100, 200),
			CentralOverlay = {
				OverlayType = nil,
			},
			FetchingStatus = {
				[ApiFetchGameDetails.KeyMapper(universeId)] = RetrievalStatus.Done,
			},
		})
		local element = mockServices({
			MoreButton = Roact.createElement(GameDetailMoreButton, {
				LayoutOrder = 1,
				universeId = universeId,
			})
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when data is not ready", function()
		local store = Rodux.Store.new(AppReducer, {
			ScreenSize = Vector2.new(100, 200),
			CentralOverlay = {
				OverlayType = nil,
			},
			FetchingStatus = {
				[ApiFetchGameDetails.KeyMapper(universeId)] = RetrievalStatus.Done,
			},
		})
		local element = mockServices({
			MoreButton = Roact.createElement(GameDetailMoreButton, {
				LayoutOrder = 1,
				universeId = universeId,
			})
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end