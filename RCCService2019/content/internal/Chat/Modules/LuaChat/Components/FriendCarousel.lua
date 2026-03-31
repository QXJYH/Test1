--
-- FriendCarousel
--
-- This is a scrollable list of friend icons.
--

local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common

local FriendIcon = require(Modules.LuaApp.Components.FriendIcon)
local Roact = require(Common.Roact)
local RoactRodux = require(Common.RoactRodux)

local FriendCarousel = Roact.Component:extend("FriendCarousel")

local DEFAULT_DOT_SIZE = 8

local IMAGE_MASK = "rbxasset://textures/ui/LuaChat/graphic/friendmask.png"
local MASK_WIDTH = 10

function FriendCarousel:init()
	self.state = {
		fadeScrollLeft = false,
		fadeScrollRight = false,
	}
end

function FriendCarousel:onPositionChanged(rbx)
	-- Programatically show / hide the fade bars at either side of the carousel.
	-- This hides items that are partly visible, but completely reveals the
	-- first / last items when they're present.

	-- Early return if we're not set up yet:
	if (rbx.CanvasSize.X.Offset == 0) or (rbx.CanvasSize.Y.Offset == 0) or
		(rbx.AbsoluteWindowSize.X == 0) or (rbx.AbsoluteWindowSize.Y == 0) then
		return
	end

	local fadeLeft = (0 < rbx.CanvasPosition.X)
	local fadeRight = (rbx.CanvasSize.X.Offset - rbx.CanvasPosition.X) > rbx.AbsoluteWindowSize.X

	if (fadeLeft ~= self.state.fadeScrollLeft) or
		(fadeRight ~= self.state.fadeScrollRight) then
		spawn(function()
			self:setState({
				fadeScrollLeft = fadeLeft,
				fadeScrollRight = fadeRight,
			})
		end)
	end
end

function FriendCarousel:didMount()
	if self.rbxScroller then
		self:onPositionChanged(self.rbxScroller)
	end
end

function FriendCarousel:render()
	-- Visual properties of this game card:
	local dotSize = self.props.dotSize or DEFAULT_DOT_SIZE
	local friends = self.props.friends or {}
	local horizontalAlignment = self.props.HorizontalAlignment or Enum.HorizontalAlignment.Left
	local itemGap = self.props.itemGap
	local itemSize = self.props.itemSize
	local layoutOrder = self.props.LayoutOrder
	local size = self.props.Size or UDim2.new(1, 0, 0, itemSize)
	local users = self.props.users

	-- Build up a horizontal list of items for our card:
	local friendItems = {}
	friendItems["Layout"] = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = horizontalAlignment,
		Padding = UDim.new(0, itemGap),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	local countFriends = #friends
	if countFriends > 0 then
		for index, friend in ipairs(friends) do
			local userFriend = users[friend.uid]
			friendItems[index] = Roact.createElement(FriendIcon, {
				user = userFriend,
				dotSize = dotSize,
				itemSize = itemSize,
				layoutOrder = index,
			})
		end
	end

	local maskLeft = nil
	if self.state.fadeScrollLeft then
		maskLeft = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = IMAGE_MASK,
			Position = UDim2.new(0, 0, 0, 0),
			Rotation = 180,
			Size = UDim2.new(0, MASK_WIDTH, 1, 0),
			ZIndex = 2,
		})
	end

	local maskRight = nil
	if self.state.fadeScrollRight then
		maskRight = Roact.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = IMAGE_MASK,
			Position = UDim2.new(1, -MASK_WIDTH, 0, 0),
			Size = UDim2.new(0, MASK_WIDTH, 1, 0),
			ZIndex = 2,
		})
	end

	-- This frame arrangement adds a semi-transparent overlay to
	-- fade out items at the edge of the frame:
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,
		Position = UDim2.new(0, 0, 0, 0),
		Size = size,
	},{
		MaskLeft = maskLeft,

		MaskRight = maskRight,

		ScrollyFrame = Roact.createElement("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, (itemSize + itemGap) * countFriends, 0, itemSize),
			ClipsDescendants = true,
			ScrollBarThickness = 0,
			Size = UDim2.new(1, 0, 1, 0),
			[Roact.Change.AbsolutePosition] = function(rbx, changed)
				self:onPositionChanged(rbx)
			end,
			[Roact.Ref] = function(rbx)
				self.rbxScroller = rbx
			end,
		}, friendItems)
	})
end

FriendCarousel = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			users = state.Users,
		}
	end
)(FriendCarousel)

return FriendCarousel