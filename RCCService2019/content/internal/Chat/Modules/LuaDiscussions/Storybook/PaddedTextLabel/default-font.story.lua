local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local PaddedTextLabel = require(script.Parent.Parent.Parent.Components.PaddedTextLabel)

return Roact.createElement("Folder", nil, {
	layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),

	Gotham = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.Gotham,
		LayoutOrder = 1,
		Text = Enum.Font.Gotham.Name,
	}),

	GothamSemibold = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.GothamSemibold,
		LayoutOrder = 2,
		Text = Enum.Font.GothamSemibold.Name,
	}),

	GothamBold = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.GothamBold,
		LayoutOrder = 3,
		Text = Enum.Font.GothamBold.Name,
	}),

	SourceSans = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.SourceSans,
		LayoutOrder = 4,
		Text = Enum.Font.SourceSans.Name,
	}),

	SourceSansSemibold = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.SourceSansSemibold,
		LayoutOrder = 5,
		Text = Enum.Font.SourceSansSemibold.Name,
	}),

	SourceSansBold = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.SourceSansBold,
		LayoutOrder = 6,
		Text = Enum.Font.SourceSansBold.Name,
	}),

	Fantasy = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.Fantasy,
		LayoutOrder = 7,
		Text = Enum.Font.Fantasy.Name,
	}),

	Code = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.Code,
		LayoutOrder = 8,
		Text = Enum.Font.Code.Name,
	}),

	Highway = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.Highway,
		LayoutOrder = 9,
		Text = Enum.Font.Highway.Name,
	}),

	SciFi = Roact.createElement(PaddedTextLabel, {
		Font = Enum.Font.SciFi,
		LayoutOrder = 10,
		Text = Enum.Font.SciFi.Name,
	}),
})
