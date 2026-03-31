local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Colors = require(Modules.LuaApp.Themes.Colors)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local NumberLocalization = require(Modules.LuaApp.Util.NumberLocalization)
local ApiFetchEconomyCurrency = require(Modules.LuaApp.Thunks.ApiFetchEconomyCurrency)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local FitChildren = require(Modules.LuaApp.FitChildren)
local TextButton = require(Modules.LuaApp.Components.TextButton)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local getCurrentPage = require(Modules.LuaApp.getCurrentPage)

local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")

local ICON_IMAGE
if FFlagChinaLicensingApp then
	ICON_IMAGE = "LuaApp/icons/robux"
else
	ICON_IMAGE = "LuaApp/icons/ic-ROBUX"
end
local ICON_WIDTH = 26
local ICON_HEIGHT = 26

local INFO_TEXT_COLOR3 = Colors.White
local INFO_TEXT_FONT = Enum.Font.SourceSansBold
local INFO_TEXT_SIZE = 28
local BUTTON_TEXT_SIZE = 28
local BUTTON_WIDTH = 136
local BUTTON_HEIGHT = 44

local CONTENT_HEIGHT = 60
local CONTENT_DIVIDER_WIDTH = 10

local BUY_ROBUX_TEXT = "Feature.GameDetails.Action.BuyRobux"

local MyRobuxArea = Roact.PureComponent:extend("MyRobuxArea")

MyRobuxArea.defaultProps = {
	BackgroundColor3 = Colors.White,
	BackgroundTransparency = 1,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Position = UDim2.new(0,0,0,0),
	paddingRight = UDim.new(0,0),
}

function MyRobuxArea:init()
	self.buyRobux = function()
		self.props.openPurchaseRobuxPage()
	end

	self.updateRobux = function()
		local localUserId = self.props.localUserId
		local requestRobuxInfo = self.props.requestRobuxInfo
		local networking = self.props.networking
		if typeof(localUserId) == "string" and localUserId ~= "" then
			requestRobuxInfo(networking, localUserId)
		end
	end
end

function MyRobuxArea:didMount()
	self.updateRobux()
end

function MyRobuxArea:didUpdate(previousProps, previousState)
	local localUserId = self.props.localUserId
    local previousLocalUserId = previousProps.localUserId
	if previousLocalUserId ~= localUserId then
		self.updateRobux()
    end
end

function MyRobuxArea:render()
	local theme = self._context.AppTheme
    local robux = self.props.robux
	local localization = self.props.localization
	local robuxInfoText = robux and NumberLocalization.localize(robux, localization:GetLocale()) or "-"
	local buyRobux = self.buyRobux

	local backgroundTransparency = self.props.BackgroundTransparency
	local backgroundColor = self.props.BackgroundColor3
	local horizontalAlignment = self.props.HorizontalAlignment
	local position = self.props.Position
	local paddingRight = self.props.paddingRight

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, CONTENT_HEIGHT),
		Position = position,
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = horizontalAlignment,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, CONTENT_DIVIDER_WIDTH),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingRight = paddingRight,
		}),
		RobuxIcon = Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, ICON_WIDTH, 0, ICON_HEIGHT),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = ICON_IMAGE,
			LayoutOrder = 1,
		}),
		RobuxInfo = Roact.createElement(FitTextLabel, {
			fitAxis = FitChildren.FitAxis.Width,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = robuxInfoText,
			Font = INFO_TEXT_FONT,
			TextColor3 = INFO_TEXT_COLOR3,
			TextSize = INFO_TEXT_SIZE,
			LayoutOrder = 2,
		}),
		-- MOBLUAPP-1610 Temporarily removing BuyRobux option
		-- BuyRobuxButton = Roact.createElement(TextButton, {
		-- 	Theme = theme.Buttons.CtaButton,
		-- 	Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
		-- 	Text = BUY_ROBUX_TEXT,
		-- 	TextSizeMin = BUTTON_TEXT_SIZE,
		-- 	TextSizeMax = BUTTON_TEXT_SIZE,
		-- 	LayoutOrder = 3,
		-- 	[Roact.Event.Activated] = buyRobux,
		-- }),
	})
end

function MyRobuxArea:didUpdate(prevProps, prevState)
	local isAppOnHomePage = self.props.isAppOnHomePage
	local prevIsAppOnHomePage = prevProps.isAppOnHomePage

	if not prevIsAppOnHomePage and isAppOnHomePage then
		self.updateRobux()
	end
end

MyRobuxArea = RoactRodux.UNSTABLE_connect2(
    function(state)
        local localUserId = state.LocalUserId
        local isAppOnHomePage = getCurrentPage(state) == AppPage.Home

		return {
            localUserId = localUserId,
            robux = state.UserRobux[localUserId],
            isAppOnHomePage = isAppOnHomePage,
		}
    end,
    function(dispatch)
		return {
            requestRobuxInfo = function(networking, userId)
				return dispatch(ApiFetchEconomyCurrency(networking, userId, false))
			end,
			openPurchaseRobuxPage = function()
				return dispatch(NavigateDown({
					name = AppPage.PurchaseRobux,
				}))
			end,
		}
	end
)(MyRobuxArea)

return RoactServices.connect({
    localization = RoactLocalization,
	networking = RoactNetworking,
})(MyRobuxArea)
