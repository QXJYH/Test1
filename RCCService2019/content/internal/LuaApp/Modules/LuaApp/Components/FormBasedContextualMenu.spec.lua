return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local FormBasedContextualMenu = require(Modules.LuaApp.Components.FormBasedContextualMenu)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local User = require(Modules.LuaApp.Models.User)

	local mockWideViewStore = {
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

	it("should create and destroy without errors for WIDE view", function()
		local element = mockServices({
			ContextualMenu = Roact.createElement(FormBasedContextualMenu, {
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
			ContextualMenu = Roact.createElement(FormBasedContextualMenu, {
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
