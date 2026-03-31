local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Url = require(CorePackages.AppTempCommon.LuaApp.Http.Url)
local Functional = require(CorePackages.AppTempCommon.Common.Functional)
local UIBlox = require(CorePackages.UIBlox)
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local Constants = require(Modules.LuaApp.Constants)
local memoize = require(Modules.Common.memoize)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local OpenCentralOverlayForLeaveRobloxAlert = require(Modules.LuaApp.Thunks.OpenCentralOverlayForLeaveRobloxAlert)
local OpenYouTubeVideo = require(Modules.LuaApp.Thunks.OpenYouTubeVideo)
local AccordionViewAnimated = require(Modules.LuaApp.Components.Generic.AccordionViewAnimated)
local AccordionView = UIBlox.AccordionView
local GameMediaItem = require(Modules.LuaApp.Components.Games.GameMediaItem)
local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)
local GenericIconButton = require(Modules.LuaApp.Components.GenericIconButton)

local ApiFetchGameMedia = require(Modules.LuaApp.Thunks.ApiFetchGameMedia)

local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")
local FFlagLuaAppUseUIBloxAccordion = require(script.Parent.Flags.LuaAppUseUIBloxAccordion)

local MAX_NUMBER_OF_ITEMS = 10
local THUMBNAIL_ASPECT_RATIO = 188.0 / 335.0

local DEFAULT_THUMBNAIL_WIDTH = 768
local DEFAULT_THUMBNAIL_HEIGHT = 432

local COLLAPSE_BUTTON_ICON = "LuaApp/icons/GameDetails/collapse"
local COLLAPSE_BUTTON_SIZE = 44
local COLLAPSE_BUTTON_ICON_SIZE = 36

local function processMediaEntry(entry)
	local mediaType = entry.assetTypeId

	local imageId
	if mediaType == Constants.GameMediaImageType.YouTubeVideo then
		imageId = string.format("https://img.youtube.com/vi/%s/hqdefault.jpg", entry.videoHash)
	else
		imageId = "http://www.roblox.com/asset/?id=" .. tostring(entry.imageId)
	end

	return {
		mediaType = entry.assetTypeId,
		imageId = imageId,
		videoTitle = entry.videoTitle,
		videoHash = entry.videoHash,
	}
end

local function generateDefaultEntry(placeId)
	return {
		mediaType = Constants.GameMediaImageType.Image,
		imageId = Url:getPlaceDefaultThumbnailUrl(placeId, DEFAULT_THUMBNAIL_WIDTH, DEFAULT_THUMBNAIL_HEIGHT),
	}
end

local selectGameMediaEntries = memoize(function(entries, maxCount, placeId, gameMediaFetchingStatus)
	if not entries then
		-- We only want to generate the default image when there're no entries, and the fetch succeeded.
		-- (Meaning the game has no images, rather than we failed to fetch those images)
		if gameMediaFetchingStatus == RetrievalStatus.Done then
			return {
				[1] = generateDefaultEntry(placeId),
			}
		else
			return {}
		end
	end

	local cappedEntries = { unpack(entries, 1, maxCount) }

	local processedEntries = {}
	for _, entry in ipairs(cappedEntries) do
		table.insert(processedEntries, processMediaEntry(entry))
	end

	return processedEntries
end)

local GameMediaAccordionView = Roact.PureComponent:extend("GameMediaAccordionView")

function GameMediaAccordionView:init()
	self.isMounted = false

	local firstImageLoaded = LoadableImage.isLoaded(self.props.firstImageId)

	self.state = {
		firstImageLoaded = firstImageLoaded,
	}

	self.performOpenYouTubeVideo = function(item)
		local guiService = self.props.guiService
		local openYouTubeVideo = self.props.openYouTubeVideo

		local videoHash = item.videoHash
		local videoTitle = item.videoTitle

		if videoHash and #videoHash > 0 and videoTitle and #videoTitle > 0 then
			openYouTubeVideo(guiService, videoHash, videoTitle)
		end
	end

	self.openItem = function(item)
		if item.mediaType == Constants.GameMediaImageType.YouTubeVideo then
			local openLeaveRobloxAlert = self.props.OpenLeaveRobloxAlert
			local showYouTubeAgeAlert = self.props.showYouTubeAgeAlert
			local continueFunc = function()
				self.performOpenYouTubeVideo(item)
			end
			local theme = self._context.AppTheme

			if showYouTubeAgeAlert then
				openLeaveRobloxAlert(continueFunc, theme)
			else
				continueFunc()
			end
		end
	end

	self.onImageLoaded = function(index)
		if index == 1 and self.state.firstImageLoaded == false and self.isMounted then
			self:setState({
				firstImageLoaded = true,
			})
		end
	end
end

if FFlagLuaAppUseUIBloxAccordion then
	function GameMediaAccordionView:renderItem(item, transparency, animationSettings)
		local theme = self._context.AppTheme.GameMediaAccordion

		local itemBackgroundColor = theme.Item.BackgroundColor
		local itemBackgroundTransparency = theme.Item.BackgroundTransparency
		local videoIconColor = theme.VideoIconColor

		local imageId = item.imageId

		return Roact.createElement(GameMediaItem, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = itemBackgroundColor,
			BackgroundTransparency = itemBackgroundTransparency,
			Image = imageId,
			ImageTransparency = transparency,
			isVideo = item.mediaType == Constants.GameMediaImageType.YouTubeVideo,
			videoIconColor = videoIconColor,
			animationSettings = animationSettings,
			onImageLoaded = function()
				local index = Functional.Find(self.props.gameMediaEntries, item)
				self.onImageLoaded(index)
			end,
			onActivated = function()
				self.openItem(item)
			end,
		})
	end
else
	function GameMediaAccordionView:renderItem(index, allowInput, transparency, animationSettings)
		local theme = self._context.AppTheme.GameMediaAccordion
		local gameMediaEntries = self.props.gameMediaEntries

		local item = gameMediaEntries[index]

		local itemBackgroundColor = theme.Item.BackgroundColor
		local itemBackgroundTransparency = theme.Item.BackgroundTransparency
		local videoIconColor = theme.VideoIconColor

		local imageId = item.imageId

		return Roact.createElement(GameMediaItem, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = itemBackgroundColor,
			BackgroundTransparency = itemBackgroundTransparency,
			Image = imageId,
			ImageTransparency = transparency,
			isVideo = item.mediaType == Constants.GameMediaImageType.YouTubeVideo,
			videoIconColor = videoIconColor,
			animationSettings = animationSettings,
			onImageLoaded = function()
				self.onImageLoaded(index)
			end,
			onActivated = allowInput and function()
				self.openItem(item)
			end or nil,
		})
	end
end

function GameMediaAccordionView:render()
	local theme = self._context.AppTheme.GameMediaAccordion
	local gameMediaEntries = self.props.gameMediaEntries
	local layoutOrder = self.props.LayoutOrder
	local width = self.props.width
	local firstImageLoaded = self.state.firstImageLoaded

	local fakeItemTheme = firstImageLoaded and theme.FakeItem.Loaded or theme.FakeItem.Loading

	if #gameMediaEntries > 0 then
		if FFlagLuaAppUseUIBloxAccordion then
			return Roact.createElement(AccordionView, {
				items = gameMediaEntries,
				itemWidth = width,
				itemHeight = width * THUMBNAIL_ASPECT_RATIO,
				renderItem = function(...) return self:renderItem(...) end,
				placeholderColor = fakeItemTheme.Color,
				placeholderBaseTransparency = fakeItemTheme.BaseTransparency,
				collapseButtonSize = COLLAPSE_BUTTON_SIZE,
				renderCollapseButton = function(activatedCallback)
					return Roact.createElement(GenericIconButton, {
						Size = UDim2.new(1, 0, 1, 0),
						iconSize = UDim2.new(0, COLLAPSE_BUTTON_ICON_SIZE, 0, COLLAPSE_BUTTON_ICON_SIZE),
						iconImage = COLLAPSE_BUTTON_ICON,
						onActivated = activatedCallback,
					})
				end,
				LayoutOrder = layoutOrder,
				maxItemsInCompactView = 3,
			})
		else
			return Roact.createElement(AccordionViewAnimated, {
				fakeItemBackgroundColor = fakeItemTheme.Color,
				fakeItemBaseTransparency = fakeItemTheme.BaseTransparency,
				fakeItemTransparencyStep = fakeItemTheme.TransparencyStep,
				items = gameMediaEntries,
				renderItem = function(...) return self:renderItem(...) end,
				itemWidth = width,
				itemHeight = width * THUMBNAIL_ASPECT_RATIO,
				LayoutOrder = layoutOrder,
			})
		end
	else
		return nil -- Nothing to show if page is loading or no media available
	end
end

function GameMediaAccordionView:didUpdate(oldProps)
	if oldProps.firstImageId ~= self.props.firstImageId then
		local isLoaded = LoadableImage.isLoaded(self.props.firstImageId)
		if isLoaded ~= self.state.firstImageLoaded then
			self:setState({
				firstImageLoaded = isLoaded
			})
		end
	end
end

function GameMediaAccordionView:didMount()
	self.isMounted = true
end

function GameMediaAccordionView:willUnmount()
	self.isMounted = false
end

GameMediaAccordionView = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameMediaEntries

		local gameMediaFetchingStatus = ApiFetchGameMedia.GetFetchingStatus(state, props.universeId)
		gameMediaEntries = selectGameMediaEntries(
			state.GameMedia[props.universeId], MAX_NUMBER_OF_ITEMS, props.placeId, gameMediaFetchingStatus)

		local firstImageId = Roact.None
		if gameMediaEntries ~= nil and gameMediaEntries[1] ~= nil then
			firstImageId = gameMediaEntries[1].imageId
		end

		return {
			gameMediaEntries = gameMediaEntries,
			firstImageId = firstImageId,
		}
	end,
	function(dispatch)
		return {
			OpenLeaveRobloxAlert = function(continueFunc, theme)
				dispatch(OpenCentralOverlayForLeaveRobloxAlert(continueFunc, theme))
			end,
			openYouTubeVideo = function(guiService, videoHash, videoTitle)
				return dispatch(OpenYouTubeVideo(guiService, videoHash, videoTitle))
			end
		}
	end
)(GameMediaAccordionView)

GameMediaAccordionView = RoactServices.connect({
	guiService = AppGuiService
})(GameMediaAccordionView)

if FFlagLuaAppPolicyRoactConnector then
	GameMediaAccordionView = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			showYouTubeAgeAlert = appPolicy.getShowYouTubeAgeAlert(),
		}
	end)(GameMediaAccordionView)
else
	GameMediaAccordionView = RoactAppPolicy.legacy_connect(function(policy, props)
		return {
			showYouTubeAgeAlert = policy and policy.getShowYouTubeAgeAlert()
		}
	end)(GameMediaAccordionView)
end

return GameMediaAccordionView
