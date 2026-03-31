local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)

local FullscreenPageWithSafeArea = Roact.PureComponent:extend("FullscreenPageWithSafeArea")

function FullscreenPageWithSafeArea:render()
	local statusBarHeight = self.props.statusBarHeight
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset

	local backgroundColor3 = self.props.BackgroundColor3
	local backgroundTransparency = self.props.BackgroundTransparency
	local includeStatusBar = self.props.includeStatusBar
	local renderFullscreenBackground = self.props.renderFullscreenBackground
	local children = self.props[Roact.Children]

	if screenSize.X == 0 or screenSize.Y == 0 then
		return nil
	end

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)
	local safeAreaPositionY = globalGuiInset.top

	if includeStatusBar then
		safeAreaSize = UDim2.new(0, safeAreaSize.X.Offset, 0, safeAreaSize.Y.Offset - statusBarHeight)
		safeAreaPositionY = safeAreaPositionY + statusBarHeight
	end

	return Roact.createElement("Frame", {
		Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
		Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = backgroundTransparency,
		Active = true,
		BorderSizePixel = 0,
	}, {
		Background = renderFullscreenBackground and renderFullscreenBackground(safeAreaPositionY),
		SafeAreaFrame = Roact.createElement("Frame", {
			Position = UDim2.new(0, globalGuiInset.left, 0, safeAreaPositionY),
			Size = safeAreaSize,
			BackgroundTransparency = 1,
			ZIndex = renderFullscreenBackground and 2 or 1,
		}, children),
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			statusBarHeight = state.TopBar.statusBarHeight,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
		}
	end
)(FullscreenPageWithSafeArea)
