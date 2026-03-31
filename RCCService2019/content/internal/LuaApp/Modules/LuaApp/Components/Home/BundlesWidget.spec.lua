return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local BundlesWidget = require(script.Parent.BundlesWidget)

	local mockRequestResult = {}
	local networkImpl = MockRequest.simpleSuccessRequest(mockRequestResult)

	local titleText = "CommonUI.Features.Label.Catalog"
	local titleIcon = "LuaApp/icons/Catalog"

	local mockStore = Rodux.Store.new(AppReducer, {})

	it("should create and destroy an empty card list without errors", function()
		local element = mockServices({
			BundlesWidget = Roact.createElement(BundlesWidget, {
				width = 600,
				titleIcon = titleIcon,
				titleText = titleText,
				onActivated = function() end,
			})
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = mockStore,
			extraServices = {
				[RoactNetworking] = networkImpl,
			},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end