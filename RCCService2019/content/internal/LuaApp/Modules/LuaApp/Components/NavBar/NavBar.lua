local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Modules = CoreGui.RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local NavBar = Roact.PureComponent:extend("NavBar")

NavBar.defaultProps = {
	layoutInfo = {
		fillDirection = Enum.FillDirection.Horizontal,
	},
}

function NavBar:render()
	local layoutInfo = self.props.layoutInfo
	local selectedIndex = self.props.selectedIndex
	local items = self.props.items
	local renderItem = ArgCheck.isType(self.props.renderItem, "function", "NavBar.props.renderItem")
	local itemCount = ArgCheck.isNonNegativeNumber(#items, "NavBar.props.items count")

	local fillDirection = layoutInfo.fillDirection
	local backgroundInfo = layoutInfo.background or {}
	local paddingInfo = layoutInfo.padding or {}
	local dividerInfo = layoutInfo.divider or {}

	local children = {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = fillDirection,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		UIPadding = Roact.createElement("UIPadding", paddingInfo),
	}

	for index, item in ipairs(items) do
		children["ItemFrame" .. tostring(index)] = Roact.createElement("Frame", {
			Size = fillDirection == Enum.FillDirection.Horizontal and
				UDim2.new(1/itemCount, 0, 1, 0) or UDim2.new(1, 0, 1/itemCount, 0),
			LayoutOrder = index,
			BackgroundTransparency = 1,
		}, {
			Item = renderItem(item, selectedIndex == index),
		})
	end

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			AnchorPoint = backgroundInfo.AnchorPoint,
			Position = backgroundInfo.Position,
			Size = backgroundInfo.Size,
			BorderSizePixel = 0,
			BackgroundTransparency = style.Theme.NavigationBar.Transparency,
			BackgroundColor3 = style.Theme.NavigationBar.Color,
			Active = true,
		}, children)
	end)
end

return NavBar