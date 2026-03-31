return function()
	local UniversalBottomBar = require(script.Parent.UniversalBottomBar)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local AppPage = require(Modules.LuaApp.AppPage)
	local UniversalBottomBarButton = require(Modules.LuaApp.Components.UniversalBottomBarButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local renderItem = function(context, selected)
		return Roact.createElement(UniversalBottomBarButton, {
			titleKey = context.titleKey,
			selected = selected,
			onActivated = function() end
		})
	end

	local testItems = {
		{
			page = AppPage.Home,
			icon = "LuaApp/icons/navbar_home",
			titleKey = "CommonUI.Features.Label.Home",
			badgeCount = 0,
		},
		{
			page = AppPage.Games,
			icon = "LuaApp/icons/navbar_games",
			titleKey = "CommonUI.Features.Label.Game",
			badgeCount = 0,
		},
	}

	local testUniversalBottomBar = function(props)
		local element = mockServices({
			UniversalBottomBar = Roact.createElement(UniversalBottomBar, props)
		}, {
			includeThemeProvider = true,
			includeLocalizationProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when there's no items", function()
		testUniversalBottomBar({
			renderItem = renderItem,
		})
	end)

	it("should create and destroy without errors when there's items", function()
		testUniversalBottomBar({
			selectedIndex = 1,
			items = testItems,
			renderItem = renderItem,
		})
	end)
end