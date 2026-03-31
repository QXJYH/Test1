local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local Constants = require(Modules.LuaApp.Constants)

local BackgroundWithMask = Roact.PureComponent:extend("BackgroundWithMask")

local BACKGROUND_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/CityBackground.png"
local BACKGROUND_MASK_IMAGE_WIDE = "rbxasset://textures/ui/LuaApp/graphic/WideView_purpleLayer.png"
local BACKGROUND_MASK_IMAGE_COMPACT = "rbxasset://textures/ui/LuaApp/graphic/CompactView_purplelayer.png"

local LOGO_SIZE = Constants.HomePageLogoSize

BackgroundWithMask.defaultProps = {
	safeAreaPositionY = 0,
}

function BackgroundWithMask:render()
	local formFactor = self.props.formFactor
	local screenSize = self.props.screenSize
	local safeAreaPositionY = self.props.safeAreaPositionY
	local zIndex = self.props.zIndex

	local backgroundAnchorPoint
	local backgroundPosition
	local backgroundSize
	local backgroundSizeConstraint
	local backgroundScaleType
	local backgroundMaskImage
	local backgroundMaskSize

	if formFactor == FormFactor.COMPACT then
		--[[
			For Compact view, the height of the square background image is determined with the following:
				Screen Width
				Space for the logo/top bar at the top, and same at the bottom for balance.
				App wide Safe Area buffer for status bar and such.
		--]]
		local backgroundAbsoluteSize = screenSize.X + LOGO_SIZE.Y * 2 + safeAreaPositionY
		backgroundAnchorPoint = Vector2.new(0.5, 0)
		backgroundPosition = UDim2.new(0.5, 0, 0, 0)
		backgroundSize = UDim2.new(0, backgroundAbsoluteSize, 0, backgroundAbsoluteSize)
		backgroundSizeConstraint = Enum.SizeConstraint.RelativeXY
		backgroundScaleType = Enum.ScaleType.Stretch
		backgroundMaskImage = BACKGROUND_MASK_IMAGE_COMPACT
		backgroundMaskSize = UDim2.new(1, 0, 1, 0) -- Same with image size
	else
		backgroundAnchorPoint = Vector2.new(0.5, 0.5)
		backgroundPosition = UDim2.new(0.5, 0, 0.5, 0)
		backgroundSize = UDim2.new(1, 0, 1, 0)
		backgroundScaleType = Enum.ScaleType.Crop
		backgroundMaskImage = BACKGROUND_MASK_IMAGE_WIDE
		backgroundMaskSize = UDim2.new(0, screenSize.X, 0, screenSize.Y) -- Exactly cover full screen
		if screenSize.X <= screenSize.Y then
			 -- Actual backgroundSize might be bigger than full screen depending on the height
			backgroundSizeConstraint = Enum.SizeConstraint.RelativeYY
		else
			 -- Actual backgroundSize will be bigger than full screen depending on the width
			backgroundSizeConstraint = Enum.SizeConstraint.RelativeXX
		end
	end

	return Roact.createElement("ImageLabel", {
		ZIndex = zIndex,
		Size = backgroundSize,
		BorderSizePixel = 0,
		Image = BACKGROUND_IMAGE,
		ScaleType = backgroundScaleType,
		SizeConstraint = backgroundSizeConstraint,
		BackgroundTransparency = 0,
		Position = backgroundPosition,
		AnchorPoint = backgroundAnchorPoint,
	}, {
		Roact.createElement("ImageLabel", {
			Size = backgroundMaskSize,
			BorderSizePixel = 0,
			Image = backgroundMaskImage,
			BackgroundTransparency = 1,
			Position = backgroundPosition,
			AnchorPoint = backgroundAnchorPoint,
			ScaleType = Enum.ScaleType.Stretch,
		}),
	})
end

BackgroundWithMask = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
		}
	end
)(BackgroundWithMask)

return BackgroundWithMask
