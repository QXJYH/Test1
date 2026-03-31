local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local FitTextLabel = require(Components.FitTextLabel)

local WIDTH = 200

return Roact.createElement("Frame", {
	Size = UDim2.new(0, WIDTH, 1, 0),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
}, {
	Layout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	Paragraph1 = Roact.createElement(FitTextLabel, {
		Text = "This is the first paragraph in this example. I guess it's really only a sentence.",
		maxWidth = WIDTH,
		LayoutOrder = 1,
	}),
	Paragraph2 = Roact.createElement(FitTextLabel, {
		Text = "This is the second paragraph in this example. It's still only a sentence, but who's counting?",
		maxWidth = WIDTH,
		LayoutOrder = 2,
	}),
})
