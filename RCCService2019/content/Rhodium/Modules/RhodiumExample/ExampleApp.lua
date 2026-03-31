local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local ExampleApp = Roact.Component:extend("ExampleApp")

function ExampleApp:init()
	self.state = {
		count = 0,
	}
end

function ExampleApp:render()
	local count = self.state.count

	local scrollChildren = {}

	scrollChildren.UIListLayout = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 10),
	})

	for i = 1, 10 do
		scrollChildren["Child"..tostring(i)] = Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 0, 200),
			Text = "Child"..tostring(i)
		})
	end

	return Roact.createElement("ScreenGui", {}, {
		Root = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
		}, {
			ScrollingFrame = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				Position = UDim2.new(0.5, 0, 0.1, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				CanvasSize = UDim2.new(0, 0, 0, 2090),
			}, scrollChildren),

			Button = Roact.createElement("TextButton", {
				Size = UDim2.new(0, 200, 0, 200),
				Position = UDim2.new(0.5, 0, 0.9, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Text = tostring(count),

				[Roact.Event.Activated] = function()
					self:setState({
						count = count + 1,
					})
				end
			}),
		}),
	})
end

return ExampleApp