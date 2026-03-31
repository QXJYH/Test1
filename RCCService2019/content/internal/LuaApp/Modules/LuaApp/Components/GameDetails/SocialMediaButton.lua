local Modules = game:GetService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local SocialMediaType = require(Modules.LuaApp.Enum.SocialMediaType)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local Common = Modules.Common
local Roact = require(Common.Roact)

local ICONS = {
	[SocialMediaType.Twitter] = "LuaApp/icons/GameDetails/social/Twitter_large",
	[SocialMediaType.Facebook] = "LuaApp/icons/GameDetails/social/Facebook_large",
	[SocialMediaType.Discord] = "LuaApp/icons/GameDetails/social/Discord_large",
	[SocialMediaType.RobloxGroup] = "LuaApp/icons/GameDetails/social/RobloxGroup",
	[SocialMediaType.YouTube] = "LuaApp/icons/GameDetails/social/Youtube_large",
	[SocialMediaType.Twitch] = "LuaApp/icons/GameDetails/social/Twitch_large",
}

local SocialMediaButton = Roact.PureComponent:extend("SocialMediaButton")

local function getUriParams(socialType, url)
	-- Facebook needs a separate URI with a PageID to open it via native app
	-- Since we don't have that, just make it open in native browser instead
	-- Twitter uses separate URI to open it via native Twitter app
	if socialType == SocialMediaType.Twitter then
		local username = url:match("twitter.com/+([a-zA-Z0-9_]+)/*")
		if username ~= nil then
			return {
				app_uri = "twitter://user?screen_name=" .. username,
				web_uri = url,
			}
		end
	end
	return {
		app_uri = url,
		web_uri = url,
	}
end

function SocialMediaButton:init()
	self.state = {
		buttonPressed = false,
	}

	self.onInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			if not self.state.buttonPressed then
				self:setState({
					buttonPressed = true,
				})
			end
		end
	end

	self.onInputEnded = function()
		if self.state.buttonPressed then
			self:setState({
				buttonPressed = false,
			})
		end
	end

	self.onActivated = function()
		local socialType = self.props.socialType
		local socialUrl = self.props.socialUrl
		local params = getUriParams(socialType, socialUrl)
		local jsonString = HttpService:JSONEncode(params)
		self.props.guiService:BroadcastNotification(jsonString, NotificationType.OPEN_SOCIAL_MEDIA)
	end
end

function SocialMediaButton:render()
	local size = self.props.Size
	local socialType = self.props.socialType
	local layoutOrder = self.props.LayoutOrder
	local buttonPressed = self.state.buttonPressed
	local buttonTheme = self._context.AppTheme.GameDetails.SocialMediaButton

	return Roact.createElement(ImageSetButton, {
			Size = size,
			LayoutOrder = layoutOrder,
			Image = ICONS[socialType],
			ImageTransparency = buttonPressed and buttonTheme.OnPressTransparency or buttonTheme.Transparency,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = self.onActivated,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
		})
end

return RoactServices.connect({
	guiService = AppGuiService
})(SocialMediaButton)
