local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AppPage = require(Modules.LuaApp.AppPage)

local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)
local LoadingSkeleton = require(Modules.LuaApp.Components.LoadingSkeleton)

local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local TEXT_SIZE = 22
local TEXT_LINE_COUNT = 2
local TEXT_HEIGHT = TEXT_SIZE * TEXT_LINE_COUNT
local THUMBNAIL_TEXT_PADDING = 10

local NAME_LOADING_SKELETON_PADDING = 10
local NAME_LOADING_SKELETON_PANELS = {
	[1] = { Size = UDim2.new(0.8, 0, 0, 16) },
	[2] = { Size = UDim2.new(0.5, 0, 0, 16) },
}

local CLBGameTile = Roact.PureComponent:extend("CLBGameTile")

local function getHeight(width)
	return width + THUMBNAIL_TEXT_PADDING + TEXT_HEIGHT
end

function CLBGameTile:init()
	self.onActivated = function()
		self.props.navigateDown({ name = AppPage.GameDetail, detail = self.props.universeId })
	end

	self.createLoadingSkeletonLayout = function()
		return Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, NAME_LOADING_SKELETON_PADDING),
		})
	end
end

function CLBGameTile:render()
	local theme = self._context.AppTheme
	local width = self.props.width
	local layoutOrder = self.props.LayoutOrder
	local thumbnail = self.props.thumbnail
	local name = self.props.name

	local height = getHeight(width)
	local textPosition = width + THUMBNAIL_TEXT_PADDING

	-- TODO: [MOBLUAPP-1246] Add onPress animation for the cards.
	return Roact.createElement("TextButton", {
		Size = UDim2.new(0, width, 0, height),
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		[Roact.Event.Activated] = self.onActivated,
	}, {
		Thumbnail = Roact.createElement(LoadableImage, {
			Size = UDim2.new(0, width, 0, width),
			Image = thumbnail,
			BackgroundColor3 = theme.ShimmerPanel.Color,
			BackgroundTransparency = theme.ShimmerPanel.Transparency,
			useShimmerAnimationWhileLoading = true,
		}),
		Name = (name == nil) and Roact.createElement(LoadingSkeleton, {
			Size = UDim2.new(1, 0, 0, TEXT_HEIGHT),
			Position = UDim2.new(0, 0, 0, textPosition),
			createLayout = self.createLoadingSkeletonLayout,
			panels = NAME_LOADING_SKELETON_PANELS,
		}) or Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, TEXT_HEIGHT),
			Position = UDim2.new(0, 0, 0, textPosition),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextSize = TEXT_SIZE,
			TextColor3 = theme.GameCard.Title.Color,
			Font = theme.GameCard.Title.Font,
			Text = name,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
		}),
	})
end

CLBGameTile = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameDetail = state.GameDetails[props.universeId]
		local gameIcon = state.GameIcons[props.universeId]

		return {
			thumbnail = gameIcon and gameIcon.url,
			name = gameDetail and gameDetail.name,
		}
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(CLBGameTile)

CLBGameTile.getHeight = getHeight

return CLBGameTile
