return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AEAppReducer = require(Modules.LuaApp.Reducers.AEReducers.AEAppReducer)
	local AESlidersFrame = require(Modules.LuaApp.Components.Avatar.UI.AESlidersFrame)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)

	it("should create and destroy without errors", function()

		local store = Rodux.Store.new(AppReducer, {
			AEAppReducer = AEAppReducer({}, {}),
		})

		local mockScrollingFrame = Instance.new("ScrollingFrame")

		local element = mockServices({
			AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
			{
				slidersFrame = Roact.createElement(AESlidersFrame, {
					deviceOrientation = DeviceOrientationMode.Portrait,
					scrollingFrameRef = mockScrollingFrame,
					analytics = {},
				})
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end