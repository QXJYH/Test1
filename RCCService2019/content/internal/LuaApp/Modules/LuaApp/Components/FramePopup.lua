local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FitChildren = require(Modules.LuaApp.FitChildren)
local RoactMotion = require(Modules.LuaApp.RoactMotion)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local LocalizedTextButton = require(Modules.LuaApp.Components.LocalizedTextButton)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

-- Some defaults:
local SEPARATOR_HEIGHT = 1
local CANCEL_FONT = Enum.Font.SourceSans
local CANCEL_FONT_SIZE = 23
local CANCEL_HEIGHT = Constants.DEFAULT_CONTEXTUAL_MENU_CANCEL_HEIGHT
local CANCEL_TEXT_COLOR = Constants.Color.GREY1
local CANCEL_ICON

if UseNewAppStyle then
	CANCEL_ICON = "LuaApp/icons/GameDetails/navigation/close"
else
	CANCEL_ICON = "LuaApp/category/ic-cancel"
end

local ICON_SIZE = 20
local ICON_HORIZONTAL_SPACE = 20

local DROPDOWN_TEXT_MARGIN = 10

local FramePopup = Roact.PureComponent:extend("FramePopup")

FramePopup.defaultProps = {
	enableCancelButton = true,
}

function FramePopup:init()
	self.state = {
		hidden = true,
	}

	-- Initialize parameters for Roact Motion
	self.yAnchorPoint = self.state.hidden and 0 or 1
	self.stiffness = nil -- use default stiffness
	self.damping = nil -- use default damping
	self.onRested = nil

	self.closeCallback = function()
		self:close()
	end

	self.onRender = function(values)
		local children = self.props[Roact.Children]
		local enableCancelButton = self.props.enableCancelButton
		local contentPosition = self.props.contentPosition
		local screenSize = self.props.screenSize

		-- Text offset to make space for the cancel icon (padding doesn't work for text):
		local iconSpacing = ICON_SIZE + (ICON_HORIZONTAL_SPACE * 2)

		local position = UDim2.new(0, 0, 1, 0)
		if contentPosition then
			position = UDim2.new(0, 0, 0, screenSize.Y)
		end

		if UseNewAppStyle then
			return withStyle(function(style)
				return Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					Position = position,
					AnchorPoint = Vector2.new(0, values.yAnchorPoint),
					BorderSizePixel = 0,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					-- Use UIPadding to make content correctly placed
					UIPadding = contentPosition and Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, screenSize.X * contentPosition.X.Scale + contentPosition.X.Offset),
						PaddingBottom = UDim.new(0, screenSize.Y - (screenSize.Y * contentPosition.Y.Scale + contentPosition.Y.Offset)),
					}),
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
					}),
					Frame = Roact.createElement(FitChildren.FitFrame, {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 1,
						Size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
					}, children),
					Separator = enableCancelButton and Roact.createElement("Frame", {
						BackgroundColor3 = style.Theme.Divider.Color,
						BackgroundTransparency = style.Theme.Divider.Transparency,
						BorderSizePixel = 0,
						LayoutOrder = 2,
						Size = UDim2.new(1, 0, 0, SEPARATOR_HEIGHT),
					}),
					Cancel = enableCancelButton and Roact.createElement("Frame", {
						BorderSizePixel = 0,
						LayoutOrder = 3,
						BackgroundColor3 = style.Theme.BackgroundUIDefault.Color,
						BackgroundTransparency = style.Theme.BackgroundUIDefault.Transparency,
						Size = UDim2.new(1, 0, 0, CANCEL_HEIGHT),
					}, {
						Icon = Roact.createElement(ImageSetButton, {
							AnchorPoint = Vector2.new(0, 0.5),
							AutoButtonColor = false,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ClipsDescendants = false,
							Image = CANCEL_ICON,
							ImageColor3 = style.Theme.IconDefault.Color,
							ImageTransparency = style.Theme.IconDefault.Transparency,
							Position = UDim2.new(0, ICON_HORIZONTAL_SPACE, 0.5, 0),
							Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
						}),
						Cancel = Roact.createElement(LocalizedTextButton, {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundColor3 = Constants.Color.WHITE,
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							Position = UDim2.new(0, iconSpacing, 0.5, 0),
							Size = UDim2.new(1, -(iconSpacing + DROPDOWN_TEXT_MARGIN), 1, 0),
							Text = "Feature.GamePage.LabelCancelField",
							Font = style.Font.Body.Font,
							TextSize = style.Font.BaseSize * style.Font.Body.RelativeSize,
							TextColor3 = style.Theme.TextDefault.Color,
							TextTransparency = style.Theme.TextDefault.Transparency,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							[Roact.Event.Activated] = self.closeCallback,
						}), -- Cancel Button
					}), -- Cancel Frame
				}) -- Popup Frame
			end)
		else
			return Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Position = position,
				AnchorPoint = Vector2.new(0, values.yAnchorPoint),
				BorderSizePixel = 0,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				-- Use UIPadding to make content correctly placed
				UIPadding = contentPosition and Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, screenSize.X * contentPosition.X.Scale + contentPosition.X.Offset),
					PaddingBottom = UDim.new(0, screenSize.Y - (screenSize.Y * contentPosition.Y.Scale + contentPosition.Y.Offset)),
				}),
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
				}),
				Frame = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 0),
					fitAxis = FitChildren.FitAxis.Height,
				}, children),
				Separator = enableCancelButton and Roact.createElement("Frame", {
					BackgroundColor3 = Constants.Color.GRAY4,
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, SEPARATOR_HEIGHT),
				}),
				Cancel = enableCancelButton and Roact.createElement("Frame", {
					BorderSizePixel = 0,
					LayoutOrder = 3,
					BackgroundColor3 = Constants.Color.WHITE,
					BackgroundTransparency = 0,
					Size = UDim2.new(1, 0, 0, CANCEL_HEIGHT),
				}, {
					Icon = Roact.createElement(ImageSetButton, {
						AnchorPoint = Vector2.new(0, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Constants.Color.WHITE,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = false,
						Image = CANCEL_ICON,
						Position = UDim2.new(0, ICON_HORIZONTAL_SPACE, 0.5, 0),
						Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
					}),
					Cancel = Roact.createElement(LocalizedTextButton, {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Constants.Color.WHITE,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Font = CANCEL_FONT,
						Position = UDim2.new(0, iconSpacing, 0.5, 0),
						Size = UDim2.new(1, -(iconSpacing + DROPDOWN_TEXT_MARGIN), 1, 0),
						Text = "Feature.GamePage.LabelCancelField",
						TextColor3 = CANCEL_TEXT_COLOR,
						TextSize = CANCEL_FONT_SIZE,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						[Roact.Event.Activated] = self.closeCallback,
					}), -- Cancel Button
				}), -- Cancel Frame
			}) -- Popup Frame
		end -- Render Function
	end
end

function FramePopup:open()
	self.yAnchorPoint = 1
	self.stiffness = nil
	self.damping = nil
	self.onRested = nil

	self:setState({
		hidden = false,
	})
end

function FramePopup:close()
	local onCancel = self.props.onCancel
	self.yAnchorPoint = 0
	-- Closing animation should be a bit faster than the open animation
	self.stiffness = 270
	self.damping = nil
	self.onRested = onCancel

	self:setState({
		hidden = true,
	})
end

function FramePopup:didMount()
	self:open()
end

function FramePopup:render()
	return Roact.createElement("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		[Roact.Event.Activated] = self.closeCallback,
	}, {
		AnimatedPopup = Roact.createElement(RoactMotion.SimpleMotion, {
			style = {
				yAnchorPoint = RoactMotion.spring(self.yAnchorPoint, self.stiffness, self.damping),
			},
			onRested = self.onRested,
			render = self.onRender,
		}) -- Animated Popup
	}) -- Transparent Popup Background
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
		}
	end
)(FramePopup)
