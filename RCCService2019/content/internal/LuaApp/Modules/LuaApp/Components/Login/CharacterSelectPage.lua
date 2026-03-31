local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local Colors = require(Modules.LuaApp.Themes.Colors)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)
local ItemListLayout = require(Modules.LuaApp.Components.Generic.ItemListLayout)

local FullscreenPageWithSafeArea = require(Modules.LuaApp.Components.FullscreenPageWithSafeArea)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local TitleAndParagraph = require(Modules.LuaApp.Components.Login.TitleAndParagraph)
local CharacterSelector = require(Modules.LuaApp.Components.Login.CharacterSelector)

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local PAGE_TITLE_KEY = "Feature.Avatar.Message.EmptyCostumes"

local BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"

local PAGE_PADDING_SIDE = 20
local PAGE_PADDING_BOTTOM_COMPACT = 40
local PAGE_PADDING_BOTTOM_WIDE = 90

local FOOTER_PADDING_TOP = 20

local NAVIGATION_ICON_SIZE = 27
local CONTINUE_BUTTON_HEIGHT = 44

local FOOTER_HEIGHT = FOOTER_PADDING_TOP + CONTINUE_BUTTON_HEIGHT

local MAX_TITLE_HEIGHT = 45
local MAX_PARAGRAPH_HEIGHT = 150

local CONTENT_VERTICAL_PADDING_COMPACT = 5
local CONTENT_VERTICAL_PADDING_WIDE = 25

local CharacterSelectPage = Roact.PureComponent:extend("CharacterSelectPage")

function CharacterSelectPage:init()
	self.state = {
		containerSize = Vector2.new(0, 0),
		headerSize = Vector2.new(0, 0),
		selectedBundleId = -1,
	}

	self.isMounted = false

	--[[

		Functions for monitoring absolute sizes of components

	--]]
	self.updateStateWithNewAbsoluteSize = function(key, newAbsoluteSize)
		if newAbsoluteSize.X > 0 and newAbsoluteSize.Y > 0 then
			-- Spawn since setstate can be triggered while a component is being reified or reconciled.
			-- This can be fixed with event suspension in new reconciler.
			spawn(function()
				if self.isMounted then
					self:setState({
						[key] = newAbsoluteSize,
					})
				end
			end)
		end
	end

	self.onAbsoluteSizeChange = function(rbx)
		self.updateStateWithNewAbsoluteSize("containerSize", rbx.AbsoluteSize)
	end

	self.onHeaderAbsoluteSizeChange = function(rbx)
		self.updateStateWithNewAbsoluteSize("headerSize", rbx.AbsoluteContentSize)
	end

	--[[

		Function for keeping track of current bundleId

	--]]
	self.onSelectedCharacterChanged = function(newBundleId)
		local selectedBundleId = self.state.selectedBundleId

		if selectedBundleId ~= newBundleId then
			spawn(function()
				if self.isMounted then
					self:setState({
						selectedBundleId = newBundleId,
					})
				end
			end)
		end
	end
end

function CharacterSelectPage:didMount()
	self.isMounted = true
end

function CharacterSelectPage:willUnmount()
	self.isMounted = false
end

function CharacterSelectPage:render()
	local formFactor = self.props.formFactor
	local bundleIds = self.props.bundleIds
	local assetIdsInBundle = self.props.assetIdsInBundle

	local containerWidth = self.state.containerSize.X
	local characterSelectorHeightOffset = self.state.headerSize.Y + FOOTER_HEIGHT

	local pagePaddingBottom = PAGE_PADDING_BOTTOM_COMPACT
	local buttonTitlePadding = CONTENT_VERTICAL_PADDING_COMPACT
	if formFactor == FormFactor.WIDE then
		pagePaddingBottom = PAGE_PADDING_BOTTOM_WIDE
		buttonTitlePadding = CONTENT_VERTICAL_PADDING_WIDE
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return Roact.createElement(FullscreenPageWithSafeArea, {
				BackgroundColor3 = style.Theme.BackgroundDefault.Color,
				BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
				includeStatusBar = true,
			}, {
				Contents = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChange,
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, PAGE_PADDING_SIDE),
						PaddingRight = UDim.new(0, PAGE_PADDING_SIDE),
						PaddingBottom = UDim.new(0, pagePaddingBottom),
					}),
					Header = Roact.createElement(ItemListLayout, {
						size = UDim2.new(1, 0, 0, 0),
						fitAxis = FitChildren.FitAxis.Height,
						Padding = UDim.new(0, buttonTitlePadding),
						[Roact.Change.AbsoluteContentSize] = self.onHeaderAbsoluteSizeChange,
						renderItemList = {
							Roact.createElement(ImageSetButton, {
								Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
								Image = BACK_BUTTON_IMAGE,
								ImageColor3 = style.Theme.TextEmphasis.Color,
								ImageTransparency = style.Theme.TextEmphasis.Transparency,
								BackgroundTransparency = 1,
								[Roact.Event.Activated] = function() end,
							}),
							Roact.createElement(TitleAndParagraph, {
								titleTextKey = PAGE_TITLE_KEY,
								width = containerWidth,
								maxTitleHeight = MAX_TITLE_HEIGHT,
								maxParagraphHeight = MAX_PARAGRAPH_HEIGHT,
							}),
						},
					}),
					CharacterSelectorArea = Roact.createElement("Frame", {
						Size = UDim2.new(1, PAGE_PADDING_SIDE * 2, 1, -characterSelectorHeightOffset),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.new(0.5, 0, 0, self.state.headerSize.Y),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
					}, {
						CharacterSelector = Roact.createElement(CharacterSelector, {
							bundleIds = bundleIds,
							assetIdsInBundle = assetIdsInBundle,
							onSelectedCharacterChanged = self.onSelectedCharacterChanged,
						}),
					}),
					Footer = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, FOOTER_HEIGHT),
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.new(0.5, 0, 1, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
					}, {
						ConfirmButton = Roact.createElement("Frame", {
							Size = UDim2.new(1, 0, 0, CONTINUE_BUTTON_HEIGHT),
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.new(0.5, 0, 1, 0),
							BorderSizePixel = 0,
							BackgroundTransparency = 0.5,
							BackgroundColor3 = Colors.Orange,
						}),
					}),
				}),
			})
		end)
	else
		return nil
	end
end

CharacterSelectPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		-- LUASTARTUP-48 will implement the thunk for the following endpoint and reducer.
		--
		-- Endpoint: https://auth.roblox.com/v3/signup/bundles
		-- Reducer (planned):
		-- 	state.newUserCharacterPresetBundles = {
		-- 		-- Track the list of bundle ids separate to preserve the order of the ids.
		-- 		bundleIds = {"4321", "0101", "2222"},
		-- 		-- Store assetIds for bundle.
		-- 		assetIdsInBundle = {
		-- 			["4321"] = {assetId1, assetId2, ...},
		-- 			["0101"] = {assetId1, assetId2, ...},
		-- 			["2222"] = {assetId1, assetId2, ...},
		-- 		}
		-- 	}

		-- local newUserCharacterPresetBundles = state.newUserCharacterPresetBundles
		-- local bundleIds = newUserCharacterPresetBundles.bundleIds
		-- local assetIdsInBundle = newUserCharacterPresetBundles.assetIdsInBundle

		local bundleIds = {
			"4321",
			"0101",
			"2222",
		}
		local assetIdsInBundle = {}

		return {
			formFactor = state.FormFactor,
			bundleIds = bundleIds,
			assetIdsInBundle = assetIdsInBundle,
		}
	end
)(CharacterSelectPage)

return CharacterSelectPage