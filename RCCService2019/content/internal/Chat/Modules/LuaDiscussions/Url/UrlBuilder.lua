local Cryo = require(game:GetService("CorePackages").Cryo)

local UriIds = {}
UriIds.__index = UriIds

function UriIds:new(ids, delimiter)
	return setmetatable({
		ids = UriIds.makeArray(ids),
		delimiter = delimiter
	}, self)
end

function UriIds:setIds(ids)
	self.ids = UriIds.makeArray(ids)
end

function UriIds.makeArray(ids)
	if type(ids) == "table" then
		return ids
	end
	return {ids}
end

function UriIds:__tostring()
	return table.concat(self.ids, self.delimiter)
end

local UrlBuilder = {}
UrlBuilder.__index = UrlBuilder

function UrlBuilder:new(baseUrl)
	return setmetatable({
		baseUrl = baseUrl,
		keyMapper = nil,
		args = {},
		pathElements = {},
		configurableIds = nil,
		idsDelimiter = ";"
	}, self)
end

function UrlBuilder:path(path)
	table.insert(self.pathElements, path)
	return self
end

function UrlBuilder:id(ids)
	self.configurableIds = UriIds:new(ids, self.idsDelimiter)
	table.insert(self.pathElements, self.configurableIds)
	return self
end

function UrlBuilder:queryArgWithIds(argName, ids)
	self.configurableIds = UriIds:new(ids, self.idsDelimiter)
	self:queryArgs({
		[argName] = self.configurableIds
	})
	return self
end

function UrlBuilder:queryArgs(args)
	self.args = Cryo.Dictionary.join(self.args, args)
	return self
end

function UrlBuilder:makeKeyMapper()
	return function(someId)
		return self:makeUrl(someId)
	end
end

function UrlBuilder:makeUri(ids)
	local fullPath = ""
	for _, element in ipairs(self.pathElements) do
		fullPath = fullPath .. "/" .. tostring(element)
	end
	return fullPath
end

function UrlBuilder:makeQueryArgs(ids)
	self:_plugInConfigurableIds(ids)
	local argsString = ""
	for k,v in pairs(self.args) do
		local arg = tostring(k) .. "=" .. tostring(v)
		if argsString:len() > 1 then
			argsString = argsString .. "&" ..arg
		else
			argsString = arg
		end
	end
	if argsString:len() > 1 then
		return "?" .. argsString
	end
	return ""
end

function UrlBuilder:makeUrl(ids)
	self:_plugInConfigurableIds(ids)
	local fullUrl = self.baseUrl .. self:makeUri(ids) .. self:makeQueryArgs(ids)
	return fullUrl
end

function UrlBuilder:_plugInConfigurableIds(ids)
	if ids ~= nil and self.configurableIds then
		self.configurableIds:setIds(ids)
	end
end

function UrlBuilder:getIds()
	if self.configurableIds and self.configurableIds.ids then
		return self.configurableIds.ids
	end
	return {}
end

return UrlBuilder
