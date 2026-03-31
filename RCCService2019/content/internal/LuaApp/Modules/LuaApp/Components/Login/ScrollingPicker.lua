local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local Otter = require(CorePackages.Otter)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local FitChildren = require(Modules.LuaApp.FitChildren)
local ItemListLayout = require(Modules.LuaApp.Components.Generic.ItemListLayout)
local ScrollingPickerDirection = require(Modules.LuaApp.Enum.ScrollingPickerDirection)

local DURATION_MULTIPLIER = 1

local OTTER_FREQUENCY = 2 * DURATION_MULTIPLIER
local SWIPE_DURATION_THRESHOLD = 0.3 * DURATION_MULTIPLIER

local SCROLLING_AXIS = {
	[ScrollingPickerDirection.Horizontal] = "X",
	[ScrollingPickerDirection.Vertical] = "Y",
}

local SUB_AXIS = {
	[ScrollingPickerDirection.Horizontal] = "Y",
	[ScrollingPickerDirection.Vertical] = "X",
}

--[[
	ScrollingPicker

	Vertically scrolling Picker element, which takes a list of items to display in the wheel.
	The following methods are recognized by this component for selecting entry.
		Tap
		Drag and Drop
		Scroll wheel
		Swipe Gesture
--]]

local ScrollingPicker = Roact.PureComponent:extend("ScrollingPicker")

ScrollingPicker.defaultProps = {
	layoutOrder = 0,
	initialIndex = 1,
	entries = {},
	entrySizeOnScrollingAxis = 10,
	scrollDirection = ScrollingPickerDirection.Vertical,
}

local RECOGNIZED_INPUT_TYPES = setmetatable(
	{
		[Enum.UserInputType.MouseButton1] = true,
		[Enum.UserInputType.Touch] = true,
	}, {
		__index = function(RECOGNIZED_INPUT_TYPES, key)
			return false
		end,
	}
)

function ScrollingPicker:init()
	local initialIndex = self.props.initialIndex
	local scrollDirection = self.props.scrollDirection

	-- LUASTARTUP-42 Make ScrollingPicker capable of handling the change of scroll direction.
	-- instead of using the value captured in :init().
	self.state = {
		scrollDirection = scrollDirection,
		scrollingAxis = SCROLLING_AXIS[scrollDirection],
		subAxis = SUB_AXIS[scrollDirection],
	}

	self.isMounted = false

	-- self.currentIndex
	--    - Used to keep track of current index calculated with frame position.
	--    - Not intended to be updated by anything other than onScrollPositionChanged.
	--
	-- self.targetIndex
	--    - Used to keep track of target index ScrollingPicker should focus.
	--    - Value is driven by user input.
	--    - Value is optionally driven by self.props.parentSpecifiedTarget.
	self.currentIndex = 1
	self.targetIndex = initialIndex
	self.timeInputBegan = tick()

	self.recognizedInputBegan = false
	self.inputChanged = false
	self.inputPreviousPositionScrollingAxis = 0

	self.scrollRef = Roact.createRef()

	--[[

		Helper Functions

	--]]
	-- Given a position on y axis, calculate the index of entry around the center of scrolling picker.
	self.getCenterIndexByPosition = function(position)
		local entrySizeOnScrollingAxis = self.props.entrySizeOnScrollingAxis

		return math.floor(-position / entrySizeOnScrollingAxis) + 1
	end

	self.getCenterIndexByScrollPosition = function(position)
		local entrySizeOnScrollingAxis = self.props.entrySizeOnScrollingAxis

		-- Add an offset to the position for scroll position
		position = position - entrySizeOnScrollingAxis / 2
		return self.getCenterIndexByPosition(position)
	end

	--[[

		Functions for updating parent with current index

	--]]
	self.updateParent = function()
		local onCurrentIndexChanged = self.props.onCurrentIndexChanged
		local onSelectedIndexChanged = self.props.onSelectedIndexChanged

		if onCurrentIndexChanged then
			onCurrentIndexChanged(self.currentIndex)
		end

		if onSelectedIndexChanged and self.currentIndex == self.targetIndex then
			onSelectedIndexChanged(self.currentIndex)
		end
	end

	self.onScrollPositionChanged = function()
		if self.scrollRef.current then
			local scrollingAxis = self.state.scrollingAxis
			local scrollPosition = self.scrollRef.current.Position[scrollingAxis].Offset
			local newIndex = self.getCenterIndexByScrollPosition(scrollPosition)

			if newIndex ~= self.currentIndex then
				self.currentIndex = newIndex
				self.updateParent()
			end
		end
	end

	--[[

		Functions for updating the scroll and current index

	--]]
	self.updateTargetIndex = function(newIndex)
		local entries = self.props.entries
		local entrySizeOnScrollingAxis = self.props.entrySizeOnScrollingAxis

		-- Do range check on the new target index
		newIndex = math.max(newIndex, 1)
		newIndex = math.min(newIndex, #entries)

		-- Update target index
		self.targetIndex = newIndex

		-- Setup motor for updated target index
		-- TODO LUASTARTUP-29 Remove stop() start() around setGoal() after Otter update
		self.motor:stop()
		self.motor:setGoal(Otter.spring(-(entrySizeOnScrollingAxis * (self.targetIndex - 1)), {
			frequency = OTTER_FREQUENCY,
		}))
		self.motor:start()

		-- Update parent with current index. Handles the case where the picker is already at the new target index.
		if self.currentIndex == self.targetIndex then
			self.updateParent()
		end
	end

	self.updateIndexByInputPosition = function(inputPosition)
		if self.scrollRef.current then
			local scrollingAxis = self.state.scrollingAxis

			local scrollAbsolutePosition = self.scrollRef.current.AbsolutePosition
			local scrollAbsoluteSize = self.scrollRef.current.AbsoluteSize

			if inputPosition.X > scrollAbsolutePosition.X and
				inputPosition.X < scrollAbsolutePosition.X + scrollAbsoluteSize.X and
				inputPosition.Y > scrollAbsolutePosition.Y and
				inputPosition.Y < scrollAbsolutePosition.Y + scrollAbsoluteSize.Y then

				local position = scrollAbsolutePosition[scrollingAxis] - inputPosition[scrollingAxis]

				local nearestIndex = self.getCenterIndexByPosition(position)

				self.updateTargetIndex(nearestIndex)
			end
		end
	end

	self.updateIndexByScrollPositionAndOffset = function(offset)
		offset = offset or 0

		if self.scrollRef.current then
			local scrollingAxis = self.state.scrollingAxis
			local scrollPosition = self.scrollRef.current.Position[scrollingAxis].Offset + offset
			local nearestIndex = self.getCenterIndexByScrollPosition(scrollPosition)

			self.updateTargetIndex(nearestIndex)
		end
	end

	--[[

		Functions for input handling

	--]]
	self.onInputBegan = function(_, inputObject)
		local entries = self.props.entries
		local scrollingAxis = self.state.scrollingAxis

		if self.isMounted and RECOGNIZED_INPUT_TYPES[inputObject.UserInputType] and #entries > 0 then
			self.recognizedInputBegan = true
			self.timeInputBegan = tick()
			self.inputPreviousPositionScrollingAxis = inputObject.Position[scrollingAxis]

			self.motor:stop()
		end
	end

	self.onInputChanged = function(_, inputObject)
		local entries = self.props.entries
		local entrySizeOnScrollingAxis = self.props.entrySizeOnScrollingAxis
		local scrollingAxis = self.state.scrollingAxis

		if self.recognizedInputBegan then
			-- Drag along with input position
			local calculatedDelta = inputObject.Position[scrollingAxis] - self.inputPreviousPositionScrollingAxis

			if self.scrollRef.current then
				local currentPosition = self.scrollRef.current.Position
				local newOffset = currentPosition[scrollingAxis].Offset + calculatedDelta
				newOffset = math.min(0, newOffset)
				newOffset = math.max(newOffset, - (entrySizeOnScrollingAxis * (#entries - 1)))

				-- TODO LUASTARTUP-29 Remove stop() start() around setGoal() after Otter update
				self.motor:stop()
				self.motor:setGoal(Otter.instant(newOffset))
				self.motor:start()
			end

			self.inputChanged = true
			self.inputPreviousPositionScrollingAxis = inputObject.Position[scrollingAxis]
		end
	end

	self.onInputEnded = function(_, inputObject)
		local scrollingAxis = self.state.scrollingAxis

		if self.recognizedInputBegan then
			if self.inputChanged then
				local timeDifference = tick() - self.timeInputBegan
				if timeDifference < SWIPE_DURATION_THRESHOLD then
					-- If Swipe
					local offset = inputObject.Delta[scrollingAxis] / timeDifference
					self.updateIndexByScrollPositionAndOffset(offset)
				else
					-- If Drag and Drop
					self.updateIndexByScrollPositionAndOffset(0)
				end
			else
				-- If Tapped
				self.updateIndexByInputPosition(inputObject.Position)
			end
		end

		self.recognizedInputBegan = false
		self.inputChanged = false
	end

	self.onMouseWheelForward = function()
		self.updateTargetIndex(self.currentIndex - 1)
	end
	self.onMouseWheelBackward = function()
		self.updateTargetIndex(self.currentIndex + 1)
	end
end

function ScrollingPicker:didMount()
	self.updateParent()
	self.motor = Otter.createSingleMotor(0)
	self.motor:onStep(function(newOffset)
		if self.scrollRef.current then
			local scrollingAxis = self.state.scrollingAxis
			local subAxis = self.state.subAxis

			local scrollDirection = self.state.scrollDirection
			local position = self.scrollRef.current.Position

			if scrollDirection == ScrollingPickerDirection.Horizontal then
				position = UDim2.new(UDim.new(position[scrollingAxis].Scale, newOffset), position[subAxis])
			else
				position = UDim2.new(position[subAxis], UDim.new(position[scrollingAxis].Scale, newOffset))
			end

			self.scrollRef.current.Position = position
		end
	end)
	self.updateTargetIndex(self.targetIndex)
	self.isMounted = true
end

function ScrollingPicker:willUnmount()
	self.isMounted = false
	self.motor:destroy()
end

function ScrollingPicker:didUpdate(prevProps)
	local parentSpecifiedTarget = self.props.parentSpecifiedTarget

	if parentSpecifiedTarget ~= self.targetIndex
		and parentSpecifiedTarget ~= prevProps.parentSpecifiedTarget then
		self.updateTargetIndex(parentSpecifiedTarget)
	end
end

function ScrollingPicker:render()
	return withStyle(function(style)
		local layoutOrder = self.props.layoutOrder
		local size = self.props.size
		local entries = self.props.entries
		local entrySizeOnScrollingAxis = self.props.entrySizeOnScrollingAxis
		local scrollDirection = self.state.scrollDirection

		local fitAxis
		local fillDirection
		local entrySize
		local frameSize
		local centerPosition
		if scrollDirection == ScrollingPickerDirection.Horizontal then
			fitAxis = FitChildren.FitAxis.Width
			fillDirection = Enum.FillDirection.Horizontal
			entrySize = UDim2.new(0, entrySizeOnScrollingAxis, 1, 0)
			frameSize = UDim2.new(0, 0, 1, 0)
			centerPosition = UDim2.new(0.5, -entrySizeOnScrollingAxis/2, 0, 0)
		else
			fitAxis = FitChildren.FitAxis.Height
			fillDirection = Enum.FillDirection.Vertical
			entrySize = UDim2.new(1, 0, 0, entrySizeOnScrollingAxis)
			frameSize = UDim2.new(1, 0, 0, 0)
			centerPosition = UDim2.new(0, 0, 0.5, -entrySizeOnScrollingAxis/2)
		end

		local listContents = {}

		for _, entry in ipairs(entries) do
			table.insert(
				listContents,
				Roact.createElement("Frame", {
					Size = entrySize,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					self.props.renderEntry(entry)
				})
			)
		end

		return Roact.createElement("Frame", {
			LayoutOrder = layoutOrder,
			Size = size,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputChanged] = self.onInputChanged,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.MouseWheelForward] = self.onMouseWheelForward,
			[Roact.Event.MouseWheelBackward] = self.onMouseWheelBackward,
		}, {
			CenterPosition = Roact.createElement("Frame", {
				Size = frameSize,
				Position = centerPosition,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			}, {
				AnimatedSlidingList = Roact.createElement(FitChildren.FitFrame, {
					Size = frameSize,
					fitAxis = fitAxis,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					[Roact.Ref] = self.scrollRef,
					[Roact.Change.AbsolutePosition] = self.onScrollPositionChanged,
				}, {
					List = Roact.createElement(ItemListLayout, {
						fitAxis = fitAxis,
						FillDirection = fillDirection,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						renderItemList = listContents,
					}),
				}),
			}),
		})
	end)
end

return ScrollingPicker