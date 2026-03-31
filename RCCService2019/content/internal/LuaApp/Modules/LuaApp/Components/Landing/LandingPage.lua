local CorePackages = game:GetService("CorePackages")
local Colors = require(CorePackages.AppTempCommon.LuaApp.Style.Colors)
local ContentProvider = game:GetService("ContentProvider")
local BaseUrl = ContentProvider.BaseUrl

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local withLocalization = require(Modules.LuaApp.withLocalization)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)

local FitChildren = require(Modules.LuaApp.FitChildren)
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local PagingLabelsScrollView = require(Modules.LuaApp.Components.Landing.PagingLabelsScrollView)
local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local BackgroundFill = require(Modules.LuaApp.Components.Login.BackgroundFill)

-- images
local BACKGROUND_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/LandingPage/LandingBackgroundTablet.png"
local BG_IMAGE_ASPECT_RATIO = (1024 / 1024)
local LOGO_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/LandingPage/logo_white_1x.png"

local CONTENT_PADDING = 20

-- Logo Image parameters
local LOGO_IMAGE_H_PADDING = 30
local LOGO_IMAGE_RATIO_XY = (510.0 / 88.0)
local LOGO_IMAGE_TOP_PADDING = 140

-- Action Button parameters
local ACTION_BUTTON_HEIGHT = 44
local ACTION_BUTTON_FONT_SIZE = 16
local ACTION_BUTTON_SPACING = 20
local SIGN_UP_BUTTON_TEXT_COLOR = Colors.Flint
local LOG_IN_BUTTON_TEXT_COLOR = Colors.White

-- Disclaimer 
local DISCLAIMER_HEIGHT = 40

-- Pading Scroll 
local PAGING_SCROLL_HOLDER_HEIGHT = 180

local LandingPage = Roact.PureComponent:extend("LandingPage")

function LandingPage:render()

	return withLocalization({
		signUpText = "Authentication.SignUp.Label.SignUp",
		logInText = "Authentication.Login.Action.LogInCapitalized",
	})(function(localizedStrings)
		local screenSize = self.props.screenSize

		local logoImageWidth = screenSize.X - 2 * LOGO_IMAGE_H_PADDING
		local logoImageHeight = logoImageWidth / LOGO_IMAGE_RATIO_XY

		local actionButtonWidth = screenSize.X - 2 * CONTENT_PADDING

		local disclaimerTopOffset = screenSize.Y - DISCLAIMER_HEIGHT - 2 * CONTENT_PADDING

		return Roact.createElement(FullscreenPageWithSafeArea , {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 =  Constants.Color.BLUE_DISABLED,
			BackgroundTransparency = 0,
			renderFullscreenBackground = function(safeAreaPositionY) 
				return Roact.createElement(BackgroundFill, {
					Image = BACKGROUND_IMAGE,
					AspectRatio = BG_IMAGE_ASPECT_RATIO
				})
			end,
		}, {
			BackgroundImage = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			},{
				UIListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Bottom
				}),
				LogoImage = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0, logoImageWidth, 0, logoImageHeight),
					Position = UDim2.new(0, LOGO_IMAGE_H_PADDING, 0, LOGO_IMAGE_TOP_PADDING),
					BackgroundTransparency = 1,
					Image = LOGO_IMAGE,
					LayoutOrder = 1,
					ScaleType = Enum.ScaleType.Fit,
				}),
				PagingScrollHolder = Roact.createElement(PagingLabelsScrollView,{
					Size = UDim2.new(1, 0, 0, PAGING_SCROLL_HOLDER_HEIGHT),
					LayoutOrder = 2,
					Position = UDim2.new(0, 0, 0, disclaimerTopOffset - 2 * (ACTION_BUTTON_HEIGHT + ACTION_BUTTON_SPACING) - PAGING_SCROLL_HOLDER_HEIGHT - CONTENT_PADDING),
					labelsTextArray = {"[First Page Content Goes Here]",  "[Second Page Content Goes Here]",  "[Third Page Content Goes Here]"},
					contentHeight = PAGING_SCROLL_HOLDER_HEIGHT,
				}),
				ButtonsHolder = Roact.createElement(FitChildren.FitFrame, {
					fitAxis = FitChildren.FitAxis.Height,
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					LayoutOrder = 3,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, CONTENT_PADDING),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top
					}),
					UIPadding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, CONTENT_PADDING),
						PaddingBottom = UDim.new(0, CONTENT_PADDING)
					}),
					SignUpButton = Roact.createElement("TextButton", {
						Text = localizedStrings.signUpText,
						TextSize = ACTION_BUTTON_FONT_SIZE,
						TextColor3 = SIGN_UP_BUTTON_TEXT_COLOR,
						Position = UDim2.new(0, CONTENT_PADDING, 0, disclaimerTopOffset - 2 * (ACTION_BUTTON_HEIGHT + ACTION_BUTTON_SPACING)),
						Size = UDim2.new(0, actionButtonWidth, 0, ACTION_BUTTON_HEIGHT),
						BackgroundTransparency = 0,
						BorderColor3 = SIGN_UP_BUTTON_TEXT_COLOR,
						BorderSizePixel = 2,
						[Roact.Event.Activated] = function()  self.props.gotoSignUp() end,
					}),
					LogInButton = Roact.createElement("TextButton", {
						Text = localizedStrings.logInText,
						TextSize = ACTION_BUTTON_FONT_SIZE,
						TextColor3 = LOG_IN_BUTTON_TEXT_COLOR,
						Position = UDim2.new(0, CONTENT_PADDING, 0, disclaimerTopOffset - (ACTION_BUTTON_HEIGHT + ACTION_BUTTON_SPACING)),
						Size = UDim2.new(0, actionButtonWidth, 0, ACTION_BUTTON_HEIGHT),
						BackgroundTransparency = 0.5,
						BorderColor3 = LOG_IN_BUTTON_TEXT_COLOR,
						BorderSizePixel = 2,
						[Roact.Event.Activated] = function() self.props.gotoLogin() end,
					}),
					SignUpDisclaimerView = Roact.createElement("Frame", {
						Size = UDim2.new(0, actionButtonWidth, 0, DISCLAIMER_HEIGHT),
						Position = UDim2.new(0, CONTENT_PADDING, 0, disclaimerTopOffset),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
					})
				}),
			}),
		  })
	end)
end

LandingPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			gotoSignUp = function()
				-- We should add code to navigate to Sign Up page
				-- e.g. dispatch(NavigateDown({ name = AppPage.Birthday }))
			end,
			gotoLogin = function()
				-- We should add code to navigate to Login page
				-- e.g. dispatch(NavigateDown({ name = AppPage.Login }))
			end,
		}
	end

)(LandingPage)


LandingPage = RoactServices.connect({
	guiService = AppGuiService,
})(LandingPage)


return LandingPage