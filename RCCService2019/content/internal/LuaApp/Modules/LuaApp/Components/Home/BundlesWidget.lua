local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Cryo = require(CorePackages.Cryo)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local memoize = require(Modules.Common.memoize)

local FetchBundleThumbnails = require(Modules.LuaApp.Thunks.Catalog.FetchBundleThumbnails)
local getCurrentPage = require(Modules.LuaApp.getCurrentPage)

local AppPage = require(Modules.LuaApp.AppPage)
local HomePageIconListWidget = require(Modules.LuaApp.Components.Home.HomePageIconListWidget)

local BundlesWidget = Roact.PureComponent:extend("BundlesWidget")

local EMPTY_PLACEHOLDER_TEXT_KEY = "Feature.Home.Message.NoItems"

local THUMBNAIL_SIZE = 150
local THUMBNAIL_SUBDIVIDE_COUNT = 20

BundlesWidget.defaultProps = {
	bundleIds = {},
}

function BundlesWidget:init()
	self.fetchIcons = function()
		local networking = self.props.networking
		local bundleIds = self.props.bundleIds
		local fetchIcons = self.props.fetchIcons

		if #bundleIds > 0 then
			fetchIcons(networking, bundleIds)
		end
	end
end

function BundlesWidget:render()
	local renderWidth = self.props.renderWidth
	local catalogIcons = self.props.iconUrls
	local titleIcon = self.props.titleIcon
	local titleText = self.props.titleText
	local onActivated = self.props.onActivated

	return Roact.createElement(HomePageIconListWidget, {
		titleIcon = titleIcon,
		titleText = titleText,
		emptyText = EMPTY_PLACEHOLDER_TEXT_KEY,
		iconUrls = catalogIcons,
		renderWidth = renderWidth,
		onActivated = onActivated,
	})
end

function BundlesWidget:didMount()
	self.fetchIcons()
end

function BundlesWidget:didUpdate(prevProps, prevState)
	local isAppOnHomePage = self.props.isAppOnHomePage
	local prevIsAppOnHomePage = prevProps.isAppOnHomePage

	if not prevIsAppOnHomePage and isAppOnHomePage then
		self.fetchIcons()
	end
end

local getImageUrls = memoize(function(bundles, ids, fetching)
	if fetching then
		return nil
	end
	return Cryo.List.map(ids, function(id)
		local bundle = bundles[tostring(id)]
		if bundle == nil or bundle.thumbnails == nil then
			return ""
		end
		return bundle.thumbnails[tostring(THUMBNAIL_SIZE)] or ""
	end)
end)

BundlesWidget = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local bundles = state.CatalogAppReducer.Bundles or {}
		local bundleIds = props.bundleIds or {}
		local isAppOnHomePage = getCurrentPage(state) == AppPage.Home
		-- set to true while fetching the id list
		local fetchingBundleIds = false
		return {
			iconUrls = getImageUrls(bundles, bundleIds, fetchingBundleIds),
			isAppOnHomePage = isAppOnHomePage,
		}
	end,
	function(dispatch)
		return {
			fetchIcons = function(networking, catalogBundlesIds)
				return dispatch(FetchBundleThumbnails(networking, catalogBundlesIds, THUMBNAIL_SIZE, THUMBNAIL_SUBDIVIDE_COUNT))
			end,
		}
	end
)(BundlesWidget)

return RoactServices.connect({
	networking = RoactNetworking,
})(BundlesWidget)
