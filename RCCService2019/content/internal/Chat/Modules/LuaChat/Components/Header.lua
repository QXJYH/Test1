local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local NotificationService = game:GetService("NotificationService")

local Modules = CoreGui.RobloxGui.Modules
local Common = Modules.Common
local LuaChat = Modules.LuaChat
local LuaApp = Modules.LuaApp

local Constants = require(LuaChat.Constants)
local Create = require(LuaChat.Create)
local FlagSettings = require(LuaChat.FlagSettings)
local LuaAppFlagSettings = require(LuaApp.FlagSettings)
local Signal = require(Common.Signal)

local Components = LuaChat.Components
local BaseHeader = require(Components.BaseHeader)
local TextButton = require(Components.TextButton)

local FFlagEnableLuaChatDiscussions = FlagSettings.EnableLuaChatDiscussions()
local FFlagChinaLicensingApp = settings():GetFFlag("ChinaLicensingApp")
local FFlagLuaChatHeaderEnableHomeButton = settings():GetFFlag("LuaChatHeaderEnableHomeButton")
local FFlagLuaChatCenterAndroidHeader = settings():GetFFlag("LuaChatCenterAndroidHeader")

local showRobloxLogoAsBackButton = FFlagChinaLicensingApp and FFlagLuaChatHeaderEnableHomeButton
local NavigateToRoute = require(Modules.LuaApp.Thunks.NavigateToRoute)
local NavigateSideways = require(Modules.LuaApp.Thunks.NavigateSideways)
local AppPage = require(Modules.LuaApp.AppPage)

local UseNewAppStyle = LuaAppFlagSettings:UseNewAppStyle()

local getThemeModuleForString = require(LuaApp.Themes.getThemeModuleForString)

local FFlagLuaAppHomeIconPolicy = settings():GetFFlag("LuaAppHomeIconPolicy")

local HEIGHT_OF_DISCONNECTED = 32

local PLATFORM_SPECIFIC_CONSTANTS = {
	[Enum.Platform.Android] = {
		HEADER_TITLE_FRAME_POSITION_NO_BACK_BUTTON = UDim2.new(0, 15, 0, 0),
		HEADER_TITLE_FRAME_POSITION = UDim2.new(0, 72, 0, 0),
		HEADER_TITLE_FRAME_ANCHOR_POINT = Vector2.new(0, 0),
		HEADER_VERTICAL_ALIGNMENT = Enum.VerticalAlignment.Center,
		HEADER_HORIZONTAL_ALIGNMENT = Enum.HorizontalAlignment.Left,
		HEADER_TEXT_X_ALIGNMENT = 0,
	},
	Default = {
		HEADER_TITLE_FRAME_POSITION_NO_BACK_BUTTON = UDim2.new(0.5, 0, 0, 0),
		HEADER_TITLE_FRAME_POSITION = UDim2.new(0.5, 0, 0, 0),
		HEADER_TITLE_FRAME_ANCHOR_POINT = Vector2.new(0.5, 0),
		HEADER_VERTICAL_ALIGNMENT = Enum.VerticalAlignment.Top,
		HEADER_HORIZONTAL_ALIGNMENT = Enum.HorizontalAlignment.Center,
		HEADER_TEXT_X_ALIGNMENT = 2,
	},
}

if FFlagLuaChatCenterAndroidHeader then
	PLATFORM_SPECIFIC_CONSTANTS[Enum.Platform.Android] = PLATFORM_SPECIFIC_CONSTANTS.Default
end

local GROUP_CHAT_ICON_HEIGHT = 25
local GROUP_CHAT_ICON_WIDTH = 25
local GROUP_CHAT_ICON = "rbxasset://textures/ui/LuaChat/icons/ic-group-16x16.png"
local TITLE_LABEL_HEIGHT = 25
local TITLE_LABEL_WIDTH = 200
local TITLE_ITEM_PADDING = 5
local SUBTITLE_LABEL_HEIGHT = 12
local SUBTITLE_LABEL_WIDTH = 200

local function getPlatformSpecific(platform)
	return PLATFORM_SPECIFIC_CONSTANTS[platform] or PLATFORM_SPECIFIC_CONSTANTS.Default
end

local Header = BaseHeader:Template()
Header.__index = Header

function Header.new(appState, dialogType)
	local self = {}
	setmetatable(self, Header)


	local selectedTheme = UseNewAppStyle and NotificationService.SelectedTheme or nil

	local theme
	if UseNewAppStyle then
		if selectedTheme == "Classic" then
			selectedTheme = "light"
		end
		theme = getThemeModuleForString(selectedTheme)
	end

	local platform = appState.store:getState().Platform

	self:SetPlatform(platform)
	local platformConstants = getPlatformSpecific(platform)

	self.heightOfHeader = UserInputService.NavBarSize.Y + UserInputService.StatusBarSize.Y
	self.heightOfDisconnected = HEIGHT_OF_DISCONNECTED

	self.buttons = {}
	self.connections = {}
	self.rbx_connections = {}

	self.appState = appState
	self.dialogType = dialogType

	local buttonType
	if FFlagLuaChatHeaderEnableHomeButton then
		if FFlagLuaAppHomeIconPolicy then
			buttonType = self:getButtonTypeFromDialogType(dialogType)
		else
			buttonType = BaseHeader:getButtonTypeFromDialogType(dialogType)
		end
	else
		buttonType = dialogType
	end
	if FFlagLuaAppHomeIconPolicy then
		self.backButton = self:GetNewBackButton(buttonType)
	else
		self.backButton = BaseHeader:GetNewBackButton(buttonType)
	end
	self.backButton.rbx.Visible = false
	self.title = ""
	self.subtitle = nil
	self.connectionState = Enum.ConnectionState.Connected

	if showRobloxLogoAsBackButton then
		if FFlagLuaAppHomeIconPolicy then
			self.homeButton = self:GetNewBackButton(self.ButtonType.Logo)
		else
			self.homeButton = BaseHeader:GetNewBackButton(BaseHeader.ButtonType.Logo)
		end
		self.homeButton.rbx.Visible = false

		table.insert(self.connections, self.homeButton.Pressed:connect(function()
			self.appState.store:dispatch(NavigateToRoute({ { name = AppPage.Home } }))
		end))
	end

	self.luaChatPlayTogetherEnabled = FlagSettings.IsLuaChatPlayTogetherEnabled(self.appState)

	self.BackButtonPressed = Signal.new()
	local backButtonConnection = self.backButton.Pressed:connect(function()
		self.BackButtonPressed:fire()
	end)
	table.insert(self.connections, backButtonConnection)

	if UseNewAppStyle then
		self.titleLabel = Create.new "TextLabel" {
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Constants.Font.BOLD,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, TITLE_LABEL_HEIGHT),
			Text = self.title,
			TextColor3 = theme.ChatTopBar.Title.Color,
			TextSize = theme.ChatTopBar.Title.Size,
			TextXAlignment = platformConstants.HEADER_TEXT_X_ALIGNMENT,
		}
	else
		self.titleLabel = Create.new "TextLabel" {
			Name = "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Constants.Font.BOLD,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, TITLE_LABEL_HEIGHT),
			Text = self.title,
			TextColor3 = Constants.Color.WHITE,
			TextSize = Constants.Font.FONT_SIZE_20,
			TextXAlignment = platformConstants.HEADER_TEXT_X_ALIGNMENT,
		}
	end

	self.groupChatIcon = Create.new "ImageLabel" {
		Name = "GroupChatIcon",
		Visible = false,
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.new(0, GROUP_CHAT_ICON_WIDTH, 0, GROUP_CHAT_ICON_HEIGHT),
		AnchorPoint = Vector2.new(1, 0),
		Image = GROUP_CHAT_ICON,
	}

	self.innerTitleFrame = Create.new "Frame" {
		Name = "InnerTitleFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, GROUP_CHAT_ICON_HEIGHT),

		Create.new "UIListLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, TITLE_ITEM_PADDING),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = platformConstants.HEADER_HORIZONTAL_ALIGNMENT,
		},

		self.groupChatIcon,
		self.titleLabel,
	}
	self.titleLabel.Size = UDim2.new(1, -(GROUP_CHAT_ICON_WIDTH + TITLE_ITEM_PADDING), 0, TITLE_LABEL_HEIGHT)

	if UseNewAppStyle then
		self.innerSubtitle = Create.new "TextLabel" {
			Name = "Subtitle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Constants.Font.STANDARD,
			LayoutOrder = 2,
			Size = UDim2.new(0, SUBTITLE_LABEL_WIDTH, 0, SUBTITLE_LABEL_HEIGHT),
			Text = "",
			TextColor3 = theme.ChatTopBar.Subtitle.Color,
			TextSize = theme.ChatTopBar.Subtitle.Size,
			TextXAlignment = platformConstants.HEADER_TEXT_X_ALIGNMENT,
		}
	else
		self.innerSubtitle = Create.new "TextLabel" {
			Name = "Subtitle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Font = Constants.Font.STANDARD,
			LayoutOrder = 2,
			Size = UDim2.new(0, SUBTITLE_LABEL_WIDTH, 0, SUBTITLE_LABEL_HEIGHT),
			Text = "",
			TextColor3 = Constants.Color.WHITE,
			TextSize = Constants.Font.FONT_SIZE_12,
			TextXAlignment = platformConstants.HEADER_TEXT_X_ALIGNMENT,
		}
	end

	self.innerTitles = Create.new "Frame" {
		Name = "Titles",
		AnchorPoint = platformConstants.HEADER_TITLE_FRAME_ANCHOR_POINT,
		BackgroundTransparency = 1,
		Position = self:GetHeaderTitleFramePosition(),
		Size = UDim2.new(0, TITLE_LABEL_WIDTH, 1, 0),

		Create.new "UIListLayout" {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = platformConstants.HEADER_HORIZONTAL_ALIGNMENT,
		},
	}

	self.innerTitleFrame.Parent = self.innerTitles

	self.innerButtons = Create.new "Frame" {
		Name = "Buttons",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -5, 0, 0),
		Size = UDim2.new(0, 100, 1, 0),

		Create.new "UIListLayout" {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = platformConstants.HEADER_VERTICAL_ALIGNMENT,
		},
	}

	self.innerContent = Create.new "Frame" {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, UserInputService.StatusBarSize.Y),
		Size = UDim2.new(1, 0, 0, UserInputService.NavBarSize.Y),

		self.backButton.rbx,
		self.innerTitles,
		self.innerButtons,
	}

	if FFlagEnableLuaChatDiscussions then
		if FFlagLuaAppHomeIconPolicy then
			self.discussionsButton = self:GetNewBackButton(BaseHeader.ButtonType.Logo)
		else
			self.discussionsButton = BaseHeader:GetNewBackButton(BaseHeader.ButtonType.Logo)
		end
		self.discussionsButton.rbx.Visible = false
		self.discussionsButton.rbx.Parent = self.innerContent

		table.insert(self.connections, self.discussionsButton.Pressed:connect(function()
			self.appState.store:dispatch(NavigateSideways({ name = AppPage.Discussions }))
		end))
	end

	if FFlagLuaChatHeaderEnableHomeButton then
		if self.homeButton and self.homeButton.rbx then
			self.homeButton.rbx.Parent = self.innerContent
		end
	end

	if UseNewAppStyle then
		self.innerHeader = Create.new "Frame" {
			Name = "Header",
			BackgroundColor3 = theme.ChatTopBar.Background.Color,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, self.heightOfHeader),

			self.innerContent,
		}
	else
		self.innerHeader = Create.new "Frame" {
			Name = "Header",
			BackgroundColor3 = Constants.Color.BLUE_PRESSED,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, self.heightOfHeader),

			self.innerContent,
		}
	end

	self.rbx = Create.new("ImageButton"){
		Name = "HeaderFrame",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, self.heightOfHeader),

		Create.new "UIListLayout" {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		},

		self.innerHeader,

		Create.new "Frame" {
			Name = "Disconnected",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Constants.Color.GRAY3,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0), -- Note: Deliberately has zero vertical height, will be scaled when shown.

			Create.new "TextLabel" {
				Name = "Title",
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Font = Constants.Font.STANDARD,
				LayoutOrder = 0,
				Position = UDim2.new(0.5, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, HEIGHT_OF_DISCONNECTED),
				Text = appState.localization:Format("Feature.Chat.Message.NoConnectionMsg"),
				TextColor3 = Constants.Color.WHITE,
				TextSize = Constants.Font.FONT_SIZE_14,
			},
		},

		Create.new "Frame" {
			Name = "GameDrawer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 0), -- Note: Deliberately zero height, will be scaled open.
			Visible = false,
		},
	}

	local parentChangedConnection = self.rbx:GetPropertyChangedSignal("Parent"):Connect(function()
		if self.rbx and self.rbx.Parent then
			self:SetTitle(self.title) -- Again, this can be much cleaner once we have proper truncation support
		end
	end)
	table.insert(self.rbx_connections, parentChangedConnection)

	local navBarSignal = UserInputService:GetPropertyChangedSignal("NavBarSize")
	local navBarConnection = navBarSignal:Connect(function()
		self:AdjustLayout()
	end)
	local statusBarSignal = UserInputService:GetPropertyChangedSignal("StatusBarSize")
	local statusBarConnection = statusBarSignal:Connect(function()
		self:AdjustLayout()
	end)
	self:AdjustLayout()
	table.insert(self.rbx_connections, navBarConnection)
	table.insert(self.rbx_connections, statusBarConnection)

	table.insert(self.rbx_connections, self.innerTitles:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:SetTitle(self.title) -- Call SetTitle to truncate text according to the new size.
	end))

	table.insert(self.rbx_connections, self.innerButtons:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:AdjustTitleHeader()
	end))

	table.insert(self.rbx_connections, self.backButton.rbx:GetPropertyChangedSignal("Visible"):Connect(function()
		self:AdjustTitleHeader()
	end))
	self:AdjustTitleHeader()

	do
		local connection = appState.store.changed:connect(function(state, oldState)
			self:SetPlatform(state.Platform)
			self:SetConnectionState(state.ConnectionState)
		end)
		table.insert(self.connections, connection)
	end

	return self
end

function Header:IsBackButtonVisible()
	return self.backButton and self.backButton.rbx and self.backButton.rbx.Visible
end

function Header:IsHomeButtonVisible()
	return self.homeButton and self.homeButton.rbx and self.homeButton.rbx.Visible
end

function Header:_isHomeOrBackButtonVisible()
	return self:IsBackButtonVisible() or self:IsHomeButtonVisible()
end

function Header:AdjustLayout()
	self.heightOfHeader = UserInputService.NavBarSize.Y + UserInputService.StatusBarSize.Y
	self.rbx.Size = UDim2.new(1, 0, 0, self.heightOfHeader)
	self.innerHeader.Size = UDim2.new(1, 0, 0, self.heightOfHeader)

	self.innerContent.Position = UDim2.new(0, 0, 0, UserInputService.StatusBarSize.Y)
	self.innerContent.Size = UDim2.new(1, 0, 0, UserInputService.NavBarSize.Y)
end

function Header:AdjustTitleHeader()
	local backButtonWidth
	if FFlagLuaChatHeaderEnableHomeButton then
		backButtonWidth = self:_isHomeOrBackButtonVisible() and self.backButton.rbx.AbsoluteSize.X or 0
	else
		backButtonWidth = self:IsBackButtonVisible() and self.backButton.rbx.AbsoluteSize.X or 0
	end

	local buttonsWidth = self.innerButtons and self.innerButtons.AbsoluteSize.X or 0

	local titleWidthOffset = math.max(backButtonWidth, buttonsWidth) * 2
	self.innerTitles.Size = UDim2.new(1, -titleWidthOffset, 1, 0)

	self:SetTitle(self.title) -- Call SetTitle to truncate text according to the new size.
end

function Header:CreateHeaderButton(name, textKey)
	local saveGroup = TextButton.new(self.appState, name, textKey)
	self:AddButton(saveGroup)
	return saveGroup
end

function Header:SetBackButtonEnabled(enabled)
	self.backButton.rbx.Visible = enabled
	self.innerTitles.Position = self:GetHeaderTitleFramePosition()
end

if FFlagLuaChatHeaderEnableHomeButton then
	function Header:SetHomeButtonEnabled(enabled)
		if self.homeButton then
			self.homeButton.rbx.Visible = enabled
		end
		self.innerTitles.Position = self:GetHeaderTitleFramePosition()
	end
end

function Header:GetHeaderTitleFramePosition()
	local isAButtonVisible
	if FFlagLuaChatHeaderEnableHomeButton then
		isAButtonVisible = self:_isHomeOrBackButtonVisible()
	else
		isAButtonVisible = self:IsBackButtonVisible()
	end

	if isAButtonVisible then
		return getPlatformSpecific(self.platform).HEADER_TITLE_FRAME_POSITION
	end

	return getPlatformSpecific(self.platform).HEADER_TITLE_FRAME_POSITION_NO_BACK_BUTTON
end

function Header:SetGroupChatIconVisibility(enabled)
	if enabled then
		self.groupChatIcon.Visible = true
	else
		self.groupChatIcon.Visible = false
	end
end

return Header
