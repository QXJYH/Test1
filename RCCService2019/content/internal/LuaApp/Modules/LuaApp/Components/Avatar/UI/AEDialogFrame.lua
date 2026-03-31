local Modules = game:GetService("CoreGui").RobloxGui.Modules
local TweenService = game:GetService("TweenService")
local CorePackages = game:GetService("CorePackages")

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local RoactServices = require(Modules.LuaApp.RoactServices)
local RoactAnalyticsAvatarEditorPage = require(Modules.LuaApp.Services.RoactAnalyticsAvatarEditorPage)
local RoactAppPolicy = require(Modules.LuaApp.RoactAppPolicy)

local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AEScreenRouter = require(Modules.LuaApp.Components.Avatar.AEScreenRouter)
local TopBar = require(Modules.LuaApp.Components.TopBar)
local AEScrollingFrame = require(Modules.LuaApp.Components.Avatar.UI.AEScrollingFrame)
local AEHatsColumn = require(Modules.LuaApp.Components.Avatar.UI.AEHatsColumn)
local AEFullViewButton = require(Modules.LuaApp.Components.Avatar.UI.AEFullViewButton)
local AEAvatarTypeSwitch = require(Modules.LuaApp.Components.Avatar.UI.AEAvatarTypeSwitch)
local AEDarkCover = require(Modules.LuaApp.Components.Avatar.UI.AEDarkCover)
local CommonConstants = require(Modules.LuaApp.Constants)
local AECategoryMenu = require(Modules.LuaApp.Components.Avatar.UI.AECategoryMenu)
local AppPage = require(Modules.LuaApp.AppPage)
local AppPageLocalizationKeys = require(Modules.LuaApp.AppPageLocalizationKeys)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AEWarningWidget = require(Modules.LuaApp.Components.Avatar.UI.AEWarningWidget)
local AEAssetDetailsWindow = require(Modules.LuaApp.Components.Avatar.UI.AEAssetDetailsWindow)
local AEEquipAsset = require(Modules.LuaApp.Components.Avatar.UI.AEEquipAsset)
local EmotesOverlay = require(Modules.LuaApp.Components.Avatar.UI.Emotes.AEEmotesOverlay)
local CatalogButton = require(Modules.LuaApp.Components.Avatar.UI.CatalogButton)
local FIntAvatarEditorNewCatalog = require(CorePackages.AppTempCommon.LuaApp.Flags.AvatarEditorNewCatalogEnabled)

local CURRENT_PAGE = AppPage.AvatarEditor

local FFlagLuaAppAEUseAppPolicyForShowingBuyRobuxOnTopBar =
	settings():GetFFlag("LuaAppAEUseAppPolicyForShowingBuyRobuxOnTopBar")
local FFlagLuaAppPolicyRoactConnector = settings():GetFFlag("LuaAppPolicyRoactConnector")

local AEDialogFrame = Roact.PureComponent:extend("AEDialogFrame")

local View = {
	[DeviceOrientationMode.Portrait] = {
		RIGHT_FRAME_SIZE = UDim2.new(1, 0, .5, 50),
		RIGHT_FRAME_POSITION = UDim2.new(0, 0, .5, -50),
		RIGHT_FRAME_FULLVIEW_POSITION = UDim2.new(0, 0, 1, 10),
		LEFT_FRAME_SIZE = UDim2.new(1, 0, .5, -50),
		BACKGROUND_TRANSPARENCY = 0,
		BACKGROUND_COLOR = CommonConstants.Color.GRAY4,
	},

	[DeviceOrientationMode.Landscape] = {
		RIGHT_FRAME_SIZE = UDim2.new(.5, 60, 1, 0),
		RIGHT_FRAME_POSITION = UDim2.new(.5, -60, 0, 0),
		RIGHT_FRAME_FULLVIEW_POSITION = UDim2.new(1, 10, 0, 0),
		LEFT_FRAME_SIZE = UDim2.new(.5, -60, 1, 0),
		BACKGROUND_TRANSPARENCY = 0.5,
		BACKGROUND_COLOR = Color3.new(),
	},
}

function AEDialogFrame:init()
	self.AvatarEditorNewCatalogButtonFlag = FIntAvatarEditorNewCatalog(self.props.localUserId)
end

function AEDialogFrame:didUpdate(prevProps, prevState)
	local deviceOrientation = self.props.deviceOrientation
	local finalPosition = self.props.fullView and
		View[deviceOrientation].RIGHT_FRAME_FULLVIEW_POSITION or
		View[deviceOrientation].RIGHT_FRAME_POSITION

	if prevProps.deviceOrientation ~= self.props.deviceOrientation then
		self.rightFrame.Position = finalPosition
	elseif prevProps.fullView ~= self.props.fullView then
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

		TweenService:Create(self.rightFrame, tweenInfo, {
			Position = finalPosition,
		}):Play()
	end
end

function AEDialogFrame:render()
	local deviceOrientation = self.props.deviceOrientation
	local AETabList = AEScreenRouter:GetView(AEScreenRouter.Intent.AETabList, AEScreenRouter.RouteMaps[deviceOrientation])
	local analytics = self.props.analytics
	local topBarHeight = self.props.topBarHeight

	local showBuyRobuxOnTopBar
	if FFlagLuaAppAEUseAppPolicyForShowingBuyRobuxOnTopBar then
		showBuyRobuxOnTopBar = self.props.showBuyRobuxOnTopBar
	else
		showBuyRobuxOnTopBar = true
	end

	local avatarHeaderIcon = self.props.avatarHeaderIcon

	local baseFrame = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1.0,
	}, {

		TopBar = Roact.createElement(TopBar, {
			LayoutOrder = 1,
			backButtonImage = avatarHeaderIcon,
			showBuyRobux = showBuyRobuxOnTopBar,
			showNotifications = true,
			showSearch = false,
			textKey = AppPageLocalizationKeys[CURRENT_PAGE],
		}),

		Frame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -topBarHeight),
			Position = UDim2.new(0, 0, 0, topBarHeight),
			BackgroundTransparency = 1,
		}, {
			DetailsWindowContainer =
				Roact.createElement(AEAssetDetailsWindow, { deviceOrientation = deviceOrientation, }),

			AssetOptionsMenu = Roact.createElement(AEEquipAsset, {
				displayType = AEConstants.EquipAssetTypes.AssetOptionsMenu,
				analytics = analytics,
				deviceOrientation = deviceOrientation,
			}),

			LeftFrame = Roact.createElement("Frame", {
				Size = View[deviceOrientation].LEFT_FRAME_SIZE,
				BackgroundTransparency = 1.0,
			}, {
				AEAvatarTypeSwitch = not self.AvatarEditorNewCatalogButtonFlag and Roact.createElement(AEAvatarTypeSwitch, {
					deviceOrientation = deviceOrientation, analytics = analytics
				}),
				CatalogButton = self.AvatarEditorNewCatalogButtonFlag and Roact.createElement(CatalogButton, {
					deviceOrientation = deviceOrientation,
				}),

				AEWarningWidgetUI = Roact.createElement(AEWarningWidget, {}),
				HatsColumn = Roact.createElement(AEHatsColumn, {
					deviceOrientation = deviceOrientation,
					analytics = analytics
				}),

				EmotesOverlay = Roact.createElement(EmotesOverlay, {
					deviceOrientation = deviceOrientation,
					analytics = analytics,
				})
			}),

			RightFrame = Roact.createElement("Frame", {
				Size = View[deviceOrientation].RIGHT_FRAME_SIZE,
				Position = View[deviceOrientation].RIGHT_FRAME_POSITION,
				BackgroundTransparency = View[deviceOrientation].BACKGROUND_TRANSPARENCY,
				BackgroundColor3 = View[deviceOrientation].BACKGROUND_COLOR,
				Active = true,

				[Roact.Ref] = function(rbx)
					self.rightFrame = rbx
				end,
			}, {
				TabListUI = Roact.createElement(AETabList, { deviceOrientation = deviceOrientation }),

				ScrollingFrame = Roact.createElement(AEScrollingFrame, {
					deviceOrientation = deviceOrientation,
					analytics = analytics
				}),
			}),

			CategoryMenuUI = Roact.createElement(AECategoryMenu,{
				analytics = analytics,
				deviceOrientation = deviceOrientation,
				size = View[deviceOrientation].RIGHT_FRAME_SIZE,
				position = View[deviceOrientation].RIGHT_FRAME_POSITION,
				fullViewPosition = View[deviceOrientation].RIGHT_FRAME_FULLVIEW_POSITION,
				zIndex = 3,
			}),

			DarkCover = Roact.createElement(AEDarkCover, {
				deviceOrientation = deviceOrientation,
			}),

			FullViewButton = Roact.createElement(AEFullViewButton, { deviceOrientation = deviceOrientation }),
		}),
	})

	return baseFrame
end

AEDialogFrame = RoactServices.connect({
	analytics = RoactAnalyticsAvatarEditorPage,
})(AEDialogFrame)

AEDialogFrame = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			fullView = state.AEAppReducer.AEFullView,
			topBarHeight = state.TopBar.topBarHeight,
			--remove localUserId when removing flag FIntAvatarEditorNewCatalog
			localUserId = state.LocalUserId,
		}
	end
)(AEDialogFrame)

if FFlagLuaAppPolicyRoactConnector then
	AEDialogFrame = RoactAppPolicy.connect(function(appPolicy, props)
		return {
			showBuyRobuxOnTopBar = appPolicy.getAvatarEditorShowBuyRobuxOnTopBar(),
			avatarHeaderIcon = appPolicy.getAvatarHeaderIcon(),
		}
	end)(AEDialogFrame)
else
	AEDialogFrame = RoactAppPolicy.legacy_connect(function(appPolicy, props)
		return {
			showBuyRobuxOnTopBar = not appPolicy or appPolicy.getAvatarEditorShowBuyRobuxOnTopBar(),
			avatarHeaderIcon = appPolicy and appPolicy.getAvatarHeaderIcon(),
		}
	end)(AEDialogFrame)
end

return AEDialogFrame
