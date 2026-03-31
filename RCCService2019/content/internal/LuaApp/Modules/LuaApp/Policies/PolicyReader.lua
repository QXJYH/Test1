local Modules = game:GetService("CoreGui").RobloxGui.Modules
local DefaultPolicy = require(Modules.LuaApp.Policies.DefaultPolicy)

local PolicyReader = {
    -- IsFeatureEnabled is only for boolean values
    IsFeatureEnabled = function(policy, feature, params)
        local value = policy[feature]
        if value ~= nil then
            if type(value) ~= "boolean" then
                error("IsFeatureEnabled: feature [" .. feature .. "] is not a boolean!")
                return nil
            else
                return value
            end
        end
        if policy ~= DefaultPolicy then
            value = DefaultPolicy[feature]
            if value ~= nil then
                if type(value) ~= "boolean" then
                    error("IsFeatureEnabled: feature [" .. feature .. "] is not a boolean!")
                    return nil
                else
                    return value
                end
            end
        end
        error("IsFeatureEnabled: feature [" .. feature .. "] is unavailable!")
        return nil
    end,

    generateFeatureFunctions = function(policy, params, target)
        for feature, defaultValue in pairs(DefaultPolicy) do
            local result = nil
            local curValue = policy[feature]
            if curValue ~= nil then
                if type(curValue) == "function" then
                    result = curValue(params)
                else
                    result = curValue
                end
            else
                if policy ~= DefaultPolicy then
                    if type(defaultValue) == "function" then
                        result = defaultValue(params)
                    else
                        result = defaultValue
                    end
                end
            end
            if result ~= nil then
                local getFeatureFunc = function(...)
                    if type(result) == "function" then
                        return result(...)
                    end
                    return result
                end
                target["get"..feature] = getFeatureFunc
            else
                error("Policy feature [" .. feature .. "] is unavailable!")
            end
        end
    end,
}

return PolicyReader