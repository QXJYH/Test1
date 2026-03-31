return function()
	local EventsPage = require(script.Parent.EventsPage)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
	local SponsoredEvent = require(Modules.LuaApp.Models.SponsoredEvent)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function testEventsPage(sponsoredEventsFetchingStatus, sponsoredEvents)
		local store = {
			FetchingStatus = {
				SponsoredEvents = sponsoredEventsFetchingStatus,
			},
			SponsoredEvents = sponsoredEvents,
		}

		local element = mockServices({
			EventsPage = Roact.createElement(EventsPage),
		}, {
			includeStoreProvider = true,
			store = store,
			includeStyleProvider = true,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end

	it("should create and destroy without errors when fetch events not started", function()
		testEventsPage(RetrievalStatus.NotStarted, {})
	end)

	it("should create and destroy without errors when fetch events loading", function()
		testEventsPage(RetrievalStatus.Fetching, {})
	end)

	it("should create and destroy without errors when fetch events succeeds", function()
		testEventsPage(RetrievalStatus.Done, {})
	end)

	it("should create and destroy without errors when fetch events succeeds with returned data", function()
		testEventsPage(RetrievalStatus.Done, SponsoredEvent.mock())
	end)

	it("should create and destroy without errors when fetch events fails", function()
		testEventsPage(RetrievalStatus.Failed, {})
	end)
end
