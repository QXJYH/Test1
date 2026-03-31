local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Cryo = dependencies.Cryo

--[[
    Add a UIListLayout to the table of children if that table isn't nil or empty. Returns a shallow copy of the original
    table with the new element added.
--]]
local function addLayout(children, layoutProps)
    if not children or Cryo.isEmpty(children) then
        return {}
    end

    local layout = Roact.createElement("UIListLayout", Cryo.Dictionary.join({
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, layoutProps))

    return Cryo.Dictionary.join(children, {
        ["GenericHeader.layout"] = layout,
    })
end

--[[
    Create a new Roact component type that organizes three sets of children into left, center and right aligned groups.
    Any of these three can be empty or nil. GenericHeader will automatically add a UIListLayout to each set of children.
    If you want to use a different layout, you will need to encapsulate that set of children in your own subframe.
    Note that the left and right children are in a container with no width, so relative widths won't work there.

    The results of this call is a component type. This will need to be passed to Roact.createElement at which point
    additional properties can be specified. For example:

    local headerType = GenericHeader("foo", leftChildren, {}, {})
    local header = Roact.createElement(headerType, {Size = UDim2.new(0.5, 0, 0.5, 0)})

    The ElementSpacing property specifies the horizontal padding of elements within the three groups of children as well
    as the padding between the groups.
--]]
local function GenericHeader(name, leftChildren, centerChildren, rightChildren)
    local wrapper = Roact.PureComponent:extend(("GenericHeader(%s)"):format(name))
    wrapper.defaultProps = {
        Size = UDim2.new(1, 0, 1, 0),
        ElementSpacing = 0,
    }

	function wrapper:init()
		self.containerRef = Roact.createRef()

        self.onResize = function(self, leftLayout, center, rightLayout)
            local size = self.containerRef.current.AbsoluteSize.X

            local leftSize = 0
            if leftLayout then
                leftSize = leftLayout.AbsoluteContentSize.X
            end

            local rightSize = 0
            if rightLayout then
                rightSize = rightLayout.AbsoluteContentSize.X
            end

            local centerSize = size - 2*(math.max(leftSize, rightSize))
            if self.props.ElementSpacing then
                centerSize = centerSize - 2*self.props.ElementSpacing
            end
            center.Size = UDim2.new(0, math.max(centerSize, 0), 1, 0)
		end
	end

    function wrapper:render()
        local padding = UDim.new(0, self.props.ElementSpacing)
        local leftCopy = addLayout(leftChildren, {
            Padding = padding,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
        })
        local centerCopy = addLayout(centerChildren, {
            Padding = padding,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        })
        local rightCopy = addLayout(rightChildren, {
            Padding = padding,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
        })

        local left = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
            LayoutOrder = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 1, 0),
		}, leftCopy)
        local center = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
            LayoutOrder = 2,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
		}, centerCopy)
        local right = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
            LayoutOrder = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 1, 0),
		}, rightCopy)

        local frameProps = Cryo.Dictionary.join(self.props, {
            [Roact.Ref] = self.containerRef,
            ElementSpacing = Cryo.None,
        })
        return Roact.createElement("Frame", frameProps,
        Cryo.Dictionary.join({
            left = left,
            center = center,
            right = right,
		}, self.props[Roact.Children] or {}))
	end

    function wrapper:didMount()
        local leftLayout = self.containerRef.current.left:FindFirstChildWhichIsA("UIGridStyleLayout")
        local center = self.containerRef.current.center
        local rightLayout = self.containerRef.current.right:FindFirstChildWhichIsA("UIGridStyleLayout")

        -- If there's center children, hook up the onResize function
        if not Cryo.isEmpty(center:GetChildren()) then
            self.connection = self.containerRef.current:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                self:onResize(leftLayout, center, rightLayout)
            end)
            self:onResize(leftLayout, center, rightLayout)
        end
	end

    function wrapper:willUnmount()
		if self.connection then
			self.connection:Disconnect()
			self.connection = nil
		end
	end

	return wrapper
end

return GenericHeader