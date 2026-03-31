local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AETabButton = require(Modules.LuaApp.Components.Avatar.UI.Views.Portrait.AETabButton)
local CommonConstants = require(Modules.LuaApp.Constants)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local AEToggleFullView = require(Modules.LuaApp.Actions.AEActions.AEToggleFullView)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorSimultaneousFullViewAvatarTypeFix = settings():GetFFlag("AvatarEditorSimultaneousFullViewAvatarTypeFix")

local AETabList = Roact.PureComponent:extend("AETabList")

local TAB_PREFIX = "Tab-"
local TAB_WIDTH = 76 + (2 / 3)
local FIRST_TAB_BONUS_WIDTH = 10
local MAX_TAB_WIDTH = 72

-- Get the UI of all the tabs in this category.
function AETabList:getTabsUI()
	local categoryIndex = self.props.categoryIndex
	local currentTabPage = self.props.tabsInfo[categoryIndex]
	local category = AECategories.categories[categoryIndex]

	local tabs = {}
	-- Loop through the tabs and create each one
	for index, page in pairs(category.pages) do
		tabs[TAB_PREFIX ..page.name] = Roact.createElement(AETabButton, {
			index = index,
			page = page,
			currentTabPage = currentTabPage,
			tabWidth = self.tabWidth,
		})
	end

	return tabs
end

function AETabList:didUpdate(prevProps)
	local categoryIndex = self.props.categoryIndex
	local tabInfo = self.props.tabsInfo[categoryIndex]

	if self.props.categoryIndex ~= prevProps.categoryIndex then
		self.tabListRef.current.CanvasPosition =
			Vector2.new(self.tabWidth * (self.props.tabsInfo[categoryIndex] - 1), 0)
	end

	if FFlagAvatarEditorSimultaneousFullViewAvatarTypeFix and tabInfo ~= prevProps.tabsInfo[categoryIndex] and self.props.fullView then
		-- Toggle back to non-fullview to prevent simultaneous click fullview camera bug
		self.props.toggleFullView()
	end
end

function AETabList:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AETabListAndButtons:getThemeInfo(deviceOrientation, themeName) or nil
	local screenSize = self.props.screenSize
	local categoryIndex = self.props.categoryIndex
	local category = AECategories.categories[categoryIndex]

	if screenSize.X then
		local space = screenSize.X - FIRST_TAB_BONUS_WIDTH
		local tabNum = space / MAX_TAB_WIDTH
		self.tabWidth = space / ((2 * math.ceil(tabNum - 0.5) + 1) / 2)
	end

	local canvasSize = UDim2.new(0, #(category.pages) * (self.tabWidth + 1) + FIRST_TAB_BONUS_WIDTH, 0, 0)
	local tabs = self:getTabsUI()

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(1, -46, 0, 50),
		Position = UDim2.new(0, 46, 0, 0),
		ClipsDescendants = false,
		BackgroundColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabList.BackgroundColor or CommonConstants.Color.WHITE,
		BorderColor3 = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.TabList.BorderColor or CommonConstants.Color.GRAY3,
		BorderSizePixel = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.TabList.BorderSize or 1,
		BackgroundTransparency = 0,
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
		CanvasSize = canvasSize,
		HorizontalScrollBarInset = Enum.ScrollBarInset.None,
		MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		ScrollBarThickness = 0,
		ScrollingEnabled = true,
		TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,

		-- Used for tweening and keeping CanvasPosition between categories.
		[Roact.Ref] = self.tabListRef,
	}, {
		Contents = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = CommonConstants.Color.WHITE,
		},
			tabs),
	})
end

function AETabList:init()
	self.tabWidth = TAB_WIDTH
	self.tabListRef = Roact.createRef()
end

function AETabList:didMount()
	if not self.state.initialized then
		self:setState({ initialized = true })
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			fullView = state.AEAppReducer.AEFullView,
			tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			toggleFullView = function()
				dispatch(AEToggleFullView())
			end,
		}
	end
)(AETabList)