local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Modules = CoreGui.RobloxGui.Modules
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local FlagSettings = require(Modules.LuaApp.FlagSettings)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local UniversalBottomBar = Roact.PureComponent:extend("UniversalBottomBar")

UniversalBottomBar.defaultProps = {
	displayOrder = 1,
}

function UniversalBottomBar:render()
	local theme = self._context.AppTheme

	local isVisible = self.props.isVisible
	local displayOrder = self.props.displayOrder
	local layoutInfo = self.props.layoutInfo
	local selectedIndex = self.props.selectedIndex
	local items = self.props.items
	local renderItem = self.props.renderItem

	ArgCheck.isType(renderItem, "function", "UniversalBottomBar.props.renderItem")

	local backgroundInfo = layoutInfo and layoutInfo.Background or {}
	local paddingInfo = layoutInfo and layoutInfo.Padding or {}
	local topBorderInfo = layoutInfo and layoutInfo.TopBorder or {}

	local children = {}
	local totalItemNum = items and #items or 0
	if totalItemNum > 0 then
		children = {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			UIPadding = Roact.createElement("UIPadding", paddingInfo),
		}

		for index, item in ipairs(items) do
			children["ItemFrame" .. tostring(index)] = Roact.createElement("Frame", {
				Size = UDim2.new(1/totalItemNum, 0, 1, 0),
				LayoutOrder = index,
				BackgroundTransparency = 1,
			}, {
				Item = renderItem(item, selectedIndex == index),
			})
		end
	end

	local renderUniversalBottomBar = function(style)
		return Roact.createElement(Roact.Portal, {
			target = CoreGui,
		}, {
			BottomBar = Roact.createElement("ScreenGui", {
				Enabled = isVisible,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = displayOrder,
			}, {
				Background = Roact.createElement("Frame", {
					AnchorPoint = backgroundInfo.AnchorPoint,
					Position = backgroundInfo.Position,
					Size = backgroundInfo.Size,
					BorderSizePixel = 0,
					BackgroundTransparency = style.Theme.NavigationBar.Transparency,
					BackgroundColor3 = style.Theme.NavigationBar.Color,
					Active = true,
				}, children),
				TopBorder = (not UseNewAppStyle) and Roact.createElement("Frame", {
					AnchorPoint = topBorderInfo.AnchorPoint,
					Position = topBorderInfo.Position,
					Size = topBorderInfo.Size,
					BorderSizePixel = 0,
					BackgroundTransparency = style.Theme.Divider.Transparency,
					BackgroundColor3 = style.Theme.Divider.Color,
				}),
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return renderUniversalBottomBar(style)
		end)
	else
		local style = {
			Theme = {
				NavigationBar = theme.BottomBar.Background,
				Divider = theme.BottomBar.TopBorder,
			},
		}
		return renderUniversalBottomBar(style)
	end
end

return UniversalBottomBar