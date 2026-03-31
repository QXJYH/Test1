return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AEUILoader = require(Modules.LuaApp.Components.Avatar.UI.AEUILoader)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)

	it("should create and destroy without errors", function()

		local store = Rodux.Store.new(AppReducer, {
			AEAppReducer = AEAppReducer({}, {}),
		})

		local element = mockServices({
			AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
			{
				loader = Roact.createElement(AEUILoader, {
					avatarEditorActive = true,
				})
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
