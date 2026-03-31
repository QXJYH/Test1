return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AEDialogFrame = require(Modules.LuaApp.Components.Avatar.UI.AEDialogFrame)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)

	describe("should create and destroy without errors, on different device orientations", function()
		it("should create and destroy without errors with PORTRAIT", function()
			local store = Rodux.Store.new(AppReducer, {
				AEAppReducer = AEAppReducer({}, {}),
			})

			local element = mockServices({
				AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
				{
					dialogFrame = Roact.createElement(AEDialogFrame, {
						deviceOrientation = DeviceOrientationMode.Portrait,
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

		it("should create and destroy without errors with LANDSCAPE", function()
			local store = Rodux.Store.new(AppReducer, {
				AEAppReducer = AEAppReducer({}, {}),
			})

			local element = mockServices({
				AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
				{
					dialogFrame = Roact.createElement(AEDialogFrame, {
						deviceOrientation = DeviceOrientationMode.Landscape,
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
	end)
end
