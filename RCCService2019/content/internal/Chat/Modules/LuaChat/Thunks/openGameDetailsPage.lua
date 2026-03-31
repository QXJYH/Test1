local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules

local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

return function(universeId)
	return function(store)
		store:dispatch(NavigateDown({
			name = AppPage.GameDetail,
			detail = tostring(universeId),
		}))
	end
end