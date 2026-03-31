-- Shirt v1.0.2

local assetUrl, fileExtension, x, y, baseUrl, mannequinId = ...

local ThumbnailGenerator = game:GetService("ThumbnailGenerator")
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailScriptStarted")

pcall(function() game:GetService("ContentProvider"):SetBaseUrl(baseUrl) end)
game:GetService("ScriptContext").ScriptsDisabled = true

local mannequin = game:GetObjects(baseUrl.. "asset/?id=" .. tostring(mannequinId))[1]
mannequin.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
mannequin.Parent = workspace

ThumbnailGenerator:AddProfilingCheckpoint("MannequinLoaded")

local shirt = game:GetObjects(assetUrl)[1]
shirt.Parent = mannequin

ThumbnailGenerator:AddProfilingCheckpoint("ObjectsLoaded")

local result, requestedUrls = ThumbnailGenerator:Click(fileExtension, x, y, --[[hideSky = ]] true)
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailGenerated")

return result, requestedUrls