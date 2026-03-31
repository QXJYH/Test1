return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AvatarWidget = require(script.Parent.AvatarWidget)

	local mockStore = Rodux.Store.new(AppReducer, {})

	it("should create and destroy without errors", function()
		local element = mockServices({
			Widget = Roact.createElement(AvatarWidget, {})
		}, {
			includeStoreProvider = true,
			store = mockStore,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end