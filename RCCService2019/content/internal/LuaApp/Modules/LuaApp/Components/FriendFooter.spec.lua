return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local FriendFooter = require(Modules.LuaApp.Components.FriendFooter)
	local User = require(Modules.LuaApp.Models.User)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockId = require(Modules.LuaApp.MockId)
	local AppReducer = require(Modules.LuaApp.AppReducer)

	local dummyUniverseId = MockId()
	local storeWithDummyFriends = Rodux.Store.new(AppReducer, {
		Users = {
			["1"] = User.fromData(1, "Hedonism Bot", true),
			["2"] = User.fromData(2, "Hypno Toad", true),
			["3"] = User.fromData(3, "John Zoidberg", false),
			["4"] = User.fromData(4, "Pazuzu", true),
			["5"] = User.fromData(5, "Ogden Wernstrom", false),
			["6"] = User.fromData(6, "Lrrr", true),
		},
		InGameUsersByGame = {
			[dummyUniverseId] = {
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
			},
		},
	})

	local function getFriendFooterElement(friendFooterProps, mockStore)
		return mockServices({
			Frame = Roact.createElement("Frame", {
				Size = UDim2.new(0, 100, 0, 30),
			}, {
				FriendFooter = Roact.createElement(FriendFooter, friendFooterProps),
			}),
		}, {
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = mockStore,
		})
	end

	it("should create and destroy without errors", function()
		local element = getFriendFooterElement({
			universeId = dummyUniverseId,
			innerMargin = 8,
			outerMargin = 8,
			titleTextSize = 8,
			footerContentWidth = 8,
			footerContentHeight = 8,
		}, storeWithDummyFriends)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when the store is empty", function()
		local element = getFriendFooterElement({
			universeId = dummyUniverseId,
			innerMargin = 8,
			outerMargin = 8,
			titleTextSize = 8,
			footerContentWidth = 8,
			footerContentHeight = 8,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no props are passed down other than universeId", function()
		local element = getFriendFooterElement({
			universeId = dummyUniverseId,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)



	it("should throw when universeId is not properly passed down", function()
		-- universeId is nil
		local element = getFriendFooterElement({
			innerMargin = 8,
			outerMargin = 8,
			titleTextSize = 8,
			footerContentWidth = 8,
			footerContentHeight = 8,
		}, storeWithDummyFriends)
		expect(function() Roact.mount(element) end).to.throw()

		-- universeId is not string
		element = getFriendFooterElement({
			unierseId = 1234,
			innerMargin = 8,
			outerMargin = 8,
			titleTextSize = 8,
			footerContentWidth = 8,
			footerContentHeight = 8,
		}, storeWithDummyFriends)
		expect(function() Roact.mount(element) end).to.throw()
	end)

end