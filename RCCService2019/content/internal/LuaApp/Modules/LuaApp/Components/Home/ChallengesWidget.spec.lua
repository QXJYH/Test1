return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)

	local ChallengesWidget = require(script.Parent.ChallengesWidget)

	local mockRequestResult = {}

	local networkImpl = MockRequest.simpleSuccessRequest(mockRequestResult)

	it("should create and destroy without errors", function()
		local element = mockServices({
			Widget = Roact.createElement(ChallengesWidget, {})
		}, {
			includeStoreProvider = true,
			includeThemeProvider = true,
			extraServices = {
				[RoactNetworking] = networkImpl,
			},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end