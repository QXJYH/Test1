local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local SetNotificationCount = require(Modules.LuaApp.Actions.SetNotificationCount)

local BadgeEventReceiver = Roact.Component:extend("BadgeEventReceiver")

function BadgeEventReceiver:init()
	local setNotificationCount = self.props.setNotificationCount
	local robloxEventReceiver = self.props.RobloxEventReceiver

	self.tokens = {
		robloxEventReceiver:observeEvent("UpdateNotificationBadge", function(detail, detailType)
			--detailType will be depricated at some point
			if detailType == "NotificationIcon" then
				setNotificationCount(tonumber(detail.badgeString))
			end
		end)
	}
end

function BadgeEventReceiver:render()
end

function BadgeEventReceiver:willUnmount()
	for _, connection in pairs(self.tokens) do
		connection:disconnect()
	end
end

BadgeEventReceiver = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			setNotificationCount = function(...)
				return dispatch(SetNotificationCount(...))
			end,
		}
	end
)(BadgeEventReceiver)

return BadgeEventReceiver
