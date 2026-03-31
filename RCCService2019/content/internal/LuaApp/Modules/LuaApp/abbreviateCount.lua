local Modules = game:GetService("CoreGui").RobloxGui.Modules
local NumberLocalization = require(Modules.LuaApp.Util.NumberLocalization)

return function(number, locale)
	return NumberLocalization.abbreviate(number, locale)
end
