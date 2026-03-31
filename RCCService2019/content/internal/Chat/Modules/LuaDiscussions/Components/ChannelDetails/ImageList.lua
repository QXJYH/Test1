local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local CircularMask = require(Components.CircularMask)
local PaddedTextLabel = require(Components.PaddedTextLabel)
local AvatarThumbnail = require(Components.ChatMessage.AvatarThumbnail)

local ImageList = Roact.PureComponent:extend("ImageList")
ImageList.defaultProps = {
    FillDirection = Enum.FillDirection.Horizontal,
    images = {},
    maxEntries = 6,
    LayoutOrder = 0,
}

local IMAGE_SIZE = UDim2.new(0, 36, 0, 36)

function ImageList:createAvatarThumbnail(index)
    local imageEntry = self.props.images[index]

    return Roact.createElement(AvatarThumbnail, {
        Image = imageEntry,
        LayoutOrder = index,
    })
end

function ImageList:render()
	return UIBlox.Style.withStyle(function(style)
	    local maxEntries = math.max(self.props.maxEntries, 1)
	    local images = self.props.images
	    local children = {
	        layout = Roact.createElement("UIListLayout", {
	            FillDirection = self.props.FillDirection
	        })
	    }

	    local numImages = #images
	    for i = 1, maxEntries-1 do
	        local imageEntry = images[i]
	        if imageEntry then
	            children["entry" .. i] = self:createAvatarThumbnail(i)
	        end
	    end

	    -- Handle last entry
	    if (numImages == maxEntries) then
	        children["lastEntry"] = self:createAvatarThumbnail(numImages)
	    elseif (numImages > maxEntries) then
	        local remainingEntries = numImages - (maxEntries-1)

	        children["lastEntry"] = Roact.createElement(CircularMask, {
	            presetSize = CircularMask.PresetSize.Size36x36,
	        }, {
	            Roact.createElement(PaddedTextLabel, {
	                Text = "+" .. remainingEntries,
	                TextSize = 12,
	                PaddingLeft = 10,
	                PaddingRight = 10,
	                PaddingTop = 10,
	                PaddingBottom = 10,
	            })
	        })
	    end

	    return Roact.createElement("Frame", {
	        LayoutOrder = self.props.LayoutOrder,
	        Size = UDim2.new(1, 0, 0, IMAGE_SIZE.Y.Offset),
	    }, children)
	end)
end

return ImageList
