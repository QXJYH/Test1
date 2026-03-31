local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local LuaApp = CoreGui.RobloxGui.Modules.LuaApp
local Roact = require(CorePackages.Roact)

local GridView = require(LuaApp.Components.Generic.GridView)

local function TestWithGridView(test, gridViewProps)
	local windowAbsoluteSize = gridViewProps.windowAbsoluteSize

	local scrollingFrame = Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(0, windowAbsoluteSize.X, 0, windowAbsoluteSize.Y),
		CanvasSize = UDim2.new(0, windowAbsoluteSize.X, 0, 10 * windowAbsoluteSize.Y),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
	}, {
		GridView = Roact.createElement(GridView, gridViewProps),
	})

	local root = Roact.createElement("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		ScrollingFrameWithGridView = scrollingFrame,
	})

	local instance = Roact.mount(root, CoreGui, "TestRoot")

	local success, result = pcall(function()
		local rootPathStr = "game.CoreGui.TestRoot.ScrollingFrameWithGridView"
		test(rootPathStr)
	end)

	Roact.unmount(instance)
	if not success then
		error(result)
	end
end

return TestWithGridView