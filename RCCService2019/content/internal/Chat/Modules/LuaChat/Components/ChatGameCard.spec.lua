return function()
	local LocalizationService = game:GetService("LocalizationService")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Localization = require(Modules.LuaApp.Localization)
	local MockId = require(Modules.LuaApp.MockId)
	local Roact = require(Modules.Common.Roact)
	local RoactRodux = require(Modules.Common.RoactRodux)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)

	local ChatGameCard = require(Modules.LuaChat.Components.ChatGameCard)

	local localization = Localization.new(LocalizationService.RobloxLocaleId)

	it("should create and destroy without errors", function()

		local store = MockStore.new()

		local renderWidth = 500
		local game = {
			placeId = MockId(),
			friends = { { uid = MockId() }, { uid = MockId() },
				{ uid = MockId() }, { uid = MockId() }, { uid = MockId() } },
		}

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			GameCard = Roact.createElement(ChatGameCard, {
				game = game,
				isPinnedGame = true,
				Localization = localization,
				renderWidth = renderWidth,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
