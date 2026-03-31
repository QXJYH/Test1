local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)

local function LaunchGame(placeId)
	local notificationType = NotificationType.LAUNCH_GAME
	local gameParams = {
		placeId = placeId
	}
	local payload = HttpService:JSONEncode(gameParams)
	GuiService:BroadcastNotification(payload, notificationType)
end

return LaunchGame