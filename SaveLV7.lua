-- =============================================
-- FULL MAP SAVE - TWEEN + ANCHOR STABLE FLY
-- Bay lên → Vòng tròn mượt + Giữ độ cao cứng
-- =============================================

print("🔄 Loading Ultra Stable Anchor + Tween Fly...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Settings = {
    RiseHeight = 280,
    CircleRadius = 550,
    RiseTime = 3.5,
    CircleSpeed = 48,           -- Chậm & mượt
    Revolutions = 3,
    
    -- Save
    SaveTerrain = false,
    SaveUnion = true,
    TreatUnionsAsParts = false,
    SaveMesh = true,
    Timeout = 300,
    DelayBeforeSave = 8,
}

-- === Noclip + Anchor ===
local function EnableFlight()
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    Humanoid.PlatformStand = true
    Root.Anchored = true          -- <-- NEO CỨNG QUAN TRỌNG
    print("🛫 Flight Mode: Anchor + Noclip Activated")
end

local function DisableFlight()
    Root.Anchored = false
    Humanoid.PlatformStand = false
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    print("✅ Flight Mode Disabled")
end

-- === BAY LÊN THẲNG ===
local function RiseToHeight()
    EnableFlight()
    print("🛫 Bay lên thẳng đến " .. Settings.RiseHeight .. " stud...")

    local startPos = Root.Position
    local targetPos = Vector3.new(startPos.X, startPos.Y + Settings.RiseHeight, startPos.Z)

    local tweenInfo = TweenInfo.new(Settings.RiseTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Root, tweenInfo, {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    tween.Completed:Wait()
    
    print("✅ Đã neo ở độ cao ổn định!")
    return targetPos
end

-- === BAY VÒNG TRÒN ỔN ĐỊNH (Có Height Lock) ===
local function CircleFly(centerPos)
    print("🔄 Bắt đầu bay vòng tròn ổn định (Anchor Mode)...")

    for rev = 1, Settings.Revolutions do
        for angle = 0, 360, 3 do
            local rad = math.rad(angle)
            local offsetX = math.cos(rad) * Settings.CircleRadius
            local offsetZ = math.sin(rad) * Settings.CircleRadius
            local yOffset = math.sin(rad * 2.5) * 20   -- Dao động nhẹ tự nhiên

            local targetPos = Vector3.new(
                centerPos.X + offsetX,
                centerPos.Y + yOffset,        -- Giữ độ cao ổn định
                centerPos.Z + offsetZ
            )

            local distance = (Root.Position - targetPos).Magnitude
            local tweenTime = math.clamp(distance / Settings.CircleSpeed, 0.08, 0.22)

            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(Root, tweenInfo, {CFrame = CFrame.new(targetPos)})
            
            tween:Play()
            tween.Completed:Wait()

            -- Height Lock (Phòng trường hợp bị tụt)
            if math.abs(Root.Position.Y - centerPos.Y) > 15 then
                Root.CFrame = CFrame.new(Root.Position.X, centerPos.Y + yOffset, Root.Position.Z)
            end

            if angle % 60 == 0 then
                print("📍 Vòng " .. rev .. "/3 | Tiến độ: " .. math.floor(angle / 3.6) .. "%")
            end
        end
    end

    print("✅ Hoàn tất bay vòng tròn ổn định!")
end

-- === SAVE ===
local function StartSave()
    print("🔄 Bắt đầu save full map | Union 100%...")
    
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
        TreatUnionsAsParts = Settings.TreatUnionsAsParts,
        SafeMode = true,
        LowMemoryMode = true,
        Timeout = Settings.Timeout,
        ShowProgress = true,
        FileName = "FullMap_StableTween_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }
    
    SaveInstance(Options)
end

-- === MAIN EXECUTION ===
settings().Rendering.QualityLevel = 1

local centerPosition = RiseToHeight()
task.wait(1.2)

CircleFly(centerPosition)

DisableFlight()

task.wait(Settings.DelayBeforeSave)

StartSave()

print("🎉 Hoàn tất! Đã tối ưu anchor + tween ổn định.")
