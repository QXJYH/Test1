local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local LocalizedFitTextLabel = require(Modules.LuaApp.Components.LocalizedFitTextLabel)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

-- TODO: replace with actual specs ...
local DEFAULT_TEXT_FONT = Enum.Font.SourceSans
local DEFAULT_TEXT_SIZE = 23
local ICON_SIZE = 36
local ICON_HORIZONTAL_PADDING = 10
local ICON_VERTICAL_PADDING = 15 -- refers to (66 - ICON_SIZE) / 2

local TextMeasureTemporaryPatch = settings():GetFFlag("TextMeasureTemporaryPatch")

-- TODO(CLIPLAYEREX-1633): We can remove this padding patch after fixing TextService:GetTextSize sizing bug
-- When the flag TextMeasureTemporaryPatch is on, Text.GetTextHeight() would add 2px to the total height and width
local TEXT_VERTICAL_PADDING = TextMeasureTemporaryPatch and 21 or 22 -- refers to (66 - DEFAULT_TEXT_SIZE) / 2

local ListCell = Roact.PureComponent:extend("ListCell")

ListCell.defaultProps = {
	textLocalization = false,
}

function ListCell:init()
	self.state = {
		cellPressed = false,
	}

	self.onInputBegan = function(_, inputObject)
		if (inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) and
			inputObject.UserInputState == Enum.UserInputState.Begin then
			if not self.state.cellPressed then
				self:setState({
					cellPressed = true,
				})
			end
		end
	end

	self.onInputEnd = function()
		if self.state.cellPressed then
			self:setState({
				cellPressed = false,
			})
		end
	end

	self.onActivated = function()
		local item = self.props.item
		item.onActivated()
	end
end

-- Returns a list of items (with text and an icon) that the user can pick from.
-- Intended to be the core functionality of the DropDownList control.
function ListCell:render()
	local item = self.props.item
	local layoutOrder = self.props.layoutOrder
	local cellPressed = self.state.cellPressed
	local iconFrameWidth = ICON_SIZE + 2 * ICON_HORIZONTAL_PADDING
	local menuTheme = self._context.AppTheme.ContextualMenu
	local iconTransparency = menuTheme.Cells.Icon.Transparency

	if item.checked then
		iconTransparency = menuTheme.Cells.Icon.OnTransparency
	elseif item.disabled then
		cellPressed = false
		iconTransparency = menuTheme.Cells.Icon.DisabledTransparency
	end

	return Roact.createElement(FitChildren.FitImageButton, {
		BackgroundTransparency = cellPressed and menuTheme.Cells.Background.OnPressTransparency or 1.0,
		BackgroundColor3 = menuTheme.Cells.Background.OnPressColor,
		BorderSizePixel = 0,
		fitAxis = FitChildren.FitAxis.Height,
		ClipsDescendants = false,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		[Roact.Event.Activated] = self.onActivated,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnd,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Icon = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			fitAxis = FitChildren.FitAxis.Height,
			Size = UDim2.new(0, iconFrameWidth, 0, 0),
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, ICON_VERTICAL_PADDING),
				PaddingLeft = UDim.new(0, ICON_HORIZONTAL_PADDING),
			}),

			Image = Roact.createElement(ImageSetLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = item.checked and item.displayIconChecked or item.displayIcon,
				ImageColor3 = item.checked and
					menuTheme.Cells.Icon.OnColor or menuTheme.Cells.Icon.Color,
				ImageTransparency = iconTransparency,
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
			}),
		}),

		Content = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			fitAxis = FitChildren.FitAxis.Height,
			LayoutOrder = 2,
			Size = UDim2.new(1, -iconFrameWidth, 0, 0),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TopPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, TEXT_VERTICAL_PADDING),
			}),

			TextContent = Roact.createElement(item.textLocalization and LocalizedFitTextLabel or FitTextLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = DEFAULT_TEXT_FONT,
				LayoutOrder = 2,
				Size = UDim2.new(1, -ICON_HORIZONTAL_PADDING, 0, 0),
				Text = item.checked and item.textChecked or item.text,
				TextColor3 = menuTheme.Title.Color,
				TextTransparency = item.disabled and
					menuTheme.Title.DisabledTransparency or menuTheme.Title.Transparency,
				TextSize = DEFAULT_TEXT_SIZE,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				fitAxis = FitChildren.FitAxis.Height,
			}),

			UIBottomPadding = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, TEXT_VERTICAL_PADDING),
				LayoutOrder = 3,
			}),
		})
	})
end

return ListCell