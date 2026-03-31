local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local Modules = CoreGui.RobloxGui.Modules
local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
local AESetGamepadNavigationMenuLevel = require(Modules.LuaApp.Actions.AEActions.AESetGamepadNavigationMenuLevel)
local AESetAvatarType = require(Modules.LuaApp.Thunks.AEThunks.AESetAvatarType)
local AEToggleFullView = require(Modules.LuaApp.Actions.AEActions.AEToggleFullView)
local AESoundManager = require(Modules.LuaApp.Components.Avatar.AESoundManager)
local RemoveScreen = require(Modules.Shell.Actions.RemoveScreen)

local AEConsoleControlsManager = {}
AEConsoleControlsManager.__index = AEConsoleControlsManager

function AEConsoleControlsManager.new(store)
	local self = {}
	self.store = store
	self.connections = {}
	setmetatable(self, AEConsoleControlsManager)
	self.savedSelectedCoreObject = nil
	return self
end

function AEConsoleControlsManager:start()
	self.started = true
	local toggleButtonDebounce = true
	local toggleViewDebounce = true

	ContextActionService:UnbindCoreAction("KeyControls")
	ContextActionService:BindCoreAction("KeyControls", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			if inputObject.KeyCode == Enum.KeyCode.ButtonSelect and not self.store:getState().AEAppReducer.AEFullView then
				if toggleButtonDebounce then
					local newAvatarType = self.store:getState().AEAppReducer.AECharacter.AEAvatarType == AEConstants.AvatarType.R6
						and AEConstants.AvatarType.R15 or AEConstants.AvatarType.R6
					toggleButtonDebounce = false
					AESoundManager:Play('ButtonPress')
					self.store:dispatch(AESetAvatarType(newAvatarType))
					toggleButtonDebounce = true
				end
			end

			if inputObject.KeyCode == Enum.KeyCode.ButtonR3 then
				if toggleViewDebounce then
					toggleViewDebounce = false
					AESoundManager:Play('ScreenChange')
					self.store:dispatch(AEToggleFullView())
					toggleViewDebounce = true
				end
			end
		end
	end,
	false, Enum.KeyCode.ButtonR3, Enum.KeyCode.ButtonSelect)

	ContextActionService:UnbindCoreAction("AvatarEditorMenu")
	ContextActionService:BindCoreAction("AvatarEditorMenu", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.End then
			if inputObject.KeyCode == Enum.KeyCode.ButtonB then
				if self.store:getState().AEAppReducer.AEGamepadNavigationMenuLevel
					~= AEConstants.GamepadNavigationMenuLevel.CategoryMenu then
					local currentMenuLevel = self.store:getState().AEAppReducer.AEGamepadNavigationMenuLevel
					local newMenuLevel = currentMenuLevel == AEConstants.GamepadNavigationMenuLevel.TabList
						and AEConstants.GamepadNavigationMenuLevel.CategoryMenu or AEConstants.GamepadNavigationMenuLevel.TabList
					AESoundManager:Play('PopUp')
					self.store:dispatch(AESetGamepadNavigationMenuLevel(newMenuLevel))
				else
					local avatarEditorScreen = self.store:getState().ScreenList[1]
					self.store:dispatch(RemoveScreen(avatarEditorScreen))
				end
			end
		end
	end,
	false, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonA)

	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	table.insert(self.connections, storeChangedConnection)
end

--[[
	When in full view, allow buttonB to close the full view, and sink the other buttons.
]]
function AEConsoleControlsManager:updateFullViewCoreAction(fullView)
	ContextActionService:UnbindCoreAction("FullView")
	if fullView == true then
		ContextActionService:BindCoreAction("FullView",
			function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.End then
					if inputObject.KeyCode == Enum.KeyCode.ButtonB then
						AESoundManager:Play('ScreenChange')
						self.store:dispatch(AEToggleFullView())
					end
					return Enum.ContextActionResult.Sink
				end
			end,
			false, Enum.KeyCode.ButtonB, Enum.KeyCode.ButtonA)
	end
end

function AEConsoleControlsManager:update(newState, oldState)
	if newState.AEAppReducer.AEFullView ~= oldState.AEAppReducer.AEFullView then
		self:updateFullViewCoreAction(newState.AEAppReducer.AEFullView)
		if newState.AEAppReducer.AEFullView then
			self.savedSelectedCoreObject = GuiService.SelectedCoreObject
			GuiService.SelectedCoreObject = nil
		else
			GuiService.SelectedCoreObject = self.savedSelectedCoreObject
		end
	end
end

function AEConsoleControlsManager:stop()
	self.started = false

	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}

	ContextActionService:UnbindCoreAction("AvatarEditorMenu")
	ContextActionService:UnbindCoreAction("FullView")
	ContextActionService:UnbindCoreAction("KeyControls")
end

return AEConsoleControlsManager