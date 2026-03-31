return function()
	local getLocalizedToastStringFromHttpError = require(script.Parent.getLocalizedToastStringFromHttpError)

	local errorsToStrings = {
		{ Enum.HttpError.DnsResolve, nil, "Feature.Toast.NetworkingError.UnableToConnect" },
		{ Enum.HttpError.ConnectFail, nil, "Feature.Toast.NetworkingError.UnableToConnect" },
		{ Enum.HttpError.NetFail, nil, "Feature.Toast.NetworkingError.UnableToConnect" },
		{ Enum.HttpError.SslConnectFail, nil, "Feature.Toast.NetworkingError.UnableToConnect" },
		{ Enum.HttpError.TimedOut, nil, "Feature.Toast.NetworkingError.Timeout" },
		{ Enum.HttpError.Aborted, nil, nil },
		{ Enum.HttpError.OK, 400, "Feature.Toast.NetworkingError.SomethingIsWrong" },
		{ Enum.HttpError.OK, 401, "Feature.Toast.NetworkingError.Unauthorized" },
		{ Enum.HttpError.OK, 403, "Feature.Toast.NetworkingError.Forbidden" },
		{ Enum.HttpError.OK, 404, "Feature.Toast.NetworkingError.NotFound" },
		{ Enum.HttpError.OK, 408, "Feature.Toast.NetworkingError.Timeout" },
		{ Enum.HttpError.OK, 429, "Feature.Toast.NetworkingError.TooManyRequests" },
		{ Enum.HttpError.OK, 418, "Feature.Toast.NetworkingError.SomethingIsWrong" },
		{ Enum.HttpError.OK, 500, "Feature.Toast.NetworkingError.SomethingIsWrong" },
		{ Enum.HttpError.OK, 501, "Feature.Toast.NetworkingError.SomethingIsWrong" },
		{ Enum.HttpError.OK, 502, "Feature.Toast.NetworkingError.SomethingIsWrong" },
		{ Enum.HttpError.OK, 503, "Feature.Toast.NetworkingError.ServiceUnavailable" },
		{ Enum.HttpError.OK, 504, "Feature.Toast.NetworkingError.Timeout" },
		{ Enum.HttpError.OK, 505, "Feature.Toast.NetworkingError.SomethingIsWrong" },
	}

	describe("getLocalizedToastStringFromHttpError", function()
		it("should return the correct error strings", function()
			for _, errorToString in ipairs(errorsToStrings) do
				expect(getLocalizedToastStringFromHttpError(errorToString[1],
					errorToString[2])).to.equal(errorToString[3])
			end
		end)

		it("should throw if given invalid arguments", function()
			expect(function()
				getLocalizedToastStringFromHttpError()
			end).to.throw()

			expect(function()
				getLocalizedToastStringFromHttpError("not enum")
			end).to.throw()

			expect(function()
				getLocalizedToastStringFromHttpError(Enum.HttpError.OK, "not number")
			end).to.throw()
		end)
	end)
end