local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local CorePackages = game:GetService("CorePackages")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local UniversalApp = require(Modules.LuaApp.Components.UniversalApp)
local LuaErrorReporter = require(Modules.Common.LuaErrorReporter)

local legacyInputSettingRefactor = settings():GetFFlag("LuaAppLegacyInputSettingRefactor")

local ERROR_REPORTER_APP_NAME = "LuaApp"

if not UserSettings().GameSettings:InStudioMode() then
	-- listen and report errors
	local errorReporter = LuaErrorReporter.new()
	errorReporter:setCurrentApp(ERROR_REPORTER_APP_NAME)
	errorReporter:startQueueTimers()
end

-- Common Setup
if game.Players.LocalPlayer == nil then
	game.Players.PlayerAdded:Wait()
end

-- Reduce render quality to optimize performance
local renderSteppedConnection = nil
renderSteppedConnection = game:GetService("RunService").RenderStepped:connect(function()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end
	settings().Rendering.QualityLevel = 1
end)

if legacyInputSettingRefactor then
	UserInputService.LegacyInputEventsEnabled = false
end

-- Mount main application component

local root = Roact.createElement(UniversalApp, {
	appName = ERROR_REPORTER_APP_NAME,
})

Roact.mount(root, CoreGui, "App")

-- Run tests when shift+alt+ctrl+T is pressed
UserInputService.InputEnded:connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard and
		input.KeyCode == Enum.KeyCode.T and
		UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and
		UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
		UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
	then
		local TestEZ = require(CorePackages.TestEZ)

		TestEZ.run(CorePackages.AppTempCommon, function(results)
			TestEZ.Reporters.TextReporter.report(results)
		end)

		TestEZ.run(Modules.LuaChat, function(results)
			TestEZ.Reporters.TextReporter.report(results)
		end)

		TestEZ.run(Modules.LuaApp, function(results)
			TestEZ.Reporters.TextReporter.report(results)
		end)
	end
end)
