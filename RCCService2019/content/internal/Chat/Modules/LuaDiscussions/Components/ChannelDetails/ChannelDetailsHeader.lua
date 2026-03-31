local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local Components = LuaDiscussions.Components
local GenericHeader = require(Components.ChatHeader.GenericHeader)
local PaddedTextLabel = require(Components.PaddedTextLabel)
local PaddedImageButton = require(Components.PaddedImageButton)
local ChannelDetailsHeader = Roact.PureComponent:extend("ChannelDetailsHeader")

local PLACEHOLDER_BACK_ICON = "rbxasset://textures/ui/LuaChat/icons/ic-back-android.png"

ChannelDetailsHeader.defaultProps = {
    padding = 10,
    text = "Channel Details",
    LayoutOrder = 0,
}

function ChannelDetailsHeader:render()
	return UIBlox.Style.withStyle(function(style)
	    local headerType = GenericHeader("Channel Details", {
	        backButton = Roact.createElement(PaddedImageButton, {
	            Image = PLACEHOLDER_BACK_ICON,
	            Size = UDim2.new(0, 60, 0, 40),
	            paddingWidth = self.props.padding,
	        })
	    }, {
	        headerText = Roact.createElement(PaddedTextLabel, {
	            Font = Enum.Font.Gotham,
	            PaddingBottom = self.props.padding,
	            PaddingTop = self.props.padding,
	            Text = self.props.text,
	            TextColor3 = Color3.fromRGB(255,255,255),
	            TextSize = 34,
	        })
	    })
	    return Roact.createElement(headerType, {
	        Size = UDim2.new(1, 0, 1, 0),
	        LayoutOrder = self.props.LayoutOrder,
	    })
	end)
end

return ChannelDetailsHeader