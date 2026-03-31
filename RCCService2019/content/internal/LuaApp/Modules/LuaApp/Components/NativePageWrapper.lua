local HttpService = game:GetService("HttpService")
local CorePackages = game:GetService("CorePackages")

local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local Constants = require(Modules.LuaApp.Constants)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local TopBar = require(Modules.LuaApp.Components.TopBar)
local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local ScreenGuiWithBlurControl = require(Modules.LuaApp.Components.ScreenGuiWithBlurControl)

local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()


local function IsRunningInStudio()
	return game:GetService("RunService"):IsStudio()
end

local NativePageWrapper = Roact.PureComponent:extend("NativePageWrapper")

NativePageWrapper.defaultProps = {
	DisplayOrder = 0,
}

function NativePageWrapper:init()
	self:broadcastNotification()
end

function NativePageWrapper:render()
	local isVisible = self.props.isVisible
	local notificationData = self.props.notificationData
	local displayOrder = ArgCheck.isNonNegativeNumber(self.props.DisplayOrder, "NativePageWrapper:DisplayOrder")

	local renderFunction = function(stylePalette)
		local backgroundColor = Constants.Color.GRAY1
		local backgroundTransparency = 0.5
		if stylePalette then
			backgroundColor = stylePalette.Theme.Overlay.Color
			backgroundTransparency = stylePalette.Theme.Overlay.Transparency
		end
		if not IsRunningInStudio() then
			return Roact.createElement(FFlagLuaAppEnablePageBlur and ScreenGuiWithBlurControl or "ScreenGui", {
				Enabled = isVisible,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = displayOrder,
			}, {
				Background = Roact.createElement(FullscreenPageWithSafeArea, {
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = backgroundTransparency,
				}),
			})
		end

		local success, data = pcall(function() return HttpService:JSONDecode(notificationData) end)
		local titleText = (success and data) and data.title or self.props.titleText

		local studioBackgroundColor = Constants.Color.GRAY4
		local studioBackgroundTransparency = 0.5
		if stylePalette then
			studioBackgroundColor = stylePalette.Theme.BackgroundDefault.Color
			studioBackgroundTransparency = stylePalette.Theme.BackgroundDefault.Transparency
		end
		return Roact.createElement(FFlagLuaAppEnablePageBlur and ScreenGuiWithBlurControl or "ScreenGui", {
			Enabled = isVisible,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = displayOrder,
		}, {
			Background = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = studioBackgroundColor,
				BackgroundTransparency = studioBackgroundTransparency,
				ZIndex = 1,
			}),
			TopBar = Roact.createElement(TopBar, {
				titleText = titleText,
				showBuyRobux = false,
				showNotifications = false,
				showSearch = false,
				ZIndex = 2,
			}),
		})
	end
	if useNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction(nil)
	end
end

function NativePageWrapper:didUpdate(prevProps)
	if not prevProps.isVisible then
		self:broadcastNotification()
	end
end

function NativePageWrapper:broadcastNotification()
	local isVisible = self.props.isVisible
	local notificationData = self.props.notificationData
	local notificationType = self.props.notificationType
	local guiService = self.props.guiService

	if isVisible then
		guiService:BroadcastNotification(notificationData, notificationType)
	end
end

NativePageWrapper = RoactServices.connect({
	guiService = AppGuiService,
})(NativePageWrapper)

return NativePageWrapper
