local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local ChannelMessage = require(Components.ChatMessage.ChannelMessage)

local MESSAGE_ENTRY_MARGIN = 50

local ChannelScrollingArea = Roact.PureComponent:extend("ChannelScrollingArea")
ChannelScrollingArea.defaultProps = {
	contentMaxWidth = 0,
	channelMessages = {},
}

function ChannelScrollingArea:createMessageChildren()
	local contentMaxWidth = self.props.contentMaxWidth
	local channelMessages = self.props.channelMessages

	local children = {
		layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 16),
			SortOrder = Enum.SortOrder.LayoutOrder,
			[Roact.Ref] = self.layoutRef,
		})
	}
	for index, channelMessage in ipairs(channelMessages) do
		children["entry-" .. channelMessage.id] = Roact.createElement(ChannelMessage, {
			maxWidth = contentMaxWidth - MESSAGE_ENTRY_MARGIN,
			channelMessage = channelMessage,
			LayoutOrder = index,
		})
	end
	return children
end

function ChannelScrollingArea:init()
	self.layoutRef = Roact.createRef()
	self.scrollingFrameRef = Roact.createRef()
end

function ChannelScrollingArea:render()
	return UIBlox.Style.withStyle(function(style)
		local children = self:createMessageChildren()

		return Roact.createElement("ScrollingFrame", {
			ScrollBarThickness = 4,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			BackgroundColor3 = Color3.fromRGB(35, 37, 39),
			Size = UDim2.new(1, 0, 1, 0),
			[Roact.Ref] = self.scrollingFrameRef,
		}, children)
	end)
end

function ChannelScrollingArea:didUpdate()
	self:_updateScrollingFrameCanvasSize()
end

function ChannelScrollingArea:didMount()
	self:_updateScrollingFrameCanvasSize()
end

function ChannelScrollingArea:_updateScrollingFrameCanvasSize()
	local scrollingFrame = self.scrollingFrameRef.current
	local layout = self.layoutRef.current
	if scrollingFrame and layout then
		local absoluteHeight = layout.AbsoluteContentSize.Y
		scrollingFrame.CanvasSize = UDim2.new(UDim.new(0, 0), UDim.new(0, absoluteHeight))
	end
end

return ChannelScrollingArea