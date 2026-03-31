local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local TweenService = game:GetService("TweenService")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local RoactAnalyticsAvatarEditorPage = require(Modules.LuaApp.Services.RoactAnalyticsAvatarEditorPage)
local RoactServices = require(Modules.LuaApp.RoactServices)
local AEConsoleCategoryMenu = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleCategoryMenu)
local AEConsoleTabList = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleTabList)
local AEConsoleAvatarTypeButton = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleAvatarTypeButton)
local AEConsoleFullViewButton = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleFullViewButton)
local AEScrollingFrame = require(Modules.LuaApp.Components.Avatar.UI.AEScrollingFrame)
local AEWarningWidget = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleWarningWidget)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local EmotesOverlay = require(Modules.LuaApp.Components.Avatar.UI.Emotes.AEEmotesOverlay)
local AEConsoleDialogFrame = Roact.PureComponent:extend("AEConsoleDialogFrame")

function AEConsoleDialogFrame:init()
	self.avatarEditorContainerRef = Roact.createRef()
	self.scrollingFrameWrapperRef = Roact.createRef()
	self.menuWrapperRef = Roact.createRef()
end

function AEConsoleDialogFrame:didMount()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	self.tweenFullViewScrollingFrame = TweenService:Create(self.scrollingFrameWrapperRef.current, tweenInfo,
		{ Position = UDim2.new(0, 650, 0, 0)})
	self.tweenNotFullViewScrollingFrame = TweenService:Create(self.scrollingFrameWrapperRef.current, tweenInfo,
		{ Position = UDim2.new(0, 0, 0, 0)})
	self.tweenFullViewMenu = TweenService:Create(self.menuWrapperRef.current, tweenInfo,
		{Position = UDim2.new(0, -580, 0, 0)})
	self.tweenNotFullViewMenu = TweenService:Create(self.menuWrapperRef.current, tweenInfo,
		{Position = UDim2.new(0, 0, 0, 0)})
end

function AEConsoleDialogFrame:didUpdate(prevProps, prevState)
	local fullView = self.props.fullView

	if fullView and fullView ~= prevProps.fullView then
		self.avatarEditorContainerRef.current.BackgroundOverlay.Visible = false
		self.tweenFullViewScrollingFrame:Play()
		self.tweenFullViewMenu:Play()
	elseif not fullView and fullView ~= prevProps.fullView then
		self.avatarEditorContainerRef.current.BackgroundOverlay.Visible = true
		self.tweenNotFullViewScrollingFrame:Play()
		self.tweenNotFullViewMenu:Play()
	end
end

function AEConsoleDialogFrame:render()
	local avatarEditorActive = self.props.avatarEditorActive

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollingEnabled = false,
		Selectable = false,
		Visible = true,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		[Roact.Ref] = self.avatarEditorContainerRef,
	}, {
		BackgroundOverlay = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = true,
			Image = 'rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-background overlay merge.png',
			ZIndex = 1,
		}),
		ScrollingFrameWrapper = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Roact.Ref] = self.scrollingFrameWrapperRef,
		}, {
			ScrollingFrame = Roact.createElement(AEScrollingFrame, {
				deviceOrientation = DeviceOrientationMode.Landscape,
				analytics = self.props.analytics
			}),
		}),
		MenuWrapper = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
			[Roact.Ref] = self.menuWrapperRef,
		}, {
			AEConsoleCategoryMenu = Roact.createElement(AEConsoleCategoryMenu, { avatarEditorActive = avatarEditorActive }),
			AEConsoleTabList = Roact.createElement(AEConsoleTabList),
		}),
		SwitchAvatarTypeButton = Roact.createElement(AEConsoleAvatarTypeButton),
		FullViewButton = Roact.createElement(AEConsoleFullViewButton),
		AEWarningWidget = Roact.createElement(AEWarningWidget),

		EmotesOverlay = Roact.createElement(EmotesOverlay, {
			deviceOrientation = DeviceOrientationMode.Landscape,
			analytics = self.props.analytics,
		}),
	})
end

AEConsoleDialogFrame = RoactServices.connect({
	analytics = RoactAnalyticsAvatarEditorPage,
})(AEConsoleDialogFrame)

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			fullView = state.AEAppReducer.AEFullView,
		}
	end
)(AEConsoleDialogFrame)
