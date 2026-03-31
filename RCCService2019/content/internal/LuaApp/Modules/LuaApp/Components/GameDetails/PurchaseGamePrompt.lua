local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local Functional = require(Modules.Common.Functional)
local Constants = require(Modules.LuaApp.Constants)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local getPurchaseErrorTypeFromErrorResponse = require(Modules.LuaApp.getPurchaseErrorTypeFromErrorResponse)

local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local PurchaseErrors = require(Modules.LuaApp.Enum.PurchaseErrors)

local AlertWindow = require(Modules.LuaApp.Components.AlertWindow)

local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local FetchGamePlayabilityAndProductInfo = require(Modules.LuaApp.Thunks.FetchGamePlayabilityAndProductInfo)
local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)
local OpenCentralOverlayForPurchaseGameRobuxShortfall =
	require(Modules.LuaApp.Thunks.OpenCentralOverlayForPurchaseGameRobuxShortfall)
local PurchaseProduct = require(Modules.LuaApp.Thunks.PurchaseProduct)

local ROBUX_CURRENCY = Constants.Currency.Robux

local GetFFlagLuaAppNewEconomyApi = require(Modules.LuaApp.Flags.GetFFlagLuaAppNewEconomyApi)

local PurchaseGamePrompt = Roact.PureComponent:extend("PurchaseGamePrompt")

PurchaseGamePrompt.defaultProps = {
	expectedCurrency = ROBUX_CURRENCY,
}

function PurchaseGamePrompt:init()
	self.onPurchaseFailedWithRobuxShortfall = function(err)
		local gameName = self.props.gameName
		local robuxShortfall = err.shortfallPrice
		local theme = self.props.theme
		local currentPage = self.props.currentPage
		local openPurchaseGameRobuxShortfallPrompt = self.props.openPurchaseGameRobuxShortfallPrompt

		openPurchaseGameRobuxShortfallPrompt(gameName, robuxShortfall, theme, { currentPage })
	end

	self.customPurchaseErrorHandler = function(errorData)
		local handled = false
		local errorType = getPurchaseErrorTypeFromErrorResponse(errorData)
		if errorType == PurchaseErrors.NotEnoughRobux then
			self.onPurchaseFailedWithRobuxShortfall(errorData)
			handled = true
		end
		return handled
	end

	if GetFFlagLuaAppNewEconomyApi() then
		self.purchaseGame = function()
			local networking = self.props.networking
			local productId = self.props.productId

			local purchaseDetail = {
				expectedCurreny = self.props.expectedCurrency,
				expectedPrice = self.props.price,
				expectedSellerId = self.props.sellerId,

				-- TODO Implement these so we can make full use of the API
				-- expectedPromoId = ...
				-- userAssetId = ...
				-- saleLocationType = ...
			}

			self.props.purchaseGame(networking, productId, purchaseDetail, self.customPurchaseErrorHandler)
				:andThen(function()
					local localization = self.props.localization

					self.props.fetchPlayabilityAndProductInfo(networking, self.props.universeId)

					local toastMessage = localization:Format("Feature.Toast.Heading.PurchaseMessage.Success")
					local toastSubMessage = localization:Format("Feature.Toast.Message.PurchaseMessage.Success", {
						gameName = self.props.gameName,
						price = self.props.price,
					})
					self.props.setCurrentToastMessage(ToastType.PurchaseMessage, toastMessage, toastSubMessage, true)

					self.props.closePrompt()
				end)
		end
	else
		self.purchaseGame = function()
			local universeId = self.props.universeId
			local productId = self.props.productId
			local sellerId = self.props.sellerId
			local expectedCurrency = self.props.expectedCurrency
			local gameName = self.props.gameName
			local price = self.props.price
			local networking = self.props.networking
			local localization = self.props.localization
			local setCurrentToastMessage = self.props.setCurrentToastMessage
			local purchaseGame = self.props.purchaseGame
			local closePrompt = self.props.closePrompt
			local fetchPlayabilityAndProductInfo = self.props.fetchPlayabilityAndProductInfo

			purchaseGame(networking, productId, expectedCurrency,
				price, sellerId, self.customPurchaseErrorHandler):andThen(
				function()
					fetchPlayabilityAndProductInfo(networking, universeId)

					local toastMessage = localization:Format("Feature.Toast.Heading.PurchaseMessage.Success")
					local toastSubMessage = localization:Format("Feature.Toast.Message.PurchaseMessage.Success", {
						gameName = gameName,
						price = price,
					})
					setCurrentToastMessage(ToastType.PurchaseMessage, toastMessage, toastSubMessage, true)

					closePrompt()
				end
			)
		end
	end
end

function PurchaseGamePrompt:didMount()
	-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE this temporary fix.
	local pageFilter = self.props.pageFilter
	local currentPage = self.props.currentPage
	local closePrompt = self.props.closePrompt
	if pageFilter and not Functional.Find(pageFilter, currentPage) then
		closePrompt()
	end
end

function PurchaseGamePrompt:render()
	local theme = self.props.theme
	local containerWidth = self.props.containerWidth
	local purchaseStatus = self.props.purchaseStatus
	local closePrompt = self.props.closePrompt
	local localization = self.props.localization
	local gameName = self.props.gameName
	local price = self.props.price
	local isPurchasing = purchaseStatus == RetrievalStatus.Fetching

	-- Set theme for all child Components
	-- TODO: MOBLUAPP-1298 Remove all theme pass-throughs when theme is unified globally
	self._context.AppTheme = theme

	return Roact.createElement(AlertWindow, {
		theme = theme,
		containerWidth = containerWidth,
		titleText = localization:Format("Feature.GameDetails.Heading.PurchaseGame"),
		titleFont = theme.GameDetails.Text.BoldFont,
		messageText = localization:Format("Feature.GameDetails.Message.PurchaseGame", {
			gameName = gameName,
			X = price,
		}),
		messageFont = theme.GameDetails.Text.Font,
		buttonFont = theme.GameDetails.Text.Font,
		confirmButtonText = localization:Format("Feature.GameDetails.Action.Unlock"),
		onConfirm = self.purchaseGame,
		isConfirming = isPurchasing,
		hasCancelButton = true,
		onCancel = closePrompt,
	})
end

PurchaseGamePrompt = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			purchaseStatus = PurchaseProduct.GetPostingStatus(state, props.productId),
			currentPage = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		local purchaseGame
		if GetFFlagLuaAppNewEconomyApi() then
			purchaseGame = function(networking, productId, purchaseDetail, customPurchaseErrorHandler)
				return dispatch(PurchaseProduct.Post(networking, productId, purchaseDetail, customPurchaseErrorHandler))
			end
		else
			purchaseGame = function(networking, productId, expectedCurrency,
				expectedPrice, sellerId, customPurchaseErrorHandler)
				return dispatch(PurchaseProduct.Post(networking,
					productId, expectedCurrency, expectedPrice, sellerId, customPurchaseErrorHandler))
			end
		end

		return {
			setCurrentToastMessage = function(toastType, toastMessage, toastSubMessage, isLocalized)
				return dispatch(SetCurrentToastMessage({
					toastType = toastType,
					toastMessage = toastMessage,
					toastSubMessage = toastSubMessage,
					isLocalized = isLocalized,
				}))
			end,
			openPurchaseGameRobuxShortfallPrompt = function(gameName, robuxShortfall, theme, pageFilter)
				return dispatch(OpenCentralOverlayForPurchaseGameRobuxShortfall(gameName, robuxShortfall, theme, pageFilter))
			end,
			purchaseGame = purchaseGame,
			closePrompt = function()
				return dispatch(CloseCentralOverlay())
			end,
			fetchPlayabilityAndProductInfo = function(networking, universeId)
				return dispatch(FetchGamePlayabilityAndProductInfo.Fetch(networking, universeId))
			end,
		}
	end
)(PurchaseGamePrompt)

PurchaseGamePrompt = RoactServices.connect({
	networking = RoactNetworking,
	localization = RoactLocalization,
})(PurchaseGamePrompt)

return PurchaseGamePrompt
