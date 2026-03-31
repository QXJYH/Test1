local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local ClearUserSpecificData = require(Modules.LuaApp.Actions.ClearUserSpecificData)
local HttpCanceller = require(Modules.LuaApp.Http.NetworkLayers.HttpCanceller)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)

return function()
	return function(store)
		store:dispatch(ClearUserSpecificData())
		HttpCanceller.cancel()
		PerformFetch.ClearOutstandingPromiseStatus()
	end
end