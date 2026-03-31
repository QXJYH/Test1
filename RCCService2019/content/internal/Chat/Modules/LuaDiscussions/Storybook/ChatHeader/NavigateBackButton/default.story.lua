local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local NavigateBackButton = require(Components.ChatHeader.NavigateBackButton)

return Roact.createElement(NavigateBackButton)
