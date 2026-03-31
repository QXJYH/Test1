return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local PeopleListContextualMenu = require(Modules.LuaApp.Components.Home.PeopleListContextualMenu)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local User = require(Modules.LuaApp.Models.User)

	local mockWideViewStore = Rodux.Store.new(AppReducer, {
		TabBarVisible = true,
		TopBar = {
			topBarHeight = 20,
		},
		FormFactor = FormFactor.WIDE,
		ScreenSize = Vector2.new(300, 200),
	})

	local mockCompactViewStore = Rodux.Store.new(AppReducer, {
		TabBarVisible = true,
		TopBar = {
			topBarHeight = 20,
		},
		FormFactor = FormFactor.COMPACT,
		ScreenSize = Vector2.new(300, 200),
	})

	it("should create and destroy without errors for WIDE view", function()
		local element = mockServices({
			ContextualMenu = Roact.createElement(PeopleListContextualMenu, {
				user = User.mock(),
				anchorSpaceSize = Vector2.new(30, 30),
				anchorSpacePosition = Vector2.new(0, 0),
			}),
		}, {
			includeStoreProvider = true,
			store = mockWideViewStore,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for COMPACT view", function()
		local element = mockServices({
			ContextualMenu = Roact.createElement(PeopleListContextualMenu, {
				user = User.mock(),
				anchorSpaceSize = Vector2.new(30, 30),
				anchorSpacePosition = Vector2.new(0, 0),
			}),
		}, {
			includeStoreProvider = true,
			store = mockCompactViewStore,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
