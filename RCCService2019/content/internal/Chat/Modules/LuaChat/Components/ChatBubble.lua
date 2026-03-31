local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local LuaChat = script.Parent.Parent
local UserThumbnail = require(script.Parent.UserThumbnail)
local TypingIndicator = require(script.Parent.TypingIndicator)

local SystemMessageBubble = require(script.Parent.SystemMessageBubble)
local UserChatBubble = require(script.Parent.UserChatBubble)
local AssetCard = require(script.Parent.AssetCard)

local Create = require(LuaChat.Create)
local Constants = require(LuaChat.Constants)
local WebApi = require(LuaChat.WebApi)

local Message = require(LuaChat.Models.Message)

local isFeatureEnabled = require(LuaChat.Utils.isFeatureEnabled)

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local LuaApp = Modules.LuaApp
local AppFeature = require(LuaApp.Enum.AppFeature)
local NotificationType = require(LuaApp.Enum.NotificationType)
local UrlBuilder = require(LuaApp.Http.UrlBuilder)

local RECEIVED_BUBBLE = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble2.png"
local RECEIVED_BUBBLE_WITH_TAIL = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble.png"
local RECEIVED_TAIL = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-tip.png"

local SENT_BUBBLE = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-self2.png"
local SENT_BUBBLE_WITH_TAIL = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-self.png"
local SENT_TAIL = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-self-tip.png"

local SENT_BUBBLE_OUTLINE = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble2.png"
local SENT_BUBBLE_OUTLINE_WITH_TAIL =  "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-right.png"
local SENT_OUTLINE_TAIL = "rbxasset://textures/ui/LuaChat/9-slice/chat-bubble-tip-right.png"

local FFlagLuaChatGameLinkRender = settings():GetFFlag("LuaChatGameLinkRender")
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")
local FFlagLuaAppHttpsWebViews = settings():GetFFlag("LuaAppHttpsWebViews")

local FlagSettings = require(LuaChat.FlagSettings)

local function isOutgoingMessage(message)
	local localUserId = tostring(Players.LocalPlayer.UserId)
	return message.senderTargetId == localUserId
end

local function isMessageSending(conversation, message)
	if conversation and conversation.sendingMessages then
		return conversation.sendingMessages:Get(message.id) ~= nil
	end
	return false
end

local PROTOCOL_IDENTIFIERS = {
	"https?://", ""
}

local RESOURCE_NAMES = {
	"www%.", "web%.", ""
}

local WHITELISTED_DOMAINS
local MESSAGE_CONTENT_PATTERNS
if FFlagChinaLicensingApp then
	WHITELISTED_DOMAINS = {
		"roblox.com", "roblox.cn", "sitetest%d%.robloxlabs.com",
		"gametest%d%.robloxlabs.com", "roblox.qq.com", "roblox-cn.com"
	}

	MESSAGE_CONTENT_PATTERNS = {
		GAME_LINK = "%/games[^%d]*(%d+)/?",
	}
else
	WHITELISTED_DOMAINS = {
		"roblox", "sitetest%d%.robloxlabs", "gametest%d%.robloxlabs"
	}

	MESSAGE_CONTENT_PATTERNS = {
		GAME_LINK = "%.com/games[^%d]*(%d+)/?",
	}
end

local ChatBubble = {}

ChatBubble.__index = ChatBubble

ChatBubble.BubbleType = {
	AssetCard = "AssetCard",
	ChatBubble = "UserChatBubble",
	SystemMessageBubble = "SystemMessageBubble",
}

local function getBubbleImages(message, bubbleType)
	if isOutgoingMessage(message) and bubbleType ~= ChatBubble.BubbleType.AssetCard then
		return SENT_BUBBLE, SENT_BUBBLE_WITH_TAIL, SENT_TAIL
	elseif isOutgoingMessage(message) then
		return SENT_BUBBLE_OUTLINE, SENT_BUBBLE_OUTLINE_WITH_TAIL, SENT_OUTLINE_TAIL
	else
		return RECEIVED_BUBBLE, RECEIVED_BUBBLE_WITH_TAIL, RECEIVED_TAIL
	end
end

function ChatBubble.new(appState, message, width)
	if FlagSettings.isMessageTypeEnabled() then
		width = width or 0

		local self = {}
		setmetatable(self, ChatBubble)

		self.width = width
		self.appState = appState
		self.message = message
		self.bubbles = {}
		self.rbx_connections = {}

		self.tailVisible = false

		self.rbx = Create.new "Frame" {
			Name = "ChatContainer",
			BackgroundTransparency = 1,

			Size = UDim2.new(1, 0, 0, 0),

			Create.new "UIListLayout" {
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		}

		self:RenderBubbles(message)

		return self
	else
		width = width or 0

		local self = {}
		setmetatable(self, ChatBubble)

		local conversationId = message.conversationId
		local isSending = isMessageSending(appState.store:getState().ChatAppReducer.Conversations[conversationId], message)

		self.width = width
		self.appState = appState
		self.message = message
		self.bubbles = {}
		self.rbx_connections = {}

		self.tailVisible = false

		self.rbx = Create.new "Frame" {
			Name = "ChatContainer",
			BackgroundTransparency = 1,

			Size = UDim2.new(1, 0, 0, 0),

			Create.new "UIListLayout" {
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
		}

		if message.moderated or isSending then
			self:AddBubble(UserChatBubble.new(appState, message, nil, self.width), 1)

		-- Specifically whitelist strings with .com/games in the url
		elseif message.content and message.content:lower():match(MESSAGE_CONTENT_PATTERNS.GAME_LINK) then
			local text = self:FilterForLinks()

			-- Flush remaining text if it is not empty
			if text:gsub("%s+","") ~= "" then
				self:AddBubble(UserChatBubble.new(appState, message, text, self.width))
			end
		else
			self:AddBubble(UserChatBubble.new(appState, message, nil, self.width), 1)
		end

		return self
	end
end

function ChatBubble:RenderBubbles(message)
	if FFlagLuaChatGameLinkRender and message.messageType == Message.MessageTypes.Link then
		self:_renderLink(message)
	elseif message.messageType == Message.MessageTypes.PlainText then
		self:_renderPlainText(message)
	else
		self:_renderMessageCannotBeDisplayed()
	end
end

function ChatBubble:_renderMessageCannotBeDisplayed()
	local cannotBeDisplayedMessage = Message.newSystemMessage("Feature.Chat.Label.NotImplementedMessageType")
	self:_renderSystemMessage(cannotBeDisplayedMessage)
end

function ChatBubble:_renderSystemMessage(message)
	self:AddBubble(SystemMessageBubble.new(self.appState, message), 1)
end

function ChatBubble:_renderPlainText(message)
	local appState = self.appState
	local conversationId = message.conversationId
	local isSending = isMessageSending(appState.store:getState().ChatAppReducer.Conversations[conversationId], message)
	if message.moderated or isSending then
		self:AddBubble(UserChatBubble.new(appState, message, nil, self.width), 1)

	-- Specifically whitelist strings with .com/games in the url
	elseif message.content and message.content:lower():match(MESSAGE_CONTENT_PATTERNS.GAME_LINK) then
		local text = self:FilterForLinks()

		-- Flush remaining text if it is not empty
		if text:gsub("%s+","") ~= "" then
			self:AddBubble(UserChatBubble.new(appState, message, text, self.width))
		end
	else
		self:AddBubble(UserChatBubble.new(appState, message, nil, self.width), 1)
	end
end

function ChatBubble:_renderLink(message)
	local gameLink = message.gameLink
	if gameLink then
		local universeId = gameLink.universeId
		if universeId then
			self:AddBubble(AssetCard.new(self.appState, self.message, nil, universeId))
		end
	else
		-- We've exhausted all known options for game links.
		self:_renderMessageCannotBeDisplayed()
	end
end

function ChatBubble:FilterForLinks()
	local text = self.message.content
	for _, protocol in pairs(PROTOCOL_IDENTIFIERS) do
		for _, resource in pairs(RESOURCE_NAMES) do
			for _, domain in pairs(WHITELISTED_DOMAINS) do

				local constructedUrlPattern = protocol .. resource .. domain .. MESSAGE_CONTENT_PATTERNS.GAME_LINK
				for assetId in text:lower():gmatch(constructedUrlPattern) do
					local linkStart, endLink = text:lower():find("[^%s*]*" .. constructedUrlPattern .. "[^%s*]*")
					if linkStart then
						local textBefore = text:sub(1, linkStart - 1)

						if textBefore:gsub("%s+","") ~= "" then
							self:AddBubble(UserChatBubble.new(self.appState, self.message, textBefore, self.width))
						end

						self:AddBubble(AssetCard.new(self.appState, self.message, assetId))

						text = text:sub(endLink + 1)
					else
						return text
					end
				end

			end
		end
	end

	return text
end

function ChatBubble:AddBubble(bubble, placement)
	table.insert(self.bubbles, placement or #self.bubbles+1 ,bubble)
	bubble.rbx.Parent = self.rbx
	bubble.LayoutOrder = placement or #self.bubbles

	for i=1,#self.bubbles do
		self.bubbles[i].LayoutOrder = i
	end

	local connection = bubble.rbx:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Resize()
	end)
	table.insert(self.rbx_connections, connection)

	self:Update()
end

function ChatBubble:SetUsernameVisible(value)
	local firstBubbleIndex = 1
	if not self.bubbles[firstBubbleIndex] or not self.bubbles[firstBubbleIndex].usernameLabel then
		return
	end

	local firstBubbleEntry = self.bubbles[firstBubbleIndex]

	local bubblePos = firstBubbleEntry.bubble.Position

	if value then
		firstBubbleEntry.usernameLabel.Visible = true

		firstBubbleEntry.bubble.Position = UDim2.new(
			bubblePos.X.Scale,
			bubblePos.X.Offset,
			0,
			16
		)
	else
		firstBubbleEntry.usernameLabel.Visible = false

		firstBubbleEntry.bubble.Position = UDim2.new(
			bubblePos.X.Scale,
			bubblePos.X.Offset,
			0,
			0
		)
	end

	self:Resize()
end

function ChatBubble:SetTypingIndicatorVisible(value)
	local firstBubbleIndex = 1
	if not self.bubbles[firstBubbleIndex] or not self.bubbles[firstBubbleIndex].usernameLabel then
		return
	end

	local firstBubbleEntry = self.bubbles[firstBubbleIndex]

	if value and not self.indicator then
		local indicator = TypingIndicator.new(self.appState, .4)
		indicator.rbx.AnchorPoint = Vector2.new(0,0.5)
		indicator.rbx.Position = UDim2.new(0, firstBubbleEntry.usernameLabel.TextBounds.X + 3, 0.5, 0)
		indicator.rbx.Parent = firstBubbleEntry.usernameLabel

		self.indicator = indicator
	elseif self.indicator and not value then
		self.indicator:Destroy()
		self.indicator = nil
	end
end

function ChatBubble:SetThumbnailVisible(value)
	if value then
		self.thumbnail = UserThumbnail.new(self.appState, self.message.senderTargetId, true)
		self.thumbnail.rbx.Position = UDim2.new(0, 10, 0, 0)
		self.thumbnail.rbx.Overlay.ImageColor3 = Constants.Color.GRAY6
		self.thumbnail.rbx.Parent = self.bubbles[1].bubbleContainer

		if isFeatureEnabled(self.appState, AppFeature.ChatTapConversationThumbnail) then
			self.thumbnail.clicked:connect(function()
				local user = self.appState.store:getState().Users[self.message.senderTargetId]
				local userId = user and user.id
				if userId then
					if FFlagLuaAppHttpsWebViews then
						GuiService:BroadcastNotification(UrlBuilder.user.profile({
							userId = userId,
						}), NotificationType.VIEW_PROFILE)
					else
						GuiService:BroadcastNotification(WebApi.MakeUserProfileUrl(userId),
							NotificationType.VIEW_PROFILE)
					end
				end
			end)
		end
	else
		if self.thumbnail then
			self.thumbnail:Destruct()
		end
	end
end

function ChatBubble:SetTailVisible(value)
	self.tailVisible = value
	if not self.bubbles[1] then return end

	for i, bubble in pairs(self.bubbles) do
		if bubble.bubbleType ~= ChatBubble.BubbleType.SystemMessageBubble then
			local bubbleImage, bubbleWithTail, tailImage = getBubbleImages(self.message, bubble.bubbleType)
			if value and i == 1 then
				bubble.bubble.Image = bubbleWithTail
				bubble.tail.Image = tailImage
				bubble.tail.Visible = true
			else
				bubble.bubble.Image = bubbleImage
				bubble.tail.Visible = false
			end
		end
	end
end

function ChatBubble:SetPaddingObject(object)
	if not self.bubbles[1] then return end

	if self.bubbles[1].paddingObject then
		self.bubbles[1].paddingObject:Destroy()
	end

	object.LayoutOrder = 1
	object.Parent = self.bubbles[1].rbx
	self.bubbles[1].paddingObject = object
	self.bubbles[1]:Resize()
end

function ChatBubble:Resize()
	local height = 0
	for _, child in ipairs(self.rbx:GetChildren()) do
		if child:IsA("GuiObject") then
			height = height + child.AbsoluteSize.Y
		end
	end

	self.rbx.Size = UDim2.new(1, 0, 0, height)
end


function ChatBubble:Update()
	self:SetTailVisible(self.tailVisible)
	self:Resize()
end

function ChatBubble:Destruct()
	for _, connection in ipairs(self.rbx_connections) do
		connection:Disconnect()
	end
	self.rbx_connections = {}

	for _, bubble in ipairs(self.bubbles) do
		bubble:Destruct()
	end

	if self.thumbnail then
		self.thumbnail:Destruct()
	end
	self.thumbnail = nil

	self.rbx:Destroy()
end

return ChatBubble
