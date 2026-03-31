local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local UIBlox = dependencies.UIBlox

local CorePackages = game:GetService("CorePackages")
local LightTheme = require(CorePackages.AppTempCommon.LuaApp.Style.Themes.LightTheme)
local Gotham = require(CorePackages.AppTempCommon.LuaApp.Style.Fonts.Gotham)

return {
	name = "discussions",
	storyRoot = script,
	middleware = function(story, target)
		local tree = Roact.createElement(UIBlox.Style.Provider, {
			style = {
				Theme = LightTheme,
				Font = Gotham,
			},
		}, {
			Story = story,
		})

		local handle = Roact.mount(tree, target, "StoryRoot")
		return function()
			Roact.unmount(handle)
		end
	end
}