local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local IS_CONSOLE = GuiService:IsTenFootInterface()
local SoundManager = nil

if IS_CONSOLE then
	SoundManager = require(Modules.Shell.SoundManager)
end

local AESoundManager = {}
AESoundManager.__index = AESoundManager

function AESoundManager:Play(name)
	if IS_CONSOLE then
		SoundManager:Play(name)
	end
end

return AESoundManager