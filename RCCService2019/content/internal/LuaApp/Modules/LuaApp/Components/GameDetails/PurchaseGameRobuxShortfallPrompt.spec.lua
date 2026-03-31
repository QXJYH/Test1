return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local LightTheme = require(Modules.LuaApp.Themes.DeprecatedLightTheme)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local PurchaseGameRobuxShortfallPrompt = require(Modules.LuaApp.Components.GameDetails.PurchaseGameRobuxShortfallPrompt)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppPage = require(Modules.LuaApp.AppPage)

	local universeId = "123"
	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
			Navigation = {
				history = { { { name = AppPage.GameDetail } } },
			}
		})

		local element = mockServices({
			PurchaseGameRobuxShortfallPrompt = Roact.createElement(PurchaseGameRobuxShortfallPrompt, {
				universeId = universeId,
				robuxShortfall = 20,
				theme = LightTheme,
				containerWidth = 100,
			})
		}, {
			includeLocalizationProvider = true,
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end