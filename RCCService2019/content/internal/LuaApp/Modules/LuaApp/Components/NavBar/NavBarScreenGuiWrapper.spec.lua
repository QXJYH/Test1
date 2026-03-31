return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local NavBarScreenGuiWrapper = require(script.parent.NavBarScreenGuiWrapper)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			NavBarScreenGuiWrapper = Roact.createElement(NavBarScreenGuiWrapper, {
				isVisible = true,
				component = "Frame",
				props = {},
			})
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end