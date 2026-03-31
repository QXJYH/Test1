--[[

        -- |- CanvasPos x -| --
        |  |               |  |
        |  |               |  |
        |  |  FillingArea  |  |
        |  |               | ScrollingFrame
  PeekView |               |  |
 component |---------------|  | --
    height |  PeekHeader   |  |  |
        |  |---------------|  |  |
        |  |  Content ...  |  | ClipFrame
        |  |---------------|  |  |
        |  |BottomContainer|  |  |
        -- |---------------| -- --
           .               .
           .  ... Content  .
           .               .

  FillingArea:
    Input can penetrate this area

    --     |-------_-------| --
    |      |               |  |
    |      |               |  |
    |      |               | PeekView
  Full     |               | component
    |   -- |-------_-------| height
    |   |  |               |  |
    | Brief|               |  |
    |   |  |               |  |
    --  -- |-------_-------| -- -- Closed
            -------_-------     -- Hidden

  isTouched:
    PeekView is under holding or swiping

  isInGoToState:
    PeekView is automatically going up or down to brief, full or close view
    This state can NOT be stopped by any touch
]]

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService('RunService')
local Roact = require(CorePackages.Roact)
local FitChildren = require(Modules.LuaApp.FitChildren)
local Symbol = require(Modules.Common.Symbol)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local ArgCheck = require(Modules.LuaApp.ArgCheck)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UIBlox = require(CorePackages.UIBlox)

local withStyle = function(func)
	-- PeekView should be shipped WITH new theme system
	if FlagSettings.UseNewAppStyle() then
		return UIBlox.Style.withStyle(func)
	end

	return func({ Theme = {
		BackgroundDefault = {
			Color = Color3.fromRGB(35, 37, 39),
			Transparency = 0,
		}
	}})
end

local BACKGROUND_SLICE_CENTER = Rect.new(9, 9, 9, 9)
local BACKGROUND_IMAGE = "LuaApp/buttons/buttonFill"
-- TODO: DRAGGER_IMAGE waiting for design
local PEEK_HEADER_HEIGHT = 25
local GO_TO_TRANSITION_TIME = 0.6
local FULL_VIEW_HEIGHT = UDim.new(1, 0)

local VT_Hidden = Symbol.named("Hidden")
local VT_Closed = Symbol.named("Closed")
local VT_Brief = Symbol.named("Brief")
local VT_Full = Symbol.named("Full")

local PeekView = Roact.PureComponent:extend("PeekView")

PeekView.defaultProps = {
	briefViewContentHeight = UDim.new(0.5, 0),
	bottomDockedContainerHeight = 0,
	bottomDockedContainerContent = nil,
	closeCallback = nil,
	hidden = false,
}

function PeekView:init()
	self.isMounted = false

	self.isTouched = false
	self.isInGoToState = false

	self.pendingCloseCallback = false

	self.viewType = VT_Hidden

	self.containerFrameRef = Roact.createRef()
	self.clipFrameRef = Roact.createRef()
	self.fillingAreaRef = Roact.createRef()
	self.swipeScrollingFrameRef = Roact.createRef()
	self.bottomContainterRef = Roact.createRef()

	self.inputBeganCallback = function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		self.isTouched = true
	end

	self.inputEndedCallback = function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		self.isTouched = false
		self.checkGoTo()
	end

	self.updateRbxInstances = function()
		if not self.isMounted then
			return
		end

		local swipeScrollingFrame = self.swipeScrollingFrameRef.current
		local scrollingFrameCanvasY = swipeScrollingFrame and swipeScrollingFrame.CanvasPosition.Y or 0

		-- Round scrollingFrameCanvasY to an integer to prevent PeekHeader & BottomContainer jittering
		if scrollingFrameCanvasY ~= math.floor(scrollingFrameCanvasY) then
			swipeScrollingFrame.CanvasPosition = Vector2.new(0, math.floor(scrollingFrameCanvasY + 0.5))
			return
		end

		if scrollingFrameCanvasY <= 0 and self.pendingCloseCallback then
			self.pendingCloseCallback = false
			local hidden = self.props.hidden
			local closeCallback = self.props.closeCallback
			if not hidden and closeCallback then
				closeCallback()
			end
		end

		local containerFrame = self.containerFrameRef.current
		local clipFrame = self.clipFrameRef.current
		local fillingArea = self.fillingAreaRef.current

		local width = containerFrame.AbsoluteSize.X
		local height = containerFrame.AbsoluteSize.Y

		clipFrame.Size = UDim2.new(0, width, 0, scrollingFrameCanvasY)
		clipFrame.Position = UDim2.new(0, 0, 0, height - scrollingFrameCanvasY)

		swipeScrollingFrame.Size = UDim2.new(0, width, 0, height)
		swipeScrollingFrame.Position = UDim2.new(0, 0, 0, - (height - scrollingFrameCanvasY))

		fillingArea.Size = UDim2.new(0, width, 0, height)

		local bottomContainter = self.bottomContainterRef.current
		if bottomContainter then
			local bottomDockedContainerHeight = self.props.bottomDockedContainerHeight
			if clipFrame.AbsoluteSize.Y > PEEK_HEADER_HEIGHT + bottomDockedContainerHeight then
				bottomContainter.Position = UDim2.new(0, 0, 1, - bottomDockedContainerHeight)
			else
				bottomContainter.Position = UDim2.new(0, 0, 1, - clipFrame.AbsoluteSize.Y + PEEK_HEADER_HEIGHT)
			end
		end

		self.checkGoTo()
	end

	self.checkGoTo = function()
		if self.isInGoToState then
			return
		end

		if self.isTouched then
			return
		end

		local containerFrameHeight = self.containerFrameRef.current.AbsoluteSize.Y
		local swipeScrollingFrame = self.swipeScrollingFrameRef.current

		local curY = swipeScrollingFrame.CanvasPosition.Y
		local inertialVelocityY = swipeScrollingFrame:GetSampledInertialVelocity().Y

		local bfvContentHeight = self.props.briefViewContentHeight
		local briefViewY = containerFrameHeight * bfvContentHeight.Scale + bfvContentHeight.Offset + PEEK_HEADER_HEIGHT
		local fullViewY = containerFrameHeight * FULL_VIEW_HEIGHT.Scale + FULL_VIEW_HEIGHT.Offset

		if curY > briefViewY and curY < fullViewY then
			local briefToFullDistance = fullViewY - briefViewY
			if self.viewType == VT_Full then
				if inertialVelocityY > 0 or curY < briefViewY + briefToFullDistance * 0.8 then
					self.goTo(VT_Closed)
				else
					self.goTo(VT_Full)
				end
			else
				if inertialVelocityY < 0 or curY > briefViewY + briefToFullDistance * 0.2 then
					self.goTo(VT_Full)
				else
					self.goTo(VT_Brief)
				end
			end
		elseif curY > 0 and curY < briefViewY then
			local closedToBriefDistance = briefViewY - 0
			if self.viewType == VT_Brief then
				if inertialVelocityY > 0 or curY < 0 + closedToBriefDistance * 0.8 then
					self.goTo(VT_Closed)
				else
					self.goTo(VT_Brief)
				end
			else
				if inertialVelocityY < 0 or curY > 0 + closedToBriefDistance * 0.2 then
					self.goTo(VT_Brief)
				else
					self.goTo(VT_Closed)
				end
			end
		end
	end

	self.onPeekHeaderActivated = function()
		if self.viewType == VT_Closed then
			self.goTo(VT_Brief)
		elseif self.viewType == VT_Brief then
			self.goTo(VT_Full)
		elseif self.viewType == VT_Full then
			self.goTo(VT_Closed)
		end
	end

	self.clearGoTo = function()
		if self.connection then
			self.connection:disconnect()
			self.connection = nil
		end
		self.isInGoToState = false
		self.clipFrameRef.current.Active = false
	end

	self.goTo = function(viewType)
		if not self.isMounted then
			return
		end

		if ArgCheck.isEqual(self.isInGoToState, false, "self.isInGoToState") then
			return
		end

		if ArgCheck.isEqual(self.connection, nil, "self.connection") then
			return
		end

		local viewSize
		if viewType == VT_Hidden then
			viewSize = UDim.new(0, 0)
		elseif viewType == VT_Closed then
			viewSize = UDim.new(0, PEEK_HEADER_HEIGHT)
			self.pendingCloseCallback = true
		elseif viewType == VT_Brief then
			local briefViewContentHeight = self.props.briefViewContentHeight
			viewSize = UDim.new(briefViewContentHeight.Scale, briefViewContentHeight.Offset + PEEK_HEADER_HEIGHT)
		elseif viewType == VT_Full then
			viewSize = FULL_VIEW_HEIGHT
		end

		self.isInGoToState = true
		self.swipeScrollingFrameRef.current:ClearInertialScrolling()
		self.clipFrameRef.current.Active = true

		local startTime = tick()

		self.connection = RunService.RenderStepped:Connect(function()
			if not self.isMounted then
				return
			end

			local swipeScrollingFrame = self.swipeScrollingFrameRef.current
			local containerFrameHeight = self.containerFrameRef.current.AbsoluteSize.Y
			local goToPosY = containerFrameHeight * viewSize.Scale + viewSize.Offset
			local timeElapsed = tick() - startTime

			-- On Complete
			if timeElapsed >= GO_TO_TRANSITION_TIME then
				self.viewType = viewType
				swipeScrollingFrame.CanvasPosition = Vector2.new(0, goToPosY)
				self.clearGoTo()
				return
			end

			local startPosY = swipeScrollingFrame.CanvasPosition.Y
			local distance = goToPosY - startPosY
			swipeScrollingFrame.CanvasPosition = Vector2.new(0,
				startPosY + distance * math.sin((timeElapsed / GO_TO_TRANSITION_TIME) * (math.pi / 2.0)))
		end)
	end

end

function PeekView:render()
	local children = self.props[Roact.Children]

	local bottomDockedContainerHeight = self.props.bottomDockedContainerHeight
	local bottomDockedContainerContent = self.props.bottomDockedContainerContent

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			[Roact.Ref] = self.containerFrameRef,
		}, {
			ClipFrame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				[Roact.Ref] = self.clipFrameRef,
			}, {
				SwipeScrollingFrame = Roact.createElement(FitChildren.FitScrollingFrame, {
					BackgroundTransparency = 1,
					ZIndex = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ClipsDescendants = false,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ElasticBehavior = Enum.ElasticBehavior.Always,
					fitFields = {
						CanvasSize = FitChildren.FitAxis.Height,
					},
					[Roact.Ref] = self.swipeScrollingFrameRef,
					[Roact.Change.CanvasPosition] = self.updateRbxInstances,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),
					FillingArea = Roact.createElement("Frame", {
						LayoutOrder = 1,
						BackgroundTransparency = 1,
						Active = false,
						[Roact.Ref] = self.fillingAreaRef,
					}),
					BackgroundFrame = Roact.createElement("Frame", {
						LayoutOrder = 2,
						ZIndex = 1,
						-- In order not to affect SwipeScrollingFrame CanvasSize
						Size = UDim2.new(1, 0, 0, 0),
						Active = false,
					}, {
						BackgroundImage = Roact.createElement(ImageSetLabel, {
							Size = UDim2.new(1, 0, 0, 9999),
							BackgroundTransparency = 1,
							ImageTransparency = style.Theme.BackgroundDefault.Transparency,
							ImageColor3 = style.Theme.BackgroundDefault.Color,
							BorderSizePixel = 0,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = BACKGROUND_SLICE_CENTER,
							Image = BACKGROUND_IMAGE,
							Active = false,
						}),
					}),
					PeekHeader = Roact.createElement("TextButton", {
						LayoutOrder = 3,
						ZIndex = 2,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, PEEK_HEADER_HEIGHT),
						[Roact.Event.Activated] = self.onPeekHeaderActivated,
					}, {
						Dragger = Roact.createElement("ImageLabel", {
							BackgroundTransparency = 0,
							Size = UDim2.new(0.15, 0, 0, 5),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Active = false,
						}),
					}),
					ContentFrame = Roact.createElement(FitChildren.FitFrame, {
						LayoutOrder = 4,
						ZIndex = 2,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						ClipsDescendants = false,
						Size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
					}, children),
					BottomContainterPlaceHolder = bottomDockedContainerHeight > 0 and Roact.createElement("Frame", {
						LayoutOrder = 5,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, bottomDockedContainerHeight),
						Active = false,
					}),
				}),
				BottomContainter = bottomDockedContainerHeight > 0 and Roact.createElement("Frame", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 0, bottomDockedContainerHeight),
					BackgroundTransparency = 1,
					[Roact.Ref] = self.bottomContainterRef,
				}, bottomDockedContainerContent),
			}),
			InputBegan = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputBegan,
				callback = self.inputBeganCallback,
			}),
			InputEnded = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputEnded,
				callback = self.inputEndedCallback,
			}),
		})
	end)
end

function PeekView:didMount()
	self.isMounted = true

	local hidden = self.props.hidden
	if not hidden then
		self.goTo(VT_Brief)
	end
end

function PeekView:didUpdate(prevProps, prevState)
	if prevProps.hidden == false and self.props.hidden == true then
		self.goTo(VT_Hidden)
	elseif prevProps.hidden == true and self.props.hidden == false then
		self.goTo(VT_Brief)
	end
end

function PeekView:willUnmount()
	self.isMounted = false
end

return PeekView
