local NotificationService = game:GetService("NotificationService")
local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local getThemeModuleForString = require(LuaApp.Themes.getThemeModuleForString)

function GetCurrentTheme()
    local selectedTheme = NotificationService.SelectedTheme;

    if selectedTheme == "Classic" then
        selectedTheme = "light"
    end

    return getThemeModuleForString(selectedTheme)
end

return GetCurrentTheme