return function()
	local MoreButton = require(script.Parent.MoreButton)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors with icon + text + rightImage button", function()
		local catalog = MorePageSettings.ItemInfo[MorePageSettings.ItemType.Catalog]

		local root = mockServices({
			element = Roact.createElement(MoreButton, {
				Text = catalog.textKey,
				icon = catalog.icon,
				rightImage = catalog.rightImage,
				onActivated = function() end,
			}),
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with text only button", function()
		local logOut = MorePageSettings.ItemInfo[MorePageSettings.ItemType.LogOut]

		local root = mockServices({
			element = Roact.createElement(MoreButton, {
				Text = logOut.textKey,
				onActivated = function() end,
			}),
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors with text + rightImage button", function()
		local aboutUs = MorePageSettings.ItemInfo[MorePageSettings.ItemType.About_AboutUs]

		local root = mockServices({
			element = Roact.createElement(MoreButton, {
				Text = aboutUs.textKey,
				rightImage = aboutUs.rightImage,
				onActivated = function() end,
			}),
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStyleProvider = true,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
	end)
end