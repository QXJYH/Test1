local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local memoize = require(Modules.Common.memoize)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)
local Constants = require(Modules.LuaApp.Constants)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local ThemeProvider = require(Modules.LuaApp.ThemeProvider)
-- TODO: remove the theme hack. MOBLUAPP-943
local HARD_CODED_THEME = require(Modules.LuaApp.Themes.DeprecatedDarkTheme)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppFeature = require(Modules.LuaApp.Enum.AppFeature)

local ActionBar = require(Modules.LuaApp.Components.GameDetails.ActionBar)
local FadeInImageLabel = require(Modules.LuaApp.Components.FadeInImageLabel)
local LoadingSkeleton = require(Modules.LuaApp.Components.LoadingSkeleton)
local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local GameMediaAccordionView = require(Modules.LuaApp.Components.Games.GameMediaAccordionView)
local GameInfoList = require(Modules.LuaApp.Components.GameDetails.GameInfoList)
local GameDetailsTopBar = require(Modules.LuaApp.Components.GameDetails.GameDetailsTopBar)
local GameHeader = require(Modules.LuaApp.Components.GameDetails.GameHeader)
local GamePlaysAndRatings = require(Modules.LuaApp.Components.GameDetails.GamePlaysAndRatings)
local RecommendedGameCarousel = require(Modules.LuaApp.Components.GameDetails.RecommendedGameCarousel)
local SocialMediaGroup = require(Modules.LuaApp.Components.GameDetails.SocialMediaGroup)
local getAmbientImageWithGameGenre = require(Modules.LuaApp.Components.GameDetails.getAmbientImageWithGameGenre)
local ScrollingFrameWithExternalScrollBar = require(
	Modules.LuaApp.Components.Generic.ScrollingFrameWithExternalScrollBar)

local FetchGameDetailsPageData = require(Modules.LuaApp.Thunks.FetchGameDetailsPageData)
local RecommendedGames = require(Modules.LuaApp.Thunks.RecommendedGames)

local FFlagLuaGameDetailsRenderTransparentBackground = settings():GetFFlag("LuaGameDetailsRenderTransparentBackground")
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local HARD_CODED_THEME_NAME = "dark"

local TOP_INNER_PADDING = 20
local BOTTOM_PADDING = 20
local CONTENT_PADDING = 30
local CONTENT_CHILDREN_PADDING = 20
local ACTION_BAR_HEIGHT = Constants.GameDetails.ActionBarHeight + Constants.GameDetails.ActionBarGradientHeight
local MAXIMUM_CONTAINER_WIDTH = 640
local PARALLAX_SPEED = 1 / 10
local BACKGROUND_IMAGE_EXPAND_SIZE = 1.8

local LOADING_SKELETON_PADDING = 15
local LOADING_SKELETON_PANELS = {
	[1] = { Size = UDim2.new(0.5, 0, 0, 35) },
	[2] = { Size = UDim2.new(0.25, 0, 0, 24) },
	[3] = { Size = UDim2.new(1, 0, 0, 200) },
	[4] = { Size = UDim2.new(1, 0, 0, 24) },
	[5] = { Size = UDim2.new(0.6, 0, 0, 24) },
}

-- The space fill at the bottom of the ScrollingFrame, in case elastic behavior
-- at the bottom makes the background image expose
local BOTTOM_FILL_HEIGHT = 500

local DESCRIPTION_TEXT_SIZE = 22
local SCROLL_BAR_THICKNESS = 8

local function getInnerPaddingSize(cardWidth)
	if cardWidth < 600 then
		return 20
	else
		return 40
	end
end

local GameDetails = Roact.PureComponent:extend("GameDetails")

function GameDetails:init()
	local universeId = self.props.universeId

	if not universeId or type(universeId) ~= "string" then
		error("Must have a valid universeId to open a game details page!")
	end

	self.backgroundRef = Roact.createRef()

	self.onCanvasPositionChanged = function(rbx)
		-- parallax background image with canvas movement
		if self.backgroundRef.current ~= nil then
			local offset = - math.min(rbx.CanvasPosition.Y * PARALLAX_SPEED, self.parallaxLimit)
			self.backgroundRef.current.Position = UDim2.new(0.5, 0, 0.5, offset)
		end
	end

	self.fetchGameDetailsPageData = function()
		local networking = self.props.networking
		local theUniverseId = self.props.universeId
		local fetchGameDetailsPageData = self.props.fetchGameDetailsPageData

		return fetchGameDetailsPageData(networking, theUniverseId)
	end
end

function GameDetails:renderOnLoading(innerPaddingSize)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, TOP_INNER_PADDING),
			PaddingLeft = UDim.new(0, innerPaddingSize),
			PaddingRight = UDim.new(0, innerPaddingSize),
		}),
		Skeleton = Roact.createElement(LoadingSkeleton, {
			Size = UDim2.new(1, 0, 1, 0),
			createLayout = function()
				return Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, LOADING_SKELETON_PADDING),
				})
			end,
			panels = LOADING_SKELETON_PANELS,
		}),
	})
end

function GameDetails:renderOnLoaded(cardWidth, innerPaddingSize)
	local universeId = self.props.universeId
	local gameDetail = self.props.gameDetail
	local showRecommendedGames = self.props.showRecommendedGames and self.props.enableRecommendedGames
	local showSocial = self.props.enableSocial
	local showGameInfoList = self.props.enableGameInfoList
	local showGamePlaysAndRatings = self.props.enableGamePlaysAndRatings
	local showDescription = (gameDetail.description ~= nil and gameDetail.description ~= '')

	local theme = HARD_CODED_THEME

	return Roact.createElement(ScrollingFrameWithExternalScrollBar, {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, showRecommendedGames and BOTTOM_FILL_HEIGHT or 0),
		BackgroundTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Always,
		ScrollBarThickness = SCROLL_BAR_THICKNESS,
		onlyRenderScrollBarOnHover = true,
		scrollBarPositionOffsetX = -SCROLL_BAR_THICKNESS,
		ScrollBarImageColor3 = theme.ScrollingFrameWithScrollBar.ScrollBar.Color,
		ScrollBarImageTransparency = theme.ScrollingFrameWithScrollBar.ScrollBar.Transparency,
		ClipsDescendants = true,
		[Roact.Change.CanvasPosition] = self.onCanvasPositionChanged,
	}, {
		ListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, CONTENT_PADDING),
		}),
		PagePadding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, innerPaddingSize),
			PaddingRight = UDim.new(0, innerPaddingSize),
			PaddingTop = UDim.new(0, TOP_INNER_PADDING),
			PaddingBottom = UDim.new(0, FFlagLuaGameDetailsRenderTransparentBackground and
				(ACTION_BAR_HEIGHT + BOTTOM_PADDING) or ACTION_BAR_HEIGHT),
		}),
		Header = Roact.createElement(GameHeader, {
			universeId = universeId,
			LayoutOrder = 1,
		}),
		ThumbnailAccordion = Roact.createElement(GameMediaAccordionView, {
			universeId = universeId,
			placeId = gameDetail.rootPlaceId,
			width = cardWidth - 2 * innerPaddingSize,
			LayoutOrder = 2,
		}),
		Description = showDescription and Roact.createElement(FitTextLabel, {
			Size = UDim2.new(1, 0, 0, 0),
			Text = gameDetail.description,
			Font = theme.GameDetails.Text.Font,
			TextSize = DESCRIPTION_TEXT_SIZE,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.GameDetails.Text.Color.Secondary,
			TextWrapped = true,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
		}),
		PlaysAndRatings = showGamePlaysAndRatings and Roact.createElement(GamePlaysAndRatings, {
			universeId = universeId,
			containerWidth = cardWidth - 2 * innerPaddingSize,
			rowPadding = CONTENT_CHILDREN_PADDING,
			LayoutOrder = 4,
		}),
		StatsAndInfo = showGameInfoList and Roact.createElement(GameInfoList, {
			LayoutOrder = 5,
			universeId = universeId,
			leftPadding = innerPaddingSize,
			rightPadding = innerPaddingSize,
		}),
		Social = showSocial and Roact.createElement(SocialMediaGroup, {
			LayoutOrder = 6,
			universeId = universeId,
		}),
		RecommendedGames = showRecommendedGames and Roact.createElement(FitChildren.FitFrame, {
			LayoutOrder = 7,
			Size = UDim2.new(1, innerPaddingSize * 2, 0, 0),
			BackgroundColor3 = theme.Color.Background,
			BorderSizePixel = 0,
			fitAxis = FitChildren.FitAxis.Height,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, CONTENT_CHILDREN_PADDING),
				PaddingBottom = UDim.new(0, BOTTOM_FILL_HEIGHT),
				PaddingLeft = UDim.new(0, innerPaddingSize),
				PaddingRight = UDim.new(0, innerPaddingSize),
			}),
			Carousel = Roact.createElement(RecommendedGameCarousel, {
				universeId = universeId,
			}),
		}),
	})
end

function GameDetails:getImageSize(containerWidth, containerHeight, imageWidth, imageHeight)
	local minimumWidth = containerWidth
	local minimumHeight = containerHeight * BACKGROUND_IMAGE_EXPAND_SIZE
	local imageAspectRatio = imageHeight / imageWidth

	local height = math.max(minimumHeight, minimumWidth * imageAspectRatio)
	local width = height / imageAspectRatio

	return Vector2.new(width, height)
end

function GameDetails:render()
	local universeId = self.props.universeId
	local gameDetail = self.props.gameDetail
	local topBarHeight = self.props.topBarHeight
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local gameDetailsPageDataStatus = self.props.gameDetailsPageDataStatus
	local showLoadingBackground = self.props.showLoadingBackground

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)
	local cardWidth = math.min(safeAreaSize.X.Offset, MAXIMUM_CONTAINER_WIDTH)
	local cardHeight = safeAreaSize.Y.Offset
	local innerPaddingSize = getInnerPaddingSize(cardWidth)

	if not FFlagLuaGameDetailsRenderTransparentBackground then
		cardHeight = cardHeight - BOTTOM_PADDING
	end

	local theme = HARD_CODED_THEME

	local backgroundImage
	if showLoadingBackground then
		backgroundImage = theme.GameDetails.LoadingView.BackgroundImage
	else
		backgroundImage = getAmbientImageWithGameGenre(gameDetail.genre)
	end
	local backgroundImageSize = self:getImageSize(cardWidth, cardHeight,
		backgroundImage.Size.X, backgroundImage.Size.Y)
	self.parallaxLimit = (backgroundImageSize.Y - cardHeight) / 2

	return Roact.createElement(ThemeProvider, {
		theme = theme,
		themeName = HARD_CODED_THEME_NAME,
	}, {
		GameDetailsPage = Roact.createElement("Frame", {
			Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
			Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
			BackgroundColor3 = FFlagLuaGameDetailsRenderTransparentBackground and
				theme.GameDetails.Background.Color or
				theme.Color.Background,
			BackgroundTransparency = FFlagLuaGameDetailsRenderTransparentBackground and
				theme.GameDetails.Background.Transparency or
				0,
			-- Absorb input
			Active = true,
			BorderSizePixel = 0,
		}, {
			SafeAreaFrame = Roact.createElement("Frame", {
				Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
				Size = safeAreaSize,
				BackgroundTransparency = 1,
			}, {
				GameDetailsCard = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					Size = UDim2.new(0, cardWidth, 0, cardHeight),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
				}, {
					TopBar = Roact.createElement(GameDetailsTopBar, {
						universeId = universeId,
					}),
					Contents = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, -topBarHeight),
						Position = UDim2.new(0, 0, 0, topBarHeight),
						BackgroundTransparency = 1,
						ClipsDescendants = true,
					}, {
						Background = Roact.createElement("Frame", {
							Size = UDim2.new(0, backgroundImageSize.X, 0, backgroundImageSize.Y),
							Position = UDim2.new(0.5, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							ZIndex = 1,
							[Roact.Ref] = self.backgroundRef,
						}, {
							FadeInImage = Roact.createElement(FadeInImageLabel, {
								Size = UDim2.new(1, 0, 1, 0),

								-- Use static background when no image is supplied
								BackgroundTransparency = backgroundImage.Image ~= "" and 1 or 0,
								BackgroundColor3 = theme.Color.Background,

								Image = backgroundImage.Image,
								Tint = backgroundImage.Tint,
							}),
						}),
						GameDetails = Roact.createElement("Frame", {
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							ZIndex = 2,
						}, {
							LoadingState = Roact.createElement(LoadingStateWrapper, {
								dataStatus = gameDetailsPageDataStatus,
								onRetry = self.fetchGameDetailsPageData,
								debugName = "GameDetails-" .. universeId,
								renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
								stateMappingStyle = LoadingStateWrapper.StateMappingStyle.DirectMapping,
								renderOnLoading = function()
									return self:renderOnLoading(innerPaddingSize)
								end,
								renderOnLoaded = function()
									return self:renderOnLoaded(cardWidth, innerPaddingSize)
								end,
							}),
						}),
						ActionBar = Roact.createElement(ActionBar, {
							leftPadding = innerPaddingSize,
							rightPadding = innerPaddingSize,
							bottomPadding = FFlagLuaGameDetailsRenderTransparentBackground and BOTTOM_PADDING or 0,
							containerWidth = cardWidth,
							universeId = universeId,
							ZIndex = 3,
						}),
					}),
				}),
			}),
		})
	})
end

function GameDetails:didMount()
	self.fetchGameDetailsPageData()
end

local getShowRecommendedGames = memoize(function(recommendedGamesFetchingStatus, recommendedGameEntries)
	if recommendedGamesFetchingStatus == RetrievalStatus.Done and
		(recommendedGameEntries == nil or #recommendedGameEntries == 0) then
		return false
	end
	return true
end)

GameDetails = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameDetailsPageDataStatus = state.GameDetailsPageDataStatus[props.universeId]

		if gameDetailsPageDataStatus == nil then
			gameDetailsPageDataStatus = RetrievalStatus.NotStarted
		end

		return {
			topBarHeight = state.TopBar.topBarHeight,
			gameDetail = state.GameDetails[props.universeId],
			gameDetailsPageDataStatus = gameDetailsPageDataStatus,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
			showLoadingBackground = gameDetailsPageDataStatus ~= RetrievalStatus.Done,
			showRecommendedGames = getShowRecommendedGames(RecommendedGames.GetFetchingStatus(state, props.universeId),
				state.RecommendedGameEntries[props.universeId]),
		}
	end,
	function(dispatch)
		return {
			fetchGameDetailsPageData = function(networking, universeId)
				return dispatch(FetchGameDetailsPageData(networking, universeId))
			end,
		}
	end
)(GameDetails)

GameDetails = RoactServices.connect({
	networking = RoactNetworking,
})(GameDetails)

if FFlagLuaAppPolicyRoactConnector then
	GameDetails = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			enableRecommendedGames = appPolicy.getRecommendedGames(),
			enableSocial = appPolicy.getSocialLinks(),
			enableGameInfoList = appPolicy.getGameInfoList(),
			enableGamePlaysAndRatings = appPolicy.getGamePlaysAndRatings(),
		}
	end)(GameDetails)
else
	GameDetails = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			enableRecommendedGames = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.RecommendedGames),
			enableSocial = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.SocialLinks),
			enableGameInfoList = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.GameInfoList),
			enableGamePlaysAndRatings = not appPolicy or appPolicy.IsFeatureEnabled(AppFeature.GamePlaysAndRatings),
		}
	end)(GameDetails)
end

return GameDetails
