local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Common = Modules.Common

local Roact = require(Common.Roact)
local RoactRodux = require(Common.RoactRodux)

local BackgroundFill = Roact.PureComponent:extend("BackgroundFill")

function BackgroundFill:render()
	local image = self.props.Image
	local ratio = self.props.AspectRatio

	local maxScreenSizeOneDimension = math.max(self.props.screenSize.X, self.props.screenSize.Y)
	
	return Roact.createElement("ImageLabel", {
		Image = image,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0
	}, {
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = ratio
		}),
		UISizeConstraint = Roact.createElement("UISizeConstraint", {
			MinSize = Vector2.new(maxScreenSizeOneDimension, maxScreenSizeOneDimension)
		})
	})
end

BackgroundFill = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			screenSize = state.ScreenSize
		}
	end
)(BackgroundFill)

return BackgroundFill
