local UserInputService = game:GetService("UserInputService")
local RobloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")

local function initRhodium()
	local TestLuaMobileApp = require(RobloxGui.Modules.RhodiumTest.LuaApp.TestLuaMobileApp)
	local RemoteRhodium = require(RobloxGui.Modules.Rhodium.RemoteRhodium)
	RemoteRhodium.setCommandPath(RobloxGui.Modules.RhodiumTest.LuaApp.Actions)

	-- Run Rhodium test when ctrl+shift+alt+R is pressed
	UserInputService.InputEnded:connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Keyboard and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
			UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
		then
			if input.KeyCode == Enum.KeyCode.R then
				TestLuaMobileApp()
			end
		end
	end)
end

local success, errMessage = pcall(initRhodium)
if not success then
	warn(errMessage)
end