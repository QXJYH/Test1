local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local UIBlox = dependencies.UIBlox
local Roact = dependencies.Roact

local CorePackages = game:GetService("CorePackages")
local DarkTheme = require(CorePackages.AppTempCommon.LuaApp.Style.Themes.DarkTheme)
local Gotham = require(CorePackages.AppTempCommon.LuaApp.Style.Fonts.Gotham)

return function(element)
    return Roact.createElement(UIBlox.Style.Provider, {
        style = {
            Theme = DarkTheme,
            Font = Gotham,
        },
    }, {
        TestElement = element,
    })
end
