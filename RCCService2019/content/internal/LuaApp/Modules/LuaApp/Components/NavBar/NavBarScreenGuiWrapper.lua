local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)

local NavBarScreenGuiWrapper = Roact.PureComponent:extend("NavBarScreenGuiWrapper")

NavBarScreenGuiWrapper.defaultProps = {
	displayOrder = 1,
}

function NavBarScreenGuiWrapper:render()
	local isVisible = self.props.isVisible
	local displayOrder = self.props.displayOrder
	local component = self.props.component
	local props = self.props.props

	return Roact.createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		NavBarScreenGuiWrapper = Roact.createElement("ScreenGui", {
			Enabled = isVisible,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = displayOrder,
		}, {
			NavBar = Roact.createElement(component, props),
		}),
	})
end

return NavBarScreenGuiWrapper