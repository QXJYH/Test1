return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local CatalogAppReducer = require(Modules.LuaApp.Reducers.Catalog.CatalogAppReducer)

	it("has the expected fields, and only the expected fields", function()
		local state = CatalogAppReducer(nil, {})

		local expectedKeys = {
			Assets = true,
			Bundles = true,
			ChinaCatalogItems = true,
			BundlesStatus = true,
		}

		for key in pairs(expectedKeys) do
			assert(state[key] ~= nil, string.format("Expected field %q", key))
		end

		for key in pairs(state) do
			assert(expectedKeys[key] ~= nil, string.format("Did not expect field %q", key))
		end
	end)
end