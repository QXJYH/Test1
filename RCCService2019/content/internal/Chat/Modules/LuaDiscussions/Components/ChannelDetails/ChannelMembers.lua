local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local PaddedTextLabel = require(Components.PaddedTextLabel)
local ImageList = require(Components.ChannelDetails.ImageList)

local ChannelMembers = Roact.PureComponent:extend("ChannelMembers")
ChannelMembers.defaultProps = {
    height = 100,
    memberList = {},
    maxEntries = 6,
    titleText = "Title Text",
    LayoutOrder = 0,
    paddingWidth = 10,
    paddingHeight = 16,
}

function ChannelMembers:render()
	return UIBlox.Style.withStyle(function(style)
	    -- These will come from theming
	    local TextColor3 = Color3.fromRGB(222, 222, 222)
	    local Font = Enum.Font.Gotham
	    local titleTextSize = 24

	    local paddingWidth = self.props.paddingWidth
	    local paddingHeight = self.props.paddingHeight

	    return Roact.createElement("Frame", {
	        LayoutOrder = self.props.LayoutOrder,
	        Size = UDim2.new(1, 0, 0, self.props.height),
	        BackgroundColor3 = Color3.fromRGB(200, 100, 0),
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
	            Text = self.props.titleText,
	            Font = Font,
	            TextSize = titleTextSize,
	            TextColor3 = TextColor3,
	            LayoutOrder = 1,
	        }),
	        members = Roact.createElement(ImageList, {
	            images = self.props.memberList,
	            maxEntries = self.props.maxEntries,
	            LayoutOrder = 2,
	        })
	    })
	end)
end

return ChannelMembers