local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local Immutable = require(Modules.Common.Immutable)

local GenericTextButton = require(Modules.LuaApp.Components.GenericTextButton)

local ContextPrimaryButton = Roact.PureComponent:extend("ContextPrimaryButton")

function ContextPrimaryButton:render()
	local theme = self._context.AppTheme
	local props = self.props
	local newProps = Immutable.Set(props, "themeSettings", theme.ContextPrimaryButton)

	return Roact.createElement(GenericTextButton, newProps)
end

return ContextPrimaryButton
