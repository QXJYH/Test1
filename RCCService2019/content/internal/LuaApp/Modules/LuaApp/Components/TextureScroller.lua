local Modules = game:GetService("CoreGui").RobloxGui.Modules
local RunService = game:GetService("RunService")

local Roact = require(Modules.Common.Roact)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ArgCheck = require(Modules.LuaApp.ArgCheck)

local TextureScroller = Roact.PureComponent:extend("TextureScroller")

function TextureScroller:init()
	self.lerpValue = 0
	self.imageRef = Roact.createRef()

	self.renderSteppedCallback = function(dt)
		local imageScrollCycleTime = self.props.imageScrollCycleTime
		local imagePositionStart = self.props.imagePositionStart
		local imagePositionEnd = self.props.imagePositionEnd

		local lerpPerFrame = 0
		if imageScrollCycleTime ~= 0 then
			lerpPerFrame = (dt / imageScrollCycleTime)
		end
		self.lerpValue = (self.lerpValue + lerpPerFrame) % 1
		self.imageRef.current.Position = imagePositionStart:lerp(imagePositionEnd, self.lerpValue)
	end
end

function TextureScroller:render()
	ArgCheck.isType(self.props.Image, "string", "self.props.Image")
	ArgCheck.isType(self.props.imageScrollCycleTime, "number", "self.props.imageScrollCycleTime")
	ArgCheck.isType(self.props.imagePositionStart, "UDim2", "self.props.imagePositionStart")
	ArgCheck.isType(self.props.imagePositionEnd, "UDim2", "self.props.imagePositionEnd")

	local size = self.props.Size
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local layoutOrder = self.props.LayoutOrder

	local image = self.props.Image
	local imageSize = self.props.imageSize
	local imageTransparency = self.props.ImageTransparency
	local imageAnchorPoint = self.props.imageAnchorPoint
	local imagePositionStart = self.props.imagePositionStart

	return Roact.createElement("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Roact.createElement(ImageSetLabel, {
			Size = imageSize,
			Position = imagePositionStart,
			AnchorPoint = imageAnchorPoint,
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = imageTransparency,
			[Roact.Ref] = self.imageRef,
		}),
		renderStepped = Roact.createElement(ExternalEventConnection, {
			event = RunService.renderStepped,
			callback = self.renderSteppedCallback,
		}),
	})
end

return TextureScroller