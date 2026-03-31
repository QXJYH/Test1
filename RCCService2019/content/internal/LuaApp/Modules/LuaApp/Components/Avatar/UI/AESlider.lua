local Modules = game:GetService("CoreGui").RobloxGui.Modules
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local GuiService = game:GetService("GuiService")
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local AESpriteSheet = require(Modules.LuaApp.Components.Avatar.AESpriteSheet)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local DeviceOrientationMode = require(Modules.LuaApp.DeviceOrientationMode)
local FFlagAvatarEditorEnableThemes = settings():GetFFlag("AvatarEditorEnableThemes2")
local FFlagAvatarEditorFixSliderSensitivity = settings():GetFFlag("AvatarEditorFixSliderSensitivity")

local AESlider = Roact.PureComponent:extend("AESlider")

local DEFAULT_LOCATION_BLUE = "rbxasset://textures/AvatarEditorImages/Sliders/gr-default-point-fill.png"
local DEFAULT_LOCATION_GRAY = "rbxasset://textures/AvatarEditorImages/Sliders/gr-default-point-empty.png"
local THUMBSTICK_MOVE_DEADZONE = 0.6
local THUMBSTICK_MOVE_SLIDER_PERCENT = 10
local THUMBSTICK_MOVE_INITIAL_REPEAT_TIME = 0.5
local THUMBSTICK_MOVE_REPEAT_TIME = 0.12
local AESLIDER_X_EXTRA_SENSITIVITY = 1

local View = {
	[DeviceOrientationMode.Portrait] = {
		PAGE_LABEL_SIZE = 31,

	},

	[DeviceOrientationMode.Landscape] = {
		PAGE_LABEL_SIZE = 0,
	}
}

function AESlider:removeConnections()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	self.moveListen = nil
	self.upListen = nil
	self.connections = {}
end

function AESlider:repeatInput()
	spawn(function()
		local sliderInfo = self.state.sliderInfo
		local repeatMoveTimer = tick()
		local fastRepeatMoveTimer = repeatMoveTimer
		self.isRunning = true
		while self.isRunning do
			local curTime = tick()
			if curTime - repeatMoveTimer >= THUMBSTICK_MOVE_INITIAL_REPEAT_TIME then
				if not fastRepeatMoveTimer or curTime - fastRepeatMoveTimer >= THUMBSTICK_MOVE_REPEAT_TIME then
					fastRepeatMoveTimer = curTime
					if not self.isDPad then
						local newValue = self.lastMoveDirection * math.ceil(sliderInfo.intervals / THUMBSTICK_MOVE_SLIDER_PERCENT)
						local lastValue = math.max(0, math.min(sliderInfo.intervals, sliderInfo.lastValue + newValue))
						self:updateAESlider(lastValue)
					else
						local lastValue = math.max(0, math.min(sliderInfo.intervals, sliderInfo.lastValue + self.lastMoveDirection))
						self:updateAESlider(lastValue)
					end
				end
			end
			self.delta = RunService.RenderStepped:wait()
		end
	end)
end

function AESlider:stopGamePadInput()
	self.lastMoveDirection = 0
	self.isRunning = false
	self.isDPad = false
end

function AESlider:disconnectGamePadListeners()
	if self.inputBeganListener then
		self.inputBeganListener:Disconnect()
	end

	if self.inputChangeListener then
		self.inputChangeListener:Disconnect()
	end

	if self.inputEndListener then
		self.inputEndListener:Disconnect()
	end
end

function AESlider:handleGamePad(input, gameProcessedEvent)
	local sliderInfo = self.state.sliderInfo
	local avatarType = self.props.avatarType

	if avatarType == AEConstants.AvatarType.R6 then
		self.highlightRef.current.Visible = false
		return
	else
		self.highlightRef.current.Visible = true
	end

	if input.UserInputState == Enum.UserInputState.End then
		self:stopGamePadInput()
		return
	end
	if input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.DPadRight then
		local newMoveDirection = input.KeyCode == Enum.KeyCode.DPadLeft and -1 or 1
		if self.lastMoveDirection ~= newMoveDirection then
			self.lastMoveDirection = newMoveDirection
			local lastValue = math.max(0, math.min(sliderInfo.intervals, sliderInfo.lastValue + newMoveDirection))
			self.isDPad = true
			self:updateAESlider(lastValue)
			self:repeatInput()
		end
		return
	end
	if input.KeyCode == Enum.KeyCode.Thumbstick1 then
		local newMoveDirection = input.Position.X
		if math.abs(newMoveDirection) > THUMBSTICK_MOVE_DEADZONE then
			local newMoveDirection = newMoveDirection > 0 and 1 or -1
			local newValue = newMoveDirection * math.ceil(sliderInfo.intervals / THUMBSTICK_MOVE_SLIDER_PERCENT)
			local lastValue = math.max(0, math.min(sliderInfo.intervals, sliderInfo.lastValue + newValue))
			if self.lastMoveDirection ~= newMoveDirection then
				self:updateAESlider(lastValue)
				self:repeatInput()
				self.lastMoveDirection = newMoveDirection
				self.isDPad = false
			end
		else
			self.lastMoveDirection = 0
			self.isRunning = false
		end
	end
end

-- Update the slider UI by setting properties on the local state.
function AESlider:updateAESlider(lastValue)
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AESliders:getThemeInfo(deviceOrientation, themeName)
	local sliderInfo = self.state.sliderInfo
	local percent = lastValue

	if sliderInfo.intervals then
		percent = lastValue / sliderInfo.intervals
	end

	if sliderInfo.intervals and sliderInfo.intervals > 0 and sliderInfo.defaultValue then
		if lastValue >= sliderInfo.defaultValue then
			sliderInfo.defaultLocationIndicatorImage = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.DefaultLocationFilled or DEFAULT_LOCATION_BLUE
		else
			sliderInfo.defaultLocationIndicatorImage = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.DefaultLocationEmpty or DEFAULT_LOCATION_GRAY
		end
	end

	if FFlagAvatarEditorFixSliderSensitivity then
		sliderInfo.draggerPosition = UDim2.new(percent, themeInfo.OrientationTheme.Dragger.PosX, .5,
			themeInfo.OrientationTheme.Dragger.PosY)
	else
		sliderInfo.draggerPosition = UDim2.new(percent, themeInfo.OrientationTheme.Dragger.PosX, .5,
			themeInfo.OrientationTheme.Dragger.PosY)
	end
	sliderInfo.fillBarSize = UDim2.new(percent, 8, 0, themeInfo.OrientationTheme.FillBar.SizeY)
	sliderInfo.lastValue = lastValue

	if sliderInfo.changedFunction then
		sliderInfo.changedFunction(lastValue)
	end

	self:setState({ sliderInfo = sliderInfo })
end

function AESlider:handle(inputPosX, sliderButtonRef)
	local sliderInfo = self.state.sliderInfo
	local lastValue = sliderInfo.lastValue
	local percent = math.max(0, math.min(1,
		(inputPosX - sliderButtonRef.AbsolutePosition.x) / sliderButtonRef.AbsoluteSize.x))
	local thisInterval = percent

	if sliderInfo.intervals then
		thisInterval = math.floor((percent * sliderInfo.intervals)+ .5)
	end

	if thisInterval ~= lastValue then
		lastValue = thisInterval
		self:updateAESlider(lastValue)
	end
end

function AESlider:inputChanged(input, gameProcessedEvent, sliderButtonRef)
	local sliderInfo = self.state.sliderInfo

	if input.UserInputState == Enum.UserInputState.Change
		and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then

		-- Update slider
		if input.Position then
			self:handle(input.Position.x, sliderButtonRef)
		end
	elseif input.UserInputState == Enum.UserInputState.End
		and (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch) then
		self:stopSliderInteraction(sliderInfo)
	end
end

function AESlider:inputStarted(input, gameProcessedEvent, sliderButtonRef)
	-- FFlagAvatarEditorFixSliderSensitivity - Remove sliderButtonRef from function arguments
	if FFlagAvatarEditorFixSliderSensitivity then
		sliderButtonRef = self.sliderRef.current
	end
	local firstX = self.firstX
	local firstY = self.firstY
	local sliderInfo = self.state.sliderInfo

	if input.UserInputState == Enum.UserInputState.Change
		and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then

		-- Determine if the first drag motion is mostly horizontal.  If it is, disable (vertical) scrolling,
		-- and allow subsequent events to move the slider
		local w
		if FFlagAvatarEditorFixSliderSensitivity then
			w = math.abs(input.Position.X - firstX + AESLIDER_X_EXTRA_SENSITIVITY)
		else
			w = math.abs(input.Position.X - firstX)
		end
		local h = math.abs(input.Position.Y - firstY)
		if w == 0 and h == 0 then return end

		if w > h then
			sliderInfo.draggerHighLightVisible = true
			self:setState({ sliderInfo = sliderInfo }) -- Show the dragger highlight on start drag.

			if self.scrollingFrameRef then  -- Do not allow scrolling when dragging a slider.
				self.scrollingFrameRef.ScrollingEnabled = false
			end

			if input.Position then
				self:handle(input.Position.x, sliderButtonRef)
			end

			self:removeConnections()

			self.moveListen = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
				self:inputChanged(input, gameProcessedEvent, sliderButtonRef)
			end)
			self.upListen = UserInputService.InputEnded:connect(function(input, gameProcessedEvent)
				self:inputChanged(input, gameProcessedEvent, sliderButtonRef)
			end)
			table.insert(self.connections, self.moveListen)
			table.insert(self.connections, self.upListen)
		else
			-- If the user is dragging vertically, disconnect event handlers to let scrolling happen.
			self:removeConnections()
		end
	end
end

function AESlider:stopSliderInteraction(sliderInfo)
	self:removeConnections()
	if sliderInfo.draggerHighLightVisible then
		sliderInfo.draggerHighLightVisible = false
		self:setState({ sliderInfo = sliderInfo })
	end

	self.scrollingFrameRef.ScrollingEnabled = true
end

function AESlider:init()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AESliders:getThemeInfo(deviceOrientation, themeName)
	self.draggerButtonRef = Roact.createRef()
	self.highlightRef = Roact.createRef()
	self.sliderRef = Roact.createRef()
	self.lastMoveDirection = 0
	local scaleInfo = self.props.scaleInfo
	self.scrollingFrameRef = self.props.scrollingFrameRef
	self.connections = {}

	local sliderInfo = {}

	sliderInfo.title = scaleInfo.title
	sliderInfo.changedFunction = function(value)
			scaleInfo.setScale(math.min(scaleInfo.max,
			math.max(scaleInfo.min, scaleInfo.min + value * scaleInfo.increment)))
	end

	-- Get the current scale percentage from the state.
	if self.props.scales[scaleInfo.property] then
		sliderInfo.currentPercent = (self.props.scales[scaleInfo.property] - scaleInfo.min) / (scaleInfo.max - scaleInfo.min)
	else
		sliderInfo.currentPercent = 0
	end

	sliderInfo.intervals = ((scaleInfo.max - scaleInfo.min) / scaleInfo.increment)
	sliderInfo.defaultValue = (scaleInfo.default - scaleInfo.min) / scaleInfo.increment
	sliderInfo.lastValue = math.floor((sliderInfo.currentPercent * sliderInfo.intervals) + .5)

	if sliderInfo.intervals > 0 and sliderInfo.defaultValue then
		sliderInfo.defaultLocationIndicatorPosition = UDim2.new(sliderInfo.defaultValue / sliderInfo.intervals, 0, 0.5, 0)

		if sliderInfo.lastValue >= sliderInfo.defaultValue then
			sliderInfo.defaultLocationIndicatorImage = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.DefaultLocationFilled or DEFAULT_LOCATION_BLUE
		else
			sliderInfo.defaultLocationIndicatorImage = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.DefaultLocationEmpty or DEFAULT_LOCATION_GRAY
		end
	else
		sliderInfo.defaultLocationIndicatorVisible = false
	end

	local percent = sliderInfo.lastValue / sliderInfo.intervals

	sliderInfo.draggerHighLightVisible = false
	if FFlagAvatarEditorFixSliderSensitivity then
		sliderInfo.draggerPosition = UDim2.new(percent, themeInfo.OrientationTheme.Dragger.PosX, .5,
			themeInfo.OrientationTheme.Dragger.PosY)
	else
		sliderInfo.draggerPosition = UDim2.new(percent, themeInfo.OrientationTheme.Dragger.PosX, .5,
			themeInfo.OrientationTheme.Dragger.PosY)
	end
	sliderInfo.fillBarSize = UDim2.new(percent, 8, 0, themeInfo.OrientationTheme.FillBar.SizeY)

	local draggerImageObject = Instance.new("ImageLabel")
	draggerImageObject.Image = "rbxasset://textures/ui/Shell/AvatarEditor/scale/slider-select.png"
	draggerImageObject.BackgroundTransparency = 1
	draggerImageObject.Size = UDim2.new(1, 14, 1, 14)
	draggerImageObject.Position = UDim2.new(0, -7, 0, -7)
	draggerImageObject.ZIndex = 3
	self.draggerImageObject = draggerImageObject
	self.state = {
		sliderInfo = sliderInfo,
	}
end

function AESlider:render()
	local deviceOrientation = self.props.deviceOrientation
	local themeName = self._context.AppTheme and self._context.AppTheme.Name or nil
	local themeInfo = self._context.AvatarEditorTheme.AESliders:getThemeInfo(deviceOrientation, themeName)
	local sliderInfo = self.state.sliderInfo
	local avatarType = self.props.avatarType
	local index = self.props.index
	local sliderPositionY

	if AEUtils.gamepadNavigationEnabled() then
		sliderPositionY = themeInfo.OrientationTheme.Slider.PosY + (120 * (index - 1))
	else
		sliderPositionY = themeInfo.OrientationTheme.Slider.PosY * index - View[deviceOrientation].PAGE_LABEL_SIZE
	end

	local highlightImageName = AEUtils.gamepadNavigationEnabled() and "consoleDraggerHighlight" or "dragger-highlight"
	local highlight = AESpriteSheet.getImage(highlightImageName)

	if FFlagAvatarEditorEnableThemes then
		highlight.imageRectOffset = nil
		highlight.imageRectSize = nil
	end

	local position = UDim2.new(themeInfo.OrientationTheme.Slider.PosXScale,
		themeInfo.OrientationTheme.Slider.PosXOffset, 0, sliderPositionY)

	return Roact.createElement("ImageButton", {
		Position = position,
		Size = themeInfo.OrientationTheme.Slider.Size,
		ZIndex = 2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		[Roact.Event.SelectionGained] = function()
			GuiService.SelectedCoreObject = self.draggerButtonRef.current
		end,
	}, {
		BackgroundBar = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			Position = themeInfo.OrientationTheme.BackgroundBar.Position,
			Size = themeInfo.OrientationTheme.BackgroundBar.Size,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = themeInfo.OrientationTheme.BackgroundBar.Image,
			ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.SlideBarEmpty or Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = themeInfo.OrientationTheme.BackgroundBar.SliceCenter,
			AnchorPoint = themeInfo.OrientationTheme.BackgroundBar.AnchorPoint,
		}),
		Dragger = not FFlagAvatarEditorFixSliderSensitivity and Roact.createElement(FFlagAvatarEditorEnableThemes
				and ImageSetLabel or "ImageLabel", {
			Position = sliderInfo.draggerPosition,
			Size = themeInfo.OrientationTheme.Dragger.Size,
			ZIndex = 2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = themeInfo.OrientationTheme.Dragger.Image,
			ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Slider or Color3.fromRGB(255, 255, 255),
			AnchorPoint = themeInfo.OrientationTheme.Dragger.AnchorPoint,
		}, {
			Highlight = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
				Position = themeInfo.OrientationTheme.Highlight.Position,
				Size = themeInfo.OrientationTheme.Highlight.Size,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = sliderInfo.draggerHighLightVisible and
					(FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.HighlightVisible or not FFlagAvatarEditorEnableThemes),
				Image = FFlagAvatarEditorEnableThemes and themeInfo.OrientationTheme.Highlight.Image
					or highlight.image,
				ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.HighlightColor
					or Color3.fromRGB(255, 255, 255),
				ImageRectOffset = highlight.imageRectOffset,
				ImageRectSize = highlight.imageRectSize,
				AnchorPoint = themeInfo.OrientationTheme.Highlight.AnchorPoint,

				[Roact.Ref] = self.highlightRef,
			}),
			DraggerOutline = FFlagAvatarEditorEnableThemes and Roact.createElement(ImageSetLabel, {
				Size = themeInfo.OrientationTheme.DraggerOutline.Size,
				BackgroundTransparency = 1,
				Image = themeInfo.OrientationTheme.DraggerOutline.Image,
				ImageColor3 = themeInfo.ColorTheme.SliderOutline,
				ZIndex = 2,
				Visible = themeInfo.OrientationTheme.DraggerOutline.Visible,
			}),
			DraggerButton = Roact.createElement("ImageLabel", {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = themeInfo.OrientationTheme.DraggerButton.Size,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),

				NextSelectionLeft = self.draggerButtonRef.current,
				NextSelectionRight = self.draggerButtonRef.current,
				SelectionImageObject = self.draggerImageObject,

				[Roact.Ref] = self.draggerButtonRef,
				[Roact.Event.SelectionGained] = function()
					self:disconnectGamePadListeners()
					self:stopGamePadInput()
					self.highlightRef.current.Visible = avatarType == AEConstants.AvatarType.R15 and true or false
					self.inputBeganListener = UserInputService.InputBegan:connect(function(input, gameProcessedEvent)
						self:handleGamePad(input, gameProcessedEvent)
					end)
					self.inputChangeListener = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
						self:handleGamePad(input, gameProcessedEvent)
					end)
					self.inputEndListener = UserInputService.InputEnded:connect(function(input, gameProcessedEvent)
						self:handleGamePad(input, gameProcessedEvent)
					end)
				end,

				[Roact.Event.SelectionLost] = function()
					self.highlightRef.current.Visible = false
					self:disconnectGamePadListeners()
					self:stopGamePadInput()
				end,
			}),
		}),
		DraggerArea = FFlagAvatarEditorFixSliderSensitivity and Roact.createElement("Frame", {
			AnchorPoint = themeInfo.OrientationTheme.DraggerArea.AnchorPoint,
			Position = sliderInfo.draggerPosition,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = themeInfo.OrientationTheme.DraggerArea.Size,
			ZIndex = 2,
			[Roact.Event.InputBegan] = function(rbx, inputObject)
				if avatarType == AEConstants.AvatarType.R15 and inputObject.UserInputState == Enum.UserInputState.Begin then
					self.moveListen = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
						self:inputStarted(input, gameProcessedEvent)
					end)

					self.connections[#self.connections + 1] = self.moveListen
					self.firstX = inputObject.Position.X
					self.firstY = inputObject.Position.Y
				end
			end,
			[Roact.Event.InputEnded] = function(rbx, inputObject)
				if avatarType == AEConstants.AvatarType.R15 and inputObject.UserInputState == Enum.UserInputState.End then
					self:stopSliderInteraction(sliderInfo)
				end
			end,
		}, {
			DraggerImage = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
				Position = UDim2.new(0.5,0,0.5,0),
				Size = themeInfo.OrientationTheme.Dragger.Size,
				ZIndex = 2,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = themeInfo.OrientationTheme.Dragger.Image,
				ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.Slider or Color3.fromRGB(255, 255, 255),
				AnchorPoint = themeInfo.OrientationTheme.Dragger.AnchorPoint,
			}, {
				Highlight = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
					Position = themeInfo.OrientationTheme.Highlight.Position,
					Size = themeInfo.OrientationTheme.Highlight.Size,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Visible = sliderInfo.draggerHighLightVisible and
					(FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.HighlightVisible or not FFlagAvatarEditorEnableThemes),
					Image = FFlagAvatarEditorEnableThemes and themeInfo.OrientationTheme.Highlight.Image
						or highlight.image,
					ImageColor3 = FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.HighlightColor
						or Color3.fromRGB(255, 255, 255),
					ImageRectOffset = highlight.imageRectOffset,
					ImageRectSize = highlight.imageRectSize,
					AnchorPoint = themeInfo.OrientationTheme.Highlight.AnchorPoint,

					[Roact.Ref] = self.highlightRef,
				}),
				DraggerOutline = FFlagAvatarEditorEnableThemes and Roact.createElement(ImageSetLabel, {
					Size = themeInfo.OrientationTheme.DraggerOutline.Size,
					BackgroundTransparency = 1,
					Image = themeInfo.OrientationTheme.DraggerOutline.Image,
					ImageColor3 = themeInfo.ColorTheme.SliderOutline,
					ZIndex = 2,
					Visible = themeInfo.OrientationTheme.DraggerOutline.Visible,
				}),
				DraggerButton = Roact.createElement("ImageLabel", {
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = themeInfo.OrientationTheme.DraggerButton.Size,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.5, 0.5),

					NextSelectionLeft = self.draggerButtonRef.current,
					NextSelectionRight = self.draggerButtonRef.current,
					SelectionImageObject = self.draggerImageObject,

					[Roact.Ref] = self.draggerButtonRef,
					[Roact.Event.SelectionGained] = function()
						self:disconnectGamePadListeners()
						self:stopGamePadInput()
						self.highlightRef.current.Visible = avatarType == AEConstants.AvatarType.R15 and true or false
						self.inputBeganListener = UserInputService.InputBegan:connect(function(input, gameProcessedEvent)
							self:handleGamePad(input, gameProcessedEvent)
						end)
						self.inputChangeListener = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
							self:handleGamePad(input, gameProcessedEvent)
						end)
						self.inputEndListener = UserInputService.InputEnded:connect(function(input, gameProcessedEvent)
							self:handleGamePad(input, gameProcessedEvent)
						end)
					end,

					[Roact.Event.SelectionLost] = function()
						self.highlightRef.current.Visible = false
						self:disconnectGamePadListeners()
						self:stopGamePadInput()
					end,
				}),
			}),
		}),
		FillBar = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			Position = themeInfo.OrientationTheme.FillBar.Position,
			Size = sliderInfo.fillBarSize,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = themeInfo.OrientationTheme.FillBar.Image,
			ImageColor3 = FFlagAvatarEditorEnableThemes
				and themeInfo.ColorTheme.FillBarColor or Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = themeInfo.OrientationTheme.FillBar.SliceCenter,
			AnchorPoint = themeInfo.OrientationTheme.FillBar.AnchorPoint,
		}),
		DefaultLocationIndicator = Roact.createElement(FFlagAvatarEditorEnableThemes and ImageSetLabel or "ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = sliderInfo.defaultLocationIndicatorPosition,
			Size = themeInfo.OrientationTheme.DefaultLocationIndicator.Size,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = FFlagAvatarEditorEnableThemes
				and themeInfo.OrientationTheme.DefaultLocationIndicator.Image or sliderInfo.defaultLocationIndicatorImage,
			ImageColor3 = FFlagAvatarEditorEnableThemes
				and sliderInfo.defaultLocationIndicatorImage or Color3.fromRGB(255, 255, 255),
			Visible = sliderInfo.defaultLocationIndicatorVisible,
		}),
		TextLabel = Roact.createElement(LocalizedTextLabel, {
			Position = themeInfo.OrientationTheme.TextLabel.Position,
			Size = themeInfo.OrientationTheme.TextLabel.Size,
			TextColor3 = (FFlagAvatarEditorEnableThemes and themeInfo.ColorTheme.PageLabelTextColor
				or themeInfo.OrientationTheme.TextLabel.TextColor3),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextSize = themeInfo.OrientationTheme.TextLabel.TextSize,
			Font = themeInfo.OrientationTheme.TextLabel.Font,
			BackgroundTransparency = 1,
			Text = sliderInfo.title,
		}),
		AESliderButton = not FFlagAvatarEditorFixSliderSensitivity and Roact.createElement("ImageButton", {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 10, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Selectable = false,

			[Roact.Event.InputBegan] = function(rbx, inputObject)
				if avatarType == AEConstants.AvatarType.R15 and inputObject.UserInputState == Enum.UserInputState.Begin then
					self.moveListen = UserInputService.InputChanged:connect(function(input, gameProcessedEvent)
						self:inputStarted(input, gameProcessedEvent, rbx)
					end)

					self.connections[#self.connections + 1] = self.moveListen
					self.firstX = inputObject.Position.X
					self.firstY = inputObject.Position.Y
				end
			end,
			[Roact.Event.InputEnded] = function(rbx, inputObject)
				if avatarType == AEConstants.AvatarType.R15 and inputObject.UserInputState == Enum.UserInputState.End then
					self:stopSliderInteraction(sliderInfo)
				end
			end,
		}),
		AESliderButtonNew = FFlagAvatarEditorFixSliderSensitivity and Roact.createElement("ImageButton", {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 40, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Selectable = false,
			[Roact.Ref] = self.sliderRef,
		}),
	})
end

function AESlider:willUnmount()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	self.connections = {}
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			scales = state.AEAppReducer.AECharacter.AEAvatarScales,
			avatarType = state.AEAppReducer.AECharacter.AEAvatarType
		}
	end
)(AESlider)