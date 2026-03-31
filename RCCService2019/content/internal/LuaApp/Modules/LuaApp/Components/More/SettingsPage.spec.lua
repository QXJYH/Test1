return function()
	local SettingsPage = require(script.Parent.SettingsPage)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer, {
			NotificationBadgeCounts = {
				MorePageSettings = 0,
			},
		})

		local element = mockServices({
			SettingsPage = Roact.createElement(SettingsPage),
		}, {
			includeLocalizationProvider = true,
			includeStyleProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
