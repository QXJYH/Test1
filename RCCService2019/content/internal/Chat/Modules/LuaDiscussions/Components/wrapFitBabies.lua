local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact

local function wrapFitBabies(component)
	local wrappedComponent = Roact.PureComponent:extend(("wrapFitBabies(%s)"):format(tostring(component)))

	function wrappedComponent:init()
		self.containerRef = Roact.createRef()

		self.onResize = function(uiLayout, optionalUIPadding)
			if not self.containerRef.current then
				return
			end

			local uiPaddingX = 0
			local uiPaddingY = 0
			if optionalUIPadding then
				uiPaddingX = optionalUIPadding.PaddingLeft.Offset + optionalUIPadding.PaddingRight.Offset
				uiPaddingY = optionalUIPadding.PaddingTop.Offset + optionalUIPadding.PaddingBottom.Offset
			end

			local contentSize = uiLayout.AbsoluteContentSize
			self.containerRef.current.Size = UDim2.new(0, contentSize.X + uiPaddingX, 0, contentSize.Y + uiPaddingY)
		end
	end

	function wrappedComponent:render()
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = self.props.LayoutOrder,
			[Roact.Ref] = self.containerRef,
		}, {
			child = Roact.createElement(component, self.props),
		})
	end

	function wrappedComponent:didMount()
		local uiLayout = self.containerRef.current:FindFirstChildWhichIsA("UIGridStyleLayout", true)
		assert(uiLayout, "Attempted to mount a wrapFitBabies component without UIGridStyleLayout!")

		local optionalUIPadding = self.containerRef.current:FindFirstChildWhichIsA("UIPadding", true)
		self.connection = uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			self.onResize(uiLayout, optionalUIPadding)
		end)
		self.onResize(uiLayout, optionalUIPadding)
	end

	function wrappedComponent:willUnmount()
		if self.connection then
			self.connection:Disconnect()
			self.connection = nil
		end
	end

	return wrappedComponent
end

return wrapFitBabies