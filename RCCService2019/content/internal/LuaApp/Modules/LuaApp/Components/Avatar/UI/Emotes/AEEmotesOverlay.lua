local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local RobloxGui = CoreGui.RobloxGui
local Modules = RobloxGui.Modules
local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local Emotes = script.Parent

local AEConstants = require(LuaApp.Components.Avatar.AEConstants)
local AEUtils = require(LuaApp.Components.Avatar.AEUtils)
local EmotesWheel = require(Emotes.AEEmotesWheel)

local EmotesOverlay = Roact.PureComponent:extend("EmotesOverlay")

function EmotesOverlay:render()
    local deviceOrientation = self.props.deviceOrientation
    local categoryPage = AEUtils.getCurrentCategory(self.props.categoryIndex)

	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo =  self._context.AvatarEditorTheme.EmotesOverlay:getThemeInfo(deviceOrientation, themeName)

    local visible = categoryPage.name == AEConstants.EMOTES
    if self.props.fullView then
        visible = false
    end

	return Roact.createElement("Frame", {
        Position = themeInfo.OrientationTheme.OverlayPosition,
        Size = themeInfo.OrientationTheme.OverlaySize,
        BackgroundTransparency = 1,
        Visible = visible,
    }, {
        EmotesWheel = Roact.createElement(EmotesWheel, {
            deviceOrientation = deviceOrientation,
        }),

        AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1,
        }),
    })
end

local function mapStateToProps(state, props)
    return {
        categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
        fullView = state.AEAppReducer.AEFullView,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(EmotesOverlay)
