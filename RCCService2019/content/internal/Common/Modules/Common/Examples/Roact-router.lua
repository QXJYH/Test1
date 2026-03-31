--[[
	Demonstrates creation of a complete routing system using Roact and Rodux.

	This example mimics the philosophy of React Router 4 with dynamic routes:
	https://reacttraining.com/react-router/web/guides/philosophy
]]

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local Rodux = require(CorePackages.Rodux)
local RoactRodux = require(CorePackages.RoactRodux)

-- A component that can be clicked to navigate around the app.
local function Link(props)
	local text = props.text
	local onClick = props.onClick

	local function setTarget()
		onClick(props.target)
	end

	return Roact.createElement("TextButton", {
		Size = UDim2.new(0, 100, 0, 30),
		Text = text,

		[Roact.Event.Activated] = setTarget,
	})
end

Link = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			location = state.location
		}
	end,
	function(dispatch)
		return {
			onClick = function(target)
				dispatch({
					type = "Navigate",
					location = target,
				})
			end
		}
	end
)(Link)

--[[
	A component that can be clicked to navigate back one step, if available.

	Appears darker if there is no history to navigate backwards to.
]]
local function BackButton(props)
	local onClick = props.onClick
	local enabled = props.enabled

	return Roact.createElement("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Text = "<",
		AutoButtonColor = enabled,
		BackgroundColor3 = enabled and Color3.new(0.8, 0.8, 0.8) or Color3.new(0.5, 0.5, 0.5),

		[Roact.Event.Activated] = onClick,
	})
end

BackButton = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			enabled = #state.history > 0,
		}
	end,
	function(dispatch)
		return {
			onClick = function()
				dispatch({
					type = "Back",
				})
			end
		}
	end
)(BackButton)

--[[
	Only renders the given component if the given route is the current one.

	The component is passed as a prop so that we don't worry about its
	descendants until they're relevant.
]]
local function Route(props)
	-- Injected by RoactRodux
	local current = props.current

	-- Provided by parent component
	local match = props.match
	local component = props.component

	if current == match then
		return Roact.createElement(component)
	end
end

Route = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			current = state.current
		}
	end, nil
)(Route)

--[[
	A navigation bar that lets us go to one of three locations, or
	travel backwards.
]]
local function NavBar()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		Back = Roact.createElement(BackButton),

		GoHome = Roact.createElement(Link, {
			text = "Go to Home",
			target = "home",
		}),

		GoAbout = Roact.createElement(Link, {
			text = "Go to About",
			target = "about",
		}),

		GoContact = Roact.createElement(Link, {
			text = "Go to Contact",
			target = "contact",
		}),
	})
end

-- 'Home' page, our default view
local function Home()
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.5, 0.3, 0.7),
		Text = "Home",
		TextSize = 30,
		TextColor3 = Color3.new(0.95, 0.95, 0.95),
	})
end

-- 'About' page
local function About()
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.5, 0.6, 0.2),
		Text = "About",
		TextSize = 30,
		TextColor3 = Color3.new(0.95, 0.95, 0.95),
	})
end

-- 'Contact' page
local function Contact()
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0.8, 0.3, 0.4),
		Text = "Contact",
		TextSize = 30,
		TextColor3 = Color3.new(0.95, 0.95, 0.95),
	})
end

--[[
	The wrapper used to package up all of our components and display them.
]]
local App = Roact.Component:extend("App")

function App:render()
	return Roact.createElement("ScreenGui", {
	}, {
		Body = Roact.createElement("Frame", {
			Size = UDim2.new(0, 600, 0, 400),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			-- These components sort of act like a static routing table.
			Home = Roact.createElement(Route, {
				match = "home",
				component = Home,
			}),

			About = Roact.createElement(Route, {
				match = "about",
				component = About,
			}),

			Contact = Roact.createElement(Route, {
				match = "contact",
				component = Contact,
			}),

			NavBar = Roact.createElement(NavBar),
		}),
	})
end

--[[
	All of our navigation is described using a Redux reducer.

	This means we can time-travel debug and log actions just like other
	Redux data.
]]

-- TODO: update to cryo

local function reducer(state, action)
	state = state or {
		current = "home",
		history = {}
	}

	if action.type == "Navigate" then
		if state.current ~= action.location then
			return {
				current = action.location,
				history = Cryo.List.join(state.history, { state.current })
			}
		end
	elseif action.type == "Back" then
		local length = #state.history

		if length == 0 then
			return state
		end

		return {
			current = state.history[length],
			history = Cryo.List.removeIndex(state.history, length)
		}
	end

	return state
end

return function()
	local store = Rodux.Store.new(reducer)

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		App = Roact.createElement(App)
	})

	Roact.mount(element, CoreGui, "Roact-router")
end