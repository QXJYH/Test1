local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local ContentProvider = game:GetService("ContentProvider")

local Common = Modules.Common

local Roact = require(Common.Roact)
local RoactRodux = require(Common.RoactRodux)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppPage = require(Modules.LuaApp.AppPage)
local LoginByEmail = require(Modules.LuaApp.Thunks.Authentication.LoginByEmail)
local LoginByPhone = require(Modules.LuaApp.Thunks.Authentication.LoginByPhone)
local LoginByUsername = require(Modules.LuaApp.Thunks.Authentication.LoginByUsername)
local LaunchApp = require(Modules.LuaApp.Thunks.Authentication.LaunchApp)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)
local Promise = require(Modules.LuaApp.Promise)

local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local GenericTextButton = require(Modules.LuaApp.Components.GenericTextButton)
local GenericTextBox = require(Modules.LuaApp.Components.GenericTextBox)
local BackgroundFill = require(Modules.LuaApp.Components.Login.BackgroundFill)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)

local isStringEmail = require(Modules.LuaApp.Components.Login.Utils.isStringEmail)
local isStringPhone = require(Modules.LuaApp.Components.Login.Utils.isStringPhone)

local TransitionAnimation = require(Modules.LuaApp.Enum.TransitionAnimation)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.LuaApp.withLocalization)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local LoginView = Roact.PureComponent:extend("LoginView")

local CLOSE_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/close"
local BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"
local LOGO_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/LandingPage/logo_white_1x.png"
local BG_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/LandingPage/LandingBackgroundTablet.png"
--local PW_SHOW_ICON = "rbxasset://textures/ui/LuaApp/graphic/Auth/pw_show.png"
--local PW_HIDE_ICON = "rbxasset://textures/ui/LuaApp/graphic/Auth/pw_hide.png"

local NAVIGATION_ICON_SIZE = 27
local BG_ASPECT_RATIO = 1024/1024
local LOGIN_CONTENTS_PADDING = 30
local LOGIN_CONTENTS_HEIGHT = 218
local LOGIN_CONTENTS_POSITION_Y = 0.45
local LOGO_MAX_WIDTH = 460
local LOGO_ASPECT_RATIO = 5.78
--local SHOW_TOGGLER_SIZE = UDim2.new(0, 16, 0, 16)
--local SHOW_TOGGLER_PADDING = 10
--local SHOW_TOGGLER_ASPECT_RATIO = 1
local TEXTBOX_PADDING_X = 10
local TEXTBOX_PADDING_Y = 7

local function renderTopButton(props)
	local layoutOrder = props.layoutOrder or 0
	local showCloseIcon = props.showCloseIcon
	local onActivated = props.onActivated
	local image = BACK_BUTTON_IMAGE

	if showCloseIcon then
		image = CLOSE_BUTTON_IMAGE
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement(ImageSetButton, {
				LayoutOrder = layoutOrder,
				Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
				Image = image,
				ImageColor3 = style.Theme.TextEmphasis.Color,
				ImageTransparency = style.Theme.TextEmphasis.Transparency,
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = onActivated,
			})
		end)
	else
		return nil
	end
end

function LoginView:init()
	self.cvalueRef = Roact.createRef()
	self.passwordRef = Roact.createRef()

	self.state = {
		errorText = "",
		loginButtonDisabled = true,
		hidePassword = true,
	}

	self.onTextBoxesChanged = function()
		if not self.cvalueRef.current or not self.passwordRef.current then return end
		if #self.cvalueRef.current.Text > 0 and #self.passwordRef.current.Text > 0 then
			self:setState({
				loginButtonDisabled = false
			})
		else
			self:setState({
				loginButtonDisabled = true
			})
		end
	end

	self.handleLoginSequence = function()
		if not self.cvalueRef.current or not self.passwordRef.current then return end
		local cvalue = self.cvalueRef.current.Text
		local password = self.passwordRef.current.Text

		return self.props.login(self.props.networking, cvalue, password):andThen(function(result)
			self.props.launchApp(self.props.networking)
		end, function(err)
			spawn(function()
				self:setState({errorText = err})
			end)
		end)
	end
end

function LoginView:didMount()
	delay(0, function()
		if not self.cvalueRef.current then return end
		self.cvalueRef.current:CaptureFocus()
	end)
end

function LoginView:didUpdate(previousProps, previousState)
	local currentPageName = self.props.currentPageName
	local previousPageName = previousProps.currentPageName

	-- NOTE: The 'GenericWebPage' in this case is really a Captcha web page (in the native layer).
	if currentPageName == AppPage.Login and previousPageName == AppPage.GenericWebPage then
		self.handleLoginSequence()
	end
end

function LoginView:render()
	local localizedErrorKey = self.state.errorText ~= "" and self.state.errorText or nil

	-- LUASTARTUP-56 TODO: use withStyle after its completion
	return withStyle(function(style)
		return withLocalization({
			localizedError = localizedErrorKey,
			logInText = "Authentication.Login.Action.LogInCapitalized",
			forgotText = "Authentication.Login.Action.ForgotPasswordOrUsernameQuestionCapitalized",
			cvalueText = "Authentication.Login.Label.UsernameEmailPhone",
			passwordText = "CommonUI.Messages.Label.Password",
		})(function(localizedStrings)
			return Roact.createElement(FullscreenPageWithSafeArea, {
				--BackgroundColor3 = theme.Main.Background.Color,
				includeStatusBar = true,
				renderFullscreenBackground = function(safeAreaPositionY)
					return Roact.createElement(BackgroundFill, {
						Image = BG_IMAGE,
						AspectRatio = BG_ASPECT_RATIO
					})
				end,
			},
			{
				BackButton = Roact.createElement(renderTopButton, {
					showCloseIcon = true,
					onActivated = self.props.navigateBack
				}),
				Logo = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.new(0.7, 0, 0.2, 0),
					Position = UDim2.new(0.5, 0, 0.2, 0),
					Image = LOGO_IMAGE,
				}, {
					UISizeConstraint = Roact.createElement("UISizeConstraint", {
						MaxSize = Vector2.new(LOGO_MAX_WIDTH, LOGO_MAX_WIDTH)
					}),
					UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
						AspectRatio = LOGO_ASPECT_RATIO,
						AspectType = Enum.AspectType.FitWithinMaxSize
					})
				}),
				LoginContents = Roact.createElement("Frame", {
					Size = UDim2.new(1, -40, 0, LOGIN_CONTENTS_HEIGHT),
					Position = UDim2.new(0.5, 0, LOGIN_CONTENTS_POSITION_Y, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, LOGIN_CONTENTS_PADDING)
					}),
					UISizeConstraint = Roact.createElement("UISizeConstraint", {
						MaxSize = Vector2.new(360, LOGIN_CONTENTS_HEIGHT)
					}),
					CValue = Roact.createElement(GenericTextBox, {
						Size = UDim2.new(1, 0, 0, 36),
						Text = "",
						PlaceholderText = localizedStrings.cvalueText,
						Font = Enum.Font.Gotham,
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						Color = Color3.new(0, 0, 0),
						Transparency = 0.3,
						TextColor = Color3.new(216/255, 216/255, 216/255),
						PlaceholderColor = Color3.new(189/255, 190/255, 190/255),
						TextTransparency = 0,
						PaddingX = TEXTBOX_PADDING_X,
						PaddingY = TEXTBOX_PADDING_Y,
						ClearTextOnFocus = false,
						TextBoxRef = self.cvalueRef,
						LayoutOrder = 0,
						onChangeText = function()
							self.onTextBoxesChanged()
						end
					}),
					PasswordContainer = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						LayoutOrder = 10,
					}, {
						--[[
						TODO: Add password functionality to GenericTextBox component (LUASTARTUP-55)
						Password = Roact.createElement(PasswordBox, {
							Size = UDim2.new(1, 0, 1, 0),
							Text = "",
							PlaceholderText = localizedStrings.passwordText,
							Font = Enum.Font.Gotham,
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							Color = Color3.new(0, 0, 0),
							Transparency = 0.3,
							TextColor = Color3.new(216/255, 216/255, 216/255),
							PlaceholderColor = Color3.new(189/255, 190/255, 190/255),
							TextTransparency = 0,
							PaddingX = TEXTBOX_PADDING_X,
							PaddingY = TEXTBOX_PADDING_Y,
							EnableShowToggler = true,
							ShowIcon = PW_SHOW_ICON,
							HideIcon = PW_HIDE_ICON,
							ShowTogglerSize = SHOW_TOGGLER_SIZE,
							ShowTogglerPadding = SHOW_TOGGLER_PADDING,
							ShowTogglerAspectRatio = SHOW_TOGGLER_ASPECT_RATIO,
							ClearTextOnFocus = false,
							TextBoxRef = self.passwordRef,
							onChangeText = function()
								self.onTextBoxesChanged()
							end
						})]]
						Password = Roact.createElement(GenericTextBox, {
							Size = UDim2.new(1, 0, 1, 0),
							Text = "",
							PlaceholderText = localizedStrings.passwordText,
							Font = Enum.Font.Gotham,
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							IsPassword = self.state.hidePassword,
							Color = Color3.new(0, 0, 0),
							Transparency = 0.3,
							TextColor = Color3.new(216/255, 216/255, 216/255),
							PlaceholderColor = Color3.new(189/255, 190/255, 190/255),
							TextTransparency = 0,
							PaddingX = TEXTBOX_PADDING_X,
							PaddingY = TEXTBOX_PADDING_Y,
							ClearTextOnFocus = false,
							TextBoxRef = self.passwordRef,
							onChangeText = function()
								self.onTextBoxesChanged()
							end
						}),
						ErrorText = Roact.createElement("TextLabel", {
							Position = UDim2.new(0, 0, 1, LOGIN_CONTENTS_PADDING/2),
							Size = UDim2.new(1, 0, 0, 24),
							AnchorPoint = Vector2.new(0, 0.5),
							Text = localizedStrings.localizedError or "",
							Font = Enum.Font.Gotham,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							TextColor3 = Color3.new(247/255, 75/255, 82/255),
							TextWrapped = true,
							BackgroundTransparency = 1,
						}),
						--[[ShowToggle = Roact.createElement("TextButton", {
							Position = UDim2.new(1, -TEXTBOX_PADDING_X/2, 0.5, 0),
							Size = SHOW_TOGGLER_SIZE,
							AnchorPoint = Vector2.new(1, 0.5),
							Text = "",
							BackgroundTransparency = 1,
							[Roact.Event.Activated] = function(rbx)
								local isHidingPassword = self.state.hidePassword
								spawn(function()
									self:setState({hidePassword = not isHidingPassword})
								end)
							end
						}, {
							ImageLabel = Roact.createElement("ImageLabel", {
								Position = UDim2.new(0.5, 0, 0.5, 0),
								Size = UDim2.new(1, 0, 1, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundTransparency = 1,
								Image = self.state.hidePassword and PW_SHOW_ICON or PW_HIDE_ICON,
								ImageTransparency = 0.5,
							}),
							UIPadding = Roact.createElement("UIPadding", {
								PaddingTop = UDim.new(0, SHOW_TOGGLER_PADDING/2),
								PaddingBottom = UDim.new(0, SHOW_TOGGLER_PADDING/2),
								PaddingLeft = UDim.new(0, SHOW_TOGGLER_PADDING/2),
								PaddingRight = UDim.new(0, SHOW_TOGGLER_PADDING/2),
							})
						})]]
					}),
					LoginButton = Roact.createElement(GenericTextButton, {
						Size = UDim2.new(1, 0, 0, 44),
						Text = localizedStrings.logInText,
						Font = Enum.Font.GothamSemibold,
						TextSize = 16,
						themeSettings = {
							Color = Color3.new(1, 1, 1),
							Transparency = 0,
							DisabledColor = Color3.new(1, 1, 1),
							DisabledTransparency = 0.5,
							OnPressColor = Color3.new(1, 1, 1),
							OnPressTransparency = 0,
							Text = {
								Color = Color3.new(57/255, 59/255, 61/255),
								Transparency = 0,
							},
							Border = {
								Hidden = true,
								Transparency = 1,
							},
						},
						isDisabled = self.state.loginButtonDisabled,
						isLoading = false,
						LayoutOrder = 20,
						onActivated = function(rbx)
							self.handleLoginSequence()
						end
					}),
					Forgot = Roact.createElement("TextButton", {
						Size = UDim2.new(1, 0, 0, 12),
						Position = UDim2.new(0, 0, 0, 206),
						Text = localizedStrings.forgotText,
						TextSize = 12,
						Font = Enum.Font.GothamSemibold,
						TextColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Center,
						LayoutOrder = 30,
						[Roact.Event.Activated] = function()
							self.props.navigateToPage({
								name = AppPage.GenericWebPage,
								detail = ContentProvider.BaseUrl .. "login/forgot-password-or-username",
								extraProps = {
									title = "",
									transitionAnimation = TransitionAnimation.SlideInFromRight
								}
							})
						end
					}),
				})
			})
		end)
	end)
end

LoginView = RoactServices.connect({
	networking = RoactNetworking,
	guiService = AppGuiService,
})(LoginView)

LoginView = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			screenSize = state.ScreenSize,
			loginStatus = state.Authentication.status,
			currentPageName = currentRoute[#currentRoute].name,
		}
	end,
	function(dispatch)
		return {
			login = function(networkImpl, cvalue, password)
				if isStringEmail(cvalue) then
					return dispatch(LoginByEmail(networkImpl, cvalue, password)):andThen(function(result)
						return Promise.resolve(result)
					end, function(err)
						return Promise.reject(err)
					end)
				elseif isStringPhone(cvalue) then
					return dispatch(LoginByPhone(networkImpl, cvalue, password)):andThen(function(result)
						return Promise.resolve(result)
					end, function(err)
						return Promise.reject(err)
					end)
				else
					return dispatch(LoginByUsername(networkImpl, cvalue, password)):andThen(function(result)
						return Promise.resolve(result)
					end, function(err)
						return Promise.reject(err)
					end)
				end
			end,
			launchApp = function(networkImpl)
				return dispatch(LaunchApp(networkImpl))
			end,
			navigateToPage = function(page)
				return dispatch(NavigateDown(page))
			end,
			navigateBack = function()
                return dispatch(NavigateBack())
            end
		}
	end
)(LoginView)

return LoginView
