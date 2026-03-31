local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local AppPage = require(Modules.LuaApp.AppPage)
local BundlesWidget = require(Modules.LuaApp.Components.Home.BundlesWidget)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local AVATAR_ICON = "LuaApp/icons/avatar_profile"
local TITLE_KEY = "CommonUI.Features.Label.Avatar"

local AvatarWidget = Roact.PureComponent:extend("AvatarWidget")

function AvatarWidget:init()
	self.onActivated = function()
		self.props.navigateDown({ name = AppPage.AvatarEditor })
	end
end

function AvatarWidget:render()
	local renderWidth = self.props.renderWidth
	local bundleIds = self.props.bundleIds

	return Roact.createElement(BundlesWidget, {
		titleIcon = AVATAR_ICON,
		titleText = TITLE_KEY,
		bundleIds = bundleIds,
		renderWidth = renderWidth,
		onActivated = self.onActivated,
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local bundleIds = state.CatalogAppReducer.ChinaCatalogItems and
				state.CatalogAppReducer.ChinaCatalogItems.AvatarBundleIds or {}
		return {
			bundleIds = bundleIds,
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(AvatarWidget)