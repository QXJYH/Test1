return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)
	local Game = require(Modules.LuaApp.Models.Game)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)

	local AppGameTile = require(script.Parent.AppGameTile)

	it("should create and destroy without errors", function()
		local entry = GameSortEntry.mock()
		local gameModel = Game.mock()

		local store = MockStore.new({
			Games = { [entry.universeId] = gameModel },
		})

		local element = mockServices({
			GameTile = Roact.createElement(AppGameTile, {
				entry = entry,
				size = Vector2.new(100, 180),
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeStyleProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when a game is sponsored", function()
		local entry = GameSortEntry.mock()
		entry.isSponsored = true
		local gameModel = Game.mock()

		local store = MockStore.new({
			Games = { [entry.universeId] = gameModel },
		})

		local element = mockServices({
			GameTile = Roact.createElement(AppGameTile, {
				entry = entry,
				size =Vector2.new(100, 180),
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeStyleProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)
end
