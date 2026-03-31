return function()
	local ApiWrapper = require(script.Parent.ApiWrapper)
	local HttpService = game:GetService("HttpService")

	local specs = {
		definitions = {
			MyItem = {
				name = "string",
				details = "string",
				_required = {
					name = true,
				},
			},
			MyRequest = {
				type = "string",
				item = "MyItem",
				_required = {
					item = true,
				},
			},
			MyResponse = {
				count = "integer",
				data = {"MyItem"},
				_required = {
					count = true,
					data = true,
				},
			},
		},
		endpoints = {
			GetItems = {
				method = "GET",
				url = "http://example.roblox.com/v1/items/{type}?sets={sets|}",
				input = {
					type = "string",
					sets = {"integer"},
					_required = {
						type = true,
					},
					_collectionFormat = {
						sets = "csv"
					},
				},
				output = "MyResponse",
			},
			PutItem = {
				method = "PUT",
				url = "http://example.roblox.com/v1/items?addToSet={addToSet|}",
				input = {
					type = "string",
					item = "MyItem",
					addToSet = {"integer"},
					_required = {
						item = true,
					},
					_collectionFormat = {
						addToSet = "multi"
					},
				},
				body = {
					"type",
					"item",
				},
				output = "nil",
			},
		},
	}

	it('should build a service object out of valid specs', function()
		local ExampleApi
		expect(function()
			ExampleApi = ApiWrapper.new(specs)
		end).to.never.throw()
		expect(type(ExampleApi)).to.equal('table')
		expect(type(ExampleApi.GetItems)).to.equal('function')
		expect(type(ExampleApi.PutItem)).to.equal('function')
	end)

	it('should make the proper API call with a valid input', function()
		local ExampleApi = ApiWrapper.new(specs)
		local requestData = {}
		local requestImpl = function(url, method, options)
			requestData.url = url
			requestData.method = method
			requestData.options = options
			if options.postBody then
				requestData.body = HttpService:JSONDecode(options.postBody)
			end
			return {
				-- noop fake promise to avoid output validation
				andThen = function()end,
			}
		end
		ExampleApi.GetItems(requestImpl, {
			type = "test",
			sets = {1, 2, 3},
		})
		-- get call without body
		expect(function()
			ExampleApi.GetItems(requestImpl, {
				type = "test",
				sets = {1, 2, 3},
			})
		end).to.never.throw()
		expect(requestData.url).to.equal("http://example.roblox.com/v1/items/test?sets=1%2C2%2C3")
		expect(requestData.method).to.equal("GET")
		expect(requestData.body).to.equal(nil)
		-- put call with body
		expect(function()
			ExampleApi.PutItem(requestImpl, {
				item = {
					name = "test"
				},
				addToSet = {1, 2, 3},
			})
		end).to.never.throw()
		expect(requestData.url).to.equal("http://example.roblox.com/v1/items?addToSet=1&addToSet=2&addToSet=3")
		expect(requestData.method).to.equal("PUT")
		expect(requestData.body.item.name).to.equal("test")
	end)

	it('should fail on invalid input', function()
		local ExampleApi = ApiWrapper.new(specs)
		local requestMade = false
		local requestImpl = function()
			-- request should fail before this point
			requestMade = true
		end
		expect(function()
			ExampleApi.PutItem(requestImpl, {
				item = {
					description = "test"
				},
				addToSet = {1, 2, 3},
			})
		end).to.throw()
		expect(requestMade).to.equal(false)
	end)

	it('should fail on invalid output', function()
		local ExampleApi = ApiWrapper.new(specs)
		local requestMade = false
		local requestImpl = function()
			requestMade = true
			return {
				andThen = function(self, cb)
					cb({
						responseBody = {
							-- count missing
							data = {},
						},
					})
				end
			}
		end
		expect(function()
			ExampleApi.GetItems(requestImpl, {
				type = "test",
			})
		end).to.throw()
		expect(requestMade).to.equal(true)
	end)

	it('should return the response on valid output', function()
		local ExampleApi = ApiWrapper.new(specs)
		local output = {
			responseBody = {
				count = 0,
				data = {},
			},
		}
		local response
		local requestImpl = function()
			return {
				andThen = function(self, cb)
					response = cb(output)
				end
			}
		end
		expect(function()
			ExampleApi.GetItems(requestImpl, {
				type = "test",
			})
		end).to.never.throw()
		expect(response).to.equal(output)
	end)
end
