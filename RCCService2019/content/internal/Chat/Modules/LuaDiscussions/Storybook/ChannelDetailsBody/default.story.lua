local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChannelDetailsBody = require(Components.ChannelDetails.ChannelDetailsBody)

local TEST_IMAGES = {
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
}

local TEST_IMAGES2 = {
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
    "rbxasset://textures/ui/LuaChat/icons/ic-profile.png",
}

return Roact.createElement(ChannelDetailsBody, {
    channelId = "channelID",
    memberList = TEST_IMAGES2,
    banList = TEST_IMAGES,
})
