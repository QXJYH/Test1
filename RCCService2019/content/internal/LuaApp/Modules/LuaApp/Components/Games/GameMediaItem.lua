local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)

local UIBlox = require(CorePackages.UIBlox)
local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem
local AnimatedItem = require(Modules.LuaApp.Components.Generic.AnimatedItem)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local LoadableImage = require(Modules.LuaApp.Components.LoadableImage)

local VIDEO_ICON_BACKGROUND = "rbxasset://textures/ui/LuaApp/graphic/playBtnBackground.png"
local VIDEO_ICON = "LuaApp/icons/GameDetails/play"
local VIDEO_ICON_PILL = "LuaApp/buttons/buttonPill"
local VIDEO_ICON_PILL_WIDTH = 60
local VIDEO_ICON_PILL_ASPECT = 90.0 / 120.0
local VIDEO_ICON_PILL_PADDING = 10
local VIDEO_ICON_SIZE = 26

local FFlagLuaAppUseUIBloxAccordion = require(script.Parent.Flags.LuaAppUseUIBloxAccordion)

local GameMediaItem = Roact.PureComponent:extend("GameMediaItem")

function GameMediaItem:init()
	local image = self.props.Image

	self.state = {
		loaded = LoadableImage.isLoaded(image),
	}

	self.isMounted = false

	self.onImageLoaded = function()
		if self.state.loaded == false and self.isMounted then
			self:setState({
				loaded = true,
			})

			if self.props.onImageLoaded then
				self.props.onImageLoaded()
			end
		end
	end
end

function GameMediaItem:didMount()
	self.isMounted = true
end

function GameMediaItem:willUnmount()
	self.isMounted = false
end

function GameMediaItem:render()
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local backgroundColor3 = self.props.BackgroundColor3
	local backgroundTransparency = self.props.BackgroundTransparency
	local image = self.props.Image
	local imageTransparency = self.props.ImageTransparency
	local isVideo = self.props.isVideo
	local videoIconColor = self.props.videoIconColor
	local animationSettings = self.props.animationSettings
	local onActivated = self.props.onActivated
	local loaded = self.state.loaded

	-- We want to only create loadable images when the item is supposed to be visible, so
	-- we don't preload images that are not on screen yet.
	local isVisible = imageTransparency ~= 1
	local useLoadableImage = isVisible and not loaded
	local drawVideoIcon = isVideo and isVisible
	local scaleType = isVideo and Enum.ScaleType.Crop or Enum.ScaleType.Stretch

	-- TODO When removing FFlagLuaAppUseUIBloxAccordion, inline the component
	-- where this variable is used.
	local animatedImage
	if FFlagLuaAppUseUIBloxAccordion then
		animatedImage = Roact.createElement(SpringAnimatedItem.AnimatedImageLabel, {
			regularProps = {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = image,
				ScaleType = scaleType,
				ZIndex = 1,
			},
			animatedValues = {
				transparency = imageTransparency
			},
			mapValuesToProps = function(values)
				return {
					ImageTransparency = values.transparency
				}
			end,
			springOptions = animationSettings
		})
	else
		animatedImage = Roact.createElement(AnimatedItem.AnimatedImageLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = image,
			ScaleType = scaleType,
			ZIndex = 1,
			animatedProps = {
				ImageTransparency = imageTransparency,
			},
			springOptions = animationSettings,
		})
	end

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = backgroundTransparency,
		BorderSizePixel = 0,
	}, {
		MediaImage = useLoadableImage and Roact.createElement(LoadableImage, {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = image,
			ImageTransparency = imageTransparency,
			ScaleType = scaleType,
			ZIndex = 1,
			useShimmerAnimationWhileLoading = true,
			onLoaded = self.onImageLoaded,
		}) or animatedImage,
		VideoIconBackground = drawVideoIcon and Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Image = VIDEO_ICON_BACKGROUND,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			VideoIcon = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(1, 1),
				Size = UDim2.new(0, VIDEO_ICON_PILL_WIDTH, 0, VIDEO_ICON_PILL_WIDTH * VIDEO_ICON_PILL_ASPECT),
				Position = UDim2.new(1, -VIDEO_ICON_PILL_PADDING, 1, -VIDEO_ICON_PILL_PADDING),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = VIDEO_ICON_PILL,
				ImageColor3 = videoIconColor,
				ImageTransparency = 0.5,
			}, {
				Icon = Roact.createElement(ImageSetLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.new(0, VIDEO_ICON_SIZE, 0, VIDEO_ICON_SIZE),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = VIDEO_ICON,
					ImageColor3 = videoIconColor,
					ScaleType = Enum.ScaleType.Fit,
				}),
			}),
		}),
		ItemActivationButton = (onActivated ~= nil) and Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			ZIndex = 3,
			[Roact.Event.Activated] = onActivated,
		})
	})
end

return GameMediaItem