local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local ArgCheck = require(CorePackages.ArgCheck)
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local MoreList = Roact.PureComponent:extend("MoreList")

MoreList.defaultProps = {
	LayoutOrder = 1,
}

function MoreList:render()
	local theme = self._context.AppTheme

	local layoutOrder = self.props.LayoutOrder
	local itemList = self.props.itemList
	local renderItem = self.props.renderItem
	local rowHeight = self.props.rowHeight

	ArgCheck.isType(renderItem, "function", "MoreList.props.renderItem")

	if not itemList or #itemList == 0 then
		return
	end

	local renderMoreList = function(backgroundStyle, dividerStyle)
		local listContents = {}

		listContents["Layout"] = #itemList > 1 and Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		})

		for index, item in ipairs(itemList) do
			local hasDivider = index < #itemList
			local itemLayoutInfo = {
				Size = UDim2.new(1, 0, 0, hasDivider and rowHeight - 1 or rowHeight),
				LayoutOrder = index * 2 - 1,
			}
			listContents["Row"..index] = renderItem(item, itemLayoutInfo)

			if hasDivider then
				local dividerXOffset = item.icon and Constants.MORE_PAGE_TEXT_PADDING_WITH_ICON or
					Constants.MORE_PAGE_ROW_PADDING_LEFT
				listContents["Divider"..index] = Roact.createElement("Frame", {
					Size = UDim2.new(1, -dividerXOffset, 0, 1),
					BackgroundColor3 = dividerStyle.Color,
					BackgroundTransparency = dividerStyle.Transparency,
					BorderSizePixel = 0,
					LayoutOrder = index * 2,
				})
			end
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, rowHeight * #itemList),
			BackgroundColor3 = backgroundStyle.Color,
			BackgroundTransparency = backgroundStyle.Transparency,
			BorderSizePixel = 1,
			BorderColor3 = dividerStyle.Color,
			LayoutOrder = layoutOrder,
		}, listContents)
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return renderMoreList(style.Theme.BackgroundUIDefault, style.Theme.Divider)
		end)
	else
		return renderMoreList(theme.MorePage.List.Background, theme.MorePage.List.Divider)
	end

end

return MoreList