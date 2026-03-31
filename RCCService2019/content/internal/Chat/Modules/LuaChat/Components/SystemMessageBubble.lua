local LuaChat = script.Parent.Parent

local Create = require(LuaChat.Create)
local Text = require(LuaChat.Text)
local Constants = require(LuaChat.Constants)

local MAX_WIDTH = 250
local PADDING_TOP = 20
local PADDING_BOTTOM = 10
local FONT_SIZE = Constants.Font.FONT_SIZE_14

local SystemMessageBubble = {}
SystemMessageBubble.__index = SystemMessageBubble

function SystemMessageBubble.new(appState, message)
	local self = {}
	setmetatable(self, SystemMessageBubble)

	self.appState = appState
	self.bubbleType = "SystemMessageBubble"
	self.message = message

	local text = self:getText()

	self.layout = Create.new "UIListLayout" {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}

	self.greyBox = Create.new "ImageLabel" {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(224, 224, 224),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = "rbxasset://textures/ui/LuaChat/9-slice/system-message.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(3, 3, 4, 4),
		LayoutOrder = 2,

		Create.new "UIPadding" {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
		},

		Create.new "TextLabel" {
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(128, 128, 128),
			Text = text,
			TextSize = FONT_SIZE,
			Font = Constants.Font.STANDARD,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextWrapped = true,
		},
	}

	self.rbx = Create.new "Frame" {
		Name = "SystemMessage",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),

		self.layout,

		Create.new "UIPadding" {
			PaddingTop = UDim.new(0, PADDING_TOP),
			PaddingBottom = UDim.new(0, PADDING_BOTTOM),
		},

		self.greyBox,
	}

	self:Resize()


	return self
end

function SystemMessageBubble:getText()
	return self.appState.localization:Format(self.message.localizedTextKey)
end

function SystemMessageBubble:Resize()
	local text = self:getText()
	local height = self.layout.AbsoluteContentSize.Y + PADDING_TOP + PADDING_BOTTOM
	self.rbx.Size = UDim2.new(1, 0, 0, height)

	local textBounds = Text.GetTextBounds(text, Constants.Font.STANDARD, FONT_SIZE, Vector2.new(MAX_WIDTH, 1000))
	self.greyBox.Size = UDim2.new(0, math.min(MAX_WIDTH, textBounds.X) + 12, 0, textBounds.Y + 8)
end

function SystemMessageBubble:Destruct()
	self.rbx:Destroy()
end

return SystemMessageBubble