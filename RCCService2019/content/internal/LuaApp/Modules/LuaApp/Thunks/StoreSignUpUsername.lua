local Modules = game:GetService("CoreGui").RobloxGui.Modules

local GetUsernameValid = require(Modules.LuaApp.Http.Requests.GetUsernameValid)
local Promise = require(Modules.LuaApp.Promise)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)

local SetSignupUsername = require(Modules.LuaApp.Actions.SetSignUpUsername)

return function (networking,username)
	return function(store)
		return GetUsernameValid(networking,username):andThen( --verify the name is accepted
			function(result)
				if result.responseBody.code==0 then
					store:dispatch(SetSignupUsername(username))
					return Promise.resolve()
				else
					return Promise.reject()
				end
			end,
			function(err)
				store:dispatch(SetNetworkingErrorToast(err))
				return Promise.reject(err)
			end
		)
	end
end