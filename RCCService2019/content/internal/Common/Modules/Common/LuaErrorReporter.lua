--[[
	A simple observer for errors on the script context.

	By default, sends formatted error reports to the AnalyticsService.
]]
local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")
local Analytics = require(script.Parent.Analytics).new()

-- flag dependencies
local influxSeriesName = settings():GetFVariable("LuaErrorsInfluxSeries")
local influxThrottlingPercentage = tonumber(settings():GetFVariable("LuaErrorsInfluxThrottling"))
local diagCounterName = settings():GetFVariable("LuaAppsDiagErrorCounter")

-- defaults
local defaultVerboseErrors = false
local defaultShouldReportDiag = true
local defaultShouldReportGoogleAnalytics = true
local defaultShouldReportInflux = false
local defaultCurrentApp = "Unknown"
local defaultQueuedReportTotalLimit = 30

--[[
	Rate limiting controls

	Boolean flag turns system on or off. Threshold is count of how many errors trigger
	rate limiting within IntervalInSec (seconds). Counts are _reduced_ by threshold on every interval.
	Counts are capped at RATE_LIMIT_CEILING to prevent eventual number overflow and to speed up
	de-activation of rate limiting in the event that the error rate drops off.
]]
local FFlagLuaAppEnableErrorReporterRateLimit = settings():GetFFlag("LuaAppEnableErrorReporterRateLimit")
local FIntLuaAppErrorReporterRateLimitThreshold = tonumber(settings():GetFVariable("LuaAppErrorReporterRateLimitThreshold"))
local FIntLuaAppErrorReporterRateLimitIntervalInSec = tonumber(settings():GetFVariable("LuaAppErrorReporterRateLimitIntervalInSec"))

local rateLimitingDiagCounterName = settings():GetFVariable("LuaAppsDiagRateLimitedErrorsCounter")
local RATE_LIMIT_CEILING = 2 * FIntLuaAppErrorReporterRateLimitThreshold

-- string formatting functions
local function createProductName(currentApp)
	local versionString = RunService:GetRobloxVersion()
	return string.format("%s-%s", currentApp, versionString)
end

local function convertNewlinesToPipes(stack)
	local rebuiltStack = ""
	local first = true
	for line in stack:gmatch("[^\r\n]+") do
		if first then
			rebuiltStack = line
			first = false
		else
			rebuiltStack = rebuiltStack .. " | " .. line
		end
	end
	return rebuiltStack
end

local function removePlayerNameFromStack(stack)
	stack = string.gsub(stack, "Players%.[^.]+%.", "Players.<Player>.")
	return stack
end

local function printError(currentApp, message, stack, offendingScript)
	local outMessages = {
		"---- Unhandled Error Handler -----",
		string.format("Current App<%s, %d> : \n%s\n", type(currentApp), #currentApp, currentApp),
		string.format("Message<%s,%d> :\n%s\n", type(message), #message, message),
		string.format("Stack<%s,%d> :\n%s", type(stack), #stack, stack),
		string.format("Script<%s> :\n%s", type(offendingScript), offendingScript:GetFullName()),
		"----------------------------------"}

	print(table.concat(outMessages, "\n"))
end

-- analytics reporting functions
local function reportErrorToGA(currentApp, errorMsg, stack, value)
	Analytics.GoogleAnalytics:trackEvent(currentApp, errorMsg, stack, value)
end

local function reportErrorToInflux(currentApp, message, stack, offendingScript)
	local additionalArgs = {
		app = currentApp,
		err = message,
		stack = stack,
		script = offendingScript:GetFullName()
	}

	-- fire the error report
	Analytics.InfluxDb:reportSeries(influxSeriesName, additionalArgs, influxThrottlingPercentage)
end

local function reportErrorToDiag(currentApp)
	-- these reports may be broken down further based on current app
	Analytics.Diag:reportCounter(diagCounterName, 1)
end

local function reportErrorRateLimitingToDiag()
	Analytics.Diag:reportCounter(rateLimitingDiagCounterName, 1)
end

-- helper queue object
local function createErrorQueue()
	-- NOTE - if error batching other types of reports becomes more important,
	-- this object can be generalized to work for more errors, not just GA
	local ErrorQueue = {
		errors = {},
		totalErrors = 0,
		totalKeys = 0,
		countdown = defaultQueuedReportTotalLimit,
		shouldCountdown = true,
	}

	function ErrorQueue:addError(currentApp, message, stack)
		local key = string.format("%s | %s | %s", currentApp, message, stack)
		if not self.errors[key] then
			self.errors[key] = {
				app = currentApp,
				message = message,
				stack =  stack,
				value = 1 }
			self.totalKeys = self.totalKeys + 1
		else
			self.errors[key].value = self.errors[key].value + 1
		end

		self.totalErrors = self.totalErrors + 1
	end

	function ErrorQueue:isReadyToReport()
		-- NOTE - GA has limits on how many reports that it will accept at a time.
		-- According to : https://developers.google.com/analytics/devguides/config/mgmt/v3/limits-quotas
		-- the Collection API is limited to 10 queries / second per IP Address
		return self.totalKeys > 10 or
			self.totalErrors > defaultQueuedReportTotalLimit or
			self.countdown <= 0
	end

	function ErrorQueue:reportAllErrors()
		-- copy the error queue and instantly clear it out
		local errors = {}
		for k, v in pairs(self.errors) do
			errors[k] = v
		end

		self.errors = {}
		self.totalErrors = 0
		self.totalKeys = 0
		self.countdown = defaultQueuedReportTotalLimit

		-- report the errors
		for _, errData in pairs(errors) do
			reportErrorToGA(errData.app, errData.message, errData.stack, errData.value)
		end
	end

	function ErrorQueue:startTimer()
		spawn(function()
			while self.shouldCountdown do
				self.countdown = self.countdown - 1
				if self:isReadyToReport() then
					self:reportAllErrors()
				end
				wait(1.0)
			end
		end)
	end

	function ErrorQueue:stopTimer()
		self.shouldCountdown = false
	end

	return ErrorQueue
end



local LuaErrorReporter = {}
LuaErrorReporter.__index = LuaErrorReporter

-- observedSignal : the Signal to listen for errors on
-- rateLimitIntervalSec : Rate limiting interval in seconds (optional).
function LuaErrorReporter.new(observedSignal, rateLimitIntervalSec)
	-- sanitize input
	if not observedSignal then
		observedSignal = ScriptContext.Error
	end

	rateLimitIntervalSec = rateLimitIntervalSec or FIntLuaAppErrorReporterRateLimitIntervalInSec

	-- _isInstance : (boolean) simple flag to identify that this object was created with new()
	-- _verbose : (boolean) when true, prints out debug information before sending error reports
	-- _shouldReportDiag : (boolean) when true, increments a counter of total errors in Diag
	-- _shouldReportGoogleAnalytics : (boolean) when true, reports the error to GoogleAnalytics
	-- _shouldReportInflux : (boolean) when true, reports the error to InfluxDb
	-- _currentScreen : (string) the name of the screen that is currently presented to the user
	-- _signalConnectionToken : (RBXScriptConnection) a token issued when connecting to the Error signal
	-- _reportQueueGA : (ErrorQueue)
	local instance = {
		_isInstance = true,
		_verbose = defaultVerboseErrors,
		_signalConnectionToken = nil,
		_shouldReportDiag = defaultShouldReportDiag,
		_shouldReportGoogleAnalytics = defaultShouldReportGoogleAnalytics,
		_shouldReportInflux = defaultShouldReportInflux,
		_currentApp = defaultCurrentApp,
		_reportQueueGA = createErrorQueue(),
		_rateLimitingThreshold = FIntLuaAppErrorReporterRateLimitThreshold,
		_rateLimitingIntervalSec = rateLimitIntervalSec,
		_rateLimitCounts = {}, -- string ref (interned!) = count
		_rateLimitNextTick = tick() + rateLimitIntervalSec,
	}
	setmetatable(instance, LuaErrorReporter)

	-- connect a listener for errors on the provided Signal.
	instance._signalConnectionToken = observedSignal:connect(function(message, stack, offendingScript)

		-- protect against endless chains of errors when actually reporting
		local success, reportMessage = pcall(function()
			instance:handleError(message, stack, offendingScript)
		end)

		if not success then
			warn(string.format("An error occurred while reporting an error : %s", reportMessage))
		end
	end)

	-- the BindToClose function does not play nicely with Studio or TestEZ (callback fires on destroyed script).
	if not RunService:IsStudio() and not _G.__TESTEZ_RUNNING_TEST__ then
		-- BindToClose has about a 30 second timeout before the datamodel will kill any running scripts,
		-- but this function will only need to fire off, at most, 9 http requests in parallel.
		-- And since we're not binding any callbacks to these http requests, it's fine.

		-- TODO: MOBLUAPP-1823 to make BindToClose return a handle which we can use to unsubscribe.
		game:BindToClose(function()
			instance:delete()
		end)
	end

	if FFlagLuaAppEnableErrorReporterRateLimit then
		-- Rate limits error reporting to X count every Y seconds.
		instance._rateLimitHeartbeatConnectionToken = RunService.Heartbeat:connect(function()
			local currentTime = tick()
			if currentTime > instance._rateLimitNextTick then
				instance:_processRateLimitingTick()
				instance._rateLimitNextTick = currentTime + instance._rateLimitingIntervalSec
			end
		end)
	end

	return instance
end

--[[
	This function is called on intervals of _rateLimitingIntervalSec in order to
	accommodate the time component of rate limiting. The _rateLimitCounts map holds the
	counts of all recent errors that have been emitted. Each time the interval ticks over,
	we decrement the count of every error by _rateLimitingThreshold in order to maintain a
	running "rate" for that error.

	The approximate error rate for a given message+stack combo is:
		self._rateLimitCounts[errorId] / _rateLimitingIntervalSec

	When the total count exceeds _rateLimitingThreshold any time during an interval, it's
	the same as exceeding the rate limit (_rateLimitingThreshold / _rateLimitingIntervalSec).

	We cap the total count allowed for any given error to RATE_LIMIT_CEILING so that if/when
	the error rate falls off, errors can be reported again quickly instead of taking an
	inordinate amount of time for their counts to come back down. This ceiling is 2x the
	threshold in order to guarantee that minor fluctuations that would cause the error to dip
	below the threshold do not lead to smaller numbers of high rate errors being reported
	spuriously.
]]
function LuaErrorReporter:_processRateLimitingTick()
	local numberOfRateLimitedErrors = 0
	for key, count in pairs(self._rateLimitCounts) do
		if count >= self._rateLimitingThreshold then
			numberOfRateLimitedErrors = numberOfRateLimitedErrors + 1
		end

		local updatedCount = count - self._rateLimitingThreshold
		if updatedCount > RATE_LIMIT_CEILING then
			self._rateLimitCounts[key] = RATE_LIMIT_CEILING
		elseif updatedCount <= 0 then
			-- remove counts that roll off, to save memory
			self._rateLimitCounts[key] = nil
		else
			self._rateLimitCounts[key] = updatedCount
		end
	end

	if numberOfRateLimitedErrors > 0 then
		reportErrorRateLimitingToDiag()
	end
end

function LuaErrorReporter:_processErrorForRateLimiting(message, stack)
	local errorId = message .. stack -- string are interned, so don't hash
	local lastCount = self._rateLimitCounts[errorId] or 0
	self._rateLimitCounts[errorId] = lastCount + 1

	return lastCount >= self._rateLimitingThreshold
end

function LuaErrorReporter:delete()
	if self._rateLimitHeartbeatConnectionToken ~= nil then
		self._rateLimitHeartbeatConnectionToken:disconnect()
	end

	-- we're cleaning up this crash observer, disconnect from the Signal
	self._signalConnectionToken:disconnect()

	-- when the game closes down, send off all the remaining reports left in the queue
	self._reportQueueGA:reportAllErrors()
	self._reportQueueGA.shouldCountdown = false
end

-- appName : (string) the english, human readable name of the current app that is hosting the lua app
function LuaErrorReporter:setCurrentApp(appName)
	if type(appName) ~= "string" then
		error("appName must be a string")
	end

	self._currentApp = appName
end

function LuaErrorReporter:startQueueTimers()
	self._reportQueueGA:startTimer()
end

function LuaErrorReporter:stopQueueTimers()
	self._reportQueueGA:stopTimer()
end

-- message : (string) the message passed from the error() call
-- stack : (string) the stack trace
-- offendingScript : (LuaSourceContainer) the specific script that threw the error
function LuaErrorReporter:handleError(message, stack, offendingScript)
	-- NOTE - offendingScript is intended to show where in the workspace the error originated.
	-- It will not be useful for the Lua Apps as all files originate out of the ***StarterScript.lua

	-- make a descriptive name to categorize the errors under- : <currentApp>-<appV
	local productName = createProductName(self._currentApp)

	-- parse out the error message
	if self._verbose then
		printError(productName, message, stack, offendingScript)
	end

	-- sanitize some inputs
	local cleanedMessage = removePlayerNameFromStack(message)
	local cleanedStack = removePlayerNameFromStack(stack)
	cleanedStack = convertNewlinesToPipes(cleanedStack)

	-- Squelch frequent errors
	if FFlagLuaAppEnableErrorReporterRateLimit and
		self:_processErrorForRateLimiting(cleanedMessage, cleanedStack) then
		return
	end

	-- report to the appropriate sources
	if self._shouldReportGoogleAnalytics then
		self._reportQueueGA:addError(productName, cleanedMessage, cleanedStack)

		if self._reportQueueGA:isReadyToReport() then
			self._reportQueueGA:reportAllErrors()
		end
	end

	if self._shouldReportInflux then
		reportErrorToInflux(productName, cleanedMessage, cleanedStack, offendingScript)
	end

	if self._shouldReportDiag then
		reportErrorToDiag(productName)
	end
end

return LuaErrorReporter
