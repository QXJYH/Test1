local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local FitChildren = require(Modules.LuaApp.FitChildren)

local FramePopOut = require(Modules.LuaApp.Components.FramePopOut)
local FramePopup = require(Modules.LuaApp.Components.FramePopup)

local CloseCentralOverlay = require(Modules.LuaApp.Thunks.CloseCentralOverlay)

local FormBasedContextualMenu = Roact.PureComponent:extend("FormBasedContextualMenu")

function FormBasedContextualMenu:render()
	local anchorSpaceSize = self.props.anchorSpaceSize
	local anchorSpacePosition = self.props.anchorSpacePosition
	local itemWidth = self.props.itemWidth
	local children = self.props[Roact.Children]

	local screenSize = self.props.screenSize
	local formFactor = self.props.formFactor
	local closeContextualMenu = self.props.closeContextualMenu

	local isWideView = formFactor == FormFactor.WIDE
	local modalComponent = isWideView and FramePopOut or FramePopup

	return Roact.createElement(modalComponent, {
		onCancel = closeContextualMenu,
		itemWidth = itemWidth,
		parentShape = {
			x = anchorSpacePosition.X,
			y = anchorSpacePosition.Y,
			width = anchorSpaceSize.X,
			height = anchorSpaceSize.Y,
			parentWidth = screenSize.X,
			parentHeight = screenSize.Y,
		},
	}, {
		Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			fitAxis = FitChildren.FitAxis.Height,
			Size = UDim2.new(0, itemWidth, 0, 0),
		}, children),
	})
end

function FormBasedContextualMenu:didUpdate(prevProps, prevState)
	local closeContextualMenu = self.props.closeContextualMenu

	if prevProps.currentRoute ~= self.props.currentRoute then
		closeContextualMenu()
	end
end

FormBasedContextualMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
			currentRoute = state.Navigation.history[#state.Navigation.history],
		}
	end,
	function(dispatch)
		return {
			closeContextualMenu = function()
				dispatch(CloseCentralOverlay())
			end,
		}
	end
)(FormBasedContextualMenu)

return FormBasedContextualMenu
