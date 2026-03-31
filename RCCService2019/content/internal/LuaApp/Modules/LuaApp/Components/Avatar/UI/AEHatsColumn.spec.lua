return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AEHatsColumn = require(Modules.LuaApp.Components.Avatar.UI.AEHatsColumn)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)
	local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

	describe("should create and destroy without errors, on different device orientations", function()
		it("should create and destroy without errors with PORTRAIT", function()
			local store = Rodux.Store.new(AppReducer, {
				AEAppReducer = AEAppReducer({}, {}),
			})

			local element
			if FFlagAvatarEditorEnableThemes then
				element = mockServices({
					AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
					{
						hatsColumn = Roact.createElement(AEHatsColumn, {
							deviceOrientation = DeviceOrientationMode.Portrait,
							analytics = {},
						})
					})
				}, {
					includeStoreProvider = true,
					store = store,
					includeThemeProvider = true,
				})
			else
				element = mockServices({
					hatsColumn = Roact.createElement(AEHatsColumn, {
						deviceOrientation = DeviceOrientationMode.Portrait,
						analytics = {},
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

		it("should create and destroy without errors with Landscape", function()
			local store = Rodux.Store.new(AppReducer, {
				AEAppReducer = AEAppReducer({}, {}),
			})

			local element
			if FFlagAvatarEditorEnableThemes then
				element = mockServices({
					AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
					{
						hatsColumn = Roact.createElement(AEHatsColumn, {
							deviceOrientation = DeviceOrientationMode.Landscape,
							analytics = {},
						})
					})
				}, {
					includeStoreProvider = true,
					store = store,
					includeThemeProvider = true,
				})
			else
				element = mockServices({
					hatsColumn = Roact.createElement(AEHatsColumn, {
						deviceOrientation = DeviceOrientationMode.Landscape,
						analytics = {},
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
	end)
end