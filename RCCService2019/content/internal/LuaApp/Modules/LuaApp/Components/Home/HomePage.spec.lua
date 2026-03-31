return function()
	local HomePage = require(script.Parent.HomePage)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local AddUser = require(Modules.LuaApp.Actions.AddUser)
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)
	local SetLocalUserId = require(Modules.LuaApp.Actions.SetLocalUserId)
	local SetUserMembershipType = require(Modules.LuaApp.Actions.SetUserMembershipType)
	local SetHomePageDataStatus = require(Modules.LuaApp.Actions.SetHomePageDataStatus)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local User = require(Modules.LuaApp.Models.User)
	local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

	local function MockStore(eachUserIsFriend, membership, dataStatus)
		local store = Rodux.Store.new(AppReducer)
		if eachUserIsFriend then
			for i, isFriend in ipairs(eachUserIsFriend) do
				store:dispatch(AddUser(User.fromData(i, "User " .. i, isFriend)))
			end
		end
		local localUser = User.mock()
		store:dispatch(AddUser(localUser))
		store:dispatch(SetLocalUserId(localUser.id))
		store:dispatch(SetHomePageDataStatus(dataStatus or RetrievalStatus.Done))
		if membership then
			store:dispatch(SetUserMembershipType(localUser.id, membership))
		else
			store:dispatch(SetUserMembershipType(localUser.id, Enum.MembershipType.None))
		end
		return store
	end

	local function MockHomepage(store)
		return mockServices({
			HomePage = Roact.createElement(HomePage),
		}, {
			includeStoreProvider = true,
			store = store,
			includeThemeProvider = true,
			includeAppPolicyProvider = true,
		})
	end

	it("should create and destroy without errors", function()
		local store = MockStore()
		local element = MockHomepage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when data is loading", function()
		local store = MockStore(nil, nil, RetrievalStatus.Fetching)
		local element = MockHomepage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when there's no data", function()
		local store = MockStore(nil, nil, RetrievalStatus.Failed)
		local element = MockHomepage(store)
		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should show the friends section if there are friends", function()
		local store = MockStore({false, true, true})
		local element = MockHomepage(store)
		local container = Instance.new("Folder")
		Roact.mount(element, container, "Test")
		expect(container.Test:FindFirstChild("FriendSection", true)).to.be.ok()
		store:destruct()
	end)

	it("should show the membership icon if the local user has membership", function()
		local store = MockStore(nil, Enum.MembershipType.BuildersClub)
		local element = MockHomepage(store)
		local container = Instance.new("Folder")
		Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("Membership", true)).to.be.ok()

		store:destruct()
	end)

	it("should hide the membership icon if the local user does not have membership", function()
		local store = MockStore()
		local element = MockHomepage(store)
		local container = Instance.new("Folder")
		Roact.mount(element, container, "Test")

		expect(container.Test:FindFirstChild("Membership", true)).to.never.be.ok()
		store:destruct()
	end)
end
