return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local TouchFriendlyIconButton = require(Modules.LuaApp.Components.Generic.TouchFriendlyIconButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors", function()
		local element = mockServices({
			TouchFriendlyIconButton = Roact.createElement(TouchFriendlyIconButton)
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end