return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local AppPage = require(Modules.LuaApp.AppPage)
	local Promise = require(Modules.LuaApp.Promise)
	local GameDetails = require(Modules.LuaApp.Components.GameDetails.GameDetails)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GameSocialLink = require(Modules.LuaApp.Models.GameSocialLink)
	local Immutable = require(Modules.Common.Immutable)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)

	local universeId = "10086"
	local function testGameDetailsPage(networkImpl)
		local store = MockStore.new({
			TopBar = {
				topBarHeight = 60,
				statusBarHeight = 20,
			},
			Navigation = {
				history = {
					{ { name = AppPage.Games } },
					{ { name = AppPage.Games }, { name = AppPage.GameDetail, detail = "123" } },
				},
				lockTimer = 0,
			}
		})

		local element = mockServices({
			GameDetails = Roact.createElement(GameDetails, {
				universeId = universeId,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			extraServices = {
				[RoactNetworking] = networkImpl,
			},
			includeAppPolicyProvider = true,
		})
		local instance = Roact.mount(element)
		-- Force the store to update right away
		store:flush()

		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors if data fetch succeeds", function()
		local mockGameDetail = GameDetail.mock(universeId, "mock game")
		local mockGameSocialLink = GameSocialLink.mock()
		local mockGameDetailsPageData = Immutable.JoinDictionaries(mockGameDetail, mockGameSocialLink)
		local mockGameDetailApiResult = {
			["data"] = { mockGameDetailsPageData }
		}

		testGameDetailsPage(MockRequest.simpleSuccessRequest(mockGameDetailApiResult))
	end)

	it("should create and destroy without errors when data fetch fails", function()
		testGameDetailsPage(MockRequest.simpleFailRequest("error"))
	end)

	it("should create and destroy without errors when data is fetching", function()
		local resolvePromise
		local networkImpl = function(url, requestMethod, options)
			return Promise.new(function(resolve, reject)
				resolvePromise = resolve
			end)
		end

		testGameDetailsPage(networkImpl)
		resolvePromise()
	end)
end
