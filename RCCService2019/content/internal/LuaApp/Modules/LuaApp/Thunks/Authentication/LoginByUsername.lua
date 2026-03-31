local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local LaunchApp = require(script.Parent.LaunchApp)
local LoginRequests = require(Modules.LuaApp.Http.Requests.LoginRequests)
local Url = require(Modules.LuaApp.Http.Url)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local LoginErrorCodes = require(Modules.LuaApp.Enum.LoginErrorCodes)

local withLocalization = require(Modules.LuaApp.withLocalization)

local function loginByUsername(networkImpl, cvalue, password)
	return function(store)
		return LoginRequests.logByUsername(networkImpl, cvalue, password):andThen(
			function(result)
				-- result : {"user":{"id":698042891,"name":"Rhodium001"}}
				-- todo we need to save cookies to disk here
				return result
			end,
			function(err)
				local body = HttpService:JSONDecode(err.Body)
				if body.errors[1].code == LoginErrorCodes.IncorrectCValueOrPassword then
					return Promise.reject("Authentication.Login.Response.IncorrectUsernamePassword")
				elseif body.errors[1].code == LoginErrorCodes.Captcha then
					store:dispatch(NavigateDown({
						name = AppPage.GenericWebPage,
						detail = "CAPTCHA_URL", -- TODO: Special value to indicate CAPTCHA!
						extraProps = {
							title = cvalue, -- TODO: Hack this property to send the username!
						},
					}))
					return Promise.reject()
				elseif body.errors[1].code == LoginErrorCodes.ServiceUnavailable then
					return Promise.reject("Authentication.Login.Response.ServiceUnavailable")
				else
					return Promise.reject("Authentication.Login.Response.SomethingWentWrong")
				end
			end
		)
	end
end

return loginByUsername 