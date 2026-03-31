local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local withLocalization = require(Modules.LuaApp.withLocalization)

local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local IssueTracker = require(Modules.LuaApp.Components.Login.IssueTracker)
local SignUpLayout = require(Modules.LuaApp.Components.Login.SignUpLayout)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local FocusedTextbox = require(Modules.LuaApp.Components.Login.FocusedTextbox)

local UsernameValidator = require(Modules.LuaApp.Thunks.Authentication.UsernameValidator)
local StoreSignUpUsername = require(Modules.LuaApp.Thunks.StoreSignUpUsername)

local UsernamePage = Roact.PureComponent:extend("UsernamePage")

local BACKGROUND_COLOR = Color3.new(35/255,37/255,39/255)
local USERNAME_BAR_COLOR = Color3.new(0.04,0.04,0.04)
local CONTINUE_INACTIVE_COLOR = Color3.new(0.569,0.569,0.569)
local CONTINUE_ACTIVE_COLOR = Color3.new(1,1,1)
local TEXT_COLOR_DARK = Color3.new(0.7,0.7,0.7)
local BACKGROUND_IMAGE_9_SLICE_FILL = "LuaApp/buttons/buttonFill"
local TYPING_PAUSE_TIME = 0.3

local DEFAULT_WIDGET_SCALE = 0.635
local MIN_WIDGET_SCALE = 0.365

function UsernamePage:init()

	self.currentInput = ""
	self.issueMessage = UsernameValidator.MessageList

	self.validateUsername = UsernameValidator.Validate

	self.state = {
		UsernameValid = false,
		IssueCondition = UsernameValidator.DefaultIssues,
		ContinueButtonOffset = -35,
		widgetSize = Vector2.new(0,0)
	}
end

function UsernamePage:render()
	local renderUsernamePage = function(localizedText)

		return Roact.createElement(SignUpLayout,{
			titleTextKey = "Authentication.SignUp.Heading.UsernamePage",
			paragraphTextKey = "Authentication.SignUp.Description.UsernamePage",
			widgetScaleDefault = DEFAULT_WIDGET_SCALE,
			widgetScaleMin = MIN_WIDGET_SCALE,
			renderWidget = function(props)
				local containerSizeY = props.containerSize.Y
				local widgetSize = props.widgetSize
				local isWideScreen = self.props.formFactor==FormFactor.WIDE

				local inputSize = containerSizeY*0.045
				local padSize = containerSizeY*0.02
				local buttonSize = containerSizeY*0.06

				local issueTrackerYOffset = (padSize*1.5+inputSize)
				local continueButtonYOffset = isWideScreen and -padSize or props.keyboardOffset+self.state.ContinueButtonOffset
				local continueButtonYSize = buttonSize

				return Roact.createElement("Frame",{
					Size = UDim2.new(1,0,0,widgetSize),
					BackgroundTransparency  = 1,
					[Roact.Change.AbsoluteSize] = function(rbx)
						spawn(function()
							self:setState({
								widgetSize = rbx.AbsoluteSize
							})
						end)
					end,
				},{
					Background = Roact.createElement(ImageSetButton, {
						Size = UDim2.new(1,0,1,0),
						Position = UDim2.new(0,0,0,0),
						BackgroundTransparency = isWideScreen and 1 or 0,
						Image = BACKGROUND_IMAGE_9_SLICE_FILL,
						ImageColor3 = BACKGROUND_COLOR,
						BackgroundColor3 = BACKGROUND_COLOR,
						BorderSizePixel = 0,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(8, 8, 9, 9),
					},{
						UsernameInput = Roact.createElement(ImageSetButton, {
							Size = UDim2.new(0.8,0,0,inputSize),
							Position = UDim2.new(0.1,0,0,padSize),
							BackgroundTransparency = 1,
							Image = BACKGROUND_IMAGE_9_SLICE_FILL,
							ImageColor3 = USERNAME_BAR_COLOR,
							BorderSizePixel = 0,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(8, 8, 9, 9),
						},{
							InputBox = Roact.createElement(FocusedTextbox,{
								Position = UDim2.new(0,8,0.15,0),
								Size = UDim2.new(1,-16,0.7,0),
								BackgroundTransparency = 1,
								Font = Enum.Font.Gotham,
								TextColor3 = TEXT_COLOR_DARK,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								ShowNativeInput = false,
								ClearTextOnFocus = false,
								Text = self.currentInput,
								[Roact.Change.Text] = function(rbx)
									if #rbx.Text>20 then
										rbx.Text = self.currentInput
									else
										local input = rbx.Text
										self.currentInput = input
										spawn(function()
											wait(TYPING_PAUSE_TIME)
											if input==rbx.Text then
												self.props.validateUsername(self.props.networking,rbx.Text,self.state.IssueCondition):andThen(
													function(result)
														if result.Input==rbx.Text then
															self:setState({
																UsernameValid = result.UsernameValid,
																IssueCondition = result.IssueCondition,
															})
														end
													end,
													function(err)

													end
												)
											end
										end)
									end
								end,
							}),
						}),
						IssueTracker = Roact.createElement(IssueTracker,{
							SizeY = widgetSize-issueTrackerYOffset+continueButtonYOffset-continueButtonYSize-(padSize*0.5),
							SizeX = self.state.widgetSize.X*0.7,
							Position = UDim2.new(0.12,0,0,issueTrackerYOffset),
							IssueMessage = self.issueMessage,
							IssueCondition = self.state.IssueCondition,
						}),
						ContinueButton = Roact.createElement(ImageSetButton,{
							Size = UDim2.new(0.84,0,0,continueButtonYSize),
							Position = UDim2.new(0.5,0,1,continueButtonYOffset),
							BackgroundTransparency = 1,
							Image = BACKGROUND_IMAGE_9_SLICE_FILL,
							ImageColor3 = self.state.UsernameValid and CONTINUE_ACTIVE_COLOR or CONTINUE_INACTIVE_COLOR,
							BorderSizePixel = 0,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(8, 8, 9, 9),
							AnchorPoint = Vector2.new(0.5,1),
							[Roact.Event.Activated] = function()
								if self.state.UsernameValid then
									self.props.submitAndContinue(self.props.networking,self.currentInput)
								end
							end,
						},{
							ButtonText = Roact.createElement("TextLabel",{
								Text = localizedText.continue,
								TextColor3 = BACKGROUND_COLOR,
								BackgroundTransparency = 1,
								Size = UDim2.new(1,0,0.4,0),
								Position = UDim2.new(0,0,0.3,0),
								Font = Enum.Font.Gotham,
								TextScaled = true,
							})
						}),
					}),
				})
			end
		})
	end

	return withLocalization({
		continue = "Feature.GameDetails.Action.Continue"
	})(renderUsernamePage)
end

UsernamePage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
		}
	end,
	function(dispatch)
		return {
			validateUsername = function(networking,username,previousIssues)
				return dispatch(UsernameValidator.Validate(networking,username,previousIssues))
			end,
			submitAndContinue = function(networking,username)
				return dispatch(StoreSignUpUsername(networking,username))
			end,
		}
	end
)(UsernamePage)

return RoactServices.connect({
	networking = RoactNetworking,
})(UsernamePage)
