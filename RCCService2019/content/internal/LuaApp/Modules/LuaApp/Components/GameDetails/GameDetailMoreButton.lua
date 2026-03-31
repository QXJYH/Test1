local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local GenericIconButton = require(Modules.LuaApp.Components.GenericIconButton)
local ApiFetchGameDetails = require(Modules.LuaApp.Thunks.ApiFetchGameDetails)
local OpenCentralOverlayForGameDetailMore = require(Modules.LuaApp.Thunks.OpenCentralOverlayForGameDetailMore)

local BUTTON_SIZE = UDim2.new(0, 44, 0, 44)
local BUTTON_ICON_IMAGE = "LuaApp/icons/GameDetails/more"
local BUTTON_ICON_SIZE = UDim2.new(0, 37, 0, 37)

local SCREEN_WIDTH_THRESHOLD = 600
local MENU_WIDTH_THRESHOLD = 300
local MENU_POP_UP_OFFSET = 15

local GameDetailMoreButton = Roact.PureComponent:extend("GameDetailMoreButton")

function GameDetailMoreButton:getMoreMenuPosition()
	local screenWidth = self.props.screenWidth
	local leftPadding = self.props.leftPadding
	local moreButton = self.moreButtonRef.current
	local moreButtonCenterX = moreButton.AbsolutePosition.x + moreButton.AbsoluteSize.x / 2
	local moreButtonTopY = moreButton.AbsolutePosition.Y

	-- menuPosX is actually the X of FramePopup here.
	-- Since menu is centered as content in the FramePopup,
	-- use a framePopupOffset to avoid changes to the behavior of current FramePopup.
	-- In the future, FramePopup animation will be replaced with Otter
	local framePopupOffset = (screenWidth - MENU_WIDTH_THRESHOLD) / 2

	local menuPosX
	if screenWidth < SCREEN_WIDTH_THRESHOLD then
		menuPosX = 0
	elseif leftPadding + (MENU_WIDTH_THRESHOLD / 2) > moreButtonCenterX then
		menuPosX = leftPadding - framePopupOffset
	else
		menuPosX = moreButtonCenterX - (MENU_WIDTH_THRESHOLD / 2) - framePopupOffset
	end

	local menuPosY = moreButtonTopY - MENU_POP_UP_OFFSET

	return UDim2.new(0, menuPosX, 0, menuPosY)
end

function GameDetailMoreButton:getMoreMenuWidth()
	local leftPadding = self.props.leftPadding
	local rightPadding = self.props.rightPadding
	local screenWidth = self.props.screenWidth
	local containerWidth = self.props.containerWidth
	local realWidth = containerWidth - leftPadding - rightPadding
	if screenWidth < SCREEN_WIDTH_THRESHOLD then
		return realWidth
	end
	return MENU_WIDTH_THRESHOLD
end

function GameDetailMoreButton:init()
	self.moreButtonRef = Roact.createRef()

	local openContextualMenu = self.props.openContextualMenu

	self.onActivated = function()
		local theme = self._context.AppTheme
		local universeId = self.props.universeId
		local isDisabled = self.props.isDisabled

		if isDisabled then
			return
		end

		local menuPosition = self:getMoreMenuPosition()
		local menuWidth = self:getMoreMenuWidth()
		openContextualMenu(universeId, theme, menuPosition, menuWidth)
	end
end

function GameDetailMoreButton:render()
	local isLoading = self.props.isLoading
	local isDisabled = self.props.isDisabled

	return Roact.createElement(GenericIconButton, {
		Size = BUTTON_SIZE,
		iconImage = BUTTON_ICON_IMAGE,
		iconSize = BUTTON_ICON_SIZE,
		isLoading = isLoading,
		isDisabled = isDisabled,
		onActivated = self.onActivated,
		buttonRef = self.moreButtonRef,
	})
end

local getIsLoading = function(fetchingStatus, gameDetail)
	return fetchingStatus == RetrievalStatus.NotStarted or
		fetchingStatus == RetrievalStatus.Fetching
end

local getIsDisabled = function(fetchingStatus, centralOverlayType)
	return fetchingStatus == RetrievalStatus.Failed or
		centralOverlayType == OverlayType.GameDetailMore
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local fetchingStatus = ApiFetchGameDetails.GetFetchingStatus(state, props.universeId)

		local centralOverlayType = state.CentralOverlay.OverlayType

		return {
			screenWidth = state.ScreenSize.X,
			isLoading = getIsLoading(fetchingStatus, state.GameDetails[props.universeId]),
			isDisabled = getIsDisabled(fetchingStatus, centralOverlayType),
		}
	end,
	function(dispatch)
		return {
			openContextualMenu = function(universeId, theme, menuPosition, menuWidth)
				dispatch(OpenCentralOverlayForGameDetailMore(universeId, theme, menuPosition, menuWidth))
			end,
		}
	end
)(GameDetailMoreButton)
