local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local FitFrameVertical = require(script.Parent.Parent.Parent.Components.FitFrameVertical)

return Roact.createElement(FitFrameVertical, {
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
	width = UDim.new(0, 60),
	horizontalAlignment = Enum.HorizontalAlignment.Left,
}, {
	element1 = Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 50, 0, 50),
		Text = "50x50",
	}),
	element2 = Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 50, 0, 100),
		Text = "50x100",
	}),
	element3 = Roact.createElement("TextLabel", {
		Size = UDim2.new(0, 50, 0, 20),
		Text = "50x20",
	}),
})
