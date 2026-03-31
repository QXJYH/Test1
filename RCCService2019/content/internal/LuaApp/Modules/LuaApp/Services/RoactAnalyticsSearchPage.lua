local Modules = game:GetService("CoreGui").RobloxGui.Modules

local RoactAnalyticsCommonGameEvents = require(Modules.LuaApp.Services.RoactAnalyticsCommonGameEvents)

local FFlagLuaAppGameSetTargetIdAnalytics = settings():GetFFlag("LuaAppGameSetTargetIdAnalytics")

local SearchPageAnalytics = {}

function SearchPageAnalytics.get(context)
	return RoactAnalyticsCommonGameEvents.get(context, {
		pageName = "gameSearch",
		createReferralCtx = function(indexInSort, sortId, gameSetTargetId, timeFilter, genreFilter)
			local gameSetTargetIdCtx = ""
			if FFlagLuaAppGameSetTargetIdAnalytics and gameSetTargetId then
				gameSetTargetIdCtx = string.format("_GameSetTargetId<%d>", gameSetTargetId)
			end
			local context = string.format("gamesort_SortFilter<%d>%s_TimeFilter<%d>_GenreFilter<%d>_Position<%d>",
				sortId,
				gameSetTargetIdCtx,
				timeFilter,
				genreFilter,
				indexInSort)
			return context
		end
	})
end

return SearchPageAnalytics