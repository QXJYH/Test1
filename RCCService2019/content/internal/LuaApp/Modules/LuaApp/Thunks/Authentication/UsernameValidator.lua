local Modules = game:GetService("CoreGui").RobloxGui.Modules

local GetUsernameValid = require(Modules.LuaApp.Http.Requests.GetUsernameValid)
local Promise = require(Modules.LuaApp.Promise)
local SetNetworkingErrorToast = require(Modules.LuaApp.Thunks.SetNetworkingErrorToast)

local UsernameIssue = require(Modules.LuaApp.Enum.UsernameIssue)
local IssueCondition = require(Modules.LuaApp.Enum.IssueCondition)

local ISSUE_CODE_MESSAGE = {
	[2] = UsernameIssue.Content,--"Appropriate for Roblox.",
	[4] = UsernameIssue.BoundingUnderscore,--"Does not start or end with _",
	[5] = UsernameIssue.MultipleUnderscores--"Has at most one _.",
	--TODO: "Does not contain private information"
}
local ISSUE_MESSAGE_LIST = {
	[UsernameIssue.Char] = "Authentication.SignUp.Label.UsernameError1",
	[UsernameIssue.Length] = "Authentication.SignUp.Label.UsernameError2",
	[UsernameIssue.InUse] = "Authentication.SignUp.Label.UsernameError3",
	[UsernameIssue.Content] = "Authentication.SignUp.Label.UsernameError4",
	[UsernameIssue.BoundingUnderscore] = "Authentication.SignUp.Label.UsernameError5",
	[UsernameIssue.MultipleUnderscores] = "Authentication.SignUp.Label.UsernameError6",
	[UsernameIssue.PII] = "Authentication.SignUp.Label.UsernameError7",
}
local DEFAULT_ISSUES = {}
for issue in pairs(ISSUE_MESSAGE_LIST) do
	DEFAULT_ISSUES[issue] = IssueCondition.Hidden
end
DEFAULT_ISSUES[UsernameIssue.Char] = IssueCondition.Problematic
DEFAULT_ISSUES[UsernameIssue.Length] = IssueCondition.Problematic
DEFAULT_ISSUES[UsernameIssue.InUse] = IssueCondition.Problematic

function validateFunction(networking,username,previousIssues)
	return function(store)
		local currentIssues = {}
		for issue,condition in pairs(previousIssues) do
			currentIssues[issue] = condition==IssueCondition.Hidden and IssueCondition.Hidden or IssueCondition.Resolved
		end
		if username=="" then
			for issue,condition in pairs(currentIssues) do
				if condition==IssueCondition.Resolved then
					currentIssues[issue] = IssueCondition.Problematic
				end
			end
			return Promise.resolve({
				Input = username,
	 			UsernameValid = false,
				IssueCondition = currentIssues,
	 		})
		else
			local foundIssue = false

			if #username<3 then
				currentIssues[UsernameIssue.Length] = IssueCondition.Problematic
				foundIssue = true
			end

			if (string.sub(username,1,1)=="_" or string.sub(username,#username)=="_") then --Manually check for _ on ends
	 			currentIssues[ISSUE_CODE_MESSAGE[4]] = IssueCondition.Problematic
	 			foundIssue = true
	 		end

	 		do --Manually check for multiple _
	 			local i = string.find(username,"_",1)
	 			if i and string.find(username,"_",i+1) then
	 				currentIssues[ISSUE_CODE_MESSAGE[5]] = IssueCondition.Problematic
	 				foundIssue = true
	 			end
	 		end

 			for i=1,#username do --Manually check characters
 				local c = string.byte(username,i)
 				if (c<48 or c>57) and (c<65 or c>90) and (c<97 or c>122) and c~=95 then
 					currentIssues[UsernameIssue.Char] = IssueCondition.Problematic
 					foundIssue = true
 					break
 				end
 			end

			if foundIssue then --check conditions manually first, then validate on server if no issues found
				return Promise.resolve({
					Input = username,
					UsernameValid = false,
					IssueCondition = currentIssues,
				})
			else
				return GetUsernameValid(networking,username):andThen(
					function(result)
						local response = {}

						local responseCode = result and result.responseBody and result.responseBody.code
						if type(responseCode) == "number" then
						 	if responseCode==6 or responseCode==7 then
						 		currentIssues[UsernameIssue.Char] = IssueCondition.Problematic
						 	elseif responseCode==3 then
						 		currentIssues[UsernameIssue.Char] = IssueCondition.Problematic
						 		currentIssues[UsernameIssue.Length] = IssueCondition.Problematic
						 	elseif responseCode==1 then
						 		currentIssues[UsernameIssue.InUse] = IssueCondition.Problematic
						 	elseif responseCode~=0 then
						 		local msg = ISSUE_CODE_MESSAGE[result.responseBody.code]
						 		currentIssues[msg] = IssueCondition.Problematic
							end
						else
							--LUASTARTUP-57
							warn("JSON failure")
						end

				 		response.Input = username
					 	response.UsernameValid = responseCode==0
					 	response.IssueCondition = currentIssues

						return Promise.resolve(response)
					end,
					function(err)
						store:dispatch(SetNetworkingErrorToast(err))
						return Promise.reject(err)
					end
				)
			end
		end
	end
end

return {
	Validate = validateFunction,
	MessageList = ISSUE_MESSAGE_LIST,
	DefaultIssues = DEFAULT_ISSUES,
}