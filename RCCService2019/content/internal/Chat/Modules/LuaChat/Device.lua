local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules

local Config = require(Modules.LuaApp.Config)
local Create = require(Modules.LuaChat.Create)
local SetPlatform = require(Modules.LuaApp.Actions.SetPlatform)

local STATUS_BAR_HEIGHT_IOS = 20
local STATUS_BAR_HEIGHT_ANDROID = 24
local NAV_BAR_HEIGHT = 44

local Device = {}

local function simulateIOS()
	local statusBarSize = Vector2.new(0, STATUS_BAR_HEIGHT_IOS)
	local navBarSize = Vector2.new(0, NAV_BAR_HEIGHT)
	local bottomBarSize = Vector2.new(0, 0)
	local rightBarSize = Vector2.new(0, 0)
	--Pcall because Tests have a lower security context
	pcall(function()
		UserInputService:SendAppUISizes(statusBarSize, navBarSize, bottomBarSize, rightBarSize)
		GuiService:SetSafeZoneOffsets(0, 0, 0, 0)
	end)
end

local function simulateAndroid()
	local statusBarSize = Vector2.new(0, STATUS_BAR_HEIGHT_ANDROID)
	local navBarSize = Vector2.new(0, NAV_BAR_HEIGHT)
	local bottomBarSize = Vector2.new(0, 0)
	local rightBarSize = Vector2.new(0, 0)
	--Pcall because Tests have a lower security context
	pcall(function()
		UserInputService:SendAppUISizes(statusBarSize, navBarSize, bottomBarSize, rightBarSize)
		GuiService:SetSafeZoneOffsets(0, 0, 0, 0)
	end)

	local screenGui = Create.new "ScreenGui" {
		Name = "StudioShellSimulation",
		DisplayOrder = 10,

		Create.new "Frame" {
			Name = "StatusBar",
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, UserInputService.StatusBarSize.Y),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(117, 117, 117),
		}
	}
	screenGui.Parent = CoreGui
end

function Device.simulatePlatformIfInStudio(store)
	if RunService:IsStudio() then
		store:dispatch(SetPlatform(Config.General.SimulatePlatform))

		if Config.General.SimulatePlatform == Enum.Platform.IOS then
			simulateIOS()
		elseif Config.General.SimulatePlatform == Enum.Platform.Android then
			simulateAndroid()
		end
	end
end

return Device