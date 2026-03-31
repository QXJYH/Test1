return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local LightTheme = require(Modules.LuaApp.Themes.DeprecatedLightTheme)
	local GenericTextButton = require(Modules.LuaApp.Components.GenericTextButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testGenericTextButton(props)
		local element = mockServices({
			GenericTextButton = Roact.createElement(GenericTextButton, props),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when there's no border", function()
		testGenericTextButton({
			themeSettings = LightTheme.ContextPrimaryButton,
			text = "test",
			isLoading = false,
		})
	end)

	it("should create and destroy without errors when there is border", function()
		testGenericTextButton({
			themeSettings = LightTheme.SecondaryButton,
			text = "test",
			isLoading = false,
		})
	end)

	it("should create and destroy without errors when isLoding == true", function()
		testGenericTextButton({
			themeSettings = LightTheme.ContextPrimaryButton,
			text = "test",
			isLoading = true,
		})
	end)
end