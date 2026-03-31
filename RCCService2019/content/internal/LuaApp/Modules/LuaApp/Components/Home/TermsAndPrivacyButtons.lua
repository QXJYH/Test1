local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local FitChildren = require(Modules.LuaApp.FitChildren)
local AgreementButton = require(Modules.LuaApp.Components.Home.AgreementButton)
local AgreementPageType = require(Modules.LuaApp.Enum.AgreementPageType)
local Constants = require(Modules.LuaApp.Constants)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local TermsAndPrivacyButtons = Roact.PureComponent:extend("TermsAndPrivacyButtons")

function TermsAndPrivacyButtons:render()
	ArgCheck.isType(self.props.textHeight, "number", "self.props.textHeight")
	ArgCheck.isType(self.props.TextSize, "number", "self.props.TextSize")
	
	local theme = self._context.AppTheme
	local textHeight = self.props.textHeight
	local TextSize = self.props.TextSize

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BackgroundTransparency = 1,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
		}),
		PrivacyButton = Roact.createElement(AgreementButton, {
			pageId = AgreementPageType.Privacy,
			textHeight = textHeight,
			TextSize = TextSize,
			LayoutOrder = 1,
		}),
		Divider = Roact.createElement("Frame", {
			Size = UDim2.new(0, 1, 0, textHeight),
			BackgroundColor3 = theme.Buttons.AgreementButton.Text.Color,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}),
		TermsButton = Roact.createElement(AgreementButton, {
			pageId = AgreementPageType.Terms,
			textHeight = textHeight,
			TextSize = TextSize,
			LayoutOrder = 3,
		}),
	})
end

return TermsAndPrivacyButtons