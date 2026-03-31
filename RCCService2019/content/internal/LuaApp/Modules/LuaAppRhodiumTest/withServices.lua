local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local LuaApp = game.CoreGui.RobloxGui.Modules.LuaApp
local mockServices = require(LuaApp.TestHelpers.mockServices)

return function(test, component, initialStoreState, props)
	initialStoreState = initialStoreState or {}
	props = props or {}

	local element = mockServices( {
		Root = Roact.createElement(component, props),
	}, {
		includeStoreProvider = true,
		includeThemeProvider = true,
		includeStyleProvider = true,
		initialStoreState = initialStoreState,
	})

	local name = tostring(component)

	local root = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		[name] = element,
	})

	local instance = Roact.mount(root, CoreGui, "TestRoot")

	local success, result = pcall(function()
		test("game.CoreGui.TestRoot."..name)
	end)

	Roact.unmount(instance)
	if not success then
		error(result)
	end
end