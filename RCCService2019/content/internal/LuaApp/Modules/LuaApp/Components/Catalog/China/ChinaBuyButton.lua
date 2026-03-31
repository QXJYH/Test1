local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local LoadingBar = require(Modules.LuaApp.Components.LoadingBar)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local PurchaseProduct = require(Modules.LuaApp.Thunks.Catalog.PurchaseProduct)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local formatInteger = require(Modules.LuaChat.Utils.formatInteger)
local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)
local FFlagLuaAppShimmerOnChinaBuyButton = settings():GetFFlag("LuaAppShimmerOnChinaBuyButton")

local BACKGROUND_IMAGE_9_SLICE = "LuaApp/buttons/buttonFill"
local ROBUX_ICON = "LuaApp/icons/robux_white"

local ROBUX_ICON_SIZE = 26
local ROBUX_TEXT_FONT = Enum.Font.GothamBold
local ROBUX_TEXT_FONT_SIZE = 22
local ROBUX_ICON_TEXT_GAP = 8

local ChinaBuyButton = Roact.PureComponent:extend("ChinaBuyButton")

local function getBuyButtonInfoFetchingStatus(state)
	return function(productId)
		assert(productId, "getBuyButtonInfoFetchingStatus must have a valid productId")
		return PerformFetch.GetStatus(state, CatalogConstants.BuyButtonInfoKey  ..tostring(productId))
	end
end

local function makingAPurchase(state)
	return function(productId)
		assert(productId, "makingAPurchase must have a valid productId")
		return PerformFetch.GetStatus(state, CatalogConstants.PurchaseProductKey ..tostring(productId))
	end
end

local function getBundleStatus(state)
	return function(productId)
		assert(productId, "getBundleStatus must have a valid productId")
		return state.CatalogAppReducer.BundlesStatus[productId]
	end
end

function ChinaBuyButton:render()
	local theme = self._context.AppTheme
	local robux = self.props.robux
	local networking = self.props.networking
	local localization = self.props.localization
	local size = self.props.Size
	local layoutOrder = self.props.LayoutOrder
	local purchaseProduct = self.props.purchaseProduct
	local itemId = self.props.itemId
	local itemInfo = self.props.itemInfo[itemId]
	local productId = self.props.itemInfo[itemId] and self.props.itemInfo[itemId].product and self.props.itemInfo[itemId].product.id or nil
	local makingAPurchase = productId and self.props.makingAPurchase(productId) == RetrievalStatus.Fetching
	local buyButtonFetchingStatus = productId and self.props.buyButtonFetchingStatus(tostring(productId))
	local bundleStatus = productId and self.props.bundleStatus(productId) or CatalogConstants.PurchaseStatus.NotPurchasable
	local itemOwned = bundleStatus == CatalogConstants.PurchaseStatus.Owned
	local isDisabled = itemOwned or bundleStatus == CatalogConstants.PurchaseStatus.NotPurchasable
		or (itemInfo == nil or itemInfo.priceInRobux == nil or robux < itemInfo.priceInRobux)
	local priceText = itemInfo and itemInfo.priceInRobux
	local showRobuxIcon

	if itemOwned then
		showRobuxIcon = false
		priceText = localization:Format("Feature.Catalog.Label.Owned")
	elseif priceText == 0 then
		showRobuxIcon = false
		priceText = localization:Format("Feature.Catalog.LabelFree")
	elseif priceText then
		showRobuxIcon = true
		priceText = formatInteger(priceText)
	end

	local buttonTheme = theme.SystemPrimaryButton

	if makingAPurchase then
		return Roact.createElement(ImageSetLabel, {
			BackgroundTransparency = 1,
			Image = BACKGROUND_IMAGE_9_SLICE,
			ImageTransparency = buttonTheme.DisabledTransparency,
			ImageColor3 = buttonTheme.DisabledColor,
			Size = size,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(8, 8, 9, 9),
		}, {
			LoadingBar = FFlagLuaAppShimmerOnChinaBuyButton and Roact.createElement(ShimmerAnimation, {
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				themeSettings = buttonTheme,
			}) or Roact.createElement(LoadingBar),
		})
	end

	return Roact.createElement(ImageSetButton, {
		Size = size,
		LayoutOrder = layoutOrder,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = BACKGROUND_IMAGE_9_SLICE,
		ImageTransparency = isDisabled and buttonTheme.DisabledTransparency or buttonTheme.Transparency,
		ImageColor3 = isDisabled and buttonTheme.DisabledColor or buttonTheme.Color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
		ClipsDescendants = true,
		Visible = buyButtonFetchingStatus == RetrievalStatus.Done,
		[Roact.Event.Activated] = function()
			if bundleStatus == CatalogConstants.PurchaseStatus.Purchasable and not itemOwned and not isDisabled then
				purchaseProduct(networking, itemInfo.product.id, itemInfo.priceInRobux or 0, itemInfo.creator.id)
			end
		end,
	},{
		Frame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ROBUX_ICON_TEXT_GAP),
			}),
			RobuxIcon = showRobuxIcon and Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, ROBUX_ICON_SIZE, 0, ROBUX_ICON_SIZE),
				BackgroundTransparency = 1,
				Image = ROBUX_ICON,
				ImageColor3 = buttonTheme.Text.Color,
				LayoutOrder = 1,
			}),
			RobuxText = Roact.createElement(FitTextLabel, {
				Size = UDim2.new(0, 0, 0, ROBUX_TEXT_FONT_SIZE),
				BackgroundTransparency = 1,
				Text = priceText,
				Font = ROBUX_TEXT_FONT,
				TextSize = ROBUX_TEXT_FONT_SIZE,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = false,
				TextColor3 = buttonTheme.Text.Color,
				TextTransparency = 0,
				LayoutOrder = 2,
				fitAxis = FitChildren.FitAxis.Width,
			}),
		}),
	})
end

ChinaBuyButton = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local localUserId = state.LocalUserId
		return {
			buyButtonFetchingStatus = getBuyButtonInfoFetchingStatus(state),
			bundleStatus = getBundleStatus(state),
			makingAPurchase = makingAPurchase(state),
			itemInfo = state.CatalogAppReducer.Bundles,
			robux = state.UserRobux[localUserId],
		}
	end,
	function(dispatch)
		return {
			purchaseProduct = function(networking, productId, expectedPrice, expectedSellerId)
				dispatch(PurchaseProduct(networking, productId, expectedPrice, expectedSellerId))
			end,
		}
	end
)(ChinaBuyButton)

return RoactServices.connect({
	networking = RoactNetworking,
	localization = RoactLocalization,
})(ChinaBuyButton)