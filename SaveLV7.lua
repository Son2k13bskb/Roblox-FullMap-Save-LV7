-- =============================================
-- Roblox Full Map Save LV7 - Preload + Stealth
-- Tối ưu crash & Union Error - By Hoàng Sơn
-- =============================================

print("🔄 Loading Full Map Preloader + Saver LV7...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- === CÀI ĐẶT CHÍNH ===
local Settings = {
    FlySpeed = 150,              -- Tốc độ bay preload
    PreloadTime = 60,            -- Thời gian preload (giây) - tăng nếu map to
    SaveAfterPreload = true,
    UndergroundDepth = -500,     -- Bay dưới đất sâu
    SkyHeight = 1000,            -- Hoặc bay trên trời
    UseUnderground = true,       -- true = dưới đất, false = trên trời
    
    -- Save Options
    SaveTerrain = true,
    TreatUnionsAsParts = false,  -- Bật true nếu Union lỗi nhiều (giảm CGS error)
    SaveUnion = true,
    Timeout = 180,
    
    -- Anti Crash & Anti Kick
    SafeMode = true,
    BoostFPS = true,
    KillOtherScripts = true,
    ShowProgress = true,
}

-- === STEALTH FLY (Noclip + Invisible) ===
local function EnableStealthFly()
    if not Root then return end
    
    local BodyVelocity = Instance.new("BodyVelocity")
    local BodyGyro = Instance.new("BodyGyro")
    
    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    BodyVelocity.Velocity = Vector3.new(0,0,0)
    BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    BodyGyro.P = 12500
    
    BodyVelocity.Parent = Root
    BodyGyro.Parent = Root
    
    -- Noclip
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    Humanoid.PlatformStand = true
    
    print("🛫 Stealth Fly Enabled - Di chuyển preload map...")
    return BodyVelocity, BodyGyro
end

-- === PRELOAD FULL MAP ===
local function PreloadFullMap()
    local BV, BG = EnableStealthFly()
    
    -- Tự động quét map (có thể chỉnh thủ công)
    print("🌍 Bắt đầu preload map... Di chuyển từ đầu đến cuối.")
    
    -- Bay theo chiều X/Z chính (có thể chỉnh tọa độ map của bạn)
    local startPos = Root.Position
    local targetX = startPos.X + 2000  -- Tăng nếu map rộng
    local targetZ = startPos.Z + 2000
    
    for i = 0, Settings.PreloadTime, 0.5 do
        local progress = i / Settings.PreloadTime
        local newPos
        
        if Settings.UseUnderground then
            newPos = Vector3.new(startPos.X + progress * (targetX - startPos.X), 
                               Settings.UndergroundDepth, 
                               startPos.Z + progress * (targetZ - startPos.Z))
        else
            newPos = Vector3.new(startPos.X + progress * (targetX - startPos.X), 
                               Settings.SkyHeight, 
                               startPos.Z + progress * (targetZ - startPos.Z))
        end
        
        BV.Velocity = (newPos - Root.Position) * Settings.FlySpeed
        BG.CFrame = CFrame.new(Root.Position)
        
        task.wait(0.5)
        
        -- Anti Crash: Nhỏ giọt load
        if i % 10 == 0 then
            print("📍 Preload progress: " .. math.floor(progress * 100) .. "%")
        end
    end
    
    BV:Destroy()
    BG:Destroy()
    Humanoid.PlatformStand = false
    print("✅ Preload hoàn tất!")
end

-- === CHẠY SAVE ===
local function StartSave()
    print("🔄 Chuẩn bị save full map sau preload...")
    
    local success, synsaveinstance = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/verysigmapro/UniversalSynSaveInstance-With-Save-Terrain/main/saveinstance_rewrite.luau", true))()
    end)
    
    if not success then
        error("❌ Load synsaveinstance thất bại!")
    end
    
    local Options = {
        SaveAll = true,
        SaveTerrain = Settings.SaveTerrain,
        SaveUnion = Settings.SaveUnion,
        SaveMesh = true,
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,  -- Giảm lỗi Union CGS
        DecompileScripts = false,
        SafeMode = Settings.SafeMode,
        Timeout = Settings.Timeout,
        ShowProgress = Settings.ShowProgress,
        FileName = "FullMap_Preloaded_" .. game.PlaceId .. "_" .. os.date("%Y%m%d_%H%M%S"),
    }
    
    synsaveinstance(Options)
end

-- === MAIN ===
if Settings.KillOtherScripts then
    -- Kill các script khác để giảm lag & detect
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("LocalScript") and script ~= script then
            script.Disabled = true
        end
    end
end

if Settings.BoostFPS then
    settings().Rendering.QualityLevel = 1
    print("⚡ Boost FPS for stability")
end

-- Bắt đầu
PreloadFullMap()

if Settings.SaveAfterPreload then
    task.wait(3)
    StartSave()
end

print("🎉 Hoàn tất! File lưu trong thư mục exploit/workspace")
