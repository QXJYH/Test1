--[[
	Demonstrates how to use RoactRodux to link Roact and Rodux toegther into
	a single project.
]]

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local Rodux = require(CorePackages.Rodux)
local RoactRodux = require(CorePackages.RoactRodux)

-- React Portion
-- This code doesn't know anything about Rodux.
-- It can function as an isolated component and should be able to do so.
local App = Roact.Component:extend("App")

function App:render()
	local count = self.props.count
	local onClick = self.props.onClick

	return Roact.createElement("ScreenGui", nil, {
		Label = Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = "Count: " .. tostring(count),
			TextSize = 48,
			AutoButtonColor = false,

			[Roact.Event.Activated] = onClick,
		})
	})
end

-- React-Rodux Portion
-- This code ties together Roact and Rodux by generating a wrapper component.
-- Connect accepts two arguments. A function that maps your rodux state to your props
-- and a function that maps the dispatch function to your props. Both functions
-- should return a table. Note that internally we are still using UNSTABLE_connect2 and
-- this will change to connect in the future.
local connector = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			count = state.count,
		}
	end,
	function(dispatch)
		print("hello?")
		return {
			onClick = function()
				dispatch({
					type = "increment",
				})
			end,
		}
	end
)

-- In a lot of cases it's useful to preserve the original component
-- For this example, we don't need the unwrapped App
App = connector(App)

-- Rodux Portion
-- This is a reducer that lets you increment a value.
local function reducer(state, action)
	state = state or {
		count = 0,
	}

	if action.type == "increment" then
		return {
			count = state.count + 1
		}
	end

	return state
end

-- Setup
return function()
	local store = Rodux.Store.new(reducer)

	-- We wrap our Roact-Rodux app in a `StoreProvider`, which makes sure our
	-- components know what store they should be connecting to.
	local app = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		App = Roact.createElement(App),
	})

	Roact.mount(app, CoreGui, "Roact-demo-rodux")
end