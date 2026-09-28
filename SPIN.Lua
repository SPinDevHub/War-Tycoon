-- [[ SPIN HUB v1 - WAR TYCOON ]]
-- By: CTcat

loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Settings.lua"))();
local FuncsV3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Main/main/Library/Example/FuncsV3"))();
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mamafoni281/Speed-hub-x-V5.0-Library/refs/heads/main/Speed-Hub-X-5.0-Library-Source"))():CreateWindow({
    ["Tab Width"] = 160,
    ["Description"] = "War Tycoon Script v1.8 | By CTcat",
    ["Title"] = "Spin Hub"
});

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Global Variables / States
local tweenSpeed = 300
local autoBarrel = false
local autoCapture = false
local autoRebirth = false
local farmKill = false
local farmPlayer = false

local walkSpeedVal = 16
local infiniteJump = false
local isFlying = false
local flySpeedVal = 100

-- Helper Function: Smooth Tween Teleport
local function tweenTo(cframe)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local dist = (hrp.Position - cframe.Position).Magnitude
        local duration = dist / math.clamp(tweenSpeed, 50, 1000)
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        tween:Play()
        return tween
    end
end

-- ==========================================
-- TABS CREATION
-- ==========================================
local FarmTab = Library:CreateTab({
    ["Name"] = "Farming",
    ["Icon"] = "rbxassetid://10723407389"
})

local PlayerTab = Library:CreateTab({
    ["Name"] = "Player",
    ["Icon"] = "rbxassetid://10723410062"
})

local SettingTab = Library:CreateTab({
    ["Name"] = "Setting",
    ["Icon"] = "rbxassetid://10734950309"
})

-- ==========================================
-- 1. FARMING MENU
-- ==========================================
local FarmingSection = FarmTab:AddSection("Tycoon & Loot Farming", true);

-- Auto Get Barrel (Oil Barrel)
FuncsV3:Toggle(FarmingSection, "Auto Get Barrel", "Teleport otomatis ngambil Oil Barrels di map", false, function(value)
    autoBarrel = value
    task.spawn(function()
        while autoBarrel do
            local barrelsFolder = Workspace:FindFirstChild("OilBarrels") or Workspace:FindFirstChild("Barrels")
            if barrelsFolder then
                for _, barrel in pairs(barrelsFolder:GetChildren()) do
                    if not autoBarrel then break end
                    if barrel:IsA("BasePart") or barrel:FindFirstChild("HumanoidRootPart") then
                        local targetCF = barrel:IsA("BasePart") and barrel.CFrame or barrel.HumanoidRootPart.CFrame
                        local tw = tweenTo(targetCF)
                        if tw then tw.Completed:Wait() end
                        task.wait(0.5)
                    end
                end
            end
            task.wait(1)
        end
    end)
end);

-- Farming Kill (Auto Kill NPC/Enemies)
FuncsV3:Toggle(FarmingSection, "Farming Kill", "Auto serang NPC/Guard di area pertempuran", false, function(value)
    farmKill = value
    task.spawn(function()
        while farmKill do
            for _, npc in pairs(Workspace:GetChildren()) do
                if not farmKill then break end
                if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                    if npc.Humanoid.Health > 0 and npc:FindFirstChild("HumanoidRootPart") then
                        local tw = tweenTo(npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        if tw then tw.Completed:Wait() end
                        -- Simulasi serangan
                        task.wait(0.3)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end);

-- Farming Player
FuncsV3:Toggle(FarmingSection, "Farming Player", "Teleport ke player musuh terdekat", false, function(value)
    farmPlayer = value
    task.spawn(function()
        while farmPlayer do
            for _, plr in pairs(Players:GetPlayers()) do
                if not farmPlayer then break end
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if plr.Character.Humanoid.Health > 0 then
                        local tw = tweenTo(plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                        if tw then tw.Completed:Wait() end
                        task.wait(1)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end);

-- Fitur Tambahan Game: Auto Capture Point
FuncsV3:Toggle(FarmingSection, "Auto Capture Point", "Rebut sektor/flag secara otomatis", false, function(value)
    autoCapture = value
    task.spawn(function()
        while autoCapture do
            local capturePoints = Workspace:FindFirstChild("CapturePoints") or Workspace:FindFirstChild("ControlPoints")
            if capturePoints then
                for _, point in pairs(capturePoints:GetChildren()) do
                    if not autoCapture then break end
                    local part = point:FindFirstChild("ClaimPart") or point:FindFirstChildOfClass("BasePart")
                    if part then
                        local tw = tweenTo(part.CFrame * CFrame.new(0, 3, 0))
                        if tw then tw.Completed:Wait() end
                        task.wait(3) -- Nunggu proses capture
                    end
                end
            end
            task.wait(1)
        end
    end)
end);

-- Fitur Tambahan Game: Auto Rebirth
FuncsV3:Toggle(FarmingSection, "Auto Rebirth", "Rebirth otomatis jika uang sudah mencukupi", false, function(value)
    autoRebirth = value
    task.spawn(function()
        while autoRebirth do
            local rebirthEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Rebirth", true)
            if rebirthEvent and rebirthEvent:IsA("RemoteEvent") then
                rebirthEvent:FireServer()
            end
            task.wait(5)
        end
    end)
end);

-- ==========================================
-- 2. PLAYER MENU
-- ==========================================
local PlayerSection = PlayerTab:AddSection("Movement & Player Mods", true);

-- WalkSpeed Textbox (Range 16 - 700)
FuncsV3:Textbox(PlayerSection, "Walk Speed", "Nilai Walkspeed (Normal - 700)", function(value)
    local num = tonumber(value)
    if num then
        walkSpeedVal = math.clamp(num, 16, 700)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedVal
        end
    end
end);

-- Infinite Jump
FuncsV3:Toggle(PlayerSection, "Infinite Jump", "Lompat tanpa batas di udara", false, function(value)
    infiniteJump = value
end);

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Fly Toggle
local bodyGyro, bodyVelocity
FuncsV3:Toggle(PlayerSection, "Fly", "Terbang bebas", false, function(value)
    isFlying = value
    local char = LocalPlayer.Character
    if isFlying and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = hrp.CFrame
        bodyGyro.Parent = hrp
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.velocity = Vector3.new(0, 0.1, 0)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Parent = hrp
        
        task.spawn(function()
            while isFlying and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                local camCF = Workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                bodyGyro.cframe = camCF
                bodyVelocity.velocity = moveDir * flySpeedVal
                RunService.RenderStepped:Wait()
            end
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end)
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end);

-- Speed Fly Textbox (Range 1 - 1100)
FuncsV3:Textbox(PlayerSection, "Speed Fly", "Kecepatan terbang (1 - 1100)", function(value)
    local num = tonumber(value)
    if num then
        flySpeedVal = math.clamp(num, 1, 1100)
    end
end);

-- Maintain WalkSpeed on Spawn
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").WalkSpeed = walkSpeedVal
end)

-- ==========================================
-- 3. SETTING MENU
-- ==========================================
local SettingSection = SettingTab:AddSection("Hub Configuration", true);

-- Tween Speed (Range 200 - 400)
FuncsV3:Textbox(SettingSection, "Tween Speed", "Kecepatan teleport (200 - 400)", function(value)
    local num = tonumber(value)
    if num then
        tweenSpeed = math.clamp(num, 200, 400)
    end
end);

-- Reset UI Button
FuncsV3:Button(SettingSection, "Reset UI", "Destroy & muat ulang UI", function()
    local coreGui = game:GetService("CoreGui")
    for _, gui in pairs(coreGui:GetChildren()) do
        if gui.Name:lower():match("speed") or gui.Name:lower():match("spin") then
            gui:Destroy()
        end
    end
end);
