return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AECategoryMenuClosed = require(Modules.LuaApp.Components.Avatar.UI.Views.Landscape.AECategoryMenuClosed)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)
	local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

	it("should create and destroy without errors", function()

		local store = Rodux.Store.new(AppReducer, {
			AEAppReducer = AEAppReducer({}, {}),
		})

		local element
		if FFlagAvatarEditorEnableThemes then
			element = mockServices({
				AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
				{
					categoryMenuClosed = Roact.createElement(AECategoryMenuClosed, {
						deviceOrientation = DeviceOrientationMode.Landscape,
						visible = true,
					})
				})
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})
		else
			element = mockServices({
				categoryMenuClosed = Roact.createElement(AECategoryMenuClosed, {
					deviceOrientation = DeviceOrientationMode.Landscape,
					visible = true,
				})
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