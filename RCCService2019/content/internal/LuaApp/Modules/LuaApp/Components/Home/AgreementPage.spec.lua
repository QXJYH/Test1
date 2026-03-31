return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AgreementPageType = require(Modules.LuaApp.Enum.AgreementPageType)
	local AgreementPage = require(Modules.LuaApp.Components.Home.AgreementPage)

	it("should create and destroy without errors for privacy", function()
		local element = mockServices({
			AgreementPage = Roact.createElement(AgreementPage, {
				pageId = AgreementPageType.Privacy,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for terms", function()
		local element = mockServices({
			AgreementPage = Roact.createElement(AgreementPage, {
				pageId = AgreementPageType.Terms,
			}),
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end