local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local FitTextLabel = require(Components.FitTextLabel)

local layoutOrder = 0
local function composeVerse(lines)
	layoutOrder = layoutOrder + 1
	local verseText = table.concat(lines, "\n")
	return Roact.createElement(FitTextLabel, {
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = verseText,
		LayoutOrder = layoutOrder,
	})
end

return Roact.createElement("Frame", {
	Size = UDim2.new(0, 300, 1, 0),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
}, {
	Layout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 16),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	Verse1 = composeVerse({
		"An old silent pond...",
		"A frog jumps into the pond,",
		"splash! Silence again.",
	}),
	Verse2 = composeVerse({
		"Autumn moonlight-",
		"a worm digs silently",
		"into the chestnut.",
	}),
	Verse3 = composeVerse({
		"In the twilight rain",
		"these brilliant-hued hibiscus -",
		"A lovely sunset.",
	}),
})
