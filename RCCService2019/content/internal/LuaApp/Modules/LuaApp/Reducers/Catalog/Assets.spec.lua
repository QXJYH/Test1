return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local LuaApp = Modules.LuaApp
	local AssetThumbnails = require(script.Parent.Assets)
	local SetAssetThumbnailsAction = require(LuaApp.Actions.Catalog.SetAssetThumbnailsAction)
	local MockId = require(LuaApp.MockId)

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	local function createMockThumbnail(size, url)
		return {
			universeId = MockId(),
			state = "",
			url = url,
			size = size,
		}
	end

	it("should be empty by default", function()
		local defaultState = AssetThumbnails(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = AssetThumbnails(nil, {})
		local newState = AssetThumbnails(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetAssetThumbnailsAction", function()
		it("should preserve purity", function()
			local oldState = AssetThumbnails(nil, {})
			local assetId = tostring(MockId())
			local thumbsData = {}
			thumbsData[assetId] = {
				["1"] = tostring(MockId())
			}
			local newState = AssetThumbnails(oldState, SetAssetThumbnailsAction(thumbsData))
			expect(oldState).to.never.equal(newState)
		end)

		it("should add thumbnails", function()
			local assetId = tostring(MockId())
			local thumbsData1 = {}
			thumbsData1[assetId] = createMockThumbnail("1", "")
			local action = SetAssetThumbnailsAction(thumbsData1)

			local oldState = AssetThumbnails(nil, {})
			local newState = AssetThumbnails(oldState, action)

			local modifiedState = newState[assetId]
			expect(modifiedState).to.never.equal(nil)
			expect(countKeys(modifiedState.thumbnails)).to.equal(1)
		end)

		it("should add thumbnails of the different sizes without effecting other thumbnail sizes", function()
			local assetId = tostring(MockId())
			local thumbsData1 = {}
			local thumbsData2 = {}
			local thumbnailSize1 = "1"
			local thumbnailSize2 = "2"
			local thumbnailUrl1 = tostring(MockId())
			local thumbnailUrl2 = tostring(MockId())
			thumbsData1[assetId] = createMockThumbnail(thumbnailSize1, thumbnailUrl1)
			thumbsData2[assetId] = createMockThumbnail(thumbnailSize2, thumbnailUrl2)
			local action1 = SetAssetThumbnailsAction(thumbsData1)
			local action2 = SetAssetThumbnailsAction(thumbsData2)

			local oldState = AssetThumbnails(nil, action1)
			local newState = AssetThumbnails(oldState, action2)

			local modifiedState = newState[assetId]
			expect(countKeys(modifiedState.thumbnails)).to.equal(2)
			expect(modifiedState.thumbnails[thumbnailSize1]).to.equal(thumbnailUrl1)
			expect(modifiedState.thumbnails[thumbnailSize2]).to.equal(thumbnailUrl2)
		end)
	end)
end