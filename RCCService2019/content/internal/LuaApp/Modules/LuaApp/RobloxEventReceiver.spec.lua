local HttpService = game:GetService("HttpService")
local Modules = game:GetService("CoreGui").RobloxGui.Modules
local mockNotificationService = require(Modules.LuaApp.TestHelpers.MockNotificationService)

return function()
	local RobloxEventReceiver = require(game:GetService("CoreGui").RobloxGui.Modules.LuaApp.RobloxEventReceiver)
	it("should be able to be created", function()
		RobloxEventReceiver.new(mockNotificationService.new())
	end)

	describe("should have the correct api", function()
		it("should require a notificationService", function()
			expect(function()
				RobloxEventReceiver.new(nil)
			end).to.throw()
			expect(function()
				RobloxEventReceiver.new({})
			end).to.throw()
			RobloxEventReceiver.new(mockNotificationService.new())
		end)

		it("should throw on bad arguments for observeEvent", function()
			local eventReceiver = RobloxEventReceiver.new(mockNotificationService.new())
			expect(function()
				eventReceiver:observeEvent()
			end).to.throw()
			expect(function()
				eventReceiver:observeEvent({}, function()end)
			end).to.throw()
			expect(function()
				eventReceiver:observeEvent("namespace", {})
			end).to.throw()
			-- normal call
			local connection = eventReceiver:observeEvent("namespace", function()end)
			connection:disconnect()
		end)
	end)

	describe("handle observer", function()
		it("takes a observer", function()
			local eventReceiver = RobloxEventReceiver.new(mockNotificationService.new())
			local connection = eventReceiver:observeEvent("namespace", function()
				error("Should not call this callback")
			end)
			connection:disconnect()
		end)

		it("notifies and disconnects observer", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local count = 0
			local test_message = "TEST"
			local test_detail = HttpService:JSONEncode({message = test_message})
			local namespace = "namespaceSingular"

			local connection = eventReceiver:observeEvent(namespace, function(event)
				count = count + 1
				expect(event.message).to.equal("TEST")
			end)
			mns.RobloxEventReceived:Fire({
				namespace = namespace,
				detail = test_detail,
			})

			expect(count).to.equal(1)
			connection:disconnect()

			mns.RobloxEventReceived:Fire({
				namespace = namespace,
				detail = test_detail,
			})
			expect(count).to.equal(1)
		end)
	end)

	describe("handle multiple observers", function()
		it("notifies and disconnects observers", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local count = 0
			local test_message = "TEST"
			local test_detail = HttpService:JSONEncode({message = test_message})
			local namespace = "namespaceSingular"

			local connection = eventReceiver:observeEvent(namespace, function(detail)
				count = count + 1
				expect(detail.message).to.equal(test_message)
			end)
			local connection2 = eventReceiver:observeEvent(namespace, function(detail)
				count = count + 1
				expect(detail.message).to.equal(test_message)
			end)

			mns.RobloxEventReceived:Fire({
				namespace = namespace,
				detail = test_detail,
			})

			expect(count).to.equal(2)
			connection:disconnect()
			connection2:disconnect()

			mns.RobloxEventReceived:Fire({
				namespace = namespace,
				detail = test_detail,
			})
			expect(count).to.equal(2)
		end)
	end)

	describe("should not call when", function()
		it("deals with different namespace", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local test_message = "TEST"
			local test_detail = HttpService:JSONEncode({message = test_message})
			local namespace = "namespace"

			local connection = eventReceiver:observeEvent("differentNameSpace", function(message)
				error("Should not call this callback")
			end)
			mns.RobloxEventReceived:Fire({
				namespace = namespace,
				detail = test_detail,
			})

			connection:disconnect()
		end)

		it("deals with different types", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local test_message = "TEST"
			local test_detail = HttpService:JSONEncode({message = test_message})
			local namespace = "namespace"

			local connection = eventReceiver:observeEvent(namespace, function(message)
				error("Should not call this callback")
			end)
			mns.RobloxEventReceived:Fire({
				namespace = "otherNameSpace",
				detail = test_detail,
			})

			connection:disconnect()
		end)

		it("expects a singlular event", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local test_message = "TEST"
			local test_detail = HttpService:JSONEncode({message = test_message})
			local namespace = "namespace"

			local connection = eventReceiver:observeEvent(namespace, function(message)
				error("Should not call this callback")
			end)
			mns.RobloxEventReceived:Fire({
				namespace = "otherNameSpace",
				detail = test_detail,
			})

			connection:disconnect()
		end)
	end)

	describe("RobloxConnectionChanged", function()
		it("notifies and disconnects an observer", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local count = 0
			local testConnectionState = Enum.ConnectionState.Connected
			local testSequenceNumber = "1"
			local namespace = "signalR"

			local connection = eventReceiver:observeEvent(namespace, function(connectionState, sequenceNumber)
				count = count + 1
				expect(connectionState).to.equal(Enum.ConnectionState.Connected)
			end)
			mns.RobloxConnectionChanged:Fire(namespace, testConnectionState, testSequenceNumber)
			expect(count).to.equal(1)
			connection:disconnect()

			mns.RobloxConnectionChanged:Fire(namespace, testConnectionState, testSequenceNumber)
			expect(count).to.equal(1)
		end)

		it("notifies and disconnects multiple observers", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local count = 0
			local testConnectionState = Enum.ConnectionState.Connected
			local testSequenceNumber = "1"
			local namespace = "signalR"

			local connection = eventReceiver:observeEvent(namespace, function(connectionState, sequenceNumber)
				count = count + 1
				expect(connectionState).to.equal(Enum.ConnectionState.Connected)
			end)
			local connection2 = eventReceiver:observeEvent(namespace, function(connectionState, sequenceNumber)
				count = count + 1
				expect(connectionState).to.equal(Enum.ConnectionState.Connected)
			end)
			mns.RobloxConnectionChanged:Fire(namespace, testConnectionState, testSequenceNumber)

			expect(count).to.equal(2)
			connection:disconnect()
			connection2:disconnect()

			mns.RobloxConnectionChanged:Fire(namespace, testConnectionState, testSequenceNumber)
			expect(count).to.equal(2)
		end)

		it("deals with a different namespace", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local testConnectionState = Enum.ConnectionState.Connected
			local testSequenceNumber = "1"
			local namespace = "signalR"

			local connection = eventReceiver:observeEvent("differentNameSpace", function(connectionState, sequenceNumber)
				error("Should not call this callback")
			end)
			mns.RobloxConnectionChanged:Fire(namespace, testConnectionState, testSequenceNumber)

			connection:disconnect()
		end)

		it("deals with different types", function()
			local mns = mockNotificationService.new()
			local eventReceiver = RobloxEventReceiver.new(mns)
			local testConnectionState = Enum.ConnectionState.Connected
			local testSequenceNumber = "1"
			local namespace = "signalR"

			local connection = eventReceiver:observeEvent(namespace, function(connectionState, sequenceNumber)
				error("Should not call this callback")
			end)
			mns.RobloxConnectionChanged:Fire("otherNameSpace", testConnectionState, testSequenceNumber)

			connection:disconnect()
		end)
	end)
end