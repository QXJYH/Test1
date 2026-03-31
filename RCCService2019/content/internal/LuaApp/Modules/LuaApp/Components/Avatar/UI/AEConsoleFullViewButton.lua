local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local TweenService = game:GetService("TweenService")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AEConsoleButtonUI = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleButtonUI)

local AEConsoleFullViewButton = Roact.PureComponent:extend("AEConsoleButton")
local IN_FULLVIEW_KEY = "Feature.Avatar.Label.ReturnToEdit"
local NOT_IN_FULLVIEW_KEY = "Feature.Avatar.Label.FullView"

function AEConsoleFullViewButton:init()
	self.buttonRef = Roact.createRef()
end

function AEConsoleFullViewButton:didMount()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	self.fullViewButtonEnterTween =
		TweenService:Create(self.buttonRef.current, tweenInfo, { Position = UDim2.new(0.5, -110, 1, -60) })
	self.fullViewButtonExitTween =
		TweenService:Create(self.buttonRef.current, tweenInfo, { Position = UDim2.new(0.5, 60, 1, -60), })
end

function AEConsoleFullViewButton:render()
	local fullView = self.props.fullView

	return Roact.createElement(AEConsoleButtonUI, {
		buttonRef = self.buttonRef,
		size = UDim2.new(0, 220, 0, 83),
		position = UDim2.new(0.5, 60, 1, -60),
		text = fullView and IN_FULLVIEW_KEY or NOT_IN_FULLVIEW_KEY,
		image = "rbxasset://textures/ui/Shell/ButtonIcons/R3ButtonDark.png",
		textSize = UDim2.new(0, 200, 0, 50),
	})
end

function AEConsoleFullViewButton:didUpdate(prevProps)
	local fullView = self.props.fullView

	if fullView and not prevProps.fullView then
		self.fullViewButtonEnterTween:Play()
	elseif not fullView and prevProps.fullView then
		self.fullViewButtonExitTween:Play()
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			fullView = state.AEAppReducer.AEFullView,
		}
	end
)(AEConsoleFullViewButton)