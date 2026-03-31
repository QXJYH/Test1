return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AECategoryMenuCloseButton = require(Modules.LuaApp.Components.Avatar.UI.Views.AECategoryMenuCloseButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockAvatarEditorTheme = require(Modules.LuaApp.TestHelpers.MockAvatarEditorTheming)
	local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

	it("should create and destroy without errors when this tab is selected", function()

		local store = Rodux.Store.new(AppReducer, {
			AEAppReducer = {},
		})

		local element
		if FFlagAvatarEditorEnableThemes then
			element = mockServices({
				AvatarEditorThemingProvider = Roact.createElement(MockAvatarEditorTheme, {},
				{
					closeButton = Roact.createElement(AECategoryMenuCloseButton)
				})
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})
		else
			element = mockServices({
				closeButton = Roact.createElement(AECategoryMenuCloseButton)
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