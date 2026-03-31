local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalyticsHomePage = require(Modules.LuaApp.Services.RoactAnalyticsHomePage)
local AppGuiService = require(Modules.LuaApp.Services.AppGuiService)

local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)

local AddFriendsTile = Roact.PureComponent:extend("AddFriendsTile")

local EVENT_CONTEXT = "addUniversalFriends"
local BUTTON_NAME = "AddFriendsButton"

local ADD_FRIEND_TILE_STROKE = "LuaApp/graphic/addfriendborder"
local ADD_FRIEND_TILE_FILL = "LuaApp/graphic/addfriendfill"
local ADD_FRIEND_ICON = "LuaApp/graphic/common_add"

function AddFriendsTile:init()
	self.onActivated = function()
		local navigateDown = self.props.navigateDown
		self.props.analytics.reportButtonClicked(EVENT_CONTEXT, BUTTON_NAME)
		navigateDown({
			name = AppPage.AddFriends,
		})
	end
end

function AddFriendsTile:render()
	local thumbnailSize = self.props.thumbnailSize
	local width = self.props.totalWidth
	local height = self.props.totalHeight
	local layoutOrder = self.props.layoutOrder

	local renderFunction = function(stylePalette)
		local addButtonFillColor = stylePalette.Theme.UIEmphasis.Color
		local addButtonFillTransparency = stylePalette.Theme.UIEmphasis.Transparency
		local addButtonBoarderColor = stylePalette.Theme.SecondaryDefault.Color
		local addButtonBoarderTransparency = stylePalette.Theme.SecondaryDefault.Transparency
		local addIconColor = stylePalette.Theme.IconEmphasis.Color
		local addIconTransparency = stylePalette.Theme.IconEmphasis.Transparency

		return Roact.createElement("Frame", {
			Size = UDim2.new(0, width, 0, height),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			AddFriendButton = Roact.createElement(ImageSetButton, {
				Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
				BackgroundTransparency = 1,
				Image = ADD_FRIEND_TILE_FILL,
				ImageColor3 = addButtonFillColor,
				ImageTransparency = addButtonFillTransparency,
				[Roact.Event.Activated] = self.onActivated,
			}, {
				AddFriendButtonBorder = Roact.createElement(ImageSetLabel, {
					Size = UDim2.new(0, thumbnailSize, 0, thumbnailSize),
					BackgroundTransparency = 1,
					Image = ADD_FRIEND_TILE_STROKE,
					ImageColor3 = addButtonBoarderColor,
					ImageTransparency = addButtonBoarderTransparency,
				}, {
					AddIcon = Roact.createElement(ImageSetLabel, {
						Size = UDim2.new(0.45, 0, 0.45, 0),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						Image = ADD_FRIEND_ICON,
						ImageColor3 = addIconColor,
						ImageTransparency = addIconTransparency,
					}),
				}),
			}),
		})
	end

	return withStyle(renderFunction)
end

AddFriendsTile = RoactRodux.UNSTABLE_connect2(
	nil,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(AddFriendsTile)

AddFriendsTile = RoactServices.connect({
	analytics = RoactAnalyticsHomePage,
	guiService = AppGuiService,
})(AddFriendsTile)

return AddFriendsTile