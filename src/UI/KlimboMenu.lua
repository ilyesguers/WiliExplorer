--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ██╗  ██╗██╗     ██╗███╗   ███╗██████╗  ██████╗                       ║
    ║  ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗██╔═══██╗                      ║
    ║  █████╔╝ ██║     ██║██╔████╔██║██████╔╝██║   ██║                      ║
    ║  ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██╗██║   ██║                      ║
    ║  ██║  ██╗███████╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝                      ║
    ║  ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝                       ║
    ║                                                                        ║
    ║  🔥 KLIMBO MENU v1.0 - Ultimate Game Tools 🔥                         ║
    ║  Works on: Blox Fruits, Brookhaven, MM2, Adopt Me, & More!            ║
    ╚═══════════════════════════════════════════════════════════════════════╝
]]

local KlimboMenu = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 ثيم KLIMBO
-- ═══════════════════════════════════════════════════════════════════════
local Theme = {
    Primary = Color3.fromRGB(255, 0, 128),      -- وردي/فوشيا
    Secondary = Color3.fromRGB(0, 255, 255),    -- سماوي
    Accent = Color3.fromRGB(255, 215, 0),       -- ذهبي
    Dark = Color3.fromRGB(10, 10, 20),
    Darker = Color3.fromRGB(5, 5, 15),
    Card = Color3.fromRGB(20, 20, 40),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 المتغيرات العامة
-- ═══════════════════════════════════════════════════════════════════════
local ActiveFeatures = {
    ESP = false,
    Aimbot = false,
    Invisible = false,
    Noclip = false,
    InfiniteJump = false,
    Speed = false,
    Fly = false,
    AntiKick = false
}

local ESPObjects = {}
local AimbotTarget = nil
local ViewingPlayer = nil
local FlySpeed = 50
local WalkSpeedValue = 50

-- ═══════════════════════════════════════════════════════════════════════
-- 🛡️ ANTI-KICK SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local AntiKick = {}

function AntiKick.Enable()
    ActiveFeatures.AntiKick = true
    
    -- Hook kick function
    local mt = getrawmetatable(game)
    if setreadonly then setreadonly(mt, false) end
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" and ActiveFeatures.AntiKick then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    
    -- Alternative method
    pcall(function()
        for _, connection in pairs(getconnections(LocalPlayer.OnTeleport)) do
            if connection.Function then
                connection:Disable()
            end
        end
    end)
    
    print("🛡️ Anti-Kick Enabled!")
end

function AntiKick.Disable()
    ActiveFeatures.AntiKick = false
    print("🛡️ Anti-Kick Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👁️ ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local ESP = {}

function ESP.CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espData = {
        Highlight = nil,
        BillboardGui = nil,
        Tracer = nil
    }
    
    local function UpdateESP()
        if not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return end
        
        -- Highlight
        if not espData.Highlight or not espData.Highlight.Parent then
            espData.Highlight = Instance.new("Highlight")
            espData.Highlight.Name = "KlimboESP"
            espData.Highlight.FillTransparency = 0.5
            espData.Highlight.OutlineTransparency = 0
            espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            espData.Highlight.Adornee = player.Character
            espData.Highlight.Parent = player.Character
        end
        
        -- Team color
        local isEnemy = true
        if player.Team and LocalPlayer.Team then
            isEnemy = player.Team ~= LocalPlayer.Team
        end
        
        espData.Highlight.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        espData.Highlight.OutlineColor = isEnemy and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
        
        -- Name & Info Billboard
        if not espData.BillboardGui or not espData.BillboardGui.Parent then
            espData.BillboardGui = Instance.new("BillboardGui")
            espData.BillboardGui.Name = "KlimboInfo"
            espData.BillboardGui.Size = UDim2.new(0, 200, 0, 50)
            espData.BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
            espData.BillboardGui.AlwaysOnTop = true
            espData.BillboardGui.Adornee = hrp
            espData.BillboardGui.Parent = hrp
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            nameLabel.Parent = espData.BillboardGui
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Name = "InfoLabel"
            infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
            infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            infoLabel.TextSize = 11
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextStrokeTransparency = 0
            infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            infoLabel.Parent = espData.BillboardGui
        end
        
        -- Update info
        local distance = (hrp.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0))).Magnitude
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        
        espData.BillboardGui.NameLabel.Text = player.Name
        espData.BillboardGui.InfoLabel.Text = string.format("❤️ %d/%d | 📏 %dm", math.floor(health), math.floor(maxHealth), math.floor(distance))
        
        -- Health bar color
        local healthPercent = health / maxHealth
        if healthPercent > 0.5 then
            espData.BillboardGui.InfoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif healthPercent > 0.25 then
            espData.BillboardGui.InfoLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            espData.BillboardGui.InfoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    espData.Connection = RunService.RenderStepped:Connect(function()
        if ActiveFeatures.ESP then
            UpdateESP()
        end
    end)
    
    ESPObjects[player] = espData
end

function ESP.RemoveESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight then
            ESPObjects[player].Highlight:Destroy()
        end
        if ESPObjects[player].BillboardGui then
            ESPObjects[player].BillboardGui:Destroy()
        end
        if ESPObjects[player].Connection then
            ESPObjects[player].Connection:Disconnect()
        end
        ESPObjects[player] = nil
    end
end

function ESP.Enable()
    ActiveFeatures.ESP = true
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.CreateESP(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        if ActiveFeatures.ESP then
            task.wait(1)
            ESP.CreateESP(player)
        end
    end)
    
    print("👁️ ESP Enabled!")
end

function ESP.Disable()
    ActiveFeatures.ESP = false
    for player, _ in pairs(ESPObjects) do
        ESP.RemoveESP(player)
    end
    print("👁️ ESP Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 AIMBOT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local Aimbot = {}
Aimbot.FOV = 200
Aimbot.Smoothness = 0.5
Aimbot.TargetPart = "Head"

function Aimbot.GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Aimbot.FOV
    
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(Aimbot.TargetPart) or hrp
            
            if hrp and humanoid and humanoid.Health > 0 and targetPart then
                -- Check team
                local isEnemy = true
                if player.Team and LocalPlayer.Team then
                    isEnemy = player.Team ~= LocalPlayer.Team
                end
                
                if isEnemy then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function Aimbot.AimAt(player)
    if not player or not player.Character then return end
    local targetPart = player.Character:FindFirstChild(Aimbot.TargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, Aimbot.Smoothness)
end

function Aimbot.Enable()
    ActiveFeatures.Aimbot = true
    
    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        if ActiveFeatures.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = Aimbot.GetClosestPlayer()
            if target then
                Aimbot.AimAt(target)
            end
        end
    end)
    
    print("🎯 Aimbot Enabled! (Hold Right Click)")
end

function Aimbot.Disable()
    ActiveFeatures.Aimbot = false
    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
    end
    print("🎯 Aimbot Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👻 INVISIBILITY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local Invisibility = {}

function Invisibility.Enable()
    ActiveFeatures.Invisible = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Method 1: Local invisibility
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    
    -- Method 2: Destroy for others (Blox Fruits style)
    pcall(function()
        local fakeChar = char:Clone()
        fakeChar.Name = "FakeCharacter"
        fakeChar.Parent = Workspace
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Transparency = 1
        end
    end)
    
    print("👻 Invisibility Enabled!")
end

function Invisibility.Disable()
    ActiveFeatures.Invisible = false
    
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end
    
    -- Remove fake character
    pcall(function()
        local fake = Workspace:FindFirstChild("FakeCharacter")
        if fake then fake:Destroy() end
    end)
    
    print("👻 Invisibility Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📷 VIEW PLAYER CAMERA
-- ═══════════════════════════════════════════════════════════════════════
local ViewCamera = {}

function ViewCamera.ViewPlayer(player)
    if not player or not player.Character then return end
    
    ViewingPlayer = player
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Spectate mode
    Camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
    
    print("📷 Viewing: " .. player.Name)
end

function ViewCamera.StopViewing()
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    ViewingPlayer = nil
    print("📷 Stopped viewing")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔫 STEAL TOOL
-- ═══════════════════════════════════════════════════════════════════════
local StealTool = {}

function StealTool.StealFromPlayer(player)
    if not player or not player.Character then return end
    
    -- Check for equipped tool
    for _, child in ipairs(player.Character:GetChildren()) do
        if child:IsA("Tool") then
            pcall(function()
                -- Method 1: Direct parent change
                child.Parent = LocalPlayer.Backpack
                print("🔫 Stole: " .. child.Name .. " from " .. player.Name)
            end)
        end
    end
    
    -- Check backpack too
    if player:FindFirstChild("Backpack") then
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    tool.Parent = LocalPlayer.Backpack
                    print("🔫 Stole from backpack: " .. tool.Name)
                end)
            end
        end
    end
end

function StealTool.StealFromAll()
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            StealTool.StealFromPlayer(player)
            count = count + 1
        end
    end
    print("🔫 Attempted steal from " .. count .. " players")
end

-- ═══════════════════════════════════════════════════════════════════════
-- ❄️ FREEZE PLAYER
-- ═══════════════════════════════════════════════════════════════════════
local FreezePlayer = {}
FreezePlayer.FrozenPlayers = {}

function FreezePlayer.Freeze(player)
    if not player or not player.Character then return end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Try to anchor (may not work on server-side characters)
    pcall(function()
        hrp.Anchored = true
    end)
    
    -- Visual freeze effect
    local freezeEffect = Instance.new("Part")
    freezeEffect.Name = "KlimboFreeze"
    freezeEffect.Size = Vector3.new(5, 7, 5)
    freezeEffect.Position = hrp.Position
    freezeEffect.Anchored = true
    freezeEffect.CanCollide = false
    freezeEffect.Transparency = 0.5
    freezeEffect.BrickColor = BrickColor.new("Pastel light blue")
    freezeEffect.Material = Enum.Material.Ice
    freezeEffect.Parent = Workspace
    
    FreezePlayer.FrozenPlayers[player] = {hrp = hrp, effect = freezeEffect}
    
    print("❄️ Froze: " .. player.Name)
end

function FreezePlayer.Unfreeze(player)
    if FreezePlayer.FrozenPlayers[player] then
        pcall(function()
            FreezePlayer.FrozenPlayers[player].hrp.Anchored = false
        end)
        
        if FreezePlayer.FrozenPlayers[player].effect then
            FreezePlayer.FrozenPlayers[player].effect:Destroy()
        end
        
        FreezePlayer.FrozenPlayers[player] = nil
        print("❄️ Unfroze: " .. player.Name)
    end
end

function FreezePlayer.UnfreezeAll()
    for player, _ in pairs(FreezePlayer.FrozenPlayers) do
        FreezePlayer.Unfreeze(player)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📍 SAFE TELEPORT (Anti-Detection)
-- ═══════════════════════════════════════════════════════════════════════
local SafeTeleport = {}

function SafeTeleport.ToPosition(position)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Enable anti-kick first
    if not ActiveFeatures.AntiKick then
        AntiKick.Enable()
    end
    
    -- Smooth teleport (harder to detect)
    local distance = (hrp.Position - position).Magnitude
    local steps = math.max(5, math.floor(distance / 50))
    
    for i = 1, steps do
        local alpha = i / steps
        local newPos = hrp.Position:Lerp(position, alpha)
        hrp.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end
    
    hrp.CFrame = CFrame.new(position)
    print("📍 Teleported safely!")
end

function SafeTeleport.ToPlayer(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    SafeTeleport.ToPosition(hrp.Position + Vector3.new(5, 0, 0))
    print("📍 Teleported to: " .. player.Name)
end

function SafeTeleport.ToMouse()
    if Mouse.Hit then
        SafeTeleport.ToPosition(Mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 PLAYER MODS
-- ═══════════════════════════════════════════════════════════════════════
local PlayerMods = {}

function PlayerMods.SetSpeed(speed)
    WalkSpeedValue = speed
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
    
    -- Keep speed on respawn
    if not PlayerMods.SpeedConnection then
        PlayerMods.SpeedConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and ActiveFeatures.Speed then
                humanoid.WalkSpeed = WalkSpeedValue
            end
        end)
    end
    
    ActiveFeatures.Speed = true
    print("⚡ Speed set to: " .. speed)
end

function PlayerMods.SetJump(power)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
        end
    end
    print("🦘 Jump set to: " .. power)
end

function PlayerMods.InfiniteJump()
    ActiveFeatures.InfiniteJump = true
    
    PlayerMods.JumpConnection = UserInputService.JumpRequest:Connect(function()
        if ActiveFeatures.InfiniteJump then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    print("🦘 Infinite Jump Enabled!")
end

function PlayerMods.Noclip()
    ActiveFeatures.Noclip = true
    
    PlayerMods.NoclipConnection = RunService.Stepped:Connect(function()
        if ActiveFeatures.Noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    print("👻 Noclip Enabled!")
end

function PlayerMods.Fly()
    ActiveFeatures.Fly = true
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "KlimboFly"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "KlimboGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9000
    bodyGyro.Parent = hrp
    
    PlayerMods.FlyConnection = RunService.RenderStepped:Connect(function()
        if ActiveFeatures.Fly and hrp then
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = direction * FlySpeed
            bodyGyro.CFrame = Camera.CFrame
        end
    end)
    
    print("🚀 Fly Enabled! (Use WASD + Space/Ctrl)")
end

function PlayerMods.StopFly()
    ActiveFeatures.Fly = false
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("KlimboFly")
            local bg = hrp:FindFirstChild("KlimboGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
    
    if PlayerMods.FlyConnection then
        PlayerMods.FlyConnection:Disconnect()
    end
    
    print("🚀 Fly Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 GAME-SPECIFIC FEATURES (Blox Fruits, etc.)
-- ═══════════════════════════════════════════════════════════════════════
local GameSpecific = {}

function GameSpecific.DetectGame()
    local placeId = game.PlaceId
    local gameName = "Unknown"
    
    -- Blox Fruits
    if placeId == 2753915549 or placeId == 4442272183 then
        gameName = "Blox Fruits"
    -- Brookhaven
    elseif placeId == 4924922222 then
        gameName = "Brookhaven"
    -- Murder Mystery 2
    elseif placeId == 142823291 then
        gameName = "MM2"
    -- Adopt Me
    elseif placeId == 920587237 then
        gameName = "Adopt Me"
    -- Jailbreak
    elseif placeId == 606849621 then
        gameName = "Jailbreak"
    end
    
    return gameName, placeId
end

function GameSpecific.BloxFruitsFeatures()
    return {
        {name = "Auto Farm", callback = function() print("🍎 Auto Farm - Coming Soon!") end},
        {name = "Fruit ESP", callback = function() 
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:find("Fruit") or obj.Name:find("fruit") then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 255, 0)
                    h.Parent = obj
                end
            end
            print("🍎 Fruit ESP Enabled!")
        end},
        {name = "Chest ESP", callback = function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:find("Chest") then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 215, 0)
                    h.Parent = obj
                end
            end
            print("📦 Chest ESP Enabled!")
        end}
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖥️ CREATE KLIMBO MENU UI
-- ═══════════════════════════════════════════════════════════════════════
function KlimboMenu.Create(parent)
    local gameName, placeId = GameSpecific.DetectGame()
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "KlimboMenu"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Theme.Dark
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 100
    MainFrame.Parent = parent
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 40))
    })
    Gradient.Rotation = 135
    Gradient.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundColor3 = Theme.Darker
    Header.BorderSizePixel = 0
    Header.ZIndex = 101
    Header.Parent = MainFrame
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    })
    HeaderGradient.Transparency = NumberSequence.new(0.8)
    HeaderGradient.Parent = Header
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 35)
    Logo.Position = UDim2.new(0, 0, 0, 5)
    Logo.Text = "👑 KLIMBO MENU 👑"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 24
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.ZIndex = 102
    Logo.Parent = Header
    
    local GameLabel = Instance.new("TextLabel")
    GameLabel.Size = UDim2.new(1, 0, 0, 20)
    GameLabel.Position = UDim2.new(0, 0, 0, 42)
    GameLabel.Text = "🎮 " .. gameName .. " | ID: " .. placeId
    GameLabel.TextColor3 = Theme.TextDim
    GameLabel.TextSize = 12
    GameLabel.Font = Enum.Font.Gotham
    GameLabel.BackgroundTransparency = 1
    GameLabel.ZIndex = 102
    GameLabel.Parent = Header
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -90)
    Content.Position = UDim2.new(0, 10, 0, 80)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = Theme.Primary
    Content.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Content.ZIndex = 101
    Content.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Content
    
    -- ═══════════════════════════════
    -- دالة إنشاء زر
    -- ═══════════════════════════════
    local function CreateButton(name, icon, color, callback, isToggle)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -10, 0, 50)
        Btn.BackgroundColor3 = Theme.Card
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.ZIndex = 102
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = color
        BtnStroke.Thickness = 2
        BtnStroke.Transparency = 0.5
        BtnStroke.Parent = Btn
        
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 40, 0, 40)
        Icon.Position = UDim2.new(0, 10, 0.5, -20)
        Icon.Text = icon
        Icon.TextSize = 24
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 103
        Icon.Parent = Btn
        
        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -120, 1, 0)
        Name.Position = UDim2.new(0, 55, 0, 0)
        Name.Text = name
        Name.TextColor3 = Theme.Text
        Name.TextSize = 14
        Name.Font = Enum.Font.GothamBold
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Name.BackgroundTransparency = 1
        Name.ZIndex = 103
        Name.Parent = Btn
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(0, 50, 0, 25)
        Status.Position = UDim2.new(1, -60, 0.5, -12)
        Status.Text = isToggle and "OFF" or "▶"
        Status.TextColor3 = isToggle and Theme.Danger or color
        Status.TextSize = 12
        Status.Font = Enum.Font.GothamBold
        Status.BackgroundColor3 = Theme.Darker
        Status.ZIndex = 103
        Status.Parent = Btn
        Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 6)
        
        local isEnabled = false
        
        Btn.MouseButton1Click:Connect(function()
            if isToggle then
                isEnabled = not isEnabled
                Status.Text = isEnabled and "ON" or "OFF"
                Status.TextColor3 = isEnabled and Theme.Success or Theme.Danger
                BtnStroke.Transparency = isEnabled and 0 or 0.5
            end
            callback(isEnabled)
        end)
        
        -- Hover
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 60)}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Card}):Play()
        end)
        
        return Btn
    end
    
    local function CreateSection(name)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(1, -10, 0, 30)
        Section.Text = "━━━ " .. name .. " ━━━"
        Section.TextColor3 = Theme.Primary
        Section.TextSize = 14
        Section.Font = Enum.Font.GothamBold
        Section.BackgroundTransparency = 1
        Section.ZIndex = 102
        Section.Parent = Content
        return Section
    end
    
    -- ═══════════════════════════════
    -- الأزرار
    -- ═══════════════════════════════
    
    CreateSection("👁️ VISUALS")
    
    CreateButton("ESP (Player)", "👁️", Theme.Primary, function(enabled)
        if enabled then ESP.Enable() else ESP.Disable() end
    end, true)
    
    CreateButton("Aimbot", "🎯", Theme.Danger, function(enabled)
        if enabled then Aimbot.Enable() else Aimbot.Disable() end
    end, true)
    
    CreateSection("👻 PLAYER")
    
    CreateButton("Invisibility", "👻", Theme.Secondary, function(enabled)
        if enabled then Invisibility.Enable() else Invisibility.Disable() end
    end, true)
    
    CreateButton("Noclip", "🚪", Color3.fromRGB(150, 100, 255), function(enabled)
        if enabled then 
            PlayerMods.Noclip() 
        else 
            ActiveFeatures.Noclip = false
            if PlayerMods.NoclipConnection then PlayerMods.NoclipConnection:Disconnect() end
        end
    end, true)
    
    CreateButton("Fly", "🚀", Color3.fromRGB(100, 200, 255), function(enabled)
        if enabled then PlayerMods.Fly() else PlayerMods.StopFly() end
    end, true)
    
    CreateButton("Infinite Jump", "🦘", Color3.fromRGB(255, 200, 100), function(enabled)
        if enabled then 
            PlayerMods.InfiniteJump() 
        else 
            ActiveFeatures.InfiniteJump = false
            if PlayerMods.JumpConnection then PlayerMods.JumpConnection:Disconnect() end
        end
    end, true)
    
    CreateButton("Speed x3", "⚡", Theme.Accent, function()
        PlayerMods.SetSpeed(48)
    end, false)
    
    CreateButton("Speed x5", "⚡⚡", Theme.Accent, function()
        PlayerMods.SetSpeed(80)
    end, false)
    
    CreateSection("🎮 PLAYERS")
    
    CreateButton("View Player Camera", "📷", Color3.fromRGB(100, 150, 255), function()
        -- سيتم إضافة قائمة اللاعبين
        local players = Players:GetPlayers()
        if #players > 1 then
            for _, p in ipairs(players) do
                if p ~= LocalPlayer then
                    ViewCamera.ViewPlayer(p)
                    break
                end
            end
        end
    end, false)
    
    CreateButton("Stop Viewing", "📷❌", Color3.fromRGB(100, 100, 150), function()
        ViewCamera.StopViewing()
    end, false)
    
    CreateButton("Steal All Tools", "🔫", Theme.Danger, function()
        StealTool.StealFromAll()
    end, false)
    
    CreateButton("Freeze Nearest", "❄️", Color3.fromRGB(100, 200, 255), function()
        local nearest = nil
        local minDist = math.huge
        local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
        
        if myPos then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - myPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = p
                        end
                    end
                end
            end
            
            if nearest then
                FreezePlayer.Freeze(nearest)
            end
        end
    end, false)
    
    CreateButton("Unfreeze All", "❄️✅", Color3.fromRGB(100, 255, 200), function()
        FreezePlayer.UnfreezeAll()
    end, false)
    
    CreateSection("📍 TELEPORT")
    
    CreateButton("TP to Mouse (Click)", "🖱️", Theme.Success, function()
        SafeTeleport.ToMouse()
    end, false)
    
    CreateButton("TP to Random Player", "👤", Color3.fromRGB(200, 150, 255), function()
        local players = Players:GetPlayers()
        local otherPlayers = {}
        for _, p in ipairs(players) do
            if p ~= LocalPlayer then
                table.insert(otherPlayers, p)
            end
        end
        if #otherPlayers > 0 then
            local random = otherPlayers[math.random(1, #otherPlayers)]
            SafeTeleport.ToPlayer(random)
        end
    end, false)
    
    CreateSection("🛡️ PROTECTION")
    
    CreateButton("Anti-Kick", "🛡️", Theme.Success, function(enabled)
        if enabled then AntiKick.Enable() else AntiKick.Disable() end
    end, true)
    
    -- Game specific
    if gameName == "Blox Fruits" then
        CreateSection("🍎 BLOX FRUITS")
        
        local bfFeatures = GameSpecific.BloxFruitsFeatures()
        for _, feature in ipairs(bfFeatures) do
            CreateButton(feature.name, "🍎", Color3.fromRGB(255, 100, 100), feature.callback, false)
        end
    end
    
    return MainFrame
end

return KlimboMenu
