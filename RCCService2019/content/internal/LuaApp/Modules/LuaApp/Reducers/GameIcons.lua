--[[
	A separate reducer for game thumbnails,setting
	it to a separate table. We are using the universeId rightNow
]]
local CorePackages = game:GetService("CorePackages")
local Cryo = require(CorePackages.Cryo)
local LuaApp = CorePackages.AppTempCommon.LuaApp
local SetGameIcons = require(LuaApp.Actions.SetGameIcons)

return function(state, action)
	state = state or {}

	if action.type == SetGameIcons.name then
		state = Cryo.Dictionary.join(state, action.gameIcons)
	end

	return state
end