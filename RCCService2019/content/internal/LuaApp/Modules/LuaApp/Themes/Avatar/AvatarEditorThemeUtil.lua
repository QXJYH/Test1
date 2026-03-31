--[[
	Utility file for the Avatar Editor theme files. Returns the correct theme information
	given an orientation, theme, and table of themes.
]]
local GuiService = game:GetService("GuiService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local Constants = require(Modules.LuaApp.Constants)
local IS_CONSOLE = GuiService:IsTenFootInterface()
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AvatarEditorThemeUtil = {}

function AvatarEditorThemeUtil.new()
	local self = {}
	setmetatable(self, AvatarEditorThemeUtil)

	self.lastTheme = nil
	self.lastOrientation = nil

	return self
end

function AvatarEditorThemeUtil:getThemeInfo(orientation, theme)
	if self.lastOrientation ~= orientation then
		if IS_CONSOLE then
			self.orientationInfo = self.themes.Orientations.Xbox
		elseif orientation == DeviceOrientationMode.Portrait then
			self.orientationInfo = self.themes.Orientations.Portrait
		elseif orientation == DeviceOrientationMode.Landscape then
			self.orientationInfo = self.themes.Orientations.Landscape
		end

		self.lastOrientation = orientation
	end

	if not IS_CONSOLE and theme and self.lastTheme ~= theme then
		if theme == Constants.Themes.Classic then
			self.colorThemeInfo = self.themes.ColorThemes.ClassicTheme
		elseif theme == Constants.Themes.Dark then
			self.colorThemeInfo = self.themes.ColorThemes.DarkTheme
		elseif theme == Constants.Themes.Light then
			self.colorThemeInfo = self.themes.ColorThemes.LightTheme
		end

		self.lastTheme = theme
	elseif not self.lastTheme and FFlagAvatarEditorEnableThemes and IS_CONSOLE then
		self.colorThemeInfo = self.themes.ColorThemes.XboxColorTheme
			or self.themes.ColorThemes.ClassicTheme
	end

	return {
		OrientationTheme = self.orientationInfo,
		ColorTheme = self.colorThemeInfo,
	}
end

return AvatarEditorThemeUtil