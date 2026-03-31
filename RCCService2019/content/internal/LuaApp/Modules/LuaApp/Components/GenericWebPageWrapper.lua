local Modules = game:GetService("CoreGui").RobloxGui.Modules
local HttpService = game:GetService("HttpService")

local Roact = require(Modules.Common.Roact)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local TransitionAnimation = require(Modules.LuaApp.Enum.TransitionAnimation)
local mapTransitionAnimationToNativeString = require(Modules.LuaApp.mapTransitionAnimationToNativeString)
local withLocalization = require(Modules.LuaApp.withLocalization)

local NativePageWrapper = require(Modules.LuaApp.Components.NativePageWrapper)

local GenericWebPageWrapper = function(props)
	local isVisible = props.isVisible
	local displayOrder = props.DisplayOrder
	local url = props.url
	local titleKey = props.titleKey
	local title = props.title
	local transitionAnimation = props.transitionAnimation

	local transitionAnimationStr = mapTransitionAnimationToNativeString(transitionAnimation)
	assert(transitionAnimation == nil
		or transitionAnimation == TransitionAnimation.None
		or transitionAnimationStr ~= nil,
		string.format("Unhandled transition animation: %q", tostring(transitionAnimation)))

	-- Set deprecated animated flag via heuristic.
	local animated = transitionAnimation ~= TransitionAnimation.None

	if titleKey ~= nil and title == nil then
		return withLocalization({
			title = titleKey
		})(function(localized)
			local jsonString = HttpService:JSONEncode({
				url = url,
				title = localized.title,
				animated = animated,
				transitionAnimation = transitionAnimationStr,
			})

			return Roact.createElement(NativePageWrapper, {
				isVisible = isVisible,
				DisplayOrder = displayOrder,
				notificationData = jsonString,
				notificationType = NotificationType.OPEN_CUSTOM_WEBVIEW,
			})
		end)
	else
		local jsonString = HttpService:JSONEncode({
			url = url,
			title = title,
			animated = animated,
			transitionAnimation = transitionAnimationStr,
		})

		return Roact.createElement(NativePageWrapper, {
			isVisible = isVisible,
			DisplayOrder = displayOrder,
			notificationData = jsonString,
			notificationType = NotificationType.OPEN_CUSTOM_WEBVIEW,
		})
	end
end

return GenericWebPageWrapper
