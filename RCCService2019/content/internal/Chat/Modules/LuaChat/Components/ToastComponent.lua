local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp
local LuaChat = Modules.LuaChat

local Create = require(LuaChat.Create)
local Constants = require(LuaChat.Constants)
local FormFactor = require(LuaApp.Enum.FormFactor)
local Text = require(Modules.Common.Text)
local ToastComplete = require(LuaChat.Actions.ToastComplete)

local INITIAL_SIZE = UDim2.new(1, -96, 0, 56)
local POSITION_HIDE = UDim2.new(0.5, 0, 1, 72)
local POSITION_SHOW = UDim2.new(0.5, 0, 1, -56-48)

local TEXT_SIZE = Constants.Font.FONT_SIZE_16
local TEXT_FONT = Constants.Font.STANDARD

local ANIMATION_DURATION = 2
local NORMAL_COMPACT_MINIMUM_WIDTH = 360
local PADDING = 12
local COMPACT_MARGIN = 48
local SMALL_COMPACT_MARGIN = 24
local WIDE_MAXIMUM_WIDTH = 400

local TOAST_BACKGROUND = "rbxasset://textures/ui/LuaChat/9-slice/error-toast.png"

local FFlagLuaChatToastRefactor = settings():GetFFlag("LuaChatToastRefactor369")

local ToastComponent = {}
ToastComponent.__index = ToastComponent

function ToastComponent.new(appState, route)
	local self = {}
	self.appState = appState
	self.route = route
	self.positionHide = POSITION_HIDE
	setmetatable(self, ToastComponent)

	if FFlagLuaChatToastRefactor then
		self.rbx = Create.new"ImageLabel" {
			Name = "ToastComponent",
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = TOAST_BACKGROUND,
			Position = self.positionHide,
			Size = INITIAL_SIZE,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(5, 5, 6, 6),
			Visible = false,

			Create.new"TextLabel" {
				Name = "Message",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = TEXT_FONT,
				Position = UDim2.new(0, PADDING, 0, PADDING),
				Size = UDim2.new(1, -2 * PADDING, 1, -2 * PADDING),
				Text = "",
				TextColor3 = Constants.Color.WHITE,
				TextSize = TEXT_SIZE,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}
		}
	else
		self.rbx = Create.new"Frame" {
			Name = "ToastComponent",
			Size = INITIAL_SIZE,
			Position = POSITION_HIDE,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 0.1,
			BackgroundColor3 = Constants.Color.GRAY1,
			BorderSizePixel = 0,
			Visible = true,
			Create.new"TextLabel" {
				Name = "Message",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = Constants.Font.STANDARD,
				TextSize = TEXT_SIZE,
				TextColor3 = Constants.Color.WHITE,
				Text = "",
				Size = UDim2.new(1, 0, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}
		}
	end


	self.appState.store.changed:connect(function(current, previous)
		if current ~= previous then
			self:Update(current.ChatAppReducer.Toast)
		end
	end)

	return self
end

-- Return the maximum possible width of the toast. This varies per device
-- this is used to calculate the width/height due to text size
function ToastComponent:GetMaxWidth(formFactor)
	if formFactor == FormFactor.WIDE then
		return WIDE_MAXIMUM_WIDTH
	end

	local screenGui = self.rbx:FindFirstAncestorOfClass("ScreenGui")
	local screenWidth = screenGui.AbsoluteSize.X
	return screenWidth - 2 * self:GetMargin(formFactor)
end

-- Return the margins for the toast. This varies if the phone screen is small
-- this is used to calculate the width/height due to text size
function ToastComponent:GetMargin(formFactor)
	local margin = COMPACT_MARGIN

	if formFactor ~= FormFactor.WIDE then
		local screenGui = self.rbx:FindFirstAncestorOfClass("ScreenGui")
		local screenWidth = screenGui.AbsoluteSize.X

		if screenWidth < NORMAL_COMPACT_MINIMUM_WIDTH then
			margin = SMALL_COMPACT_MARGIN
		end
	end

	return margin
end

function ToastComponent:Update(toast)
	if toast == nil then
		return
	end

	-- We don't want to show the toast if another one with the same id is being shown.
	if self.toast and (self.toast.id == toast.id) then
		return
	end

	self.toast = toast
	self:Show(toast)
end

function ToastComponent:Hide()
	self.rbx:TweenPosition(
		self.positionHide,
		Enum.EasingDirection.In,
		Enum.EasingStyle.Quad,
		Constants.Tween.DEFAULT_TWEEN_TIME,
		false,
		function(status)
			self.appState.store:dispatch(ToastComplete(self.toast))
			self.toast = nil
		end
	)
end

function ToastComponent:Show(toast)
	local label = self.rbx.Message
	label.Text = toast.messageKey ~= nil and
		self.appState.localization:Format(toast.messageKey, toast.messageArguments) or ""

	local positionShown
	if FFlagLuaChatToastRefactor then
		local formFactor = self.appState.store:getState().FormFactor

		-- figure out how wide the toast can be
		local maxWidth = self:GetMaxWidth(formFactor)
		-- figure out the margins for hiding/showing the toast
		local margin = self:GetMargin(formFactor)

		-- determine the height/width of the text field to fit inside the toast
		local bounds = Text.GetTextBounds(
			label.Text,
			label.Font,
			label.TextSize,
			Vector2.new(maxWidth - 2 * PADDING, 1000)
		)

		-- scale up the toast to fit the textfield
		local width = bounds.X + 2 * PADDING
		local height = bounds.Y + 2 * PADDING

		positionShown = UDim2.new(0.5, 0, 1, -height - margin)
		self.positionHide = UDim2.new(0.5, 0, 1, height + margin)

		self.rbx.Size = UDim2.new(0, width, 0, height)
		self.rbx.Position = self.positionHide
		self.rbx.Visible = true
	else
		local textWidth = label.TextBounds.X

		self.rbx.Size = UDim2.new(0, textWidth + PADDING * 2, 0, 56)
		self.rbx.Position = POSITION_HIDE

		positionShown = POSITION_SHOW
	end

	self.rbx:TweenPosition(
		positionShown,
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		Constants.Tween.DEFAULT_TWEEN_TIME,
		false,
		function(status)
			wait(ANIMATION_DURATION)
			if self.toast.id == toast.id then
				self:Hide()
			end
		end
	)
end

return ToastComponent
