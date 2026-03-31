return function()
	local ChallengePage = require(script.Parent.ChallengePage)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Promise = require(Modules.LuaApp.Promise)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local PerformFetch = require(CorePackages.AppTempCommon.LuaApp.Thunks.Networking.Util.PerformFetch)

	local GameDetail = require(Modules.LuaApp.Models.GameDetail)

	local testChallengeItems = {"1", "2"}
	local mockGameDetailsData = {
		[1] = GameDetail.mock("1", "mock game1"),
		[2] = GameDetail.mock("2", "mock game2"),
	}

	local mockFetchResult = {
		["data"] = mockGameDetailsData,
	}

	local function testChallengePage(dataInStore, networkImpl)
		local store = MockStore.new(dataInStore)
		local element = mockServices({
			ChallengePage = Roact.createElement(ChallengePage),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
			extraServices = {
				[RoactNetworking] = networkImpl,
			},
		})
		local instance = Roact.mount(element)
		store:flush()
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors when data is loaded", function()
		PerformFetch.ClearOutstandingPromiseStatus()

		testChallengePage({
			ChallengeItems = testChallengeItems,
		}, MockRequest.simpleSuccessRequest(mockFetchResult))

		PerformFetch.ClearOutstandingPromiseStatus()
	end)

	it("should create and destroy without errors when data is loading", function()
		PerformFetch.ClearOutstandingPromiseStatus()

		local resolvers = {}
		local networkImpl = function(url, requestMethod, options)
			return Promise.new(function(resolve, reject)
				resolvers[#resolvers + 1] = resolve
			end)
		end

		testChallengePage({
			ChallengeItems = testChallengeItems,
		}, networkImpl)

		local emptyResult = {
			responseBody = {
				data = {},
			}
		}

		for _, resolver in ipairs(resolvers) do
			resolver(emptyResult)
		end

		PerformFetch.ClearOutstandingPromiseStatus()
	end)

	it("should create and destroy without errors when data failed to load", function()
		PerformFetch.ClearOutstandingPromiseStatus()

		testChallengePage({
			ChallengeItems = testChallengeItems,
		}, MockRequest.simpleFailRequest("error"))

		PerformFetch.ClearOutstandingPromiseStatus()
	end)
end