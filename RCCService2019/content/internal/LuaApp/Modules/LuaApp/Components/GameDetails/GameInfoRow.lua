local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local GameDetailsEvents = require(Modules.LuaApp.Analytics.Events.GameDetailsEvents)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local TransitionAnimation = require(Modules.LuaApp.Enum.TransitionAnimation)

local GameDetailsSubpageEvent = GameDetailsEvents.GameDetailsSubpage

local TEXT_SIZE = 22
local LINK_ARROW_PRE_SPACE = 11
local LINK_ARROW_IMAGE_SIZE = 14

local LINK_ARROW_IMAGE= "LuaApp/icons/GameDetails/navigation/pushRight_small"

local GameInfoRow = Roact.PureComponent:extend("GameInfoRow")

GameInfoRow.defaultProps = {
	leftPadding = 0,
	rightPadding = 0,
}

function GameInfoRow:init()
	self.infoNameTextLabelRef = Roact.createRef()

	self.state = {
		buttonPressed = false,
	}

	self.onInputBegan = function(_, inputObject)
		if inputObject.UserInputState == Enum.UserInputState.Begin and
			(inputObject.UserInputType == Enum.UserInputType.Touch or
			inputObject.UserInputType == Enum.UserInputType.MouseButton1) then
			if not self.state.buttonPressed then
				self:setState({
					buttonPressed = true,
				})
			end
		end
	end

	self.onInputEnded = function()
		if self.state.buttonPressed then
			self:setState({
				buttonPressed = false,
			})
		end
	end

	self.onActivated = function()
		local linkPage = self.props.linkPage
		if not linkPage then
			return
		end
		-- fire analytics event
		local analyticsEventStream = self.props.analytics.EventStream
		local placeId = self.props.placeId
		local subPageType = self.props.analyticsSubPage
		GameDetailsSubpageEvent(analyticsEventStream, "GameInfoRow", placeId, subPageType)
		-- open subpage
		local infoNameLocalized = self.infoNameTextLabelRef.current.Text

        self.props.navigateDown({
            name = AppPage.GenericWebPage,
            detail = linkPage,
            extraProps = {
                title = infoNameLocalized,
                transitionAnimation = TransitionAnimation.SlideInFromRight,
            },
        })
	end
end

function GameInfoRow:render()
	local gameDetailsTheme = self._context.AppTheme.GameDetails
	local rowTheme = gameDetailsTheme.GameInfoList.Cells
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local buttonPressed = self.state.buttonPressed

	local infoName = self.props.infoName
	local infoData = self.props.infoData
	local hasLink = self.props.linkPage ~= nil
	local leftPadding = self.props.leftPadding
	local rightPadding = self.props.rightPadding

	if not hasLink then
		buttonPressed = false
	end

	return Roact.createElement("ImageButton", {
		Size = size,
		Position = position,
		AutoButtonColor = false,
		LayoutOrder = layoutOrder,
		BorderSizePixel = 0,
		BackgroundTransparency = buttonPressed and
			rowTheme.Background.Transparency.Pressed or rowTheme.Background.Transparency.Default,
		BackgroundColor3 = rowTheme.Background.Color,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		[Roact.Event.Activated] = self.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, leftPadding),
			PaddingRight = UDim.new(0, rightPadding),
		}),
		InfoNameTextLabel = Roact.createElement(LocalizedTextLabel, {
			Size = UDim2.new(0.5, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = gameDetailsTheme.Text.Font,
			TextColor3 = gameDetailsTheme.Text.Color.Secondary,
			Text = infoName,
			TextSize = TEXT_SIZE,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			[Roact.Ref] = self.infoNameTextLabelRef,
		}),
		InfoDataTextLabel = Roact.createElement("TextLabel", {
			Size = UDim2.new(0.5, 0, 1, 0),
			Position = UDim2.new(0.5, hasLink and (- LINK_ARROW_PRE_SPACE - LINK_ARROW_IMAGE_SIZE) or 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = gameDetailsTheme.Text.Font,
			TextColor3 = gameDetailsTheme.Text.Color.Main,
			Text = infoData,
			TextSize = TEXT_SIZE,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Center,
		}),
		LinkArrow = hasLink and Roact.createElement(ImageSetLabel, {
			Size = UDim2.new(0, LINK_ARROW_IMAGE_SIZE, 0, LINK_ARROW_IMAGE_SIZE),
			Position = UDim2.new(1, - LINK_ARROW_IMAGE_SIZE, 0.5, - LINK_ARROW_IMAGE_SIZE / 2),
			Image = LINK_ARROW_IMAGE,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}),
	})
end

GameInfoRow = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			navigateDown = function(page)
				return dispatch(NavigateDown(page))
			end
		}
	end
)(GameInfoRow)

return RoactServices.connect({
	analytics = RoactAnalytics,
})(GameInfoRow)
