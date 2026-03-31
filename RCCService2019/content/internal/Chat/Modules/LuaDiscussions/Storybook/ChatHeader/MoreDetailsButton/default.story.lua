local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local MoreDetailsButton = require(Components.ChatHeader.MoreDetailsButton)

return Roact.createElement(MoreDetailsButton)
