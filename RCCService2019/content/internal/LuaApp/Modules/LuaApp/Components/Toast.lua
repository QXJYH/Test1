local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local RoactMotion = require(Modules.LuaApp.RoactMotion)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local RemoveCurrentToastMessage = require(Modules.LuaApp.Actions.RemoveCurrentToastMessage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local ToastType = require(Modules.LuaApp.Enum.ToastType)

local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local ScreenGuiWithBlurControl = require(Modules.LuaApp.Components.ScreenGuiWithBlurControl)

local LEFT_OUTER_PADDING = 10
local RIGHT_OUTER_PADDING = 10
local MAXIMUM_WIDTH = 400

local BUTTON_DOWN_SCALE = 0.95

local TOAST_SLIDE_STIFFNESS = 400
local TOAST_SLIDE_DAMPING = 38

local TOAST_SLIDE_FAST_STIFFNESS = 900
local TOAST_SLIDE_FAST_DAMPING = 50

local TOAST_TRANSPARENCY_STIFFNESS = 900
local TOAST_TRANSPARENCY_DAMPING = 50

local TOAST_SPRING_PRECISION = 0.5

local DISPLAY_TIMER = 3

local TITLE_TEXT_SIZE = 15
local SUBTITLE_TEXT_SIZE = 13
local TOAST_PADDING_VERTICAL = 4
local TOAST_PADDING_HORIZONTAL = 12
local TOAST_TOP_MARGIN = 12
local TOAST_SLICE_CENTER = Rect.new(18, 18, 18, 18)
local TOAST_IMAGE = "LuaApp/9-slice/gr-capsule-circle"

local isLuaGameDetailsPageEnabled = FlagSettings.IsLuaGameDetailsPageEnabled()
local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")

local Toast = Roact.PureComponent:extend("Toast")

function Toast:openGameDetails(placeId)
	self.props.navigateDown({ name = AppPage.GameDetail, detail = placeId })
end

function Toast:openLuaGameDetails(universeId)
	self.props.navigateDown({ name = AppPage.GameDetail, detail = universeId })
end

function Toast:onButtonUp()
	if self.state.buttonDown then
		self:setState({
			buttonDown = false,
		})
	end
end

function Toast:onButtonDown()
	if not self.state.buttonDown then
		self:setState({
			buttonDown = true,
		})
	end
end

function Toast:open()
	if self.state.close then
		self.positionY = RoactMotion.spring(self.props.topBarHeight + TOAST_TOP_MARGIN,
			TOAST_SLIDE_STIFFNESS, TOAST_SLIDE_DAMPING, TOAST_SPRING_PRECISION)
		self.transparency = RoactMotion.spring(0, TOAST_TRANSPARENCY_STIFFNESS, TOAST_TRANSPARENCY_DAMPING,
			TOAST_SPRING_PRECISION)
		self.onRested = function()
			local currentToastMessage = self.currentToastMessage
			delay(DISPLAY_TIMER, function()
				if self.currentToastMessage == currentToastMessage and not self.state.close then
					self.props.removeCurrentToastMessage()
				end
			end)
		end

		self:setState({
			close = false,
		})
	end
end

function Toast:close()
	if not self.state.close then
		local slideStiffness = self.nextToastMessage and TOAST_SLIDE_FAST_STIFFNESS or TOAST_SLIDE_STIFFNESS
		local slideDamping = self.nextToastMessage and TOAST_SLIDE_FAST_DAMPING or TOAST_SLIDE_DAMPING
		self.positionY = RoactMotion.spring(self.props.topBarHeight, slideStiffness, slideDamping, TOAST_SPRING_PRECISION)
		self.transparency = RoactMotion.spring(1, TOAST_TRANSPARENCY_STIFFNESS, TOAST_TRANSPARENCY_DAMPING,
			TOAST_SPRING_PRECISION)
		self.onRested = function()
			if self.nextToastMessage then
				self.currentToastMessage = self.nextToastMessage
				self.nextToastMessage = nil
				self:open()
			else
				self.currentToastMessage = nil
			end
		end

		self:setState({
			close = true,
		})
	end
end

function Toast:init()
	self.positionY = 0
	self.transparency = 1
	self.onRested = nil

	self.currentToastMessage = nil
	self.nextToastMessage = nil

	self.state = {
		close = true,
		buttonDown = false,
	}

	self.onButtonInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			self:onButtonDown()
		end
	end

	self.onButtonInputEnded = function()
		self:onButtonUp()
	end

	self.onButtonActivated = function()
		self:onButtonUp()
		if self.currentToastMessage then
			local currentToastType = self.currentToastMessage.toastType
			if isLuaGameDetailsPageEnabled then
				local universeId = self.currentToastMessage.universeId
				if currentToastType == ToastType.QuickLaunchError and universeId then
					self:openLuaGameDetails(universeId)
				end
			else
				local placeId = self.currentToastMessage.placeId
				if currentToastType == ToastType.QuickLaunchError and placeId then
					self:openGameDetails(placeId)
				end
			end
			self.props.removeCurrentToastMessage()
		end
	end

	self.onRender = function(values)
		local screenSize = self.props.screenSize
		local localization = self.props.localization

		local currentToastMessage = self.currentToastMessage
		if not currentToastMessage or not next(currentToastMessage) then
			return nil
		end

		local toastMessage = currentToastMessage.toastMessage
		local toastSubMessage = currentToastMessage.toastSubMessage
		local isLocalized = currentToastMessage.isLocalized or false

		if not isLocalized then
			toastMessage = toastMessage and localization:Format(toastMessage) or nil
			toastSubMessage = toastSubMessage and localization:Format(toastSubMessage) or nil
		end

		-- self.calculateToastSpecs(screenSize, self.currentToastMessage, localization)
		local maxTotalWidth = math.min(screenSize.X - LEFT_OUTER_PADDING - RIGHT_OUTER_PADDING, MAXIMUM_WIDTH)
		local maxTextWidth = maxTotalWidth - TOAST_PADDING_HORIZONTAL * 2

		return Roact.createElement(FitChildren.FitImageButton, {
			Size = UDim2.new(1, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, values.positionY),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = TOAST_IMAGE,
			ImageTransparency = values.transparency,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = TOAST_SLICE_CENTER,

			[Roact.Event.InputBegan] = self.onButtonInputBegan,
			[Roact.Event.InputEnded] = self.onButtonInputEnded,
			[Roact.Event.Activated] = self.onButtonActivated,

			fitAxis = FitChildren.FitAxis.Both,
		}, {
			UIScaler = Roact.createElement("UIScale", {
				Scale = self.state.buttonDown and BUTTON_DOWN_SCALE or 1,
			}),
			Layout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, TOAST_PADDING_HORIZONTAL),
				PaddingRight = UDim.new(0, TOAST_PADDING_HORIZONTAL),
				PaddingTop = UDim.new(0, TOAST_PADDING_VERTICAL),
				PaddingBottom = UDim.new(0, TOAST_PADDING_VERTICAL),
			}),
			ToastMessage = Roact.createElement(FitTextLabel, {
				Size = UDim2.new(1, 0, 0, TITLE_TEXT_SIZE),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Enum.Font.SourceSans,
				Text = toastMessage,
				TextSize = TITLE_TEXT_SIZE,
				TextColor3 = Constants.Color.WHITE,
				TextTransparency = values.transparency,
				LayoutOrder = 1,
				maxWidth = maxTextWidth,
				TextWrapped = true,
				fitAxis = FitChildren.FitAxis.Both,
			}),
			ToastSubMessage = toastSubMessage and
				Roact.createElement(FitTextLabel, {
					Size = UDim2.new(0, 0, 0, SUBTITLE_TEXT_SIZE),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = Enum.Font.SourceSans,
					Text = toastSubMessage,
					TextSize = SUBTITLE_TEXT_SIZE,
					TextColor3 = Constants.Color.GRAY3,
					TextTransparency = values.transparency,
					LayoutOrder = 2,
					maxWidth = maxTextWidth,
					TextWrapped = true,
					fitAxis = FitChildren.FitAxis.Both,
				}),
		})
	end
end

function Toast:render()
	local displayOrder = self.props.displayOrder
	local topBarHeight = self.props.topBarHeight
	local currentToastMessage = self.currentToastMessage

	if not currentToastMessage or not next(currentToastMessage) or not currentToastMessage.toastMessage then
		return nil
	end

	return Roact.createElement(FFlagLuaAppEnablePageBlur and ScreenGuiWithBlurControl or "ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = displayOrder,
	}, {
		ToastButton = Roact.createElement(RoactMotion.SimpleMotion, {
			defaultStyle = {
				positionY = topBarHeight,
				transparency = 1,
			},
			style = {
				positionY = self.positionY,
				transparency = self.transparency,
			},
			onRested = self.onRested,
			render = self.onRender,
		}),
	})
end

function Toast:didUpdate(oldProps, oldState)
	if oldProps.currentToastMessage ~= self.props.currentToastMessage then
		-- If currentToastMessage updated, and there was a toastMessage, toast should slide up
		-- Otherwise if there was no toastMessage and there's a new toastMessage, toast should slide down
		local oldToastMessage = oldProps.currentToastMessage
		local newToastMessage = self.props.currentToastMessage
		if next(oldToastMessage) then
			self.nextToastMessage = next(newToastMessage) and newToastMessage or nil
			self:close()
		elseif next(newToastMessage) then
			self.currentToastMessage = newToastMessage
			self:open()
		end
	end

	if oldProps.currentRoute ~= self.props.currentRoute and self.currentToastMessage and
		self.currentToastMessage.toastType == ToastType.QuickLaunchError then
		self.props.removeCurrentToastMessage()
	end
end

Toast = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			currentToastMessage = state.CurrentToastMessage,
			topBarHeight = state.TopBar.topBarHeight,
			currentRoute = state.Navigation.history[#state.Navigation.history],
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			removeCurrentToastMessage = function()
				return dispatch(RemoveCurrentToastMessage())
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(Toast)

return RoactServices.connect({
	localization = RoactLocalization,
})(Toast)
