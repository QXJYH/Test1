--[[
	Creates a tempoary Roact wrapper component that is a button with states.
		If an image is not provided the background color and background transparency will be set instead.
	Props in addition to ImageButton:
		Disabled : bool - Is the button disabled. If it is disabled, the activated event will not fire.
		StateChanged : function ( currentState : Constants.ButtonState, nextState : Constants.ButtonState )
			- Fires when the button state changes.
--]]

local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Immutable = require(Modules.Common.Immutable)
local ButtonState = require(Modules.LuaApp.Enum.ButtonState)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local StateTable = require(Modules.LuaApp.StateTable)

local StateButton = Roact.PureComponent:extend("StateButton")

local FFlagLuaFixRoactRefAssignment = game:GetFastFlag("LuaFixRoactRefAssignment")


function StateButton:init()
	if not FFlagLuaFixRoactRefAssignment then
		self.ref = Roact.createRef()
	end
	self.state = {
		currentState = ButtonState.Default,
	}
	self.id = "StateButton"..tostring(self)

	self.stateTable = StateTable.new(self.id, ButtonState.Default, {},
	{
		[ButtonState.Default] = {
			OnPressed = { nextState = ButtonState.Pressed },
			StartHover = { nextState = ButtonState.Hover },
			OnSelectionGained = { nextState = ButtonState.Selected },
			Disable = { nextState = ButtonState.Disabled },
		},
		[ButtonState.Hover] = {
			OnSelectionGained = { nextState = ButtonState.Selected },
			OnPressed = { nextState = ButtonState.Pressed },
			EndHover = { nextState = ButtonState.Default },
			Disable = { nextState = ButtonState.Disabled },
		},
		[ButtonState.Pressed] = {
			OnSelectionGained = { nextState = ButtonState.SelectedPressed },
			OnReleased = { nextState = ButtonState.Default },
			OnReleasedHover = { nextState = ButtonState.Hover },
			Disable = { nextState = ButtonState.Disabled },
		},
		[ButtonState.Selected] = {
			OnSelectionLost = { nextState = ButtonState.Default },
			OnPressed = { nextState = ButtonState.SelectedPressed },
			Disable = { nextState = ButtonState.Disabled },
		},
		[ButtonState.SelectedPressed] = {
			OnSelectionLost = { nextState = ButtonState.Default },
			OnReleased = { nextState = ButtonState.Selected },
			Disable = { nextState = ButtonState.Disabled },
		},
		[ButtonState.Disabled] = {
			Enable = { nextState = ButtonState.Default },
		},
	})

	self.stateTable:onStateChange(function(oldState, newState, updatedContext)
		if not FFlagLuaFixRoactRefAssignment then
			if self.ref.current == nil then
				return
			end
		end

		self:setState({
			currentState = newState,
		})
		if self.props.StateChanged then
			self.props.StateChanged(oldState, newState)
		end
	end)
end

function StateButton:render()
	local props = self.props
	local newProps = Immutable.RemoveFromDictionary(self.props, "Disabled", "StateChanged", Roact.Event.Activated)
	newProps.Selectable = true
	newProps[Roact.Event.MouseEnter] = function(...)
		self.stateTable.events.StartHover()
		if props[Roact.Event.MouseEnter] ~= nil then
			return props[Roact.Event.MouseEnter](...)
		end
	end
	newProps[Roact.Event.MouseLeave] = function(...)
		self.stateTable.events.EndHover()
		if props[Roact.Event.MouseLeave] ~= nil then
			return props[Roact.Event.MouseLeave](...)
		end
	end
	newProps[Roact.Event.InputBegan] = function(...)
		local inputObject = select(2, ...)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or
			inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.KeyCode == Enum.KeyCode.ButtonA then
			self.stateTable.events.OnPressed()
		end
		if props[Roact.Event.InputBegan] ~= nil then
			return props[Roact.Event.InputBegan](...)
		end
	end
	newProps[Roact.Event.InputEnded] = function(...)
		local inputObject = select(2, ...)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self.stateTable.events.OnReleasedHover()
		elseif inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.KeyCode == Enum.KeyCode.ButtonA or
			inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self.stateTable.events.OnReleased()
		end
		if props[Roact.Event.InputEnded] ~= nil then
			return props[Roact.Event.InputEnded](...)
		end
	end
	newProps[Roact.Event.SelectionGained] = function(...)
		self.stateTable.events.OnSelectionGained()
		if props[Roact.Event.SelectionGained] ~= nil then
			return props[Roact.Event.SelectionGained](...)
		end
	end
	newProps[Roact.Event.SelectionLost] = function(...)
		self.stateTable.events.OnSelectionLost()
		if props[Roact.Event.SelectionLost] ~= nil then
			return props[Roact.Event.SelectionLost](...)
		end
	end
	newProps[Roact.Event.Activated] = function(...)
		if self.state ~= ButtonState.Disabled and self.props[Roact.Event.Activated] ~= nil then
			return self.props[Roact.Event.Activated](...)
		end
	end
	if not FFlagLuaFixRoactRefAssignment then
		newProps[Roact.Ref] = function(rbx)
			self.ref.current = rbx
			local refHandler = props[Roact.Ref]
			if refHandler then
				-- if the ref is created using Roact.createRef
				if type(refHandler) == "table" then
					refHandler.current = rbx
				elseif type(refHandler) == "function" then
					refHandler(rbx)
				else
					error("Unsupported type for [Roact.Ref]: "..type(refHandler))
				end
			end
		end
	end
	return Roact.createElement(ImageSetButton, newProps)
end

function StateButton:didUpdate(previousProps, previousState)
	if self.props.Disabled ~= previousProps.Disabled then
		if self.props.Disabled then
			self.stateTable.events.Disable()
		else
			self.stateTable.events.Enable()
		end
	end
end

return StateButton