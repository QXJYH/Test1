return function()

	local HomeHeaderUserAvatar = require(script.Parent.HomeHeaderUserAvatar)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CorePackages = game:GetService("CorePackages")

	local Roact = require(Modules.Common.Roact)
	local UserModel = require(Modules.LuaApp.Models.User)
	local Constants = require(Modules.LuaApp.Constants)
	local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)

	local FFlagLuaAppMakeAvatarThumbnailTypesEnum = settings():GetFFlag("LuaAppMakeAvatarThumbnailTypesEnum")

	local function MockHomeHeaderUserAvatar()
		local localUserModel = UserModel.mock()
		local thumbnailType

		if FFlagLuaAppMakeAvatarThumbnailTypesEnum then
			thumbnailType = AvatarThumbnailTypes.HeadShot
		else
			thumbnailType = Constants.AvatarThumbnailTypes.HeadShot
		end

		return Roact.createElement(HomeHeaderUserAvatar, {
			localUserModel = localUserModel,
			thumbnailType = thumbnailType,
		})
	end

	it("should create and destroy without errors", function()
		local element = MockHomeHeaderUserAvatar()

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

end