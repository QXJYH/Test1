local CoreGui = game:GetService("CoreGui")

local Modules = CoreGui.RobloxGui.Modules

local Roact = require(Modules.Common.Roact)
local Constants = require(Modules.LuaApp.Constants)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)

local FriendIcon = require(Modules.LuaApp.Components.FriendIcon)

local ICON_PADDING = 3

local ICON_SIZE_LARGE = 32
local ICON_SIZE_SMALL = 24
local PREFERRED_NUMBER_OF_ICONS_MIN = 3

local NUMBERED_CIRCLE = "LuaApp/graphic/gr-counter-slot-32x32"
local NUMBERED_ICON_FONT = Enum.Font.SourceSans
local NUMBERED_ICON_FONT_COLOR = Constants.Color.GRAY2
local NUMBERED_ICON_FONT_SIZE = 15

local function NumberedIcon(props)
	local size = props.size
	local layoutOrder = props.layoutOrder
	local count = props.count

	return Roact.createElement(ImageSetLabel, {
		Size = UDim2.new(0, size, 0, size),
		LayoutOrder = layoutOrder,
		Image = NUMBERED_CIRCLE,
		BackgroundTransparency = 1,
	}, {
		Count = Roact.createElement("TextLabel", {
			Size = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Font = NUMBERED_ICON_FONT,
			TextSize = NUMBERED_ICON_FONT_SIZE,
			Text = "+" .. count,
			TextColor3 = NUMBERED_ICON_FONT_COLOR,
			BackgroundTransparency = 1,
		}),
	})
end

local UserIconList = Roact.PureComponent:extend("UserIconList")

UserIconList.defaultProps = {
	users = {},
}

function UserIconList:render()
	local width = self.props.width
	local height = self.props.height
	local layoutOrder = self.props.layoutOrder
	local users = self.props.users
	local numberOfUsers = #users
	local numberedIconValue = 0
	local maskColor = self.props.maskColor

	if numberOfUsers <= 0 then
		return nil
	end

	local function GetMaxNumberOfIconsInWidth(iconSize, availableWidth)
		return math.floor((availableWidth + ICON_PADDING) / (iconSize + ICON_PADDING))
	end

	local userIconSize

	if height >= ICON_SIZE_LARGE
		and GetMaxNumberOfIconsInWidth(ICON_SIZE_LARGE, width) >= PREFERRED_NUMBER_OF_ICONS_MIN then
		userIconSize = ICON_SIZE_LARGE
	elseif height >= ICON_SIZE_SMALL then
		userIconSize = ICON_SIZE_SMALL
	else
		userIconSize = height
	end

	local listOfIcons = {}
	local maxNumberOfIcons = GetMaxNumberOfIconsInWidth(userIconSize, width)

	if maxNumberOfIcons > 0 then
		if numberOfUsers > maxNumberOfIcons then
			numberedIconValue = numberOfUsers - (maxNumberOfIcons - 1)
		end

		listOfIcons.ListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, ICON_PADDING),
		})

		local maxFriendIndex = numberedIconValue > 0 and maxNumberOfIcons - 1
								or math.min(maxNumberOfIcons, numberOfUsers)
		for index = 1, maxFriendIndex do
			local user = users[index]
			listOfIcons["UserIcon"..index] = Roact.createElement(FriendIcon, {
				user = user,
				itemSize = userIconSize,
				layoutOrder = index,
				maskColor = maskColor,
			})
		end

		listOfIcons.NumberedIcon = numberedIconValue > 0 and Roact.createElement(NumberedIcon, {
			size = userIconSize,
			layoutOrder = maxNumberOfIcons,
			count = numberedIconValue,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, width, 0, height),
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
	}, listOfIcons)
end

return UserIconList