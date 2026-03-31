return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local RunService = game:GetService("RunService")
	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local VersionTextWidget = require(Modules.LuaApp.Components.Home.VersionTextWidget)

	it("should create and destroy without errors", function()
		local element = mockServices({
			VersionTextWidget = Roact.createElement(VersionTextWidget, {
				TextSize = 12,
				textHeight = 17,
			}),
		}, {
			includeThemeProvider = true,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end