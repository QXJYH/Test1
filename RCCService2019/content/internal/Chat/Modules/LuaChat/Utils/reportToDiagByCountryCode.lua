local Modules = game:GetService("CoreGui").RobloxGui.Modules

local PercentReportingByCountryCode = tonumber(settings():GetFVariable("PercentReportingByCountryCode")) or 0
local FFlagUsingSendMeasureBatch2 = settings():GetFFlag("UsingSendMeasureBatch2")
local ReportToDiagByCountryCode = require(Modules.LuaApp.Http.Requests.ReportToDiagByCountryCode)
local WebApi = require(Modules.LuaChat.WebApi)

local function shouldReportForLocation()
	return math.random(0, 99) < PercentReportingByCountryCode
end

if FFlagUsingSendMeasureBatch2 then
	return function(featureName, measureName, seconds)
		ReportToDiagByCountryCode(featureName, measureName, seconds * 1000, PercentReportingByCountryCode)
	end
else
	return function(featureName, measureName, seconds)
		if not shouldReportForLocation() then
			return
		end

		local status = WebApi.ReportToDiagByCountryCode(featureName, measureName, seconds)
		if status ~= WebApi.Status.OK then
			warn("Failed to report ".. measureName .." to Diag")
		end
	end
end