local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Promise = require(Modules.LuaApp.Promise)
local LaunchApp = require(script.Parent.LaunchApp)
local LoginRequests = require(Modules.LuaApp.Http.Requests.LoginRequests)
local Url = require(Modules.LuaApp.Http.Url)

local function login(networkImpl, username, password)
	return function(store)
		return LoginRequests.logByUsername(networkImpl, username, password):andThen(
			function(result)
				-- result : {"user":{"id":698042891,"name":"Rhodium001"}}
				-- todo we need to save cookies to disk here
				return result
			end,
			function(err)
				local body = HttpService:JSONDecode(err.Body)
				-- Captcha
				if body.errors[1].code == 2 then
					local captchaUrl = string.format("%scaptcha/app/login?credentialsType=username&credentialsValue=%s",
						Url.WWW_URL, username)
					warn("open captcha validation page:\n", captchaUrl, "\n\n")
					-- todo we need to pop out a browser for captcha.
					-- GuiService:OpenBrowserWindow(captchaUrl)
				end
				return Promise.reject(err)
			end
		)
	end
end

return function(networkImpl, username, password)
	return function(store)
		return store:dispatch(login(networkImpl, username, password)):andThen(function(result)
			return store:dispatch(LaunchApp(networkImpl))
		end, function(err)
			-- login failed, should notify the reason.
		end)
	end
end