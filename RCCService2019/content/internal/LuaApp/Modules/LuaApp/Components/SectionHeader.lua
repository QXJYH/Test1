local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local LocalizedFitTextLabel = require(Modules.LuaApp.Components.LocalizedFitTextLabel)
local Text = require(Modules.Common.Text)

local SECTION_HEADER_HEIGHT = Constants.SECTION_HEADER_HEIGHT

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()
--NOTE: remove when UseNewAppStyle is removed
local TEXT_SIZE = SECTION_HEADER_HEIGHT
local TEXT_FONT = Enum.Font.SourceSansLight

local SectionHeader = Roact.PureComponent:extend("SectionHeader")

SectionHeader.defaultProps = {
	Size = UDim2.new(1, 0, 0, SECTION_HEADER_HEIGHT),
	--NOTE: remove this color default when UseNewAppStyle is cleaned up
	TextColor3 = Constants.Color.GRAY1,
	useLocalizedText = false,
}

function SectionHeader:render()
	local text = self.props.text
	local layoutOrder = self.props.LayoutOrder
	local size = self.props.Size
	local position = self.props.Position
	local textColor = self.props.TextColor3
	local textTransparency = self.props.TextTransparency
	local useLocalizedText = self.props.useLocalizedText

	local renderFunction = function(style)

		local textFont = TEXT_FONT
		local textSize = TEXT_SIZE
		if style then
			local font = style.Font
			local theme = style.Theme
			textFont = font.Header1.Font
			textSize = font.BaseSize * font.Header1.RelativeSize
			textColor = theme.TextEmphasis.Color
			textTransparency = theme.TextEmphasis.Transparency

			local textHeight = Text.GetTextHeight(text, textFont, textSize, 10000)
			size = UDim2.new(1, 0, 0, textHeight)
		end

		return Roact.createElement(useLocalizedText and LocalizedFitTextLabel or FitTextLabel, {
			LayoutOrder = layoutOrder,
			Size = size,
			Position = position,
			BackgroundTransparency = 1,
			TextSize = textSize,
			TextColor3 = textColor,
			TextTransparency = textTransparency,
			Font = textFont,
			Text = text,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			fitAxis = FitChildren.FitAxis.Height,
		})
	end

	if UseNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction()
	end
end

return SectionHeader