local CorePackages = game:GetService("CorePackages")
local Symbol = require(CorePackages.Symbol)

local extend = function(symbolName)
	local modelDeclaration = {
		symbol = Symbol.named(symbolName)
	}

	function modelDeclaration.is(model)
		return type(model) == "table"
			and model.symbol == modelDeclaration.symbol
	end

	function modelDeclaration.new()
		return {
			symbol = modelDeclaration.symbol,
		}
	end

	return modelDeclaration
end

return extend