local Modules = game:GetService("CoreGui").RobloxGui.Modules
local TweenService = game:GetService("TweenService")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESetCategoryMenuOpen = require(Modules.LuaApp.Actions.AEActions.AESetCategoryMenuOpen)
local AEToggleAssetOptionsMenu = require(Modules.LuaApp.Actions.AEActions.AEToggleAssetOptionsMenu)
local AEToggleAssetDetailsWindow = require(Modules.LuaApp.Actions.AEActions.AEToggleAssetDetailsWindow)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local AEDarkCover = Roact.PureComponent:extend("AEDarkCover")

function AEDarkCover:render()
	local visible = self.state.visible
	local zIndex = self.props.categoryMenuOpen == AEConstants.CategoryMenuOpen.OPEN and 2 or 3

	local backgroundTransparency = self.state.backgroundTransparency

	return Roact.createElement("ImageButton", {
		BackgroundColor3 = FFlagAvatarEditorEnableThemes and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(25, 25, 25),
		BorderColor3 = FFlagAvatarEditorEnableThemes and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(25, 25, 25),
		Selectable = false,
		Size = UDim2.new(1, 0, 1, 0),
		ImageTransparency = 1,
		AutoButtonColor = false,
		BackgroundTransparency = backgroundTransparency,
		ZIndex = zIndex,
		Visible = visible,

		[Roact.Event.Activated] = function()
			self:hideDarkCover()
		end,

		[Roact.Ref] = self.darkCoverFrame,
	})
end

function AEDarkCover:init()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AEDarkCover:getThemeInfo(nil, themeName) or nil
	self.connections = {}
	self.darkCoverFrame = Roact.createRef()
	self.state = {
		visible = false,
		backgroundTransparency = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Transparency or 0.4,
	}
end

-- Set up the tweens needed, and add any connections to a table.
function AEDarkCover:didMount()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AEDarkCover:getThemeInfo(nil, themeName) or nil
	local hideTweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local hidePropertyGoals = { BackgroundTransparency = 1 }
	local hideTween = TweenService:Create(self.darkCoverFrame.current, hideTweenInfo, hidePropertyGoals)
	local tweenConnection = hideTween.Completed:Connect(function()
		self.darkCoverFrame.current.Visible = false
	end)

	local showTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local backgroundTransparency = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Transparency or 0.4
	local showPropertyGoals = { BackgroundTransparency = backgroundTransparency }
	local showTween = TweenService:Create(self.darkCoverFrame.current, showTweenInfo, showPropertyGoals)

	self.connections[#self.connections + 1] = tweenConnection
	self.hideTween = hideTween
	self.showTween = showTween
end

function AEDarkCover:didUpdate(prevProps, prevState)
	local enabled = (self.props.categoryMenuOpen == AEConstants.CategoryMenuOpen.OPEN)
		or self.props.assetOptionsMenu.enabled or self.props.assetDetailsWindow.enabled

	if enabled then
		self:showDarkCover()
	else
		self:hideDarkCover()
	end

	if prevProps.deviceOrientation ~= self.props.deviceOrientation
		and self.props.categoryMenuOpen == AEConstants.CategoryMenuOpen.OPEN then
		self:hideDarkCover()
	end
end

function AEDarkCover:showDarkCover()
	self.darkCoverFrame.current.Visible = true
	self.showTween:Play()
end

function AEDarkCover:hideDarkCover()
	self.hideTween:Play()
	if self.props.categoryMenuOpen == AEConstants.CategoryMenuOpen.OPEN then
		self.props.closeDarkCover(true, false, false)
	elseif self.props.assetOptionsMenu.enabled then
		self.props.closeDarkCover(false, true, false)
	elseif self.props.assetDetailsWindow.enabled then
		self.props.closeDarkCover(false, false, true)
	end

	self.hideTween:Play()
end

function AEDarkCover:willUnmount()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	self.connections = {}
end

AEDarkCover = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryMenuOpen = state.AEAppReducer.AECategory.AECategoryMenuOpen,
			assetOptionsMenu = state.AEAppReducer.AEAssetOptionsMenu,
			assetDetailsWindow = state.AEAppReducer.AEAssetDetailsWindow,
			deviceOrientation = state.DeviceOrientation,
		}
	end,

	function(dispatch)
		return {
			closeDarkCover = function(closeCategoryMenu, closeAssetOptions, closeAssetDetails)
				if closeCategoryMenu then
					dispatch(AESetCategoryMenuOpen(AEConstants.CategoryMenuOpen.CLOSED))
				elseif closeAssetOptions then
					dispatch(AEToggleAssetOptionsMenu(false, nil))
				elseif closeAssetDetails then
					dispatch(AEToggleAssetDetailsWindow(false, nil))
				end
			end,
		}
	end
)(AEDarkCover)

return AEDarkCover