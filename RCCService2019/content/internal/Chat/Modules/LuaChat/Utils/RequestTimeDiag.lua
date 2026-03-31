local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp

local ReportToDiagByCountryCode = require(LuaApp.Http.Requests.ReportToDiagByCountryCode)

local RequestTimeDiag = {}
RequestTimeDiag.__index = RequestTimeDiag

function RequestTimeDiag:new(metricName)
	assert(metricName, "metricName is required")
	return setmetatable({
		metricName = metricName,
		startTime = tick()
	}, self)
end

function RequestTimeDiag:report()
	local endTime = tick()
	local elapsedTime = endTime - self.startTime
	ReportToDiagByCountryCode(
		self.metricName,
		"RoundTripTime",
		elapsedTime,
		100
	)
end

return RequestTimeDiag
