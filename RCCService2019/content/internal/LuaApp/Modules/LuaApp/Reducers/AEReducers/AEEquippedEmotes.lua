local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local Modules = CoreGui.RobloxGui.Modules
local LuaApp = Modules.LuaApp

local Cryo = require(CorePackages.Cryo)
local Rodux = require(CorePackages.Rodux)

local AEConstants = require(LuaApp.Components.Avatar.AEConstants)

local AEReceivedAvatarData = require(LuaApp.Actions.AEActions.AEReceivedAvatarData)
local AESelectCategoryTab = require(LuaApp.Actions.AEActions.AESelectCategoryTab)
local AEToggleEquipAsset = require(LuaApp.Actions.AEActions.AEToggleEquipAsset)

local EMOTES_CATEGORY = 5

local default = {
    slotInfo = {},

    tabOpen = 1,
}

local function createSlotInfo(emotesData)
    local slotInfo = {}

    for _, emoteInfo in ipairs(emotesData) do
        local slotNumber = emoteInfo.position
        local assetId = tostring(emoteInfo.assetId)

        slotInfo[slotNumber] = {
            assetId = assetId,
            position = slotNumber,
        }
    end

    return slotInfo
end

local function addEmoteToSlot(slotInfo, position, emoteInfo)
    return Cryo.Dictionary.join(slotInfo, {
        [position] = emoteInfo,
    })
end

local function removeEmoteFromSlot(slotInfo, position)
    return Cryo.Dictionary.join(slotInfo, {
        [position] = Cryo.None,
    })
end

return Rodux.createReducer(default, {
    [AEReceivedAvatarData.name] = function(state, action)
        local emotesData = action.avatarData.emotes
        emotesData = emotesData or {}

        local slotInfo = createSlotInfo(emotesData)

        return Cryo.Dictionary.join(state, {
            slotInfo = slotInfo,
        })
    end,

    [AEToggleEquipAsset.name] = function(state, action)
        if action.assetType ~= AEConstants.AssetTypes.Emote then
            return state
        end

        local oldEmoteInfo = state.slotInfo[state.tabOpen]

        local emoteInfo = {
            assetId = action.assetId,
            position = state.tabOpen,
        }

        local newSlotInfo
        if not oldEmoteInfo or oldEmoteInfo.assetId ~= emoteInfo.assetId then
            newSlotInfo = addEmoteToSlot(state.slotInfo, state.tabOpen, emoteInfo)
        else
            newSlotInfo = removeEmoteFromSlot(state.slotInfo, state.tabOpen)
        end

        return Cryo.Dictionary.join(state, {
            slotInfo = newSlotInfo,
        })
    end,

    [AESelectCategoryTab.name] = function(state, action)
        if action.categoryIndex ~= EMOTES_CATEGORY then
            return state
        end

        return Cryo.Dictionary.join(state, {
            tabOpen = action.tabIndex,
        })
    end,
})
