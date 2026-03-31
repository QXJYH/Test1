local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local PaddedTextLabel = require(Components.PaddedTextLabel)
local ChannelAnnouncement = Roact.PureComponent:extend("ChannelAnnouncement")
ChannelAnnouncement.defaultProps = {
    LayoutOrder = 0,
    channelAnnouncement = "Announcement",
    channelName = "Channel Name",
    onActivated = nil,
    paddingHeight = 20,
    paddingWidth = 10,
    fullHeight = 100,
}

function ChannelAnnouncement:render()
	return UIBlox.Style.withStyle(function(style)
	    -- These variables will come from Theming
	    local TextColor3 = Color3.fromRGB(222, 222, 222)
	    local Font = Enum.Font.Gotham
	    local titleTextSize = 24
	    local subtitleTextSize = 12

	    local paddingHeight = self.props.paddingHeight
	    local paddingWidth = self.props.paddingWidth
	    local onActivated = self.props.onActivated

	    return Roact.createElement("ImageButton", {
	        LayoutOrder = self.props.LayoutOrder,
	        Size = UDim2.new(1, 0, 0, self.props.fullHeight),
	        [Roact.Event.Activated] = onActivated,
	    }, {
	        padding = Roact.createElement("UIPadding", {
	            PaddingBottom = UDim.new(0, paddingHeight),
	            PaddingTop = UDim.new(0, paddingHeight),
	        }),
	        layout = Roact.createElement("UIListLayout", {
	            FillDirection = Enum.FillDirection.Vertical,
	            SortOrder = Enum.SortOrder.LayoutOrder,
	        }),
	        title = Roact.createElement(PaddedTextLabel, {
	            PaddingLeft = paddingWidth,
	            PaddingRight = paddingWidth,
	            PaddingBottom = paddingHeight/2,
	            Text = self.props.channelName,
	            Font = Font,
	            TextSize = titleTextSize,
	            TextColor3 = TextColor3,
	            LayoutOrder = 1,
	        }),
	        subtitle = Roact.createElement(PaddedTextLabel, {
	            PaddingLeft = paddingWidth,
	            PaddingRight = paddingWidth,
	            PaddingTop = paddingHeight/2,
	            Text = self.props.channelAnnouncement,
	            Font = Enum.Font.Gotham,
	            TextSize = subtitleTextSize,
	            TextColor3 = TextColor3,
	            LayoutOrder = 2,
	        })
	    })

	end)
end

return ChannelAnnouncement
