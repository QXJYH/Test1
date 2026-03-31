local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local HomePageWidget = require(Modules.LuaApp.Components.Home.HomePageWidget)
local IconCardList = require(Modules.LuaApp.Components.Home.IconCardList)
local Constants = require(Modules.LuaApp.Constants)

local EMPTY_TEXT_SIZE = Constants.HomePagePanelProps.WidgetContentText.Size

local HomePageIconListWidget = Roact.PureComponent:extend("HomePageIconListWidget")

local DEFAULT_CONTENT_PADDING = {
	PaddingTop = UDim.new(0, 11),
	PaddingBottom = UDim.new(0, 30),
	PaddingLeft = UDim.new(0, 20),
	PaddingRight = UDim.new(0, 20),
}

HomePageIconListWidget.defaultProps = {
	renderWidth = 375,
	anchorPoint = Vector2.new(0.5, 0.5),
	position = UDim2.new(0.5, 0, 0.5, 0),
	contentPadding = DEFAULT_CONTENT_PADDING,
	cardPadding = 10,
}

function HomePageIconListWidget:render()
	local contentPadding = self.props.contentPadding
	local titleIcon = self.props.titleIcon
	local titleText = self.props.titleText
	local onActivated = self.props.onActivated

	local renderContent = function()
		local contentPadding = self.props.contentPadding
		--Subtracting the paddings from the render width to get the desired 1 extra icon being shown.
		local renderWidth = self.props.renderWidth - contentPadding.PaddingLeft.Offset - contentPadding.PaddingRight.Offset
		local cardPadding = self.props.cardPadding
		local emptyText = self.props.emptyText
		local iconUrls = self.props.iconUrls

		return Roact.createElement(IconCardList, {
			emptyText = emptyText,
			textSize = EMPTY_TEXT_SIZE,
			width = renderWidth,
			iconUrls = iconUrls,
			padding = cardPadding,
		})
	end

	return Roact.createElement(HomePageWidget, {
		icon = titleIcon,
		titleKey = titleText,
		contentPadding = contentPadding,
		renderContent = renderContent,
		onActivated = onActivated,
	})
end

return HomePageIconListWidget