local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local FFlagAvatarEditorRefactorPageType = settings():GetFFlag("AvatarEditorRefactorPageType")
local FFlagAvatarEditorEmotesSupport = settings():GetFFlag("AvatarEditorEmotesSupport")
local AECategories = {}

AECategories.AssetCategory = {
	ALL = 1,
	CLOTHING = 2,
	BODY = 3,
	ANIMATION = 4,
	OUTFIT = 5,
}

AECategories.AssetTypeIdToCategory = {
	["Outfits"] = AECategories.AssetCategory.OUTFIT, -- Outfits
	["8"] = AECategories.AssetCategory.CLOTHING, -- Hats
	["41"] = AECategories.AssetCategory.CLOTHING, -- Hair
	["42"] = AECategories.AssetCategory.CLOTHING, -- Face Accessories
	["43"] = AECategories.AssetCategory.CLOTHING, -- Neck
	["44"] = AECategories.AssetCategory.CLOTHING, -- Shoulder
	["45"] = AECategories.AssetCategory.CLOTHING, -- Front
	["46"] = AECategories.AssetCategory.CLOTHING, -- Back
	["47"] = AECategories.AssetCategory.CLOTHING, -- Waist
	["11"] = AECategories.AssetCategory.CLOTHING, -- Shirts
	["12"] = AECategories.AssetCategory.CLOTHING, -- Pants
	["19"] = AECategories.AssetCategory.CLOTHING, -- Gear
	["17"] = AECategories.AssetCategory.BODY, -- Heads
	["18"] = AECategories.AssetCategory.BODY, -- Faces
	["27"] = AECategories.AssetCategory.BODY, -- Torso
	["28"] = AECategories.AssetCategory.BODY, -- Right Arms
	["29"] = AECategories.AssetCategory.BODY, -- Left Arms
	["30"] = AECategories.AssetCategory.BODY, -- Left Legs
	["31"] = AECategories.AssetCategory.BODY, -- Right Legs
	["48"] = AECategories.AssetCategory.ANIMATION, -- Climb Anim
	["50"] = AECategories.AssetCategory.ANIMATION, -- Fall Anim
	["51"] = AECategories.AssetCategory.ANIMATION, -- Idle Anim
	["52"] = AECategories.AssetCategory.ANIMATION, -- Jump Anim
	["53"] = AECategories.AssetCategory.ANIMATION, -- Run Anim
	["54"] = AECategories.AssetCategory.ANIMATION, -- Swim Anim
	["55"] = AECategories.AssetCategory.ANIMATION, -- Walk Anim
	["61"] = AECategories.AssetCategory.ANIMATION, -- Emotes
}

-- When removing FFlagAvatarEditorEnableThemes, iconImageName & iconImageSelectedName can be removed.
local recentPage = FFlagAvatarEditorRefactorPageType and {
	name = 'Recent All',
	title = 'Feature.Avatar.Heading.RecentAll',
	titleLandscape = 'Feature.Avatar.Heading.All',
	iconImageName =	'ic-all',
	iconImageSelectedName = 'ic-all-on',
	iconImageSetName = 'ic-all',
	iconImageSetSelectedName = 'ic-all-on',
	itemType = "All",
	pageType = AEConstants.PageType.RecentAll,
	emptyStringKey = 'Feature.Avatar.Message.EmptyRecentItems',
} or {
	name = 'Recent All',
	title = 'Feature.Avatar.Heading.RecentAll',
	titleLandscape = 'Feature.Avatar.Heading.All',
	iconImageName =	'ic-all',
	iconImageSelectedName = 'ic-all-on',
	iconImageSetName = 'ic-all',
	iconImageSetSelectedName = 'ic-all-on',
	itemType = "All",
	pageType = AEConstants.PageType.AssetCards,
	recentPageType = AECategories.AssetCategory.ALL,
	emptyStringKey = 'Feature.Avatar.Message.EmptyRecentItems',
}
local outfitsPage = {
	name = 'Outfits',
	title = 'Feature.Avatar.Label.MyCostumes',
	titleLandscape = 'Feature.Avatar.Label.MyCostumes',
	titleConsole = 'Feature.Avatar.Label.MyCostumes',
	iconImageName = 'ic-all',
	iconImageSelectedName = 'ic-all-on',
	iconImageSetName = 'ic-all',
	iconImageSetSelectedName = 'ic-all-on',
	pageType = AEConstants.PageType.AssetCards,
	assetTypeId = "Outfits",
	emptyStringKey = 'Feature.Avatar.Message.EmptyCostumes',
}
local presetCostumesPage = {
	name = 'PresetCostumes',
	title = 'Feature.Avatar.Label.PresetCostumes',
	titleLandscape = 'Feature.Avatar.Label.PresetCostumes',
	titleConsole = 'Feature.Avatar.Label.PresetCostumes',
	iconImageName = 'ic-costumes',
	iconImageSelectedName = 'ic-costumes-on',
	iconImageSetName = 'ic-costume',
	iconImageSetSelectedName = 'ic-costume-on',
	pageType = AEConstants.PageType.AssetCards,
	assetTypeId = AEConstants.PRESET_COSTUMES,
	emptyStringKey = 'Feature.Avatar.Message.EmptyCostumes',
}
local hatsPage = {
	name = 'Hats',
	title = 'Feature.Avatar.Label.Hats',
	titleLandscape = 'Feature.Avatar.Label.Hat',
	iconImageName = 'ic-hat',
	iconImageSelectedName = 'ic-hat-on',
	iconImageSetName = 'ic-hat',
	iconImageSetSelectedName = 'ic-hat-on',
	CameraFocus = "headWideFocus",
	CameraZoomRadius = 9.5,
	shopUrl = "/catalog/?Category=11&Subcategory=9",
	assetTypeId = "8",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetHats',
	cameraVerticalChange = Vector3.new(0, 0.25, 0),
}
local hairPage = {
	name = 'Hair',
	title = 'Feature.Avatar.Label.Hair',
	iconImageName = 'ic-hair',
	iconImageSelectedName = 'ic-hair-on',
	iconImageSetName = 'ic-hair',
	iconImageSetSelectedName = 'ic-hair-on',
	CameraFocus = "headWideFocus",
	CameraZoomRadius = 7.5,
	shopUrl = "/catalog/?Category=11&Subcategory=20",
	assetTypeId = "41",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetHair',
}
local faceAccessoryPage = {
	name = 'Face Accessories',
	title = 'Feature.Avatar.Label.FaceAccessories',
	titleLandscape = 'Feature.Avatar.Label.Face',
	iconImageName = 'ic-face-accessories',
	iconImageSelectedName = 'ic-face-accessories-on',
	iconImageSetName = 'ic-face-accessories',
	iconImageSetSelectedName = 'ic-face-accessories-on',
	CameraFocus = "faceFocus",
	CameraZoomRadius = 4.5,
	shopUrl = "/catalog/?Category=11&Subcategory=21",
	assetTypeId = "42",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetFaceAccessories',
}
local neckAccessoryPage = {
	name = 'Neck Accessories',
	title = 'Feature.Avatar.Label.NeckAccessories',
	titleLandscape = 'Feature.Avatar.Label.Neck',
	iconImageName = 'ic-neck',
	iconImageSelectedName = 'ic-neck-on',
	iconImageSetName = 'ic-neck',
	iconImageSetSelectedName = 'ic-neck-on',
	CameraFocus = "neckFocus",
	CameraZoomRadius = 6.5,
	shopUrl = "/catalog/?Category=11&Subcategory=22",
	assetTypeId = "43",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetNeckAccessories',
}
local shoulderAccessoryPage = {
	name = 'Shoulder Accessories',
	title = 'Feature.Avatar.Label.ShoulderAccessories',
	titleLandscape = 'Feature.Avatar.Label.Shoulder',
	iconImageName = 'ic-shoulders',
	iconImageSelectedName = 'ic-shoulders-on',
	iconImageSetName = 'ic-shoulder',
	iconImageSetSelectedName = 'ic-shoulder-on',
	CameraFocus = "shoulderFocus",
	CameraZoomRadius = 6.5,
	shopUrl = "/catalog/?Category=11&Subcategory=23",
	assetTypeId = "44",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetShoulderAccessories',
}
local frontAccessoryPage = {
	name = 'Front Accessories',
	title = 'Feature.Avatar.Label.FrontAccessories',
	titleLandscape = 'Feature.Avatar.Label.Front',
	iconImageName = 'ic-front',
	iconImageSelectedName = 'ic-front-on',
	iconImageSetName = 'ic-front',
	iconImageSetSelectedName = 'ic-front-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 7.5,
	shopUrl = "/catalog/?Category=11&Subcategory=24",
	assetTypeId = "45",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetFrontAccessories',
}
local backAccessoryPage = {
	name = 'Back Accessories',
	title = 'Feature.Avatar.Label.BackAccessories',
	titleLandscape = 'Feature.Avatar.Label.Back',
	iconImageName = 'ic-back',
	iconImageSelectedName = 'ic-back-on',
	iconImageSetName = 'ic-back',
	iconImageSetSelectedName = 'ic-back-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 9,
	shopUrl = "/catalog/?Category=11&Subcategory=25",
	assetTypeId = "46",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetBackAccessories',
}
local waistAccessoryPage = {
	name = 'Waist Accessories',
	title = 'Feature.Avatar.Label.WaistAccessories',
	titleLandscape = 'Feature.Avatar.Label.Waist',
	iconImageName = 'ic-waist',
	iconImageSelectedName = 'ic-waist-on',
	iconImageSetName = 'ic-waist',
	iconImageSetSelectedName = 'ic-waist-on',
	CameraFocus = "waistFocus",
	CameraZoomRadius = 6.5,
	shopUrl = "/catalog/?Category=11&Subcategory=26",
	assetTypeId = "47",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetWaistAccessories',
}
local shirtsPage = {
	name = 'Shirts',
	title = 'Feature.Avatar.Label.Shirts',
	titleLandscape = 'Feature.Avatar.Label.Shirt',
	iconImageName = 'ic-shirts',
	iconImageSelectedName = 'ic-shirts-on',
	iconImageSetName = 'ic-shirt',
	iconImageSetSelectedName = 'ic-shirt-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 9,
	shopUrl = "/catalog/?Category=3&Subcategory=12",
	assetTypeId = "11",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetShirts',
	cameraVerticalChange = Vector3.new(0, -0.7, 0),
}
local pantsPage = {
	name = 'Pants',
	title = 'Feature.Avatar.Label.Pants',
	iconImageName = 'ic-pants',
	iconImageSelectedName = 'ic-pants-on',
	iconImageSetName = 'ic-pants',
	iconImageSetSelectedName = 'ic-pants-on',
	CameraFocus = "legsFocus",
	CameraZoomRadius = 9.5,
	shopUrl = "/catalog/?Category=3&Subcategory=14",
	assetTypeId = "12",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetPants',
	cameraVerticalChange = Vector3.new(0, -.7, 0),
}
local facesPage = {
	name = 'Faces',
	title = 'Feature.Avatar.Label.Faces',
	titleLandscape = 'Feature.Avatar.Label.Face',
	iconImageName = 'ic-face',
	iconImageSelectedName = 'ic-face-on',
	iconImageSetName = 'ic-face',
	iconImageSetSelectedName = 'ic-face-on',
	CameraFocus = "faceFocus",
	CameraZoomRadius = 5,
	shopUrl = "/catalog/?Category=4&Subcategory=10",
	assetTypeId = "18",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetFaces',
}
local headsPage = {
	name = 'Heads',
	title = 'Feature.Avatar.Label.Heads',
	titleLandscape = 'Feature.Avatar.Label.Head',
	iconImageName = 'ic-head',
	iconImageSelectedName = 'ic-head-on',
	iconImageSetName = 'ic-head',
	iconImageSetSelectedName = 'ic-head-on',
	CameraFocus = "faceFocus",
	CameraZoomRadius = 4.5,
	shopUrl = "/catalog/?Category=4&Subcategory=15",
	assetTypeId = "17",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetHeads',
}
local torsosPage = {
	name = 'Torsos',
	title = 'Feature.Avatar.Label.Torsos',
	titleLandscape = 'Feature.Avatar.Label.Torso',
	iconImageName = 'ic-torso',
	iconImageSelectedName = 'ic-torso-on',
	iconImageSetName = 'ic-torso',
	iconImageSetSelectedName = 'ic-torso-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 7.5,
	assetTypeId = "27",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetTorsos',
}
local rightArmsPage = {
	name = 'Right Arms',
	title = 'Feature.Avatar.Label.RightArms',
	iconImageName = 'ic-right-arms',
	iconImageSelectedName = 'ic-right-arms-on',
	iconImageSetName = 'ic-right-arms',
	iconImageSetSelectedName = 'ic-right-arms-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 9,
	assetTypeId = "28",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetRightArms',
	cameraVerticalChange = Vector3.new(0, -0.7, 0),
}
local leftArmsPage = {
	name = 'Left Arms',
	title = 'Feature.Avatar.Label.LeftArms',
	iconImageName = 'ic-left-arms',
	iconImageSelectedName = 'ic-left-arms-on',
	iconImageSetName = 'ic-left-arms',
	iconImageSetSelectedName = 'ic-left-arms-on',
	CameraFocus = "armsFocus",
	CameraZoomRadius = 9,
	assetTypeId = "29",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetLeftArms',
	cameraVerticalChange = Vector3.new(0, -0.7, 0),
}
local rightLegsPage = {
	name = 'Right Legs',
	title = 'Feature.Avatar.Label.RightLegs',
	iconImageName = 'ic-right-legs',
	iconImageSelectedName = 'ic-right-legs-on',
	iconImageSetName = 'ic-right-legs',
	iconImageSetSelectedName = 'ic-right-legs-on',
	CameraFocus = "legsFocus",
	CameraZoomRadius = 9,
	assetTypeId = "31",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetRightLegs',
	cameraVerticalChange = Vector3.new(0, -.7, 0),
}
local leftLegsPage = {
	name = 'Left Legs',
	title = 'Feature.Avatar.Label.LeftLegs',
	iconImageName = 'ic-left-legs',
	iconImageSelectedName = 'ic-left-legs-on',
	iconImageSetName = 'ic-left-legs',
	iconImageSetSelectedName = 'ic-left-legs-on',
	CameraFocus = "legsFocus",
	CameraZoomRadius = 9,
	assetTypeId = "30",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetLeftLegs',
	cameraVerticalChange = Vector3.new(0, -.7, 0),
}
local gearPage = {
	name = 'Gear',
	title = 'Feature.Avatar.Label.Gear',
	iconImageName = 'ic-gear',
	iconImageSelectedName = 'ic-gear-on',
	iconImageSetName = 'ic-gear',
	iconImageSetSelectedName = 'ic-gear-on',
	shopUrl = "/catalog/?Category=5",
	assetTypeId = "19",
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetGear',
}
local skinTonePage = {
	name = 'Skin Tone',
	title = 'Feature.Avatar.Label.SkinTone',
	iconImageName = 'ic-skintone',
	iconImageSelectedName = 'ic-skintone-on',
	iconImageSetName = 'ic-skintone',
	iconImageSetSelectedName = 'ic-skintone-on',
	special = true,
	pageType = AEConstants.PageType.BodyColors,
}
local scalePage = {
	name = 'Scale',
	title = 'Feature.Avatar.Label.Scale',
	iconImageName = 'ic-scale',
	iconImageSelectedName = 'ic-scale-on',
	iconImageSetName = 'ic-scale',
	iconImageSetSelectedName = 'ic-scale-on',
	special = true,
	pageType = AEConstants.PageType.Scale,
}
local climbAnimPage = {
	name = 'Climb Animations',
	title = 'Feature.Avatar.Label.ClimbAnimations',
	titleLandscape = 'Feature.Avatar.Label.Climb',
	iconImageName = 'ic-climb',
	iconImageSelectedName = 'ic-climb-on',
	iconImageSetName = 'ic-climb',
	iconImageSetSelectedName = 'ic-climb-on',
	assetTypeId = "48",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetClimbAnimations',
}
local jumpAnimPage = {
	name = 'Jump Animations',
	title = 'Feature.Avatar.Label.JumpAnimations',
	titleLandscape = 'Feature.Avatar.Label.Jump',
	iconImageName = 'ic-jump',
	iconImageSelectedName = 'ic-jump-on',
	iconImageSetName = 'ic-jump',
	iconImageSetSelectedName = 'ic-jump-on',
	assetTypeId = "52",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetJumpAnimations',
}
local fallAnimPage = {
	name = 'Fall Animations',
	title = 'Feature.Avatar.Label.FallAnimations',
	titleLandscape = 'Feature.Avatar.Label.Fall',
	iconImageName = 'ic-fall',
	iconImageSelectedName = 'ic-fall-on',
	iconImageSetName = 'ic-fall',
	iconImageSetSelectedName = 'ic-fall-on',
	assetTypeId = "50",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetFallAnimations',
}
local idleAnimPage = {
	name = 'Idle Animations',
	title = 'Feature.Avatar.Label.IdleAnimations',
	titleLandscape = 'Feature.Avatar.Label.Idle',
	iconImageName = 'ic-idle',
	iconImageSelectedName = 'ic-idle-on',
	iconImageSetName = 'ic-idle',
	iconImageSetSelectedName = 'ic-idle-on',
	assetTypeId = "51",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetIdleAnimations',
}
local walkAnimPage = {
	name = 'Walk Animations',
	title = 'Feature.Avatar.Label.WalkAnimations',
	titleLandscape = 'Feature.Avatar.Label.Walk',
	iconImageName = 'ic-walk',
	iconImageSelectedName = 'ic-walk-on',
	iconImageSetName = 'ic-walk',
	iconImageSetSelectedName = 'ic-walk-on',
	assetTypeId = "55",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetWalkAnimations',
}
local runAnimPage = {
	name = 'Run Animations',
	title = 'Feature.Avatar.Label.RunAnimations',
	titleLandscape = 'Feature.Avatar.Label.Run',
	iconImageName = 'ic-run',
	iconImageSelectedName = 'ic-run-on',
	iconImageSetName = 'ic-run',
	iconImageSetSelectedName = 'ic-run-on',
	assetTypeId = "53",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetRunAnimations',
}
local swimAnimPage = {
	name = 'Swim Animations',
	title = 'Feature.Avatar.Label.SwimAnimations',
	titleLandscape = 'Feature.Avatar.Label.Swim',
	iconImageName = 'ic-swim',
	iconImageSelectedName = 'ic-swim-on',
	iconImageSetName = 'ic-swim',
	iconImageSetSelectedName = 'ic-swim-on',
	assetTypeId = "54",
	pageType = AEConstants.PageType.Animation,
	emptyStringKey = 'Feature.Avatar.Message.EmptyAssetSwimAnimations',
}
local currentlyWearingClothingPage = {
	name = 'Feature.Avatar.Label.CurrentlyWearing',
	title = 'Feature.Avatar.Label.CurrentlyWearing',
	titleLandscape = 'Feature.Avatar.Label.CurrentlyWearing',
	iconImageName = 'ic-costumes',
	iconImageSelectedName = 'ic-costumes-on',
	iconImageSetName = 'ic-costume',
	iconImageSetSelectedName = 'ic-costume-on',
	pageType = AEConstants.PageType.CurrentlyWearing,
	emptyStringKey = 'Feature.Avatar.Message.EmptyCurrentlyWearing',
}
local recentCategory = {
	name = 'Feature.Avatar.Heading.Recent',
	title = 'Feature.Avatar.Heading.Recent',
	iconImageName = 'ic-recent',
	selectedIconImageName = 'ic-recent-on',
	imageSetName = 'AE/Icons/ic-recent',
	imageSetSelectedName = 'AE/Icons/ic-recent-on',
	iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-recent-wht.png',
	selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-recent-blk.png',
	pages = {currentlyWearingClothingPage, recentPage,},
	positionInCategoryMenu = 1,
}
local clothingCategory = {
	name = 'Feature.Avatar.Heading.Clothing',
	title = 'Feature.Avatar.Heading.Clothing',
	iconImageName = 'ic-clothing',
	selectedIconImageName = 'ic-clothing-on',
	imageSetName = 'AE/Icons/ic-clothing',
	imageSetSelectedName = 'AE/Icons/ic-clothing-on',
	iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-clothing-wht.png',
	selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-clothing-blk.png',
	positionInCategoryMenu = 2,
	pages = {hatsPage,
		shirtsPage,
		pantsPage,
		hairPage,
		faceAccessoryPage,
		neckAccessoryPage,
		shoulderAccessoryPage,
		frontAccessoryPage,
		backAccessoryPage,
		waistAccessoryPage,
		gearPage,},
}
local bodyCategory = {
	name = 'Feature.Avatar.Heading.Body',
	title = 'Feature.Avatar.Heading.Body',
	iconImageName = 'ic-body',
	selectedIconImageName = 'ic-body-on',
	imageSetName = 'AE/Icons/ic-body',
	imageSetSelectedName = 'AE/Icons/ic-body-on',
	iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-body-wht.png',
	selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-body-blk.png',
	positionInCategoryMenu = 3,
	pages = {
		skinTonePage,
		scalePage,
		facesPage,
		headsPage,
		torsosPage,
		rightArmsPage,
		leftArmsPage,
		rightLegsPage,
		leftLegsPage},
}
local animationCategory = {
	name = 'Feature.Avatar.Heading.Animations',
	title = 'Feature.Avatar.Heading.Animations',
	titleLandscape = 'Feature.Avatar.Heading.Animations',
	iconImageName = 'ic-animations',
	selectedIconImageName = 'ic-animations-on',
	imageSetName = 'AE/Icons/ic-run',
	imageSetSelectedName = 'AE/Icons/ic-run-on',
	iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-animation-wht.png',
	selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-animation-blk.png',
	positionInCategoryMenu = 4,
	pages = {idleAnimPage, walkAnimPage, runAnimPage, jumpAnimPage, fallAnimPage, climbAnimPage, swimAnimPage}
}
local outfitsCategory = {
	name = 'Outfits',
	title = 'Feature.Avatar.Heading.Outfits',
	iconImageName = 'ic-costumes',
	selectedIconImageName = 'ic-costumes-on',
	imageSetName = 'AE/Icons/ic-costume',
	imageSetSelectedName = 'AE/Icons/ic-costume-on',
	iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-costume-wht.png',
	selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-costume-blk.png',
	positionInCategoryMenu = FFlagAvatarEditorEmotesSupport and 6 or 5,
	pages = {outfitsPage, presetCostumesPage}
}

if FFlagAvatarEditorEmotesSupport then
	local function createEmotesPage(pageNumber)
		return {
			name = tostring(pageNumber),
			title = 'Feature.Avatar.Heading.Emotes',
			iconText = tostring(pageNumber),
			emoteSlot = pageNumber,

			assetTypeId = "61",
			pageType = AEConstants.PageType.Emotes,
			emptyStringKey = 'Feature.Avatar.Message.EmptyAssetEmotes',
		}
	end

	local emotesPages = {}
	for i = 1, AEConstants.EmotesPages do
		emotesPages[i] = createEmotesPage(i)
	end

	local emotesCategory = {
		name = AEConstants.EMOTES,
		title = 'Feature.Avatar.Heading.Emotes',
		imageSetName = 'AE/Icons/ic-emote',
		imageSetSelectedName = 'AE/Icons/ic-emote-on',
		iconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-emote-wht.png',
		selectedIconImageConsole = 'rbxasset://textures/ui/Shell/AvatarEditor/icon/ic-emote-blk.png',
		positionInCategoryMenu = 5,
		pages = emotesPages,
	}

	AECategories.categories = {
		recentCategory,
		clothingCategory,
		bodyCategory,
		animationCategory,
		emotesCategory,
		outfitsCategory,
	}
else
	AECategories.categories = {
		recentCategory,
		clothingCategory,
		bodyCategory,
		animationCategory,
		outfitsCategory,
	}
end

return AECategories
