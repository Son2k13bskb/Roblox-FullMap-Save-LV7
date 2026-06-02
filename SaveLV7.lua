-- =============================================
-- FULL MAP SAVE - CIRCLE SKY FLY + UNION 100%
-- Bay cố định 200-350 stud + Vòng tròn mượt + Noclip
-- =============================================

print("🔄 Loading Circle Sky Preload + Union Preserve...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Settings = {
    HeightAboveGround = 280,     -- Giữ cố định ~280 stud cách mặt đất
    CircleRadius = 1200,         -- Bán kính vòng tròn (trung bình to)
    PreloadSpeed = 55,           -- Bay chậm mượt
    PreloadDuration = 75,        -- Thời gian bay dài hơn để load full map
    Revolutions = 3,             -- Bay 3 vòng tròn
    
    -- Save Options
    SaveTerrain = false,
    SaveUnion = true,
    TreatUnionsAsParts = false,   -- UNION 100% (không chuyển Part)
    SaveMesh = true,
    Timeout = 300,
    DelayBeforeSave = 8,
}

-- === Noclip Toàn Bộ Trong Khi Bay ===
local function EnableNoclip()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    Humanoid.PlatformStand = true
end

local function DisableNoclip()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    Humanoid.PlatformStand = false
end

-- === BAY VÒNG TRÒN CỐ ĐỊNH TRÊN TRỜI ===
local function CircleSkyFly()
    EnableNoclip()
    
    local BV = Instance.new("BodyVelocity")
    local BG = Instance.new("BodyGyro")
    
    BV.MaxForce = Vector3.new(60000, 60000, 60000)
    BG.MaxTorque = Vector3.new(60000, 60000, 60000)
    BV.P = 1500
    BG.P = 12000
    
    BV.Parent = Root
    BG.Parent = Root
    
    local startPos = Root.Position
    local centerX, centerZ = startPos.X, startPos.Z
    local currentHeight = startPos.Y + Settings.HeightAboveGround
    
    print("🛫 Bay vòng tròn cố định cao " .. Settings.HeightAboveGround .. " stud - Preload map...")
    
    for rev = 1, Settings.Revolutions do
        for angle = 0, 360, 4 do  -- Bước nhỏ → mượt
            local rad = math.rad(angle)
            local targetX = centerX + math.cos(rad) * Settings.CircleRadius
            local targetZ = centerZ + math.sin(rad) * Settings.CircleRadius
            local targetY = currentHeight + math.sin(rad * 2) * 40  -- Dao động nhẹ theo Y
            
            local target = Vector3.new(targetX, targetY, targetZ)
            
            BV.Velocity = (target - Root.Position) * Settings.PreloadSpeed
            BG.CFrame = CFrame.lookAt(Root.Position, target)
            
            if angle % 60 == 0 then
                print("📍 Vòng " .. rev .. "/3 - Tiến độ: " .. math.floor(angle / 3.6) .. "%")
            end
            
            task.wait(0.35)  -- Delay mượt, tránh dật
        end
    end
    
    BV:Destroy()
    BG:Destroy()
    DisableNoclip()
    
    print("✅ Preload vòng tròn hoàn tất!")
end

-- === SAVE (Giữ Union 100%) ===
local function StartSave()
    print("🔄 Bắt đầu save full map | Union giữ nguyên...")
    
    local success, SaveInstance = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua", true))()
    end)
    
    if not success then
        error("❌ Không load được SaveInstance")
    end
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = Settings.SaveMesh,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,   -- false = Union thật
        DecompileScripts = false,
        SafeMode = true,
        LowMemoryMode = true,
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_CircleUnion100_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    SaveInstance(Options)
end

-- === CHẠY SCRIPT ===
settings().Rendering.QualityLevel = 1

CircleSkyFly()

task.wait(Settings.DelayBeforeSave)

StartSave()

print("🎉 Hoàn tất! Union được giữ nguyên 100%.")
