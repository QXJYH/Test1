local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local abbreviateCount = require(Modules.LuaApp.abbreviateCount)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactLocalization = require(Modules.LuaApp.Services.RoactLocalization)
local RoactNetworking = require(Modules.LuaApp.Services.RoactNetworking)
local RoactAnalytics = require(Modules.LuaApp.Services.RoactAnalytics)
local ReasonForNotVoteable = require(Modules.LuaApp.Enum.ReasonForNotVoteable)
local RetrievalStatus = require(Modules.LuaApp.Enum.RetrievalStatus)
local ToastType = require(Modules.LuaApp.Enum.ToastType)
local VoteStatus = require(Modules.LuaApp.Enum.VoteStatus)

local SetCurrentToastMessage = require(Modules.LuaApp.Actions.SetCurrentToastMessage)
local FetchGameVotes = require(Modules.LuaApp.Thunks.FetchGameVotes)
local FetchUserGameVotes = require(Modules.LuaApp.Thunks.FetchUserGameVotes)
local PatchUserVotes = require(Modules.LuaApp.Thunks.PatchUserVotes)

local GenericIconButton = require(Modules.LuaApp.Components.GenericIconButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local PrimaryStatWidget = require(Modules.LuaApp.Components.PrimaryStatWidget)

local GameDetailsEvents = require(Modules.LuaApp.Analytics.Events.GameDetailsEvents)
local VoteEvent = GameDetailsEvents.Vote

local RATINGS_HEIGHT = 70
local ICON_SIZE = 44
local VOTE_ICON_SIZE = 36
local HORIZONTAL_PADDING = 10

local BACKGROUND_IMAGE_SLICE_CENTER = Rect.new(9, 9, 9, 9)

local BACKGROUND_IMAGE = "LuaApp/buttons/buttonFill"
local RATING_IMAGE = "LuaApp/icons/GameDetails/rating_large"

local VOTE_UP_OFF = "LuaApp/icons/GameDetails/voteUpOff"
local VOTE_UP_ON = "LuaApp/icons/GameDetails/voteUpOn"

local VOTE_DOWN_OFF = "LuaApp/icons/GameDetails/voteDownOff"
local VOTE_DOWN_ON = "LuaApp/icons/GameDetails/voteDownOn"

local GameRatings = Roact.PureComponent:extend("GameRatings")

function GameRatings:init()
	self.onVoteButtonActivated = function(vote)
		local universeId = self.props.universeId
		local networking = self.props.networking
		local rootPlaceId = self.props.rootPlaceId

		if not self.props.dataLoadSucceed then
			-- re-try if gameVotes is not available, otherwise patch request directly
			if self.props.gameVotesFetchingStatus == RetrievalStatus.Failed then
				self.props.dispatchFetchGameVotes(networking, universeId)
			else
				self.props.patchUserVotes(networking, universeId, vote, VoteStatus.NotVoted)
				VoteEvent(self.props.analytics.EventStream, "GameRatings", rootPlaceId, vote, VoteStatus.NotVoted)
			end
			return
		end

		local userGameVotes = self.props.userGameVotes
		local reasonForNotVoteable = userGameVotes.reasonForNotVoteable

		if userGameVotes.canVote then
			--PATCH vote
			local curVote = userGameVotes.userVote
			if curVote == vote then
				-- Clear current vote
				vote = VoteStatus.NotVoted
			end
			self.props.patchUserVotes(networking, universeId, vote, curVote)
			VoteEvent(self.props.analytics.EventStream, "GameRatings", rootPlaceId, vote, curVote)
		elseif reasonForNotVoteable == ReasonForNotVoteable.PlayGame then
			self.props.setCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = "Feature.Toast.VoteError.PlayGame",
			})
		elseif reasonForNotVoteable == ReasonForNotVoteable.FloodCheckThresholdMet then
			self.props.setCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = "Feature.Toast.VoteError.FloodCheckThresholdMet",
			})
		elseif reasonForNotVoteable == ReasonForNotVoteable.AssetNotVoteable then
			self.props.setCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = "Feature.Toast.VoteError.AssetNotVoteable",
			})
		else
			self.props.setCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = "Feature.Toast.VoteError.Default",
			})
		end
	end

	self.onVoteUpActivated = function()
		self.onVoteButtonActivated(VoteStatus.VotedUp)
	end

	self.onVoteDownActivated = function()
		self.onVoteButtonActivated(VoteStatus.VotedDown)
	end
end

function GameRatings:render()
	local theme = self._context.AppTheme

	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder

	local width = self.props.width
	local gameVotes = self.props.gameVotes
	local userGameVotes = self.props.userGameVotes
	local gameVotesFetchingStatus = self.props.gameVotesFetchingStatus
	local isLoading = self.props.isLoading
	local dataLoadSucceed = self.props.dataLoadSucceed

	local localization = self.props.localization

	local upVotes = gameVotes and gameVotes.upVotes or 0
	local downVotes = gameVotes and gameVotes.downVotes or 0

	local totalVotes = upVotes + downVotes
	local totalVotesText = gameVotesFetchingStatus == RetrievalStatus.Done and
		abbreviateCount(totalVotes, localization:GetLocale()) or "--"
	totalVotesText = string.upper(localization:Format("Feature.GameDetails.Label.Votes", { votes = totalVotesText }))

	local votePercentageText = totalVotes > 0 and tostring(math.floor((upVotes / totalVotes) * 100)) .. "%" or "--"

	local userVote = dataLoadSucceed and userGameVotes and userGameVotes.userVote

	return Roact.createElement(ImageSetLabel, {
		Size = UDim2.new(0, width, 0, RATINGS_HEIGHT),
		Position = position,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = BACKGROUND_IMAGE,
		ImageColor3 = theme.GameDetails.Rating.Background.Color,
		ImageTransparency = theme.GameDetails.Rating.Background.Transparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = BACKGROUND_IMAGE_SLICE_CENTER,
	}, {
		RatingsStat = Roact.createElement(PrimaryStatWidget, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			icon = RATING_IMAGE,
			number = votePercentageText,
			label = totalVotesText,
			font = theme.GameDetails.Text.BoldFont,
			color = theme.GameDetails.Text.Color.Main,
			width = width - ICON_SIZE * 2 - HORIZONTAL_PADDING * 3,
		}),
		VoteUp = Roact.createElement(GenericIconButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -HORIZONTAL_PADDING, 0.5, 0),
			Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
			iconImage = userVote == VoteStatus.VotedUp and VOTE_UP_ON or VOTE_UP_OFF,
			iconSize = UDim2.new(0, VOTE_ICON_SIZE, 0, VOTE_ICON_SIZE),
			isChecked = userVote == VoteStatus.VotedUp,
			isLoading = isLoading,
			onActivated = self.onVoteUpActivated,
		}),
		VoteDown = Roact.createElement(GenericIconButton, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -HORIZONTAL_PADDING * 2 - ICON_SIZE, 0.5, 0),
			Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
			iconImage = userVote == VoteStatus.VotedDown and VOTE_DOWN_ON or VOTE_DOWN_OFF,
			iconSize = UDim2.new(0, VOTE_ICON_SIZE, 0, VOTE_ICON_SIZE),
			isChecked = userVote == VoteStatus.VotedDown,
			isLoading = isLoading,
			onActivated = self.onVoteDownActivated,
		}),
	})
end

GameRatings = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local gameVotesFetchingStatus = FetchGameVotes.GetFetchingStatus(state, props.universeId)
		local userGameVotesFetchingStatus = FetchUserGameVotes.GetFetchingStatus(state, props.universeId)
		local userVotesPatchingStatus = PatchUserVotes.GetPatchingStatus(state, props.universeId)
		local gameVotes = state.GameVotes[props.universeId]
		local userGameVotes = state.UserGameVotes[props.universeId]
		local rootPlaceId = state.GameDetails[props.universeId].rootPlaceId

		return {
			gameVotes = gameVotes,
			userGameVotes = userGameVotes,
			rootPlaceId = rootPlaceId,
			gameVotesFetchingStatus = gameVotesFetchingStatus,
			isLoading = gameVotesFetchingStatus == RetrievalStatus.Fetching or
				userGameVotesFetchingStatus == RetrievalStatus.Fetching or
				userVotesPatchingStatus == RetrievalStatus.Fetching,
			dataLoadSucceed = gameVotes and userGameVotes,
		}
	end,
	function(dispatch)
		return {
			setCurrentToastMessage = function(toastMessage)
				return dispatch(SetCurrentToastMessage(toastMessage))
			end,
			dispatchFetchGameVotes = function(networking, universeId)
				return dispatch(FetchGameVotes.Fetch(networking, universeId))
			end,
			patchUserVotes = function(networking, universeId, vote, curVote)
				return dispatch(PatchUserVotes.Patch(networking, universeId, vote, curVote))
			end,
		}
	end
)(GameRatings)

return RoactServices.connect({
	localization = RoactLocalization,
	networking = RoactNetworking,
	analytics = RoactAnalytics,
})(GameRatings)
