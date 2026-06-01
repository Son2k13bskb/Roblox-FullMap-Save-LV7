-- =============================================
-- FULL MAP SAVE - SKY PRELOAD + UNION 100%
-- Bay chậm mượt - Union giữ nguyên - Anti Crash
-- =============================================

print("🔄 Loading Stable Sky Preload Saver...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Settings = {
    SkyHeight = 650,           -- Cao vừa phải
    PreloadSpeed = 65,         -- Bay CHẬM & MƯỢT (giảm die)
    PreloadDuration = 65,      -- Tăng thời gian preload để load map đầy đủ
    ScanRange = 2800,
    
    -- Save Options
    SaveTerrain = false,       -- Tắt Terrain (giảm crash mạnh)
    SaveUnion = true,
    TreatUnionsAsParts = false, -- GIỮ UNION 100%
    SaveMesh = true,
    SaveScripts = false,
    DecompileScripts = false,
    
    -- Anti Crash
    SafeMode = true,
    LowMemoryMode = true,
    Timeout = 300,
    DelayBeforeSave = 8,
}

-- === FLY MƯỢT MÀ TRÊN TRỜI ===
local function SmoothSkyFly()
    local BV = Instance.new("BodyVelocity")
    local BG = Instance.new("BodyGyro")
    
    BV.MaxForce = Vector3.new(40000, 40000, 40000)
    BG.MaxTorque = Vector3.new(40000, 40000, 40000)
    BV.P = 1250
    BG.P = 12500
    
    BV.Parent = Root
    BG.Parent = Root
    
    Humanoid.PlatformStand = true
    
    -- Anti va chạm
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    print("🛫 Bay chậm mượt trên trời - Preload map...")
    
    local startPos = Root.Position
    local time = 0
    
    while time < Settings.PreloadDuration do
        time = time + 0.5
        
        -- Bay theo đường xoắn ốc nhẹ để quét map rộng hơn
        local angle = time * 0.3
        local radius = 800 + math.sin(time * 0.2) * 300
        
        local targetX = startPos.X + math.cos(angle) * radius
        local targetZ = startPos.Z + math.sin(angle) * radius
        local targetY = startPos.Y + Settings.SkyHeight + math.sin(time * 0.4) * 80
        
        local target = Vector3.new(targetX, targetY, targetZ)
        
        BV.Velocity = (target - Root.Position) * Settings.PreloadSpeed
        BG.CFrame = CFrame.lookAt(Root.Position, target)
        
        if time % 8 < 0.5 then
            print("📍 Preload: " .. math.floor((time / Settings.PreloadDuration) * 100) .. "%")
        end
        
        task.wait(0.5)
    end
    
    BV:Destroy()
    BG:Destroy()
    Humanoid.PlatformStand = false
    print("✅ Preload map hoàn tất!")
end

-- === SAVE ===
local function StartSave()
    print("🔄 Bắt đầu save full map | Union giữ nguyên 100%...")
    
    local success, SaveInstance = pcall(function()
        -- Dùng repo chính ổn định nhất hiện tại
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua", true))()
    end)
    
    if not success then
        error("❌ Không load được SaveInstance!")
    end
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = Settings.SaveMesh,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,   -- false = Union 100%
        DecompileScripts = false,
        SafeMode = true,
        LowMemoryMode = true,
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_Union100_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    SaveInstance(Options)
end

-- === MAIN ===
settings().Rendering.QualityLevel = 1

SmoothSkyFly()

task.wait(Settings.DelayBeforeSave)

StartSave()

print("🎉 Hoàn tất. Union được giữ nguyên.")
