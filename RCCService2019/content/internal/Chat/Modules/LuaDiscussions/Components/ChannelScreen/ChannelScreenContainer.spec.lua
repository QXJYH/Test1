return function()
	local ChannelScreenContainer = require(script.Parent.ChannelScreenContainer)

	local LuaDiscussions = script:FindFirstAncestor("LuaDiscussions")

	local dependencies = require(LuaDiscussions.dependencies)
	local Promise = dependencies.Promise
	local Roact = dependencies.Roact
	local RoactRodux = dependencies.RoactRodux
	local Rodux = dependencies.Rodux

	local DiscussionsAppReducer = require(LuaDiscussions.DiscussionsAppReducer)
	local mountStyledFrame = require(LuaDiscussions.UnitTestHelpers.mountStyledFrame)

	local FullAppReducer = Rodux.combineReducers({
		DiscussionsAppReducer = DiscussionsAppReducer,
		FetchingStatus = Rodux.createReducer({}, {}),
		ScreenSize = Rodux.createReducer(Vector2.new(100, 100), {}),
	})

	local function createStoreWithState(state)
		return Rodux.Store.new(FullAppReducer, state, { Rodux.thunkMiddleware })
	end

	local function createHttpRequest(response)
		return function()
			return Promise.resolve({
				responseBody = {
					data = response,
				},
			})
		end
	end

	describe("lifecycle", function()
		it("SHOULD mount and unmount without issue", function()
			local store = createStoreWithState()

			local tree = Roact.createElement(RoactRodux.StoreProvider, {
				store = store,
			}, {
				container = Roact.createElement(ChannelScreenContainer, {
					networkImpl = createHttpRequest({}),
					channelId = "-1",
				}),
			})

			local _, cleanup = mountStyledFrame(tree)
			cleanup()
		end)
	end)

	describe("props channelMessages", function()
		it("SHOULD derive channelMessages prop from store", function()
			local mockChannelId = "mockChannelId"
			local mockId1 = "mockId1"
			local mockMessage1 = {
				id = mockId1,
				created = "created",
			}
			local store = createStoreWithState({
				DiscussionsAppReducer = {
					channelMessages = {
						byId = {
							[mockId1] = mockMessage1,
						},
						byChannelId = {
							[mockChannelId] = { mockId1 },
						}
					}
				}
			})

			local tree = Roact.createElement(RoactRodux.StoreProvider, {
				store = store,
			}, {
				container = Roact.createElement(ChannelScreenContainer, {
					networkImpl = createHttpRequest({}),
					channelId = mockChannelId,
				}),
			})

			local frame, cleanup = mountStyledFrame(tree)

			local message = frame:FindFirstChild("entry-" .. mockId1, true)
			expect(message).to.be.ok()

			cleanup()
		end)
	end)
end