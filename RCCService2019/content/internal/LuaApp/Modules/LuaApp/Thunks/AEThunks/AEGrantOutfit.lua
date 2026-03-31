local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEGrantOutfit = require(Modules.LuaApp.Actions.AEActions.AEGrantOutfit)
local AEGetOutfit = require(Modules.LuaApp.Thunks.AEThunks.AEGetOutfit)

return function(outfitId)
	return function(store)
		store:dispatch(AEGrantOutfit(outfitId))
		store:dispatch(AEGetOutfit(outfitId))
	end
end