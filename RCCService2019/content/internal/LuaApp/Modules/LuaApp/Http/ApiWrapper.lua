
local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local Cryo = require(CorePackages.Cryo)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)

local NULLTOKEN = "##NULL##TOKEN##"

local ApiWrapper = {}

local function mapValues(obj, cb)
	local result = {}
	for name, value in pairs(obj) do
		result[name] = cb(value, name)
	end
	return result
end

local function transformInput(input, specs)
	if type(specs._collectionFormat) ~= "table" then
		return input
	end
	return mapValues(input, function(value, name)
		if specs._collectionFormat[name] == "csv" then
			return table.concat(value, ",")
		end

		return value
	end)
end

local function getBody(input, specs)
	local result

	if type(specs) == "table" then
		result = {}
		for _, name in ipairs(specs) do
			result[name] = input[name]
			if result[name] == nil then
				result[name] = NULLTOKEN
			end
		end
	elseif type(specs) == "string" then
		result = input[specs]
	else
		return nil
	end

	result = HttpService:JSONEncode(result)
	result = string.gsub(result, "\"" .. NULLTOKEN .. "\"", "null")
	return result
end

function ApiWrapper.endpoint(specs, definitions)
	return function(requestImpl, input)
		ArgCheck.matchesInterface(input, specs.input, "input", definitions)
		input = transformInput(input, specs.input)
		local url = UrlBuilder.fromString(specs.url)(input)
		local options = {}
		if specs.body then
			options.postBody = getBody(input, specs.body)
		end
		return requestImpl(url, specs.method, options):andThen(function(output)
			ArgCheck.matchesInterface(output.responseBody, specs.output, "output", definitions)
			return output
		end)
	end
end

function ApiWrapper.new(specs)
	local definitions = specs.definitions;

	return mapValues(specs.endpoints, function(endpoint)
		return ApiWrapper.endpoint(endpoint, definitions)
	end)
end

return ApiWrapper
