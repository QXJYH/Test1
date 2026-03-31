return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AEDarkCover = require(Modules.LuaApp.Components.Avatar.UI.AEDarkCover)
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
					darkCover = Roact.createElement(AEDarkCover, {
						deviceOrientation = DeviceOrientationMode.Portrait,
					})
				})
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})
		else
			element = mockServices({
				darkCover = Roact.createElement(AEDarkCover, {
					deviceOrientation = DeviceOrientationMode.Portrait,
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