--[[
Events page
_____________________
|                   |
|       TopBar      |
|___________________|
|                   |
|     EventList     |
|  _______________  |
| |               | |
| | EventButton 1 | |
| | EventButton 2 | |
| | EventButton 3 | |
| |_______________| |
|___________________|
]]

local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local UrlBuilder = require(Modules.LuaApp.Http.UrlBuilder)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local SponsoredEvents = require(Modules.LuaApp.Thunks.SponsoredEvents)

local TopBar = require(Modules.LuaApp.Components.TopBar)
local EventButton = require(Modules.LuaApp.Components.More.EventButton)
local MorePageScrollingFrame = require(Modules.LuaApp.Components.More.MorePageScrollingFrame)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)

local EVENTS_PADDING = 10

local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local FixMorePageScroll = FlagSettings.FixMorePageScroll()

local EventsPage = Roact.PureComponent:extend("EventsPage")

function EventsPage:init()
	self.dispatchFetchSponsoredEvents = function()
		return self.props.dispatchFetchSponsoredEvents(self.props.networking)
	end

	self.onButtonActivated = function(context)
		self.props.navigateDown({
			name = AppPage.GenericWebPage,
			detail = context.url,
			extraProps = {
				title = context.title,
			},
		})
	end

	self.getEventUrl = function(path)
		local urlBuilder = UrlBuilder.new({
			base = "www",
			path = path,
		})
		return urlBuilder()
	end
end

function EventsPage:renderOnLoaded(textStyle)
	local isWideView = self.props.formFactor == FormFactor.WIDE
	local topBarHeight = self.props.topBarHeight
	local sponsoredEvents = self.props.sponsoredEvents

	if sponsoredEvents and #sponsoredEvents > 0 then
		local paddingHorizontal = isWideView and Constants.MORE_PAGE_WIDE_PADDING_HORINZONTAL or
			Constants.MORE_PAGE_SECTION_PADDING
		local paddingVertical = isWideView and Constants.MORE_PAGE_WIDE_PADDING_VERTICAL or
			Constants.MORE_PAGE_SECTION_PADDING
		local eventList = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, EVENTS_PADDING),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, paddingVertical),
				PaddingBottom = UDim.new(0, paddingVertical),
				PaddingLeft = UDim.new(0, paddingHorizontal),
				PaddingRight = UDim.new(0, paddingHorizontal),
			}),
		}

		for index, event in ipairs(sponsoredEvents) do
			eventList["Event"..tostring(index)..event.name] =  Roact.createElement(EventButton, {
				LayoutOrder = index,
				Image = event.imageUrl,
				context = {
					title = event.title,
					url = self.getEventUrl(event.pagePath),
				},
				onActivated = self.onButtonActivated,
			})
		end

		-- Clean up props when remove FFlagFixMorePageScroll
		return Roact.createElement(FixMorePageScroll and MorePageScrollingFrame or FitChildren.FitScrollingFrame, {
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
		}, eventList)
	else
		-- No event is going on, display no event text
		return Roact.createElement(LocalizedTextLabel, {
			Position = UDim2.new(0, 0, 0, topBarHeight),
			Size = UDim2.new(1, 0, 1, -topBarHeight),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "CommonUI.Features.Label.MoreEvents",
			Font = textStyle.Font,
			TextSize = textStyle.Size,
			TextColor3 = textStyle.Color,
			TextTransparency = textStyle.Transparency,
			TextWrapped = true,
		})
	end
end

function EventsPage:render()
	local theme = self._context.AppTheme

	local sponsoredEventsFetchingStatus = self.props.sponsoredEventsFetchingStatus

	local renderEventsPage = function(backgroundStyle, textStyle)
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
			EventsContent = Roact.createElement(LoadingStateWrapper, {
				dataStatus = sponsoredEventsFetchingStatus,
				onRetry = self.dispatchFetchSponsoredEvents,
				debugName = "EventsPage",
				renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
				renderOnLoaded = function()
					return self:renderOnLoaded(textStyle)
				end,
			}),
		})
	end

	if UseNewAppStyle then
		return withStyle(function(style)
			local textStyle = Cryo.Dictionary.join(style.Theme.TextMuted, {
				Font = style.Font.Body.Font,
				Size = style.Font.BaseSize * style.Font.Body.RelativeSize
			})
			return renderEventsPage(style.Theme.BackgroundDefault, textStyle)
		end)
	else
		return renderEventsPage(theme.MorePage.Background, theme.EventsPage.Text)
	end
end

function EventsPage:didMount()
	if self.props.sponsoredEventsFetchingStatus == RetrievalStatus.NotStarted then
		self.dispatchFetchSponsoredEvents()
	end
end

EventsPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			topBarHeight = state.TopBar.topBarHeight,
			sponsoredEvents = state.SponsoredEvents,
			sponsoredEventsFetchingStatus = SponsoredEvents.GetFetchingStatus(state),
		}
	end,
	function(dispatch)
		return {
			dispatchFetchSponsoredEvents = function(networking)
				return dispatch(SponsoredEvents.Fetch(networking))
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(EventsPage)

return RoactServices.connect({
	networking = RoactNetworking,
})(EventsPage)
