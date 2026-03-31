return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local UserTile = require(script.Parent.UserTile)
	local User = require(Modules.LuaApp.Models.User)

	local UserModel = require(Modules.LuaApp.Models.User)

	it("should create and destroy without errors", function()
		local element = mockServices({
				Roact.createElement(UserTile, {
				user = UserModel.mock(),
				thumbnailSize = 80,
				width = 80,
				height = 105,
				layoutOrder = 1,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy with presence without errors", function()
		local user = UserModel.mock()
		user.presence = User.PresenceType.Online
		local element = mockServices({
				Roact.createElement(UserTile, {
				user = UserModel.mock(),
				thumbnailSize = 80,
				width = 80,
				height = 105,
				layoutOrder = 1,
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end