local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelAnnouncement = require(Components.ChannelDetails.ChannelAnnouncement)
local ChannelDetailsHeader = require(Components.ChannelDetails.ChannelDetailsHeader)
local ChannelMembers = require(Components.ChannelDetails.ChannelMembers)
local PaddedTextLabel = require(Components.PaddedTextLabel)
local RoactBlock = dependencies.RoactBlock
local UIBlox = dependencies.UIBlox

local ChannelDetailsBody = Roact.PureComponent:extend("ChannelDetailsBody")

ChannelDetailsBody.defaultProps = {
    screenSize = UDim2.new(0, 375, 0, 812),
    memberList = {},
    banList = {},
}

function ChannelDetailsBody:render()
	return UIBlox.Style.withStyle(function(style)
	    --[[
	        TODO (SOC-6421): communicate with backend and get actual data from the channelId,
	        such that we can pass it in to the various parts of this component
	    ]]

	    return Roact.createElement("Frame", {
	        Size = self.props.screenSize,
	    }, RoactBlock.verticalLayout({
	        RoactBlock.insert(
	            UDim2.new(1, 0, 0, 100),
	            Roact.createElement(ChannelDetailsHeader)
	        ),
	        RoactBlock.insert(
	            UDim2.new(1, 0, 0, 100),
	            Roact.createElement(ChannelAnnouncement)
	        ),
	        RoactBlock.insert(
	            UDim2.new(1, 0, 0, 100),
	            Roact.createElement(ChannelMembers, {
	                titleText = "Channel Members",
	                memberList = self.props.memberList,
	            })
	        ),
	        RoactBlock.insert(
	            UDim2.new(1, 0, 0, 100),
	            Roact.createElement(ChannelMembers, {
	                titleText = "Banned Individuals",
	                memberList = self.props.banList,
	            })
	        ),
	        RoactBlock.insert(
	            UDim2.new(1, 0, 0, 100),
	            Roact.createElement("ImageButton", {
	                Size = UDim2.new(1, 0, 0, 64),
	                [Roact.Event.Activated] = function()
	                    print("reported")
	                end,
	            }, {
	                text = Roact.createElement(PaddedTextLabel, {
	                    TextSize = 24,
	                    Text = "Report Channel",
	                    PaddingTop = 20,
	                    PaddingBottom = 20,
	                    PaddingLeft = 20,
	                }),
	            })
	        ),
	    }))
	end)
end

return ChannelDetailsBody