return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AEOwnedAssets = require(script.Parent.AEOwnedAssets)
	local AESetOwnedAssets = require(Modules.LuaApp.Actions.AEActions.AESetOwnedAssets)
	local AEGrantAsset = require(Modules.LuaApp.Actions.AEActions.AEGrantAsset)
	local AERevokeAsset = require(Modules.LuaApp.Actions.AEActions.AERevokeAsset)
	local AEGrantOutfit = require(Modules.LuaApp.Actions.AEActions.AEGrantOutfit)
	local AERevokeOutfit = require(Modules.LuaApp.Actions.AEActions.AERevokeOutfit)
	local AEConstants = require(Modules.LuaApp.Components.Avatar.AEConstants)
	local MockId = require(Modules.LuaApp.MockId)
	local FFlagAvatarEditorCostumeSignalR = settings():GetFFlag("AvatarEditorCostumeSignalR")

	describe("AESetOwnedAssets", function()
		it("should be unchanged by other actions", function()
			local oldState = AEOwnedAssets(nil, {})
			local newState = AEOwnedAssets(oldState, { type = "not a real action" })
			expect(oldState).to.equal(newState)
		end)

		it("should set the assets a player owns", function()
			local assets = { 1, 2, 3 }
			local assets2 = { 4, 5, 6 }
			local newState = AEOwnedAssets(nil, AESetOwnedAssets(1, assets))
			newState = AEOwnedAssets(newState, AESetOwnedAssets(2, assets2))
			expect(#newState[1]).to.equal(3)
		end)

		it("should not duplicate any owned assets", function()
			local assets = { 1, 2, 3 }
			local newState = AEOwnedAssets(nil, AESetOwnedAssets(1, assets))
			newState = AEOwnedAssets(newState, AESetOwnedAssets(1, assets))

			expect(#newState[1]).to.equal(3)
			expect(newState[1][1]).never.to.equal(newState[1][2])
			expect(newState[1][1]).never.to.equal(newState[1][3])
		end)
	end)

	describe("AEGrantAsset", function()
		it("should grant an asset and move it to the front of its respective list.", function()
			local assets = { "1", "2", "3" }
			local newAsset = "5"
			local assetTypeId = "1"
			local newState = AEOwnedAssets(nil, AESetOwnedAssets(assetTypeId, assets))

			newState = AEOwnedAssets(newState, AEGrantAsset(assetTypeId, newAsset))
			expect(newState["1"][1]).to.equal(newAsset)
			expect(#newState["1"]).to.equal(4)
		end)

		it("should not grant assets that are already owned.", function()
			local assets = { 1, 2, 3 }
			local dupAsset = 1
			local assetTypeId = 1
			local newState = AEOwnedAssets(nil, AESetOwnedAssets(assetTypeId, assets))

			newState = AEOwnedAssets(newState, AEGrantAsset(assetTypeId, dupAsset))
			expect(#newState[1]).to.equal(3)
		end)
	end)

	describe("AERevokeAsset", function()
		it("should remove an asset.", function()
			local assets = { "1", "2", "3" }
			local revokeAssetId = "1"
			local assetTypeId = "1"
			local newState = AEOwnedAssets(nil, AESetOwnedAssets(assetTypeId, assets))
			newState = AEOwnedAssets(newState, AERevokeAsset(assetTypeId, revokeAssetId))

			expect(#newState["1"]).to.equal(2)
			expect(newState["1"][1]).never.to.equal(revokeAssetId)
		end)
	end)

	if FFlagAvatarEditorCostumeSignalR then
		describe("AEGrantOutfit", function()
			it("should grant a outfit.", function()
				local outfitId = MockId();
				local newState = AEOwnedAssets(nil, AEGrantOutfit(outfitId))
				expect(newState[AEConstants.OUTFITS][1]).to.equal(outfitId)
			end)
			it("should not grant costumes that are already owned.", function()
				local outfitId = MockId();
				local newState = AEOwnedAssets(nil, AEGrantOutfit(outfitId))

				newState = AEOwnedAssets(newState, AEGrantOutfit(outfitId))
				expect(newState[AEConstants.OUTFITS][1]).to.equal(outfitId)
				expect(newState[AEConstants.OUTFITS][2]).to.equal(nil)
			end)
		end)

		describe("AERevokeOutfit", function()
			it("should remove an outfit.", function()
				local outfitId = MockId();
				local newState = AEOwnedAssets(nil, AEGrantOutfit(outfitId))
				newState = AEOwnedAssets(newState, AERevokeOutfit(outfitId))

				expect(newState[AEConstants.OUTFITS][1]).to.equal(nil)
				expect(newState[AEConstants.OUTFITS][1]).never.to.equal(outfitId)
			end)
		end)
	end
end