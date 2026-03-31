local CorePackages = game:GetService("CorePackages")

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local NativePageWrapper = require(Modules.LuaApp.Components.NativePageWrapper)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local withLocalization = require(Modules.LuaApp.withLocalization)

local NativeViewProfileWrapper = Roact.PureComponent:extend("NativeViewProfileWrapper")

local PAGE_TITLE = "CommonUI.Features.Label.Profile"

function NativeViewProfileWrapper:render()
	local isVisible = self.props.isVisible
	local displayOrder = self.props.DisplayOrder
	local url = self.props.url

	local renderFunction = function(localized)
		return Roact.createElement(NativePageWrapper, {
			titleText = localized.titleText,
			isVisible = isVisible,
			DisplayOrder = displayOrder,
			notificationData = url,
			notificationType = NotificationType.VIEW_PROFILE,
		})
	end

	return withLocalization({
		titleText = PAGE_TITLE,
	})(function(localizedStrings)
		return renderFunction(localizedStrings)
	end)
end

return NativeViewProfileWrapper