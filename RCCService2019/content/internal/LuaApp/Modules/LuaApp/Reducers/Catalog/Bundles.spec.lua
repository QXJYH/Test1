return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local LuaApp = Modules.LuaApp
	local Bundles = require(script.Parent.Bundles)
	local BundleInfo = require(Modules.LuaApp.Models.Catalog.BundleInfo)
	local SetBundleInfoAction = require(LuaApp.Actions.Catalog.SetBundleInfoAction)
	local SetBundleThumbnailsAction = require(LuaApp.Actions.Catalog.SetBundleThumbnailsAction)
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
			targetId = MockId(),
			state = "",
			url = url,
			size = size,
		}
	end

	it("should be empty by default", function()
		local defaultState = Bundles(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = Bundles(nil, {})
		local newState = Bundles(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetBundleInfoAction", function()
		it("should preserve purity", function()
			local oldState = Bundles(nil, {})
			local bundleId = tostring(MockId())
			local thumbsData = {}
			thumbsData[bundleId] = {
				["1"] = tostring(MockId())
			}
			local newState = Bundles(oldState, SetBundleInfoAction(thumbsData))
			expect(oldState).to.never.equal(newState)
		end)

		it("should add a single bundle", function()
			local bundleId = MockId()
			local bundleModel = BundleInfo.mock()
			local bundle = {}
			bundle[bundleId] = bundleModel

			local oldState = Bundles(nil, {})
			local newState = Bundles(oldState, SetBundleInfoAction(bundle))

			expect(newState[bundleId]).to.be.ok()
		end)

		it("should update a bundle without effecting existing thumbnails", function()
			local bundleId = tostring(MockId())

			-- Make the Bundle
			local bundleModel = BundleInfo.mock()
			local bundle = {}
			bundle[bundleId] = bundleModel

			-- Make the thumbnail
			local thumbsData = {}
			thumbsData[bundleId] = createMockThumbnail("1", "")
			local action1 = SetBundleThumbnailsAction(thumbsData)
			local action2 = SetBundleInfoAction(bundle)

			local oldState = Bundles({}, action1)
			local newState = Bundles(oldState, action2)

			local modifiedState = newState[bundleId]
			expect(countKeys(modifiedState.thumbnails)).to.equal(1)
		end)
	end)

	describe("SetBundleThumbnailsAction", function()
		it("should preserve purity", function()
			local oldState = Bundles(nil, {})
			local bundleId = tostring(MockId())
			local thumbsData = {}
			thumbsData[bundleId] = {
				["1"] = tostring(MockId())
			}
			local newState = Bundles(oldState, SetBundleThumbnailsAction(thumbsData))
			expect(oldState).to.never.equal(newState)
		end)

		it("should add thumbnails", function()
			local bundleId = tostring(MockId())
			local thumbsData1 = {}
			thumbsData1[bundleId] = createMockThumbnail("1", "")
			local action = SetBundleThumbnailsAction(thumbsData1)

			local oldState = Bundles(nil, {})
			local newState = Bundles(oldState, action)

			local modifiedState = newState[bundleId]
			expect(modifiedState).to.never.equal(nil)
			expect(countKeys(modifiedState.thumbnails)).to.equal(1)
		end)

		it("should add thumbnails of the different sizes without effecting other thumbnail sizes", function()
			local bundleId = tostring(MockId())
			local thumbsData1 = {}
			local thumbsData2 = {}
			local thumbnailSize1 = "1"
			local thumbnailSize2 = "2"
			local thumbnailUrl1 = tostring(MockId())
			local thumbnailUrl2 = tostring(MockId())
			thumbsData1[bundleId] = createMockThumbnail(thumbnailSize1, thumbnailUrl1)
			thumbsData2[bundleId] = createMockThumbnail(thumbnailSize2, thumbnailUrl2)
			local action1 = SetBundleThumbnailsAction(thumbsData1)
			local action2 = SetBundleThumbnailsAction(thumbsData2)

			local oldState = Bundles(nil, action1)
			local newState = Bundles(oldState, action2)

			local modifiedState = newState[bundleId]
			expect(countKeys(modifiedState.thumbnails)).to.equal(2)
			expect(modifiedState.thumbnails[thumbnailSize1]).to.equal(thumbnailUrl1)
			expect(modifiedState.thumbnails[thumbnailSize2]).to.equal(thumbnailUrl2)
		end)

		it("should update a bundle's thumbnail without effecting other existing bundle info", function()
			local bundleId = tostring(MockId())

			-- Make the Bundle
			local bundleModel = BundleInfo.mock()
			local bundle = {}
			bundle[bundleId] = bundleModel

			-- Make the thumbnail
			local thumbsData = {}
			thumbsData[bundleId] = createMockThumbnail("1", "")
			local action1 = SetBundleInfoAction(bundle)
			local action2 = SetBundleThumbnailsAction(thumbsData)

			local oldState = Bundles({}, action1)
			local newState = Bundles(oldState, action2)

			local modifiedState = newState[bundleId]
			expect(modifiedState.receivedMarketPlaceInfo).to.equal(true)
		end)
	end)
end