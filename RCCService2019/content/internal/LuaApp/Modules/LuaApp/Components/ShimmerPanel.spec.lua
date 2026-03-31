return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local ShimmerPanel = require(Modules.LuaApp.Components.ShimmerPanel)

	it("should create and destroy without errors", function()
		local element = mockServices({
			ShimmerPanel = Roact.createElement(ShimmerPanel, {
				Size = UDim2.new(0, 100, 0, 100),
			})
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end