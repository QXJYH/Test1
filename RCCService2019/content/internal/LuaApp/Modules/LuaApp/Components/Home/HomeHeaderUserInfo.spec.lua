return function()
	local HomeHeaderUserInfo = require(script.Parent.HomeHeaderUserInfo)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules

	local Roact = require(Modules.Common.Roact)
	local UserModel = require(Modules.LuaApp.Models.User)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local function MockHomeHeaderUserInfo(formFactor, membershipType)
		local localUserModel = UserModel.mock()
		localUserModel.membership = membershipType

		return mockServices({
			HomeHeaderUserInfo = Roact.createElement(HomeHeaderUserInfo, {
				localUserModel = localUserModel,
				formFactor = formFactor,
				sidePadding = 12,
				sectionPadding = 12,
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = MockHomeHeaderUserInfo(FormFactor.COMPACT, Enum.MembershipType.None)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("it should adapt to different formfactors", function()
		it("should render COMPACT formfactor properly", function()
			local element = MockHomeHeaderUserInfo(FormFactor.COMPACT, Enum.MembershipType.None)
			local container = Instance.new("Folder")
			Roact.mount(element, container, "Test")
			expect(container.Test:FindFirstChild("UserAvatar", true)).to.never.be.ok()
		end)

		it("should render WIDE formfactor properly", function()
			local element = MockHomeHeaderUserInfo(FormFactor.WIDE, Enum.MembershipType.None)
			local container = Instance.new("Folder")
			Roact.mount(element, container, "Test")
			expect(container.Test:FindFirstChild("UserAvatar", true)).to.be.ok()
		end)

		it("should render with an UNKNOWN formfactor without issues", function()
			local element = MockHomeHeaderUserInfo(FormFactor.UNKNOWN, Enum.MembershipType.None)
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)

	describe("it should properly display user membership information", function()
		describe("should hide membership info if user is not a paid member", function()
			it("COMPACT", function()
				local element = MockHomeHeaderUserInfo(FormFactor.COMPACT, Enum.MembershipType.None)
				local container = Instance.new("Folder")
				Roact.mount(element, container, "Test")
				expect(container.Test:FindFirstChild("Membership", true)).to.never.be.ok()
			end)

			it("WIDE", function()
				local element = MockHomeHeaderUserInfo(FormFactor.WIDE, Enum.MembershipType.None)
				local container = Instance.new("Folder")
				Roact.mount(element, container, "Test")
				expect(container.Test:FindFirstChild("Membership", true)).to.never.be.ok()
			end)
		end)

		describe("should display membership info if user is a paid member", function()
			it("COMPACT", function()
				local element = MockHomeHeaderUserInfo(FormFactor.COMPACT, Enum.MembershipType.BuildersClub)
				local container = Instance.new("Folder")
				Roact.mount(element, container, "Test")
				expect(container.Test:FindFirstChild("Membership", true)).to.be.ok()
			end)

			it("WIDE", function()
				local element = MockHomeHeaderUserInfo(FormFactor.WIDE, Enum.MembershipType.BuildersClub)
				local container = Instance.new("Folder")
				Roact.mount(element, container, "Test")
				expect(container.Test:FindFirstChild("Membership", true)).to.be.ok()
			end)
		end)
	end)

end
