--[[
	This module allows you to replace ids within your normalized state with other data.
]]

local function populateFromIds(state, normalizedData)
	local newDictionary = {}

	for key, value in pairs(state) do
		if type(value) == "table" then
			newDictionary[key] = populateFromIds(value, normalizedData)
		else
			newDictionary[key] = normalizedData[value]
		end
	end

	return newDictionary
end

return populateFromIds