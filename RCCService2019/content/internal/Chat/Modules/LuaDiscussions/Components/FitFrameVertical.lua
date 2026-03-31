local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local CorePackages = game:GetService("CorePackages")
local Roact = dependencies.Roact
local Immutable = require(CorePackages.AppTempCommon.Common.Immutable)

local FitFrameVertical = Roact.PureComponent:extend("FitFrameVertical")
FitFrameVertical.defaultProps = {
	width = UDim.new(0, 0),
	contentPadding = UDim.new(0, 0),
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
}

function FitFrameVertical:init()
	self.layoutRef = Roact.createRef()
	self.frameRef = Roact.createRef()

	self.onResize = function()
		local currentLayout = self.layoutRef.current
		local currentFrame = self.frameRef.current
		if not currentFrame or not currentLayout then
			return
		end

		local width = self.props.width
		local absoluteContentSize = currentLayout.AbsoluteContentSize
		local fullHeight = absoluteContentSize.Y

		currentFrame.Size = UDim2.new(width, UDim.new(0, fullHeight))
	end
end

function FitFrameVertical:render()
	local backgroundColor3 = self.props.BackgroundColor3
	local children = self.props[Roact.Children] or {}
	local width = self.props.width
	local horizontalAlignment = self.props.HorizontalAlignment
	local backgroundTransparency = self.props.BackgroundTransparency
	local contentPadding = self.props.contentPadding
	local layoutOrder = self.props.LayoutOrder
	local fillDirection = self.props.FillDirection
	local verticalAlignment = self.props.VerticalAlignment

	local fullHeight = 0
	if self.layoutRef.current then
		fullHeight = self.layoutRef.current.AbsoluteContentSize.Y
	end

	return Roact.createElement("Frame", {
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = backgroundTransparency,
		Size = UDim2.new(width.Scale, width.Offset, 0, fullHeight),
		LayoutOrder = layoutOrder,
		[Roact.Ref] = self.frameRef,
	},
		Immutable.JoinDictionaries(children, {
			layout = Roact.createElement("UIListLayout", {
				Padding = contentPadding,
				FillDirection = fillDirection,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = horizontalAlignment,
				VerticalAlignment = verticalAlignment,
				[Roact.Ref] = self.layoutRef,
				[Roact.Change.AbsoluteContentSize] = self.onResize,
			})
		})
	)
end

function FitFrameVertical:didMount()
	self.onResize()
end

function FitFrameVertical:didUpdate()
	self.onResize()
end

return FitFrameVertical
