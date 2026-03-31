local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Common = Modules.Common
local LuaApp = Modules.LuaApp

local AppGuiService = require(LuaApp.Services.AppGuiService)
local Constants = require(LuaApp.Constants)
local FitChildren = require(LuaApp.FitChildren)
local FormFactor = require(LuaApp.Enum.FormFactor)
local GameButton = require(LuaApp.Components.GameButton)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local LuaAppFlags = CorePackages.AppTempCommon.LuaApp.Flags
local NotificationType = require(LuaApp.Enum.NotificationType)

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local RoactServices = require(LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(LuaApp.Services.RoactAnalyticsHomePage)
local FeatureContext = require(LuaApp.Enum.FeatureContext)
local convertUniverseIdToString = require(LuaAppFlags.ConvertUniverseIdToString)
local Text = require(Common.Text)

local AppPage = require(LuaApp.AppPage)
local NavigateDown = require(LuaApp.Thunks.NavigateDown)

local GAME_BUTTON_SIZE = 94
local GAME_ICON_SIZE = 90
local COMPACT_PADDING = 15
local WIDE_PADDING = 12
local GAME_NAME_LABEL_HEIGHT = 40
local SEPARATOR_HEIGHT = 1
local SEPARATOR_COLOR = Constants.Color.GRAY4

local GAME_TITLE_TOP_PADDING = 12
local GAME_TITLE_BOTTOM_PADDING = 24
local GAME_TITLE_COLOR = Constants.Color.GRAY1

local DEFAULT_BACKGROUND_COLOR = Constants.Color.WHITE
local DEFAULT_BUTTON_HEIGHT = 32
local DEFAULT_GAME_BACKGROUND_COLOR = Constants.Color.GRAY6
local DEFAULT_TEXT_FONT = Enum.Font.SourceSans
local DEFAULT_TEXT_SIZE = 20

local VIEW_GAME_DETAILS_FROM_ICON = Constants.AnalyticsKeyword.VIEW_GAME_DETAILS_FROM_ICON
local VIEW_GAME_DETAILS_FROM_TITLE = Constants.AnalyticsKeyword.VIEW_GAME_DETAILS_FROM_TITLE

local TextMeasureTemporaryPatch = settings():GetFFlag("TextMeasureTemporaryPatch")

local UserActiveGame = Roact.PureComponent:extend("UserActiveGame")

local FlagSettings = require(Modules.LuaApp.FlagSettings)
local useNewAppStyle = FlagSettings.UseNewAppStyle()

UserActiveGame.defaultProps = {
	gameThumbnail = Constants.DEFAULT_GAME_ICON,
}

local function Separator(props)
	local layoutOrder = props.layoutOrder

	return Roact.createElement("Frame", {
		BackgroundColor3 = SEPARATOR_COLOR,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, SEPARATOR_HEIGHT),
	})
end

-- Right now, game name is the place name
-- Both present API and multiget-place-details doesn't return game name
local function getGameName(universePlaceInfo, friend)
	if universePlaceInfo then
		return universePlaceInfo.name
	end

	local lastLocation = friend and friend.lastLocation
	if lastLocation then
		return lastLocation
	end

	return ""
end

function UserActiveGame:init()
	self.openGameDetails = function(fromWhere)
		local universePlaceInfo = self.props.universePlaceInfo

		-- If game data is not ready, do nothing.
		if not universePlaceInfo then
			return
		end

		local analytics = self.props.analytics
		local friend = self.props.friend
		local index = self.props.index
		local dismissContextualMenu = self.props.dismissContextualMenu
		local featureContext = self.props.featureContext

		local rootPlaceId = universePlaceInfo.universeRootPlaceId

		local universeId = convertUniverseIdToString(self.props.universeId)
		local navigateDown = self.props.navigateDown

		if featureContext == FeatureContext.PeopleList then
			analytics.reportViewProfileFromPeopleList(friend.id, index, rootPlaceId, fromWhere)
		end

		if dismissContextualMenu then
			dismissContextualMenu()
		end

		navigateDown({
			name = AppPage.GameDetail,
			detail = universeId
		})
	end

	self.getGameTitleHeight = function(text, font, textSize, maxWidth)
		local gameTitleHeight = Text.GetTextHeight(text, font, textSize, maxWidth)

		-- TODO(CLIPLAYEREX-1633): We can remove this padding patch after fixing TextService:GetTextSize sizing bug
		-- When the flag TextMeasureTemporaryPatch is on, Text.GetTextHeight() would add 2px to the total height
		-- For getting the correct height, 2px need to subtracting from here.
		if TextMeasureTemporaryPatch then
			gameTitleHeight = gameTitleHeight - 2
		end

		return math.min(GAME_NAME_LABEL_HEIGHT, gameTitleHeight)
	end
end

function UserActiveGame:createGameNameButton(height, gameName, textXAlignment, textYAlignment, stylePalette)
	local textColor = GAME_TITLE_COLOR
	local textTransparency = 0
	local textSize = DEFAULT_TEXT_SIZE
	local textFont = DEFAULT_TEXT_FONT

	if stylePalette then
		local theme = stylePalette.Theme
		local font = stylePalette.Font
		textColor = theme.TextEmphasis.Color
		textTransparency = theme.TextEmphasis.Transparency
		textSize = font.BaseSize * font.Header2.RelativeSize
		textFont = font.Header2.Font
	end

	return Roact.createElement("TextButton", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = textFont,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, height),
		Text = gameName,
		TextColor3 = textColor,
		TextTransparency = textTransparency,
		TextSize = textSize,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		TextXAlignment = textXAlignment,
		TextYAlignment = textYAlignment,

		[Roact.Event.Activated] = function()
			self.openGameDetails(VIEW_GAME_DETAILS_FROM_TITLE)
		end,
	})
end

function UserActiveGame:renderPhone(stylePalette)
	local layoutOrder = self.props.layoutOrder
	local width = self.props.width
	local universeId = self.props.universeId
	local friend = self.props.friend
	local index = self.props.index
	local dismissContextualMenu = self.props.dismissContextualMenu
	local featureContext = self.props.featureContext
	local gameThumbnail = self.props.gameThumbnail
	local universePlaceInfo = self.props.universePlaceInfo
	local headerRef = self.props[Roact.Ref]

	local gameName = getGameName(universePlaceInfo, friend)
	local backgroundColor = DEFAULT_BACKGROUND_COLOR
	local backgroundTransparency = 0
	local gameIconBackgroundColor = gameThumbnail and DEFAULT_BACKGROUND_COLOR or DEFAULT_GAME_BACKGROUND_COLOR
	local gameIconBackgroundTransparency = 0

	local maxWidth = width - 2 * COMPACT_PADDING
	local gameNameHeight = self.getGameTitleHeight(gameName, DEFAULT_TEXT_FONT, DEFAULT_TEXT_SIZE, maxWidth)
	local iconPadding = (GAME_BUTTON_SIZE - GAME_ICON_SIZE) / 2
	local widthOffset = -2 * COMPACT_PADDING

	if stylePalette then
		local theme = stylePalette.Theme

		backgroundColor = theme.BackgroundUIDefault.Color
		backgroundTransparency = theme.BackgroundUIDefault.Transparency

		gameIconBackgroundColor = gameThumbnail and backgroundColor or theme.PlaceHolder.Color
		gameIconBackgroundTransparency = gameThumbnail and backgroundTransparency or theme.PlaceHolder.Transparency
	end

	return Roact.createElement(FitChildren.FitImageButton, {
		BackgroundTransparency = 1,
		fitAxis = FitChildren.FitAxis.Height,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		AutoButtonColor = false,
		[Roact.Ref] = headerRef,
	}, {
		GameContent = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			fitAxis = FitChildren.FitAxis.Height,
			Size = UDim2.new(1, 0, 0, 0),
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			GameIcon = Roact.createElement("Frame", {
				BackgroundColor3 = gameIconBackgroundColor,
				BackgroundTransparency = gameIconBackgroundTransparency,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.new(0, GAME_BUTTON_SIZE, 0, GAME_BUTTON_SIZE),
			}, {
				Icon = Roact.createElement(ImageSetButton, {
					BackgroundColor3 = gameIconBackgroundColor,
					BorderSizePixel = 0,
					Image = gameThumbnail,
					Position = UDim2.new(0, iconPadding, 0, iconPadding),
					Size = UDim2.new(0, GAME_ICON_SIZE, 0, GAME_ICON_SIZE),

					[Roact.Event.Activated] = function()
						self.openGameDetails(VIEW_GAME_DETAILS_FROM_ICON)
					end,
				}),
			}),

			GameName = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				fitAxis = FitChildren.FitAxis.Height,
				LayoutOrder = 2,
				Size = UDim2.new(1, widthOffset, 0, 0),
			},{
				Layout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				NameButton = self:createGameNameButton(
					gameNameHeight,
					gameName,
					Enum.TextXAlignment.Center,
					Enum.TextYAlignment.Center,
					stylePalette
				),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, GAME_TITLE_TOP_PADDING),
				}),
			}),

			InteractiveButton = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				fitAxis = FitChildren.FitAxis.Height,
				LayoutOrder = 3,
				Size = UDim2.new(1, widthOffset, 0, 0),
			},{
				Layout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, GAME_TITLE_BOTTOM_PADDING),
				}),

				Button = Roact.createElement(GameButton, {
					maxWidth = maxWidth,
					showLoadingIndicatorWhenDataNotReady = true,
					universeId = universeId,
					friend = friend,
					index = index,
					callbackOnOpenGameDetails = dismissContextualMenu,
					callbackOnJoinGame = dismissContextualMenu,
					featureContext = featureContext,
				}),
			}),

			Separator = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				LayoutOrder = 5,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Line = Roact.createElement(Separator, {
					layoutOrder = 2,
				}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, GAME_TITLE_BOTTOM_PADDING - SEPARATOR_HEIGHT),
				})
			}),
		}),

		Background = Roact.createElement("Frame", {
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = backgroundTransparency,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, -GAME_BUTTON_SIZE / 2),
			Position = UDim2.new(0, 0, 0, GAME_BUTTON_SIZE / 2),
		}),
	})
end

function UserActiveGame:renderTablet(stylePalette)
	local layoutOrder = self.props.layoutOrder
	local width = self.props.width
	local universeId = self.props.universeId
	local friend = self.props.friend
	local index = self.props.index
	local dismissContextualMenu = self.props.dismissContextualMenu
	local featureContext = self.props.featureContext
	local gameThumbnail = self.props.gameThumbnail
	local universePlaceInfo = self.props.universePlaceInfo
	local headerRef = self.props[Roact.Ref]

	local gameName = getGameName(universePlaceInfo, friend)
	local backgroundColor = DEFAULT_BACKGROUND_COLOR
	local backgroundTransparency = 0
	local gameIconBackgroundColor = gameThumbnail and DEFAULT_BACKGROUND_COLOR or DEFAULT_GAME_BACKGROUND_COLOR
	local gameIconBackgroundTransparency = 0

	local maxWidth = width - 3 * WIDE_PADDING - GAME_ICON_SIZE
	local buttonTopPadding = GAME_ICON_SIZE - GAME_NAME_LABEL_HEIGHT - DEFAULT_BUTTON_HEIGHT

	if stylePalette then
		local theme = stylePalette.Theme

		backgroundColor = theme.BackgroundUIDefault.Color
		backgroundTransparency = theme.BackgroundUIDefault.Transparency

		gameIconBackgroundColor = gameThumbnail and backgroundColor or theme.PlaceHolder.Color
		gameIconBackgroundTransparency = gameThumbnail and backgroundTransparency or theme.PlaceHolder.Transparency
	end

	return Roact.createElement(FitChildren.FitImageButton, {
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
		fitAxis = FitChildren.FitAxis.Height,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(0, width, 0, 0),
		AutoButtonColor = false,
		[Roact.Ref] = headerRef,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		GameContent = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			fitAxis = FitChildren.FitAxis.Height,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
		},{
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, WIDE_PADDING),
				PaddingLeft = UDim.new(0, WIDE_PADDING),
				PaddingRight = UDim.new(0, WIDE_PADDING),
				PaddingBottom = UDim.new(0, WIDE_PADDING - 1),
			}),

			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, COMPACT_PADDING),
			}),

			GameIcon = Roact.createElement(ImageSetButton, {
				BackgroundColor3 = gameIconBackgroundColor,
				BackgroundTransparency = gameIconBackgroundTransparency,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Image = gameThumbnail,
				Size = UDim2.new(0, GAME_ICON_SIZE, 0, GAME_ICON_SIZE),

				[Roact.Event.Activated] = function()
					self.openGameDetails(VIEW_GAME_DETAILS_FROM_ICON)
				end,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, WIDE_PADDING),
				}),
			}),

			GameInfo = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				fitAxis = FitChildren.FitAxis.Height,
				LayoutOrder = 2,
				Size = UDim2.new(1, -COMPACT_PADDING - GAME_ICON_SIZE, 0, 0),
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				NameButton = self:createGameNameButton(
					GAME_NAME_LABEL_HEIGHT,
					gameName,
					Enum.TextXAlignment.Left,
					Enum.TextYAlignment.Top,
					stylePalette
				),

				InteractiveButton = Roact.createElement(FitChildren.FitFrame, {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 2,
					fitAxis = FitChildren.FitAxis.Height,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
					}),

					Button = Roact.createElement(GameButton, {
						layoutOrder = 3,
						maxWidth = maxWidth,
						showLoadingIndicatorWhenDataNotReady = true,
						universeId = universeId,
						friend = friend,
						index = index,
						callbackOnOpenGameDetails = dismissContextualMenu,
						callbackOnJoinGame = dismissContextualMenu,
						featureContext = featureContext,
					}),

					Padding = Roact.createElement("UIPadding", {
						PaddingTop = UDim.new(0, buttonTopPadding),
					}),
				}),
			}),
		}),

		Separator = Roact.createElement(Separator, {
			layoutOrder = 2,
		}),
	})
end

function UserActiveGame:render()
	local formFactor = self.props.formFactor

	local renderFunction = function(stylePalette)
		if formFactor == FormFactor.COMPACT then
			return self:renderPhone(stylePalette)
		else
			return self:renderTablet(stylePalette)
		end
	end

	if useNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction(nil)
	end
end

UserActiveGame = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local universeId = convertUniverseIdToString(props.universeId)

		return {
			formFactor = state.FormFactor,
			gameThumbnail = state.GameThumbnails[universeId],
			universePlaceInfo = state.UniversePlaceInfos[universeId],
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(UserActiveGame)

UserActiveGame = RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
	guiService = AppGuiService,
})(UserActiveGame)

return UserActiveGame
