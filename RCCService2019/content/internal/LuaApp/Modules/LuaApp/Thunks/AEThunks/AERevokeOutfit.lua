local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AERevokeOutfit = require(Modules.LuaApp.Actions.AEActions.AERevokeOutfit)

return function(outfitId)
	return function(store)
		store:dispatch(AERevokeOutfit(outfitId))
	end
end