local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local LuaChat = Modules.LuaChat

local Create = require(LuaChat.Create)
local Constants = require(LuaChat.Constants)
local Text = require(LuaChat.Text)

local UserChatBubbleModerationError = {}
UserChatBubbleModerationError.__index = UserChatBubbleModerationError

function UserChatBubbleModerationError.new(appState, filteringTextKey)
	local self = {}
	setmetatable(self, UserChatBubbleModerationError)

	self.label = Create.new "TextLabel" {
		Name = "ModeratedNoticeText",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		TextSize = Constants.Font.FONT_SIZE_14,
		Text = appState.localization:Format(filteringTextKey),
		Font = Constants.Font.STANDARD,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
	}

    self.rbx = Create.new "Frame" {
		Name = "ModeratedNotice",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		self.label
    }

    return self
end

function UserChatBubbleModerationError:setLayoutOrder(layoutOrder)
	self.rbx.LayoutOrder = layoutOrder
end

function UserChatBubbleModerationError:setTextColor(textColor)
	self.label.TextColor3 = textColor
end

function UserChatBubbleModerationError:setParent(parent)
	self.rbx.Parent = parent
end

function UserChatBubbleModerationError:ResizeToWidth(width)
	local label = self.label
	local height = Text.GetTextHeight(
		label.Text,
		label.Font,
		label.TextSize,
		width
	)

	self.rbx.Size = UDim2.new(0, width, 0, height)
end

function UserChatBubbleModerationError:Destruct()
	self.rbx:Destroy()
end

return UserChatBubbleModerationError