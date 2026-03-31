return function()
	local Modules = game:GetService("CoreGui"):FindFirstChild("RobloxGui").Modules
	local SetNotificationCount = require(Modules.LuaApp.Actions.SetNotificationCount)
	local SetFriendRequestsCount = require(Modules.LuaApp.Actions.SetFriendRequestsCount)
	local SetUnreadMessageCount = require(Modules.LuaApp.Actions.SetUnreadMessageCount)
	local SetEmailNotificationCount = require(Modules.LuaApp.Actions.SetEmailNotificationCount)
	local SetPasswordNotificationCount = require(Modules.LuaApp.Actions.SetPasswordNotificationCount)
	local NotificationBadgeCounts = require(Modules.LuaApp.Reducers.NotificationBadgeCounts)

	describe("NotificationBadgeCounts", function()
		it("should all be 0 by default", function()
			local state = NotificationBadgeCounts(nil, {})

			expect(state).to.be.a("table")
			expect(state.TopBarNotificationIcon).to.equal(0)
			expect(state.MorePageMessages).to.equal(0)
			expect(state.MorePageFriends).to.equal(0)
			expect(state.MorePageEmailSettings).to.equal(0)
			expect(state.MorePagePasswordSettings).to.equal(0)
			expect(state.MorePageSettings).to.equal(0)
		end)

		it("should be unmodified by other actions", function()
			local oldState = NotificationBadgeCounts(nil, {})
			local newState = NotificationBadgeCounts(oldState, { type = "not a real action" })

			expect(oldState).to.equal(newState)
		end)

		it("should be changed using SetNotificationCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local notificationCount = 10

			state = NotificationBadgeCounts(state, SetNotificationCount(notificationCount))
			expect(state.TopBarNotificationIcon).to.equal(notificationCount)
		end)

		it("should be changed using SetFriendRequestsCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local friendRequestsCount = 20

			state = NotificationBadgeCounts(state, SetFriendRequestsCount(friendRequestsCount))
			expect(state.MorePageFriends).to.equal(friendRequestsCount)
		end)

		it("should be changed using SetUnreadMessageCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local unreadMessageCount = 10

			state = NotificationBadgeCounts(state, SetUnreadMessageCount(unreadMessageCount))
			expect(state.MorePageMessages).to.equal(unreadMessageCount)
		end)

		it("should be changed using SetEmailNotificationCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local emailNotificationCount = 1

			state = NotificationBadgeCounts(state, SetEmailNotificationCount(emailNotificationCount))
			expect(state.MorePageEmailSettings).to.equal(emailNotificationCount)
			expect(state.MorePageSettings).to.equal(emailNotificationCount)
		end)

		it("should be changed using SetPasswordNotificationCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local passwordNotificationCount = 1

			state = NotificationBadgeCounts(state, SetPasswordNotificationCount(passwordNotificationCount))
			expect(state.MorePagePasswordSettings).to.equal(passwordNotificationCount)
			expect(state.MorePageSettings).to.equal(passwordNotificationCount)
		end)

		it("MorePageSettings should be equal to MorePageEmailSettings + MorePagePasswordSettings", function()
			local state = NotificationBadgeCounts(nil, {})
			local emailNotificationCount = 1
			local passwordNotificationCount = 1

			state = NotificationBadgeCounts(state, SetEmailNotificationCount(emailNotificationCount))
			state = NotificationBadgeCounts(state, SetPasswordNotificationCount(passwordNotificationCount))
			expect(state.MorePageEmailSettings).to.equal(emailNotificationCount)
			expect(state.MorePagePasswordSettings).to.equal(passwordNotificationCount)
			expect(state.MorePageSettings).to.equal(emailNotificationCount+passwordNotificationCount)
		end)

		if settings():GetFFlag("FixCountOfUnreadNotificationError") then
			it("should not modify old state", function()
				local state = NotificationBadgeCounts(nil, {})
				local notificationCount = 0

				state = NotificationBadgeCounts(state, SetNotificationCount(notificationCount))

				local notificationCount2 = 10
				local newState = NotificationBadgeCounts(state, SetNotificationCount(notificationCount2))

				expect(newState).to.never.equal(state)
				expect(state.TopBarNotificationIcon).to.equal(notificationCount)
				expect(newState.TopBarNotificationIcon).to.equal(notificationCount2)
			end)
		end

		it("should not modify old state using SetFriendRequestsCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local friendRequestsCount = 10

			state = NotificationBadgeCounts(state, SetFriendRequestsCount(friendRequestsCount))

			local friendRequestsCount2 = 20
			local newState = NotificationBadgeCounts(state, SetFriendRequestsCount(friendRequestsCount2))

			expect(newState).to.never.equal(state)
			expect(state.MorePageFriends).to.equal(friendRequestsCount)
			expect(newState.MorePageFriends).to.equal(friendRequestsCount2)
		end)

		it("should not modify old state using SetUnreadMessageCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local unreadMessageCount = 10

			state = NotificationBadgeCounts(state, SetUnreadMessageCount(unreadMessageCount))

			local unreadMessageCount2 = 20
			local newState = NotificationBadgeCounts(state, SetUnreadMessageCount(unreadMessageCount2))

			expect(newState).to.never.equal(state)
			expect(state.MorePageMessages).to.equal(unreadMessageCount)
			expect(newState.MorePageMessages).to.equal(unreadMessageCount2)
		end)

		it("should not modify old state using SetEmailNotificationCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local emailNotificationCount = 1

			state = NotificationBadgeCounts(state, SetEmailNotificationCount(emailNotificationCount))

			local emailNotificationCount2 = 0
			local newState = NotificationBadgeCounts(state, SetEmailNotificationCount(emailNotificationCount2))

			expect(newState).to.never.equal(state)
			expect(state.MorePageEmailSettings).to.equal(emailNotificationCount)
			expect(state.MorePageSettings).to.equal(emailNotificationCount)
			expect(newState.MorePageEmailSettings).to.equal(emailNotificationCount2)
			expect(newState.MorePageSettings).to.equal(emailNotificationCount2)
		end)

		it("should not modify old state using SetPasswordNotificationCount", function()
			local state = NotificationBadgeCounts(nil, {})
			local passwordNotificationCount = 10

			state = NotificationBadgeCounts(state, SetPasswordNotificationCount(passwordNotificationCount))

			local passwordNotificationCount2 = 20
			local newState = NotificationBadgeCounts(state, SetPasswordNotificationCount(passwordNotificationCount2))

			expect(newState).to.never.equal(state)
			expect(state.MorePagePasswordSettings).to.equal(passwordNotificationCount)
			expect(state.MorePageSettings).to.equal(passwordNotificationCount)
			expect(newState.MorePagePasswordSettings).to.equal(passwordNotificationCount2)
			expect(newState.MorePageSettings).to.equal(passwordNotificationCount2)
		end)

		it("should throw if notificationCount is not a number using SetNotificationCount", function()
			expect(function()
				NotificationBadgeCounts(nil, SetNotificationCount(nil))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetNotificationCount(true))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetNotificationCount(""))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetNotificationCount({}))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetNotificationCount(function() end))
			end).to.throw()
		end)

		it("should throw if friendRequestsCount is not a number using SetFriendRequestsCount", function()
			expect(function()
				NotificationBadgeCounts(nil, SetFriendRequestsCount(nil))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetFriendRequestsCount(true))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetFriendRequestsCount(""))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetFriendRequestsCount({}))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetFriendRequestsCount(function() end))
			end).to.throw()
		end)

		it("should throw if unreadMessageCount is not a number using SetUnreadMessageCount", function()
			expect(function()
				NotificationBadgeCounts(nil, SetUnreadMessageCount(nil))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetUnreadMessageCount(true))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetUnreadMessageCount(""))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetUnreadMessageCount({}))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetUnreadMessageCount(function() end))
			end).to.throw()
		end)

		it("should throw if unreadMessageCount is not a number using SetEmailNotificationCount", function()
			expect(function()
				NotificationBadgeCounts(nil, SetEmailNotificationCount(nil))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetEmailNotificationCount(true))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetEmailNotificationCount(""))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetEmailNotificationCount({}))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetEmailNotificationCount(function() end))
			end).to.throw()
		end)

		it("should throw if accountNotificationCount is not a number using SetPasswordNotificationCount", function()
			expect(function()
				NotificationBadgeCounts(nil, SetPasswordNotificationCount(nil))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetPasswordNotificationCount(true))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetPasswordNotificationCount(""))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetPasswordNotificationCount({}))
			end).to.throw()

			expect(function()
				NotificationBadgeCounts(nil, SetPasswordNotificationCount(function() end))
			end).to.throw()
		end)
	end)


end