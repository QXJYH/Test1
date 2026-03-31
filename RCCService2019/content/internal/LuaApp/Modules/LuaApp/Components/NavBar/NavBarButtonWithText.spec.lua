return function()
	local NavBarButtonWithText = require(script.Parent.NavBarButtonWithText)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testNavBarButtonWithText = function(props)
		local element = mockServices({
			NavBarButtonWithText = Roact.createElement(NavBarButtonWithText, props)
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors", function()
		testNavBarButtonWithText({
			icon = "LuaApp/icons/navbar_home",
			titleKey = "CommonUI.Features.Label.Home",
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when badgeCount > 0", function()
		testNavBarButtonWithText({
			icon = "LuaApp/icons/navbar_home",
			titleKey = "CommonUI.Features.Label.Home",
			badgeCount = 100,
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when current button is selected", function()
		testNavBarButtonWithText({
			icon = "LuaApp/icons/navbar_home",
			titleKey = "CommonUI.Features.Label.Home",
			selected = true,
			onActivated = function() end,
		})
	end)
end