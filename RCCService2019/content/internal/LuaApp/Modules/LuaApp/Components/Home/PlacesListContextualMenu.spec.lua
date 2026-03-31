return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local PlacesListContextualMenu = require(Modules.LuaApp.Components.Home.PlacesListContextualMenu)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local Game = require(Modules.LuaApp.Models.Game)

	local mockTabletStore = {
		TabBarVisible = true,
		TopBar = {
			topBarHeight = 20,
		},
		FormFactor = FormFactor.WIDE,
		ScreenSize = Vector2.new(300, 200),
	}

	local mockCompactViewStore = {
		TabBarVisible = true,
		TopBar = {
			topBarHeight = 20,
		},
		FormFactor = FormFactor.COMPACT,
		ScreenSize = Vector2.new(300, 200),
	}

	it("should create and destroy without errors", function()
		-- Tablet
		local element = mockServices({
			ContextualMenu = Roact.createElement(PlacesListContextualMenu, {
				game = Game.mock(),
				anchorSpaceSize = Vector2.new(30, 30),
				anchorSpacePosition = Vector2.new(0, 0),
			}),
		}, {
			includeStoreProvider = true,
			store = mockTabletStore,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)

		-- COMPACT view
		element = mockServices({
			ContextualMenu = Roact.createElement(PlacesListContextualMenu, {
				game = Game.mock(),
				anchorSpaceSize = Vector2.new(30, 30),
				anchorSpacePosition = Vector2.new(0, 0),
			}),
		}, {
			includeStoreProvider = true,
			store = mockCompactViewStore,
		})

		instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
