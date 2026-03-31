local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local memoize = require(Modules.Common.memoize)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local Cryo = require(CorePackages.Cryo)

local Constants = require(Modules.LuaApp.Constants)
local RoactMotion = require(Modules.LuaApp.RoactMotion)
local LaunchErrorLocalizationKeys = require(Modules.LuaApp.LaunchErrorLocalizationKeys)
local NotificationType = require(Modules.LuaApp.Enum.NotificationType)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local AppPage = require(Modules.LuaApp.AppPage)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local NavigateSideways = require(Modules.LuaApp.Thunks.NavigateSideways)
local OpenCentralOverlayForPlacesList = require(Modules.LuaApp.Thunks.OpenCentralOverlayForPlacesList)

local UIScaler = require(Modules.LuaApp.Components.UIScaler)
local GameBasicStats = require(Modules.LuaApp.Components.Games.GameBasicStats)
local QuickLaunchAnimation = require(Modules.LuaApp.Components.Games.QuickLaunchAnimation)
local GameThumbnail = require(Modules.LuaApp.Components.GameThumbnail)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local FriendFooter = require(Modules.LuaApp.Components.FriendFooter)

local ApiFetchPlayabilityStatus = require(Modules.LuaApp.Thunks.ApiFetchPlayabilityStatus)
local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)

local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local Requests = Modules.LuaApp.Http.Requests
local SponsoredGamesRecordClick = require(Requests.SponsoredGamesRecordClick)
local RoactServices = require(Modules.LuaApp.RoactServices)

local FlagSettings = require(Modules.LuaApp.FlagSettings)

local isLuaGameDetailsPageEnabled = FlagSettings.IsLuaGameDetailsPageEnabled()
local FFlagEnableQuickGameLaunch = settings():GetFFlag("EnableQuickGameLaunch")

-- Define static positions on the card:
local DEFAULT_ICON_SCALE = 1
local PRESSED_ICON_SCALE = 0.9
local BUTTON_DOWN_STIFFNESS = 1000
local BUTTON_DOWN_DAMPING = 50
local BUTTON_DOWN_SPRING_PRECISION = 0.5

local SPONSOR_TEXT_SIZE = 14

local LARGE_GAME_CARD_WIDTH = 148
local MEDIUM_GAME_CARD_WIDTH = 100

local SPONSOR_COLOR = Constants.Color.GRAY3
local SPONSOR_TEXT_COLOR = Constants.Color.WHITE

local LONG_PRESS_TIMER = 0.125

local DEFAULT_GAME_ICON = Constants.DEFAULT_GAME_ICON

local GameCardFooterLayout = {
	[Constants.GameCardLayoutType.Small] = {
		OuterMargin = 3,
		InnerMargin = 3,
		TitleTextSize = 16,
	},
	[Constants.GameCardLayoutType.Medium] = {
		OuterMargin = 6,
		InnerMargin = 3,
		TitleTextSize = 16,
	},
	[Constants.GameCardLayoutType.Large] = {
		OuterMargin = 6,
		InnerMargin = 3,
		TitleTextSize = 18,
	},
}

local ZIndex = {
	GameCard = 2,
	Sponsor = 3,
	QuickLaunch = 4,
}

local QUICK_LAUNCH_STATE = {
	HIDDEN = "Hidden",
	SHORT_PRESS = "ShortPress",
	PLAY_ANIMATION = "PlayAnimation",
	REWIND_ANIMATION_BUTTON_UP = "RewindAnimationButtonUp",
	REWIND_ANIMATION_BUTTON_DOWN = "RewindAnimationButtonDown",
	HIDDEN_BUTTON_DOWN = "HiddenButtonDown",
}

-- A global boolean to track if there's any pressed game card, for button debouncing purpose
local hasPressedGameCard = false

local GameCard = Roact.PureComponent:extend("GameCard")

GameCard.defaultProps = {
	friendFooterEnabled = false,
}

function GameCard:isQuickLaunchVisible()
	return self.state.quickLaunchState == QUICK_LAUNCH_STATE.PLAY_ANIMATION or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_UP
end

function GameCard:isAnimationRewind()
	return self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_UP
end

function GameCard:isGameCardPressed()
	return self.state.quickLaunchState == QUICK_LAUNCH_STATE.SHORT_PRESS or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.PLAY_ANIMATION or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN or
		self.state.quickLaunchState == QUICK_LAUNCH_STATE.HIDDEN_BUTTON_DOWN
end

function GameCard:eventDisconnect()
	if self.onAbsolutePositionChanged then
		self.onAbsolutePositionChanged:Disconnect()
		self.onAbsolutePositionChanged = nil
	end
end

function GameCard:setQuickLaunchState(quickLaunchState, quickLaunchTriggerTime)
	self:setState({
		quickLaunchState = quickLaunchState,
		quickLaunchTriggerTime = FFlagEnableQuickGameLaunch and quickLaunchTriggerTime or 0,
	})
end

function GameCard:Action_onButtonUp()
	self:eventDisconnect()
	hasPressedGameCard = false
end

function GameCard:Action_onButtonDown()
	hasPressedGameCard = true

	self:eventDisconnect()
	self.onAbsolutePositionChanged = self.gameCardRef.current and
		self.gameCardRef.current:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self.Event_buttonUp()
	end)

	if FFlagEnableQuickGameLaunch and self.props.playabilityFetchingStatus == RetrievalStatus.NotStarted then
		self.props.fetchPlayabilityStatus(self.props.networking, { self.props.game.universeId })
	end
end

function GameCard:Action_openGameDetails()
	local navDetail
	if isLuaGameDetailsPageEnabled then
		navDetail = self.props.game.universeId
	else
		navDetail = self.props.game.placeId
	end

	local useSidewaysNavigation = self.props.useSidewaysNavigation
	if useSidewaysNavigation then
		self.props.navigateSideways({ name = AppPage.GameDetail, detail = navDetail })
	else
		self.props.navigateDown({ name = AppPage.GameDetail, detail = navDetail })
	end

	-- fire some analytics
	local index = self.props.index
	local reportGameDetailOpened = self.props.reportGameDetailOpened
	reportGameDetailOpened(index)

	-- Record sponsored game click
	local networking = self.props.networking
	local entry = self.props.entry
	local isSponsored = entry.isSponsored
	if isSponsored then
		SponsoredGamesRecordClick(networking, entry.adId)
	end
end

function GameCard:Action_launchGame()
	local notificationType = NotificationType.LAUNCH_GAME
	local gameParams = {
		placeId = self.props.game.placeId
	}
	local payload = HttpService:JSONEncode(gameParams)
	self.props.guiService:BroadcastNotification(payload, notificationType)

	-- fire analytics event
	local reportQuickGameLaunch = self.props.reportQuickGameLaunch
	if reportQuickGameLaunch then
		reportQuickGameLaunch.success()
	end
end

function GameCard:Action_launchError(message)
	-- Right now we still need placeId to open native game details page
	-- Should remove placeId later when we support lua game details page
	local toastMessage = {
		toastType = ToastType.QuickLaunchError,
		toastMessage = LaunchErrorLocalizationKeys[message],
		toastSubMessage = "Feature.GamePage.QuickLaunch.ViewDetails",
		universeId = self.props.game.universeId,
		placeId = self.props.game.placeId,
	}
	self.props.setCurrentToastMessage(toastMessage)

	-- fire analytics event
	local reportQuickGameLaunch = self.props.reportQuickGameLaunch
	if reportQuickGameLaunch then
		reportQuickGameLaunch.failure(message)
	end
end

function GameCard:init()
	self.gameCardRef = Roact.createRef()
	self.friendFooterRef = Roact.createRef()

	self.state = {
		quickLaunchState = QUICK_LAUNCH_STATE.HIDDEN,
		quickLaunchTriggerTime = 0,
	}

	self.Event_buttonDown = function()
		if not hasPressedGameCard and not self:isGameCardPressed() then
			self:Action_onButtonDown()
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.SHORT_PRESS, tick() + LONG_PRESS_TIMER)
		end
	end

	self.Event_buttonUp = function()
		local quickLaunchState = self.state.quickLaunchState
		if quickLaunchState == QUICK_LAUNCH_STATE.SHORT_PRESS or
			quickLaunchState == QUICK_LAUNCH_STATE.HIDDEN_BUTTON_DOWN then
			self:Action_onButtonUp()
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN)
		elseif quickLaunchState == QUICK_LAUNCH_STATE.PLAY_ANIMATION or
			quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN then
			self:Action_onButtonUp()
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_UP)
		end
	end

	self.Event_buttonShortPressed = function(inputObject)
		local game = self.props.game
		local size = self.props.size
		local openContextualMenu = self.props.openContextualMenu

		local isFriendFooterPressed = false
		if self.friendFooterRef.current then
			local inputPosition = inputObject.Position
			local footerSize = self.friendFooterRef.current.AbsoluteSize
			local footerPosition = self.friendFooterRef.current.AbsolutePosition

			isFriendFooterPressed = inputPosition.X >= footerPosition.X and inputPosition.X <= (footerPosition.X + footerSize.X)
						and inputPosition.Y >= footerPosition.Y and inputPosition.Y <= (footerPosition.Y + footerSize.Y)
		end
		if self:isGameCardPressed() then
			self:Action_onButtonUp()
			if isFriendFooterPressed then
				openContextualMenu(game, size, self.getCardPosition())
			else
				self:Action_openGameDetails()
			end
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN)
		end
	end

	self.Event_animationDone = function()
		local fetchingFailed = self.props.playabilityFetchingStatus == RetrievalStatus.Failed
		local playabilityStatus = self.props.playabilityStatus

		-- If fetching succeed, we'll use whatever returned in playabilityStatus
		-- If fetching failed, game is not playable, launchMessage will be RetrievalStatus.Failed
		-- Otherwise, We should launch game directly when there's no fetched result yet

		-- Don't use isPlayable = playabilityStatus and playabilityStatus.isPlayable or X because
		-- playabilityStatus.isPlayable might be false and it will fall back to X, which we don't want
		local isPlayable = not fetchingFailed
		local launchMessage = fetchingFailed and RetrievalStatus.Failed
		if playabilityStatus then
			isPlayable = playabilityStatus.isPlayable
			launchMessage = playabilityStatus.playabilityStatus
		end

		if isPlayable then
			self:Action_launchGame()
			self:Action_onButtonUp()
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN)
		else
			self:Action_launchError(launchMessage)
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN)
		end
	end

	self.Event_rewindDone = function()
		if self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_UP then
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN)
		elseif self.state.quickLaunchState == QUICK_LAUNCH_STATE.REWIND_ANIMATION_BUTTON_DOWN then
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN_BUTTON_DOWN)
		end
	end

	self.Event_routeChanged = function()
		if self.state.quickLaunchState ~= QUICK_LAUNCH_STATE.HIDDEN then
			self:Action_onButtonUp()
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.HIDDEN)
		end
	end

	self.onButtonInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			self.Event_buttonDown()
		end
	end

	self.onButtonInputEnded = function(_, inputObject)
		if self.state.quickLaunchState == QUICK_LAUNCH_STATE.SHORT_PRESS and
			inputObject.UserInputState == Enum.UserInputState.End and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			self.Event_buttonShortPressed(inputObject)
		else
			self.Event_buttonUp()
		end
	end

	self.renderSteppedCallback = function(dt)
		local quickLaunchTriggerTime = self.state.quickLaunchTriggerTime
		if quickLaunchTriggerTime > 0 and tick() >= quickLaunchTriggerTime then
			self:setQuickLaunchState(QUICK_LAUNCH_STATE.PLAY_ANIMATION)

			-- fire analytics event
			local reportQuickGameLaunch = self.props.reportQuickGameLaunch
			if reportQuickGameLaunch then
				reportQuickGameLaunch.entry()
			end
		end
	end

	self.getCardPosition = function()
		if self.gameCardRef.current then
			return self.gameCardRef.current.AbsolutePosition
		else
			return Vector2.new(0, 0)
		end
	end

	self.getLayoutType = function(width)
		if width >= LARGE_GAME_CARD_WIDTH then
			return Constants.GameCardLayoutType.Large
		elseif width >= MEDIUM_GAME_CARD_WIDTH then
			return Constants.GameCardLayoutType.Medium
		else
			return Constants.GameCardLayoutType.Small
		end
	end

	self.getLayoutInfo = function(layoutType, isOneRowTitle)
		local size = self.props.size
		local layoutInfo = Cryo.Dictionary.join(GameCardFooterLayout[layoutType])
		layoutInfo.TitleHeight = isOneRowTitle and layoutInfo.TitleTextSize or layoutInfo.TitleTextSize * 2
		layoutInfo.FooterHeight = size.Y - size.X
		layoutInfo.FriendFooterHeight = layoutInfo.FooterHeight - layoutInfo.OuterMargin * 2 - layoutInfo.TitleHeight
		layoutInfo.FooterContentWidth = size.X - layoutInfo.OuterMargin * 2
		return layoutInfo
	end
end

function GameCard:render()
	local theme = self._context.AppTheme
	local size = self.props.size
	local layoutOrder = self.props.layoutOrder

	local entry = self.props.entry
	local game = self.props.game
	local friendFooterEnabled = self.props.friendFooterEnabled
	local hasInGameFriends = self.props.hasInGameFriends

	local name = game.name
	local universeId = game.universeId
	local totalDownVotes = game.totalDownVotes
	local totalUpVotes = game.totalUpVotes

	local playerCount = entry.playerCount
	local isSponsored = entry.isSponsored

	local displayFriendFooter = friendFooterEnabled and hasInGameFriends

	local displayGameInfoInFooter = not isSponsored and not displayFriendFooter
	local displaySponsoredFooter = isSponsored and not displayFriendFooter

	local layoutType = self.getLayoutType(size.X)
	local layoutInfo = self.getLayoutInfo(layoutType, isSponsored or displayFriendFooter)

	local quickLaunchVisible = self:isQuickLaunchVisible()
	local rewindAnimation = self:isAnimationRewind()
	local isGameCardPressed = self:isGameCardPressed()

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, size.X, 0, size.Y),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,

		[Roact.Ref] = self.gameCardRef,
	}, {
		GameButton = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			ZIndex = ZIndex.GameCard,

			[Roact.Event.InputBegan] = self.onButtonInputBegan,
			[Roact.Event.InputEnded] = self.onButtonInputEnded,
		}, {
			UIScaler = Roact.createElement(UIScaler, {
				scaleValue = RoactMotion.spring(isGameCardPressed and PRESSED_ICON_SCALE or DEFAULT_ICON_SCALE,
					BUTTON_DOWN_STIFFNESS, BUTTON_DOWN_DAMPING, BUTTON_DOWN_SPRING_PRECISION),
			}),
			Icon = Roact.createElement(GameThumbnail, {
				Size = UDim2.new(0, size.X, 0, size.X),
				universeId = universeId,
				BorderSizePixel = 0,
				BackgroundColor3 = Constants.Color.GRAY5,
				loadingImage = DEFAULT_GAME_ICON,
				ZIndex = ZIndex.GameCard,
			}),
			GameInfoFooter = (not displayFriendFooter) and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, layoutInfo.FooterHeight),
				Position = UDim2.new(0, 0, 0, size.X),
				BackgroundTransparency = theme.GameCard.Background.Transparency,
				BorderSizePixel = 0,
				BackgroundColor3 = theme.GameCard.Background.Color,
				ZIndex = ZIndex.GameCard,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, layoutInfo.InnerMargin),
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, layoutInfo.OuterMargin),
					PaddingRight = UDim.new(0, layoutInfo.OuterMargin),
					PaddingTop = UDim.new(0, layoutInfo.OuterMargin),
				}),
				Title = Roact.createElement("TextLabel", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, layoutInfo.TitleHeight),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextSize = layoutInfo.TitleTextSize,
					TextColor3 = theme.GameCard.Title.Color,
					Font = theme.GameCard.Title.Font,
					Text = name,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top, -- Center sinks the text down by 2 pixels
					TextWrapped = true,
				}),
				Info = displayGameInfoInFooter and Roact.createElement(GameBasicStats, {
					LayoutOrder = 2,
					playerCount = playerCount,
					upVotes = totalUpVotes,
					downVotes = totalDownVotes,
					themeInfo = theme.GameCard.GameBasicStats,
					layoutType = Constants.GameBasicStatsLayoutType[layoutType],
				}),
			}),
			FriendFooter = displayFriendFooter and Roact.createElement("Frame", {
				Size = UDim2.new(0, size.X, 0, layoutInfo.FooterHeight),
				Position = UDim2.new(0, 0, 0, size.X),
				BackgroundTransparency = theme.GameCard.Background.Transparency,
				BackgroundColor3 = theme.GameCard.Background.Color,
				BorderSizePixel = 0,
				ZIndex = ZIndex.GameCard,
				[Roact.Ref] = self.friendFooterRef,
			}, {
				FriendFooter = Roact.createElement(FriendFooter, {
					universeId = universeId,
					innerMargin = layoutInfo.InnerMargin,
					outerMargin = layoutInfo.OuterMargin,
					titleTextSize = layoutInfo.TitleTextSize,
					footerContentWidth = layoutInfo.FooterContentWidth,
					footerContentHeight = layoutInfo.FriendFooterHeight,
				}),
			}),
			Sponsor = displaySponsoredFooter and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, SPONSOR_TEXT_SIZE + layoutInfo.OuterMargin * 2),
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = SPONSOR_COLOR,
				BorderSizePixel = 0,
				ZIndex = ZIndex.Sponsor,
			}, {
				SponsorText = Roact.createElement(LocalizedTextLabel, {
					Size = UDim2.new(1, -layoutInfo.OuterMargin * 2, 0, SPONSOR_TEXT_SIZE),
					Position = UDim2.new(0, layoutInfo.OuterMargin, 0, layoutInfo.OuterMargin),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextSize = SPONSOR_TEXT_SIZE,
					TextColor3 = SPONSOR_TEXT_COLOR,
					Font = Enum.Font.SourceSans,
					Text = "Feature.GamePage.Label.Sponsored",
				})
			}),
			QuickLaunchAnimation = quickLaunchVisible and Roact.createElement(QuickLaunchAnimation, {
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = ZIndex.QuickLaunch,
				gameCardHeight = size.Y,
				rewindAnimation = rewindAnimation,
				onAnimationDoneCallback = self.Event_animationDone,
				onRewindDoneCallback = self.Event_rewindDone,
			}),
		}),
		renderStepped = self.state.quickLaunchTriggerTime > 0 and Roact.createElement(ExternalEventConnection, {
			event = RunService.renderStepped,
			callback = self.renderSteppedCallback,
		}),
	})
end

function GameCard:didUpdate(oldProps, oldState)
	if oldProps.currentRoute ~= self.props.currentRoute then
		self.Event_routeChanged()
	end
end

function GameCard:willUnmount()
	self:Action_onButtonUp()
end

local getHasInGameFriends = memoize(function(localUserId, users, inGameUsers)
	if not localUserId or not users or not inGameUsers then
		return false
	end

	for _, userId in pairs(inGameUsers) do
		if userId ~= localUserId then
			local user = users[userId]
			if user and user.isFriend then
				return true
			end
		end
	end
	return false
end)

GameCard = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local universeId = props.entry.universeId

		return {
			game = state.Games[universeId],
			hasInGameFriends = getHasInGameFriends(
				state.LocalUserId,
				state.Users,
				state.InGameUsersByGame[universeId]
			),
			playabilityFetchingStatus = ApiFetchPlayabilityStatus.GetFetchingStatus(state, universeId),
			playabilityStatus = state.PlayabilityStatus[universeId],
			currentRoute = state.Navigation.history[#state.Navigation.history],
		}
	end,
	function(dispatch)
		return {
			fetchPlayabilityStatus = function(networking, universeIds)
				return dispatch(ApiFetchPlayabilityStatus.Fetch(networking, universeIds))
			end,
			setCurrentToastMessage = function(toastMessage)
				return dispatch(SetCurrentToastMessage(toastMessage))
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
			navigateSideways = function(page)
				dispatch(NavigateSideways(page))
			end,
			openContextualMenu = function(game, anchorSpaceSize, anchorSpacePosition)
				dispatch(OpenCentralOverlayForPlacesList(game, anchorSpaceSize, anchorSpacePosition))
			end,
		}
	end
)(GameCard)

return RoactServices.connect({
	guiService = AppGuiService,
	networking = RoactNetworking,
})(GameCard)
