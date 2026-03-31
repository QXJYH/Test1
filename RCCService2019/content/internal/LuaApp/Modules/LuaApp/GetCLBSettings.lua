local HttpService = game:GetService("HttpService")
local CorePackages = game:GetService("CorePackages")
local Logging = require(CorePackages.Logging)

local function splitFStringToList(fstring)
	local listOfIds = {}

	local success, body = pcall(function()
		return HttpService:JSONDecode(fstring)
	end)

	if success then
		listOfIds = body
		for index, _ in ipairs(listOfIds) do
			listOfIds[index] = tostring(listOfIds[index])
		end
	else
		Logging.warn(string.format("JSONDecode for string \"%s\" failed!", fstring))
	end

	return listOfIds
end

local FStringCLBLuaAppChallengeItems = settings():GetFVariable("CLBLuaAppChallengeItems")
local challengeItems = splitFStringToList(FStringCLBLuaAppChallengeItems)

local GetCLBSettings = {}

function GetCLBSettings.GetChallengeItems()
	return challengeItems
end

return GetCLBSettings
