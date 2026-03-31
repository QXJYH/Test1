local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local TweenService = game:GetService("TweenService")

local Roact = require(CorePackages.Roact)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local RoactRodux = require(Modules.Common.RoactRodux)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ImageSetButton = require(Modules.LuaApp.Components.ImageSetButton)
local AppPage = require(Modules.LuaApp.AppPage)
local NavigateDown = require(Modules.LuaApp.Thunks.NavigateDown)
local withLocalization = require(Modules.LuaApp.withLocalization)

local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")

local CatalogButton = Roact.PureComponent:extend("CatalogButton")

local CATALOG_ICON = "LuaApp/icons/more_catalog"
local CATALOG_URL = "https://www.roblox.com/catalog"
local CATALOG_KEY = "CommonUI.Features.Label.Catalog"
local SHOP_KEY = "Feature.Avatar.Action.Shop"

local CatalogButtonView = {
	[DeviceOrientationMode.Portrait] = {
        POSITION = UDim2.new(0.67, 0, 0, 24),
        FULLVIEW_POSITION = UDim2.new(0.67, 0, 0, -60)
	},

	[DeviceOrientationMode.Landscape] = {
        POSITION = UDim2.new(0.67, 0, 0, 24),
        FULLVIEW_POSITION = UDim2.new(0.67, 0, 0, -60)
	}
}

function CatalogButton:init()
    self.btnRef = Roact.createRef()
end

function CatalogButton:updateOnFullViewChanged(isFullView)
    local deviceOrientation = self.props.deviceOrientation
    local finalPosition = isFullView and
        CatalogButtonView[deviceOrientation].FULLVIEW_POSITION or
        CatalogButtonView[deviceOrientation].POSITION

        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

        local tweenGoals = {
            Position = finalPosition
        }

        TweenService:Create(self.btnRef.current, tweenInfo, tweenGoals):Play()
end

function CatalogButton:didUpdate(prevProps, prevState)
    if self.props.fullView ~= prevProps.fullView then
        self:updateOnFullViewChanged(self.props.fullView)
    end
end

function CatalogButton:render()
    local deviceOrientation = self.props.deviceOrientation

    local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil

    local themeInfo = FFlagAvatarEditorEnableThemes and
        self._context.AvatarEditorTheme.CatalogButton:getThemeInfo(nil, themeName) or nil

    local renderButton = function(localized)
        local Button = Roact.createElement(ImageSetButton, {
            Position = CatalogButtonView[deviceOrientation].POSITION,
            Size = UDim2.new(0.3, 0, 0, 30),
            AutoButtonColor = false,
            BackgroundColor3 = Color3.new(255, 255, 255),
            BackgroundTransparency = 1,
            Image = 'LuaApp/buttons/buttonFill',
            ImageColor3 = FFlagAvatarEditorEnableThemes and
                themeInfo.ColorTheme.BackgroundColor or
                Color3.new(255, 255, 255),
            BorderColor3 = Color3.new(27, 42, 53),
            BorderSizePixel = 0,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(8, 8, 9, 9),
            [Roact.Event.Activated] = function()
                self.props.navigateDown({
                    name = AppPage.GenericWebPage,
                    detail = CATALOG_URL,
                    extraProps = {
                        titleKey = CATALOG_KEY
                    },
                })
            end,
            [Roact.Ref] = self.btnRef
        }, {
            Icon = Roact.createElement(ImageSetLabel, {
                Image = CATALOG_ICON,
                ImageColor3 = FFlagAvatarEditorEnableThemes and
                    themeInfo.ColorTheme.IconColor or
                    Color3.new(0, 0, 0),
                Position = UDim2.new(0.05, 0, 0.075, 0),
                Size = UDim2.new(0, 25, 0, 25),
                BackgroundTransparency = 1
            }),
            Text = Roact.createElement("TextLabel", {
                Text = localized.shopText,
                Position = UDim2.new(0.43, 0, 0, 0),
                Size = UDim2.new(0, 42, 0, 30),
                BackgroundTransparency = 1,
                Font = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
                TextScaled = true,
                TextColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.IconColor or Color3.fromRGB(0, 0, 0)
            })
        })
        return Button
    end

    return withLocalization({
        shopText = SHOP_KEY
    })(function(localized)
        return renderButton(localized)
    end)
end

CatalogButton = RoactRodux.UNSTABLE_connect2(
    function(state, props)
        return {
                fullView = state.AEAppReducer.AEFullView,
                state = state
            }
	end,
	function(dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end
		}
	end
)(CatalogButton)

return CatalogButton