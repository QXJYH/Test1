local ContentProvider = game:GetService("ContentProvider")
local FFlagFixLoadableImageDoesNotLoadCachedImage = settings():GetFFlag("FixLoadableImageDoesNotLoadCachedImage")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local Roact = require(Modules.Common.Roact)

local ShimmerAnimation = require(Modules.LuaApp.Components.ShimmerAnimation)

local decal = Instance.new("Decal")

local loadedImagesByUri = {}

local LoadableImage = Roact.PureComponent:extend("LoadableImage")

LoadableImage.defaultProps = {
	useShimmerAnimationWhileLoading = false,
	ScaleType = Enum.ScaleType.Stretch,
}

function LoadableImage:init()
	self.state = {
		loaded = loadedImagesByUri[self.props.Image],
	}

	self._isMounted = false
end

function LoadableImage:render()
	local size = self.props.Size
	local position = self.props.Position
	local borderSizePixel = self.props.BorderSizePixel
	local backgroundColor3 = self.props.BackgroundColor3
	local backgroundTransparency = self.props.BackgroundTransparency
	local scaleType = self.props.ScaleType
	local zIndex = self.props.ZIndex
	local image = self.props.Image
	local loadingImage = self.props.loadingImage
	local useShimmerAnimationWhileLoading = self.props.useShimmerAnimationWhileLoading
	local loaded = self.state.loaded
	local shimmerPanelTheme = self._context.AppTheme.ShimmerPanel

	if not loaded and useShimmerAnimationWhileLoading then
		return Roact.createElement("Frame", {
			Position = position,
			BorderSizePixel = borderSizePixel,
			BackgroundColor3 = shimmerPanelTheme.Color,
			BackgroundTransparency = shimmerPanelTheme.Transparency,
			ZIndex = zIndex,
			Size = size,
		}, {
			Shimmer = Roact.createElement(ShimmerAnimation, {
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
	else
		return Roact.createElement("ImageLabel", {
			Position = position,
			BorderSizePixel = borderSizePixel,
			BackgroundColor3 = backgroundColor3,
			BackgroundTransparency = backgroundTransparency,
			ScaleType = scaleType,
			ZIndex = zIndex,
			Size = size,
			Image = loaded and image or loadingImage,
		})
	end
end

-- NOTE iconCardList relies on this behavior (image == "")
function LoadableImage:shouldLoadImage(image)
	return image ~= nil and image ~= "" and not loadedImagesByUri[image]
end

function LoadableImage:didUpdate(oldProps)
	-- If the image changed, reload
	if oldProps.Image ~= self.props.Image then
		self:_loadImage()
	end
end

function LoadableImage:didMount()
	self._isMounted = true

	self:_loadImage()
end

function LoadableImage:willUnmount()
	self._isMounted = false
end

function LoadableImage:_loadImage()
	local image = self.props.Image

	if self:shouldLoadImage(image) then
		if self.state.loaded then
			self:setState({
				loaded = false
			})
		end
	else
		if FFlagFixLoadableImageDoesNotLoadCachedImage then
			if loadedImagesByUri[image] and not self.state.loaded then
				self:setState({
					loaded = true
				})
			end
		end
		return
	end

	-- Synchronization/Batching work should be done in engine for performance improvements
	-- related ticket: CLIPLAYEREX-1764
	spawn(function()
		decal.Texture = image
		ContentProvider:PreloadAsync({decal})

		loadedImagesByUri[image] = true

		if self._isMounted then
			self:setState({
				loaded = true
			})

			if self.props.onLoaded then
				self.props.onLoaded()
			end
		end
	end)
end

function LoadableImage._mockPreloadDone(image)
	loadedImagesByUri[image] = true
end

function LoadableImage.isLoaded(image)
	if image == Roact.None or image == nil or image == "" then
		return false
	else
		return loadedImagesByUri[image] ~= nil
	end
end

return LoadableImage
