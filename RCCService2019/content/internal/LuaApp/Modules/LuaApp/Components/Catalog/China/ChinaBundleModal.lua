local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local LuaApp = CorePackages.AppTempCommon.LuaApp
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local NavigateBack = require(Modules.LuaApp.Thunks.NavigateBack)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local AppPage = require(Modules.LuaApp.AppPage)
local Constants = require(Modules.LuaApp.Constants)
local Colors = require(Modules.LuaApp.Themes.Colors)
local FitChildren = require(Modules.LuaApp.FitChildren)
local FitTextLabel = require(Modules.LuaApp.Components.FitTextLabel)
local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)
local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
local ChinaBuyButton = require(Modules.LuaApp.Components.Catalog.China.ChinaBuyButton)
local PerformFetch = require(Modules.LuaApp.Thunks.Networking.Util.PerformFetch)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)

local FetchBundleInfo = require(Modules.LuaApp.Thunks.Catalog.FetchBundleInfo)
local FetchBundleThumbnails = require(Modules.LuaApp.Thunks.Catalog.FetchBundleThumbnails)
local GetIsPurchasable = require(Modules.LuaApp.Thunks.Catalog.GetIsPurchasable)

local Promise = require(LuaApp.Promise)

local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)

local LoadingStateWrapper = require(Modules.LuaApp.Components.LoadingStateWrapper)
local LoadingSkeleton = require(Modules.LuaApp.Components.LoadingSkeleton)
local ScrollingFrameWithExternalScrollBar = require(
	Modules.LuaApp.Components.Generic.ScrollingFrameWithExternalScrollBar)

local NAVIGATION_BUTTON_LEFT_PADDING = 15
local NAVIGATION_BUTTON_SIZE = 36
local NAVIGATION_ICON_SIZE = 36
local CLOSE_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/close"
local BACK_BUTTON_IMAGE = "LuaApp/icons/GameDetails/navigation/pushLeft"

local BOTTOM_PADDING = 20
local ACTION_BAR_HEIGHT = 44
local ACTION_BAR_GRADIENT_HEIGHT = Constants.GameDetails.ActionBarGradientHeight
local ACTION_BAR_TOTAL_HEIGHT = ACTION_BAR_HEIGHT + ACTION_BAR_GRADIENT_HEIGHT + BOTTOM_PADDING
local ACTION_BAR_GRADIENT_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/gradient_0_100.png"

local TITLE_FONT_SIZE = 32
local DESCRIPTION_TEXT_SIZE = 16
local THUMBNAIL_API_SIZE = 420
local THUMBNAIL_SIZE_KEY = CatalogConstants.ThumbnailSize["420"]
local THUMBNAIL_SUBDIVIDE_COUNT = 20
local TOP_THUMBNAIL_PADDING = 30
local TOP_DESCRIPTION_PADDING = 15
local MAXIMUM_CONTAINER_WIDTH = 640
local LOADING_SKELETON_PADDING = 15
local LOADING_SKELETON_PANELS = {
	[1] = { Size = UDim2.new(0.5, 0, 0, 35) },
	[2] = { Size = UDim2.new(0.25, 0, 0, 24) },
	[3] = { Size = UDim2.new(1, 0, 0, 200) },
	[4] = { Size = UDim2.new(1, 0, 0, 24) },
	[5] = { Size = UDim2.new(0.6, 0, 0, 24) },
}

local DETAILS_BACKGROUND_IMAGE =  "rbxasset://textures/ui/LuaApp/graphic/itemcardbkg_dark.png"
local DETAILS_OVERLAY_COLOR = Colors.Black
local DETAILS_OVERLAY_TRANSPARENCY = 0.3
local DETAILS_SECONDARY_TEXT_COLOR = Colors.Smoke

local SCROLL_BAR_THICKNESS = 8

local ChinaBundleModal = Roact.PureComponent:extend("ChinaBundleModal")

local function getLayout(cardWidth)
	if cardWidth < 600 then
		return {
			padding = 20,
			thumbnailSize = 300,
			backgroundHeight = 600,
		}
	else
		return {
			padding = 40,
			thumbnailSize = 420,
			backgroundHeight = 800,
		}
	end
end

local function selectShowCloseIcon(history, routeName)
	local currentRoute = history[#history]

	local numberOfPages = 0
	if currentRoute then
		for index = 1, #currentRoute do
			if currentRoute[index].name == routeName then
				numberOfPages = numberOfPages + 1

				if numberOfPages > 1 then
					break
				end
			end
		end
	end

	-- Show the close icon if there are 1 or fewer pages, to accommodate
	-- the case where the current page is not yet part of the route history.
	return numberOfPages <= 1
end

function ChinaBundleModal:init()
	self.fetchItemDetailsPageData = function()
		return Promise.new(function(resolve, reject)
			spawn(function()
				local networking = self.props.networking
				local itemId = self.props.itemId
				local productId = self.props.itemInfo[itemId] and self.props.itemInfo[itemId].product and self.props.itemInfo[itemId].product.id or nil

				local success, result = pcall(function()
					self.props.getIsPurchasable(networking, productId)
					self.props.getBundleThumbnails(networking, {itemId}, THUMBNAIL_API_SIZE, THUMBNAIL_SUBDIVIDE_COUNT)
					return self.props.fetchBundleInfo(networking, {itemId})
				end)
				if success then
					resolve(result)
				else
					reject(result)
				end
			end)
		end)
	end

	self.backgroundRef = Roact.createRef()
	self.onCanvasPositionChanged = function(rbx)
		-- fix background image with canvas movement
		if self.backgroundRef.current ~= nil then
			local offset = -rbx.CanvasPosition.Y
			self.backgroundRef.current.Position = UDim2.new(0, 0, 0, offset)
		end
	end
end

function ChinaBundleModal:didMount()
	self.fetchItemDetailsPageData()
end

function ChinaBundleModal:renderOnLoading(innerPaddingSize)
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, innerPaddingSize),
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

function ChinaBundleModal:renderOnLoaded(cardWidth, innerPaddingSize)
	local theme = self._context.AppTheme
	local itemInfo = self.props.itemInfo[self.props.itemId]
	local thumbData = itemInfo.thumbnails or {}
	local thumbnail = thumbData[THUMBNAIL_SIZE_KEY]

	local layoutInfo = getLayout(cardWidth)
	local thumbnailSize = layoutInfo.thumbnailSize

	return Roact.createElement("Frame", {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		ItemBackground = Roact.createElement("ImageLabel", {
			Image = DETAILS_BACKGROUND_IMAGE,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, layoutInfo.backgroundHeight),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 1,
			[Roact.Ref] = self.backgroundRef,
		}),
		ScrollingFrame = Roact.createElement(ScrollingFrameWithExternalScrollBar, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ElasticBehavior = Enum.ElasticBehavior.Always,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			onlyRenderScrollBarOnHover = true,
			ScrollBarThickness = SCROLL_BAR_THICKNESS,
			scrollBarPositionOffsetX = -SCROLL_BAR_THICKNESS,
			ScrollBarImageColor3 = theme.ScrollingFrameWithScrollBar.ScrollBar.Color,
			ScrollBarImageTransparency = theme.ScrollingFrameWithScrollBar.ScrollBar.Transparency,
			ClipsDescendants = true,
			ZIndex = 2,
			[Roact.Change.CanvasPosition] = self.onCanvasPositionChanged,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			PagePadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, innerPaddingSize),
				PaddingBottom = UDim.new(0, ACTION_BAR_HEIGHT),
			}),
			Header = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				fitAxis = FitChildren.FitAxis.Height,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, innerPaddingSize),
					PaddingRight = UDim.new(0, innerPaddingSize),
				}),
				HeaderText = Roact.createElement(FitTextLabel, {
					Size = UDim2.new(1, 0, 0, 0),
					Text = itemInfo.name,
					Font = theme.Widget.Header.Text.Font,
					TextSize = TITLE_FONT_SIZE,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Widget.Header.Text.Color,
					TextWrapped = true,
					BackgroundTransparency = 1,
				}),
			}),
			ItemThumbnail = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, thumbnailSize + TOP_THUMBNAIL_PADDING),
			}, {
				ListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, TOP_THUMBNAIL_PADDING),
				}),
				Image = Roact.createElement(LoadableImage, {
					Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = thumbnail,
					useShimmerAnimationWhileLoading = true,
					LayoutOrder = 1,
				})
			}),
			Description = itemInfo.description and Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(1, 0, 0, 0),
				fitAxis = FitChildren.FitAxis.Height,
				BackgroundTransparency = 1,
				LayoutOrder = 3,
			}, {
				ListLayout = Roact.createElement("UIListLayout"),
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, TOP_DESCRIPTION_PADDING),
					PaddingLeft = UDim.new(0, innerPaddingSize),
					PaddingRight = UDim.new(0, innerPaddingSize),
					PaddingBottom = UDim.new(0, BOTTOM_PADDING),
				}),
				DescriptionText = Roact.createElement(FitTextLabel, {
					Size = UDim2.new(1, 0, 0, 0),
					Text = itemInfo.description,
					Font = theme.Widget.ContentText.Font,
					TextSize = DESCRIPTION_TEXT_SIZE,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = DETAILS_SECONDARY_TEXT_COLOR,
					TextWrapped = true,
					TextScaled = true,
					BackgroundTransparency = 1,
				}),
			}),
		}),
	})
end

function ChinaBundleModal:render()
	local theme = self._context.AppTheme
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)
	local cardWidth = math.min(safeAreaSize.X.Offset, MAXIMUM_CONTAINER_WIDTH)
	local cardHeight = safeAreaSize.Y.Offset
	local layoutInfo = getLayout(cardWidth)
	local innerPaddingSize = layoutInfo.padding
	local onRetry = self.fetchItemDetailsPageData
	local topBarHeight = self.props.topBarHeight
	local statusBarHeight = self.props.statusBarHeight
	local showCloseIcon = self.props.showCloseIcon
	local navigateBack = self.props.navigateBack
	local dataStatus = self.props.fetchingState
	local itemId = self.props.itemId
	local backgroundElement = self.props.backgroundElement

	return Roact.createElement("Frame", {
		Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
		Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
		BackgroundTransparency = 1,
		Active = true,
		BorderSizePixel = 0,
	}, {
		SafeAreaFrame = Roact.createElement("Frame", {
			Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
			BackgroundColor3 = DETAILS_OVERLAY_COLOR,
			BackgroundTransparency = DETAILS_OVERLAY_TRANSPARENCY,
			Size = safeAreaSize,
		}, {
			ChinaBundleDetailsCard = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0, cardWidth, 0, cardHeight),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
			}, {
				TouchFriendlyNavigationButton = Roact.createElement("TextButton", {
					Position = UDim2.new(0, NAVIGATION_BUTTON_LEFT_PADDING, 0, statusBarHeight),
					Size = UDim2.new(0, NAVIGATION_BUTTON_SIZE, 0, NAVIGATION_BUTTON_SIZE),
					BackgroundTransparency = 1,
					Text = "",
					[Roact.Event.Activated] = navigateBack,
				}, {
					NavigationButton = Roact.createElement(ImageSetLabel, {
						Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Image = showCloseIcon and CLOSE_BUTTON_IMAGE or BACK_BUTTON_IMAGE,
						ImageColor3 = theme.GameDetails.TopBar.Icon.Color,
						BackgroundTransparency = 1,
					}),
				}),
				Contents = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, -topBarHeight),
					Position = UDim2.new(0, 0, 0, topBarHeight),
					BackgroundColor3 = theme.Color.Background,
					ClipsDescendants = true,
				}, {
					Background = backgroundElement,
					ChinaItemDetails = Roact.createElement("Frame", {
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, -ACTION_BAR_HEIGHT - BOTTOM_PADDING),
						BackgroundTransparency = 1,
						ZIndex = 2,
					}, {
						LoadingState = Roact.createElement(LoadingStateWrapper, {
							dataStatus = dataStatus,
							onRetry = onRetry,
							renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage,
							stateMappingStyle = LoadingStateWrapper.StateMappingStyle.DirectMapping,
							renderOnLoading = function()
								return self:renderOnLoading(innerPaddingSize)
							end,
							renderOnLoaded = function() return self:renderOnLoaded(cardWidth, innerPaddingSize) end,
						}),
					}),
					ChinaBuyButtonFrame = Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 0, ACTION_BAR_TOTAL_HEIGHT),
						Position = UDim2.new(0, 0, 1, -ACTION_BAR_TOTAL_HEIGHT),
						BackgroundTransparency = 1,
						ZIndex = 3,
					}, {
						ActionBar = Roact.createElement("Frame", {
							Size = UDim2.new(1, 0, 0, ACTION_BAR_HEIGHT + BOTTOM_PADDING),
							Position = UDim2.new(0, 0, 1, -ACTION_BAR_HEIGHT - BOTTOM_PADDING),
							BackgroundColor3 = theme.Color.Background,
							BackgroundTransparency = 0,
							BorderSizePixel = 0,
						}, {
							Padding = Roact.createElement("UIPadding", {
								PaddingLeft = UDim.new(0, innerPaddingSize),
								PaddingRight = UDim.new(0, innerPaddingSize),
								PaddingBottom = UDim.new(0, BOTTOM_PADDING),
							}),
							BuyButton = Roact.createElement(ChinaBuyButton, {
								Size = UDim2.new(1, 0, 1, 0),
								LayoutOrder = 2,
								itemId = itemId,
							}),
						}),
						Gradient = Roact.createElement("ImageLabel", {
							Size = UDim2.new(1, 0, 0, ACTION_BAR_GRADIENT_HEIGHT),
							Position = UDim2.new(0, 0, 1, -ACTION_BAR_HEIGHT - BOTTOM_PADDING),
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Image = ACTION_BAR_GRADIENT_IMAGE,
							ImageColor3 = theme.Color.Background,
						})
					})
				}),
			}),
		}),
	})
end

ChinaBundleModal = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			topBarHeight = state.TopBar.topBarHeight,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
			itemInfo = state.CatalogAppReducer.Bundles,
			fetchingState = PerformFetch.GetStatus(state, CatalogConstants.BundlesInfoKey .. tostring(props.itemId)),
			statusBarHeight = state.TopBar.statusBarHeight,
			showCloseIcon = selectShowCloseIcon(state.Navigation.history, AppPage.ChinaBundleModal),
		}
	end,
	function(dispatch)
		return {
			navigateBack = function()
				return dispatch(NavigateBack())
			end,
			getBundleThumbnails = function(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount)
				return dispatch(FetchBundleThumbnails(networking, bundleIds, thumbnailSize, thumbnailSubdivideCount))
			end,
			fetchBundleInfo = function(networking, bundleIds)
				return dispatch(FetchBundleInfo(networking, bundleIds))
			end,
			getIsPurchasable = function(networking, productId)
				dispatch(GetIsPurchasable(networking, productId))
			end,
		}
	end
)(ChinaBundleModal)

return RoactServices.connect({
	networking = RoactNetworking,
})(ChinaBundleModal)