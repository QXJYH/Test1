local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local AvatarEditorTheme = require(Modules.LuaApp.Themes.Avatar.AvatarEditorTheme)

local Roact = require(CorePackages.Roact)

local ContextWrapper = {}

function ContextWrapper.wrap(component)
    local Component = Roact.PureComponent:extend(tostring(component))

    function Component:init()
        self._context.AvatarEditorTheme = AvatarEditorTheme()
    end

    function Component:render()
        return Roact.createElement(component, self.props)
    end

    return Component
end

return ContextWrapper