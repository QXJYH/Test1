local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local AvatarEditorTheme = require(Modules.LuaApp.Themes.Avatar.AvatarEditorTheme)

local MockAvatarEditorTheme = Roact.Component:extend("AELoader")

function MockAvatarEditorTheme:init()
	self._context.AvatarEditorTheme = AvatarEditorTheme()
end

function MockAvatarEditorTheme:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return MockAvatarEditorTheme