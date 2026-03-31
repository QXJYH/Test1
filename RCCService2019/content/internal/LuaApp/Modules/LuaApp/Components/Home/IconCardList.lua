local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)
local GetGridLayoutSettings = require(Modules.LuaApp.GetGridLayoutSettings)

local IconCardList = Roact.PureComponent:extend("IconCardList")

local PADDING = 10

IconCardList.defaultProps = {
	anchorPoint = Vector2.new(0.5, 0.5),
	position = UDim2.new(0.5, 0, 0.5, 0),
	loadingImage = "",
	textSize = 16,
}

function IconCardList:render()
	local theme = self._context.AppTheme.IconCards
	local loadingImage = self.props.loadingImage
	local anchorPoint = self.props.anchorPoint
	local position = self.props.position
	local padding = self.props.padding or PADDING
	local width = self.props.width
	local emptyText = self.props.emptyText
	local textSize = self.props.textSize
	local iconUrls = self.props.iconUrls
	local cardBorderSizePixel = self.props.borderSizePixel
	local cardBackgroundColor = self.props.backgroundColor
	local cardCount, cardWidth = GetGridLayoutSettings.Small(width, padding)
	local cardSize = UDim2.new(0, cardWidth, 0, cardWidth)
	local size = UDim2.new(0, width, 0, cardWidth)
	local iconsList

	--Add 1 more card to show that there are more content
	cardCount = cardCount + 1

	-- if number of icons unknown, show all as loading
	if iconUrls == nil then
		iconUrls = {}
		for i = 0, cardCount do
			table.insert(iconUrls, "")
		end
	end

	if iconUrls == nil or next(iconUrls) == nil then
		iconsList =  Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = emptyText,
			Font = theme.Text.Font,
			TextColor3 = theme.Text.Color,
			TextSize = textSize,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		})
	else
		local icons = {}
		icons.uiListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, padding),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		-- NOTE: UIBlox's LoadableImage will no longer support empty strings.
		--		Instead of getting each empty string from iconUrls, consider
		--		iterating through cardCount to create LoadableImage components.
		for k, iconUrl in ipairs(iconUrls) do
			cardCount = cardCount -1
			icons[k] = Roact.createElement(LoadableImage, {
				Size = cardSize,
				Image = iconUrl,
				BorderSizePixel = cardBorderSizePixel,
				BackgroundColor3 = cardBackgroundColor,
				useShimmerAnimationWhileLoading = true,
				LayoutOrder = k,
			})
			if cardCount == 0 then
				break
			end
		end

		iconsList = Roact.createElement("Frame", {
			AnchorPoint = anchorPoint,
			Position = position,
			Size = size,
			BackgroundTransparency = 1,
		}, icons)
	end
	return iconsList
end

return IconCardList
