local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local ChatInputBar = require(Components.ChatInput.ChatInputBar)

local function onSend(text)
	print("! " .. text .. " !")
end

return Roact.createElement(ChatInputBar, {onSend = onSend})
