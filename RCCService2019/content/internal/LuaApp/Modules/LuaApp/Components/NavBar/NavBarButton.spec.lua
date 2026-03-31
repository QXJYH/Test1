return function()
	local NavBarButton = require(script.Parent.NavBarButton)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testNavBarButton = function(props)
		local element = mockServices({
			NavBarButton = Roact.createElement(NavBarButton, props)
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors", function()
		testNavBarButton({
			icon = "LuaApp/icons/navbar_home",
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when badgeCount > 0", function()
		testNavBarButton({
			icon = "LuaApp/icons/navbar_home",
			badgeCount = 100,
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when current button is selected", function()
		testNavBarButton({
			icon = "LuaApp/icons/navbar_home",
			selected = true,
			onActivated = function() end,
		})
	end)
end