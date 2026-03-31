-- for now AppState will be singleton so we can more easily migrate to Rodux
-- but if we also migrate to Roact, this will need to change

local CorePackages = game:GetService("CorePackages")

local AppShellReducer = require(script.Parent.Reducers.AppShellReducer)
local Rodux = require(CorePackages.Rodux)

local AppState = {}

function AppState:Init()
	self.store = Rodux.Store.new(AppShellReducer, {}, {
		Rodux.thunkMiddleware,
	})
end

function AppState:Destruct()
	self.store:destruct()
end

AppState:Init()

return AppState