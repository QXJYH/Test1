--[[
	Unlike RoactAnalytics, RoactAnalyticsHomePage is merely a consumer of the analytics implementation.
	It does not require its own setter to be called when the RoactServices ServiceProvider is initialized.
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules

local RoactAnalyticsCommonGameEvents = require(Modules.LuaApp.Services.RoactAnalyticsCommonGameEvents)

local FFlagLuaAppGameSetTargetIdAnalytics = settings():GetFFlag("LuaAppGameSetTargetIdAnalytics")

local HomePageAnalytics = {}
function HomePageAnalytics.get(context)
	return RoactAnalyticsCommonGameEvents.get(context, {
		pageName = "home",
		createReferralCtx = function(indexInSort, sortId, gameSetTargetId)
			local gameSetTargetIdCtx = ""
			if FFlagLuaAppGameSetTargetIdAnalytics and gameSetTargetId then
				gameSetTargetIdCtx = string.format("_GameSetTargetId<%d>", gameSetTargetId)
			end
			local context = string.format("home_SortFilter<%d>%s_Position<%d>",
				sortId,
				gameSetTargetIdCtx,
				indexInSort)
			return context
		end
	})
end

return HomePageAnalytics