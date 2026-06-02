-- =============================================
-- FULL MAP SAVE - TWEEN SERVICE + CIRCLE FLY
-- Bay lên thẳng → Vòng tròn mượt - Union 100%
-- =============================================

print("🔄 Loading TweenService Sky Circle Preload...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local Settings = {
    RiseHeight = 280,
    CircleRadius = 550,
    RiseTime = 4,              -- Thời gian bay lên (giây)
    CircleSpeed = 55,          -- Tốc độ bay vòng (stud/giây)
    Revolutions = 3,
    
    -- Save
    SaveTerrain = false,
    SaveUnion = true,
    TreatUnionsAsParts = false,   -- UNION 100%
    SaveMesh = true,
    Timeout = 300,
    DelayBeforeSave = 8,
}

-- === Noclip ===
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

-- === BAY LÊN THẲNG BẰNG TWEEN ===
local function RiseToHeight()
    EnableNoclip()
    print("🛫 Bay lên thẳng đến " .. Settings.RiseHeight .. " stud bằng Tween...")

    local startPos = Root.Position
    local targetPos = Vector3.new(startPos.X, startPos.Y + Settings.RiseHeight, startPos.Z)

    local tweenInfo = TweenInfo.new(
        Settings.RiseTime,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(Root, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()

    print("✅ Đã lên độ cao ổn định!")
    return targetPos
end

-- === BAY VÒNG TRÒN BẰNG TWEEN (Loop mượt) ===
local function CircleFly(centerPos)
    print("🔄 Bắt đầu bay vòng tròn bán kính " .. Settings.CircleRadius .. " stud...")

    local totalTimePerCircle = (2 * math.pi * Settings.CircleRadius) / Settings.CircleSpeed
    local angleStep = 4  -- Bước góc nhỏ = mượt

    for rev = 1, Settings.Revolutions do
        for angle = 0, 360, angleStep do
            local rad = math.rad(angle)
            local offsetX = math.cos(rad) * Settings.CircleRadius
            local offsetZ = math.sin(rad) * Settings.CircleRadius
            local yOffset = math.sin(rad * 3) * 30   -- Dao động nhẹ tự nhiên

            local targetPos = Vector3.new(
                centerPos.X + offsetX,
                centerPos.Y + yOffset,
                centerPos.Z + offsetZ
            )

            local distance = (Root.Position - targetPos).Magnitude
            local tweenTime = math.clamp(distance / Settings.CircleSpeed, 0.08, 0.25)

            local tweenInfo = TweenInfo.new(
                tweenTime,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            )

            local tween = TweenService:Create(Root, tweenInfo, {CFrame = CFrame.new(targetPos)})
            tween:Play()
            tween.Completed:Wait()

            if angle % 60 == 0 then
                print("📍 Vòng " .. rev .. "/3 | " .. math.floor(angle / 3.6) .. "%")
            end
        end
    end

    print("✅ Hoàn tất bay vòng tròn!")
end

-- === SAVE FUNCTION ===
local function StartSave()
    print("🔄 Bắt đầu save full map | Union giữ nguyên 100%...")

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
        FileName = "FullMap_TweenCircle_" .. game.PlaceId .. "_" .. os.date("%H%M%S"),
    }

    SaveInstance(Options)
end

-- === MAIN ===
settings().Rendering.QualityLevel = 1

local centerPosition = RiseToHeight()
task.wait(1)

CircleFly(centerPosition)

DisableNoclip()

task.wait(Settings.DelayBeforeSave)

StartSave()

print("🎉 Hoàn tất! Union giữ nguyên 100%.")
