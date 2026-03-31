local Modules = game:GetService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)
local TransitionAnimation = require(Modules.LuaApp.Enum.TransitionAnimation)

local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")

local FFlagOpenYouTubeContentInApp = settings():GetFFlag("OpenYouTubeContentInApp")

local VIDEO_OPTIONS_STR = table.concat({
	"autoplay=1",
	"controls=0",
	"modestbranding=1",
	"rel=0",
	"loop=0",
	"cc_load_policy=0",
	"playsinline=0",
}, "&")

local VIDEO_OPTIONS = {
	autoplay = 1,
	controls = 0,
	modestbranding = 1,
	rel = 0,
	loop = 0,
	cc_load_policy = 0,
	playsinline = 0,
}

return function(guiService, videoHash, videoTitle)
	return function(store)
		local videoUrl
		if FFlagLuaAppHttpsWebViews then
			videoUrl = UrlBuilder.new({
				base = "https://www.youtube.com",
				path = "/embed/{id}",
				query = VIDEO_OPTIONS,
			})({
				id = videoHash,
			})
		else
			videoUrl = string.format("https://www.youtube.com/embed/%s?%s",
				videoHash, VIDEO_OPTIONS_STR)
		end

		if FFlagOpenYouTubeContentInApp then
			local extraProps = {
				title = videoTitle,
				transitionAnimation = TransitionAnimation.SlideInFromRight,
			}

			store:dispatch(NavigateDown({
				name = AppPage.YouTubePlayer,
				detail = videoUrl,
				extraProps = extraProps,
			}))
		else
			local jsonString = HttpService:JSONEncode({
				url = videoUrl,
				title = videoTitle,
				animated = true,
			})

			guiService:BroadcastNotification(jsonString, NotificationType.OPEN_YOUTUBE_VIDEO)
		end
	end
end
