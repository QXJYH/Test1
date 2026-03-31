--[[
	'Refs' are a concept that let you break out of the Roact paradigm and access
	Roblox instances directly.

	Pass a callback as a prop using the key [Roact.Ref] to receive
	the reference.

	When the object is destructed or the ref is replaced in an update, the ref
	callback will be passed nil.

	This feature is intended to be an escape hatch; it should not be necessary
	for the majority of work using Roact. In many cases, code using refs can be
	isolated and exposed with a friendlier API.
]]

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local App = Roact.Component:extend("App")

function App:init()
	self.ref = Roact.createRef()
end

function App:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 123, 0, 123),

		[Roact.Ref] = self.ref,
	})
end

function App:didMount()
	print("Roblox Instance:", self.ref.current)
	print("Roblox Instance Size:", self.ref.current.Size)
end

return function()
	local element = Roact.createElement(App)

	Roact.mount(element, nil, "SomeName")
end