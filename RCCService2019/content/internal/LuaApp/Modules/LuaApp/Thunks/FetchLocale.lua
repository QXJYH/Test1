local AppStorageService = game:GetService("AppStorageService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Modules = CoreGui.RobloxGui.Modules
local GetLocale = require(Modules.LuaApp.Http.Requests.GetLocale)
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)

return function(networkImpl)
	return GetLocale(networkImpl):andThen(
		function(result)
			local data = result[1]

			local signupAndLoginLocale = data.signupAndLogin.locale
			local generalExperienceLocale = data.generalExperience.locale
			local ugcLocale = data.ugc.locale
			return {
				signupAndLoginLocale = signupAndLoginLocale,
				generalExperienceLocale = generalExperienceLocale,
				ugcLocale = ugcLocale,
			}
		end
	)
end