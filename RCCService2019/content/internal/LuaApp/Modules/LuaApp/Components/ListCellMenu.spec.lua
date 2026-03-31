return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local ListCellMenu = require(script.Parent.ListCellMenu)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local MenuItem1 = {
		displayIcon = "rbxasset://textures/ui/LuaApp/icons/ic-view-details20x20.png",
		text = "TestItem1",
		onActivated = nil,
	}
	local MenuItem2 = {
		text = "Feature.Favorites.Label.Favorite",
		textChecked = "Feature.Favorites.Label.Favorited",
		textLocalization = true,
		displayIcon = "LuaApp/icons/ic-tbc",
		displayIconChecked = "LuaApp/icons/ic-google",
		checked = false,
		onActivated = function()
			print("test")
		end
	}

	local menuItems = { MenuItem1, MenuItem2 }

	it("should create and destroy without errors on COMPACT view", function()
		local store = Rodux.Store.new(AppReducer, {
			FormFactor = FormFactor.COMPACT,
			ScreenSize = {
				X = 320,
				Y = 640,
			}
		})

		local element = mockServices({
			contextualListMenu = Roact.createElement(ListCellMenu, {
				items = menuItems,
				layoutOrder = 2,
				width = 200,
				maxHeight = 150,
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors on WIDE view", function()
		local store = Rodux.Store.new(AppReducer, {
			FormFactor = FormFactor.WIDE,
			ScreenSize = {
				X = 320,
				Y = 640,
			}
		})

		local element = mockServices({
			contextualListMenu = Roact.createElement(ListCellMenu, {
				items = menuItems,
				layoutOrder = 2,
				width = 200,
				maxHeight = 200,
			})
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
