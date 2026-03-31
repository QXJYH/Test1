return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local UserIconList = require(Modules.LuaApp.Components.UserIconList)
	local User = require(Modules.LuaApp.Models.User)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

	local mockUserIds = {
		"123456781",
		"123456782",
		"123456783",
		"123456784",
		"123456785",
		"123456786",
	}

	local listOfFriends = {
		User.fromData(mockUserIds[1], "Hedonism Bot", true),
		User.fromData(mockUserIds[2], "Hypno Toad", true),
		User.fromData(mockUserIds[3], "John Zoidberg", false),
		User.fromData(mockUserIds[4], "Pazuzu", true),
		User.fromData(mockUserIds[5], "Ogden Wernstrom", false),
		User.fromData(mockUserIds[6], "Lrrr", true),
	}

	local shortListOfFriends = {
		User.fromData(mockUserIds[1], "Hedonism Bot", true),
		User.fromData(mockUserIds[2], "Hypno Toad", true),
	}

	local function getMockSuccessfulRequestBodyForUserId(userId)
		return {
			targetId = tonumber(userId),
			state = "Completed",
			imageUrl = "",
		}
	end

	local mockSuccessfulRequestBody = {
		data = {
			getMockSuccessfulRequestBodyForUserId(mockUserIds[1]),
			getMockSuccessfulRequestBodyForUserId(mockUserIds[2]),
			getMockSuccessfulRequestBodyForUserId(mockUserIds[3]),
			getMockSuccessfulRequestBodyForUserId(mockUserIds[4]),
			getMockSuccessfulRequestBodyForUserId(mockUserIds[5]),
			getMockSuccessfulRequestBodyForUserId(mockUserIds[6]),
		}
	}

	local function getUserIconListElement(UserIconListArgs)
		return mockServices({
			UserIconList = Roact.createElement(UserIconList, UserIconListArgs)
		}, {
			includeStoreProvider = true,
			extraServices = {
				[RoactNetworking] = MockRequest.simpleSuccessRequest(mockSuccessfulRequestBody),
			}
		})
	end

	it("should create and destroy without errors", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 100,
			height = 30,
			users = listOfFriends,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when size is zero", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 0,
			height = 0,
			users = listOfFriends,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when no friends are passed down for display", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 100,
			height = 30,
			users = {},
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should not display numbered icon if all friends can be displayed", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 100,
			height = 30,
			users = shortListOfFriends,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("NumberedIcon", true)).to.never.be.ok()

		Roact.unmount(instance)
	end)

	it("should display numbered icon if there is one or more friends that can't fit on the footer", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 100,
			height = 30,
			users = listOfFriends,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("NumberedIcon", true)).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should display 2 avatars if the card can fit 2 circles and 2 friends are in game.", function()
		local element = getUserIconListElement({
			layoutOrder = 1,
			width = 70,
			height = 30,
			users = shortListOfFriends,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "Test")

		local numberOfUserIcons = 0
		local allChildren = container.Test:GetChildren()
		for _, child in pairs(allChildren) do
			if string.find(child.Name, "UserIcon") then
				numberOfUserIcons = numberOfUserIcons + 1
			end
		end

		expect(container.Test:FindFirstChild("NumberedIcon", false)).to.equal(nil)
		expect(numberOfUserIcons).to.equal(2)

		Roact.unmount(instance)
	end)

end