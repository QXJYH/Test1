local Modules = game:GetService("CoreGui").RobloxGui.Modules

local ArgCheck = require(Modules.LuaApp.ArgCheck)
local OverlayType = require(Modules.LuaApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.LuaApp.Actions.SetCentralOverlay)

return function(props)
	return function(store)
		ArgCheck.isType(props.user, "table", "props.user passed down to OpenCentralOverlayForPeopleList")
		ArgCheck.isType(props.positionIndex, "number", "props.positionIndex passed down to OpenCentralOverlayForPeopleList")
		ArgCheck.isType(props.onOpen, "function", "props.onOpen passed down to OpenCentralOverlayForPeopleList")
		ArgCheck.isType(props.onClose, "function", "props.onClose passed down to OpenCentralOverlayForPeopleList")
		ArgCheck.isType(props.anchorSpaceSize, "Vector2", "props.anchorSpaceSize passed down to OpenCentralOverlayForPeopleList")
		ArgCheck.isType(props.anchorSpacePosition, "Vector2", "props.anchorSpacePosition passed down to OpenCentralOverlayForPeopleList")

		store:dispatch(SetCentralOverlay(OverlayType.PeopleList, props))
	end
end