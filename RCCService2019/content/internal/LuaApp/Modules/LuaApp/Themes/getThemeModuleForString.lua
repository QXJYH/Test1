
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local ClassicTheme = require(Modules.LuaApp.Themes.ClassicTheme)
local LightTheme = require(Modules.LuaApp.Themes.DeprecatedLightTheme)
local DarkTheme = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)

local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)

local THEME_MAP = {
	["dark"] = DarkTheme,
	["light"] = LightTheme,
	["classic"] = ClassicTheme,
}

return function (themeName)
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
