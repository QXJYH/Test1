local HttpService = game:GetService("HttpService")

local ClbCatalogAssetIds = settings():GetFVariable("ClbCatalogAssetIds")
local ClbCatalogBundleIds = settings():GetFVariable("ClbCatalogBundleIds")
local ClbAvatarBundleIds = settings():GetFVariable("ClbAvatarBundleIds")

return function(state, action)
	state = state or {
		AssetIds = HttpService:JSONDecode(ClbCatalogAssetIds),
		BundleIds = HttpService:JSONDecode(ClbCatalogBundleIds),
		AvatarBundleIds = HttpService:JSONDecode(ClbAvatarBundleIds),
	}

	return state
end
