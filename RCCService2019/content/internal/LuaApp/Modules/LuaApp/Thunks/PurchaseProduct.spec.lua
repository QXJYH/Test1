return function()
	local PurchaseProduct = require(script.Parent.PurchaseProduct)
	local Modules = game:GetService("CoreGui").RobloxGui.Modules
	local MockStore = require(Modules.LuaApp.TestHelpers.MockStore)
	local MockRequest = require(Modules.LuaApp.TestHelpers.MockRequest)
	local withFlag = require(Modules.LuaApp.TestHelpers.withFlag)
	local PurchaseErrors = require(Modules.LuaApp.Enum.PurchaseErrors)
	local PurchaseErrorLocalizationKeys = require(Modules.LuaApp.PurchaseErrorLocalizationKeys)
	local GetFFlagLuaAppNewEconomyApi = require(Modules.LuaApp.Flags.GetFFlagLuaAppNewEconomyApi)

	local Result = {
		NotCompleted = "NotCompleted",
		Resolved = "Resolved",
		rejected = "Rejected",
	}

	local MockPurchaseError = {
		None = "None",
		Error = "Error",
	}

	local DivId = {
		PriceChangedView = "PriceChangedView",
		TransactionFailureView = "TransactionFailureView",
		InsufficientFundsView = "InsufficientFundsView",
	}

	local Title = {
		MembershipLevelTooLow = "Membership Level Too Low",
		PurchasesAreCurrentlyDisabled = "Purchases are Currently Disabled",
		ItemNotForSale = "Item Not For Sale",
		AgeRestrictedItem = "Age Restricted Item",
		ItemOwned = "Item Owned",
		TooManyPurchases = "Too Many Purchases",
		InvalidParameter = "Invalid Parameter",
		Unauthorized = "Unauthorized",
	}

	local mockProductInfo = {
		productId = 123,
		expectedCurrency = 1,
		expectedPrice = 10,
		expectedSellerId = 321,
	}

	local mockProductId = 123

	local mockPurchaseDetail = {
		expectedCurrency = 1,
		expectedPrice = 10,
		expectedSellerId = 321
	}

	local StatusCode = {
		Nil = nil,
		Successful = 200,
		Unsuccessful = 400, -- Random status code was chosen since any code that is not 200 is regarded as failure.
	}

	local getMockSuccessResponseBody = function(statusCode)
		return {
			productId = 123,
			title = "someTitle",
			showDivID = DivId.PriceChangedView,
			shortfallPrice = 0,
			statusCode = statusCode or StatusCode.Successful,
		}
	end

	local getMockUnsuccessResponseBodyWithErrorType = function(props)
		props = props or {}

		return {
			productId = 123,
			title = props.title or "someTitle",
			showDivID = props.showDivId or DivId.TransactionFailureView,
			shortfallPrice = props.shortfallPrice or 0,
			statusCode = StatusCode.Unsuccessful,
		}
	end

	local store = MockStore.new()

	it("should resolve when purchase was successful with statusCode 200", function()
		withFlag("LuaAppNewEconomyApi", function()
			local networking = MockRequest.simpleSuccessRequest(getMockSuccessResponseBody(StatusCode.Successful))
			local result = Result.NotCompleted

			store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
				:andThen(function() result = Result.Resolved end)
				:catch(function() result = Result.Rejected end)

			expect(result).to.equal(Result.Resolved)
		end)
	end)

	it("should resolve when purchase was successful with statusCode nil", function()
		withFlag("LuaAppNewEconomyApi", function()
			local networking = MockRequest.simpleSuccessRequest(getMockSuccessResponseBody(StatusCode.Nil))
			local result = Result.NotCompleted

			store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
				:andThen(function() result = Result.Resolved end)
				:catch(function() result = Result.Rejected end)

			expect(result).to.equal(Result.Resolved)
		end)
	end)

	it("should reject when the purchase was not successful", function()
		withFlag("LuaAppNewEconomyApi", function()
			local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType())
			local result = Result.NotCompleted

			store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
				:andThen(function() result = Result.Resolved end)
				:catch(function() result = Result.Rejected end)

			expect(result).to.equal(Result.Rejected)
		end)
	end)

	it("should reject when the purchase request was not successful", function()
		withFlag("LuaAppNewEconomyApi", function()
			local networking = MockRequest.simpleFailRequest("error")
			local result = Result.NotCompleted

			store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
				:andThen(function() result = Result.Resolved end)
				:catch(function() result = Result.Rejected end)

			expect(result).to.equal(Result.Rejected)
		end)
	end)

	describe("PurchaseProduct with customPurchaseErrorHandler", function()
		local loggedPurchaseError = MockPurchaseError.None

		local function customPurchaseErrorHandler(purchaseProductData)
			loggedPurchaseError = MockPurchaseError[purchaseProductData.title]
			return loggedPurchaseError and true or false
		end

		it("should handle error with provided error handler", function()
			withFlag("LuaAppNewEconomyApi", function()
				local targetError = MockPurchaseError.Error
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, customPurchaseErrorHandler))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(loggedPurchaseError).to.equal(targetError)

				loggedPurchaseError = MockPurchaseError.None
			end)
		end)

		it("should handle error with default error handler if provided error handler couldn't handle", function()
			withFlag("LuaAppNewEconomyApi", function()
				local targetError = "unrecognizedErrorType"
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, customPurchaseErrorHandler))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(loggedPurchaseError).to.equal(nil)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])

				loggedPurchaseError = MockPurchaseError.None
			end)
		end)
	end)

	describe("PurchaseProduct without customPurchaseErrorHandler", function()
		it("should handle purchase request with low membership level and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.MembershipLevelTooLow }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])
			end)
		end)

		it("should handle purchase request on already owned item and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.ItemOwned }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.AlreadyOwn])
			end)
		end)

		it("should handle purchase request on purchase-disabled item and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.PurchasesAreCurrentlyDisabled }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.PurchaseDisabled])
			end)
		end)

		it("should handle purchase request on item not for sale and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.ItemNotForSale }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotForSale])
			end)
		end)

		it("should handle purchase request on item with age restriction and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.AgeRestrictedItem }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.Under13])
			end)
		end)

		it("should handle 'too many purchases' and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.TooManyPurchases }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.TooManyPurchases])
			end)
		end)

		it("should handle 'invalide parameter' and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.InvalidParameter}))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.InvalidRequest])
			end)
		end)

		it("should handle unautorized purchase request and update toastMessage with appropriate message", function()
			withFlag("LuaAppNewEconomyApi", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.Unauthorized }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.Unauthorized])
			end)
		end)

		describe("handling purchase with insufficient funds", function()
			it("should recognize divId 'TransactionFailureView' with positive shortfallPrice as insufficient funds and update toastMessage with appropriate message", function()
				withFlag("LuaAppNewEconomyApi", function()

					local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({
						shortfallPrice = 1,
					}))

					local result = Result.NotCompleted

					store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
						:andThen(function() result = Result.Resolved end)
						:catch(function() result = Result.Rejected end)

					expect(result).to.equal(Result.Rejected)
					expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotEnoughRobux])
				end)
			end)

			it("should recognize divId 'InsufficientFundsView' with positive shortfallPrice as insufficient funds and update toastMessage with appropriate message", function()
				withFlag("LuaAppNewEconomyApi", function()
					local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({
						showDivId = DivId.InsufficientFundsView,
						shortfallPrice = 1,
					}))

					local result = Result.NotCompleted

					store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
						:andThen(function() result = Result.Resolved end)
						:catch(function() result = Result.Rejected end)


					expect(result).to.equal(Result.Rejected)
					expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotEnoughRobux])
				end)
			end)
		end)

		it("should handle error with default error handler if customPurchaseErrorHandler was not passed in", function()
			withFlag("LuaAppNewEconomyApi", function()
				local targetError = "unrecognizedErrorType"
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))
				local result = Result.NotCompleted

				store:dispatch(PurchaseProduct.Post(networking, mockProductId, mockPurchaseDetail, nil))
					:andThen(function() result = Result.Resolved end)
					:catch(function() result = Result.Rejected end)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])
			end)
		end)
	end)

	-- Only run old tests when the flag is off
	if not GetFFlagLuaAppNewEconomyApi() then
		it("should resolve when purchase was successful with statusCode 200", function()
			local networking = MockRequest.simpleSuccessRequest(getMockSuccessResponseBody(StatusCode.Successful))

			local result = Result.NotCompleted
			store:dispatch(
				PurchaseProduct.Post(
					networking,
					mockProductInfo.productId,
					mockProductInfo.expectedCurrency,
					mockProductInfo.expectedPrice,
					mockProductInfo.expectedSellerId,
					nil
				)
			):andThen(
				function()
					result = Result.Resolved
				end,
				function()
					result = Result.Rejected
				end
			)
			expect(result).to.equal(Result.Resolved)
		end)

		it("should resolve when purchase was successful with statusCode nil", function()
			local networking = MockRequest.simpleSuccessRequest(getMockSuccessResponseBody(StatusCode.Nil))

			local result = Result.NotCompleted
			store:dispatch(
				PurchaseProduct.Post(
					networking,
					mockProductInfo.productId,
					mockProductInfo.expectedCurrency,
					mockProductInfo.expectedPrice,
					mockProductInfo.expectedSellerId,
					nil
				)
			):andThen(
				function()
					result = Result.Resolved
				end,
				function()
					result = Result.Rejected
				end
			)
			expect(result).to.equal(Result.Resolved)
		end)

		it("should reject when the purchase was not successful", function()
			local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType())

			local result = Result.NotCompleted
			store:dispatch(
				PurchaseProduct.Post(
					networking,
					mockProductInfo.productId,
					mockProductInfo.expectedCurrency,
					mockProductInfo.expectedPrice,
					mockProductInfo.expectedSellerId,
					nil
				)
			):andThen(
				function()
					result = Result.Resolved
				end,
				function()
					result = Result.Rejected
				end
			)
			expect(result).to.equal(Result.Rejected)
		end)

		it("should reject when the purchase request was not successful", function()
			local networking = MockRequest.simpleFailRequest("error")

			local result = Result.NotCompleted
			store:dispatch(
				PurchaseProduct.Post(
					networking,
					mockProductInfo.productId,
					mockProductInfo.expectedCurrency,
					mockProductInfo.expectedPrice,
					mockProductInfo.expectedSellerId,
					nil
				)
			):andThen(
				function()
					result = Result.Resolved
				end,
				function()
					result = Result.Rejected
				end
			)
			expect(result).to.equal(Result.Rejected)
		end)

		describe("PurchaseProduct with customPurchaseErrorHandler", function()
			local loggedPurchaseError = MockPurchaseError.None

			local function customPurchaseErrorHandler(purchaseProductData)
				loggedPurchaseError = MockPurchaseError[purchaseProductData.title]
				return loggedPurchaseError and true or false
			end

			it("should handle error with provided error handler", function()
				local targetError = MockPurchaseError.Error
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						customPurchaseErrorHandler
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(loggedPurchaseError).to.equal(targetError)

				loggedPurchaseError = MockPurchaseError.None
			end)

			it("should handle error with default error handler if provided error handler couldn't handle", function()
				local targetError = "unrecognizedErrorType"
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						customPurchaseErrorHandler
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(loggedPurchaseError).to.equal(nil)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])

				loggedPurchaseError = MockPurchaseError.None
			end)
		end)

		describe("PurchaseProduct without customPurchaseErrorHandler", function()
			it("should handle purchase request with low membership level and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.MembershipLevelTooLow }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])
			end)

			it("should handle purchase request on already owned item and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.ItemOwned }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.AlreadyOwn])
			end)

			it("should handle purchase request on purchase-disabled item and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.PurchasesAreCurrentlyDisabled }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.PurchaseDisabled])
			end)

			it("should handle purchase request on item not for sale and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.ItemNotForSale }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotForSale])
			end)

			it("should handle purchase request on item with age restriction and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.AgeRestrictedItem }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.Under13])
			end)

			it("should handle 'too many purchases' and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.TooManyPurchases }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.TooManyPurchases])
			end)

			it("should handle 'invalide parameter' and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.InvalidParameter}))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.InvalidRequest])
			end)

			it("should handle unautorized purchase request and update toastMessage with appropriate message", function()
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = Title.Unauthorized }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.Unauthorized])
			end)

			describe("handling purchase with insufficient funds", function()
				it("should recognize divId 'TransactionFailureView' with positive shortfallPrice as insufficient funds and update toastMessage with appropriate message", function()
					local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({
						shortfallPrice = 1,
					}))

					local result = Result.NotCompleted
					store:dispatch(
						PurchaseProduct.Post(
							networking,
							mockProductInfo.productId,
							mockProductInfo.expectedCurrency,
							mockProductInfo.expectedPrice,
							mockProductInfo.expectedSellerId,
							nil
						)
					):andThen(
						function()
							result = Result.Resolved
						end,
						function()
							result = Result.Rejected
						end
					)

					expect(result).to.equal(Result.Rejected)
					expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotEnoughRobux])
				end)

				it("should recognize divId 'InsufficientFundsView' with positive shortfallPrice as insufficient funds and update toastMessage with appropriate message", function()
					local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({
						showDivId = DivId.InsufficientFundsView,
						shortfallPrice = 1,
					}))

					local result = Result.NotCompleted
					store:dispatch(
						PurchaseProduct.Post(
							networking,
							mockProductInfo.productId,
							mockProductInfo.expectedCurrency,
							mockProductInfo.expectedPrice,
							mockProductInfo.expectedSellerId,
							nil
						)
					):andThen(
						function()
							result = Result.Resolved
						end,
						function()
							result = Result.Rejected
						end
					)

					expect(result).to.equal(Result.Rejected)
					expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.NotEnoughRobux])
				end)
			end)

			it("should handle error with default error handler if customPurchaseErrorHandler was not passed in", function()
				local targetError = "unrecognizedErrorType"
				local networking = MockRequest.simpleSuccessRequest(getMockUnsuccessResponseBodyWithErrorType({ title = targetError }))

				local result = Result.NotCompleted
				store:dispatch(
					PurchaseProduct.Post(
						networking,
						mockProductInfo.productId,
						mockProductInfo.expectedCurrency,
						mockProductInfo.expectedPrice,
						mockProductInfo.expectedSellerId,
						nil
					)
				):andThen(
					function()
						result = Result.Resolved
					end,
					function()
						result = Result.Rejected
					end
				)

				expect(result).to.equal(Result.Rejected)
				expect(store:getState().CurrentToastMessage.toastMessage).to.equal(PurchaseErrorLocalizationKeys[PurchaseErrors.UnknownFailure])
			end)
		end)
	end
end
