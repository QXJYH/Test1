return function()
	local NavBar = require(script.Parent.NavBar)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local AppPage = require(Modules.LuaApp.AppPage)
	local NavBarButton = require(Modules.LuaApp.Components.NavBar.NavBarButton)
	local NavBarButtonWithText = require(Modules.LuaApp.Components.NavBar.NavBarButtonWithText)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local renderItem = function(context, selected)
		return Roact.createElement(NavBarButton, {
			selected = selected,
			onActivated = function() end
		})
	end

	local renderItemWithText = function(context, selected)
		return Roact.createElement(NavBarButtonWithText, {
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
			actionType = Enum.AppShellActionType.TapHomePageTab,
			badgeCount = 0,
		},
		{
			page = AppPage.Games,
			icon = "LuaApp/icons/navbar_games",
			titleKey = "CommonUI.Features.Label.Game",
			actionType = Enum.AppShellActionType.TapGamePageTab,
			badgeCount = 0,
		},
	}

	local testNavBar = function(props)
		local element = mockServices({
			NavBar = Roact.createElement(NavBar, props)
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should throw when there is no item", function()
		expect(function()
			testNavBar({
				renderItem = function() end,
			})
		end).to.throw()
	end)

	it("should throw when there is no renderItem function", function()
		expect(function()
			testNavBar({
				items = testItems,
			})
		end).to.throw()
	end)

	it("should create and destroy without errors when there are items", function()
		testNavBar({
			selectedIndex = 1,
			items = testItems,
			renderItem = renderItem,
		})
		testNavBar({
			selectedIndex = 1,
			items = testItems,
			renderItem = renderItemWithText,
		})
	end)

	it("should create and destroy without errors when there are items in Horizontal layout", function()
		testNavBar({
			selectedIndex = 1,
			layoutInfo = {
				fillDirection = Enum.FillDirection.Horizontal,
			},
			items = testItems,
			renderItem = renderItem,
		})
		testNavBar({
			selectedIndex = 1,
			layoutInfo = {
				fillDirection = Enum.FillDirection.Horizontal,
			},
			items = testItems,
			renderItem = renderItemWithText,
		})
	end)

	it("should create and destroy without errors when there are items in Vertical layout", function()
		testNavBar({
			selectedIndex = 1,
			layoutInfo = {
				fillDirection = Enum.FillDirection.Vertical,
			},
			items = testItems,
			renderItem = renderItem,
		})
		testNavBar({
			selectedIndex = 1,
			layoutInfo = {
				fillDirection = Enum.FillDirection.Vertical,
			},
			items = testItems,
			renderItem = renderItemWithText,
		})
	end)
end