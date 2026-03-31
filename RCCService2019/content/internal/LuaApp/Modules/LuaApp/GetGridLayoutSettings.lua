--[[
	Documentation:
	https://confluence.roblox.com/display/DESIGN/Grid+Systems
	https://docs.google.com/spreadsheets/d/1zLNqGop2ha2Y4Twcvh3w_LwuAr2CwkM-AvTlhPrz7WU/edit?usp=sharing
]]
local ArgCheck = require(script.Parent.ArgCheck)


local GRID_SETTINGS_MEDIUM = {
	minimumCardCount = 2,
	minimumCardWidth = 160,
}

local GRID_SETTINGS_LARGE = {
	minimumCardCount = 1,
	minimumCardWidth = 330,
}

local function getGridLayoutSettingsHelper(containerWidth, cardPadding, settingsTable)
	ArgCheck.isNonNegativeNumber(containerWidth, "GetGridLayoutSettings: containerWidth")
	ArgCheck.isNonNegativeNumber(cardPadding, "GetGridLayoutSettings: cardPadding")
	ArgCheck.isType(settingsTable, "table", "GetGridLayoutSettings: settingsTable")

	local cardCount = math.floor((containerWidth + cardPadding) / (settingsTable.minimumCardWidth + cardPadding))
	cardCount = math.max(settingsTable.minimumCardCount, cardCount)
	local cardWidth = (containerWidth - (cardCount - 1) * cardPadding) / cardCount

	-- Always return integer width to avoid floating number precision issues.
	cardWidth = math.floor(cardWidth)

	return cardCount, cardWidth
end

local GetGridLayoutSettings = {}

-- Small grid always holds 1 more card than the medium grid.
function GetGridLayoutSettings.Small(containerWidth, cardPadding)
	local cardCount, _ = getGridLayoutSettingsHelper(containerWidth, cardPadding, GRID_SETTINGS_MEDIUM)

	cardCount = cardCount + 1
	local cardWidth = (containerWidth - (cardCount - 1) * cardPadding) / cardCount

	-- Always return integer width to avoid floating number precision issues.
	cardWidth = math.floor(cardWidth)

	return cardCount, cardWidth
end

function GetGridLayoutSettings.Medium(containerWidth, cardPadding)
	return getGridLayoutSettingsHelper(containerWidth, cardPadding, GRID_SETTINGS_MEDIUM)
end

function GetGridLayoutSettings.Large(containerWidth, cardPadding)
	return getGridLayoutSettingsHelper(containerWidth, cardPadding, GRID_SETTINGS_LARGE)
end

return GetGridLayoutSettings