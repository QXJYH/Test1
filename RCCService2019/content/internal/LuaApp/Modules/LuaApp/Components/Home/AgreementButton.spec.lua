return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AgreementButton = require(Modules.LuaApp.Components.Home.AgreementButton)
	local AgreementPageType = require(Modules.LuaApp.Enum.AgreementPageType)

	it("should create and destroy without errors for privacy", function()
		local element = mockServices({
			AgreementButton = Roact.createElement(AgreementButton, {
				pageId = AgreementPageType.Privacy,
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

	it("should create and destroy without errors for terms", function()
		local element = mockServices({
			AgreementButton = Roact.createElement(AgreementButton, {
				pageId = AgreementPageType.Terms,
				TextSize = 16,
				textHeight = 22,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end