return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local GenericIconButton = require(Modules.LuaApp.Components.GenericIconButton)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testGenericIconButton(props)
		local element = mockServices({
			GenericIconButton = Roact.createElement(GenericIconButton, props),
		}, {
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

    it("should create and destroy without errors when default", function()
		testGenericIconButton()
    end)

	it("should create and destroy without errors when isLoding == true", function()
		testGenericIconButton({
			isLoading = true,
		})
    end)

    it("should create and destroy without errors when isChecked == true", function()
		testGenericIconButton({
			isChecked = true,
		})
    end)
end