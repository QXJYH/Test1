return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local LoadableButton = require(Modules.LuaApp.Components.LoadableButton)

	it("should create and destroy without errors", function()
		local element = mockServices({
			LoadableButton = Roact.createElement(LoadableButton, {
				Size = UDim2.new(0, 8, 0, 8),
				Loading = true,
			})
		}, {
			includeThemeProvider = true,
		})



		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end