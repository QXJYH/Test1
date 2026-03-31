return function()
	local GuiService = game:GetService("GuiService")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService('UserInputService')
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
	local AppRunService = require(Modules.LuaApp.Services.AppRunService)
	local AppUserInputService = require(Modules.LuaApp.Services.AppUserInputService)
	local AntiAddictionPrompt = require(script.Parent.AntiAddictionPrompt)

	it("should create and destroy alert without errors", function()
		local element = mockServices({
			Prompt = Roact.createElement(AntiAddictionPrompt, {
				okCallback = function() end,
				message = "alert text",
				lockOut = false,
			})
		}, {
			includeLocalizationProvider = true,
			includeStoreProvider = true,
			includeThemeProvider = true,
			extraServices = {
				[AppGuiService] = GuiService,
				[AppRunService] = RunService,
				[AppUserInputService] = UserInputService,
			},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy lockout alert without errors", function()
		local element = mockServices({
			Prompt = Roact.createElement(AntiAddictionPrompt, {
				okCallback = function() end,
				message = "lock out alert text",
				lockOut = true,
			})
		}, {
			includeLocalizationProvider = true,
			includeStoreProvider = true,
			includeThemeProvider = true,
			extraServices = {
				[AppGuiService] = GuiService,
				[AppRunService] = RunService,
				[AppUserInputService] = UserInputService,
			},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end