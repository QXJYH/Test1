-- Deprecated, remove with FFlagLuaAppUseUIBloxAccordion

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)

local AnimatedItem = require(Modules.LuaApp.Components.Generic.AnimatedItem)
local GenericIconButton = require(Modules.LuaApp.Components.GenericIconButton)

local COLLAPSE_BUTTON_ICON = "LuaApp/icons/GameDetails/collapse"
local COLLAPSE_BUTTON_SIZE = 44
local COLLAPSE_BUTTON_ICON_SIZE = 36

local VERTICAL_MARGIN = 10 -- Margin between expanded items
local SHRINK_STEP = 20 -- How much each item shrinks below card above it

local MAX_ITEMS_IN_COMPACT_VIEW = 3
local PRESSED_SCALE = 0.9
local COLLAPSE_BUTTON_ANIMATION_START_POSITION = 10

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local AccordionViewAnimated = Roact.PureComponent:extend("AccordionViewAnimated")

AccordionViewAnimated.defaultProps = {
	items = {},
}

function AccordionViewAnimated:init()
	self.state = {
		expanded = false,
		isExpandPressed = false,
	}

	self.collapseButtonActivated = function()
		self:setState({
			expanded = false,
		})
	end

	self.expandButtonActivated = function()
		self:setState({
			expanded = true,
			isExpandPressed = false,
		})
	end

	self.onButtonInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			self:setState({
				isExpandPressed = true,
			})
		end
	end

	self.onButtonInputEnded = function(_, inputObject)
		if self.state.isExpandPressed then
			self:setState({
				isExpandPressed = false,
			})
		end
	end

	self.rootFrameRef = Roact.createRef()
	self.scalerFrameRef = Roact.createRef()

	self.onListLayoutAbsoluteContentSizeChanged = function(rbx)
		if self.rootFrameRef.current and self.scalerFrameRef then
			local itemWidth = self.props.itemWidth
			local minimumHeight = self:getCompactTotalHeight()
			local contentHeight = rbx.AbsoluteContentSize.Y

			self.scalerFrameRef.current.Size = UDim2.new(0, itemWidth, 0, contentHeight)
			self.rootFrameRef.current.Size = UDim2.new(0, itemWidth, 0, math.max(minimumHeight, contentHeight))
		end
	end
end

function AccordionViewAnimated:getCompactTotalHeight()
	local items = self.props.items
	local itemHeight = self.props.itemHeight
	local totalNumberOfItems = #items

	return itemHeight + (math.min(MAX_ITEMS_IN_COMPACT_VIEW, totalNumberOfItems) - 1) * VERTICAL_MARGIN
end

function AccordionViewAnimated:getLayoutInfo()
	local items = self.props.items
	local itemHeight = self.props.itemHeight
	local fakeItemBaseTransparency = self.props.fakeItemBaseTransparency
	local fakeItemTransparencyStep = self.props.fakeItemTransparencyStep
	local expanded = self.state.expanded

	local layoutData = {}

	local totalNumberOfItems = #items

	for index = 1, totalNumberOfItems do
		if expanded then
			layoutData[index] = {
				widthOffset = 0,
				height = itemHeight,
				fakeItemTransparency = 1,
				realItemTransparency = 0,
			}
		else
			if index == 1 then
				layoutData[1] = {
					widthOffset = 0,
					height = itemHeight,
					fakeItemTransparency = 1,
					realItemTransparency = 0,
				}
			elseif index <= MAX_ITEMS_IN_COMPACT_VIEW then
				layoutData[index] = {
					widthOffset = - SHRINK_STEP * (index - 1),
					height = VERTICAL_MARGIN,
					fakeItemTransparency = fakeItemBaseTransparency + fakeItemTransparencyStep * (index - 2),
					realItemTransparency = 1,
				}
			else
				layoutData[index] = {
					widthOffset = - SHRINK_STEP * (index - 1),
					height = 0,
					fakeItemTransparency = 1,
					realItemTransparency = 1,
				}
			end
		end
	end

	return layoutData
end

function AccordionViewAnimated:render()
	local layoutOrder = self.props.LayoutOrder
	local items = self.props.items
	local itemWidth = self.props.itemWidth
	local renderItem = self.props.renderItem
	local fakeItemBackgroundColor = self.props.fakeItemBackgroundColor
	local expanded = self.state.expanded
	local isExpandPressed = self.state.isExpandPressed

	local layoutData = self:getLayoutInfo()

	local totalNumberOfItems = #items
	local canExpand = (totalNumberOfItems > 1)

	local children = {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, expanded and VERTICAL_MARGIN or 0),
			[Roact.Change.AbsoluteContentSize] = self.onListLayoutAbsoluteContentSizeChanged,
		}),
		-- TODO: we should figure out a good way to do group transparency,
		-- so we can fade out this icon instead of using ClipsDescendants.
		CollapseButton = canExpand and Roact.createElement(AnimatedItem.AnimatedFrame, {
			LayoutOrder = 1,
			Size = UDim2.new(0, COLLAPSE_BUTTON_SIZE, 0, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			ZIndex = 0,
			ClipsDescendants = true,
			animatedProps = {
				-- Increase the size by 1 pixel so the animation looks better with the spring damping.
				[AnimatedItem.AnimatedProp.Size.Offset.Y] = expanded and COLLAPSE_BUTTON_SIZE + 1 or 0,
			},
			springOptions = ANIMATION_SPRING_SETTINGS,
		}, {
			AnimationContainer = Roact.createElement(AnimatedItem.AnimatedFrame, {
				Size = UDim2.new(0, COLLAPSE_BUTTON_SIZE, 0, COLLAPSE_BUTTON_SIZE),
				BackgroundTransparency = 1,
				animatedProps = {
					[AnimatedItem.AnimatedProp.Position.Offset.Y] = expanded and 0 or
						COLLAPSE_BUTTON_ANIMATION_START_POSITION,
				},
				springOptions = ANIMATION_SPRING_SETTINGS,
			}, {
				Button = Roact.createElement(GenericIconButton, {
					Size = UDim2.new(1, 0, 1, 0),
					iconSize = UDim2.new(0, COLLAPSE_BUTTON_ICON_SIZE, 0, COLLAPSE_BUTTON_ICON_SIZE),
					iconImage = COLLAPSE_BUTTON_ICON,
					onActivated = self.collapseButtonActivated,
				}),
			}),
		}),
	}

	for index, _ in ipairs(items) do
		local layout = layoutData[index]

		local clickToExpand = canExpand and not expanded and index == 1

		children["Item" .. tostring(index)] = Roact.createElement(AnimatedItem.AnimatedFrame, {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = index + 1,
			ZIndex = totalNumberOfItems + 1 - index;
			animatedProps = {
				[AnimatedItem.AnimatedProp.Size.Offset.X] = layout.widthOffset,
				[AnimatedItem.AnimatedProp.Size.Offset.Y] = layout.height,
			},
			ClipsDescendants = true,
			springOptions = ANIMATION_SPRING_SETTINGS,
		}, {
			RealItem = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Item = renderItem(index, not clickToExpand, layout.realItemTransparency, ANIMATION_SPRING_SETTINGS),
			}),
			FakeItem = Roact.createElement(AnimatedItem.AnimatedFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = fakeItemBackgroundColor,
				animatedProps = {
					BackgroundTransparency = layout.fakeItemTransparency,
				},
				springOptions = ANIMATION_SPRING_SETTINGS,
				BorderSizePixel = 0,
			}),
			ClickToExpand = clickToExpand and Roact.createElement("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = totalNumberOfItems + 1,
				Text = "",
				[Roact.Event.Activated] = self.expandButtonActivated,
				[Roact.Event.InputBegan] = self.onButtonInputBegan,
				[Roact.Event.InputEnded] = self.onButtonInputEnded,
			})
		})
	end

	children.Scaler = Roact.createElement(AnimatedItem.AnimatedUIScale, {
		animatedProps = {
			Scale = isExpandPressed and PRESSED_SCALE or 1,
		},
		springOptions = ANIMATION_SPRING_SETTINGS,
	})

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, itemWidth, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		[Roact.Ref] = self.rootFrameRef,
	}, {
		-- UIScale doesn't work properly on the root frame because of a bug
		-- between UIScaler and UIListLayout. (CLIPLAYEREX-2469)
		-- So we put in an extra frame for now to achieve the correct effect.
		ScalerFrame = Roact.createElement("Frame", {
			Size = UDim2.new(0, itemWidth, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			[Roact.Ref] = self.scalerFrameRef,
		}, children),
	})
end

return AccordionViewAnimated
