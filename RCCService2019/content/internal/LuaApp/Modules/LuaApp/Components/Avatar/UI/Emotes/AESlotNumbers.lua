local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local RobloxGui = CoreGui.RobloxGui
local Modules = RobloxGui.Modules
local LuaApp = Modules.LuaApp

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local AEConstants = require(LuaApp.Components.Avatar.AEConstants)
local AEUtils = require(LuaApp.Components.Avatar.AEUtils)

local SlotNumbers = Roact.PureComponent:extend("SlotNumbers")

function SlotNumbers:render()
    local deviceOrientation = self.props.deviceOrientation
    local categoryPage = AEUtils.getCurrentCategory(self.props.categoryIndex)

	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo =  self._context.AvatarEditorTheme.EmotesWheel:getThemeInfo(deviceOrientation, themeName)

    local focusedIndex = 0
    if categoryPage.name == AEConstants.EMOTES then
        focusedIndex = self.props.tabsInfo[self.props.categoryIndex]
    end

    local slotNumbers = {}

    for slotIndex = 1, AEConstants.EmotesConstants.EmotesPerPage do
        local segmentAngle = 360 / AEConstants.EmotesConstants.EmotesPerPage
        local angle = segmentAngle * (slotIndex - 1) + AEConstants.EmotesConstants.SegmentsStartRotation
        local radius = AEConstants.EmotesConstants.InnerCircleSizeRatio / 2

        local numberSize = AEConstants.EmotesConstants.SlotNumberSize
        local numberPadding = numberSize / 2 - AEConstants.EmotesConstants.SlotNumberOffset

        local cos = math.cos(math.rad(angle))
        local xRadiusPos = radius * cos

        local xPadding = numberPadding * cos
        local xPos = 0.5 + xRadiusPos + xPadding

        local sin = math.sin(math.rad(angle))
        local yRadiusPos = radius * sin

        local yPadding = numberPadding * sin
        local yPos = 0.5 + yRadiusPos + yPadding

        local textTransparency = 0
        if focusedIndex ~= slotIndex and not self.props.slotInfo[slotIndex] then
            textTransparency = 0.5
        end

        slotNumbers[slotIndex] = Roact.createElement("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(xPos, 0, yPos, 0),
            Size = UDim2.new(numberSize, 0, numberSize, 0),

            BackgroundTransparency = 1,

            TextScaled = true,
            TextSize = themeInfo.OrientationTheme.SlotNumberTextSize,
            TextTransparency = textTransparency,
            TextColor3 = Color3.new(1, 1, 1),
            Text = slotIndex,
            Font = themeInfo.OrientationTheme.SlotNumberFont,
        }, {
            TextSizeConstraint = Roact.createElement("UITextSizeConstraint", {
                MaxTextSize = themeInfo.OrientationTheme.SlotNumberTextSize,
            }),
        })
    end

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
    }, slotNumbers)
end

local function mapStateToProps(state)
    return {
        slotInfo = state.AEAppReducer.AEEquippedEmotes.slotInfo,
        categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
        tabsInfo = state.AEAppReducer.AECategory.AETabsInfo,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(SlotNumbers)