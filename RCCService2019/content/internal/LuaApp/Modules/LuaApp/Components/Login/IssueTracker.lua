local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local Roact = require(CorePackages.Roact)
local withLocalization = require(Modules.LuaApp.withLocalization)

local TEXT_COLOR = Color3.new(1,1,1)
local ImageSetLabel = require(Modules.LuaApp.Components.ImageSetLabel)
local ISSUE_RESOLVED_IMAGE = "LuaApp/icons/status_progress"
local ISSUE_UNRESOLVED_IMAGE = "LuaApp/icons/GameDetails/navigation/close"

local IssueCondition = require(Modules.LuaApp.Enum.IssueCondition)

local IssueTracker = Roact.PureComponent:extend("IssueTracker")

IssueTracker.defaultProps = {
	MinFontSize = 12,
	MaxFontSize = 24,
	TextScaleFactor = 0.05,
}

function IssueTracker:render()
	local issues = self.props.IssueMessage
	local condition = self.props.IssueCondition

	local sizeX = self.props.SizeX
	local sizeY = self.props.SizeY

	local minFontSize = self.props.MinFontSize
	local maxFontSize = self.props.MaxFontSize
	local textScaleFactor = self.props.TextScaleFactor

	local fontSize = math.min(maxFontSize,math.max(minFontSize,sizeX*textScaleFactor))
	local fontSpaceSize = math.floor(fontSize*0.25)
	local visibleIssueCap = math.floor((sizeY+fontSpaceSize)/(fontSize+fontSpaceSize))

	return withLocalization(
		issues
	)(function(localizedStrings)
		local issueList = {}

		local optional = {}
		for iss,message in pairs(issues) do
			local isIssue = condition[iss]==IssueCondition.Problematic
			local isShown = condition[iss]~=IssueCondition.Hidden
			if isShown then
				table.insert(issueList,Roact.createElement("Frame",{
					Size = UDim2.new(1,0,0,fontSize),
					BackgroundTransparency = 1,
					LayoutOrder = string.byte(message,#message) --Keeps issues in listed order
				},{
					List = Roact.createElement("UIListLayout",{
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0,fontSpaceSize*1.5),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					CheckHolder = Roact.createElement("Frame",{
						Size = UDim2.new(0,fontSize,0,fontSize),
						LayoutOrder = 1,
						BackgroundTransparency = 1,
					},{
						CheckMark = Roact.createElement(ImageSetLabel,{
							BackgroundTransparency = 1,
							Image = isIssue and ISSUE_UNRESOLVED_IMAGE or ISSUE_RESOLVED_IMAGE,
							Size = UDim2.new(0,fontSize+fontSpaceSize,0,fontSize+fontSpaceSize),
							Position = UDim2.new(0.5,0,0.5,0),
							AnchorPoint = Vector2.new(0.5,0.5),
						}),
					}),
					IssueLabel = Roact.createElement("TextLabel",{
						Size = UDim2.new(1,0,0,fontSize),
						Text = localizedStrings[iss],
						Font = Enum.Font.Gotham,
						TextScaled = true,
						TextColor3 = TEXT_COLOR,
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						LayoutOrder = 2,
					}),
				}))
				if not isIssue then
					table.insert(optional,#issueList)
				end
			end
		end

		--prioritize active issues in the event that showing every active/resolved issue would cover the continue button
		local tryToRemove = #issueList-visibleIssueCap
		if tryToRemove>0 then
			for i=#optional,math.max(1,#optional-tryToRemove+1),-1 do
				table.remove(issueList,optional[i])
			end
			for i=1+visibleIssueCap,#issueList do
				issueList[i] = nil
			end
		end

		table.insert(issueList,
			Roact.createElement("UIListLayout",{
				Padding = UDim.new(0,fontSpaceSize),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
		)

		return Roact.createElement("Frame",{
			Size = UDim2.new(0,sizeX,0,sizeY),
			Position = self.props.Position,
			BackgroundTransparency = 1,
		},issueList)
	end)
end

return IssueTracker