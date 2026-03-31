return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AEWarningWidget = require(Modules.LuaApp.Components.Avatar.UI.AEWarningWidget)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)
	local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")

	it("should create and destroy without errors", function()

		local store = Rodux.Store.new(AppReducer, {
			AEAppReducer = AEAppReducer({}, {}),
		})

		local element
		if FFlagAvatarEditorGothamFont then
			element = mockServices({
				AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
				{
					warningWidget = Roact.createElement(AEWarningWidget)
				})
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})
		else
			element = mockServices({
				warningWidget = Roact.createElement(AEWarningWidget)
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})
		end

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end