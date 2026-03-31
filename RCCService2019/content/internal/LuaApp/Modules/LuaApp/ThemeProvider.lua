local AppStorageService = game:GetService("AppStorageService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)

local ThemeProvider = Roact.Component:extend("ThemeProvider")

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings:UseNewAppStyle()

local getThemeModuleForString

if useNewAppStyle then
	getThemeModuleForString = require(Modules.LuaApp.Themes.getThemeModuleForString)
else
	local CorePackages = game:GetService("CorePackages")
	local Logging = require(CorePackages.Logging)

	local ClassicTheme = require(Modules.LuaApp.Themes.ClassicTheme)
	local LightTheme = require(Modules.LuaApp.Themes.DeprecatedLightTheme)
	local DarkTheme = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)

local THEME_MAP = {
	["dark"] = DarkTheme,
	["light"] = LightTheme,
	["classic"] = ClassicTheme,
}

	getThemeModuleForString = function (themeName)
		if themeName ~= nil and #themeName > 0 then
			local mappedTheme = THEME_MAP[string.lower(themeName)]
			if mappedTheme ~= nil then
				return mappedTheme
			else
				Logging.warn("Unrecognized theme name: " .. themeName)
			end
		end

		return ClassicTheme
	end
end

function ThemeProvider:init(props)
	local theme = props.theme
	local themeName = props.themeName
	self._context.AppTheme = useNewAppStyle and getThemeModuleForString(themeName) or theme
end

function ThemeProvider:didMount()
	if FlagSettings:EnableLuaAppLoginPageForUniversalAppDev() then
		self.connection = AppStorageService.ItemWasSet:Connect(
			function(key, value)
				if key == LocalStorageKey.Theme then
					if useNewAppStyle then
						self._context.AppTheme = getThemeModuleForString(value)
					end
				end
			end
		)
	end
end

function ThemeProvider:willUnmount()
	if FlagSettings:EnableLuaAppLoginPageForUniversalAppDev() then
		if self.connection then
			self.connection:Disconnect()
		end
	end
end

function ThemeProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ThemeProvider
