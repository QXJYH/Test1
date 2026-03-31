local AppStorageService = game:GetService("AppStorageService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Modules = CoreGui.RobloxGui.Modules
local LocalStorageKey = require(Modules.LuaApp.Enum.LocalStorageKey)

local User = {}
User.__index = User

function User.new(userId, username, membershipType, isUnder13)
	local self = {
		userId = userId,
		username = username,
		membershipType = membershipType,
		isUnder13 = isUnder13,
	}

	setmetatable(self, User)
	return self
end

function User.fromRequest(result)
	return User.new(
		result.responseBody.UserId,
		result.responseBody.Username,
		tonumber(result.responseBody.MembershipType),
		result.responseBody.AgeBracket == 1
	)
end

function User.fromLocalStorage()
	return User.new(
		tonumber(AppStorageService:GetItem(LocalStorageKey.UserId)) or -1,
		AppStorageService:GetItem(LocalStorageKey.Username),
		tonumber(AppStorageService:GetItem(LocalStorageKey.Membership)) or -1,
		AppStorageService:GetItem(LocalStorageKey.IsUnder13) == "true" and true or false
	)
end

function User.clearLocalStorage()
	AppStorageService:SetItem(LocalStorageKey.UserId, "-1")
	AppStorageService:SetItem(LocalStorageKey.Username, "")
	AppStorageService:SetItem(LocalStorageKey.Membership, "")
	AppStorageService:SetItem(LocalStorageKey.IsUnder13, "")
end

function User:setToLocalPlayer()
	Players:SetLocalPlayerInfo(self.userId, self.username, self.membershipType, self.isUnder13)
end

function User:setToLocalStorage()
	AppStorageService:SetItem(LocalStorageKey.UserId, tostring(self.userId))
	AppStorageService:SetItem(LocalStorageKey.Username, self.username)
	AppStorageService:SetItem(LocalStorageKey.Membership, tostring(self.membershipType))
	AppStorageService:SetItem(LocalStorageKey.IsUnder13, tostring(self.isUnder13))
end

function User:isSame(user)
	return self.userId == user.userId
end

function User:toString()
	return string.format("userId:%s, username:%s, membershipType:%s, isUnder13:%s",
		tostring(self.userId), self.username, tostring(self.membershipType), tostring(self.isUnder13))
end

return User