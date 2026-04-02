-- Avatar_R15_Action v1.1.1
-- For R6, this generates the normal with/without gear pose. For R15 it positions their body in an action pose.
local baseUrl, characterAppearanceUrl, fileExtension, x, y = ...

local ThumbnailGenerator = game:GetService("ThumbnailGenerator")
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailScriptStarted")

pcall(function() game:GetService("ContentProvider"):SetBaseUrl(baseUrl) end)
game:GetService("ScriptContext").ScriptsDisabled = true
game:GetService("HttpService").HttpEnabled = true

pcall(function() game:GetService("InsertService"):SetAssetUrl(baseUrl .. "/Asset/?id=%d") end)
pcall(function() game:GetService("InsertService"):SetAssetVersionUrl(baseUrl .. "/Asset/?assetversionid=%d") end)
pcall(function() game:GetService("ScriptInformationProvider"):SetAssetUrl(baseUrl .. "/Asset/") end)

local Insert = game:GetService("InsertService")
local HttpService = game:GetService("HttpService")

local player = game:GetService("Players"):CreateLocalPlayer(0)
player.CharacterAppearance = characterAppearanceUrl
player:LoadCharacterBlocking()

ThumbnailGenerator:AddProfilingCheckpoint("PlayerCharacterLoaded")

local poseAnimationId = "http://bbblox.org/asset/?id=532421348"

local function getJointBetween(part0, part1)
    for _, obj in pairs(part1:GetChildren()) do
        if obj:IsA("Motor6D") and obj.Part0 == part0 then
            return obj
        end
    end
end

local function applyKeyframe(character, poseKeyframe)
    local function recurApplyPoses(parentPose, poseObject)
        if parentPose then
            local joint = getJointBetween(character[parentPose.Name], character[poseObject.Name])
            if joint and poseObject.Weight ~= 0 then
                joint.C1 = poseObject.CFrame:inverse() + joint.C1.p
            end
        end
        for _, subPose in pairs(poseObject:GetSubPoses()) do
            recurApplyPoses(poseObject, subPose)
        end
    end

    for _, poseObj in pairs(poseKeyframe:GetPoses()) do
        recurApplyPoses(nil, poseObj)
    end
end

local function applyR15Pose(character)
    local poseKeyframSequence = game:GetService("KeyframeSequenceProvider"):GetKeyframeSequence(poseAnimationId)
    local poseKeyframe = poseKeyframSequence:GetKeyframes()[1]
    applyKeyframe(character, poseKeyframe)
end

local function findAttachmentsRecur(parent, resultTable, returnDictionary)
    for _, obj in pairs(parent:GetChildren()) do
        if obj:IsA("Attachment") then
            if returnDictionary then
                resultTable[obj.Name] = obj
            else
                resultTable[#resultTable + 1] = obj
            end
        elseif not obj:IsA("Tool") and not obj:IsA("Accoutrement") then
            findAttachmentsRecur(obj, resultTable, returnDictionary)
        end
    end
end

local function findAttachmentsInTool(tool)
    local attachments = {}
    findAttachmentsRecur(tool, attachments, false)
    return attachments
end

local function findAttachmentsInCharacter(character)
    local attachments = {}
    findAttachmentsRecur(character, attachments, true)
    return attachments
end

local function weldAttachments(attach1, attach2)
    local weld = Instance.new("Weld")
    weld.Part0 = attach1.Parent
    weld.Part1 = attach2.Parent
    weld.C0 = attach1.CFrame
    weld.C1 = attach2.CFrame
    weld.Parent = attach1.Parent
    return weld
end

local function findFirstMatchingAttachment(model, name)
    for _, child in pairs(model:GetChildren()) do
        if child:IsA("Attachment") and child.Name == name then
            return child
        elseif not child:IsA("Accoutrement") and not child:IsA("Tool") then
            local foundAttachment = findFirstMatchingAttachment(child, name)
            if foundAttachment then
                return foundAttachment
            end
        end
    end
end

local function doR15ToolPose(character, humanoid, tool)
    local characterAttachments = findAttachmentsInCharacter(character)
    local toolAttachments = findAttachmentsInTool(tool)
    local foundAttachments = false

    for _, attachment in pairs(toolAttachments) do
        local matchingAttachment = characterAttachments[attachment.Name]
        if matchingAttachment then
            foundAttachments = true
            weldAttachments(matchingAttachment, attachment)
        end
    end

    if foundAttachments then
        tool.Parent = character
        applyR15Pose(character)

        local toolPose = tool:FindFirstChild("ThumbnailPose")
        if toolPose and toolPose:IsA("Keyframe") then
            applyKeyframe(character, toolPose)
        end
    else
        tool.Parent = nil
        local rightShoulderJoint = getJointBetween(character.UpperTorso, character.RightUpperArm)
        if rightShoulderJoint then
            rightShoulderJoint.C1 = rightShoulderJoint.C1 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 1, 0):inverse()
        end
        if tool:FindFirstChild("Handle") then
            local attachment = findFirstMatchingAttachment(character, "RightGripAttachment")
            if attachment then
                tool.Handle.CFrame = attachment.Parent.CFrame * attachment.CFrame * tool.Grip:inverse()
            end
        end
        humanoid:EquipTool(tool)
    end
end

local function applyMesh(character, children, limb)
    local ok, msg = pcall(function()
        local specialMesh = children[1]
        local part = character[limb]
        local m = part:FindFirstChild("Mesh")
        if not m then
            m = Instance.new("SpecialMesh")
            m.Parent = part
        end
        m.Scale = specialMesh.Scale
        m.TextureId = specialMesh.TextureId
        m.MeshId = specialMesh.MeshId
        m.MeshType = specialMesh.MeshType
        m.VertexColor = specialMesh.VertexColor
    end)
    if not ok then
        print("error loading mesh", msg)
    end
end

local function applyPackage(character, children)
    local ok, msg = pcall(function()
        for _, asset in pairs(children) do
            asset.Parent = character
        end
    end)
    if not ok then
        print("error loading package", msg)
    end
end

local avatarData = HttpService:JSONDecode(HttpService:GetAsync(characterAppearanceUrl))

local character = player.Character
if character then
    local done = 0
    local total = #avatarData.assets

    for _, asset in pairs(avatarData.assets) do
        coroutine.wrap(function()
            local ok, Asset = pcall(function()
                return Insert:LoadAsset(asset.id)
            end)

            if not ok then
                print("failed to load asset", asset.id, Asset)
                done = done + 1
                return
            end

            local children = Asset:GetChildren()

            if asset.assetType.id == 17 then
                applyMesh(character, children, "Head")
            elseif asset.assetType.id == 27 or asset.assetType.id == 28 or asset.assetType.id == 29 or asset.assetType.id == 30 or asset.assetType.id == 31 then
                applyPackage(character, children)
            else
                for _, item in pairs(children) do
                    if asset.assetType.id == 18 then
                        local head = character.Head
                        if head:FindFirstChild("face") then
                            head.face:Destroy()
                        end
                        item.Name = "face"
                        item.Parent = head
                    else
                        item.Parent = character
                    end
                end
            end

            done = done + 1
        end)()
    end

    repeat wait() until done == total

    local bc = avatarData.bodyColors
    if bc then
        local colors = {
            ['Head']      = bc.headColorId,
            ['Torso']     = bc.torsoColorId,
            ['Left Arm']  = bc.leftArmColorId,
            ['Right Arm'] = bc.rightArmColorId,
            ['Left Leg']  = bc.leftLegColorId,
            ['Right Leg'] = bc.rightLegColorId,
        }
        for part, color in pairs(colors) do
            if character:FindFirstChild(part) then
                character[part].BrickColor = BrickColor.new(color)
            end
        end
    end

    local tool = character:FindFirstChildOfClass("Tool")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        local equippedPoseValue = animateScript:FindFirstChild("Pose") or animateScript:FindFirstChild("pose")
        if equippedPoseValue then
            local poseAnim = equippedPoseValue:FindFirstChildOfClass("Animation")
            if poseAnim then
                poseAnimationId = poseAnim.AnimationId
            end
        end
    end

    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            if tool then
                character.Torso["Right Shoulder"].CurrentAngle = math.rad(90)
            end
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            if tool then
                doR15ToolPose(character, humanoid, tool)
            else
                applyR15Pose(character)
            end
        end
    end
end

local result, requestedUrls = ThumbnailGenerator:Click(fileExtension, x, y, --[[hideSky = ]] true)
ThumbnailGenerator:AddProfilingCheckpoint("ThumbnailGenerated")

return result, requestedUrls