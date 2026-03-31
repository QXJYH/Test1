local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local IconWithText = require(Components.IconWithText)

return function(target)
	local tree = Roact.createElement(IconWithText, {
		Text = "The enigma has been solved. It is an Icon with Text",
		Image = "rbxassetid://2610133241",
		fullHeight = 80
	})

	local handle = Roact.mount(tree, target, "preview")

	return function()
		Roact.unmount(handle)
	end
end
