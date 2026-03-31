local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local CorePackages = game:GetService("CorePackages")
local Roact = dependencies.Roact
local Common = CorePackages.AppTempCommon.Common
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local Immutable = require(Common.Immutable)
local wrapFitBabies = require(Components.wrapFitBabies)

local PLACEHOLDER_BACKGROUND = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-self2.png"
local SOME_LIGHT_GREY_COLOR = Color3.fromRGB(57, 59, 61)
local SOME_DARK_GREY_COLOR = Color3.fromRGB(24, 25, 27)

local ChatBubbleContainer = Roact.PureComponent:extend("ChatBubbleContainer")
ChatBubbleContainer.defaultProps = {
	isIncoming = false,
	innerPadding = 12,
}

function ChatBubbleContainer:render()
	return UIBlox.Style.withStyle(function(style)
		local isIncoming = self.props.isIncoming
		local innerPadding = self.props.innerPadding
		local children = self.props[Roact.Children] or {}

		return Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ImageColor3 = isIncoming and SOME_DARK_GREY_COLOR or SOME_LIGHT_GREY_COLOR,

			Image = PLACEHOLDER_BACKGROUND,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(10, 10, 11, 11),
		}, Immutable.JoinDictionaries(children, {
			layout = Roact.createElement("UIListLayout"),
			padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, innerPadding),
				PaddingLeft = UDim.new(0, innerPadding),
				PaddingRight = UDim.new(0, innerPadding),
				PaddingBottom = UDim.new(0, innerPadding),
			})
		}))
	end)
end

return wrapFitBabies(ChatBubbleContainer)