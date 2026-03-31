local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local NativePageWrapper = require(Modules.LuaApp.Components.NativePageWrapper)

return function(props)
	local isVisible = props.isVisible
	local placeId = props.placeId

	return Roact.createElement(NativePageWrapper, {
		isVisible = isVisible,
		notificationData = tostring(placeId),
		notificationType = NotificationType.VIEW_GAME_DETAILS,
	})
end
