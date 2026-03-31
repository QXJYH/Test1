return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local MockId = require(Modules.LuaApp.MockId)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local NativeViewUserProfileWrapper = require(script.parent.NativeViewUserProfileWrapper)

	it("should create and destroy without errors", function()
		local userId = MockId()
		local element = mockServices({
			wrapper = Roact.createElement(NativeViewUserProfileWrapper, {
				isVisible = true,
				userId = userId,
			}),
		}, {
			includeStoreProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end