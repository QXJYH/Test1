return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local GameCard = require(Modules.LuaApp.Components.Games.GameCard)
	local GameSortEntry = require(Modules.LuaApp.Models.GameSortEntry)
	local Game = require(Modules.LuaApp.Models.Game)
	local User = require(Modules.LuaApp.Models.User)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockId = require(Modules.LuaApp.MockId)

	local mockedListOfUsers = {
		["1"] = User.fromData(1, "Hedonism Bot", true),
		["2"] = User.fromData(2, "Hypno Toad", true),
		["3"] = User.fromData(3, "John Zoidberg", false),
		["4"] = User.fromData(4, "Pazuzu", true),
		["5"] = User.fromData(5, "Ogden Wernstrom", false),
		["6"] = User.fromData(6, "Lrrr", true),
	}

	local mockedListOfFriendIds = {
		"1",
		"2",
	}

	local mockedListOfNonFriendIds = {
		"3",
		"5",
	}

	it("should create and destroy without errors", function()
		local entry = GameSortEntry.mock()
		local gameModel = Game.mock()

		local store = Rodux.Store.new(AppReducer, {
			Games = { [entry.universeId] = gameModel },
		})

		local element = mockServices({
			gameCard = Roact.createElement(GameCard, {
				entry = entry,
				size = Vector2.new(60, 60),
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when a game is sponsored", function()
		local entry = GameSortEntry.mock()
		entry.isSponsored = true
		local gameModel = Game.mock()

		local store = Rodux.Store.new(AppReducer, {
			Games = { [entry.universeId] = gameModel },
		})

		local element = mockServices({
			gameCard = Roact.createElement(GameCard, {
				entry = entry,
				size = Vector2.new(60, 60),
			})
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	describe("FriendFooter", function()
		it("should not display FriendFooter by default", function()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()

			local store = Rodux.Store.new(AppReducer, {
				Games = { [entry.universeId] = gameModel },
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
				})
			}, {
				includeStoreProvider = true,
				store = store,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.never.be.ok()

			Roact.unmount(instance)
			store:destruct()
		end)

		it("should display FriendFooter when it is enabled and in-game friends exist", function()
			local mockLocalUserId = MockId()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()

			local mockStore = Rodux.Store.new(AppReducer, {
				LocalUserId = mockLocalUserId,
				Games = {
					[entry.universeId] = gameModel,
				},
				Users = mockedListOfUsers,
				InGameUsersByGame = {
					[entry.universeId] = mockedListOfFriendIds,
				},
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
					friendFooterEnabled = true,
				}),
			}, {
				includeStoreProvider = true,
				store = mockStore,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.be.ok()

			Roact.unmount(instance)
			mockStore:destruct()
		end)

		it("should not display FriendFooter when it is enabled but there are no in-game friends (empty InGameUsersByGame)", function()
			local mockLocalUserId = MockId()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()

			local mockStore = Rodux.Store.new(AppReducer, {
				LocalUserId = mockLocalUserId,
				Games = {
					[entry.universeId] = gameModel,
				},
				Users = mockedListOfUsers,
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
					friendFooterEnabled = true,
				}),
			}, {
				includeStoreProvider = true,
				store = mockStore,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.never.be.ok()

			Roact.unmount(instance)
			mockStore:destruct()
		end)

		it("should not display FriendFooter when it is enabled but there are no in-game friends (non-friends are in InGameUsersByGame)", function()
			local mockLocalUserId = MockId()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()

			local mockStore = Rodux.Store.new(AppReducer, {
				LocalUserId = mockLocalUserId,
				Games = {
					[entry.universeId] = gameModel,
				},
				Users = mockedListOfUsers,
				InGameUsersByGame = {
					[entry.universeId] = mockedListOfNonFriendIds,
				},
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
					friendFooterEnabled = true,
				}),
			}, {
				includeStoreProvider = true,
				store = mockStore,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.never.be.ok()

			Roact.unmount(instance)
			mockStore:destruct()
		end)

		it("should not display FriendFooter when it is disabled and there are in-game friends", function()
			local mockLocalUserId = MockId()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()

			local mockStore = Rodux.Store.new(AppReducer, {
				LocalUserId = mockLocalUserId,
				Games = {
					[entry.universeId] = gameModel,
				},
				Users = mockedListOfUsers,
				InGameUsersByGame = {
					[entry.universeId] = mockedListOfFriendIds,
				},
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
					friendFooterEnabled = false,
				}),
			}, {
				includeStoreProvider = true,
				store = mockStore,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.never.be.ok()

			Roact.unmount(instance)
			mockStore:destruct()
		end)

		it("should not display FriendFooter when it is enabled, but local user is in-game", function()
			local mockLocalUserId = MockId()
			local entry = GameSortEntry.mock()
			local gameModel = Game.mock()
			local mockStore = Rodux.Store.new(AppReducer, {
				LocalUserId = mockLocalUserId,
				Games = {
					[entry.universeId] = gameModel,
				},
				Users = {
					mockLocalUserId = User.fromData(1, "Hedonism Bot", false),
				},
				InGameUsersByGame = {
					[entry.universeId] = {
						mockLocalUserId,
					},
				},
			})

			local element = mockServices({
				gameCard = Roact.createElement(GameCard, {
					entry = entry,
					size = Vector2.new(60, 60),
					friendFooterEnabled = true,
				}),
			}, {
				includeStoreProvider = true,
				store = mockStore,
				includeThemeProvider = true,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container, "Test")

			expect(container.Test:FindFirstChild("FriendFooter", true)).to.never.be.ok()

			Roact.unmount(instance)
			mockStore:destruct()
		end)
	end)
end