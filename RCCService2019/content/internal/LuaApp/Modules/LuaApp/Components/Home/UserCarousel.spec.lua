return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local User = require(Modules.LuaApp.Models.User)
	local UserCarousel = require(Modules.LuaApp.Components.Home.UserCarousel)
	local UserCarouselEntry = require(Modules.LuaApp.Components.Home.UserCarouselEntry)
	local FlagSettings = require(Modules.LuaApp.FlagSettings)

	local FFlagLuaHomePageFriendWindowing = FlagSettings.IsPeopleListV1Enabled()

	it("should create and destroy without errors", function()
		local store = Rodux.Store.new(AppReducer)

		local element = mockServices({
			userCarousel = Roact.createElement(UserCarousel, {
				friends = {
					["1"] = User.fromData(1, "Roblox", true)
				}
			})
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	if FFlagLuaHomePageFriendWindowing then
		describe("Windowing", function()
			local function GetMockStoreWithScreenSize(screenSize)
				return Rodux.Store.new(AppReducer, {
					ScreenSize = screenSize,
				})
			end

			local listOfFriends = {}
			table.insert(listOfFriends, User.fromData(1, "Hedonism Bot", true))
			table.insert(listOfFriends, User.fromData(2, "Hypno Toad", true))
			table.insert(listOfFriends, User.fromData(3, "John Zoidberg", true))
			table.insert(listOfFriends, User.fromData(4, "Pazuzu", true))
			table.insert(listOfFriends, User.fromData(5, "Ogden Wernstrom", true))
			table.insert(listOfFriends, User.fromData(6, "Lrrr", true))

			local cardWidth = UserCarouselEntry.getCardWidth()

			it("should destroy user entry when it is off screen, but re-create it once it is within range", function()
				local numberOfVisibleCards = 2
				local shellWidth = numberOfVisibleCards * cardWidth
				local mockStore = GetMockStoreWithScreenSize(Vector2.new(shellWidth, 1000))

				local function getElementWithFriends(friends)
					return mockServices({
						Shell = Roact.createElement("Frame", {
							Size = UDim2.new(0, shellWidth, 1, 0),
						}, {
							userCarousel = Roact.createElement(UserCarousel, {
								friends = listOfFriends,
								friendCount = 6,
							}),
						}),
					}, {
						includeStoreProvider = true,
						store = mockStore,
					})
				end

				local function CarouselContainsUsername(carouselContents, targetUsername)
					local carouselChildren = carouselContents:GetChildren()

					for _, child in pairs(carouselChildren) do
						if child.ClassName == "ImageButton" then
							local userEntryUsername = child:FindFirstChild("Username", true)
							if userEntryUsername and userEntryUsername.Text == targetUsername then
								return true
							end
						end
					end
					return false
				end

				local element = getElementWithFriends(listOfFriends)
				local container = Instance.new("Folder")
				local instance = Roact.mount(element, container, "Test")

				local carouselContents = container.Test:FindFirstChild("Content", true)

				expect(CarouselContainsUsername(carouselContents, listOfFriends[1].name)).to.equal(true)
				expect(CarouselContainsUsername(carouselContents, listOfFriends[#listOfFriends].name)).to.equal(false)

				carouselContents.CanvasPosition = Vector2.new(#listOfFriends * cardWidth - shellWidth, 0)

				instance = Roact.reconcile(instance, element)
				carouselContents = container.Test:FindFirstChild("Content", true)

				expect(CarouselContainsUsername(carouselContents, listOfFriends[1].name)).to.equal(false)
				expect(CarouselContainsUsername(carouselContents, listOfFriends[#listOfFriends].name)).to.equal(true)

				carouselContents.CanvasPosition = Vector2.new(0, 0)

				instance = Roact.reconcile(instance, element)
				carouselContents = container.Test:FindFirstChild("Content", true)

				expect(CarouselContainsUsername(carouselContents, listOfFriends[1].name)).to.equal(true)
				expect(CarouselContainsUsername(carouselContents, listOfFriends[#listOfFriends].name)).to.equal(false)

				Roact.unmount(instance)
				mockStore:destruct()
			end)

		end)
	end
end
