return function()
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")

    local Modules = CoreGui.RobloxGui.Modules
    local LuaApp = Modules.LuaApp

    local AEConstants = require(LuaApp.Components.Avatar.AEConstants)
    local AEEquippedEmotes = require(script.Parent.AEEquippedEmotes)

    local EMOTES_TYPE = AEConstants.AssetTypes.Emote
    local EMOTES_CATEGORY = 5

    -- Actions
    local AEReceivedAvatarData = require(LuaApp.Actions.AEActions.AEReceivedAvatarData)
    local AESelectCategoryTab = require(LuaApp.Actions.AEActions.AESelectCategoryTab)
    local AEToggleEquipAsset = require(LuaApp.Actions.AEActions.AEToggleEquipAsset)

	it("should be unchanged by other actions", function()
		local oldState = AEEquippedEmotes(nil, {})
		local newState = AEEquippedEmotes(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("AEReceivedAvatarData", function()
        it("should create emotes info from received avatar data", function()
            local avatarData = [[
                {
                    "scales": {},
                    "playerAvatarType": "R15",
                    "bodyColors": {},
                    "assets": [],
                    "defaultShirtApplied": false,
                    "defaultPantsApplied": false,
                    "emotes": [
                        {
                            "assetId": 2147616526,
                            "assetName": "Laugh",
                            "position": 1
                        },
                        {
                            "assetId": 2147617580,
                            "assetName": "Wave",
                            "position": 4
                        }
                    ]
                }
            ]]

            local dataTable = HttpService:JSONDecode(avatarData)

            local newState = AEEquippedEmotes(nil, AEReceivedAvatarData(dataTable))
            expect(newState.slotInfo[1].assetId).to.equal("2147616526")
            expect(newState.slotInfo[4].assetId).to.equal("2147617580")
        end)
	end)

	describe("AEToggleEquipAsset", function()
        it("should equip an Emote with AEToggleEquipAsset", function()
            local newState = AEEquippedEmotes(nil, AEToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1].assetId).to.equal("333")
        end)

        it("should unequip an asset with AEToggleEquipAsset", function()
            local newState = AEEquippedEmotes(nil, AEToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1].assetId).to.equal("333")

            newState = AEEquippedEmotes(newState, AEToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1]).never.to.be.ok()
        end)

        it("should not equip non Emotes with AEToggleEquipAsset", function()
            local newState = AEEquippedEmotes(nil, AEToggleEquipAsset("1", "333"))
            expect(newState.slotInfo[1]).never.to.be.ok()
        end)
    end)

    describe("AESelectCategoryTab", function()
        it("should change tabOpen with AESelectCategoryTab", function()
            local newState = AEEquippedEmotes(nil, AESelectCategoryTab(EMOTES_CATEGORY, 4))
            expect(newState.tabOpen).to.equal(4)

            newState = AEEquippedEmotes(newState, AESelectCategoryTab(EMOTES_CATEGORY, 2))
            expect(newState.tabOpen).to.equal(2)
        end)

        it("should not change tabOpen with AESelectCategoryTab for other categories", function()
            local newState = AEEquippedEmotes(nil, AESelectCategoryTab(EMOTES_CATEGORY, 4))
            expect(newState.tabOpen).to.equal(4)

            newState = AEEquippedEmotes(newState, AESelectCategoryTab(1, 2))
            expect(newState.tabOpen).to.equal(4)
        end)
    end)

    describe("AESelectCategoryTab and AEToggleEquipAsset", function()
        it("should equip emote on selected slot", function()
            local newState = AEEquippedEmotes(nil, AESelectCategoryTab(EMOTES_CATEGORY, 4))
            expect(newState.tabOpen).to.equal(4)

            newState = AEEquippedEmotes(newState, AEToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[4].assetId).to.equal("333")
        end)
    end)
end