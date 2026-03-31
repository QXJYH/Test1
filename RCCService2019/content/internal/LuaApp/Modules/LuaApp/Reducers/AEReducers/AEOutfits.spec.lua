return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AEOutfits = require(script.Parent.AEOutfits)
	local AESetOutfitInfo = require(Modules.LuaApp.Actions.AEActions.AESetOutfitInfo)
	local AERevokeOutfit = require(Modules.LuaApp.Actions.AEActions.AERevokeOutfit)
	local AEUpdateOutfit = require(Modules.LuaApp.Actions.AEActions.AEUpdateOutfit)
	local AEOutfitInfo = require(Modules.LuaApp.Models.AEOutfitInfo)
	local FFlagAvatarEditorCostumeSignalR = settings():GetFFlag("AvatarEditorCostumeSignalR")

	it("should be unchanged by other actions", function()
		local oldState = AEOutfits(nil, {})
		local newState = AEOutfits(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	it("should save an outfit's info (list of assets and body colors)", function()
		local outfit = AEOutfitInfo.mock()
		outfit.assets = { 1, 2, 3 }

		local oldState = AEOutfits(nil, {})
		local newState = AEOutfits(oldState, AESetOutfitInfo(outfit))

		expect(newState[outfit.outfitId]).to.equal(outfit)

	end)

	it("should save multiple outfits, without changing other outfits.", function()
		local outfit = AEOutfitInfo.mock()
		outfit.assets = { 1, 2, 3 }
		local outfit2 = AEOutfitInfo.mock()

		local oldState = AEOutfits(nil, {})
		local newState = AEOutfits(oldState, AESetOutfitInfo(outfit))
		expect(newState[outfit.outfitId]).to.equal(outfit)

		newState = AEOutfits(newState, AESetOutfitInfo(outfit2))
		expect(newState[outfit.outfitId]).to.equal(outfit)
		expect(newState[outfit2.outfitId]).to.equal(outfit2)
	end)
	if FFlagAvatarEditorCostumeSignalR then
		it("Should remove an outfit's information, without changing other outfits.", function()
				local outfit = AEOutfitInfo.mock()
				outfit.assets = { 1, 2, 3 }
				local outfit2 = AEOutfitInfo.mock()

				AEOutfits(nil, AESetOutfitInfo(outfit))
				local oldState = AEOutfits(newState, AESetOutfitInfo(outfit2))
				local newState = AEOutfits(oldState, AERevokeOutfit(outfit.outfitId))
				expect(newState[outfit.outfitId]).to.equal(nil)
				expect(newState[outfit2.outfitId]).to.equal(outfit2)

				newState = AEOutfits(oldState, AEUpdateOutfit(outfit2.outfitId))
				expect(newState[outfit2.outfitId]).to.equal(nil)
		end)
	end
end