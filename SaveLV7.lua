-- =============================================
-- FULL MAP SAVE LV7 - ANTI CRASH CAO
-- Preload chậm + Save nhẹ + Chunked
-- =============================================

print("🔄 Loading Anti-Crash Full Map Saver...")

local Settings = {
    -- Preload
    PreloadEnabled = true,
    PreloadSpeed = 80,
    UndergroundDepth = -400,
    PreloadDuration = 45,           -- Giảm xuống nếu map nhỏ

    -- Save Options (Quan trọng để tránh crash)
    SaveTerrain = true,
    SaveUnion = true,
    TreatUnionsAsParts = true,      -- RẤT QUAN TRỌNG: Giảm lỗi Union & crash
    SaveMesh = true,
    SaveScripts = false,
    DecompileScripts = false,

    -- Anti-Crash
    SafeMode = true,
    LowMemoryMode = true,           -- Bật để giảm memory
    ChunkedWrite = true,            -- Viết file theo chunk
    Timeout = 300,                  -- Tăng timeout
    DelayBeforeSave = 8,            -- Delay sau preload
}

-- === STEALTH PRELOAD (Chậm & Ổn định) ===
local function StealthPreload()
    local Character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local Root = Character:WaitForChild("HumanoidRootPart")
    
    local BV = Instance.new("BodyVelocity")
    local BG = Instance.new("BodyGyro")
    BV.MaxForce = Vector3.new(1e5,1e5,1e5)
    BG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    BV.Parent = Root
    BG.Parent = Root
    
    game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
    
    print("🛫 Preload chậm & ổn định (Anti-Crash)...")
    
    for i = 1, Settings.PreloadDuration do
        local pos = Root.Position
        BV.Velocity = Vector3.new(50, Settings.UndergroundDepth - pos.Y, 30)
        BG.CFrame = CFrame.new(pos)
        
        if i % 8 == 0 then
            print("📍 Preload: " .. math.floor((i/Settings.PreloadDuration)*100) .. "%")
        end
        task.wait(0.6)  -- Delay cao hơn để tránh lag spike
    end
    
    BV:Destroy()
    BG:Destroy()
    print("✅ Preload xong!")
end

-- === MAIN SAVE ===
local function StartSave()
    print("🔄 Bắt đầu save full map (Low Memory Mode)...")
    
    local synsave = loadstring(game:HttpGet("https://raw.githubusercontent.com/verysigmapro/UniversalSynSaveInstance-With-Save-Terrain/main/saveinstance_rewrite.luau", true))()
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = Settings.SaveMesh,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,   -- Giảm crash Union
        DecompileScripts = false,
        SafeMode = true,
        LowMemoryMode = true,          -- Option chống crash
        ChunkedWrite = true,           -- Viết file theo từng phần
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_AntiCrash_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    synsave(Options)
end

-- === CHẠY ===
settings().Rendering.QualityLevel = 1   -- Giảm chất lượng để tiết kiệm RAM

if Settings.PreloadEnabled then
    StealthPreload()
end

task.wait(Settings.DelayBeforeSave)

StartSave()

print("🎉 Script chạy xong. Nếu vẫn crash thì thử tắt SaveTerrain trước.")
