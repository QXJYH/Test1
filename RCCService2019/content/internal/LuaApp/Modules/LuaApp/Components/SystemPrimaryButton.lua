local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local Cryo = require(CorePackages.Cryo)
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GenericTextButton = require(Modules.LuaApp.Components.GenericTextButton)

local SystemPrimaryButton = Roact.PureComponent:extend("SystemPrimaryButton")

function SystemPrimaryButton:render()
	local theme = self._context.AppTheme
	local props = self.props
	local newProps = Cryo.Dictionary.join(props, { themeSettings = theme.SystemPrimaryButton })

	return Roact.createElement(GenericTextButton, newProps)
end

return SystemPrimaryButton
