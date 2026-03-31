local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local new = require(script.Parent.new)

local function verticalLayout(array)
	local layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return new(layout, array)
end

return verticalLayout