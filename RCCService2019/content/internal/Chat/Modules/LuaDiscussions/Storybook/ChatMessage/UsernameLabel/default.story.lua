local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UsernameLabel = require(Components.ChatMessage.UsernameLabel)

return Roact.createElement(UsernameLabel)
