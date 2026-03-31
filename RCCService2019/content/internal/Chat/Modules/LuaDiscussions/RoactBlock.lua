-- RoactBlock.lua
-- Index based block/div creation for blocking out high level components in a layout.

--[[
	This library is designed to reduce the visual noise when creating views/layouts
	that are composed of multiple high level components as a RoactBlock outline.

	UIListLayout and LayoutOrder-ing is implied from the order of the RoactBlock array.

		function render(props)
			return Roact.createElement("Frame", props, RoactBlock.verticalLayout({
				RoactBlock.insert(
					UDim2.new(1, 0, 0, 72),
					Roact.createElement(TopBar)
				),

				RoactBlock.insert(
					UDim2.new(1, 0, 0, 100),
					Roact.createElement("TextLabel", {
						Text = "Center",
					})
				),

				RoactBlock.insert(
					UDim2.new(1, 0, 0, 30),
					Roact.createElement(BottomBar)
				),
			}))
		end
]]

local RoactBlockImpl = script.Parent.RoactBlockImpl

return {
	verticalLayout = require(RoactBlockImpl.verticalLayout),
	insert = require(RoactBlockImpl.insert),
}