-- =============================================
-- FULL MAP SAVE LV7 - SKY PRELOAD + ANTI CRASH
-- Map trung bình to - TẮT TERRAIN - Bay trên trời
-- =============================================

print("🔄 Loading Sky Preload + Ultra Stable Saver...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Settings = {
    -- Preload trên trời
    SkyHeight = 800,              -- Bay cao trên trời
    PreloadSpeed = 120,
    PreloadDuration = 50,         -- Giây (tăng nếu map rộng)
    ScanDistance = 2500,          -- Phạm vi quét map
    
    -- Save Options (Siêu ổn định)
    SaveTerrain = false,          -- TẮT để tránh crash
    SaveUnion = true,
    TreatUnionsAsParts = true,    -- Giảm lỗi Union & crash
    SaveMesh = true,
    SaveScripts = false,
    DecompileScripts = false,
    
    -- Anti-Crash LV8
    SafeMode = true,
    LowMemoryMode = true,
    ChunkedWrite = true,
    Timeout = 240,
    DelayBeforeSave = 6,
    QualityLevel = 1,             -- Giảm đồ họa
}

-- === BAY TRÊN TRỜI (Stealth Fly) ===
local function SkyStealthFly()
    local BV = Instance.new("BodyVelocity")
    local BG = Instance.new("BodyGyro")
    
    BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BV.Parent = Root
    BG.Parent = Root
    
    Humanoid.PlatformStand = true
    
    -- Tắt va chạm
    for _, v in pairs(Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
    
    print("🛫 Bay trên trời cao - Preload map...")
    
    local startPos = Root.Position
    local directions = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 1),
        Vector3.new(1, 0, -1),
    }
    
    for phase = 1, 4 do
        for _, dir in pairs(directions) do
            for i = 1, 12 do
                local target = startPos + dir * Settings.ScanDistance * (i / 12) + Vector3.new(0, Settings.SkyHeight, 0)
                BV.Velocity = (target - Root.Position) * Settings.PreloadSpeed
                BG.CFrame = CFrame.new(Root.Position)
                
                task.wait(0.4)
            end
        end
        print("📍 Preload phase " .. phase .. "/4 hoàn tất")
    end
    
    BV:Destroy()
    BG:Destroy()
    Humanoid.PlatformStand = false
    print("✅ Preload trên trời xong!")
end

-- === SAVE FUNCTION ===
local function StartSave()
    print("🔄 Bắt đầu save full map (Ultra Low Memory)...")
    
    local success, SaveInstance = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.lua", true))()
    end)
    
    if not success then
        warn("❌ Không load được repo chính. Dùng fork thay thế.")
        return
    end
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = Settings.SaveMesh,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,
        DecompileScripts = Settings.DecompileScripts,
        SafeMode = Settings.SafeMode,
        LowMemoryMode = Settings.LowMemoryMode,
        ChunkedWrite = Settings.ChunkedWrite,
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_SkyPreload_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    SaveInstance(Options)
end

-- === MAIN EXECUTION ===
settings().Rendering.QualityLevel = Settings.QualityLevel

-- Preload trước
SkyStealthFly()

-- Delay trước save
task.wait(Settings.DelayBeforeSave)

-- Save
StartSave()

print("🎉 Script hoàn tất. File lưu trong thư mục exploit.")
print("💡 Nếu vẫn crash: Giảm PreloadDuration hoặc TreatUnionsAsParts = false")
