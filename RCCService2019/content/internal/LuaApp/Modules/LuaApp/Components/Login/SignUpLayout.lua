local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)

local ItemListLayout = require(Modules.LuaApp.Components.Generic.ItemListLayout)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)

local TitleAndParagraph = require(Modules.LuaApp.Components.Login.TitleAndParagraph)

local CLOSE_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/close"
local BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"

local NAVIGATION_ICON_MIN_SIZE = 27
local NAVIGATION_ICON_SCALE = 0.12

local CONTENT_VERTICAL_PADDING_COMPACT = 5
local CONTENT_VERTICAL_PADDING_WIDE = 25

local LEFT_SCREEN_RATIO = 0.55

local MAX_CONTENT_WIDTH = 400
local MAX_TITLE_HEIGHT = 60
local MAX_PARAGRAPH_HEIGHT = 200

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local SignUpLayout = Roact.PureComponent:extend("SignUpLayout")

SignUpLayout.defaultProps = {
	widgetScaleDefault = 0.635,
	widgetScaleMin = 0.38,
	widgetScaleWideMode = 0.3,
}

function SignUpLayout:init()
	self.state = {
		containerSize = Vector2.new(0, 0),
		keyboardScale = 0,
		keyboardOffset = 0,
	}

	self.isMounted = false

	self.onAbsoluteSizeChanged = function(rbx)
		local newAbsoluteSize = rbx.AbsoluteSize
		if newAbsoluteSize.X > 0 and newAbsoluteSize.Y > 0 then
			-- Spawn since setstate can be triggered while a component is being reified or reconciled.
			-- This can be fixed with event suspension in new reconciler.
			spawn(function()
				if self.isMounted then
					self:setState({
						containerSize = newAbsoluteSize,
					})
				end
			end)
		end
	end

	self.keyboardEvent = UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible"):connect(function()
		local newScale = 0
		local keyboardOffset = 0
		local containerSizeY = self.state.containerSize.Y
		if containerSizeY>0 and UserInputService.OnScreenKeyboardVisible then
			keyboardOffset = UserInputService.OnScreenKeyboardPosition.Y-containerSizeY-20 --Offset for keyboard and predictive text
			newScale = (containerSizeY-UserInputService.OnScreenKeyboardPosition.Y)/containerSizeY
		end
		spawn(function()
			self:setState({
				keyboardScale = newScale,
				keyboardOffset = keyboardOffset,
			})
		end)
	end)
end

function SignUpLayout:didMount()
	self.isMounted = true
end

function SignUpLayout:willUnmount()
	self.isMounted = false
	if self.keyboardEvent then
		self.keyboardEvent:disconnect()
		self.keyboardEvent = nil
	end
end

local function renderTopButton(props)
	local layoutOrder = props.layoutOrder or 0
	local showCloseIcon = props.showCloseIcon
	local image = BACK_BUTTON_IMAGE

	if showCloseIcon then
		image = CLOSE_BUTTON_IMAGE
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement(ImageSetButton, {
				LayoutOrder = layoutOrder,
				Size = UDim2.new(1, 0, 0, props.buttonSize),
				Image = image,
				ImageColor3 = style.Theme.TextEmphasis.Color,
				ImageTransparency = style.Theme.TextEmphasis.Transparency,
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = function() end,
			})
		end)
	else
		return Roact.createElement(ImageSetButton, {
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 0, props.buttonSize),
			Image = image,
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = function() end,
		},{
			Roact.createElement("UIAspectRatioConstraint")
		})
	end
end

function SignUpLayout:render()
	local titleTextKey = self.props.titleTextKey
	local paragraphTextKey = self.props.paragraphTextKey
	local renderWidget = self.props.renderWidget

	local formFactor = self.props.formFactor

	local isWideView = formFactor == FormFactor.WIDE

	local containerSize = self.state.containerSize
	local keyboardScale = self.state.keyboardScale
	local widgetScale = math.max(keyboardScale+self.props.widgetScaleMin,self.props.widgetScaleDefault)

	local contentPosition = UDim2.new(LEFT_SCREEN_RATIO, 0, 0.5, 0)
	local contentAnchorPoint = Vector2.new(1, 0.5)
	local textBoxWidth = MAX_CONTENT_WIDTH

	local shortestEdge = math.min(containerSize.X,containerSize.Y)-40
	if shortestEdge < MAX_CONTENT_WIDTH / LEFT_SCREEN_RATIO then
		contentPosition = UDim2.new(0, 0, 0.5, 0)
		contentAnchorPoint = Vector2.new(0, 0.5)
		textBoxWidth = shortestEdge * LEFT_SCREEN_RATIO
	end

	if isWideView and UserInputService.OnScreenKeyboardVisible then
		contentPosition = UDim2.new(contentPosition.X.Scale,0,0,0)
		contentAnchorPoint = Vector2.new(contentAnchorPoint.X,0)
	end

	local canBreakTitleText = true

	local useTitleHeight = MAX_TITLE_HEIGHT
	local useParagraphHeight = MAX_PARAGRAPH_HEIGHT

	--scale down text if widget is to large
	if not isWideView then
		local approxScreenSpace = containerSize.Y*(1-widgetScale)
		useTitleHeight = math.min(approxScreenSpace*0.12,useTitleHeight)
		useParagraphHeight = math.min(approxScreenSpace*0.3,useParagraphHeight)

		if approxScreenSpace<100 then --if not enough screen space, cut paragraph and make title bigger
			useTitleHeight = useTitleHeight+useTitleHeight
			paragraphTextKey = nil
		end
	end

	local backButtonSize = math.max(
		math.min(containerSize.X,containerSize.Y)*NAVIGATION_ICON_SCALE,
		NAVIGATION_ICON_MIN_SIZE
	)

	local content
	if isWideView then
		content = {
			Container = Roact.createElement("Frame",{
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5,0,0,0),
				Size = UDim2.new(1,0,1,-20),
				AnchorPoint = Vector2.new(0.5,0)
			},{
				AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
				ContentWrapper = Roact.createElement(FitChildren.FitFrame, {
					Size = UDim2.new(LEFT_SCREEN_RATIO, 0, 1, 0),
					Position = contentPosition,
					AnchorPoint = contentAnchorPoint,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					Content = Roact.createElement(ItemListLayout, {
						size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
						Padding = UDim.new(0, CONTENT_VERTICAL_PADDING_WIDE),
						renderItemList = {
							Roact.createElement(renderTopButton, {
								showCloseIcon = self.props.showCloseIcon,
								buttonSize = backButtonSize*0.6,
							}),
							Roact.createElement(TitleAndParagraph, {
								titleTextKey = titleTextKey,
								paragraphTextKey = paragraphTextKey,
								width = textBoxWidth,
								maxTitleHeight = useTitleHeight,
								maxParagraphHeight = useParagraphHeight,
							}),
							Roact.createElement(FitChildren.FitFrame, {
								Size = UDim2.new(1, 0, 0, 0),
								fitAxis = FitChildren.FitAxis.Height,
								BorderSizePixel = 0,
								BackgroundTransparency = 1,
							}, {
								Widget = renderWidget and renderWidget({
									formFactor = formFactor,
									containerSize = containerSize,
									widgetSize = self.props.widgetScaleWideMode*containerSize.Y,
									keyboardOffset = 0,
								}),
							}),
						},
					}),
				}),
			}),
		}
	else
		content = {
			ContentWrapper = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				fitAxis = FitChildren.FitAxis.Height,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				ListLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, CONTENT_VERTICAL_PADDING_COMPACT),
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 20),
					PaddingRight = UDim.new(0, 20),
				}),
				TopButton = Roact.createElement(renderTopButton, {
					layoutOrder = 1,
					showCloseIcon = self.props.showCloseIcon,
					buttonSize = backButtonSize,
				}),
				TitleAndParagraph = Roact.createElement(TitleAndParagraph, {
					layoutOrder = 2,
					titleTextKey = titleTextKey,
					paragraphTextKey = paragraphTextKey,
					width = textBoxWidth,
					maxTitleHeight = useTitleHeight,
					maxParagraphHeight = useParagraphHeight,
					breakTitleString = canBreakTitleText,
				}),
			}),
			WidgetWrapper = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				fitAxis = FitChildren.FitAxis.Height,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 1, 0),
				AnchorPoint = Vector2.new(0.5, 1),
			}, {
				Widget = renderWidget and renderWidget({
					formFactor = formFactor,
					containerSize = containerSize,
					widgetSize = widgetScale*containerSize.Y,
					keyboardOffset = self.state.keyboardOffset,
				}),
			}),
		}
	end

	return Roact.createElement(FullscreenPageWithSafeArea, {
		BackgroundTransparency = 1,
		includeStatusBar = true,
		renderFullscreenBackground = function()
			local AspectRatio = 1 --isWideView and BG_WIDE_ASPECT_RATIO or BG_COMPACT_ASPECT_RATIO
			local Size = UDim2.new(2,0,1,0)
			if self.state.containerSize.X/self.state.containerSize.Y>AspectRatio then
				Size = UDim2.new(1,0,2,0)
			end

			return Roact.createElement("Frame",{ --Temporary background frame
				--Image = isWideView and BG_WIDE_IMAGE or BG_COMPACT_IMAGE,
				BackgroundColor3 = Color3.new(0,0,0),
				Size = Size,
				Position = UDim2.new(0.5,0,0,0),
				AnchorPoint = Vector2.new(0.5,0),
				BorderSizePixel = 0
			},{
				AspectRatio = Roact.createElement("UIAspectRatioConstraint",{
					AspectRatio = AspectRatio,
				})
			})
		end
	},{
		ContentFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
		}, content),
	})
end

local function shouldShowCloseIcon()
	-- TODO This should depend on navigation history. Given that new roact-navigation is in the works
	-- and that we didn't hook up pages in the context of app navigation, just returning a random value.
	--
	-- Reference: GameDetailsTopBar.lua
	return false
end

SignUpLayout = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			showCloseIcon = shouldShowCloseIcon(),
		}
	end
)(SignUpLayout)

return SignUpLayout
