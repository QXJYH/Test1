return function()
	local CorePackages = game:GetService("CorePackages")
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local FriendIcon = require(Modules.LuaApp.Components.FriendIcon)
	local User = require(Modules.LuaApp.Models.User)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

	local GetLuaAppUseNewAvatarThumbnailsApi = require(CorePackages.AppTempCommon.LuaApp.Flags.GetLuaAppUseNewAvatarThumbnailsApi)

	local mockIds = {
		"223456781",
		"223456782",
		"223456783",
		"223456784",
		"223456785",
		"223456786",
	}

	local inGameFriend = User.fromData(mockIds[1], "Hedonismbot", true)
	inGameFriend.presence = User.PresenceType.IN_GAME

	local onlineFriend = User.fromData(mockIds[2], "Hypno Toad", true)
	onlineFriend.presence = User.PresenceType.ONLINE

	local inStudioFriend = User.fromData(mockIds[3], "Ogden Wernstrom", true)
	inStudioFriend.presence = User.PresenceType.IN_STUDIO

	local offlineFriend = User.fromData(mockIds[4], "Pazuzu", true)
	offlineFriend.presence = User.PresenceType.OFFLINE

	local notFriend = User.fromData(mockIds[5], "John Zoidberg", false)
	notFriend.presence = User.PresenceType.ONLINE

	local noPresenceFriend = User.fromData(mockIds[6], "John Zoidberg", false)
	notFriend.presence = nil

	local function CreateBasicFriendIcon(user)
		return Roact.createElement(FriendIcon, {
			user = inGameFriend,
			dotSize = 8,
			itemSize = 24,
			layoutOrder = 0,
		})
	end

	local function getMockSuccessfulRequestBodyForUserId(userId)
		return {
			targetId = tonumber(userId),
			state = "Completed",
			imageUrl = "",
		}
	end

	local mockSuccessfulRequestBody = {
		data = {}
	}

	for _, mockId in pairs(mockIds) do
		table.insert(mockSuccessfulRequestBody.data, getMockSuccessfulRequestBodyForUserId(mockId))
	end

	local function getFriendElementOfuser(user)
		if GetLuaAppUseNewAvatarThumbnailsApi() then
			return mockServices({
				FriendIcon = CreateBasicFriendIcon(user)
			}, {
				includeStoreProvider = true,
				extraServices = {
					[RoactNetworking] = MockRequest.simpleSuccessRequest(mockSuccessfulRequestBody),
				}
			})
		else
			return mockServices({
				FriendIcon = CreateBasicFriendIcon(user)
			}, {
				includeStoreProvider = true,
			})
		end
	end

	it("should create and destroy without errors", function()
		local notFriendElement = getFriendElementOfuser(inGameFriend)
		local notFriendInstance = Roact.mount(notFriendElement)
		Roact.unmount(notFriendInstance)
	end)

	it("should create and destroy without errors on all user presence state", function()
		local inGameElement = getFriendElementOfuser(inGameFriend)
		local inGameInstance = Roact.mount(inGameElement)
		Roact.unmount(inGameInstance)

		local onlineElement = getFriendElementOfuser(onlineFriend)
		local onlineInstance = Roact.mount(onlineElement)
		Roact.unmount(onlineInstance)

		local inStudioElement = getFriendElementOfuser(inStudioFriend)
		local inStudioInstance = Roact.mount(inStudioElement)
		Roact.unmount(inStudioInstance)

		local offlineElement = getFriendElementOfuser(offlineFriend)
		local offlineInstance = Roact.mount(offlineElement)
		Roact.unmount(offlineInstance)

		local noPresenceElement = getFriendElementOfuser(noPresenceFriend)
		local noPresenceInstance = Roact.mount(noPresenceElement)
		Roact.unmount(noPresenceInstance)
	end)

	it("should create friend icon regardless of friendship", function()
		local notFriendElement = getFriendElementOfuser(notFriend)
		local notFriendInstance = Roact.mount(notFriendElement)
		Roact.unmount(notFriendInstance)
	end)

	it("should not create image label for presence indicator if user is offline or unrecognized", function()
		local friendIconElement = getFriendElementOfuser(inGameFriend)
		local container = Instance.new("Folder")
		local instance = Roact.mount(friendIconElement, container, "Test")

		expect(container.Test:FindFirstChild("FriendIcon", true)).to.equal(nil)

		Roact.unmount(instance)
	end)
end