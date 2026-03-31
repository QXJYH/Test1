local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)
local Otter = require(CorePackages.Otter)
local Immutable = require(Modules.Common.Immutable)

local FadeInImageLabel = Roact.PureComponent:extend("FadeInImageLabel")

local function getCombinedTransparency(transparency1, transparency2)
	return 1 - (1 - transparency1) * (1 - transparency2)
end

function FadeInImageLabel:init()
	self.state = {
		currentImage = self.props.Image,
		currentImageTint = self.props.Tint,
		nextImage = nil,
		nextImageTint = nil,
	}

	self.currentImageRef = Roact.createRef()
	self.currentImageTintRef = Roact.createRef()
	self.nextImageRef = Roact.createRef()
	self.nextImageTintRef = Roact.createRef()

	self.setCurrentImageTransparency = function(transparency)
		if self.currentImageRef.current then
			self.currentImageRef.current.ImageTransparency = transparency
		end
		if self.currentImageTintRef.current then
			self.currentImageTintRef.current.BackgroundTransparency =
				getCombinedTransparency(transparency, self.state.currentImageTint.Transparency)
		end
	end

	self.setNextImageTransparency = function(transparency)
		if self.nextImageRef.current then
			self.nextImageRef.current.ImageTransparency = transparency
		end
		if self.nextImageTintRef.current then
			self.nextImageTintRef.current.BackgroundTransparency =
				getCombinedTransparency(transparency, self.state.nextImageTint.Transparency)
		end
	end

	-- Start with a total transparent image
	self.transparencyMotor = Otter.createSingleMotor(1)

	self.transparencyMotor:onStep(function(transparency)
		self.setCurrentImageTransparency(transparency)
		self.setNextImageTransparency(1 - transparency)
	end)

	-- Fade in the 1st image
	self.transparencyMotor:setGoal(Otter.spring(0))
	self.transparencyMotor:start()
end

function FadeInImageLabel:didUpdate(prevProps)
	-- If the Image field gets updated, then we want to fade out the current
	-- image and fade in the new image.
	if prevProps.Image ~= self.props.Image then
		self:setState({
			currentImage = prevProps.Image,
			currentImageTint = prevProps.Tint,
			nextImage = self.props.Image,
			nextImageTint = self.props.Tint,
		})

		self.transparencyMotor:setGoal(Otter.spring(1))

		self.transparencyMotor:onComplete(function()
			self.setCurrentImageTransparency(0)
			self.setNextImageTransparency(1)

			local currentNextImage = self.state.nextImage
			local currentNextImageTint = self.state.nextImageTint or Roact.None
			self:setState({
				currentImage = currentNextImage,
				currentImageTint = currentNextImageTint,
				nextImage = Roact.None,
				nextImageTint = Roact.None,
			})
		end)
	end
end

function FadeInImageLabel:willUnmount()
	self.transparencyMotor:destroy()
end

function FadeInImageLabel:render()
	local props = self.props
	local currentImage = self.state.currentImage
	local currentImageTint = self.state.currentImageTint
	local nextImage = self.state.nextImage
	local nextImageTint = self.state.nextImageTint

	local newProps = Immutable.RemoveFromDictionary(props, "Tint")
	newProps.Image = currentImage
	newProps[Roact.Ref] = self.currentImageRef

	return Roact.createElement("ImageLabel", newProps, {
		Tint = currentImageTint and Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = currentImageTint.Color,
			BackgroundTransparency = currentImageTint.Transparency,
			BorderSizePixel = 0,
			ZIndex = 1,
			[Roact.Ref] = self.currentImageTintRef,
		}),
		NewImage = nextImage and Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = nextImage,
			ZIndex = 2,
			[Roact.Ref] = self.nextImageRef,
		}, {
			Tint = nextImageTint and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = nextImageTint.Color,
				BackgroundTransparency = nextImageTint.Transparency,
				BorderSizePixel = 0,
				[Roact.Ref] = self.nextImageTintRef,
			}),
		}),
	})
end

return FadeInImageLabel