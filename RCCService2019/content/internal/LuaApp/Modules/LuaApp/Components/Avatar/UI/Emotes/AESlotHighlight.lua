local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local RobloxGui = CoreGui.RobloxGui
local Modules = RobloxGui.Modules
local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local AEConstants = require(LuaApp.Components.Avatar.AEConstants)
local AEUtils = require(LuaApp.Components.Avatar.AEUtils)

local SlotHighlight = Roact.PureComponent:extend("SlotHighlight")

function SlotHighlight:render()
    local deviceOrientation = self.props.deviceOrientation
    local categoryPage = AEUtils.getCurrentCategory(self.props.categoryIndex)

	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo =  self._context.AvatarEditorTheme.EmotesWheel:getThemeInfo(deviceOrientation, themeName)

    local focusedIndex = 0
    if categoryPage.name == AEConstants.EMOTES then
        focusedIndex = self.props.tabsInfo[self.props.categoryIndex]
    end

    local segmentAngle = 360 / AEConstants.EmotesConstants.EmotesPerPage
    local angle = segmentAngle * (focusedIndex - 1) + AEConstants.EmotesConstants.SegmentsStartRotation
    local highlightImageSize = themeInfo.OrientationTheme.HighlightImageSize

    return Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Rotation = angle,
        Visible = focusedIndex ~= 0,
    }, {
        HighlightImage = Roact.createElement("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = themeInfo.OrientationTheme.HighlightImage,
        }, {
            AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = highlightImageSize.X / highlightImageSize.Y,
            }),

            SizeConstraint = Roact.createElement("UISizeConstraint", {
                MaxSize = highlightImageSize,
            }),
        }),
    })
end

local function mapStateToProps(state, props)
    return {
        categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
        tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(SlotHighlight)