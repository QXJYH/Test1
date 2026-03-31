local AppPageProperties = require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.AppPageProperties)

local result = {}
for key, value in pairs(AppPageProperties) do
	result[key] = value.nameLocalizationKey
end

return result
