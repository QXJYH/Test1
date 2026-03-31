return function()
	local NavigationBar = require(script.Parent.NavigationBar)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors with a title", function()
		local element = mockServices({
			NavigationBar = Roact.createElement(NavigationBar, {
				title = "CommonUI.Features.Label.Home",
			}),
		}, {
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors without a title", function()
		local element = mockServices({
			NavigationBar = Roact.createElement(NavigationBar),
		}, {
			includeStoreProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end