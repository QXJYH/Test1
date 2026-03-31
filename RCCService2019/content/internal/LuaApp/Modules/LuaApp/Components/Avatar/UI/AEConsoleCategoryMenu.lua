local Modules = game:GetService("CoreGui").RobloxGui.Modules
local GuiService = game:GetService("GuiService")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Roact)
local AEConsoleCategoryButton = require(Modules.LuaApp.Components.Avatar.UI.AEConsoleCategoryButton)
local AECategories = require(Modules.LuaApp.Components.Avatar.AECategories)

local AEConsoleCategoryMenu = Roact.PureComponent:extend("AEConsoleCategoryMenu")

function AEConsoleCategoryMenu:init()
	self.categoryMenuRef = Roact.createRef()
end

function AEConsoleCategoryMenu:didMount()
	GuiService:AddSelectionParent("CategoryMenu", self.categoryMenuRef.current)
end

function AEConsoleCategoryMenu:willUnmount()
	GuiService:RemoveSelectionGroup("CategoryMenu")
end

function AEConsoleCategoryMenu:render()
	local categoryButtons = {}
	local avatarEditorActive = self.props.avatarEditorActive

	for index, category in pairs(AECategories.categories) do
		categoryButtons["Category" ..index] = Roact.createElement(AEConsoleCategoryButton, {
			index = index,
			category = category,
			avatarEditorActive = avatarEditorActive,
		})
	end

	categoryButtons["UIListLayout"] = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 20),
	})

	return Roact.createElement("Frame", {
		Position = UDim2.new(0, 100, 0, 270),
		Size = UDim2.new(0, 360, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 2,

		[Roact.Ref] = self.categoryMenuRef,
	},
		categoryButtons)
end

return AEConsoleCategoryMenu