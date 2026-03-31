local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AEConsoleTabButton = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleTabButton)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)

local BUTTON_INTERVAL = 100
local SELECTOR_TOP_MIN_DISTANCE = 270
local SELECTOR_BOTTOM_MIN_DISTANCE = 190
local BUTTONS_BEFORE_SCROLLING_DOWN = 6
local BUTTONS_BEFORE_SCROLLING_UP = 1
local AEConsoleTabList = Roact.PureComponent:extend("AEConsoleTabList")

function AEConsoleTabList:init()
	self.tabListRef = Roact.createRef()
end

function AEConsoleTabList:didMount()
	GuiService:AddSelectionParent("TabList", self.tabListRef.current)

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	self.openTween = TweenService:Create(self.tabListRef.current, tweenInfo, { Visible = true })
	self.closeTween = TweenService:Create(self.tabListRef.current, tweenInfo, { Visible = false })
end

function AEConsoleTabList:willUnmount()
	GuiService:RemoveSelectionGroup("TabList")
end

function AEConsoleTabList:render()
	local categoryIndex = self.props.categoryIndex
	local tabButtons = {}

	for index, page in pairs(AECategories.categories[categoryIndex].pages) do
		tabButtons["Tab" ..index] = Roact.createElement(AEConsoleTabButton, {
			index = index,
			page = page,
		})
	end

	return Roact.createElement("ScrollingFrame", {
		Position = UDim2.new(0, 220, 0, 170),
		Size = UDim2.new(0, 360, 1, 0),
		CanvasSize = UDim2.new(1, 0, 1, #AECategories.categories[categoryIndex].pages * 100),
		BackgroundTransparency = 1,
		ScrollingEnabled = false,
		Selectable = false,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		Visible = false,
		ZIndex = 2,

		[Roact.Ref] = self.tabListRef,
	},
		tabButtons)
end

function AEConsoleTabList:didUpdate(prevProps, prevState)
	if self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel then
		if self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.CategoryMenu then
			self.tabListRef.current.Visible = false
		elseif self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.TabList and
			prevProps.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.CategoryMenu then
			self.openTween:Play()
			self:tweenCanvas(true)
		end
	end

	if self.props.tabsInfo ~= prevProps.tabsInfo then
		self:tweenCanvas(false)
	end
end

function AEConsoleTabList:getCanvasPositionGoal(tabButton, tabIndex)
	local topDistance = tabButton.AbsolutePosition.Y
	local bottomDistance = self.tabListRef.current.Parent.AbsoluteSize.Y - topDistance - tabButton.AbsoluteSize.Y
	local canvasPositionGoal = self.tabListRef.current.CanvasPosition

	if bottomDistance < SELECTOR_BOTTOM_MIN_DISTANCE then
		canvasPositionGoal = Vector2.new(0, (tabIndex - BUTTONS_BEFORE_SCROLLING_DOWN) * BUTTON_INTERVAL)
	elseif topDistance < SELECTOR_TOP_MIN_DISTANCE then
		canvasPositionGoal = Vector2.new(0, (tabIndex - BUTTONS_BEFORE_SCROLLING_UP) * BUTTON_INTERVAL)
	end

	return canvasPositionGoal
end

function AEConsoleTabList:tweenCanvas(instant)
	local currentCanvasPosition = self.tabListRef.current.CanvasPosition
	local selectedTabIndex = self.props.tabsInfo[self.props.categoryIndex]
	local canvasPositionGoal = self:getCanvasPositionGoal(GuiService.SelectedCoreObject, selectedTabIndex)

	if canvasPositionGoal ~= currentCanvasPosition then
		-- If opening the tablist, the tween is instant. Otherwise the tween is for scrolling.
		if instant then
			self.tabListRef.current.CanvasPosition = canvasPositionGoal
		else
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			TweenService:Create(self.tabListRef.current, tweenInfo, { CanvasPosition = canvasPositionGoal }):Play()
		end
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
		}
	end
)(AEConsoleTabList)