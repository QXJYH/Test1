local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local FormFactor = require(Modules.LuaApp.Enum.FormFactor)
local ScrollingPickerDirection = require(Modules.LuaApp.Enum.ScrollingPickerDirection)
local Colors = require(CorePackages.AppTempCommon.LuaApp.Style.Colors)

local ScrollingPicker = require(Modules.LuaApp.Components.Login.ScrollingPicker)

local CONTAINER_TO_ENTRY_SCALE_COMPACT = 0.5
local CONTAINER_TO_ENTRY_SCALE_WIDE = 0.4

local UNFOCUSED_CHARACTER_SIZE_SCALE = 0.8

local CharacterSelector = Roact.PureComponent:extend("CharacterSelector")

CharacterSelector.defaultProps = {
	bundleIds = {},
}

function CharacterSelector:init()
	self.state = {
		currentBundleId = -1,
		entryWidth = 100,
	}

	self.isMounted = false

	self.onContainerAbsoluteSizeChange = function(rbx)
		local formFactor = self.props.formFactor
		local containerAbsoluteWidth = rbx.AbsoluteSize.X

		local newEntryWidth
		if formFactor == FormFactor.COMPACT then
			newEntryWidth = containerAbsoluteWidth * CONTAINER_TO_ENTRY_SCALE_COMPACT
		else
			newEntryWidth = containerAbsoluteWidth * CONTAINER_TO_ENTRY_SCALE_WIDE
		end

		spawn(function()
			if self.isMounted then
				self:setState({
					entryWidth = newEntryWidth,
				})
			end
		end)
	end

	self.onSelectedIndexChanged = function(index)
		local bundleIds = self.props.bundleIds
		local onSelectedCharacterChanged = self.props.onSelectedCharacterChanged
		local currentBundleId = self.state.currentBundleId
		local newBundleId = bundleIds[index]

		if currentBundleId ~= newBundleId then
			spawn(function()
				if self.isMounted then
					if onSelectedCharacterChanged then
						onSelectedCharacterChanged(newBundleId)
					end

					self:setState({
						currentBundleId = newBundleId,
					})
				end
			end)
		end
	end

	self.renderCharacter = function(bundleId)
		-- LUASTARTUP-48 will actually hook up the data to be used by renderCharacter.
		-- local assetIdsInBundle = self.props.assetIdsInBundle[bundleId]

		local avatarSize
		if bundleId == self.state.currentBundleId then
			avatarSize = UDim2.new(1, 0, 1, 0)
		else
			avatarSize = UDim2.new(UNFOCUSED_CHARACTER_SIZE_SCALE, 0, UNFOCUSED_CHARACTER_SIZE_SCALE, 0)
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Colors.Green,
			BackgroundTransparency = 0.3,
		}, {
			-- LUASTARTUP-32 will create viewportFrame component and replace the Frame.
			AvatarPlaceholder = Roact.createElement("Frame", {
				Size = avatarSize,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
			}, {
				AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.FitWithinMaxSize,
				}),
			}),
		})
	end
end

function CharacterSelector:didMount()
	self.isMounted = true
end

function CharacterSelector:willUnmount()
	self.isMounted = false
end

function CharacterSelector:render()
	local bundleIds = self.props.bundleIds
	local entryWidth = self.state.entryWidth

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		[Roact.Change.AbsoluteSize] = self.onContainerAbsoluteSizeChange,
	}, {
		Wheel = Roact.createElement(ScrollingPicker, {
			size = UDim2.new(1, 0, 1, 0),
			renderEntry = self.renderCharacter,
			entries = bundleIds,
			entrySizeOnScrollingAxis = entryWidth,
			onSelectedIndexChanged = self.onSelectedIndexChanged,
			scrollDirection = ScrollingPickerDirection.Horizontal,
		}),
	})
end

CharacterSelector = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			formFactor = state.FormFactor,
		}
	end
)(CharacterSelector)

return CharacterSelector