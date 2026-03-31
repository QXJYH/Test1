local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local Constants = require(LuaApp.Constants)
local AvatarThumbnailTypes = require(CorePackages.AppTempCommon.LuaApp.Enum.AvatarThumbnailTypes)

local FitChildren = require(LuaApp.FitChildren)

local withLocalization = require(Modules.LuaApp.withLocalization)

local LocalizedSectionHeaderWithSeeAll = require(LuaApp.Components.LocalizedSectionHeaderWithSeeAll)
local AddFriendsButton = require(LuaApp.Components.Home.AddFriendsButton)

local CarouselWidget = require(Modules.LuaApp.Components.Generic.CarouselWidget)
local AddFriendsTile = require(Modules.LuaApp.Components.Home.AddFriendsTile)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local AppPage = require(Modules.LuaApp.AppPage)
local Url = require(LuaApp.Http.Url)

local UserCarouselEntry = require(LuaApp.Components.Home.UserCarouselEntry)

local UrlBuilder = require(LuaApp.Http.UrlBuilder)
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")

local CAROUSEL_PADDING_DIM = UDim.new(0, Constants.USER_CAROUSEL_PADDING)

local FRIEND_SECTION_MARGIN = 15 - UserCarouselEntry.horizontalPadding()

local FFlagLuaHomePageShowAddFriendsButton = settings():GetFFlag("LuaHomePageShowAddFriendsButtonV361")
local FFlagLuaAppMakeAvatarThumbnailTypesEnum = settings():GetFFlag("LuaAppMakeAvatarThumbnailTypesEnum")
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

local ADD_FRIENDS_BUTTON_WIDTH = Constants.PeopleList.ADD_FRIENDS_FRAME_WIDTH

local HEADER_HEIGHT = 20
local CARD_PADDING = 12
local FRIEND_THUMBNAIL_SIZE = 80
local FRIEND_CARD_SIZE = Vector2.new(FRIEND_THUMBNAIL_SIZE, 105)

local UserCarousel = Roact.PureComponent:extend("UserCarousel")

UserCarousel.defaultProps = {
	friendCount = 0,
}

function UserCarousel:init()
	self.state = {
		cardWindowStart = 1,
		cardsInWindow = 0,
		cardWidth = 0,
	}

	self.onSeeAllFriends = function()
		local navigateDown = self.props.navigateDown
		local url
		if FFlagLuaAppHttpsWebViews then
			url = UrlBuilder.static.friends()
		else
			url = string.format("%susers/friends", Url.BASE_URL)
		end
		navigateDown({
			name = AppPage.ViewProfile,
			detail = url,
		})
	end

	self.scrollingFrameRefCallback = function(rbx)
		self.scrollingFrameRef = rbx
	end

	if useNewAppStyle then
		self.updateCardWindowBounds = function()
			if not self.scrollingFrameRef then
				return
			end

			local screenSize = self.props.screenSize
			local userCardSizeX = FRIEND_THUMBNAIL_SIZE + CARD_PADDING

			local containerWidth = screenSize.X
			local windowOffset = self.scrollingFrameRef.CanvasPosition.X - userCardSizeX


			local cardWindowStart = math.max(1, math.floor(windowOffset / userCardSizeX))

			local cardsInWindow = math.ceil(containerWidth / userCardSizeX) + 1

			local shouldUpdate = cardWindowStart ~= self.state.cardWindowStart
				or cardsInWindow ~= self.state.cardsInWindow
				or userCardSizeX ~= self.state.cardWidth

			if shouldUpdate then
				self:setState({
					cardWindowStart = cardWindowStart,
					cardsInWindow = cardsInWindow,
					cardWidth = userCardSizeX
				})
			end
		end
	else
		self.updateCardWindowBounds = function()
			if not self.scrollingFrameRef then
				return
			end

			local formFactor = self.props.formFactor
			local screenSize = self.props.screenSize

			local containerWidth = screenSize.X - FRIEND_SECTION_MARGIN
			local windowOffset = self.scrollingFrameRef.CanvasPosition.X

			local userCardSizeX = UserCarouselEntry.getCardWidth(formFactor)

			local cardWindowStart
			if FFlagLuaHomePageShowAddFriendsButton then
				cardWindowStart = math.max(1, math.floor((windowOffset - ADD_FRIENDS_BUTTON_WIDTH) / userCardSizeX) + 1)
			else
				cardWindowStart = math.max(1, math.floor(windowOffset / userCardSizeX) + 1)
			end

			local cardsInWindow = math.ceil(containerWidth / userCardSizeX) + 1

			local shouldUpdate = cardWindowStart ~= self.state.cardWindowStart
				or cardsInWindow ~= self.state.cardsInWindow
				or userCardSizeX ~= self.state.cardWidth


			if shouldUpdate then
				self:setState({
					cardWindowStart = cardWindowStart,
					cardsInWindow = cardsInWindow,
					cardWidth = userCardSizeX
				})
			end
		end
	end
end

function UserCarousel:newRender()
	local layoutOrder = self.props.LayoutOrder
	local friendCount = self.props.friendCount
	local cardWidth = FRIEND_CARD_SIZE.X

	local friendCardSize = FRIEND_CARD_SIZE

	local friends = self.state.friends
	local cardsInWindow = self.state.cardsInWindow
	local cardWindowStart = self.state.cardWindowStart
	local cardWindowEnd = math.min(#friends, cardWindowStart + cardsInWindow - 1)
	local setPeopleListFrozen = self.props.setPeopleListFrozen

	local headerKey
	if friendCount == 0 then
		headerKey = "CommonUI.Features.Label.Friends"
	else
		headerKey = {
			"Feature.Home.HeadingFriends",
			friendCount = friendCount,
		}
	end

	local function createUserEntry(user, count)
		return Roact.createElement(UserCarouselEntry, {
			user = user,
			count = count,
			thumbnailSize = FRIEND_THUMBNAIL_SIZE,
			totalWidth = FRIEND_CARD_SIZE.X,
			totalHeight = FRIEND_CARD_SIZE.Y,
			formFactor = self.props.formFactor,
			setPeopleListFrozen = setPeopleListFrozen,
		})
	end

	local userTiles = {}
	local order = 1

	-- First Element is the AddFriendsButton
	if cardWindowStart == 1 then
		local addFriendTile = Roact.createElement(AddFriendsTile, {
			thumbnailSize = FRIEND_THUMBNAIL_SIZE,
			totalWidth = FRIEND_CARD_SIZE.X,
			totalHeight = FRIEND_CARD_SIZE.Y,
			layoutOrder = order,
		})
		userTiles["AddFriend"] = addFriendTile
		order = order + 1
	end

	for index = cardWindowStart, cardWindowEnd do
		userTiles[index] = createUserEntry(friends[index], order)
		order = order + 1
	end

	userTiles.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, CARD_PADDING),
	})

	--The padding adds an empty frame that will push the windowed elemets into view.
	local totalCardSize = cardWidth + CARD_PADDING
	local leftPadding = (cardWindowStart > 1) and cardWindowStart * totalCardSize or 0

	if leftPadding > 0 then
		userTiles.Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, leftPadding),
		})
	end

	local canvasWidth = (#friends + 1) * ( totalCardSize )

	local renderFunction = function(localized)
		return Roact.createElement("Frame", {
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, HEADER_HEIGHT + friendCardSize.Y),
		}, {
			UserCarousel = Roact.createElement(CarouselWidget, {
				title = localized.headerText,
				items = userTiles,
				onSeeAll = self.onSeeAllFriends,
				carouselHeight = friendCardSize.Y,
				canvasWidth = canvasWidth,
				onChangeCanvasPosition = self.updateCardWindowBounds,
				onRefCallback = self.scrollingFrameRefCallback,
			})
		})
	end

	return withLocalization({
		headerText = headerKey
	})(function(localized)
		return renderFunction(localized)
	end)
end

function UserCarousel:oldRender()
	local formFactor = self.props.formFactor
	local friendCount = self.props.friendCount
	local layoutOrder = self.props.LayoutOrder

	local friendSectionHeight = UserCarouselEntry.height(formFactor)
	local seeAllButtonVisible = friendCount > 0

	local content, headerText
	if friendCount == 0 then
		if not FFlagLuaHomePageShowAddFriendsButton then
			return nil
		end

		content = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, friendSectionHeight),
			BackgroundTransparency = 1,
		}, {
			layout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			addFriendsButton = Roact.createElement(AddFriendsButton, {
				hasNoFriend = true,
			}),
		})

		headerText = "CommonUI.Features.Label.Friends"
	else
		local setPeopleListFrozen = self.props.setPeopleListFrozen

		local friends = self.state.friends
		local cardStart = self.state.cardWindowStart
		local numCards = self.state.cardsInWindow
		local cardWidth = self.state.cardWidth

		local canvasSizeX
		if FFlagLuaHomePageShowAddFriendsButton then
			canvasSizeX = #friends * cardWidth + FRIEND_SECTION_MARGIN + ADD_FRIENDS_BUTTON_WIDTH
		else
			canvasSizeX = #friends * cardWidth + FRIEND_SECTION_MARGIN
		end

		local function createUserEntry(user, count)
			local avatarThumbnailType

			if FFlagLuaAppMakeAvatarThumbnailTypesEnum then
				avatarThumbnailType = AvatarThumbnailTypes.HeadShot
			else
				avatarThumbnailType = Constants.AvatarThumbnailTypes.HeadShot
			end

			return Roact.createElement(UserCarouselEntry, {
				user = user,
				formFactor = formFactor,
				count = FFlagLuaHomePageShowAddFriendsButton and (count - 1) or count,
				highlightColor = Constants.Color.WHITE,
				setPeopleListFrozen = setPeopleListFrozen,
				thumbnailType = avatarThumbnailType,
			})
		end

		local leftPadding = math.max(0, (cardStart - 1) * cardWidth) + FRIEND_SECTION_MARGIN

		if FFlagLuaHomePageShowAddFriendsButton and cardStart > 1 then
			leftPadding  = leftPadding + ADD_FRIENDS_BUTTON_WIDTH
		end

		local peopleListItems = {}
		-- First Element is the AddFriendsButton
		if FFlagLuaHomePageShowAddFriendsButton and cardStart == 1 then
			local addFriendsButton = Roact.createElement(AddFriendsButton, {
				hasNoFriend = false,
			})

			table.insert(peopleListItems, addFriendsButton)
		end

		for i = math.max(1, cardStart), math.min(#friends,cardStart + numCards) do
			table.insert(peopleListItems, createUserEntry(friends[i], #peopleListItems + 1))
		end

		peopleListItems.Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		peopleListItems.Padding = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.new(0, leftPadding, 1, 0),
		})

		content = Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, friendSectionHeight),
			ScrollBarThickness = 0,
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, canvasSizeX, 1, 0),
			ScrollingDirection = Enum.ScrollingDirection.X,

			[Roact.Change.CanvasPosition] = self.updateCardWindowBounds,
			[Roact.Ref] = self.scrollingFrameRefCallback,
		}, peopleListItems)

		headerText = {
			"Feature.Home.HeadingFriends",
			friendCount = friendCount,
		}
	end

	return Roact.createElement(FitChildren.FitFrame, {
			Size = UDim2.new(1, 0, 0, 0),
			fitAxis = FitChildren.FitAxis.Height,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		},
		{
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Container = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				fitFields = {
					Size = FitChildren.FitAxis.Height,
				},
			},
			{
				SidePadding = Roact.createElement("UIPadding", {
					PaddingLeft = CAROUSEL_PADDING_DIM,
					PaddingRight = CAROUSEL_PADDING_DIM,
				}),
				Header = Roact.createElement(LocalizedSectionHeaderWithSeeAll, {
					text = headerText,
					LayoutOrder = 1,
					onSelected = self.onSeeAllFriends,
					seeAllButtonVisible = seeAllButtonVisible,
				}),
			}),
			CarouselFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, friendSectionHeight),
				BackgroundColor3 = Constants.Color.WHITE,
				LayoutOrder = 2,
				BorderSizePixel = 0,
			},
			{
				Content = content,
			}),
		}
	)
end

--NOTE: when cleaning up LuaAppEnableStyleProvider replace render with newRender
if useNewAppStyle then
	UserCarousel.render = UserCarousel.newRender
else
	UserCarousel.render = UserCarousel.oldRender
end

function UserCarousel.getDerivedStateFromProps(props)
	if not props.peopleListFrozen then
		return {
			friends = props.friends,
		}
	end
end

function UserCarousel:didMount()
	self.updateCardWindowBounds()
end

function UserCarousel:didUpdate(prevProps)
	if self.props.screenSize ~= prevProps.screenSize or self.props.formFactor ~= prevProps.formFactor then
		self.updateCardWindowBounds()
	end
end

UserCarousel = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize,
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(UserCarousel)

return UserCarousel
