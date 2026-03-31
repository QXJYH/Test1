return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local LuaApp = Modules.LuaApp
	local BundlesStatus = require(script.Parent.BundlesStatus)
	local SetBundleStatus = require(LuaApp.Actions.Catalog.SetBundleStatus)
	local CatalogConstants = require(Modules.LuaApp.Components.Catalog.CatalogConstants)
	local MockId = require(LuaApp.MockId)

	local function countKeys(t)
		local count = 0
		for _ in pairs(t) do
			count = count + 1
		end
		return count
	end

	it("should be empty by default", function()
		local defaultState = BundlesStatus(nil, {})
		expect(type(defaultState)).to.equal("table")
		expect(countKeys(defaultState)).to.equal(0)
	end)

	it("should be unchanged by other actions", function()
		local oldState = BundlesStatus(nil, {})
		local newState = BundlesStatus(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("SetBundleStatus", function()
		it("should preserve purity", function()
			local oldState = BundlesStatus(nil, {})
			local bundleId = tostring(MockId())

			local newState = BundlesStatus(oldState, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.Owned))
			expect(oldState).to.never.equal(newState)
		end)

		it("should set a bundle as Owned", function()
			local bundleId = MockId()
			local newState = BundlesStatus(nil, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.Owned))

			expect(newState[bundleId]).to.equal(CatalogConstants.PurchaseStatus.Owned)
		end)

		it("should set a bundle as Purchasable", function()
			local bundleId = MockId()
			local newState = BundlesStatus(nil, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.Purchasable))

			expect(newState[bundleId]).to.equal(CatalogConstants.PurchaseStatus.Purchasable)
		end)

		it("should set a bundle as NotPurchasable", function()
			local bundleId = MockId()
			local newState = BundlesStatus(nil, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.NotPurchasable))

			expect(newState[bundleId]).to.equal(CatalogConstants.PurchaseStatus.NotPurchasable)
		end)

		it("should overwrite the status of a bundle", function()
			local bundleId = MockId()
			local newState = BundlesStatus(nil, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.Purchasable))
			expect(newState[bundleId]).to.equal(CatalogConstants.PurchaseStatus.Purchasable)

			newState = BundlesStatus(newState, SetBundleStatus(bundleId, CatalogConstants.PurchaseStatus.Owned))
			expect(newState[bundleId]).to.equal(CatalogConstants.PurchaseStatus.Owned)
		end)
	end)
end