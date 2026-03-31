return function()
	local FFlagLuaAppPurchaseErrorToastRefactor = settings():GetFFlag("LuaAppPurchaseErrorToastRefactor2")

	local PurchaseErrors = require(script.parent.Enum.PurchaseErrors)
	local getPurchaseErrorTypeFromErrorResponse = require(script.Parent.getPurchaseErrorTypeFromErrorResponse)

	local showDivIdKey
	if FFlagLuaAppPurchaseErrorToastRefactor then
		showDivIdKey = "showDivId"
	else
		showDivIdKey = "showDivID"
	end

	local function mockNotEnoughRobuxResponse()
		return {
			balanceAfterSale = -4;
			currentPrice = 5;
			shortfallPrice = 4;
			AssetID = 167980381;
			expectedPrice = 5;
			title = "Error";
			statusCode = 500;
			[showDivIdKey] = "TransactionFailureView";
			currentCurrency = 1;
		}
	end

	local function mockInsufficientFundsResponse()
		return {
			shortfallPrice = 4;
			statusCode = 500;
			[showDivIdKey] = "InsufficientFundsView";
		}
	end

	local function mockNormalErrorResponse(modalTitle, showDiv)
		return {
			statusCode = 500,
			title = modalTitle,
			[showDivIdKey] = showDiv,
		}
	end

	local testTitleShowDivToError = {
		[1] = { nil, "PriceChangedView", PurchaseErrors.UnknownFailure, },
		[2] = { "Membership Level Too Low", "TransactionFailureView", PurchaseErrors.UnknownFailure, },
		[3] = { "Purchases are Currently Disabled", "TransactionFailureView", PurchaseErrors.PurchaseDisabled, },
		[4] = { "Item Not For Sale", "TransactionFailureView", PurchaseErrors.NotForSale, },
		[5] = { "Age Restricted Item", "TransactionFailureView", PurchaseErrors.Under13, },
		[6] = { "Item Owned", "TransactionFailureView", PurchaseErrors.AlreadyOwn, },
		[7] = { "Too Many Purchases", "TransactionFailureView", PurchaseErrors.TooManyPurchases, },
		[8] = { "Invalid Parameter", "TransactionFailureView", PurchaseErrors.InvalidRequest, },
		[9] = { "Unauthorized", "TransactionFailureView", PurchaseErrors.Unauthorized, },
	}

	it("should return the correct error type", function()
		expect(getPurchaseErrorTypeFromErrorResponse(mockNotEnoughRobuxResponse())).to.
			equal(PurchaseErrors.NotEnoughRobux)
		expect(getPurchaseErrorTypeFromErrorResponse(mockInsufficientFundsResponse())).to.
			equal(PurchaseErrors.NotEnoughRobux)

		for _, testData in ipairs(testTitleShowDivToError) do
			expect(getPurchaseErrorTypeFromErrorResponse(
				mockNormalErrorResponse(testData[1], testData[2]))).to.equal(testData[3])
		end
	end)
end