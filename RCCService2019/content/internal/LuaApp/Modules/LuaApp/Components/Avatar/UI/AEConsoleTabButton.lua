local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AESelectCategoryTab = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategoryTab)
local AESetGamepadNavigationMenuLevel = require(Modules.LuaApp.Actions.AEActions.AESetGamepadNavigationMenuLevel)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local Constants = require(Modules.LuaApp.Constants)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local AEGetUserInventory = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserInventory)
local AECurrentPageHasAssets = require(Modules.LuaApp.Selectors.AESelectors.AECurrentPageHasAssets)
local AEGetUserOutfits = require(Modules.LuaApp.Thunks.AEThunks.AEGetUserOutfits)
local SoundManager = require(Modules.Shell.SoundManager)
local AEConsoleTabButton = Roact.PureComponent:extend("AEConsoleTabButton")

local BUTTON_INTERVAL = 100

function AEConsoleTabButton:init()
	self.buttonRef = Roact.createRef()

	local selectionImageObject = Instance.new("ImageLabel")
	selectionImageObject.Image = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-item selector-8px corner.png"
	selectionImageObject.Position = UDim2.new(0, -7, 0, -7)
	selectionImageObject.Size = UDim2.new(1, 14, 1, 14)
	selectionImageObject.BackgroundTransparency = 1
	selectionImageObject.ScaleType = Enum.ScaleType.Slice
	selectionImageObject.SliceCenter = Rect.new(31, 31, 63, 63)
	selectionImageObject.ZIndex = 2
	self.selectionImageObject = selectionImageObject
end

function AEConsoleTabButton:render()
	local index = self.props.index
	local page = self.props.page
	local categoryIndex = self.props.categoryIndex
	local tabsInfo = self.props.tabsInfo
	local tabButtonImage, textColor, textTransparency
	textTransparency =
		self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage and 0.5 or 0

	if index == tabsInfo[categoryIndex] then
		tabButtonImage = "rbxasset://textures/ui/Shell/AvatarEditor/button/btn-category-selected.png"
		textColor = Constants.Color.GRAY1
		textTransparency = 0
	else
		tabButtonImage = "rbxasset://textures/ui/Shell/AvatarEditor/button/btn-category.png"
		textColor = Constants.Color.WHITE
	end

	local text = page.title
	local textLocalized = true

	if page.iconText then
		text = page.iconText
		textLocalized = false
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(0, 360, 0, 80),
		Position = UDim2.new(0, 0, 0, index * BUTTON_INTERVAL),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = tabButtonImage,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
		Selectable = true,
		SelectionImageObject = self.selectionImageObject,
		ZIndex = 2,

		[Roact.Ref] = self.buttonRef,
		[Roact.Event.SelectionGained] = function()
			self.props.selectCategoryTab(categoryIndex, index)
		end,
		[Roact.Event.Activated] = function()
			if self.props.hasAssetsToRender or
				page.pageType == AEConstants.PageType.BodyColors or page.pageType == AEConstants.PageType.Scale then
				SoundManager:Play('OverlayOpen')
				self.props.setGamepadNavigationMenuLevel(AEConstants.GamepadNavigationMenuLevel.AssetsPage)
			end
		end,
	}, {

		MoveSelection = Roact.createElement("Sound", {
			SoundId = "rbxasset://sounds/ui/Shell/MoveSelection.mp3",
			Volume = 0.35,
		}),

		TabButtonText = Roact.createElement(textLocalized and LocalizedTextLabel or "TextLabel", {
			Position = UDim2.new(0, 20, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = textColor,
			TextTransparency = textTransparency,
			TextSize = 36,
			Font = Enum.Font.SourceSans,
			ZIndex = 2,
		})
	})
end

function AEConsoleTabButton:didUpdate(prevProps, prevState)
	-- Check if user entered or exited the tab list
	if self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel and
		self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.TabList and
		self.props.tabsInfo[self.props.categoryIndex] == self.props.index then
		GuiService.SelectedCoreObject = self.buttonRef.current
	end

	local page = self.props.page
	local getUserInventory = self.props.getUserInventory
	local initializedTabs = self.props.initializedTabs
	local getUserOutfits = self.props.getUserOutfits
	local costumePage = page.assetTypeId == AEConstants.OUTFITS or page.assetTypeId == AEConstants.PRESET_COSTUMES

	-- Check if this tab has been accessed before. If not, dispatch an action for a web call.
	if not costumePage and page.assetTypeId and not initializedTabs[page.assetTypeId]
		and self.currentTabPage == self.index then
		getUserInventory(page.assetTypeId)
	elseif costumePage and not initializedTabs[page.assetTypeId]
		and self.currentTabPage == self.index then
		getUserOutfits(page.assetTypeId)
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
			initializedTabs = state.AEAppReducer.AECategory.AEInitializedTabs,
			hasAssetsToRender = AECurrentPageHasAssets(state.AEAppReducer),
		}
	end,

	function(dispatch)
		return {
			selectCategoryTab = function(categoryIndex, tabIndex)
				dispatch(AESelectCategoryTab(categoryIndex, tabIndex))
			end,
			setGamepadNavigationMenuLevel = function(gamepadNavigationMenuLevel)
				dispatch(AESetGamepadNavigationMenuLevel(gamepadNavigationMenuLevel))
			end,
			getUserInventory = function(assetType)
				dispatch(AEGetUserInventory(assetType))
			end,
			getUserOutfits = function(costumeType, pageNumber)
				dispatch(AEGetUserOutfits(costumeType, pageNumber))
			end,
		}
	end
)(AEConsoleTabButton)