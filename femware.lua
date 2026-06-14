-- =============================================
-- 🔥 FEMWARE ULTIMATE v4.2 (SAFE EDITION)
-- Developed by FEMWARE CORPORATION
-- For Forsaken / Delta / Xeno / Executors
-- =============================================
-- Версия с оптимизациями по замечаниям Gemini:
-- - Скорость фиксированная (24), без дёрганья.
-- - Радиус автофарма уменьшен до 20 (чтобы не банили).
-- - ESP стабильный, не жрёт ресурсы.
-- =============================================

repeat task.wait() until game:IsLoaded()
local plr = game.Players.LocalPlayer
if _G.FemwareLoaded then return end
_G.FemwareLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local char = plr.Character or plr.CharacterAdded:Wait()
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
end)

-- 🔹 Бесконечная стамина (адаптивная под Xeno)
task.spawn(function()
    while true do
        task.wait(0.3)
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local stamina = hum:FindFirstChild("Stamina") or hum:FindFirstChild("StaminaValue") or hum:FindFirstChild("_stamina")
                if stamina then stamina.Value = 100 end
            end
        end
    end
end)

-- 🔹 Fly (F) + Noclip (G) с защитой от чата
local flying, noclip = false, false
local bodyVel, speed = nil, 50

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        flying = not flying
        if flying then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bodyVel.Velocity = Vector3.new(0, 0, 0)
                bodyVel.Parent = hrp
                hum.PlatformStand = true
                
                task.spawn(function()
                    while flying and char and hrp and bodyVel and bodyVel.Parent do
                        task.wait()
                        local move = Vector3.new(
                            (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or (UIS:IsKeyDown(Enum.KeyCode.A) and -1 or 0)),
                            (UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0)),
                            (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or (UIS:IsKeyDown(Enum.KeyCode.S) and -1 or 0))
                        )
                        bodyVel.Velocity = (hrp.CFrame.RightVector * move.X + Vector3.new(0, move.Y, 0) + hrp.CFrame.LookVector * move.Z) * speed
                    end
                end)
            end
        else
            if bodyVel then bodyVel:Destroy() end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        
    elseif input.KeyCode == Enum.KeyCode.G then
        noclip = not noclip
    end
end)

RunService.Stepped:Connect(function()
    if noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then 
                part.CanCollide = false 
            end
        end
    end
end)

-- 🔹 РАСШИРЕННЫЙ ESP (Имя, роль, дистанция, класс)
local espList = {}
local function getRole(player)
    local character = player.Character
    if character then
        if character:FindFirstChild("Killer") or character:FindFirstChild("Murderer") or character:FindFirstChild("Jason") then
            return "🔪 KILLER"
        elseif character:FindFirstChild("Survivor") or character:FindFirstChild("Victim") then
            return "🛡️ SURVIVOR"
        end
    end
    return "❓ UNKNOWN"
end

local function getClass(player)
    local character = player.Character
    if character then
        for _, v in pairs(character:GetChildren()) do
            if v:IsA("Tool") or v:IsA("Accessory") then
                return "🪦 " .. v.Name
            end
        end
    end
    return "⚠️ NO CLASS"
end

local function createAdvancedESP(p)
    if p == plr then return end
    
    p.CharacterAdded:Connect(function(newCharacter)
        task.wait(1)
        if espList[p] then espList[p]:Destroy() end
        
        local bill = Instance.new("BillboardGui")
        bill.Name = "FemwareESP"
        bill.Size = UDim2.new(0, 250, 0, 80)
        bill.AlwaysOnTop = true
        bill.Adornee = newCharacter
        
        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255, 20, 147)
        txt.TextScaled = false
        txt.TextWrapped = true
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        
        local hrpPlr = char and char:FindFirstChild("HumanoidRootPart")
        task.spawn(function()
            while bill and bill.Parent do
                task.wait(0.5)
                local characterESP = p.Character
                local hrpTarget = characterESP and characterESP:FindFirstChild("HumanoidRootPart")
                if characterESP and hrpTarget and hrpPlr then
                    local distance = (hrpPlr.Position - hrpTarget.Position).Magnitude
                    local role = getRole(p)
                    local class = getClass(p)
                    txt.Text = string.format("👤 %s\n📏 %.0fм\n%s\n%s", p.Name, distance, role, class)
                else
                    txt.Text = string.format("👤 %s\n❓ OFFLINE", p.Name)
                end
            end
        end)
        
        bill.Parent = newCharacter
        espList[p] = bill
    end)
end

Players.PlayerAdded:Connect(createAdvancedESP)
Players.PlayerRemoving:Connect(function(p)
    if espList[p] then
        espList[p]:Destroy()
        espList[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    createAdvancedESP(p)
    if p ~= plr and p.Character then
        local bill = Instance.new("BillboardGui")
        bill.Name = "FemwareESP"
        bill.Size = UDim2.new(0, 250, 0, 80)
        bill.AlwaysOnTop = true
        bill.Adornee = p.Character
        
        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255, 20, 147)
        txt.TextScaled = false
        txt.TextWrapped = true
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        
        local hrpPlr = char and char:FindFirstChild("HumanoidRootPart")
        task.spawn(function()
            while bill and bill.Parent do
                task.wait(0.5)
                local characterESP = p.Character
                local hrpTarget = characterESP and characterESP:FindFirstChild("HumanoidRootPart")
                if characterESP and hrpTarget and hrpPlr then
                    local distance = (hrpPlr.Position - hrpTarget.Position).Magnitude
                    local role = getRole(p)
                    local class = getClass(p)
                    txt.Text = string.format("👤 %s\n📏 %.0fм\n%s\n%s", p.Name, distance, role, class)
                else
                    txt.Text = string.format("👤 %s\n❓ OFFLINE", p.Name)
                end
            end
        end)
        
        bill.Parent = p.Character
        espList[p] = bill
    end
end

-- 🔹 Скорость (фиксированная 24, безопасная)
local currentSpeed = 24
RunService.RenderStepped:Connect(function()
    if char and char:FindFirstChildOfClass("Humanoid") then
        char:FindFirstChildOfClass("Humanoid").WalkSpeed = currentSpeed
    end
end)

-- 🔹 Anti-AFK
local vu = game:GetService("VirtualUser")
plr.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- 🔹 Безопасный AutoFarm (радиус 20, а не 100)
task.spawn(function()
    while true do
        task.wait(5)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local generators = {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Generator" and v:FindFirstChild("ProximityPrompt") then
                    table.insert(generators, v)
                end
            end
            
            for _, gen in pairs(generators) do
                local prompt = gen.ProximityPrompt
                if (hrp.Position - gen.Position).Magnitude <= 20 then
                    prompt:InputHoldBegin()
                    task.wait(1.5)
                    if prompt and prompt.Parent then
                        prompt:InputHoldEnd()
                    end
                    task.wait(1.5)
                end
            end
        end
    end
end)

-- 🔹 GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FemwareUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 280)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.2
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderColor3 = Color3.fromRGB(255, 20, 147)
frame.BorderSizePixel = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🔥 FEMWARE v4.2 (SAFE)"
title.TextColor3 = Color3.fromRGB(255, 20, 147)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

local list = Instance.new("TextLabel", frame)
list.Size = UDim2.new(1, 0, 0, 240)
list.Position = UDim2.new(0, 0, 0, 35)
list.Text = "✅ Fly [F]\n✅ Noclip [G]\n✅ ESP (Name + Role + Distance + Class)\n✅ Speed (24 fixed)\n✅ Anti-AFK\n✅ Safe Auto Farm (radius 20)"
list.TextColor3 = Color3.fromRGB(200, 200, 200)
list.TextXAlignment = Enum.TextXAlignment.Left
list.BackgroundTransparency = 1
list.TextSize = 13

gui.Parent = CoreGui

print("FEMWARE CORPORATION v4.2 — Loaded successfully. Nevermore is watching ^_^")