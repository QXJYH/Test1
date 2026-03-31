return function()
	local UniversalBottomBarButton = require(script.Parent.UniversalBottomBarButton)

	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testUniversalBottomBarButton = function(props)
		local element = mockServices({
			UniversalBottomBarButton = Roact.createElement(UniversalBottomBarButton, props)
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors", function()
		testUniversalBottomBarButton({
			titleKey = "CommonUI.Features.Label.Home",
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when badgeCount > 0", function()
		testUniversalBottomBarButton({
			titleKey = "CommonUI.Features.Label.Home",
			badgeCount = 5,
			onActivated = function() end,
		})
	end)

	it("should create and destroy without errors when current button is selected", function()
		testUniversalBottomBarButton({
			titleKey = "CommonUI.Features.Label.Home",
			selected = true,
			onActivated = function() end,
		})
	end)
end