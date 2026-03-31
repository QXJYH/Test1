return function()
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local LightTheme = require(Modules.LuaApp.Themes.DeprecatedLightTheme)
	local LeaveRobloxAlert = require(Modules.LuaApp.Components.GameDetails.LeaveRobloxAlert)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
				PurchaseGamePrompt = Roact.createElement(LeaveRobloxAlert, {
				continueFunc = function() print("test") end,
				theme = LightTheme,
				containerWidth = 100,
			})
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end