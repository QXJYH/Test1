local CorePackages = game:GetService("CorePackages")

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local NativeViewProfileWrapper = require(Modules.LuaApp.Components.NativeViewProfileWrapper)

local Url = require(Modules.LuaApp.Http.Url)
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)

local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")

local NativeViewUserProfileWrapper = Roact.PureComponent:extend("NativeViewUserProfileWrapper")

function NativeViewUserProfileWrapper:render()
	local isVisible = self.props.isVisible
	local displayOrder = self.props.DisplayOrder
	local userId = self.props.userId
	local url
	if FFlagLuaAppHttpsWebViews then
		url = UrlBuilder.user.profile({
			userId = userId
		})
	else
		url = Url:getUserProfileUrl(userId)
	end

	return Roact.createElement(NativeViewProfileWrapper, {
		isVisible = isVisible,
		DisplayOrder = displayOrder,
		url = url,
	})
end

return NativeViewUserProfileWrapper