-- Deprecated. Remove with FFlagLuaAppUseUIBloxAccordion

--[[
	Creates a Roact component which will automatically animate

	Props:
		animatedProps : table. Props put in this table will be animated.
			Since We don't have very good support of non-integer values in Otter yet (like UDim2)
			We have to separate and convert them to individual pieces. See AnimatedItem.AnimatedProp.
			For properties that are integers such as "BackgroundTransparency", use directly.
		springOptions : table. For configuring the spring in Otter.
		onComplete : function. Called when the animation is complete.

	Example:
		To create a frame whose position animates up / down:
		AnimatedFrame = Roact.createElement(AnimatedItem.AnimatedFrame, {
			Size = ...,
			BackgroundColor3 = ...,
			animatedProps = {
				[AnimatedItem.AnimatedProp.Position.Offset.Y] = goal,
			},
		})
		Whenever goal changes, the frame will animate toward the new position.
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Otter = require(CorePackages.Otter)
local Roact = require(Modules.Common.Roact)
local Immutable = require(Modules.Common.Immutable)
local TableUtilities = require(Modules.LuaApp.TableUtilities)

local FFlagLuaFixRoactRefAssignment = game:GetFastFlag("LuaFixRoactRefAssignment")

local AnimatedItem = {}

AnimatedItem.AnimatedProp = {
	Size = {
		Offset = {
			X = "SizeOffsetX",
			Y = "SizeOffsetY",
		},
	},
	Position = {
		Offset = {
			X = "PositionOffsetX",
			Y = "PositionOffsetY",
		},
	},
}

function AnimatedItem.wrap(component)
	local AnimatedComponent = Roact.PureComponent:extend(string.format("AnimatedItem(%s)",
		tostring(component)))

	AnimatedComponent.defaultProps = {
		animatedProps = {},
	}

	function AnimatedComponent:init()
		self.instance = nil
		if FFlagLuaFixRoactRefAssignment then
			local propsRef = self.props[Roact.Ref]
			assert(
				type(propsRef) ~= "function",
				("%s does not support function ref forwarding"):format(tostring(AnimatedComponent))
			)
			self.ref = propsRef or Roact.createRef()
		else
			self.ref = function(rbx)
				if rbx == nil then
					return
				end

				self.instance = rbx
				local refHandler = self.props[Roact.Ref]
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

				-- Apply props to the ref. This is done here because Ref could change,
				-- and we want to reapply when that happens.
				self.applyProps(self.props.animatedProps)
			end
		end

		self.applyProps = function(props)
			if FFlagLuaFixRoactRefAssignment then
				self.instance = self.ref.current
			end

			if not self.instance then
				return
			end

			for propName, value in pairs(props) do
				if propName == AnimatedItem.AnimatedProp.Size.Offset.X then
					-- This can't be written outside because not every element has size/position properties
					local size = self.instance.Size
					size = UDim2.new(UDim.new(size.X.Scale, value), size.Y)
					self.instance.Size = size
				elseif propName == AnimatedItem.AnimatedProp.Size.Offset.Y then
					local size = self.instance.Size
					size = UDim2.new(size.X, UDim.new(size.Y.Scale, value))
					self.instance.Size = size
				elseif propName == AnimatedItem.AnimatedProp.Position.Offset.X then
					local position = self.instance.Position
					position = UDim2.new(UDim.new(position.X.Scale, value), position.Y)
					self.instance.Position = position
				elseif propName == AnimatedItem.AnimatedProp.Position.Offset.Y then
					local position = self.instance.Position
					position = UDim2.new(position.X, UDim.new(position.Y.Scale, value))
					self.instance.Position = position
				else
					-- Apply the prop directly to the Roblox instance. This works for properties which are integers,
					-- such as ImageTransparency, BackgroundTransparency.
					self.instance[propName] = value
				end
			end
		end

		self.onComplete = function()
			if self.props.onComplete then
				self.props.onComplete()
			end
		end

		self.motor = nil
	end

	function AnimatedComponent:didMount()
		local animatedProps = self.props.animatedProps

		-- Set up motor
		self.motor = Otter.createGroupMotor(animatedProps)
		self.motor:onStep(function(newValues)
			self.applyProps(newValues)
		end)
		self.motor:onComplete(self.onComplete)
		self.motor:start()

		if FFlagLuaFixRoactRefAssignment then
			self.applyProps(self.props.animatedProps)
		end
	end

	function AnimatedComponent:render()
		local props = Immutable.RemoveFromDictionary(self.props, "animatedProps", "onComplete", "springOptions")
		props[Roact.Ref] = self.ref

		return Roact.createElement(component, props)
	end

	function AnimatedComponent:didUpdate(oldProps)
		-- If the animatedProps changed, set new goals for the motor so they animate.
		if not TableUtilities.ShallowEqual(self.props.animatedProps, oldProps.animatedProps) then
			local goals = {}
			for propName, newValue in pairs(self.props.animatedProps) do
				local springOptions = self.props.springOptions -- nil means default
				goals[propName] = Otter.spring(newValue, springOptions)
			end
			self.motor:setGoal(goals)
		end
	end

	function AnimatedComponent:willUnmount()
		self.motor:destroy()
		self.motor = nil
	end

	return AnimatedComponent
end

AnimatedItem.AnimatedFrame = AnimatedItem.wrap("Frame")
AnimatedItem.AnimatedImageLabel = AnimatedItem.wrap("ImageLabel")
AnimatedItem.AnimatedUIScale = AnimatedItem.wrap("UIScale")

return AnimatedItem