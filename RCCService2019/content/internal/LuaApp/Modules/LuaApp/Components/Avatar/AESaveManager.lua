local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local AEWebApi = require(Modules.LuaApp.Components.Avatar.AEWebApi)
local AEUtils = require(Modules.LuaApp.Components.Avatar.AEUtils)
local IS_CONSOLE = GuiService:IsTenFootInterface()
local EventHub
if IS_CONSOLE then
	EventHub = require(Modules.Shell.EventHub)
end
local FFAvatarEditorEquippedAssetsNilIndexingFix = settings():GetFFlag("AvatarEditorEquippedAssetsNilIndexingFix")

local AESaveManager = {}
AESaveManager.__index = AESaveManager
local TIME_BETWEEN_SAVES = 5

function AESaveManager.new(store)
	local self = {}
	self.store = store
	self.connections = {}
	setmetatable(self, AESaveManager)

	return self
end

function AESaveManager:start()
	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	table.insert(self.connections, storeChangedConnection)
	self.timeSinceLastSave = 0.0
	self.waitingForSave = false
	self.characterUpdated = false
	self.characterEquipped = false
	self.lastSavedBodyColors = self.store:getState().AEAppReducer.AECharacter.AEBodyColors
	self.lastSavedAvatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType
	self.lastSavedScales = self.store:getState().AEAppReducer.AECharacter.AEAvatarScales
	self.lastSavedAssets = self.store:getState().AEAppReducer.AECharacter.AEEquippedAssets
	self.lastSavedEmotes = self.store:getState().AEAppReducer.AEEquippedEmotes.slotInfo
end

function AESaveManager:update(newState, oldState)
	local newBodyColors = newState.AEAppReducer.AECharacter.AEBodyColors
	local newAvatarType = newState.AEAppReducer.AECharacter.AEAvatarType
	local newScales = newState.AEAppReducer.AECharacter.AEAvatarScales
	local newAssets = newState.AEAppReducer.AECharacter.AEEquippedAssets
	local newEmotes = newState.AEAppReducer.AEEquippedEmotes.slotInfo
	local shouldSave = false

	if newBodyColors ~= self.lastSavedBodyColors or newAvatarType ~= self.lastSavedAvatarType
		or newScales ~= self.lastSavedScales or newAssets ~= self.lastSavedAssets
		or newEmotes ~= self.lastSavedEmotes then
		shouldSave = true
	end

	-- If something needs to be saved and we aren't waiting to save already
	if shouldSave and not self.saving then
		self:save(false)
	end
end

function AESaveManager:stop()
	self:save(true)
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}

	-- Notify PackageData to update the avatar's profile picture
	if IS_CONSOLE then
		spawn(function()
			if self.characterUpdated then
				EventHub:dispatchEvent(EventHub.Notifications["CharacterUpdated"])
			end

			if self.characterEquipped then
				EventHub:dispatchEvent(EventHub.Notifications["CharacterEquipped"],
					self.store:getState().AEAppReducer.AECharacter.AEEquippedAssets, self.characterUpdated)
			end

			self.characterUpdated = false
			self.characterEquipped = false
		end)
	end
end

-- skipWait: only when stop() is called.
function AESaveManager:save(skipWait)
	self.saving = true

	spawn(function()
		local timeSinceLastSave = tick() - self.timeSinceLastSave
		-- Save no shorter than every 5 seconds
		if not skipWait and timeSinceLastSave < TIME_BETWEEN_SAVES then
			wait(TIME_BETWEEN_SAVES - timeSinceLastSave)
		end

		-- Use the latest store in case the character was updated while waiting
		local currentBodyColors = self.store:getState().AEAppReducer.AECharacter.AEBodyColors
		local avatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType
		local currentScales = self.store:getState().AEAppReducer.AECharacter.AEAvatarScales
		local currentAssets = self.store:getState().AEAppReducer.AECharacter.AEEquippedAssets
		local currentEmotes = self.store:getState().AEAppReducer.AEEquippedEmotes.slotInfo

		if currentBodyColors ~= self.lastSavedBodyColors then
			self:saveBodyColors(currentBodyColors)
			self.characterUpdated = true
		end

		if avatarType ~= self.lastSavedAvatarType then
			self:saveAvatarType(avatarType)
			self.characterUpdated = true
		end

		if currentScales ~= self.lastSavedScales then
			self:saveScales(currentScales)
			self.characterUpdated = true
		end

		if (currentAssets or not FFAvatarEditorEquippedAssetsNilIndexingFix) and currentAssets ~= self.lastSavedAssets then
			self:saveAssets(currentAssets)
			self.characterUpdated = true
			self.characterEquipped = true
		end

		if currentEmotes ~= self.lastSavedEmotes then
			self:saveEmotes(currentEmotes)
			self.characterUpdated = true
			self.characterEquipped = true
		end

		self.timeSinceLastSave = tick()
		self.saving = false
	end)
end

function AESaveManager:saveBodyColors(currentBodyColors)
	local bodyColors = {
		["headColorId"] = currentBodyColors["headColorId"],
		["leftArmColorId"] = currentBodyColors["leftArmColorId"],
		["leftLegColorId"] = currentBodyColors["leftLegColorId"],
		["rightArmColorId"] = currentBodyColors["rightArmColorId"],
		["rightLegColorId"] = currentBodyColors["rightLegColorId"],
		["torsoColorId"] = currentBodyColors["torsoColorId"]
	}
	local status = AEWebApi.SetBodyColors(bodyColors)
	if status ~= AEWebApi.Status.OK then
		warn("Failure saving body colors.")
	else
		self.lastSavedBodyColors = currentBodyColors
	end
end

function AESaveManager:saveAvatarType(avatarType)
	local status = AEWebApi.SetPlayerAvatarType(avatarType)
	if status ~= AEWebApi.Status.OK then
		warn("Failure saving avatar type.")
	else
		self.lastSavedAvatarType = avatarType
	end
end

function AESaveManager:saveScales(currentScales)
	local status = AEWebApi.SetScales(currentScales)
	if status ~= AEWebApi.Status.OK then
		warn("Failure saving scales.")
	else
		self.lastSavedScales = currentScales
	end
end

function AESaveManager:saveAssets(currentAssets)
	local assets = AEUtils.getEquippedAssetIds(currentAssets)

	local status = AEWebApi.SetWearingAssets(assets)
	if status ~= AEWebApi.Status.OK then
		warn("Failure saving assets.")
	else
		self.lastSavedAssets = currentAssets
	end
end

function AESaveManager:saveEmotes(currentEmotes)
	local postDataArray = {}
	for _, emoteInfo in pairs(currentEmotes) do
		postDataArray[#postDataArray + 1] = emoteInfo
	end

	local status = AEWebApi.SetEmotes(postDataArray)
	if status ~= AEWebApi.Status.OK then
		warn("Failure saving emotes.")
	else
		self.lastSavedEmotes = currentEmotes
	end
end

return AESaveManager