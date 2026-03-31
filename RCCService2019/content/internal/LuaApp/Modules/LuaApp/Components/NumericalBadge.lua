local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local Text = require(Modules.Common.Text)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local BADGE_IMAGE = "LuaApp/9-slice/notification_badge"
local BADGE_SIZE = 24
local BADGE_SLICE_CENTER = Rect.new(12, 12, 13, 13)

local BADGE_TEXT_PADDING = 3
local BADGE_INNER_PADDING = 2

local MAX_COUNT = 99
local EXPAND_TEXT = "99+"

local NumericalBadge = Roact.PureComponent:extend("NumericalBadge")

NumericalBadge.defaultProps = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, 0, 0, 0),
	badgeCount = 0,
	inAppChrome = false,
}

function NumericalBadge:render()
	local badgeTheme = self._context.AppTheme.NumericalBadge

	local anchorPoint = self.props.AnchorPoint
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder

	local badgeCount = self.props.badgeCount
	local inAppChrome = self.props.inAppChrome

	if type(badgeCount) ~= "number" or badgeCount <= 0 then
		return nil
	end

	local function renderBadge(borderStyle, innerStyle, textStyle)
		local countText = badgeCount > MAX_COUNT and EXPAND_TEXT or tostring(badgeCount)
		local countTextWidth = Text.GetTextWidth(countText, textStyle.Font, textStyle.TextSize)

		local totalWidth = countTextWidth + BADGE_TEXT_PADDING * 2 + BADGE_INNER_PADDING * 2
		totalWidth = math.max(BADGE_SIZE, totalWidth)

		return Roact.createElement(ImageSetLabel, {
			AnchorPoint = anchorPoint,
			Position = position,
			Size = UDim2.new(0, totalWidth, 0, BADGE_SIZE),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = BADGE_IMAGE,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = BADGE_SLICE_CENTER,
			ImageColor3 = borderStyle.Color,
			ImageTransparency = borderStyle.Transparency,
			LayoutOrder = layoutOrder,
		}, {
			InnerBadge = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -BADGE_INNER_PADDING * 2, 1, -BADGE_INNER_PADDING * 2),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = BADGE_IMAGE,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = BADGE_SLICE_CENTER,
				ImageColor3 = innerStyle.Color,
				ImageTransparency = innerStyle.Transparency,
			}, {
				Count = Roact.createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, countTextWidth, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = textStyle.Font,
					Text = countText,
					TextSize = textStyle.TextSize,
					TextColor3 = textStyle.TextColor3,
					TextTransparency = textStyle.TextTransparency,
				}),
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			local textStyle = {
				Font = style.Font.Footer.Font,
				TextSize = style.Font.Footer.RelativeSize * style.Font.BaseSize,
				TextColor3 = style.Theme.SystemPrimaryContent.Color,
				TextTransparency = style.Theme.SystemPrimaryContent.Transparency,
			}
			return renderBadge(style.Theme.BackgroundDefault, style.Theme.SystemPrimaryDefault, textStyle)
		end)
	else
		local borderStyle = {
			Color = inAppChrome and badgeTheme.Border.AppChrome.Color or badgeTheme.Border.Default.Color,
			Transparency = inAppChrome and badgeTheme.Border.AppChrome.Transparency or
				badgeTheme.Border.Default.Transparency
		}

		local innerStyle = {
			Color = badgeTheme.Inner.Color,
			Transparency = badgeTheme.Inner.Transparency
		}

		local textStyle = {
			Font = badgeTheme.Text.Font,
			TextSize = badgeTheme.Text.Size,
			TextColor3 = badgeTheme.Text.Color,
			TextTransparency = 0,
		}

		return renderBadge(borderStyle, innerStyle, textStyle)
	end
end

return NumericalBadge