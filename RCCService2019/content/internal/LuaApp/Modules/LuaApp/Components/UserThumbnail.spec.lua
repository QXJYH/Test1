return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local User = require(Modules.LuaApp.Models.User)
	local UserThumbnail = require(Modules.LuaApp.Components.UserThumbnail)
	local FlagSettings = require(Modules.LuaApp.FlagSettings)

	local FFUseAssetsWithBorderForPresence = FlagSettings.IsUseAssetsWithBorderForPresenceEnabled()

	it("should create and destroy without errors", function()
		local element = Roact.createElement(UserThumbnail, {
			measurements = {
				THUMBNAIL_SIZE = 90,
				DROPSHADOW_SIZE = 98,

				USERNAME = {
					TEXT_LINE_HEIGHT = 20,
					TEXT_FONT_SIZE = 18,
					TEXT_TOP_PADDING = 3,
				},

				PRESENCE = {
					TEXT_TOP_PADDING = 3,
					TEXT_LINE_HEIGHT = 20,
					TEXT_FONT_SIZE = 15,

					ICONS = {
						[User.PresenceType.ONLINE] = "",
						[User.PresenceType.IN_GAME] = "",
						[User.PresenceType.IN_STUDIO] = "",
					},

					DROPSHADOW_MARGIN = 0,
					BORDER_DIAMETER = 14,
					ICON_OFFSET = 5,
					ICON_SIZE = 24,
				},

				PRESENCE_TEXT_HEIGHT = 0
			},
			user = User.mock()
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy correct presence thumbnail without errors", function()
		local measurements = {
			PRESENCE = {
				TEXT_FONT_SIZE = 15,
				TEXT_LINE_HEIGHT = 15,
				TEXT_TOP_PADDING = 3,

				ICONS = {
					[User.PresenceType.ONLINE] = "LuaApp/graphic/gr-indicator-online",
					[User.PresenceType.IN_GAME] = "LuaApp/graphic/gr-indicator-instudio",
					[User.PresenceType.IN_STUDIO] = "LuaApp/graphic/gr-indicator-ingame",
				},

				BORDER_DIAMETER = 14,
				ICON_OFFSET = 5,
				ICON_SIZE = 24,
			}
		}
		local presenceIcon = UserThumbnail.makeUserPresenceIcon(measurements, User.PresenceType.ONLINE)
		local container = Instance.new("Folder")
		local instance = Roact.mount(presenceIcon, container, "testMount")
		expect(container:FindFirstChild("testMount").ClassName).to.equal("ImageLabel")

		local children = container:FindFirstChild("testMount"):GetChildren()

		if FFUseAssetsWithBorderForPresence then
			expect(#children).to.equal(0)
		else
			expect(#children).to.equal(1)
			expect((children[1]).ClassName).to.equal("ImageLabel")
		end

		Roact.unmount(instance)
	end)

	it("should not create presence element when user offline", function()
		local measurements = {
			PRESENCE = {
				TEXT_FONT_SIZE = 15,
				TEXT_LINE_HEIGHT = 15,
				TEXT_TOP_PADDING = 3,

				ICONS = {
					[User.PresenceType.ONLINE] = "LuaApp/graphic/gr-indicator-online",
					[User.PresenceType.IN_GAME] = "LuaApp/graphic/gr-indicator-instudio",
					[User.PresenceType.IN_STUDIO] = "LuaApp/graphic/gr-indicator-ingame",
				},

				BORDER_DIAMETER = 14,
				ICON_OFFSET = 5,
				ICON_SIZE = 24,
			}
		}
		local presenceIcon = UserThumbnail.makeUserPresenceIcon(measurements, User.PresenceType.OFFLINE)
		if FFUseAssetsWithBorderForPresence then
			expect(presenceIcon).to.equal(nil)
		else
			expect(presenceIcon).to.be.ok()
		end
	end)
end
