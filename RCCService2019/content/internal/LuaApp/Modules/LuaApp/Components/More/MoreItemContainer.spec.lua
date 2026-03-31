return function()
	local MoreItemContainer = require(script.Parent.MoreItemContainer)

	local CorePackages = game:GetService("CorePackages")
	local Roact = require(CorePackages.Roact)
	local Rodux = require(CorePackages.Rodux)

	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local AppReducer = require(Modules.LuaApp.AppReducer)
	local MorePageSettings = require(Modules.LuaApp.MorePageSettings)
	local User = require(Modules.LuaApp.Models.User)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)
	local SetLocalUserId = require(Modules.LuaApp.Actions.SetLocalUserId)

	local function MockStore()
		local store = Rodux.Store.new(AppReducer, nil, { Rodux.thunkMiddleware })
		local localUser = User.mock()
		store:dispatch(SetLocalUserId(localUser.id))
		return store
	end

	local testItem = function(item, layoutInfo)
		local store = MockStore()

		local root = mockServices({
			element = Roact.createElement(MoreItemContainer, {
				item = item,
				layoutInfo = layoutInfo,
			}),
		}, {
			includeLocalizationProvider = true,
			includeThemeProvider = true,
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(root)
		Roact.unmount(instance)
		store:destruct()
	end

	it("should create and destroy without errors for all more page items", function()
		local allItems = MorePageSettings.ItemInfo
		for _, item in pairs(allItems) do
			testItem(item)
		end
	end)

	it("should throw if item is not a table", function()
		expect(function()
			testItem(nil)
		end).to.throw()
		expect(function()
			testItem("")
		end).to.throw()
		expect(function()
			testItem(0)
		end).to.throw()
		expect(function()
			testItem(function() end)
		end).to.throw()
	end)

	it("should throw if layoutInfo is not a table", function()
		expect(function()
			testItem(nil)
		end).to.throw()
		expect(function()
			testItem("")
		end).to.throw()
		expect(function()
			testItem(0)
		end).to.throw()
		expect(function()
			testItem(function() end)
		end).to.throw()
	end)
end