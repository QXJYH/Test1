local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local function new(layout, array)
	array = array or {}

	local roactChildren = {
		blockLayout = layout,
	}

	for index, entry in ipairs(array) do
		local size = entry.size
		local element = entry.element

		roactChildren[index .. "-block"] = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = size,
			LayoutOrder = index,
		}, {
			child = element,
		})
	end

	return roactChildren
end

return new