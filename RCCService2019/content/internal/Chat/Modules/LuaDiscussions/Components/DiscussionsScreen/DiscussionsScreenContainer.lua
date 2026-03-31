local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local RoactRodux = dependencies.RoactRodux

local DiscussionsScreenLayout = require(script.Parent.DiscussionsScreenLayout)

local DiscussionsScreenContainer = Roact.PureComponent:extend("DiscussionsScreenContainer")
DiscussionsScreenContainer.defaultProps = {
    discussionModels = {},
}

function DiscussionsScreenContainer:render()
    return Roact.createElement(DiscussionsScreenLayout, {
        discussionModels = self.props.discussionModels,
    })
end

return DiscussionsScreenContainer
-- return RoactRodux.UNSTABLE_connect2(function()
--  --TODO(SOC-6376): Hookup Discussions with backend
-- end,
-- function()

-- end)(DiscussionsScreenContainer)