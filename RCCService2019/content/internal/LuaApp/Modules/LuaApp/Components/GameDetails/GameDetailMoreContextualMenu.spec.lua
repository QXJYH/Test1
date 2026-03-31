return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
    local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GameDetailMoreContextualMenu = require(Modules.LuaApp.Components.GameDetails.GameDetailMoreContextualMenu)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AppPage = require(Modules.LuaApp.AppPage)

	local universeId = "123456"

	local mockTheme = {
		ContextualMenu = {
			Cells = {
				Icon = {
					Color = Color3.fromRGB(1, 2, 3),
					OnColor = Color3.fromRGB(1, 2, 3),
				},
				Content = {
					Color = Color3.fromRGB(1, 2, 3),
					DisabledColor = Color3.fromRGB(1, 2, 3),
					DisabledTransparency = 0.5,
				},
				Background = {
					OnPressColor = Color3.fromRGB(1, 2, 3),
					OnPressTransparency = 0.9,
				},
			},
			Background = {
				Color = Color3.fromRGB(1, 2, 3),
			},
			Cancel = {
				Color = Color3.fromRGB(1, 2, 3),
			},
			Title = {
				Color = Color3.fromRGB(1, 2, 3),
			},
			Message = {
				Color = Color3.fromRGB(1, 2, 3),
			},
			Divider = {
				Color = Color3.fromRGB(1, 2, 3),
			},
		},
	}

    it("should create and destroy without errors", function()
        local store = Rodux.Store.new(AppReducer, {
            GameDetails = {
				[universeId] = GameDetail.mock(universeId, "mock game"),
			},
            GameFavorites = {
				[universeId] = true,
			},
			GameFollowings = {
				[universeId] = {
					canFollow = true,
					isFollowed = false,
				},
			},
			Navigation = {
				history = { { { name = AppPage.GameDetail } } },
			}
		})
		local element = mockServices({
			ContextualMenu = Roact.createElement(GameDetailMoreContextualMenu, {
				universeId = universeId,
				theme = mockTheme,
			}),
		}, {
			includeStoreProvider = true,
            store = store,
            includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end