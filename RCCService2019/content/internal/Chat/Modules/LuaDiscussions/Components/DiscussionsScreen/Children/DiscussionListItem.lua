local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Otter = dependencies.Otter
local Components = LuaDiscussions.Components

local ChannelListItem = require(Components.DiscussionsScreen.Children.ChannelListItem)
local DiscussionSectionHeader = require(Components.DiscussionsScreen.Children.DiscussionSectionHeader)

local DiscussionContainer = Roact.PureComponent:extend("DiscussionContainer")
DiscussionContainer.defaultProps = {
    channelModels = {
        -- expects the following fields:
        -- channelId
        -- mainText
        -- subText
    },
    discussionIcon = nil,
    discussionBackground = nil,
}

-- TODO (SOC-6510): we eventually want to phase out the need for content height... section header height may be necessary though
local DISCUSSION_SECTION_HEADER_HEIGHT = 80
local DISCUSSION_CHANNEL_HEIGHT = 60

local MOTOR_OPTIONS = {
    dampingRatio = 1,
    frequency = 4,
}

function DiscussionContainer:init()
    self.motor = Otter.createSingleMotor(1)
    self.state = {
        collapsed = false,
    }
    self.contentHeight = 0
    self.layoutRef = Roact.createRef()
    self.ref = Roact.createRef()
    self.onActivatedImage = function() end
    self.onActivatedMoreDetails = function() end
    self.expand = function()
        if self.state.collapsed then
            self.motor:setGoal(Otter.spring(1, MOTOR_OPTIONS))
        else
            self.motor:setGoal(Otter.spring(0, MOTOR_OPTIONS))
        end
        self.state.collapsed = not self.state.collapsed
    end
end

function DiscussionContainer:render()
    local discussionIcon = self.props.discussionIcon
    local discussionBackground = self.props.discussionBackground
    local channelModels = self.props.channelModels

    local channelSection = {
        layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            [Roact.Ref] = self.layoutRef,
            [Roact.Change.AbsoluteContentSize] = function(rbx)
                self.childrenHeight = rbx.AbsoluteContentSize.Y
            end
        }),
    }
    for i, channel in ipairs(channelModels) do
        channelSection["channel" .. i] = Roact.createElement(ChannelListItem, {
            channelId = channel.channelId,
            mainText = channel.mainText,
            subText = channel.subText,
            LayoutOrder = i + 1
        })
    end

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, DISCUSSION_SECTION_HEADER_HEIGHT + #channelModels * DISCUSSION_CHANNEL_HEIGHT),
        LayoutOrder = self.props.LayoutOrder,
        ClipsDescendants = true,
        [Roact.Ref] = self.ref,
    }, {
        layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        sectionHeader = Roact.createElement(DiscussionSectionHeader, {
            discussionIcon = discussionIcon,
            discussionBackground = discussionBackground,
            onActivated = self.expand,
            onActivatedImage = self.onActivatedImage,
            onActivatedMoreDetails = self.onActivatedMoreDetails,
            height = DISCUSSION_SECTION_HEADER_HEIGHT,
        }),

        channelSection = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, self.contentHeight),

            LayoutOrder = 2,
        }, channelSection)
    })
end

function DiscussionContainer:didMount()
    self.contentHeight = self.ref.current.Size.Y.Offset
    self.motor:onStep(function(value)
        if self.ref.current then
            self.ref.current.Size = UDim2.new(1, 0, 0, self.childrenHeight * value + (self.contentHeight-self.childrenHeight))
        end
    end)
    self.motor:start()
end

function DiscussionContainer:willUnmount()
    self.motor:destroy()
end

return DiscussionContainer