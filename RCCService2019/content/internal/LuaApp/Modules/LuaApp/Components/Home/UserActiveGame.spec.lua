return function()
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local Roact = require(Modules.Common.Roact)
	local Rodux = require(Modules.Common.Rodux)

	local UserActiveGame = require(Modules.LuaApp.Components.Home.UserActiveGame)
	local FormFactor = require(Modules.LuaApp.Enum.FormFactor)

	local AppReducer = require(Modules.LuaApp.AppReducer)
	local mockServices = require(Modules.LuaApp.TestHelpers.mockServices)

	it("should create and destroy without errors on COMPACT view", function()
		local universeId = "684893369"
		local store = Rodux.Store.new(AppReducer, {
			UniversePlaceInfos = { [universeId] = {
				name = "Moon Miners 2 Beta",
				price = 0,
				placeId = "1881607517",
				universeRootPlaceId = "1881607517",
				isPlayable = true,
			}},
		})

		local friend = {
			id = "460160812",
			placeId = "1881607517",
		}

		local element = mockServices({
			userActiveGame = Roact.createElement(UserActiveGame, {
				dismissContextualMenu = nil,
				formFactor = FormFactor.COMPACT,
				friend = friend,
				layoutOrder = 1,
				position = 10,
				universeId = universeId,
				width = 275,
			})
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors on WIDE view", function()
		local universeId = "684893369"
		local store = Rodux.Store.new(AppReducer, {
			UniversePlaceInfos = { [universeId] = {
				name = "Moon Miners 2 Beta",
				price = 200,
				placeId = "1881607517",
				universeRootPlaceId = "1881607517",
				isPlayable = false,
				reasonProhibited = "PurchaseRequired",
			}},
		})

		local friend = {
			id = "460160812",
			placeId = "1881607517",
		}

		local element = mockServices({
			userActiveGame = Roact.createElement(UserActiveGame, {
				dismissContextualMenu = nil,
				formFactor = FormFactor.WIDE,
				friend = friend,
				layoutOrder = 1,
				position = 10,
				universeId = universeId,
				width = 320,
			})
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
		store:destruct()
	end)

	it("should create and destroy without errors when empty store is provided", function()
		-- universe id is from User Model
		-- When universeId is ready, UniversePlaceInfos and GameThumbnails may not contains the data for the specific universeId
		local universeId = "684893369"
		local store = Rodux.Store.new(AppReducer)

		local placeName = "Granny"
		local friend = {
			id = "460160812",
			placeId = "1881607517",
			lastLocation = "Playing " .. placeName,
		}

		local element = mockServices({
			userActiveGame = Roact.createElement(UserActiveGame, {
				dismissContextualMenu = nil,
				formFactor = FormFactor.COMPACT,
				friend = friend,
				layoutOrder = 1,
				position = 10,
				universeId = universeId,
				width = 275,
			})
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "UserActiveGame")
		local children = container.Test:GetChildren()
		expect(children).to.be.ok()

		-- Even though UniversePlaceInfos is not ready, we're able to set game name based on friend's info
		local gameNameLabelText = instance.GameContent.GameInfo.NameButton.Text
		assert(gameNameLabelText == placeName, "Game name was not set properly")

		Roact.unmount(instance)
	end)

	it("should create and destroy without errors when empty store is provided", function()
		-- Even though universeId is there, UniversePlaceInfos and GameThumbnails may not contains the data for the specific universeId
		local universeId = "684893369"
		local store = Rodux.Store.new(AppReducer)

		local placeName = "Granny"
		local friend = {
			id = "460160812",
			placeId = "1881607517",
			lastLocation = placeName,
		}

		local element = mockServices({
			userActiveGame = Roact.createElement(UserActiveGame, {
				dismissContextualMenu = nil,
				formFactor = FormFactor.COMPACT,
				friend = friend,
				layoutOrder = 1,
				position = 10,
				universeId = universeId,
				width = 275,
			})
		}, {
			includeStoreProvider = true,
			store = store,
		})

		local container = Instance.new("Folder")
		local instance = Roact.mount(element, container, "UserActiveGame")
		local children = container.UserActiveGame:GetChildren()
		expect(children).to.be.ok()

		-- Even though UniversePlaceInfos is not ready, we're able to set game name based on friend's info
		local gameNameLabelText = container.UserActiveGame.GameContent.GameInfo.NameButton.Text
		assert(gameNameLabelText == placeName, "Game name was not set properly")

		Roact.unmount(instance)
	end)
end
