local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local SOME_LIGHT_GREYISH_COLOR = Color3.fromRGB(189, 190, 190)

local PaddedTextLabel = require(Components.PaddedTextLabel)

local UsernameLabel = Roact.PureComponent:extend("UsernameLabel")
UsernameLabel.defaultProps = {
	usernameContent = "Username",
	LayoutOrder = 0,
}

function UsernameLabel:render()
	return UIBlox.Style.withStyle(function(style)
		local usernameContent = self.props.usernameContent
		local layoutOrder = self.props.LayoutOrder

		return Roact.createElement(PaddedTextLabel, {
			Font = Enum.Font.Gotham,
			LayoutOrder = layoutOrder,
			PaddingBottom = 5,
			PaddingTop = 5,
			Text = usernameContent,
			TextSize = 12,
			TextColor3 = SOME_LIGHT_GREYISH_COLOR,
		})
	end)
end

return UsernameLabel