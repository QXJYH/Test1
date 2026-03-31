local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Modules = CoreGui.RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local RoactRodux = require(CorePackages.RoactRodux)
local Immutable = require(Modules.Common.Immutable)

local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local Colors = require(Modules.LuaApp.Themes.Colors)
local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)

local Constants = require(Modules.LuaApp.Constants)

local ScreenGuiWithBlurControl = require(Modules.LuaApp.Components.ScreenGuiWithBlurControl)
local PlacesListContextualMenu = require(Modules.LuaApp.Components.Home.PlacesListContextualMenu)
local PeopleListContextualMenu = require(Modules.LuaApp.Components.Home.PeopleListContextualMenu)
local GameDetailMoreContextualMenu = require(Modules.LuaApp.Components.GameDetails.GameDetailMoreContextualMenu)
local LeaveRobloxAlert = require(Modules.LuaApp.Components.GameDetails.LeaveRobloxAlert)
local ConfirmSignOut = require(Modules.LuaApp.Components.Login.ConfirmSignOut)
local PurchaseGamePrompt = require(Modules.LuaApp.Components.GameDetails.PurchaseGamePrompt)
local PurchaseGameRobuxShortfallPrompt = require(Modules.LuaApp.Components.GameDetails.PurchaseGameRobuxShortfallPrompt)
local PremiumMigrationNotice = require(Modules.LuaApp.Components.PremiumMigrationNotice)

local FFlagLuaAppEnablePageBlur = settings():GetFFlag("LuaAppEnablePageBlur")
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local UseNewAppStyle = FlagSettings.UseNewAppStyle()

local OverlayWithBackground = {
	[OverlayType.PlacesList] = true,
	[OverlayType.PeopleList] = true,
	[OverlayType.PurchaseGame] = true,
	[OverlayType.PurchaseGameRobuxShortfall] = true,
	[OverlayType.LeaveRobloxAlert] = true,
	[OverlayType.ConfirmSignOut] = true,
	[OverlayType.PremiumMigrationNotice] = true,
}

local OverlayComponent = {
	[OverlayType.PlacesList] = PlacesListContextualMenu,
	[OverlayType.PeopleList] = PeopleListContextualMenu,
	[OverlayType.GameDetailMore] = GameDetailMoreContextualMenu,
	[OverlayType.PurchaseGame] = PurchaseGamePrompt,
	[OverlayType.PurchaseGameRobuxShortfall] = PurchaseGameRobuxShortfallPrompt,
	[OverlayType.LeaveRobloxAlert] = LeaveRobloxAlert,
	[OverlayType.ConfirmSignOut] = ConfirmSignOut,
	[OverlayType.PremiumMigrationNotice] = PremiumMigrationNotice,
}

local CentralOverlay = Roact.PureComponent:extend("CentralOverlay")

function CentralOverlay:render()
	local displayOrder = self.props.displayOrder
	local overlayComponent = self.props.overlayComponent
	local arguments = self.props.arguments
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local shouldCreateBackgroundWrapper = self.props.shouldCreateBackgroundWrapper

	if screenSize.X <= 0 or screenSize.Y <= 0 then
		return nil
	end

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)

	local renderFunction = function(stylePalette)
		local backgroundColor = Colors.Black
		local backgroundTransparency = 0.3
		if stylePalette then
			--Display on top of bottom bar
			safeAreaSize = UDim2.new(0, safeAreaSize.X.Offset, 0, safeAreaSize.Y.Offset + Constants.BOTTOM_BAR_SIZE)
			backgroundColor = stylePalette.Theme.Overlay.Color
			backgroundTransparency = stylePalette.Theme.Overlay.Transparency
		end
		return overlayComponent and Roact.createElement(Roact.Portal, {
			target = CoreGui,
		}, {
			PortalUIForOverlay = Roact.createElement(
				FFlagLuaAppEnablePageBlur and ScreenGuiWithBlurControl or "ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = displayOrder,
			}, {
				OverlayComponent = shouldCreateBackgroundWrapper and Roact.createElement("Frame", {
					Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
					Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = backgroundTransparency,
					BorderSizePixel = 0,
					-- Absorb input
					Active = true,
				}, {
					SafeAreaFrame = Roact.createElement("Frame", {
						Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
						Size = safeAreaSize,
						BackgroundTransparency = 1,
						ClipsDescendants = true,
					}, {
						Prompt = Roact.createElement(overlayComponent, Immutable.JoinDictionaries(arguments, {
							containerWidth = safeAreaSize.X.Offset,
						})),
					}),
				}) or Roact.createElement(overlayComponent, arguments),
			}),
		})
	end
	if UseNewAppStyle then
		return withStyle(renderFunction)
	else
		return renderFunction()
	end
end

CentralOverlay = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local overlayType = state.CentralOverlay.OverlayType

		return {
			overlayComponent = OverlayComponent[overlayType],
			shouldCreateBackgroundWrapper = OverlayWithBackground[overlayType],
			arguments = state.CentralOverlay.Arguments,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
		}
	end
)(CentralOverlay)

return CentralOverlay