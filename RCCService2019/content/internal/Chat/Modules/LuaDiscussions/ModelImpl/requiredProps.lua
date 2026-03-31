local LuaPackages = game:GetService("CorePackages")
local Cryo = require(LuaPackages.Cryo)

local function createFromProps(modelImpl, requiredProps)
	assert(requiredProps, string.format("Missing requiredProps argument when creating model: %s",
		tostring(modelImpl.symbol)
	))

	modelImpl.fromProps = function(props)
		for propName, propType in pairs(requiredProps) do
			if type(props[propName]) ~= propType then
				error(string.format(
					"%s expects `%s` prop to be a %s! Got (%s) `%s` instead.",
					tostring(modelImpl.symbol),
					tostring(propName),
					tostring(propType),
					type(props[propName]),
					tostring(props[propName])
				))
			end
		end

		return Cryo.Dictionary.join(props, modelImpl.new())
	end

	return modelImpl
end

return createFromProps