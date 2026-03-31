return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	local UserInfoWidget = require(script.Parent.UserInfoWidget)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local UserModel = require(Modules.LuaApp.Models.User)

	local function mockUserInfoWidget(membershipType)
		local localUserModel = UserModel.mock()
		localUserModel.membership = membershipType

		return  mockServices({
				Roact.createElement(UserInfoWidget, {
					localUserModel = localUserModel,
					layoutOrder = 1,
					formFactor = FormFactor.COMPACT,
			})
		})
	end

	it("should create and destroy without errors", function()
		local element = mockUserInfoWidget(Enum.MembershipType.None)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy with builders club without errors", function()
		local element = mockUserInfoWidget(Enum.MembershipType.BuildersClub)

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end