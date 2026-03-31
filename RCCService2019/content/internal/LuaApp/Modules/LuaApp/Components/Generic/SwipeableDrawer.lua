local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)

local FitChildren = require(Modules.LuaApp.FitChildren)

local SwipeableDrawer = Roact.PureComponent:extend("SwipeableDrawer")

--[[
start:
       -- |        | <- 0
       |  |        |
container |        |
   height |        |
       |  |--------| <- startPosition
       -- |content |    (maxPosition)

fully drawn out:
          |        | <- 0
          |--------| <- containerHeight - canvasHeight
          |content |    (minPosition)
          |  ...   |
          |  ...   |
          |  end   |
]]

function SwipeableDrawer:init()
	self.frameRef = nil
	self.onFrameRef = function(rbx)
		if rbx then
			local startPosition = self.props.startPosition
			self.frameRef = rbx
			-- Set startPostion
			self.frameRef.Position = UDim2.new(0, 0, 0, startPosition)
		end
	end

	self.scrollingFrameRef = Roact.createRef()

	self.recalculateDrawerPosition = function()
		if self.frameRef and self.scrollingFrameRef.current then
			local maxPosition = self.props.startPosition

			local canvasHeight = self.scrollingFrameRef.current.CanvasSize.Y.Offset
			local containerHeight = self.props.containerHeight
			local minPosition = math.max(0, containerHeight - canvasHeight)

			local currentPosition = self.frameRef.Position.Y.Offset
			local canvasMovement = self.scrollingFrameRef.current.CanvasPosition.Y

			if currentPosition == minPosition and canvasMovement > 0 or
				currentPosition == maxPosition and canvasMovement < 0 then
				return
			end

			local newPosition = currentPosition - canvasMovement
			newPosition = math.max(newPosition, minPosition)
			newPosition = math.min(newPosition, maxPosition)

			self.frameRef.Position = UDim2.new(0, 0, 0, newPosition)
			self.scrollingFrameRef.current.CanvasPosition = Vector2.new(0, 0)
		end
	end
end

function SwipeableDrawer:render()
	local size = self.props.Size
	local anchorPoint = self.props.AnchorPoint
	local children = self.props[Roact.Children]

	return Roact.createElement("Frame", {
		Size = size,
		AnchorPoint = anchorPoint,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		[Roact.Ref] = self.onFrameRef,
	}, {
		ScrollingFrame = Roact.createElement(FitChildren.FitScrollingFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			ClipsDescendants = false,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.Always,
			fitFields = {
				CanvasSize = FitChildren.FitAxis.Height,
			},
			[Roact.Ref] = self.scrollingFrameRef,
			[Roact.Change.CanvasSize] = self.recalculateDrawerPosition,
			[Roact.Change.CanvasPosition] = self.recalculateDrawerPosition,
		}, children)
	})
end

function SwipeableDrawer:didUpdate(prevProps)
	if prevProps.startPosition ~= self.props.startPosition or
		prevProps.containerHeight ~= self.props.containerHeight then
		self.recalculateDrawerPosition()
	end
end

return SwipeableDrawer
