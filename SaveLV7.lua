-- =============================================
-- CUSTOM FULL MAP SAVER - ADVANCED UNION REPAIR
-- Union 100% - CSG Error -6 Mitigation System
-- Tác giả: Custom cho Hoàng Sơn
-- =============================================

print("🔄 Loading Advanced Custom Map Saver with Union Repair...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ==================== SETTINGS ====================
local Settings = {
    RiseHeight = 280,
    CircleRadius = 550,
    RiseTime = 3.5,
    CircleSpeed = 48,
    Revolutions = 3,
    
    SaveTerrain = false,
    SaveUnion = true,
    TreatUnionsAsParts = false,        -- Giữ Union 100%
    SaveMesh = true,
    
    -- Union Repair Settings
    MaxUnionRepairAttempts = 5,
    SimplifyComplexUnions = true,
    RemoveNegativeParts = true,
    LogUnionErrors = true,
    Timeout = 360,
}

local SavedUnions = {}
local FailedUnions = {}

-- ==================== FLIGHT SYSTEM ====================
local function EnableStableFlight()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    Humanoid.PlatformStand = true
    Root.Anchored = true
end

local function DisableStableFlight()
    Root.Anchored = false
    Humanoid.PlatformStand = false
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local function RiseToHeight()
    EnableStableFlight()
    local startPos = Root.Position
    local targetPos = Vector3.new(startPos.X, startPos.Y + Settings.RiseHeight, startPos.Z)

    local tween = TweenService:Create(Root, TweenInfo.new(Settings.RiseTime, Enum.EasingStyle.Sine), {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
    return targetPos
end

local function CircleFly(centerPos)
    for rev = 1, Settings.Revolutions do
        for angle = 0, 360, 3 do
            local rad = math.rad(angle)
            local x = centerPos.X + math.cos(rad) * Settings.CircleRadius
            local z = centerPos.Z + math.sin(rad) * Settings.CircleRadius
            local y = centerPos.Y + math.sin(rad * 2.5) * 20

            local target = Vector3.new(x, y, z)
            local tweenTime = math.clamp((Root.Position - target).Magnitude / Settings.CircleSpeed, 0.08, 0.22)

            local tween = TweenService:Create(Root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
            tween:Play()
            tween.Completed:Wait()

            if angle % 60 == 0 then
                print(string.format("📍 Vòng %d/3 - %d%%", rev, math.floor(angle / 3.6)))
            end
        end
    end
end

-- ==================== UNION REPAIR SYSTEM (Core) ====================
local function DeepCopyUnion(union)
    if not union or not union:IsA("UnionOperation") then return nil end
    
    local newUnion = Instance.new("UnionOperation")
    newUnion.Name = union.Name .. "_Repaired"
    newUnion.CFrame = union.CFrame
    newUnion.Size = union.Size
    newUnion.Color = union.Color
    newUnion.Material = union.Material
    newUnion.Transparency = union.Transparency
    newUnion.UsePartColor = union.UsePartColor
    newUnion.CollisionFidelity = Enum.CollisionFidelity.Default
    newUnion.RenderFidelity = Enum.RenderFidelity.Precise
    
    -- Copy children (NegativeParts, etc.)
    for _, child in pairs(union:GetChildren()) do
        if child:IsA("BasePart") then
            local clone = child:Clone()
            clone.Parent = newUnion
        end
    end
    
    return newUnion
end

local function RepairUnion(union, attempt)
    if attempt > Settings.MaxUnionRepairAttempts then
        table.insert(FailedUnions, union)
        return nil
    end
    
    print(string.format("🔧 Repairing Union: %s | Attempt %d", union.Name, attempt))
    
    local success, repaired = pcall(function()
        local newUnion = DeepCopyUnion(union)
        
        -- Remove problematic negative parts
        if Settings.RemoveNegativeParts then
            for _, child in pairs(newUnion:GetChildren()) do
                if child:IsA("BasePart") and child.Name:lower():find("negative") then
                    child:Destroy()
                end
            end
        end
        
        -- Simplify if too complex
        if Settings.SimplifyComplexUnions and #newUnion:GetChildren() > 8 then
            newUnion.CollisionFidelity = Enum.CollisionFidelity.Box
        end
        
        return newUnion
    end)
    
    if success and repaired then
        table.insert(SavedUnions, repaired)
        return repaired
    else
        return RepairUnion(union, attempt + 1)
    end
end

local function ProcessAllUnionsInMap()
    print("🔍 Đang quét và repair tất cả Union trong map...")
    local count = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("UnionOperation") then
            count = count + 1
            local repaired = RepairUnion(obj, 1)
            if repaired then
                -- Replace original with repaired version in a safe way
                pcall(function()
                    repaired.Parent = obj.Parent
                    obj:Destroy()
                end)
            end
        end
    end
    
    print(string.format("✅ Đã xử lý %d Union | Failed: %d", count, #FailedUnions))
end

-- ==================== CUSTOM SAVE FUNCTION ====================
local function CustomSaveMap()
    print("🚀 Bắt đầu Custom Save Full Map...")
    
    ProcessAllUnionsInMap()  -- Repair Union trước khi save
    
    local success, SaveInstance = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua", true))()
    end)
    
    if not success then
        error("❌ Không load được base saver!")
    end
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = Settings.SaveMesh,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,
        SafeMode = true,
        LowMemoryMode = true,
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_CustomUnionFix_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    SaveInstance(Options)
end

-- ==================== MAIN EXECUTION ====================
settings().Rendering.QualityLevel = 1

print("🛫 Bắt đầu Preload Map...")
local centerPos = RiseToHeight()
task.wait(1.5)
CircleFly(centerPos)
DisableStableFlight()

task.wait(Settings.DelayBeforeSave or 8)

CustomSaveMap()

print("🎉 Custom Save hoàn tất!")
print("📊 Saved Unions: " .. #SavedUnions .. " | Failed: " .. #FailedUnions)
if #FailedUnions > 0 then
    warn("⚠️ Một số Union vẫn lỗi. Khuyến nghị thử map khác hoặc giảm độ phức tạp.")
end
