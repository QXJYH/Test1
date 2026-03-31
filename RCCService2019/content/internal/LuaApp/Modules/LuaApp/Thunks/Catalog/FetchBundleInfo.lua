local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CoreGui = game:GetService("CoreGui")
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local LuaApp = CoreGui.RobloxGui.Modules.LuaApp
local CatalogWebApi = require(LuaApp.Components.Catalog.CatalogWebApi)
local SetBundleInfoAction = require(LuaApp.Actions.Catalog.SetBundleInfoAction)
local Promise = require(LuaApp.Promise)
local Result = require(LuaApp.Result)
local Logging = require(CorePackages.Logging)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local function convertToId(value)
	if type(value) ~= "number" and type(value) ~= "string" then
		return Result.error("convertToId expects value passed in to be a number or a string")
	end
	return Result.success(tostring(value))
end

local function keyMapper(bundleId)
	return "luaapp.itemapi.bundlesinfo." .. tostring(bundleId)
end

return function(networkImpl, bundleIds)
	return function(store)
		ArgCheck.isType(bundleIds, "table", "FetchBundleInfo thunk expects bundleIds to be a table")
		ArgCheck.isNonNegativeNumber(#bundleIds, "FetchBundleInfo thunk expects bundleIds count to be greater than 0")
		local currentBundles = store:getState().CatalogAppReducer.Bundles
		local bundleIdsToGet = {}
		for _,bundleId in pairs(bundleIds) do
			if currentBundles[tostring(bundleId)] == nil then
				table.insert(bundleIdsToGet, bundleId)
			end
		end

		-- Don't call the webApi for thumbnails we already have
		if #bundleIdsToGet == 0 then
			return Promise.resolve("We already have the bundleIds")
		end

		return PerformFetch.Batch(bundleIds, keyMapper, function(store, filteredBundleIds)
			return CatalogWebApi.FetchBundles(networkImpl, filteredBundleIds):andThen(function(result)
				local results = {}
				for _, bundleId in ipairs(filteredBundleIds) do
					results[keyMapper(bundleId)] = Result.new(false, nil)
				end
				local bundles = {}
				local data = result and result.responseBody
				if data ~= nil then
					for _,bundleInfo in pairs(data) do
						local convertToIdResult = convertToId(bundleInfo.id)
							convertToIdResult:match(function(id)
							bundles[id] = bundleInfo
							results[keyMapper(tostring(bundleInfo.id))] = Result.new(true, nil)
						end):matchError(function(decodeError)
							warn(decodeError)
						end)
					end
					store:dispatch(SetBundleInfoAction(bundles))
				else
					Logging.warn("Response from FetchBundleInfo is malformed!")
				end
				return Promise.resolve(results)
			end,
			function(err)
				local results = {}
				for _, bundleId in ipairs(filteredBundleIds) do
					results[keyMapper(bundleId)] = Result.new(false, nil)
				end
				return Promise.resolve(results)
			end)
		end)(store)
	end
end