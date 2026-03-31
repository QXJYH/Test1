return function()
	local MorePage = require(script.Parent.MorePage)

	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppPage = require(Modules.LuaApp.AppPage)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local SponsoredEvent = require(Modules.LuaApp.Models.SponsoredEvent)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testMorePage(morePageType, sponsoredEventsFetchingStatus, sponsoredEvents)
		local store = {
			FetchingStatus = {
				SponsoredEvents = sponsoredEventsFetchingStatus,
			},
			SponsoredEvents = sponsoredEvents,
			NotificationBadgeCounts = {
				MorePageFriends = 0,
				MorePageMessages = 0,
				MorePageEmailSettings = 0,
				MorePagePasswordSettings = 0,
				MorePageSettings = 0,
			},
		}

		local element = mockServices({
			MorePage = Roact.createElement(MorePage, {
				morePageType = morePageType,
			}),
		}, {
			includeLocalizationProvider = true,
			includeStyleProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when fetch events not started", function()
		testMorePage(AppPage.More, RetrievalStatus.NotStarted, {})
		testMorePage(AppPage.SimplifiedMore, RetrievalStatus.NotStarted, {})
	end)

	it("should create and destroy without errors when fetch events loading", function()
		testMorePage(AppPage.More, RetrievalStatus.Fetching, {})
		testMorePage(AppPage.SimplifiedMore, RetrievalStatus.Fetching, {})
	end)

	it("should create and destroy without errors when fetch events succeeds", function()
		testMorePage(AppPage.More, RetrievalStatus.Done, {})
		testMorePage(AppPage.SimplifiedMore, RetrievalStatus.Done, {})
	end)

	it("should create and destroy without errors when fetch events succeeds with returned data", function()
		testMorePage(AppPage.More, RetrievalStatus.Done, SponsoredEvent.mock())
		testMorePage(AppPage.SimplifiedMore, RetrievalStatus.Done, SponsoredEvent.mock())
	end)

	it("should create and destroy without errors when fetch events fails", function()
		testMorePage(AppPage.More, RetrievalStatus.Failed, {})
		testMorePage(AppPage.SimplifiedMore, RetrievalStatus.Failed, {})
	end)
end
