local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Rodux = require(Modules.Common.Rodux)
local AESetGamepadNavigationMenuLevel = require(Modules.LuaApp.Actions.AEActions.AESetGamepadNavigationMenuLevel)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)

return Rodux.createReducer(
	AEConstants.GamepadNavigationMenuLevel.CategoryMenu
, {
	[AESetGamepadNavigationMenuLevel.name] = function(state, action)
		return action.gamepadNavigationMenuLevel
	end,
})