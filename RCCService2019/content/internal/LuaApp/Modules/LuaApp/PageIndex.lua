local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AppPage = require(Modules.LuaApp.AppPage)

local pageTypeByIndex = {
	AppPage.Home,
	AppPage.Games,
	AppPage.AvatarEditor,
	AppPage.Chat,
	AppPage.More,
}

local pageIndexByType = {}
for index, pageType in ipairs(pageTypeByIndex) do
	pageIndexByType[pageType] = index
end

return {
	PageTypeByIndex = pageTypeByIndex,
	PageIndexByType = pageIndexByType,
}