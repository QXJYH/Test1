local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local StatusCodes = require(script.Parent.Parent.StatusCodes)
local Url = require(script.Parent.Parent.Url)

local FFlagUsingSendMeasureBatch2 = settings():GetFFlag("UsingSendMeasureBatch2")

if FFlagUsingSendMeasureBatch2 then
    math.randomseed(tick())
    return function(featureName, measureName, value, percentReporting)
        if 100 * math.random() > percentReporting then
            return
        end
        RbxAnalyticsService:ReportToDiagByCountryCode(featureName, measureName, value);
    end
else
    return function(featureName, measureName, value, percentReporting)

        if 100*math.random() > percentReporting then
            return
        end

        local url = string.format("%s/performance/send-measurement", Url.METRICS_URL)
        local body = HttpService:JSONEncode({
            featureName = featureName,
            measureName = measureName,
            value = value,
        })

        local CONTENT_TYPE_HEADER_KEY = "Content-Type"
        local httpRequest = HttpService:RequestInternal({
            Url = url,
            Method = "POST",
            Body = body,
            CachePolicy = Enum.HttpCachePolicy.None,
            RequestType = Enum.HttpRequestType.Analytics,
            Headers = {
                [CONTENT_TYPE_HEADER_KEY] = "application/json"
            },
        })
        httpRequest:Start(function(success, response)
            if success then
                if response.StatusCode >= StatusCodes.BAD_REQUEST then
                    warn(string.format("Reporting round trip time by country code failed with status code: %d, and response: %s",
                     response.StatusCode, response.Body))
                end
            else
                warn(string.format("Reporting round trip time by country code failed with HTTP error: %s",
                    tostring(response.HttpError)))
            end
        end)
    end
end
