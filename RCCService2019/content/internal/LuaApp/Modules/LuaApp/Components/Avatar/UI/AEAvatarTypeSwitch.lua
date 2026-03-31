local Modules = game:GetService("CoreGui"):FindFirstChild("RobloxGui").Modules
local TweenService = game:GetService("TweenService")
local CorePackages = game:GetService("CorePackages")

local LocalizedFitTextLabel = require(Modules.LuaApp.Components.LocalizedFitTextLabel)
local AESetAvatarType = require(Modules.LuaApp.Thunks.AEThunks.AESetAvatarType)
local AESendAnalytics = require(Modules.LuaApp.Thunks.AEThunks.AESendAnalytics)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local FitChildren = require(Modules.LuaApp.FitChildren)

local AEToggleFullView = require(Modules.LuaApp.Actions.AEActions.AEToggleFullView)
local FIntAvatarEditorNewCatalog = require(CorePackages.AppTempCommon.LuaApp.Flags.AvatarEditorNewCatalogEnabled)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorGothamFont = settings():GetFFlag("AvatarEditorGothamFont")
local FFlagAvatarEditorRTranslations = settings():GetFFlag("AvatarEditorRTranslations")
local FFlagAvatarEditorSimultaneousFullViewAvatarTypeFix = settings():GetFFlag("AvatarEditorSimultaneousFullViewAvatarTypeFix")

local R6_TEXT = "R6"
local R15_TEXT = "R15"
local PADDING = 4

local View = {
	[DeviceOrientationMode.Portrait] = {
		POSITION = FFlagAvatarEditorRTranslations and
			UDim2.new(1, -20, 0, 24) or
			UDim2.new(1, -88, 0, 24),
		FULLVIEW_POSITION = UDim2.new(1, -88, 0, -60),
		OFF_COLOR = Color3.new(0.44, 0.44, 0.44),
		ON_COLOR = Color3.new(1, 1, 1),
		TEXT_SIZE = FFlagAvatarEditorGothamFont and 14 or 18,
		PAGE_LABEL_SIZE = 31,
	},

	[DeviceOrientationMode.Landscape] = {
		POSITION = FFlagAvatarEditorRTranslations and
			UDim2.new(1, -20, 0, 24) or
			UDim2.new(1, -88, 0, 24),
		FULLVIEW_POSITION = UDim2.new(1, -88, 0, -60),
		OFF_COLOR = Color3.fromRGB(182, 182, 182),
		ON_COLOR = Color3.new(1, 1, 1),
		TEXT_SIZE = FFlagAvatarEditorGothamFont and 14 or 18,
		PAGE_LABEL_SIZE = 0,
	}
}

local AEAvatarTypeSwitch = Roact.PureComponent:extend("AEAvatarTypeSwitch")

AEAvatarTypeSwitch.defaultProps = {
    index = 0,
}

-- Update the position of the R6/R15 button when going into the full view.
function AEAvatarTypeSwitch:updateOnFullViewChanged(isFullView)
	local deviceOrientation = self.props.deviceOrientation
	local finalPosition = isFullView and
		View[deviceOrientation].FULLVIEW_POSITION or
		View[deviceOrientation].POSITION

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

	local tweenGoals = {
		Position = finalPosition
	}

	TweenService:Create(self.avatarTypeFrame.current, tweenInfo, tweenGoals):Play()
end

function AEAvatarTypeSwitch:updateAvatarType()
	local avatarType = self.props.avatarType
	local positionGoal = avatarType == AEConstants.AvatarType.R6 and UDim2.new(0, 2, 0, 2) or UDim2.new(1, -32, 0, 2)
	if FFlagAvatarEditorRTranslations and avatarType == AEConstants.AvatarType.R15 then
		positionGoal = self.R15SwitchPosition
	end
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	local tweenGoals = {
		Position = positionGoal
	}

	TweenService:Create(self.toggleLabel.current, tweenInfo, tweenGoals):Play()
	if FFlagAvatarEditorSimultaneousFullViewAvatarTypeFix and self.props.fullView then
		-- Toggle back to non-fullview to prevent simultaneous click fullview camera bug
		self.props.toggleFullView()
	end
end

-- Connect to the store to change the avatar type
function AEAvatarTypeSwitch:onAvatarTypeClicked()
	local sendAnalytics = self.props.sendAnalytics
	local analytics = self.props.analytics
	local setAvatarType = self.props.setAvatarType
	local newAvatarType = self.props.avatarType == AEConstants.AvatarType.R6
		and AEConstants.AvatarType.R15 or AEConstants.AvatarType.R6

	setAvatarType(newAvatarType)
	sendAnalytics(analytics.toggleAvatarType, newAvatarType)
end

function AEAvatarTypeSwitch:init()
	self.AvatarEditorNewCatalogButtonFlag = FIntAvatarEditorNewCatalog(self.props.localUserId)
	self.avatarTypeFrame = Roact.createRef()
	self.toggleLabel = Roact.createRef()
	local avatarType = self.props.avatarType
	local initialSwitchPosition = avatarType == AEConstants.AvatarType.R6
		and UDim2.new(0, 2, 0, 2) or UDim2.new(1, -32, 0, 2)

	if FFlagAvatarEditorRTranslations then
		self.avatarTypeLabelRef = Roact.createRef()

		if avatarType == AEConstants.AvatarType.R15 then
			-- Note: Initial position cannot be a scale value or else fitChildren will elongate
			initialSwitchPosition = UDim2.new(0,0,0,0)
		end
	end

	self.state = {
		toggleLabelPosition = initialSwitchPosition,
	}
end

function AEAvatarTypeSwitch:didUpdate(prevProps, prevState)
	if self.props.avatarType ~= prevProps.avatarType then
		self:updateAvatarType()
	elseif not self.AvatarEditorNewCatalogButtonFlag and self.props.fullView ~= prevProps.fullView then
		self:updateOnFullViewChanged(self.props.fullView)
	end
end

function AEAvatarTypeSwitch:didMount()
	if FFlagAvatarEditorRTranslations then
		local avatarTypeLabelRef = self.avatarTypeLabelRef.current
		local R15TogglePositionX = avatarTypeLabelRef.AbsoluteSize.X / 2
		self.R15SwitchPosition = UDim2.new(0, R15TogglePositionX, 0, 2)
		self:updateAvatarType()
	end
end

function AEAvatarTypeSwitch:render()
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = FFlagAvatarEditorEnableThemes and
		self._context.AvatarEditorTheme.AEAvatarTypeSwitch:getThemeInfo(self.props.deviceOrientation, themeName) or nil
	local toggleLabelPosition = self.state.toggleLabelPosition
	local deviceOrientation = self.props.deviceOrientation
	local avatarType = self.props.avatarType
	local switchImage = AESpriteSheet.getImage("ctn-toggle")
	local buttonToggleImage = AESpriteSheet.getImage("btn-toggle")
	local r6LabelTextColor
	local r15LabelTextColor

	local sliderTheme = FFlagAvatarEditorEnableThemes and themeInfo.OrientationTheme.SliderFrame or nil
	local sliderPosition = (sliderTheme and self.AvatarEditorNewCatalogButtonFlag) and
		UDim2.new(sliderTheme.PosXScale, sliderTheme.PosXOffset, 0,
		sliderTheme.PosY * self.props.index - View[self.props.deviceOrientation].PAGE_LABEL_SIZE) or nil

	local txtColor
	if FFlagAvatarEditorEnableThemes then
		txtColor = self.AvatarEditorNewCatalogButtonFlag and
			themeInfo.ColorTheme.InactiveTextColorSlider or
			themeInfo.ColorTheme.InactiveTextColor
	end

	if avatarType == AEConstants.AvatarType.R6 then
		r6LabelTextColor = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.ActiveTextColor or View[deviceOrientation].ON_COLOR
		r15LabelTextColor = FFlagAvatarEditorEnableThemes
			and txtColor or View[deviceOrientation].OFF_COLOR
	else
		r6LabelTextColor = FFlagAvatarEditorEnableThemes
			and txtColor or View[deviceOrientation].OFF_COLOR
		r15LabelTextColor = FFlagAvatarEditorEnableThemes
			and themeInfo.ColorTheme.ActiveTextColor or View[deviceOrientation].ON_COLOR
	end

	if FFlagAvatarEditorEnableThemes then
		switchImage.imageRectSize = nil
		switchImage.imageRectOffset = nil
		buttonToggleImage.imageRectSize = nil
		buttonToggleImage.imageRectOffset = nil
	end

	-- Create all the UI elements.
	local outColor
	if FFlagAvatarEditorEnableThemes then
		outColor = self.AvatarEditorNewCatalogButtonFlag and
			themeInfo.ColorTheme.OuterColorSlider or
			themeInfo.ColorTheme.OuterColor
	end
	if FFlagAvatarEditorRTranslations then
		return Roact.createElement(FitChildren.FitImageButton, {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 64, 0, 28),
			Position = sliderPosition and sliderPosition or View[deviceOrientation].POSITION,
			Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-toggle-outter' or switchImage.image,
			ImageColor3 = FFlagAvatarEditorEnableThemes
				and outColor or Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.new(255, 255, 255),
			BorderColor3 = Color3.new(27, 42, 53),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ImageRectOffset = switchImage.imageRectOffset,
			ImageRectSize = switchImage.imageRectSize,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = FFlagAvatarEditorEnableThemes and Rect.new(14, 13, 15, 15) or switchImage.sliceCenter,
			fitFields = {
				Size = FitChildren.FitAxis.Both,
			},
			[Roact.Ref] = self.avatarTypeFrame,
		}, {
			Switch = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
				Size = UDim2.new(0.5, 0, 1, -1 * PADDING),
				Position = toggleLabelPosition,
				BorderColor3 = Color3.new(27, 42, 53),
				BackgroundColor3 = Color3.new(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-toggle-inner' or buttonToggleImage.image,
				ImageColor3 = FFlagAvatarEditorEnableThemes
					and themeInfo.ColorTheme.InnerColor or Color3.fromRGB(255, 255, 255),
				ImageRectOffset = buttonToggleImage.imageRectOffset,
				ImageRectSize = buttonToggleImage.imageRectSize,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = FFlagAvatarEditorEnableThemes and Rect.new(12, 11, 13, 13) or buttonToggleImage.sliceCenter,
				[Roact.Ref] = self.toggleLabel,
			}),
			ButtonContainer = Roact.createElement("ImageButton", {
				BackgroundColor3 = Color3.new(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.new(27, 42, 53),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				[Roact.Event.Activated] = function(rbx)
					self:onAvatarTypeClicked()
				end,
			}),
			AvatarTypeLabels = Roact.createElement(FitChildren.FitFrame, {
				Size = UDim2.new(0,0,1,0),
				fitAxis = FitChildren.FitAxis.Both,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				[Roact.Ref] = self.avatarTypeLabelRef,
			},{
				UIPadding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingTop = UDim.new(0, PADDING),
					PaddingBottom = UDim.new(0, PADDING),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				R15Label = Roact.createElement(LocalizedFitTextLabel, {
					AnchorPoint = Vector2.new(0,0.5),
					BorderColor3 = Color3.new(27, 42, 53),
					BackgroundColor3 = Color3.new(101, 243, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
					LayoutOrder = 1,
					Text = "Feature.Avatar.Label.R15",
					TextSize = View[deviceOrientation].TEXT_SIZE,
					TextColor3 = r15LabelTextColor,
					fitAxis = FitChildren.FitAxis.Both,
				}),
				R6Label = Roact.createElement(LocalizedFitTextLabel, {
					AnchorPoint = Vector2.new(0,0.5),
					BorderColor3 = Color3.new(27, 42, 53),
					BackgroundColor3 = Color3.new(101, 243, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
					LayoutOrder = 0,
					Text = "Feature.Avatar.Label.R6",
					TextSize = View[deviceOrientation].TEXT_SIZE,
					TextColor3 = r6LabelTextColor,
					fitAxis = FitChildren.FitAxis.Both,
				}),
			})
		})
	else
		return Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			Size = UDim2.new(0, 64, 0, 28),
			Position = sliderPosition and sliderPosition or View[deviceOrientation].POSITION,
			Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-toggle-outter' or switchImage.image,
			ImageColor3 = FFlagAvatarEditorEnableThemes
				and outColor or Color3.fromRGB(255, 255, 255),
			BackgroundColor3 = Color3.new(255, 255, 255),
			BorderColor3 = Color3.new(27, 42, 53),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = self.AvatarEditorNewCatalogButtonFlag and 2 or 1,
			ImageRectOffset = switchImage.imageRectOffset,
			ImageRectSize = switchImage.imageRectSize,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = FFlagAvatarEditorEnableThemes and Rect.new(14, 13, 15, 15) or switchImage.sliceCenter,

			[Roact.Ref] = self.avatarTypeFrame,
		}, {
			Switch = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
				Size = UDim2.new(0, 30, 0, 24),
				Position = toggleLabelPosition,
				BorderColor3 = Color3.new(27, 42, 53),
				BackgroundColor3 = Color3.new(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = FFlagAvatarEditorEnableThemes and 'AE/Graphic/gr-toggle-inner' or buttonToggleImage.image,
				ImageColor3 = FFlagAvatarEditorEnableThemes
					and themeInfo.ColorTheme.InnerColor or Color3.fromRGB(255, 255, 255),
				ImageRectOffset = buttonToggleImage.imageRectOffset,
				ImageRectSize = buttonToggleImage.imageRectSize,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = FFlagAvatarEditorEnableThemes and Rect.new(12, 11, 13, 13) or buttonToggleImage.sliceCenter,

				[Roact.Ref] = self.toggleLabel,
			}),
			ButtonContainer = Roact.createElement("ImageButton", {
				BackgroundColor3 = Color3.new(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.new(27, 42, 53),
				BorderSizePixel = 0,
				Size = UDim2.new(1.4, 0, 1.4, 0),
				Position = UDim2.new(-0.2, 0, -0.2, 0),

				[Roact.Event.Activated] = function(rbx)
					self:onAvatarTypeClicked()
				end,
			}),
			R15Label = Roact.createElement("TextLabel", {
				BorderColor3 = Color3.new(27, 42, 53),
				BackgroundColor3 = Color3.new(101, 243, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -33, 0, 0),
				Size = UDim2.new(0, 32, 1, -1),
				Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
				Text = R15_TEXT,
				TextSize = View[deviceOrientation].TEXT_SIZE,
				TextColor3 = r15LabelTextColor,
			}),
			R6Label = Roact.createElement("TextLabel", {
				BorderColor3 = Color3.new(27, 42, 53),
				BackgroundColor3 = Color3.new(101, 243, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 32, 1, -1),
				Font = FFlagAvatarEditorGothamFont and themeInfo.ColorTheme.Text.Font or Enum.Font.SourceSans,
				Text = R6_TEXT,
				TextSize = View[deviceOrientation].TEXT_SIZE,
				TextColor3 = r6LabelTextColor,
			}),
		})
	end
end

return RoactRodux.UNSTABLE_connect2(function(state, props)
	return {
			avatarType = state.AEAppReducer.AECharacter.AEAvatarType,
			fullView = state.AEAppReducer.AEFullView,
			resolutionScale = state.AEAppReducer.AEResolutionScale,
			--remove localUserId when removing flag FIntAvatarEditorNewCatalog
			localUserId = state.LocalUserId,
		}
	end,

	function(dispatch)
		return {
			setAvatarType = function(newAvatarType)
				dispatch(AESetAvatarType(newAvatarType))
			end,
			sendAnalytics = function(analyticsFunction, value)
				dispatch(AESendAnalytics(analyticsFunction, value))
			end,
			toggleFullView = function()
				dispatch(AEToggleFullView())
			end,
		}
	end
)(AEAvatarTypeSwitch)