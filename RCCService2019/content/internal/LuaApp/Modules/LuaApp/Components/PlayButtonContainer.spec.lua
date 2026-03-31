return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local AppPage = require(Modules.LuaApp.AppPage)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local PlayabilityStatusEnum = require(Modules.LuaApp.Enum.PlayabilityStatus)
	local PlayButtonStates = require(Modules.LuaApp.Enum.PlayButtonStates)
	local GameDetail = require(Modules.LuaApp.Models.GameDetail)
	local GameProductInfo = require(Modules.LuaApp.Models.GameProductInfo)
	local FetchGamePlayabilityAndProductInfo = require(Modules.LuaApp.Thunks.FetchGamePlayabilityAndProductInfo)
	local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)

	local PlayButtonContainer = require(Modules.LuaApp.Components.PlayButtonContainer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local testUniverseId = "10086"
	local testPlaceId = "10000"
	local testGameDetail = GameDetail.mock(testUniverseId, "name")
	testGameDetail.rootPlaceId = testPlaceId
	local testGameDetailNeedsPurchase = GameDetail.mock(testUniverseId, "name")
	testGameDetailNeedsPurchase.rootPlaceId = testPlaceId
	testGameDetailNeedsPurchase.price = 25
	testGameDetailNeedsPurchase.productId = 123
	local testProductInfoForSale = GameProductInfo.mock(testUniverseId)
	local testProductInfoNotForSale = GameProductInfo.mock(testUniverseId)
	testProductInfoNotForSale.isForSale = false

	local function mockPlayabilityStatus(isPlayable, playabilityStatus)
		return {
			isPlayable = isPlayable,
			universeId = testUniverseId,
			playabilityStatus = playabilityStatus,
		}
	end

	local propsToState = {
		[1] = { RetrievalStatus.NotStarted, RetrievalStatus.NotStarted, nil, nil, nil, PlayButtonStates.Loading },
		[2] = { RetrievalStatus.Fetching, RetrievalStatus.NotStarted, nil, nil, nil, PlayButtonStates.Loading },
		[3] = { RetrievalStatus.NotStarted, RetrievalStatus.Fetching, nil, nil, nil, PlayButtonStates.Loading },
		[4] = { RetrievalStatus.Fetching, RetrievalStatus.Fetching, nil, nil, nil, PlayButtonStates.Loading },
		[5] = { RetrievalStatus.Fetching, RetrievalStatus.Done, nil, nil, nil, PlayButtonStates.Loading },
		[6] = { RetrievalStatus.Done, RetrievalStatus.Fetching, nil, nil, nil, PlayButtonStates.Loading },
		[7] = { RetrievalStatus.Failed, RetrievalStatus.Done, nil, testGameDetail, nil, PlayButtonStates.Playable },
		[8] = { RetrievalStatus.Done, RetrievalStatus.Done,
			mockPlayabilityStatus(true, nil),
			testGameDetail, nil, PlayButtonStates.Playable },
		[9] = { RetrievalStatus.Done, RetrievalStatus.Failed,
			mockPlayabilityStatus(true, nil),
			nil, nil, PlayButtonStates.UnplayableOther },
		[10] = { RetrievalStatus.Done, RetrievalStatus.Done,
			mockPlayabilityStatus(false, PlayabilityStatusEnum.UniverseRootPlaceIsPrivate),
			testGameDetail, nil,  PlayButtonStates.Private },
		[11] = { RetrievalStatus.Done, RetrievalStatus.Done,
			mockPlayabilityStatus(false, PlayabilityStatusEnum.PurchaseRequired),
			testGameDetailNeedsPurchase, testProductInfoForSale, PlayButtonStates.PaidAccess },
		[12] = { RetrievalStatus.Done, RetrievalStatus.Done,
			mockPlayabilityStatus(false, PlayabilityStatusEnum.PurchaseRequired),
			testGameDetailNeedsPurchase, testProductInfoNotForSale, PlayButtonStates.UnplayableOther },
		[13] = { RetrievalStatus.Done, RetrievalStatus.Done,
			mockPlayabilityStatus(false, PlayabilityStatusEnum.DeviceRestricted),
			testGameDetail, nil, PlayButtonStates.UnplayableOther },
	}

	local function testPlayButtonContainer(playabilityAndPurchaseInfoFetchingStatus, gameDetailFetchingStatus,
		playabilityStatus, gameDetail, gameProductInfo, expectedState)
		local store = Rodux.Store.new(AppReducer, {
			PlayabilityStatus = {
				[testUniverseId] = playabilityStatus,
			},
			GameDetails = {
				[testUniverseId] = gameDetail,
			},
			GamesProductInfo = {
				[testUniverseId] = gameProductInfo,
			},
			FetchingStatus = {
				[ApiFetchGameDetails.KeyMapper(testUniverseId)] = gameDetailFetchingStatus,
				[FetchGamePlayabilityAndProductInfo.KeyMapper(testUniverseId)] =
					playabilityAndPurchaseInfoFetchingStatus,
			},
			Navigation = {
				history = { { { name = AppPage.GameDetail } } },
			},
		})

		local playButtonState = PlayButtonContainer.selectPlayButtonState(playabilityAndPurchaseInfoFetchingStatus,
			gameDetailFetchingStatus, playabilityStatus, gameDetail, gameProductInfo)

		expect(playButtonState).to.equal(expectedState)

		local element = mockServices({
			PlayButtonContainer = Roact.createElement(PlayButtonContainer, {
				universeId = testUniverseId,
			}),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors and be in the correct state", function()
		for _, testPropToState in ipairs(propsToState) do
			testPlayButtonContainer(unpack(testPropToState))
		end
	end)
end