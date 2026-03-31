local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local TimeStampCentered = require(Components.ChatMessage.TimeStampCentered)

return Roact.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
}, {
    layout = Roact.createElement("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    }),
	time1 = Roact.createElement(TimeStampCentered, {
		isoTime = "1984-12-12",
		layoutOrder = 1,
	}),
	time2 = Roact.createElement(TimeStampCentered, {
		isoTime = "2094-12-12",
		layoutOrder = 2,
	}),
	time3 = Roact.createElement(TimeStampCentered, {
		isoTime = "1994-11-12",
		layoutOrder = 3,
	}),
	time4 = Roact.createElement(TimeStampCentered, {
		isoTime = "2004-10-15",
		layoutOrder = 4,
	}),
	time5 = Roact.createElement(TimeStampCentered, {
		isoTime = "2019-04-29",
		layoutOrder = 5,
	}),
})
