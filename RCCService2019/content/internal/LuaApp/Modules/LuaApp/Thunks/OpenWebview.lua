local Modules = game:GetService("CoreGui").RobloxGui.Modules
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local AppPage = require(Modules.LuaApp.AppPage)


return function(url, title)
	assert(type(url) == "string",
		string.format("OpenWebview thunk expects url to be a string, was %s", type(url)))
	assert(type(title) == "string",
		string.format("OpenWebview thunk expects url to be a string, was %s", type(string)))

	return function(store)
		store:dispatch(
			NavigateDown({
				name = AppPage.GenericWebPage,
				detail = url,
				extraProps = {
					title = title,
				},
			})
		)
	end
end
