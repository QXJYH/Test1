local HttpService = game:GetService("HttpService")
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = CorePackages.AppTempCommon.LuaApp

local Promise = require(LuaApp.Promise)
local NetworkProfiler = require(LuaApp.NetworkProfiler)
local StatusCode = require(Modules.LuaApp.Http.StatusCodes)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local HttpCanceller = require(script.Parent.HttpCanceller)

local CONTENT_TYPE_HEADER_KEY = "Content-Type"
local DEFAULT_TIMEOUT = 15000
local DEFAULT_MAX_RETRY_COUNT = 4
local DEFAULT_PRIORITY = 0
local DEFAULT_CACHE_POLICY = Enum.HttpCachePolicy.None
local MAX_RETRY_AFTER_VALUE_ACCEPTED = 16

local RETRY_ON_STATUS_CODE = {
	[StatusCode.REQUEST_TIMEOUT] = true,
	[StatusCode.SERVICE_UNAVAILABLE] = true,
	[StatusCode.GATEWAY_TIMEOUT] = true,
}

local restrictLuaAppRetriesByStatusCode = settings():GetFFlag("RestrictLuaAppRetriesByStatusCode")

local RequestInternalWrapper = {}
RequestInternalWrapper.__index = RequestInternalWrapper

function RequestInternalWrapper.new(requestService, url, requestMethod, options)
	local self = {
		resolve = nil,
		reject = nil,
		retryCount = 0,
		maxRetryCount = options and options.maxRetryCount or DEFAULT_MAX_RETRY_COUNT,
		httpRequest = nil,
		canceled = false,
		requestService = requestService,
		session = FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() and HttpCanceller.currentSession() or nil,
	}

	self.internalOptions = {
		Url = url,
		Method = requestMethod and requestMethod or "GET",
		Body = options and options.postBody or nil,
		Timeout = options and options.timeout or DEFAULT_TIMEOUT,
		CachePolicy = options and options.cachePolicy or DEFAULT_CACHE_POLICY,
		Priority = options and options.priority or DEFAULT_PRIORITY,
		Headers = options and options.headers or nil,
		RequestType = options and options.requestType or nil,
	}
	if (requestMethod == "POST" or requestMethod == "PATCH")
		and (self.internalOptions["Headers"] == nil
			or self.internalOptions["Headers"][CONTENT_TYPE_HEADER_KEY] == nil) then
		self.internalOptions["Headers"] = self.internalOptions["Headers"] or {}
		self.internalOptions["Headers"][CONTENT_TYPE_HEADER_KEY] = "application/json"
	end

	setmetatable(self, RequestInternalWrapper)
	return self
end

function RequestInternalWrapper:start(resolve, reject)
	self.resolve = resolve
	self.reject = reject
	self:makeRequest()
end

function RequestInternalWrapper:processResponse(response)
	local okay, result = pcall(HttpService.JSONDecode, HttpService, response.Body)

	if not okay then
		self.reject({HttpError = Enum.HttpError.OK, isJSONValid = false})
	else
		local responseTimeMs
		if settings():GetFFlag("TrackCurlTimeProfile") then
			NetworkProfiler:track({
				queued = response.Stats.DurationInQueue,
				nameLookup = response.Stats.DurationNameLookup,
				connect = response.Stats.DurationConnect,
				sslHandshake = response.Stats.DurationSSLHandshake,
				makeRequest = response.Stats.DurationMakeRequest,
				receiveResponse = response.Stats.DurationReceiveResponse,
			})
			responseTimeMs = response.Stats.RoundTripTime*1000
		else
			responseTimeMs = response.RoundTripTime*1000
		end
		local shimmedResponse  = {
				responseCode = response.StatusCode,
				requestUrl = self.internalOptions.Url,
				responseTimeMs = responseTimeMs,
				isJSONValid = true,
				result,
				responseBody = result,
		}
		self.resolve(shimmedResponse)
	end
end

function RequestInternalWrapper:retry(lastResponse, waitTime)
	self.retryCount = self.retryCount + 1
	if self.retryCount > self.maxRetryCount then
		self.reject(lastResponse)
		return
	end

	waitTime = waitTime or math.pow(2, self.retryCount)

	delay(waitTime, function()
		self:makeRequest()
	end)
end

function RequestInternalWrapper:makeRequest()
	if self.canceled then
		return
	end
	self.httpRequest = self.requestService:RequestInternal(self.internalOptions)
	self.httpRequest:Start(function(success, response)
		if FlagSettings.EnableLuaAppLoginPageForUniversalAppDev() then
			if self.session ~= HttpCanceller.currentSession() then
				warn("Http request aborted", self.internalOptions.Url)
				return
			end
		end
		if success then
			if restrictLuaAppRetriesByStatusCode then
				if response.StatusCode >= 200 and response.StatusCode < 400 then
					self:processResponse(response)
				elseif RETRY_ON_STATUS_CODE[response.StatusCode] then
					self:retry(response)
				elseif response.StatusCode == StatusCode.TOO_MANY_REQUESTS  and response.Headers["Retry-After"] then
					local waitTime = tonumber(response.Headers["Retry-After"])
					if waitTime ~= nil and waitTime <= MAX_RETRY_AFTER_VALUE_ACCEPTED then
						self:retry(response, waitTime)
					else
						self.reject(response)
					end
				else
					self.reject(response)
				end
			else
				if response.StatusCode >= 200 and response.StatusCode < 400 then
					self:processResponse(response)
				else
					self:retry(response)
				end
			end
		elseif not self.canceled then
			self:retry({HttpError = response.HttpError})
		end
	end)
end

function RequestInternalWrapper:cancel()
	self.canceled = true
	self.reject({HttpError = Enum.HttpError.Aborted})
	if self.httpRequest then
		self.httpRequest:Cancel()
	end
end

return function(requestService)
	if not requestService then
		requestService = HttpService
	end
	return function(url, requestMethod, options)

		local requestWrapper = RequestInternalWrapper.new(requestService, url, requestMethod, options)

		local httpPromise = Promise.new(function(resolve, reject)
			requestWrapper:start(resolve, reject)
		end)

		local function cancel()
			requestWrapper:cancel()
		end

		return httpPromise, cancel
	end
end