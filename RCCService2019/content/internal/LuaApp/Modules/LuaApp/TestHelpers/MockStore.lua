local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Rodux = require(CorePackages.Rodux)
local AppReducer = require(Modules.LuaApp.AppReducer)

local MockStore = {}

function MockStore.new(initialState)
	return Rodux.Store.new(AppReducer, initialState or {}, { Rodux.thunkMiddleware })
end

return MockStore