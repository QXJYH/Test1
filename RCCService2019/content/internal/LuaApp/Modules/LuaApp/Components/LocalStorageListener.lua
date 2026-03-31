local AppStorageService = game:GetService("AppStorageService")
local LocalizationService = game:GetService("LocalizationService")
local NotificationService = game:GetService("NotificationService")

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)

local Roact = require(Modules.Common.Roact)

local LocalStorageListener = Roact.PureComponent:extend("LocalStorageListener")

function LocalStorageListener:init()

end

function LocalStorageListener:render()

end

function LocalStorageListener:didMount()
	self.connections = {
		AppStorageService.ItemWasSet:Connect(
			function(key, value)
				if key == LocalStorageKey.RobloxLocaleId then
					LocalizationService:SetRobloxLocaleId(value)
				elseif key == LocalStorageKey.Theme then
					NotificationService.SelectedTheme = value
				end
			end
		)
	}
end

function LocalStorageListener:willUnmount()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
end

return LocalStorageListener
