return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local ScreenGuiWrap = require(script.parent.ScreenGuiWrap)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			ScreenGuiWrap = Roact.createElement(ScreenGuiWrap, {
				component = "Frame",
				isVisible = true,
				props = {},
			})
		}, {
			includeStoreProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end