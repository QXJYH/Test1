-- Avatar_R15_Headshot v1.0.0 boiiii
local baseUrl, characterAppearanceUrl, fileExtension, x, y = ...

local ThumbnailGenerator = game:GetService("ThumbnailGenerator")
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailScriptStarted")

pcall(function() game:GetService("ContentProvider"):SetBaseUrl(baseUrl) end)
game:GetService("ScriptContext").ScriptsDisabled = true
game:GetService("UserInputService").MouseIconEnabled = false

local player = game:GetService("Players"):CreateLocalPlayer(0)
player.CharacterAppearance = characterAppearanceUrl
player:LoadCharacterBlocking()

ThumbnailGenerator:AddProfilingCheckpoint("PlayerCharacterLoaded")

local character = player.Character

local function FindFirstChildWhichIsA(inst, className)
    for _, child in pairs(inst:GetChildren()) do
        if child:IsA(className) then
            return child
        end
    end
    return nil
end


for _, child in pairs(character:GetChildren()) do
    if child:IsA("Tool") then
        child:Destroy()
    end
end


local FFlagOnlyCheckHeadAccessoryInHeadShot = false
local headAttachments = {
    HatAttachment = true,
    HairAttachment = true,
    FaceFrontAttachment = true,
    FaceRearAttachment = true,
}

local cameraOffsetX = 0
local cameraOffsetY = 0
local maxHatZoom = 130
local baseHatZoom = 30
local maxDimension = 0
local quadratic = true

for _, child in pairs(character:GetChildren()) do
    if child:IsA("Accoutrement") then
        local handle = child:FindFirstChild("Handle")
        if handle then
            local attachment = FindFirstChildWhichIsA(handle, "Attachment")
            if not FFlagOnlyCheckHeadAccessoryInHeadShot or not attachment or headAttachments[attachment.Name] then
                local size = handle.Size / 2 + handle.Position - character.Head.Position
                local xy = Vector2.new(size.x, size.y)
                if xy.Magnitude > maxDimension then
                    maxDimension = xy.Magnitude
                end
            end
        end
    end
end

local maxHatOffset = 0.5
maxDimension = math.min(1, maxDimension / 3)
if quadratic then
    maxDimension = maxDimension * maxDimension
end

local yAngle = -math.pi / 16
local viewOffset   = character.Head.CFrame * CFrame.new(cameraOffsetX, cameraOffsetY + maxHatOffset * maxDimension, 0.1)
local positionOffset = character.Head.CFrame + (CFrame.Angles(0, yAngle, 0).LookVector.Unit * 3)

local camera = Instance.new("Camera", character)
camera.Name = "ThumbnailCamera"
camera.CameraType = Enum.CameraType.Scriptable
camera.CoordinateFrame = CFrame.new(positionOffset.Position, viewOffset.Position)
camera.FieldOfView = baseHatZoom + (maxHatZoom - baseHatZoom) * maxDimension

workspace.CurrentCamera = camera

local result, requestedUrls = ThumbnailGenerator:Click(fileExtension, x, y, --[[hideSky = ]] true)
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailGenerated")

return result, requestedUrls