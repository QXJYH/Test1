local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)
local memoize = require(Modules.Common.memoize)

local BundlesWidget = require(Modules.LuaApp.Components.Home.BundlesWidget)

local CatalogWidget = Roact.PureComponent:extend("CatalogWidget")

local CATALOG_ICON = "LuaApp/icons/Catalog"

local TITLE_KEY = "CommonUI.Features.Label.Catalog"

local ICON_COUNT = 5

function CatalogWidget:init()
	self.onActivated = function()
		self.props.navigateDown({ name = AppPage.ChinaCatalog })
	end
end

function CatalogWidget:render()
	local renderWidth = self.props.renderWidth
	local bundleIds = self.props.bundleIds

	return Roact.createElement(BundlesWidget, {
		titleIcon = CATALOG_ICON,
		titleText = TITLE_KEY,
		bundleIds = bundleIds,
		renderWidth = renderWidth,
		onActivated = self.onActivated,
	})
end

local getBundleIds = memoize(function(catalogBundleIds, count)
	local bundleIds = {}
	for i = 1, count do
		table.insert(bundleIds, catalogBundleIds[i])
	end
	return bundleIds
end)

CatalogWidget = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local catalogBundleIds = state.CatalogAppReducer.ChinaCatalogItems and state.CatalogAppReducer.ChinaCatalogItems.BundleIds or {}
		return {
			bundleIds = getBundleIds(catalogBundleIds, ICON_COUNT),
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				return dispatch(NavigateDown(page))
			end,
		}
	end
)(CatalogWidget)

return CatalogWidget