local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AEUILoader = Roact.Component:extend("AEUILoader")

function AEUILoader:render()
	local deviceOrientation = self.props.deviceOrientation
	local dialogFrame = self._context.AvatarEditorTheme.AEDialogFrame
	local avatarEditorActive = self.props.avatarEditorActive
	local elements = {
		AvatarEditorScreen = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			Enabled = avatarEditorActive,
		}, {
			DialogFrame = Roact.createElement(dialogFrame, {
				deviceOrientation = deviceOrientation,
				avatarEditorActive = avatarEditorActive,
			}),
		}),
	}

	return Roact.createElement(Roact.Portal, {target = CoreGui}, elements)
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			deviceOrientation = state.DeviceOrientation,
		}
	end
)(AEUILoader)