local CorePackages = game:GetService("CorePackages")
local Color = require(CorePackages.AppTempCommon.Common.Color)

local Colors = {
	Obsidian = Color.Color3FromHex(0x18191B),
	Carbon = Color.Color3FromHex(0x1F2123),
	Slate = Color.Color3FromHex(0x232527),
	Flint = Color.Color3FromHex(0x393B3D),
	Graphite = Color.Color3FromHex(0x656668),
	Pumice = Color.Color3FromHex(0xBDBEBE),

	Black = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),

	Gray1 = Color.Color3FromHex(0x191919),
	Gray2 = Color.Color3FromHex(0x757575),
	Gray3 = Color.Color3FromHex(0xB8B8B8),
	Gray4 = Color.Color3FromHex(0xE3E3E3),
	Gray5 = Color.Color3FromHex(0xF2F2F2),
	Gray6 = Color.Color3FromHex(0xF5F5F5),

	Alabaster = Color.Color3FromHex(0xEFF2F5),
	Smoke = Color.Color3FromHex(0x7B7C7D),
	Ash = Color.Color3FromHex(0xE3E5E8),

	BluePrimary = Color.Color3FromHex(0x00A2FF),
	BlueHover = Color.Color3FromHex(0x32B5FF),
	BluePressed = Color.Color3FromHex(0x0074BD),
	BlueDisabled = Color.Color3FromHex(0x99DAFF),

	Green = Color.Color3FromHex(0x00B06F),
	Red = Color.Color3FromHex(0xF74B52),
	Green2 = Color3.fromRGB(2, 183, 87),
	Orange = Color3.fromRGB(246, 136, 2),
	BrownWarning = Color3.fromRGB(162, 89, 1),
	-- TODO: migrate all the colors in Constants.lua to here

	-- A bit off colors to fix CLI-24097; see changelist 245702 description for more details
	ChatTopBarBluePressed = Color.Color3FromHex(0x0074BE), -- note: This color is Colors.BluePressed + 1 blue
	ChatTopBarWhite = Color.Color3FromHex(0xFFFFFE), -- note: This color is Colors.White - 1 blue
	ChatTopBarSlate =  Color.Color3FromHex(0x232528), -- note: This color is Colors.Slate + 1 blue
}

setmetatable(Colors,
	{
		__newindex = function(t, key, index)
		end,
		__index = function(t, index)
			error("Colors table has no value: " .. tostring(index))
		end
	}
)

return Colors