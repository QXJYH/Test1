local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local withLocalization = require(Modules.LuaApp.withLocalization)

local Colors = require(Modules.LuaApp.Themes.Colors)
local FitChildren = require(Modules.LuaApp.FitChildren)
local Text = require(CorePackages.AppTempCommon.Common.Text)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local TitleAndParagraph = Roact.PureComponent:extend("TitleAndParagraph")

TitleAndParagraph.defaultProps = {
	layoutOrder = 0,
	width = 10,
	maxTitleHeight = 10,
	maxParagraphHeight = 20,
	textXAlignment = Enum.TextXAlignment.Left,
}

function TitleAndParagraph:render()
	local formFactor = self.props.formFactor

	local layoutOrder = self.props.layoutOrder
	local titleTextKey = self.props.titleTextKey
	local paragraphTextKey = self.props.paragraphTextKey

	local width = self.props.width
	local maxTitleHeight = self.props.maxTitleHeight
	local maxParagraphHeight = self.props.maxParagraphHeight
	local textXAlignment = self.props.textXAlignment

	local titleTextDefaultSize = 32
	local titleTextFont = Enum.Font.GothamBold
	local titleTextColor = Colors.White

	local titleParagraphPadding = 15

	local paragraphTextDefaultSize = 16
	local paragraphTextFont = Enum.Font.Gotham
	local paragraphTextColor = Colors.White

	if formFactor == FormFactor.COMPACT then
		titleTextDefaultSize = 20
		titleParagraphPadding = 5
		paragraphTextDefaultSize = 12
	end

	local renderFrame = function(localizedStrings)
		local titleText = localizedStrings.titleText or ""
		local paragraphText = localizedStrings.paragraphText or ""

		local titleFrontText = titleText
		local titleTextBroken = false
		if self.props.breakTitleString then
			local spacePos = #titleText
			while spacePos>0 and string.byte(titleText,spacePos)~=32 do spacePos = spacePos-1 end --Find last space of string
			if spacePos~=0 then
				titleFrontText = string.sub(titleText,1,spacePos-1)
				titleText = titleFrontText.."\n"..string.sub(titleText,spacePos+1)
				titleTextBroken = true
			end
		end


		local titleActualHeight = Text.GetTextHeight(titleFrontText, titleTextFont, titleTextDefaultSize, width)
		local paragraphActualHeight = Text.GetTextHeight(paragraphText, paragraphTextFont, paragraphTextDefaultSize, width)

		local titleHeight = math.min(maxTitleHeight, titleActualHeight)
		local paragraphHeight = math.min(maxParagraphHeight, paragraphActualHeight)

		if titleTextBroken then
			titleHeight = titleHeight+titleHeight
		end

		return Roact.createElement(FitChildren.FitFrame, {
			LayoutOrder = layoutOrder,
			Size = UDim2.new(0, width, 0, 0),
			fitAxis = FitChildren.FitAxis.Height,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, titleParagraphPadding),
			}),
			Title = Roact.createElement("TextLabel", {
				LayoutOrder = 1,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				TextXAlignment = textXAlignment,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = titleText,
				Font = titleTextFont,
				TextColor3 = titleTextColor,
				Size = UDim2.new(1, 0, 0, titleHeight),
				TextScaled = true,
			}, {
				UITextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
					MaxTextSize = titleTextDefaultSize,
				}),
			}),
			Paragraph = Roact.createElement("TextLabel", {
				LayoutOrder = 2,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				TextXAlignment = textXAlignment,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = paragraphText,
				Font = paragraphTextFont,
				TextColor3 = paragraphTextColor,
				Size = UDim2.new(1, 0, 0, paragraphHeight),
				TextScaled = true,
			}, {
				UITextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
					MaxTextSize = paragraphTextDefaultSize,
				}),
			}),
		})
	end

	return withLocalization({
		titleText = titleTextKey,
		paragraphText = paragraphTextKey,
	})(function(localizedStrings)
		return renderFrame(localizedStrings)
	end)
end

TitleAndParagraph = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
		}
	end
)(TitleAndParagraph)

return TitleAndParagraph
