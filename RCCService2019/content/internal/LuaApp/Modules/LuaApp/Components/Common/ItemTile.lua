--[[
	TODO: switch to item tile in UIBlox in the future.
	https://jira.rbx.com/browse/MOBLUAPP-1859
]]
local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local ItemTileName = require(Modules.LuaApp.Components.Common.ItemTileName)
local ItemTileIcon = require(Modules.LuaApp.Components.Common.ItemTileIcon)
local ItemTile = Roact.PureComponent:extend("ItemTile")

local TITLE_TEXT_LINE_COUNT = 2
local PADDING = 10

ItemTile.defaultProps = {
	titleTextLineCount = TITLE_TEXT_LINE_COUNT,
	innerPadding = PADDING,
}

function ItemTile:init()
	self.footerRef = Roact.createRef()
	self.state = {
		tileWidth = 0,
		tileHeight = 0,
	}

	self.onAbsoluteSizeChange = function(rbx)
		if self.footerRef.current then
			local tileWidth = rbx.AbsoluteSize.X
			local tileHeight = rbx.AbsoluteSize.Y
			spawn(function()
				self:setState({
					tileWidth = tileWidth,
					tileHeight = tileHeight,
				})
			end)
		end
	end
end

function ItemTile:render()
	local thumbnail = self.props.thumbnail
	local name = self.props.name
	local layoutOrder = self.props.layoutOrder
	local onActivated = self.props.onActivated
	local footer = self.props.footer
	local titleTextLineCount = self.props.titleTextLineCount
	local innerPadding = self.props.innerPadding

	local renderFuntion = function(stylePalette)
		local style = stylePalette
		local font = style.Font
		local titleTextHeight = font.BaseSize * font.Header2.RelativeSize * titleTextLineCount
		local footerHeight = self.state.tileHeight - self.state.tileWidth - innerPadding - titleTextHeight - innerPadding

		--TODO: use generic/state button from UIBlox
		return Roact.createElement("TextButton", {
			Text = "",
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = onActivated,
			[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChange
		},{
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, innerPadding),
			}),
			Thumbnail = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			},{
				Image = Roact.createElement(ItemTileIcon, {
					Image = thumbnail,
				})
			}),
			Name = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, titleTextHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			},{
				Text = Roact.createElement(ItemTileName, {
					name = name,
				}),
			}),
			Footer = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, footerHeight),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				[Roact.Ref] = self.footerRef,
			},{
				Footer = footer,
			}),
		})
	end
	return withStyle(renderFuntion)
end

return ItemTile