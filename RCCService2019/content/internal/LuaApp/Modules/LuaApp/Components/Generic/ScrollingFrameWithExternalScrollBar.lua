local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local UserInputService = game:GetService("UserInputService")

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)

local FitChildren = require(Modules.LuaApp.FitChildren)

local function getDevicePlatform()
	if _G.__TESTEZ_RUNNING_TEST__ then
		return Enum.Platform.None
	end

	return UserInputService:GetPlatform()
end

-- The platform data in the store is overwritten to IOS in RobloxStudio by LuaChat code,
-- which makes debugging this component in Studio difficult. So I'm getting the device
-- on my own here.
local DEVICE_PLATFORM = getDevicePlatform()
local IS_DESKTOP_DEVICE = (DEVICE_PLATFORM == Enum.Platform.Windows or DEVICE_PLATFORM == Enum.Platform.OSX)

-- When using scroll bar in a normal Roblox scrolling frame,
-- the scroll bar is included in the "size" and "position" of the scrolling frame.
-- This component creates a scrolling frame without counting the scroll bar into
-- its size and position properties.
-- (only supports vertical scrolling frame now.)
local ScrollingFrameWithExternalScrollBar = Roact.PureComponent:extend("ScrollingFrameWithExternalScrollBar")

ScrollingFrameWithExternalScrollBar.defaultProps = {
	BorderSizePixel = 0,
	scrollBarPositionOffsetX = 0,
	onlyRenderScrollBarOnHover = false,
}

function ScrollingFrameWithExternalScrollBar:init()
	self.state = {
		hover = false,
	}
end

function ScrollingFrameWithExternalScrollBar:render()
	local size = self.props.Size
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local zIndex = self.props.ZIndex
	local scrollBarThickness = self.props.ScrollBarThickness
	local scrollBarPositionOffsetX = self.props.scrollBarPositionOffsetX
	local onlyRenderScrollBarOnHover = self.props.onlyRenderScrollBarOnHover

	local hover = self.state.hover

	local scrollBarTotalSize = scrollBarThickness + scrollBarPositionOffsetX
	local renderScrollBar = not onlyRenderScrollBarOnHover or (onlyRenderScrollBarOnHover and hover)

	local scrollingFrameProps = Cryo.Dictionary.join(self.props, {
		scrollBarPositionOffsetX = Cryo.None,
		onlyRenderScrollBarOnHover = Cryo.None,
		ZIndex = Cryo.None,
		Size = UDim2.new(1, scrollBarTotalSize, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		ScrollBarThickness = renderScrollBar and scrollBarThickness or 0,
		fitFields = {
			CanvasSize = FitChildren.FitAxis.Height,
		},
		-- MouseEnter and MouseLeave events get triggered on mobile devices when we press/release
		-- the scrolling frame. So we need to do a platform check here.
		-- This issue has been reported as CLIPLAYEREX-2700.
		[Roact.Event.MouseEnter] = function()
			if IS_DESKTOP_DEVICE then
				self:setState({
					hover = true,
				})
			end
		end,
		[Roact.Event.MouseLeave] = function()
			if IS_DESKTOP_DEVICE then
				self:setState({
					hover = false,
				})
			end
		end,
	})

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		BackgroundTransparency = 1,
		ClipsDescendants = false,
	}, {
		ScrollingFrame = Roact.createElement(FitChildren.FitScrollingFrame, scrollingFrameProps)
	})
end

return ScrollingFrameWithExternalScrollBar