--
-- Contextual List Menu
--
-- This Contextual List Menu supports irregular menu item
--

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local UIBlox = require(CorePackages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Constants = require(Modules.LuaApp.Constants)
local FlagSettings = require(Modules.LuaApp.FlagSettings)
local getSafeAreaSize = require(Modules.LuaApp.getSafeAreaSize)
local Colors = require(Modules.LuaApp.Themes.Colors)

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local FitChildren = require(LuaApp.FitChildren)
local FormFactor = require(LuaApp.Enum.FormFactor)
local FramePopOut = require(LuaApp.Components.FramePopOut)
local FramePopup = require(LuaApp.Components.FramePopup)

local UseNewAppStyle = FlagSettings.UseNewAppStyle()

-- TODO SOC-3214: Change this file name to ContextualMenu
local ContextualListMenu = Roact.PureComponent:extend("ContextualListMenu")

local WIDE_MENU_DEFAULT_WIDTH = Constants.DEFAULT_WIDE_CONTEXTUAL_MENU__WIDTH

ContextualListMenu.defaultProps = {
	menuWidth = WIDE_MENU_DEFAULT_WIDTH,
}

function ContextualListMenu:render()
	local components = self.props[Roact.Children] or {}
	local callbackCancel = self.props.callbackCancel
	local formFactor = self.props.formFactor
	local screenSize = self.props.screenSize
	local globalGuiInset = self.props.globalGuiInset
	local menuWidth = self.props.menuWidth
	local screenShape = self.props.screenShape

	local isWideView = formFactor == FormFactor.WIDE

	if screenSize.X <= 0 or screenSize.Y <= 0 then
		return nil
	end

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)

	components["Layout"] = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local listMenuContents = Roact.createElement(FitChildren.FitFrame, {
		BackgroundTransparency = 1,
		fitAxis = FitChildren.FitAxis.Height,
		Size = UDim2.new(1, 0, 0, 0),
	}, components)

	local portalContents
	if isWideView then
		portalContents = Roact.createElement(FramePopOut, {
			itemWidth = menuWidth,
			onCancel = callbackCancel,
			parentShape = screenShape,
		}, {
			Content = listMenuContents,
		})
	else
		portalContents = Roact.createElement(FramePopup, {
			onCancel = callbackCancel,
		}, {
			Content = listMenuContents,
		})
	end

	if UseNewAppStyle then
		local newSafeAreaSize = UDim2.new(0, safeAreaSize.X.Offset, 0, safeAreaSize.Y.Offset + Constants.BOTTOM_BAR_SIZE)
		return withStyle(function(style)
			return Roact.createElement(Roact.Portal, {
				target = CoreGui,
			}, {
				PortalUI = Roact.createElement("ScreenGui", {
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					DisplayOrder = Constants.DisplayOrder.ContextualListMenu,
				}, {
					Content = Roact.createElement("Frame", {
						Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
						Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
						BackgroundColor3 = style.Theme.Overlay.Color,
						BackgroundTransparency = style.Theme.Overlay.Transparency,
						BorderSizePixel = 0,
						-- Absorb input
						Active = true,
					}, {
						SafeAreaFrame = Roact.createElement("Frame", {
							Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
							Size = newSafeAreaSize,
							BackgroundTransparency = 1,
							ClipsDescendants = true,
						}, {
							Content = portalContents,
						}),
					}),
				}),
			})
		end)
	else
		return Roact.createElement(Roact.Portal, {
			target = CoreGui,
		}, {
			PortalUI = Roact.createElement("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = Constants.DisplayOrder.ContextualListMenu,
			}, {
				Content = Roact.createElement("Frame", {
					Position = UDim2.new(0, -globalGuiInset.left, 0, -globalGuiInset.top),
					Size = UDim2.new(0, screenSize.X, 0, screenSize.Y),
					BackgroundColor3 = Colors.Black,
					BackgroundTransparency = 0.3,
					BorderSizePixel = 0,
					-- Absorb input
					Active = true,
				}, {
					SafeAreaFrame = Roact.createElement("Frame", {
						Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
						Size = safeAreaSize,
						BackgroundTransparency = 1,
					}, {
						Content = portalContents,
					}),
				}),
			}),
		})
	end
end

ContextualListMenu = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
			screenSize = state.ScreenSize,
			globalGuiInset = state.GlobalGuiInset,
		}
	end
)(ContextualListMenu)

return ContextualListMenu
