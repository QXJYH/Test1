local GuiService = game:GetService("GuiService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEDialogFrame = require(Modules.LuaApp.Components.Avatar.UI.AEDialogFrame)
local IS_CONSOLE = GuiService:IsTenFootInterface()

return function()
	if IS_CONSOLE then
		return require(Modules.LuaApp.Components.Avatar.UI.AEConsoleDialogFrame)
	else
		return AEDialogFrame
	end
end