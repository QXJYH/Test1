--[[
More page
_____________________
|                   |
|       TopBar      |
|___________________|
|   MorePageTable   |
|    __________     |
|    | List 1 |     |
|    | List 2 |     |
|    | List 3 |     |
|    | List 4 |     |
|    | List 5 |     |
|    |________|     |
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
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local MoreTable = require(Modules.LuaApp.Components.More.MoreTable)
local MoreItemContainer = require(Modules.LuaApp.Components.More.MoreItemContainer)
local MorePageScrollingFrame = require(Modules.LuaApp.Components.More.MorePageScrollingFrame)

local FetchNotificationCount = require(Modules.LuaApp.Thunks.FetchNotificationCount)
local SponsoredEvents = require(Modules.LuaApp.Thunks.SponsoredEvents)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local FixMorePageScroll = FlagSettings.FixMorePageScroll()

local MorePage = Roact.PureComponent:extend("MorePage")

function MorePage:init()
	self.renderItem = function(item, itemLayoutInfo)
		return Roact.createElement(MoreItemContainer, {
			item = item,
			layoutInfo = itemLayoutInfo,
		})
	end
end

function MorePage:render()
	local theme = self._context.AppTheme

	local formFactor = self.props.formFactor
	local topBarHeight = self.props.topBarHeight
	local morePageItemTable = self.props.morePageItemTable

	local isWideView = formFactor == FormFactor.WIDE

	local renderMorePage = function(backgroundStyle)
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
				MorePageTable = Roact.createElement(MoreTable, {
					itemTable = morePageItemTable,
					renderItem = self.renderItem,
					rowHeight = Constants.MORE_PAGE_ROW_HEIGHT,
					padding = Constants.MORE_PAGE_SECTION_PADDING,
				}),
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			return renderMorePage(style.Theme.BackgroundDefault)
		end)
	else
		return renderMorePage(theme.MorePage.Background)
	end
end

function MorePage:didMount()
	if self.props.sponsoredEventsFetchingStatus == RetrievalStatus.NotStarted then
		self.props.dispatchFetchSponsoredEvents(self.props.networking)
	end
end

function MorePage:didUpdate(previousProps, previousState)
	local currentPageName = self.props.currentPageName
	local previousPageName = previousProps.currentPageName
	local previousRootPageName = previousProps.currentRootPageName

	if currentPageName == AppPage.More and previousPageName ~= AppPage.More and
		previousRootPageName == AppPage.More then
		-- Navigate from more sub page to more root page should update notification counts
		self.props.dispatchFetchNotificationCount(self.props.networking)
	end
end

local getMorePageItemTable = memoize(function(morePageType, notificationBadgeCounts, eventsCount)
	return Cryo.List.map(MorePageSettings.GetItemsInPage(morePageType), function(itemList)
		return Cryo.List.map(itemList, function(item)
			local badgeCount = 0
			if item.itemType == MorePageSettings.ItemType.Friends then
				badgeCount = notificationBadgeCounts.MorePageFriends
			elseif item.itemType == MorePageSettings.ItemType.Messages then
				badgeCount = notificationBadgeCounts.MorePageMessages
			elseif item.itemType == MorePageSettings.ItemType.Settings or
				item.itemType == MorePageSettings.ItemType.Settings_AccountInfo then
				badgeCount = notificationBadgeCounts.MorePageSettings
			elseif item.itemType == MorePageSettings.ItemType.Events then
				badgeCount = eventsCount
			end

			if item.badgeCount ~= badgeCount then
				return Cryo.Dictionary.join(item, {
					badgeCount = badgeCount,
				})
			end
			return item
		end)
	end)
end)

MorePage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]

		return {
			formFactor = state.FormFactor,
			topBarHeight = state.TopBar.topBarHeight,
			currentRootPageName = currentRoute[1].name,
			currentPageName = currentRoute[#currentRoute].name,
			sponsoredEventsFetchingStatus = SponsoredEvents.GetFetchingStatus(state),
			morePageItemTable = getMorePageItemTable(props.morePageType or AppPage.More,
				state.NotificationBadgeCounts,
				#state.SponsoredEvents),
		}
	end,
	function(dispatch)
		return {
			dispatchFetchNotificationCount = function(networking)
				return dispatch(FetchNotificationCount(networking))
			end,
			dispatchFetchSponsoredEvents = function(networking)
				return dispatch(SponsoredEvents.Fetch(networking))
			end,
		}
	end
)(MorePage)

return RoactServices.connect({
	networking = RoactNetworking,
})(MorePage)
