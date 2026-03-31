local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local TweenService = game:GetService("TweenService")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AEConsoleButtonUI = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleButtonUI)

local AEConsoleAvatarTypeButton = Roact.PureComponent:extend("AEConsoleButton")
local R15_TEXT_KEY = "Feature.Avatar.Label.SwitchToR15"
local R6_TEXT_KEY = "Feature.Avatar.Label.SwitchToR6"

function AEConsoleAvatarTypeButton:init()
	self.buttonRef = Roact.createRef()
end

function AEConsoleAvatarTypeButton:didMount()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	self.avatarTypeSwitchTweenFV =
		TweenService:Create(self.buttonRef.current, tweenInfo, { Position = UDim2.new(0.5, -280, 1, 100), })
	self.avatarTypeSwitchTweenOriginal =
		TweenService:Create(self.buttonRef.current, tweenInfo, { Position = UDim2.new(0.5, -280, 1, -60), })
end

function AEConsoleAvatarTypeButton:render()
	local avatarType = self.props.avatarType

	return Roact.createElement(AEConsoleButtonUI, {
		buttonRef = self.buttonRef,
		size = UDim2.new(0, 280, 0, 83),
		position = UDim2.new(0.5, -280, 1, -60),
		text = avatarType == AEConstants.AvatarType.R15 and R6_TEXT_KEY or R15_TEXT_KEY,
		image = "rbxasset://textures/ui/Shell/ButtonIcons/SelectButtonDark.png",
		textSize = UDim2.new(0, 180, 0, 50),
	})
end

function AEConsoleAvatarTypeButton:didUpdate(prevProps)
	local fullView = self.props.fullView

	if fullView and not prevProps.fullView then
		self.avatarTypeSwitchTweenFV:Play()
	elseif not fullView and prevProps.fullView then
		self.avatarTypeSwitchTweenOriginal:Play()
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			fullView = state.AEAppReducer.AEFullView,
			avatarType = state.AEAppReducer.AECharacter.AEAvatarType,
		}
	end
)(AEConsoleAvatarTypeButton)