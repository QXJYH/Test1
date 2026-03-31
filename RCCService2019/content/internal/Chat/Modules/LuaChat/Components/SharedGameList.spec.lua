return function()
	local SharedGameList = require(script.Parent.SharedGameList)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local FFlagLuaChatDragListTextFix = settings():GetFFlag("LuaChatDragListTextFix")

	local function createStoreWithPopularGames(games)
		local gamesInfo = {}
		local placeIds = {}
		for _, game in ipairs(games) do
			gamesInfo[game.placeId] = game
			table.insert(placeIds, game.placeId)
		end

		return Rodux.Store.new(AppReducer, {
			ChatAppReducer = {
				SharedGameSorts = {
					Popular = {
						placeIds = placeIds,
					},
				},
				SharedGamesInfo = gamesInfo,
				ShareGameToChatAsync = {
					fetchedGamesBySort = {
						Popular = true,
					},
				},
			},
		})
	end

	describe("SHOULD create and destroy without errors", function()
		it("WHEN state is loading", function()
			local element = mockServices({
				SharedGameList = Roact.createElement(SharedGameList, {
					frameHeight = 100,
					gameSort = "Popular",
				}),
			}, {
				includeStoreProvider = true,
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("WHEN state has loaded and games in the sort is undefined", function()
			local store = Rodux.Store.new(AppReducer, {
				ChatAppReducer = {
					ShareGameToChatAsync = {
						fetchedGamesBySort = {
							Popular = true,
						},
					},
				},
			})

			local element = mockServices({
				SharedGameList = Roact.createElement(SharedGameList, {
					frameHeight = 100,
					gameSort = "Popular",
				}),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("WHEN state has loaded and games are properly defined in the sort", function()
			local adoptMeId = "adopt-me-id"
			local mockGameModel = {
				imageToken = "mock-token",
				name = "😍Adopt Me!😍",
				placeId = adoptMeId,
				isPlayable = false,
				creatorName = "DreamCraft",
			}
			local store = createStoreWithPopularGames({mockGameModel})


			local element = mockServices({
				SharedGameList = Roact.createElement(SharedGameList, {
					frameHeight = 100,
					gameSort = "Popular",
				}),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			local gamesListElement = container:FindFirstChild("GamesList", true)
			expect(gamesListElement).to.be.ok()

			local sharedGameItemsCount = 0
			for _, child in pairs(gamesListElement:GetChildren()) do
				if child:IsA("GuiObject") then
					sharedGameItemsCount = sharedGameItemsCount + 1
				end
			end

			expect(sharedGameItemsCount).to.equal(1)
			Roact.unmount(instance)
		end)

		it("SHOULD show the `no games found` tip if we have 0 games", function()
			local store = createStoreWithPopularGames({})

			local element = mockServices({
				SharedGameList = Roact.createElement(SharedGameList, {
					frameHeight = 100,
					gameSort = "Popular",
				}),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			local noGamesTipInstance = container:FindFirstChild("NoGamesTip", true)
			expect(noGamesTipInstance).to.be.ok()

			Roact.unmount(instance)
		end)

		it("SHOULD not show the `no games found` tip if we more than 0 games", function()
			if (not FFlagLuaChatDragListTextFix) then
				return
			end
			local mockGameModel = {
				imageToken = "mock-token",
				name = "😍Adopt Me!😍",
				placeId = "placeId",
				isPlayable = false,
				creatorName = "DreamCraft",
			}
			local store = createStoreWithPopularGames({mockGameModel})

			local element = mockServices({
				SharedGameList = Roact.createElement(SharedGameList, {
					frameHeight = 100,
					gameSort = "Popular",
				}),
			}, {
				includeStoreProvider = true,
				store = store,
			})

			local container = Instance.new("Folder")
			local instance = Roact.mount(element, container)

			local noGamesTipInstance = container:FindFirstChild("NoGamesTip", true)
			expect(noGamesTipInstance).to.never.be.ok()

			Roact.unmount(instance)
		end)
	end)
end