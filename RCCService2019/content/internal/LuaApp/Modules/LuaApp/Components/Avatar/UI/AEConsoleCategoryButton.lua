local Modules = game:GetService("CoreGui").RobloxGui.Modules
local CorePackages = game:GetService("CorePackages")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local AESelectCategory = require(Modules.LuaApp.Thunks.AEThunks.AESelectCategory)
local AESetGamepadNavigationMenuLevel = require(Modules.LuaApp.Actions.AEActions.AESetGamepadNavigationMenuLevel)
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local LocalizedTextLabel = require(Modules.LuaApp.Components.LocalizedTextLabel)
local SoundManager = require(Modules.Shell.SoundManager)

local AEConsoleCategoryButton = Roact.PureComponent:extend("AEConsoleCategoryButton")

function AEConsoleCategoryButton:init()
	self.buttonRef = Roact.createRef()

	local selectionImageObject = Instance.new("ImageLabel")
	selectionImageObject.Image = "rbxasset://textures/ui/Shell/AvatarEditor/graphic/gr-item selector-8px corner.png"
	selectionImageObject.Position = UDim2.new(0, -7, 0, -7)
	selectionImageObject.Size = UDim2.new(1, 14, 1, 14)
	selectionImageObject.BackgroundTransparency = 1
	selectionImageObject.ScaleType = Enum.ScaleType.Slice
	selectionImageObject.SliceCenter = Rect.new(31, 31, 63, 63)
	self.selectionImageObject = selectionImageObject
end

function AEConsoleCategoryButton:didMount()
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local closeSizeGoals = {
		Size = UDim2.new(0, 80, 0, 80)
	}
	local closeTextGoals = {
		TextTransparency = 1
	}

	self.closeTween = TweenService:Create(self.buttonRef.current, tweenInfo, closeSizeGoals)
	self.closeTextTween = TweenService:Create(self.buttonRef.current.CategoryText, tweenInfo, closeTextGoals)

	local openSizeGoals = {
		Size = UDim2.new(0, 360, 0, 80)
	}
	local openTextGoals = {
		TextTransparency = 0
	}

	self.openTween = TweenService:Create(self.buttonRef.current, tweenInfo, openSizeGoals)
	self.openTextTween = TweenService:Create(self.buttonRef.current.CategoryText, tweenInfo, openTextGoals)
end

function AEConsoleCategoryButton:render()
	local index = self.props.index
	local category = self.props.category
	local categoryIndex = self.props.categoryIndex
	local categoryButtonImage, categoryIconImage, textColor
	local imageTransparency = 0

	if (self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.TabList
		or self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.AssetsPage)
		and categoryIndex ~= index then
		imageTransparency = 0.5
	end

	if index == categoryIndex then
		categoryButtonImage = "rbxasset://textures/ui/Shell/AvatarEditor/button/btn-category-selected.png"
		categoryIconImage = category.selectedIconImageConsole
		textColor = Color3.fromRGB(25, 25, 25)
	else
		categoryButtonImage = "rbxasset://textures/ui/Shell/AvatarEditor/button/btn-category.png"
		categoryIconImage = category.iconImageConsole
		textColor = Color3.fromRGB(255, 255, 255)
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.new(0, 360, 0, 80),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = categoryButtonImage,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
		Selectable = true,
		SelectionImageObject = self.selectionImageObject,
		ZIndex = 2,
		[Roact.Ref] = self.buttonRef,
		[Roact.Event.SelectionGained] = function()
			self.props.selectCategory(self.props.index)
		end,
		[Roact.Event.Activated] = function()
			self.props.setGamepadNavigationMenuLevel(AEConstants.GamepadNavigationMenuLevel.TabList)
			SoundManager:Play('OverlayOpen')
		end,
	}, {
		MoveSelection = Roact.createElement("Sound", {
			SoundId = "rbxasset://sounds/ui/Shell/MoveSelection.mp3",
			Volume = 0.35,
		}),
		CategoryIcon = Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 24, 0.5, 0),
			Size = UDim2.new(0, 32, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = categoryIconImage,
			ImageTransparency = imageTransparency,
			ZIndex = 2,
		}),
		CategoryText = Roact.createElement(LocalizedTextLabel, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 80, 0.5, 0),
			Size = UDim2.new(0, 200, 0, 50),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = category.title,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = textColor,
			TextTransparency = 0,
			TextSize = 36,
			Font = Enum.Font.SourceSans,
			ZIndex = 2,
		})
	})
end

function AEConsoleCategoryButton:didUpdate(prevProps, prevState)
	-- Check if user entered category menu or tab list
	if self.props.gamepadNavigationMenuLevel ~= prevProps.gamepadNavigationMenuLevel then
		if self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.CategoryMenu then
			if self.props.index == self.props.categoryIndex then
				GuiService.SelectedCoreObject = self.buttonRef.current
			end
			self.openTween:Play()
			self.openTextTween:Play()
		elseif self.props.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.TabList and
			prevProps.gamepadNavigationMenuLevel == AEConstants.GamepadNavigationMenuLevel.CategoryMenu then
			self.closeTween:Play()
			self.closeTextTween:Play()
		end
	end

	if self.props.avatarEditorActive ~= prevProps.avatarEditorActive and self.props.avatarEditorActive
		and self.props.index == self.props.categoryIndex then
		GuiService.SelectedCoreObject = self.buttonRef.current
	end
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			categoryIndex = state.AEAppReducer.AECategory.AECategoryIndex,
			gamepadNavigationMenuLevel = state.AEAppReducer.AEGamepadNavigationMenuLevel,
		}
	end,

	function(dispatch)
		return {
			selectCategory = function(index)
				dispatch(AESelectCategory(index))
			end,
			setGamepadNavigationMenuLevel = function(gamepadNavigationMenuLevel)
				dispatch(AESetGamepadNavigationMenuLevel(gamepadNavigationMenuLevel))
			end,
		}
	end
)(AEConsoleCategoryButton)