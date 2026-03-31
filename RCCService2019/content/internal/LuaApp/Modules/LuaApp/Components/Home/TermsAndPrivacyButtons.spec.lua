return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local TermsAndPrivacyButtons = require(Modules.LuaApp.Components.Home.TermsAndPrivacyButtons)

	it("should create and destroy without errors", function()
		local element = mockServices({
			TermsAndPrivacyButtons = Roact.createElement(TermsAndPrivacyButtons, {
				TextSize = 12,
				textHeight = 17,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end