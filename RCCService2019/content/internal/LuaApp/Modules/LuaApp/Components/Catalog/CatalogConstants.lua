local CatalogConstants

CatalogConstants = {
	ThumbnailSize = {
		["150"] = "150",
		["420"] = "420",
	},

	ItemType = {
		Bundle = "Bundle",
		Asset = "Asset",
	},

	BundlesInfoKey = "luaapp.itemapi.bundlesinfo.",
	BuyButtonInfoKey = "catalog.getispurchasable.",
	PurchaseProductKey = "catalog.purchaseproduct.",

	ExpectedCurrencyRobux = 1,

	PurchaseStatus = {
		Owned = 1,
		Purchasable = 2,
		NotPurchasable = 3,
	},
}

return CatalogConstants
