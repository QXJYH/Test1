local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactAnalyticsTopBar = require(Modules.LuaApp.Services.RoactAnalyticsTopBar)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local AppPage = require(Modules.LuaApp.AppPage)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local NavigateUp = require(Modules.LuaApp.Thunks.NavigateUp)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local NavigateSideways = require(Modules.LuaApp.Thunks.NavigateSideways)
local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)

local SetTopBarHeight = require(Modules.LuaApp.Actions.SetTopBarHeight)
local SetSearchParameters = require(Modules.LuaApp.Actions.SetSearchParameters)

local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)
local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local Constants = require(Modules.LuaApp.Constants)
local AppPageLocalizationKeys = require(Modules.LuaApp.AppPageLocalizationKeys)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local SearchUuid = require(Modules.LuaApp.SearchUuid)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local SearchBar = require(Modules.LuaApp.Components.SearchBar)
local NotificationBadge = require(Modules.LuaApp.Components.NotificationBadge)
local NumericalBadge = require(Modules.LuaApp.Components.NumericalBadge)
local SiteMessageBanner = require(Modules.LuaApp.Components.SiteMessageBanner)
local TouchFriendlyIconButton = require(Modules.LuaApp.Components.Generic.TouchFriendlyIconButton)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")
local FFlagLuaAppTopBarCustomBackButton = settings():GetFFlag("LuaAppTopBarCustomBackButton")
local UseNewAppStyle = FlagSettings.UseNewAppStyle()
local IsLuaBottomBarEnabled = FlagSettings.IsLuaBottomBarEnabled()

local NAV_BAR_SIZE = 44

local ICON_IMAGE_SIZE = 24
local ICON_BUTTON_SIZE = 44
local BACK_BUTTON_SIZE = 72
local BACK_BUTTON_IMAGE = "LuaApp/icons/ic-back"
local SEARCH_ICON_IMAGE = "LuaApp/icons/ic-search"
local ROBUX_ICON_IMAGE = "LuaApp/icons/ic-ROBUX"
local NOTIFICATION_ICON_IMAGE = "LuaApp/icons/ic-notification"
local NUMERICAL_BADGE_OFFSET = 10

-- Retheme
if UseNewAppStyle then
	BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"
	SEARCH_ICON_IMAGE  = "LuaApp/icons/ic-search-new"
	NOTIFICATION_ICON_IMAGE = "LuaApp/icons/GameDetails/notificationsOn"
	ROBUX_ICON_IMAGE = "LuaApp/icons/archived/ARCHIVED_robux"
	ICON_IMAGE_SIZE = 36
end

local SEARCH_BAR_SIZE = 260
local SEARCH_BAR_PADDING = 6

local DeviceSpecificTopBarIconSpec = {
	--[[
	[Form Factor Type] = {
		MarginRight = Right margin for the list layout of the icons
		Padding = Padding between icons in the list layout
		IconButtonSize = Size of the icon button(touchable area)
		BackImageOffset = Space between back button edge to back button image
	},
	--]]
	[FormFactor.COMPACT] = {
		MarginRight = 13,
		Padding = 2,
		IconButtonSize = 34,
		BackImageOffset = 16,
	},
	[FormFactor.WIDE] = {
		MarginRight = 12,
		Padding = 3,
		IconButtonSize = 44,
		BackImageOffset = 20,
	},
}

local TOP_BAR_COLOR = Constants.Color.BLUE_PRESSED
local TOP_SYSTEM_BACKGROUND_COLOR = Constants.Color.BLUE_PRESSED

local DEFAULT_TEXT_COLOR = Constants.Color.WHITE

local DEFAULT_TITLE_FONT = Enum.Font.SourceSansSemibold
local DEFAULT_TITLE_FONT_SIZE = 23

local DEFAULT_ZINDEX = 2

local FFlagLuaAppSiteMessageBannerEnabled = settings():GetFFlag("LuaAppSiteMessageBannerEnabled")
local FFlagEnablePopupDataModelFocusedEvents = settings():GetFFlag("EnablePopupDataModelFocusedEvents")

-- TODO: remove with UseNewAppStyle
local function TouchFriendlyImageIcon(props)
	local image = props.Image
	local anchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	local position = props.Position or UDim2.new(0, 0, 0, 0)
	local layoutOrder = props.LayoutOrder
	local onActivated = props.onActivated
	local hasNotificationBadge = props.hasNotificationBadge
	local notificationCount = props.notificationCount

	local iconImageAnchorPoint = props.iconImageAnchorPoint or Vector2.new(0.5, 0.5)
	local iconImagePosition = props.iconImagePosition or UDim2.new(0.5, 0, 0.5, 0)
	local iconImageSize = props.iconImageSize
	local iconButtonSize = props.iconButtonSize

	local notificationBadge = nil
	if hasNotificationBadge then
		notificationBadge = IsLuaBottomBarEnabled and Roact.createElement(NumericalBadge, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, NUMERICAL_BADGE_OFFSET, 1, -NUMERICAL_BADGE_OFFSET),
			badgeCount = notificationCount and tonumber(notificationCount),
			inAppChrome = true,
		}) or Roact.createElement(NotificationBadge, {
			notificationCount = notificationCount,
		})
	end

	return Roact.createElement(ImageSetButton, {
		AnchorPoint = anchorPoint,
		Position = position,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, iconButtonSize, 1, 0),
		LayoutOrder = layoutOrder,
		[Roact.Event.Activated] = onActivated,
	}, {
		IconImage = Roact.createElement(ImageSetLabel, {
			AnchorPoint = iconImageAnchorPoint,
			Position = iconImagePosition,
			Size = UDim2.new(0, iconImageSize, 0, iconImageSize),
			Image = image,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			NotificationBadge = notificationBadge,
		}),
	})
end

local TopBar = Roact.PureComponent:extend("TopBar")

TopBar.defaultProps = {
	textColor = DEFAULT_TEXT_COLOR,
	titleFont = DEFAULT_TITLE_FONT,
	titleSize = DEFAULT_TITLE_FONT_SIZE,
	showBackButton = false,
	backButtonImage = BACK_BUTTON_IMAGE,
	showBuyRobux = false,
	showNotifications = false,
	showSearch = false,
	enableSearch = false,
	enableSiteMessageBanner = false,
	ZIndex = DEFAULT_ZINDEX,
}

function TopBar:updateTopBarHeight()
	if self.props.setTopBarHeight then
		local statusBarHeight = self.props.statusBarHeight
		local newTopBarHeight = statusBarHeight + NAV_BAR_SIZE + self.state.siteMessageBannerHeight
		self.props.setTopBarHeight(newTopBarHeight)
	end
end

function TopBar:init()
	self.isMounted = false

	self.state = {
		isSearching = false,
		siteMessageBannerHeight = 0,
	}

	self.onSearchButtonActivated = function()
		self:setState({
			isSearching = true,
		})
	end

	self.onExitSearch = function()
		self:setState({
			isSearching = false,
		})
	end

	self.cancelSearchCallback = function()
		self.props.analytics.reportSearchCanceled("games")
		self.onExitSearch()
	end

	self:updateTopBarHeight()

	self.siteMessageBannerSizeChangedCallback = function(rbx)
		local newBannerHeight = math.max(rbx.AbsoluteSize.Y, 0)
		if self.state.siteMessageBannerHeight ~= newBannerHeight then
			-- spawn to ensure we don't execute during reconciliation
			spawn(function()
				-- ensure we're mounted so we don't execute on dead data
				if not self.isMounted then
					return
				end

				self:setState({
					siteMessageBannerHeight = newBannerHeight
				})

				self:updateTopBarHeight()
			end)
		end
	end

	self.showBuyRobuxCallback = function()
		local currentRoute = self.props.currentRoute
		local currentPage = currentRoute[1].name

		if FFlagEnablePopupDataModelFocusedEvents then
			self.props.openPurchaseRobuxPage()
		else
			self.props.guiService:BroadcastNotification("", NotificationType.PURCHASE_ROBUX)
		end

		self.props.analytics.reportRobuxButtonClick(currentPage)
	end

	self.showNotificationsCallback = function()
		if FFlagEnablePopupDataModelFocusedEvents then
			self.props.openNotificationsPage()
		else
			self.props.guiService:BroadcastNotification("", NotificationType.VIEW_NOTIFICATIONS)
		end

		self.props.analytics.reportNSButtonTouch(tonumber(self.props.numberOfNotifications))
	end

	self.onSearchBarFocused = function()
		self.props.analytics.reportSearchFocused("games")
		if self.props.formFactor == FormFactor.WIDE then
			self:setState({
				isSearching = true,
			})
		end
	end

	self.confirmSearchCallback = function(keyword)
		local searchUuid = SearchUuid()

		self.props.setSearchParameters(searchUuid, keyword, true)
		self.props.analytics.reportSearched("games", keyword)
		self.onExitSearch()
		self.props.navigateToSearch(self.props.currentRoute, searchUuid)
	end

end

function TopBar:didMount()
	self.isMounted = true
end

function TopBar:willUnmount()
	self.isMounted = false
end

function TopBar:renderClassic()
	local formFactor = self.props.formFactor
	local currentRoute = self.props.currentRoute
	local platform = self.props.platform

	local textColor = self.props.textColor
	local textTitleFont = self.props.titleFont
	local textTitleFontSize = self.props.titleSize
	local titleText = self.props.titleText

	local showBackButton = self.props.showBackButton
	local backButtonImage = self.props.backButtonImage
	local showBuyRobux = self.props.showBuyRobux
	local showNotifications = self.props.showNotifications and self.props.enableNotifications
	local showSearch = self.props.showSearch and self.props.enableSearch
	local showSiteMessageBanner = FFlagLuaAppSiteMessageBannerEnabled and self.props.enableSiteMessageBanner

	local numberOfNotifications = self.props.numberOfNotifications

	local zIndex = self.props.ZIndex

	local navigateUp = self.props.navigateUp
	local navigateBack = self.props.navigateBack

	local statusBarHeight = self.props.statusBarHeight

	local topNavBarHeight = statusBarHeight + NAV_BAR_SIZE

	local currentPageName = currentRoute[#currentRoute].name
	local rootPageName = currentRoute[1].name

	local currentTopBarIconSpec = DeviceSpecificTopBarIconSpec[formFactor]

	local iconMarginRight = currentTopBarIconSpec and currentTopBarIconSpec.MarginRight or 0
	local iconPadding = currentTopBarIconSpec and currentTopBarIconSpec.Padding or 0
	local iconButtonSize = currentTopBarIconSpec and currentTopBarIconSpec.IconButtonSize or ICON_BUTTON_SIZE
	local backImageOffset = currentTopBarIconSpec and currentTopBarIconSpec.BackImageOffset or 0

	local isCompactView = formFactor == FormFactor.COMPACT

	local navBarLayout = {}

	if isCompactView and self.state.isSearching then
		navBarLayout["SearchBar"] = Roact.createElement(SearchBar, {
			cancelSearch = self.cancelSearchCallback,
			confirmSearch = self.confirmSearchCallback,
			onFocused = self.onSearchBarFocused,
			isPhone = isCompactView,
			placeholderText = "Search.GlobalSearch.Example.SearchGames",
		})
	else
		if showBackButton then
			navBarLayout["BackButton"] = Roact.createElement(TouchFriendlyImageIcon, {
				iconImageAnchorPoint = Vector2.new(0, 0.5),
				iconImagePosition = UDim2.new(0, backImageOffset, 0.5, 0),
				iconImageSize = ICON_IMAGE_SIZE,
				iconButtonSize = BACK_BUTTON_SIZE,
				Image = FFlagLuaAppTopBarCustomBackButton and backButtonImage or BACK_BUTTON_IMAGE,
				onActivated = (platform == Enum.Platform.IOS) and navigateBack or navigateUp,
			})
		end

		navBarLayout["Title"] = Roact.createElement(titleText and "TextLabel" or LocalizedTextLabel, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Font = textTitleFont,
			Text = titleText or { AppPageLocalizationKeys[currentPageName] or AppPageLocalizationKeys[rootPageName] },
			TextColor3 = textColor,
			TextSize = textTitleFontSize,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
		})

		local rightIcons = {}
		rightIcons["Layout"] = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, iconPadding),
		})

		if showSearch then
			rightIcons["Search"] = isCompactView and Roact.createElement(TouchFriendlyImageIcon, {
				iconImageSize = ICON_IMAGE_SIZE,
				iconButtonSize = iconButtonSize,
				Image = SEARCH_ICON_IMAGE,
				LayoutOrder = 3,
				onActivated = self.onSearchButtonActivated,
			}) or Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, SEARCH_BAR_SIZE + SEARCH_BAR_PADDING, 1, 0),
				LayoutOrder = 3,
			}, {
				SearchBar = Roact.createElement(SearchBar, {
					Size = UDim2.new(0, SEARCH_BAR_SIZE, 1, 0),
					cancelSearch = self.cancelSearchCallback,
					confirmSearch = self.confirmSearchCallback,
					onFocused = self.onSearchBarFocused,
					placeholderText = "Search.GlobalSearch.Example.SearchGames",
					isPhone = isCompactView,
				})
			})
		end

		if showBuyRobux then
			rightIcons["Robux"] = Roact.createElement(TouchFriendlyImageIcon, {
				iconImageSize = ICON_IMAGE_SIZE,
				iconButtonSize = iconButtonSize,
				Image = ROBUX_ICON_IMAGE,
				LayoutOrder = 4,
				onActivated = self.state.isSearching and self.cancelSearchCallback or self.showBuyRobuxCallback,
			})
		end

		if showNotifications then
			rightIcons["Notifications"] = Roact.createElement(TouchFriendlyImageIcon, {
				iconImageSize = ICON_IMAGE_SIZE,
				iconButtonSize = iconButtonSize,
				Image = NOTIFICATION_ICON_IMAGE,
				LayoutOrder = 5,
				onActivated = self.state.isSearching and self.cancelSearchCallback or self.showNotificationsCallback,
				hasNotificationBadge = true,
				notificationCount = numberOfNotifications,
			})
		end

		navBarLayout["RightIcons"] = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -iconMarginRight, 0.5, 0),
			Size = UDim2.new(1, -iconMarginRight, 1, 0),
		}, rightIcons)
	end

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = zIndex,
	}, {
		TopBar = Roact.createElement("Frame", {
			BackgroundColor3 = TOP_SYSTEM_BACKGROUND_COLOR,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, topNavBarHeight),
			ZIndex = 2,
		}, {
			NavBar = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = TOP_BAR_COLOR,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, NAV_BAR_SIZE),
			}, navBarLayout),
		}),
		SiteMessageBanner = showSiteMessageBanner and Roact.createElement(SiteMessageBanner, {
			Position = UDim2.new(0, 0, 0, topNavBarHeight),
			Size = UDim2.new(1, 0, 0, 0),
			[Roact.Change.AbsoluteSize] = self.siteMessageBannerSizeChangedCallback
		}),
		DarkOverlay = Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			AutoButtonColor = false,
			BackgroundColor3 = Constants.Color.GRAY1,
			BackgroundTransparency = 0.5,
			Text = "",
			Visible = self.state.isSearching,
			[Roact.Event.Activated] = self.cancelSearchCallback,
			ZIndex = 1,
		}),
	})
end

function TopBar:renderWithStyle()
	local formFactor = self.props.formFactor
	local currentRoute = self.props.currentRoute
	local platform = self.props.platform

	local titleText = self.props.titleText

	local showBackButton = self.props.showBackButton
	local backButtonImage = self.props.backButtonImage
	local showBuyRobux = self.props.showBuyRobux
	local showNotifications = self.props.showNotifications and self.props.enableNotifications
	local showSearch = self.props.showSearch and self.props.enableSearch
	local showSiteMessageBanner = FFlagLuaAppSiteMessageBannerEnabled and self.props.enableSiteMessageBanner

	local numberOfNotifications = self.props.numberOfNotifications

	local zIndex = self.props.ZIndex

	local navigateUp = self.props.navigateUp
	local navigateBack = self.props.navigateBack

	local statusBarHeight = self.props.statusBarHeight

	local topNavBarHeight = statusBarHeight + NAV_BAR_SIZE

	local currentPageName = currentRoute[#currentRoute].name
	local rootPageName = currentRoute[1].name

	local currentTopBarIconSpec = DeviceSpecificTopBarIconSpec[formFactor]

	local iconMarginRight = currentTopBarIconSpec and currentTopBarIconSpec.MarginRight or 0
	local iconPadding = currentTopBarIconSpec and currentTopBarIconSpec.Padding or 0
	local iconButtonSize = currentTopBarIconSpec and currentTopBarIconSpec.IconButtonSize or ICON_BUTTON_SIZE
	local backImageOffset = currentTopBarIconSpec and currentTopBarIconSpec.BackImageOffset or 0

	local isCompactView = formFactor == FormFactor.COMPACT

	local navBarLayout = {}

	return withStyle(function(style)
		if isCompactView and self.state.isSearching then
			navBarLayout["SearchBar"] = Roact.createElement(SearchBar, {
				cancelSearch = self.cancelSearchCallback,
				confirmSearch = self.confirmSearchCallback,
				onFocused = self.onSearchBarFocused,
				isPhone = isCompactView,
				placeholderText = "Search.GlobalSearch.Example.SearchGames",
			})
		else
			if showBackButton then
				navBarLayout["BackButton"] = Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, BACK_BUTTON_SIZE, 1, 0),
					icon = FFlagLuaAppTopBarCustomBackButton and backButtonImage or BACK_BUTTON_IMAGE,
					iconSize = ICON_IMAGE_SIZE,
					iconPosition = UDim2.new(0, backImageOffset, 0.5, 0),
					iconAnchorPoint = Vector2.new(0, 0.5),
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					onActivated = (platform == Enum.Platform.IOS) and navigateBack or navigateUp,
				})
			end

			navBarLayout["Title"] = Roact.createElement(titleText and "TextLabel" or LocalizedTextLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Font = style.Font.Header1.Font,
				TextSize = style.Font.BaseSize * style.Font.Header1.RelativeSize,
				Text = titleText or { AppPageLocalizationKeys[currentPageName] or AppPageLocalizationKeys[rootPageName] },
				TextColor3 = style.Theme.TextEmphasis.Color,
				TextTransparency = style.Theme.TextEmphasis.Transparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})

			local rightIcons = {}
			rightIcons["Layout"] = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, iconPadding),
			})

			if showSearch then
				rightIcons["Search"] = isCompactView and Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = 3,
					icon = SEARCH_ICON_IMAGE,
					iconSize = ICON_IMAGE_SIZE,
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					onActivated = self.onSearchButtonActivated,
				}) or Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, SEARCH_BAR_SIZE + SEARCH_BAR_PADDING, 1, 0),
					LayoutOrder = 3,
				}, {
					SearchBar = Roact.createElement(SearchBar, {
						Size = UDim2.new(0, SEARCH_BAR_SIZE, 1, 0),
						cancelSearch = self.cancelSearchCallback,
						confirmSearch = self.confirmSearchCallback,
						onFocused = self.onSearchBarFocused,
						placeholderText = "Search.GlobalSearch.Example.SearchGames",
						isPhone = isCompactView,
					})
				})
			end

			if showBuyRobux then
				rightIcons["Robux"] = Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = 4,
					icon = ROBUX_ICON_IMAGE,
					iconSize = ICON_IMAGE_SIZE,
					--NOTE: When Robux icon is updated to the new one it will not need to be colored in Lua
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					--
					onActivated = self.state.isSearching and self.cancelSearchCallback or self.showBuyRobuxCallback,
				})
			end

			if showNotifications then
				rightIcons["Notifications"] = Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = 5,
					icon = NOTIFICATION_ICON_IMAGE,
					iconSize = ICON_IMAGE_SIZE,
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					onActivated = self.state.isSearching and self.cancelSearchCallback or self.showNotificationsCallback,
				}, {
					-- Retheme forces use of new NumericalBadge
					NotificationBadge = Roact.createElement(NumericalBadge, {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, 0, 0, 0),
						badgeCount = numberOfNotifications and tonumber(numberOfNotifications),
					})
				})
			end

			navBarLayout["RightIcons"] = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -iconMarginRight, 0.5, 0),
				Size = UDim2.new(1, -iconMarginRight, 1, 0),
			}, rightIcons)
		end

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = zIndex,
		}, {
			TopBar = Roact.createElement("Frame", {
				BackgroundColor3 = style.Theme.BackgroundDefault.Color,
				BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, topNavBarHeight),
				ZIndex = 2,
			}, {
				NavBar = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = style.Theme.BackgroundDefault.Color,
					BackgroundTransparency = style.Theme.BackgroundDefault.Transparency,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.new(1, 0, 0, NAV_BAR_SIZE),
				}, navBarLayout),
			}),
			BottomBorder = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				Position = UDim2.new(0, 0, 0, topNavBarHeight),
				BackgroundColor3 = style.Theme.BackgroundMuted.Color,
				BackgroundTransparency = style.Theme.BackgroundMuted.Transparency,
				BorderSizePixel = 0,
				ZIndex = 3,
			}),
			SiteMessageBanner = showSiteMessageBanner and Roact.createElement(SiteMessageBanner, {
				Position = UDim2.new(0, 0, 0, topNavBarHeight),
				Size = UDim2.new(1, 0, 0, 0),
				[Roact.Change.AbsoluteSize] = self.siteMessageBannerSizeChangedCallback
			}),
			DarkOverlay = Roact.createElement("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				AutoButtonColor = false,
				BackgroundColor3 = style.Theme.Overlay.Color,
				BackgroundTransparency = style.Theme.Overlay.Transparency,
				Text = "",
				Visible = self.state.isSearching,
				[Roact.Event.Activated] = self.cancelSearchCallback,
				ZIndex = 1,
			}),
		})
	end)
end

function TopBar:render()
	if UseNewAppStyle then
		return self:renderWithStyle()
	else
		return self:renderClassic()
	end
end

function TopBar:didUpdate(prevProps)
	self:updateTopBarHeight()
end

TopBar = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]

		return {
			formFactor = state.FormFactor,
			numberOfNotifications = state.NotificationBadgeCounts.TopBarNotificationIcon,
			currentRoute = currentRoute,
			-- Show back button only if we're not on a root page, i.e. current route longer than 1.
			showBackButton = #currentRoute > 1,
			platform = state.Platform,
			statusBarHeight = state.TopBar.statusBarHeight,
		}
	end,
	function(dispatch)
		return {
			setTopBarHeight = function(newTopBarHeight)
				return dispatch(SetTopBarHeight(newTopBarHeight))
			end,
			setSearchParameters = function(searchUuid, searchKeyword, isKeywordSuggestionEnabled)
				return dispatch(SetSearchParameters(searchUuid, {
					searchKeyword = searchKeyword,
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				}))
			end,
			navigateUp = function()
				return dispatch(NavigateUp())
			end,
			navigateBack = function()
				return dispatch(NavigateBack())
			end,
			navigateToSearch = function(currentRoute, searchUuid)
				local isOnRootPage = (#currentRoute == 1)

				if isOnRootPage then
					dispatch(NavigateDown({ name = AppPage.SearchPage, detail = searchUuid }))
				else
					dispatch(NavigateSideways({ name = AppPage.SearchPage, detail = searchUuid }))
				end
			end,
			openPurchaseRobuxPage = function()
				return dispatch(NavigateDown({
					name = AppPage.PurchaseRobux,
				}))
			end,
			openNotificationsPage = function()
				return dispatch(NavigateDown({
					name = AppPage.Notifications,
				}))
			end,
		}
	end
)(TopBar)

TopBar = RoactServices.connect({
	analytics = RoactAnalyticsTopBar,
	guiService = AppGuiService,
	networking = RoactNetworking,
})(TopBar)

if FFlagLuaAppPolicyRoactConnector then
	TopBar = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			enableNotifications = appPolicy.getNotifications(),
			enableSearch = appPolicy.getSearchBar(),
			enableSiteMessageBanner = appPolicy.getSiteMessageBanner(),
		}
	end)(TopBar)
else
		TopBar = RoactAppPolicy.legacy_connect(function(appPolicy, props)
			return {
				enableNotifications = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.Notifications),
				enableSearch = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.SearchBar),
				enableSiteMessageBanner = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.SiteMessageBanner),
			}
		end)(TopBar)
end

return TopBar
