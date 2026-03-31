local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Cryo)
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local ScreenGuiWithBlurControl = Roact.PureComponent:extend("ScreenGuiWithBlurControl")

function ScreenGuiWithBlurControl:render()
	local hasScreenGuiBlur = self.props.hasScreenGuiBlur
	local blurDisplayOrder = self.props.blurDisplayOrder
	local displayOrder = self.props.DisplayOrder

	local onTopOfCoreBlur = false
	if hasScreenGuiBlur and displayOrder >= blurDisplayOrder then
		onTopOfCoreBlur = true
	end

	local newProps = Cryo.Dictionary.join(self.props, {
		hasScreenGuiBlur = Cryo.None,
		blurDisplayOrder = Cryo.None,
		OnTopOfCoreBlur = onTopOfCoreBlur,
	})

	return Roact.createElement("ScreenGui", newProps)
end

ScreenGuiWithBlurControl = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			hasScreenGuiBlur = state.ScreenGuiBlur.hasBlur,
			blurDisplayOrder = state.ScreenGuiBlur.blurDisplayOrder,
		}
	end
)(ScreenGuiWithBlurControl)

return ScreenGuiWithBlurControl