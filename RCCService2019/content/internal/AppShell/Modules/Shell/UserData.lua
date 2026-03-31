--[[
			// UserData.lua
			// API for all user related data

			// TODO:
				Eventually all of this will move into Rodux
]]
local CoreGui = game:GetService("CoreGui")
local GuiRoot = CoreGui:FindFirstChild("RobloxGui")
local Modules = GuiRoot:FindFirstChild("Modules")
local ShellModules = Modules:FindFirstChild("Shell")
local Players = game:GetService('Players')
local UserInputService = game:GetService("UserInputService")

local Http = require(ShellModules:FindFirstChild('Http'))
local Utility = require(ShellModules:FindFirstChild('Utility'))

local UserData = {}

local currentUserData = nil

local function setVoteCountAsync()
	local voteResult = Http.GetVoteCountAsync()
	currentUserData["VoteCount"] = voteResult and voteResult['VoteCount'] or 0
end

function UserData:Initialize()
	if currentUserData then
		Utility.DebugLog("Trying to initialize UserData when we already have valid data.")
	end

	currentUserData = {}

	if UserInputService:GetPlatform() == Enum.Platform.XBoxOne then
		spawn(setVoteCountAsync)
	end
end

function UserData:GetVoteCount()
	if not currentUserData then
		Utility.DebugLog("Error: UserData:GetVoteCount() - UserData has not been initialized. Don't do that!")
		return nil
	end
	return currentUserData["VoteCount"]
end

function UserData:IncrementVote()
	currentUserData["VoteCount"] = (currentUserData["VoteCount"] or 0) + 1
end

function UserData:DecrementVote()
	currentUserData["VoteCount"] = math.max((currentUserData["VoteCount"] or 0) - 1, 0)
end

function UserData:Reset()
	currentUserData = nil
end

--[[ This should no longer be used ]]--
function UserData.GetLocalUserIdAsync()
	return UserData.GetLocalPlayerAsync().userId
end

function UserData.GetLocalPlayerAsync()
	local localPlayer = Players.LocalPlayer
	while not localPlayer do
		wait()
		localPlayer = Players.LocalPlayer
	end
	return localPlayer
end

function UserData.GetPlatformUserBalanceAsync()
	local result = Http.GetPlatformUserBalanceAsync()
	if not result then
		-- TODO: Error Code
		return nil
	end
	--

	return result["Robux"]
end

function UserData.GetTotalUserBalanceAsync()
	local result = Http.GetTotalUserBalanceAsync()
	if not result then
		return nil
	end

	return result["robux"]
end

return UserData
