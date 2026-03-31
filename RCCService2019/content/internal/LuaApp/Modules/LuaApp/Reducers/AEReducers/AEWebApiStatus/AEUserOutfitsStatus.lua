local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local AEUserOutfitsStatus = require(Modules.LuaApp.Actions.AEActions.AEWebApiStatus.AEUserOutfitsStatus)
local Immutable = require(CorePackages.AppTempCommon.Common.Immutable)

return function(state, action)
	state = state or {}
	if action.type == AEUserOutfitsStatus.name then
		return Immutable.Set(state, action.costumeType, action.status)
	end
	return state
end
