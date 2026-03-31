--[[
Settings page
_____________________
|                   |
|       TopBar      |
|___________________|
| SettingsPageList  |
|     _________     |
|     | Row 1 |     |
|     | Row 2 |     |
|     | Row 3 |     |
|     | Row 4 |     |
|     | Row 5 |     |
|     |_______|     |
|___________________|
]]

local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local memoize = require(Modules.Common.memoize)
local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local MorePageSettings = require(Modules.LuaApp.MorePageSettings)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local MoreList = require(Modules.LuaApp.Components.More.MoreList)
local MoreItemContainer = require(Modules.LuaApp.Components.More.MoreItemContainer)
local MorePageScrollingFrame = require(Modules.LuaApp.Components.More.MorePageScrollingFrame)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local FixMorePageScroll = FlagSettings.FixMorePageScroll()

local SettingsPage = Roact.PureComponent:extend("SettingsPage")

function SettingsPage:init()
	self.renderItem = function(item, itemLayoutInfo)
		return Roact.createElement(MoreItemContainer, {
			item = item,
			layoutInfo = itemLayoutInfo,
		})
	end
end

function SettingsPage:render()
	local theme = self._context.AppTheme

	local formFactor = self.props.formFactor
	local topBarHeight = self.props.topBarHeight
	local settingsPageItemList = self.props.settingsPageItemList

	local isWideView = formFactor == FormFactor.WIDE

	local renderSettingsPage = function(backgroundStyle)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = backgroundStyle.Color,
			BackgroundTransparency = backgroundStyle.Transparency,
		}, {
			TopBar = Roact.createElement(TopBar, {
				showBuyRobux = true,
				showNotifications = true,
			}),
			-- Clean up props when remove FFlagFixMorePageScroll
			Scroller = Roact.createElement(FixMorePageScroll and MorePageScrollingFrame or FitChildren.FitScrollingFrame, {
				Position = UDim2.new(0, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, -topBarHeight),
				CanvasSize = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,
				ClipsDescendants = false,
				fitFields = {
					CanvasSize = FitChildren.FitAxis.Height,
				},
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_HORINZONTAL or 0),
					PaddingRight = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_HORINZONTAL or 0),
					PaddingTop = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_VERTICAL or
						Constants.MORE_PAGE_SECTION_PADDING),
					PaddingBottom = UDim.new(0, isWideView and Constants.MORE_PAGE_WIDE_PADDING_VERTICAL or
						Constants.MORE_PAGE_SECTION_PADDING),
				}),
				SettingsPageList = Roact.createElement(MoreList, {
					itemList = settingsPageItemList,
					renderItem = self.renderItem,
					rowHeight = Constants.MORE_PAGE_ROW_HEIGHT,
				}),
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return renderSettingsPage(style.Theme.BackgroundDefault)
		end)
	else
		return renderSettingsPage(theme.MorePage.Background)
	end
end

local getSettingsPageItemList = memoize(function(notificationCount)
	return Cryo.List.map(MorePageSettings.GetItemsInPage(AppPage.Settings), function(item)
		if item.itemType == MorePageSettings.ItemType.Settings_AccountInfo and
			item.badgeCount ~= notificationCount then
			return Cryo.Dictionary.join(item, {
				badgeCount = notificationCount,
			})
		end
		return item
	end)
end)

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local notificationCount = state.NotificationBadgeCounts.MorePageSettings

		return {
			formFactor = state.FormFactor,
			topBarHeight = state.TopBar.topBarHeight,
			settingsPageItemList = getSettingsPageItemList(notificationCount),
		}
	end
)(SettingsPage)
