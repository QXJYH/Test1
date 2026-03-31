local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Modules = CoreGui.RobloxGui.Modules
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local FFlagAvatarEditorFixLegCameraPosition = settings():GetFFlag("AvatarEditorFixLegCameraPosition")

local AECameraManager = {}
AECameraManager.__index = AECameraManager

local cameraDefaultFOV = 70
local STANDARD_TOP_BAR_HEIGHT = 64
local FULLVIEW_SCALAR_CONSTANT = 5.5
local SCALAR_CONSTANT = 3.9
local EXTRA_ZOOM_PORTRAIT = 22
local EXTRA_ZOOM_LANDSCAPE = 12
local CONSOLE = "Console"
local MIN_Y_POSITION = 0.7
local MIN_Y_FOCUS_POINT = 0.9
local MAX_Y_POSITION = 8.5
local MAX_Y_FOCUS_POINT = 9

-- Location of the humanoid root part of the default rig in Mobile.rbxl
local DEFAULT_RIG_POSITION = Vector3.new(15.276, 3.71, -16.821)

local themeInfo = {
	[DeviceOrientationMode.Portrait] =
	{
		cameraCenterScreenPosition = UDim2.new(0, 0, -0.5, 40),
		cameraDefaultPosition = Vector3.new(5.4427, 5.1198, -32.4536),
		zoomRadius = function(zoomRadius)
			return zoomRadius
		end,
		scalarConstant = 3.9,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition - UDim2.new(0, 0, 0, STANDARD_TOP_BAR_HEIGHT - topBarHeight)
		end,
	},

	[DeviceOrientationMode.Landscape] =
	{
		cameraCenterScreenPosition = UDim2.new(-0.5, 0, 0, 10),
		cameraDefaultPosition = Vector3.new(11.4540, 4.4313, -24.0810),
		zoomRadius = function(zoomRadius)
			return zoomRadius
		end,
		scalarConstant = 3.9,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition - UDim2.new(0, 0, 0, STANDARD_TOP_BAR_HEIGHT - topBarHeight)
		end,
	},
	[CONSOLE] = {
		cameraCenterScreenPosition = UDim2.new(0, 0, 0, 0),
		cameraDefaultPosition = Vector3.new(11.4540, 4.4313, -24.0810),
		zoomRadius = function(zoomRadius)
			return math.min(7, zoomRadius)
		end,
		scalarConstant = 4.9,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition
		end,
	}
}

local legsFocus = {'RightUpperLeg', 'LeftUpperLeg', 'RightLowerLeg', 'LeftLowerLeg'}

-- List of body parts the camera can focus on
local avatarTypeBodyPartCameraFocus = {
	[AEConstants.AvatarType.R15] = {
		legsFocus = legsFocus,
		faceFocus = {'Head'},
		armsFocus = {'UpperTorso'},
		headWideFocus = {'Head'},
		neckFocus = {'Head', 'UpperTorso'},
		shoulderFocus = {'Head', 'RightUpperArm', 'LeftUpperArm'},
		waistFocus = {'LowerTorso', 'RightUpperLeg', 'LeftUpperLeg'}
	},
	[AEConstants.AvatarType.R6] = {
		legsFocus = {'Right Leg', 'Left Leg'},
		faceFocus = {'Head'},
		armsFocus = {'Torso'},
		headWideFocus = {'Head'},
		neckFocus = {'Head', 'Torso'},
		shoulderFocus = {'Head', 'Right Arm', 'Left Arm'},
		waistFocus = {'Torso', 'Right Leg', 'Left Leg'}
	}
}

local fullViewCameraFieldOfView = 70

local function getFullViewCameraCFrame(topBarHeight, scalar)
	return CFrame.new(
		13.2618074, scalar, -22.701086,
		-0.94241035, 0.0557777137, -0.329775006,
		0.000000000, 0.98599577, 0.166770056,
		0.334458828, 0.157165825, -0.92921263)
end

function AECameraManager.new(store)
	local self = {}
	self.store = store
	self.connections = {}
	setmetatable(self, AECameraManager)

	local camera = game.Workspace.CurrentCamera
	self.camera = camera
	local topBarHeight = self.store:getState().TopBar and self.store:getState().TopBar.topBarHeight or 0

	self.tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
	self.fullViewCameraGoals = {
		CFrame = getFullViewCameraCFrame(topBarHeight, nil),
		FieldOfView = fullViewCameraFieldOfView,
	}
	self.tweenFullView = TweenService:Create(self.camera, self.tweenInfo, self.fullViewCameraGoals)

	return self
end

function AECameraManager:start()
	self.camera.CameraType = Enum.CameraType.Scriptable
	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	table.insert(self.connections, storeChangedConnection)

	local state = self.store:getState()
	local categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex
	local tabIndex = state.AEAppReducer.AECategory.AETabsInfo[categoryIndex]
	local page = AECategories.categories[categoryIndex].pages[tabIndex]
	local fullView = state.AEAppReducer.AEFullView

	if not fullView then
		self:handleCameraChange(page, state, true)
	end

	self:updateCameraSignal()
end

function AECameraManager:stop()
	for _, connection in pairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}
end

function AECameraManager:updateCameraSignal()
	if self.connections["hrpSignal"] then
		self.connections["hrpSignal"]:disconnect()
	end

	-- Update camera position on change in humanoid root part, i.e. scaling height/body type.
	local cameraSignal = self.store:getState().AEAppReducer.AECharacter.AECurrentCharacter["HumanoidRootPart"]:
		GetPropertyChangedSignal('CFrame'):connect(function()

		local cFrameY = self.store:getState().AEAppReducer.AECharacter.AECurrentCharacter["HumanoidRootPart"].CFrame.y

		if cFrameY ~= self.lastCFrameY then
			local state = self.store:getState()
			local categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex
			local tabIndex = state.AEAppReducer.AECategory.AETabsInfo[categoryIndex]
			local page = AECategories.categories[categoryIndex].pages[tabIndex]
			self:handleCameraChange(page, state, false)
		end

		self.lastCFrameY = cFrameY
	end)

	self.connections["hrpSignal"] = cameraSignal
end

function AECameraManager:update(state, oldState)
	local currentCategoryIndex = state.AEAppReducer.AECategory.AECategoryIndex
	local oldCategoryIndex = oldState.AEAppReducer.AECategory.AECategoryIndex
	local currentTab = state.AEAppReducer.AECategory.AETabsInfo[currentCategoryIndex]
	local oldTab = oldState.AEAppReducer.AECategory.AETabsInfo[oldCategoryIndex]
	local currentFullView = state.AEAppReducer.AEFullView
	local oldFullView = oldState.AEAppReducer.AEFullView
	local instantChange = false
	local page = AECategories.categories[currentCategoryIndex].pages[currentTab]
	local avatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType
	local topBarHeight = state.TopBar and state.TopBar.topBarHeight or 0
	local oldTopBarHeight = oldState.TopBar and oldState.TopBar.topBarHeight or 0

	if state.DeviceOrientation ~= oldState.DeviceOrientation then
		instantChange = true
	end

	if state.AEAppReducer.AECharacter.AECurrentCharacter
		~= oldState.AEAppReducer.AECharacter.AECurrentCharacter then
		self:updateCameraSignal()
		self:handleCameraChange(AECategories.categories[currentCategoryIndex].pages[currentTab], state, instantChange)
	end

	-- Tween the camera on tab change to focus on the relevant character part
	if currentCategoryIndex ~= oldCategoryIndex or currentTab ~= oldTab or instantChange then
		self:handleCameraChange(AECategories.categories[currentCategoryIndex].pages[currentTab], state, instantChange)
	end

	-- If the top bar height changes, update the camera to show the character appropriately.
	if topBarHeight ~= oldTopBarHeight then
		self.fullViewCameraGoals.CFrame = getFullViewCameraCFrame(topBarHeight)
		self.tweenFullView = TweenService:Create(self.camera, self.tweenInfo, self.fullViewCameraGoals)
	end

	if currentFullView ~= oldFullView or topBarHeight ~= oldTopBarHeight then
		if currentFullView then
			self:playTweenFullView()
		else
			self:handleCameraChange(AECategories.categories[currentCategoryIndex].pages[currentTab], state)
		end
	elseif currentFullView and state.DeviceOrientation ~= oldState.DeviceOrientation then
		self.camera.CFrame = self.fullViewCameraGoals.CFrame
		self.camera.FieldOfView = fullViewCameraFieldOfView
	end

	if not avatarTypeBodyPartCameraFocus[avatarType][page.CameraFocus]
		and state.AEAppReducer.AEAccessoryChangeOnModel ~= oldState.AEAppReducer.AEAccessoryChangeOnModel then
		self:handleCameraChange(page, state, false)
	end
end

function AECameraManager:playTweenFullView()
	local character = self.store:getState().AEAppReducer.AECharacter.AECurrentCharacter
	local scalar = (character:GetExtentsSize() / 2).Y / SCALAR_CONSTANT
	local yPosition = FULLVIEW_SCALAR_CONSTANT * scalar
	local topBarHeight = self.store:getState().TopBar and self.store:getState().TopBar.topBarHeight or 0

	local fullViewCameraGoals = {
		CFrame = getFullViewCameraCFrame(topBarHeight, yPosition),
		FieldOfView = 90,
	}
	local newFullViewTween = TweenService:Create(self.camera, self.tweenInfo, fullViewCameraGoals)
	newFullViewTween:Play()
end

function AECameraManager:handleCameraChange(page, state, instant)
	local deviceOrientation = self.store:getState().DeviceOrientation or CONSOLE
	local character = self.store:getState().AEAppReducer.AECharacter.AECurrentCharacter
	local position = themeInfo[deviceOrientation].cameraDefaultPosition
	local avatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType
	local parts = avatarTypeBodyPartCameraFocus[avatarType][page.CameraFocus] or {'HumanoidRootPart'}
	local focusPoint = self:getFocusPoint(parts)

	if character then
		self.lastCFrameY = character["HumanoidRootPart"].CFrame.y
	end

	if not avatarTypeBodyPartCameraFocus[avatarType][page.CameraFocus] then
		focusPoint = Vector3.new(focusPoint.X, (character:GetExtentsSize() / 2).Y, focusPoint.Z)
	end

	position = Vector3.new(position.X, focusPoint.Y, position.Z)
	local zoomRadius = page.CameraZoomRadius or 0
	zoomRadius = themeInfo[deviceOrientation].zoomRadius(zoomRadius)

	-- Zoom out if the character is too tall to fit the current view.
	if not page.CameraZoomRadius then
		local scalarConstant = themeInfo[deviceOrientation].scalarConstant
		local scalar = focusPoint.Y / scalarConstant

		if deviceOrientation == DeviceOrientationMode.Portrait then
			zoomRadius = (zoomRadius + EXTRA_ZOOM_PORTRAIT) * scalar
		else
			zoomRadius = (zoomRadius + EXTRA_ZOOM_LANDSCAPE) * scalar
		end
	end

	if zoomRadius > 0 then
		local toCamera = (position - focusPoint)
		toCamera = Vector3.new(toCamera.x, 0, toCamera.z).unit
		position = focusPoint + zoomRadius * toCamera
	end

	self:tweenCameraIntoPlace(position, focusPoint, cameraDefaultFOV, instant)
end

function AECameraManager:getFocusPoint(partNames)
	local numParts = #partNames

	-- Focus on the torso if there is nothing specific to focus on.
	if numParts == 0 then
		return DEFAULT_RIG_POSITION
	end

	local sumOfPartPositions = Vector3.new()

	for _, partName in next, partNames do
		sumOfPartPositions = sumOfPartPositions + self:getPartPosition(partName).p
	end

	return sumOfPartPositions / numParts
end

function AECameraManager:getPartPosition(partName)
	local character = self.store:getState().AEAppReducer.AECharacter.AECurrentCharacter
	local categoryIndex = self.store:getState().AEAppReducer.AECategory.AECategoryIndex
	local tabIndex = self.store:getState().AEAppReducer.AECategory.AETabsInfo[categoryIndex]
	local page = AECategories.categories[categoryIndex].pages[tabIndex]
	local avatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType
	local cameraVerticalChange = (page.cameraVerticalChange and avatarType == AEConstants.AvatarType.R15)
		and page.cameraVerticalChange or Vector3.new(0, 0, 0)

	if character and character:FindFirstChild(partName) then
		return character[partName].cFrame + cameraVerticalChange
	else
		return CFrame.new(DEFAULT_RIG_POSITION)
	end
end

function AECameraManager:tweenCameraIntoPlace(position, focusPoint, targetFOV, instant)
	local deviceOrientation = self.store:getState().DeviceOrientation or CONSOLE
	local cameraCenterScreenPosition =
		themeInfo[deviceOrientation].cameraCenterScreenPosition
	local topBarHeight = self.store:getState().TopBar and self.store:getState().TopBar.topBarHeight or 0

	-- Clamp to minumum focus point and position
	if FFlagAvatarEditorFixLegCameraPosition then
		local focusPointY = math.clamp(focusPoint.Y, MIN_Y_FOCUS_POINT, MAX_Y_FOCUS_POINT)
		focusPoint = Vector3.new(focusPoint.X, focusPointY, focusPoint.Z)

		local positionY = math.clamp(position.Y, MIN_Y_POSITION, MAX_Y_POSITION)
		position = Vector3.new(position.X, positionY, position.Z)
	end

	-- Adjust the center of the camera if the top bar height changes.
	cameraCenterScreenPosition =
		themeInfo[deviceOrientation].adjustCameraCenterPosition(cameraCenterScreenPosition, topBarHeight)

	local screenSize = self.camera.ViewportSize
	local screenWidth = screenSize.X
	local screenHeight = screenSize.Y

	local fy = 0.5 * targetFOV * math.pi / 180.0 -- half vertical field of view (in radians)
	local fx = math.atan( math.tan(fy) * screenWidth / screenHeight ) -- half horizontal field of view (in radians)

	local anglesX = math.atan( math.tan(fx)
		* (cameraCenterScreenPosition.X.Scale + 2.0 * cameraCenterScreenPosition.X.Offset / screenWidth))
	local anglesY = math.atan( math.tan(fy)
		* (cameraCenterScreenPosition.Y.Scale + 2.0 * cameraCenterScreenPosition.Y.Offset / screenHeight))

	local targetCFrame
		= CFrame.new(position)
		* CFrame.new(Vector3.new(), focusPoint - position)
		* CFrame.Angles(anglesY, anglesX, 0)

	if instant then
		self.camera.FieldOfView = targetFOV
		self.camera.CFrame = targetCFrame
	else
		local cameraGoals = {
			CFrame = targetCFrame;
			FieldOfView = targetFOV;
		}
		TweenService:Create(self.camera, self.tweenInfo, cameraGoals):Play()
	end
end

return AECameraManager