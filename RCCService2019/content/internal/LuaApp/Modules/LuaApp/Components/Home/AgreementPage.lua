local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local AppPageWithNavigationBar = require(Modules.LuaApp.Components.Generic.AppPageWithNavigationBar)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local AgreementPageText = require(Modules.LuaApp.Components.Home.AgreementPageText)

local AgreementPage = Roact.PureComponent:extend("AgreementPage")

function AgreementPage:renderContent()
	local theme = self._context.AppTheme
	local textList = AgreementPageText[self.props.pageId].TextList

	local childElems = {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 5),
		}),
	}

	for i = 1, #textList do
		local TextBox = Roact.createElement(FitTextLabel, {
			Active = false,
			Size = UDim2.new(1, 0, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			LayoutOrder = i,
			TextColor3 = theme.AgreementPage.Text.Color,
			BackgroundColor3 = theme.AgreementPage.Background.Color,
			TextSize = theme.AgreementPage.Text.Size,
			BorderSizePixel = 0,

			Text = textList[i],
		})

		table.insert( childElems, TextBox )
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = theme.AgreementPage.Background.Color,
		BorderSizePixel = 0,
		fitAxis = FitChildren.FitAxis.Height,
	},
		childElems
	)
end

function AgreementPage:render()
	local theme = self._context.AppTheme

	ArgCheck.isType(self.props.pageId, "string", "AgreementPage expects pageId to be a string")

	local nameLocalizationKey = AgreementPageText[self.props.pageId].Title

	return Roact.createElement(AppPageWithNavigationBar, {
			title = nameLocalizationKey,
			BackgroundColor3 = theme.AgreementPage.Background.Color,
			renderContentOnLoaded = function(...)
				return self:renderContent(...)
			end
		})
end

return AgreementPage