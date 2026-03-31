local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEUpdateOutfit = require(Modules.LuaApp.Actions.AEActions.AEUpdateOutfit)
local AEGetOutfit = require(Modules.LuaApp.Thunks.AEThunks.AEGetOutfit)
local FFlagAvatarEditorCostumeSignalR = settings():GetFFlag("AvatarEditorCostumeSignalR")

return function(outfitId)
	return function(store)
		if FFlagAvatarEditorCostumeSignalR then
			store:dispatch(AEUpdateOutfit(outfitId))
			store:dispatch(AEGetOutfit(outfitId))
		end
	end
end