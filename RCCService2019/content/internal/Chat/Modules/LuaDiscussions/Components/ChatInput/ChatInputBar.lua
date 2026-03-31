local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")
local dependencies = require(LuaDiscussions.dependencies)
local Roact = dependencies.Roact
local Components = LuaDiscussions.Components
local UIBlox = dependencies.UIBlox

local ChatInputTextbox = require(Components.ChatInput.ChatInputTextbox)
local SendButton = require(Components.ChatInput.SendButton)

local MARGIN_LEFT = 24
local SOME_MEDIUM_GREY_COLOR = Color3.fromRGB(57, 59, 61)
local FULL_HEIGHT = 72

local ChatInputBar = Roact.PureComponent:extend("ChatInputBar")
ChatInputBar.defaultProps = {
	onSend = nil,
}

function ChatInputBar:init()
	self.textBoxRef = Roact.createRef()

	-- SOC-6357 - Add a test for sending
	self.sendText = function()
		local text = self.textBoxRef.current.Text
		if self.props.onSend and #text > 0 then
			self.props.onSend(text)
		end
		self.textBoxRef.current.Text = ""
	end

	self.onFocusLost = function(_, enterPressed)
		if enterPressed then
			self.sendText()
		end
	end
end

function ChatInputBar:render()
	return UIBlox.Style.withStyle(function(style)
		return Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = SOME_MEDIUM_GREY_COLOR,
			Size = UDim2.new(1, 0, 0, FULL_HEIGHT),
		}, {
			layout = Roact.createElement("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			leftSpacer = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, MARGIN_LEFT, 1, 0),
			}),
			textBox = Roact.createElement(ChatInputTextbox, {
				marginLeft = MARGIN_LEFT,
				marginRight = FULL_HEIGHT,
				marginHeight = 10,
				LayoutOrder = 1,
				[Roact.Ref] = self.textBoxRef,
				onFocusLost = self.onFocusLost,
			}),
			sendButton = Roact.createElement(SendButton, {
				fullExtents = FULL_HEIGHT,
				LayoutOrder = 2,
				onActivated = self.sendText,
			}),
		})
	end)
end

return ChatInputBar
