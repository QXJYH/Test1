--[[
	A fake notification service for faking Notifications for tests
]]

local mockNotificationService = {}
mockNotificationService.__index = mockNotificationService

function mockNotificationService.ScheduleNotification(userId, alertId, alertMsg, minutesToFire)
end

function mockNotificationService.CancelNotification(userId, alertId)
end

function mockNotificationService.CancelAllNotification(userId)
end

function mockNotificationService.GetScheduledNotifications(userId)
end

function mockNotificationService.ActionEnabled(actionType)
end

function mockNotificationService.ActionTaken(actionType)
end

function mockNotificationService.new()
	local mns = {}
	setmetatable(mns, mockNotificationService)

	mns.RobloxEventReceived = {
		BindableEvent = Instance.new("BindableEvent")
	}

	mns.RobloxConnectionChanged = {
		BindableEvent = Instance.new("BindableEvent")
	}

	function mns.RobloxEventReceived:Connect(callback)
		return mns.RobloxEventReceived.BindableEvent.Event:Connect(callback)
	end

	function mns.RobloxEventReceived:Fire(event)
		mns.RobloxEventReceived.BindableEvent:Fire(event)
	end

	function mns.RobloxConnectionChanged:Connect(callback)
		return mns.RobloxConnectionChanged.BindableEvent.Event:Connect(callback)
	end

	function mns.RobloxConnectionChanged:Fire(event)
		mns.RobloxConnectionChanged.BindableEvent:Fire(event)
	end

	function mns.RobloxConnectionChanged:Connect(callback)
		return mns.RobloxConnectionChanged.BindableEvent.Event:Connect(callback)
	end

	function mns.RobloxConnectionChanged:Fire(connectionName, connectionState, sequenceNumber)
		mns.RobloxConnectionChanged.BindableEvent:Fire(connectionName, connectionState, sequenceNumber)
	end

	return mns
end

return mockNotificationService