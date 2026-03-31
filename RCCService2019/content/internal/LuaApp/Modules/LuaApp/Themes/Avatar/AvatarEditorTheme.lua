local Modules = game:GetService("CoreGui").RobloxGui.Modules
local AEAssetCard = require(Modules.LuaApp.Themes.Avatar.AEAssetCard)
local AEBodyColors = require(Modules.LuaApp.Themes.Avatar.AEBodyColors)
local AEScrollingFrame = require(Modules.LuaApp.Themes.Avatar.AEScrollingFrame)
local AESliders = require(Modules.LuaApp.Themes.Avatar.AESliders)
local AEDialogFrame = require(Modules.LuaApp.Themes.Avatar.AEDialogFrame)
local AETabListAndButtons = require(Modules.LuaApp.Themes.Avatar.AETabListAndButtons)
local AEAvatarTypeSwitch = require(Modules.LuaApp.Themes.Avatar.AEAvatarTypeSwitch)
local AECategoryMenuAndButtons = require(Modules.LuaApp.Themes.Avatar.AECategoryMenuAndButtons)
local AEAssetOptionsAndDetailsMenu = require(Modules.LuaApp.Themes.Avatar.AEAssetOptionsAndDetailsMenu)
local AEShopButton = require(Modules.LuaApp.Themes.Avatar.AEShopButton)
local AEHatSlot = require(Modules.LuaApp.Themes.Avatar.AEHatSlot)
local AEDarkCover = require(Modules.LuaApp.Themes.Avatar.AEDarkCover)
local AEWarningWidget = require(Modules.LuaApp.Themes.Avatar.AEWarningWidget)
local EmotesWheel = require(Modules.LuaApp.Themes.Avatar.AEEmotesWheel)
local EmotesOverlay = require(Modules.LuaApp.Themes.Avatar.AEEmotesOverlay)
local CatalogButton = require(Modules.LuaApp.Themes.Avatar.CatalogButton)

return function()
	return {
		AEDarkCover =  AEDarkCover.new(),
		AEHatSlot = AEHatSlot.new(),
		AEShopButton = AEShopButton.new(),
		AEAssetOptionsAndDetailsMenu = AEAssetOptionsAndDetailsMenu.new(),
		AEAvatarTypeSwitch = AEAvatarTypeSwitch.new(),
		AETabListAndButtons = AETabListAndButtons.new(),
		AECategoryMenuAndButtons = AECategoryMenuAndButtons.new(),
		AEAssetCard = AEAssetCard.new(),
		AEBodyColors = AEBodyColors.new(),
		AEScrollingFrame = AEScrollingFrame.new(),
		AESliders = AESliders.new(),
		AEDialogFrame = AEDialogFrame(),
		AEWarningWidget = AEWarningWidget.new(),
		EmotesWheel = EmotesWheel.new(),
		EmotesOverlay = EmotesOverlay.new(),
		CatalogButton = CatalogButton.new(),
	}
end