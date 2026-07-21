--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ██╗  ██╗██╗     ██╗███╗   ███╗██████╗  ██████╗                       ║
    ║  ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗██╔═══██╗                      ║
    ║  █████╔╝ ██║     ██║██╔████╔██║██████╔╝██║   ██║                      ║
    ║  ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██╗██║   ██║                      ║
    ║  ██║  ██╗███████╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝                      ║
    ║  ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝                       ║
    ║                                                                        ║
    ║  🔥 KLIMBO MENU v2.0 - Ultimate Game Tools 🔥                         ║
    ║  ✅ Fixed: ZIndex rendering issue                                      ║
    ║  ✅ Fixed: UI visibility after load                                    ║
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
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(0, 255, 255),
    Accent = Color3.fromRGB(255, 215, 0),
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
    
    pcall(function()
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
    end)
    
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
        Connection = nil
    }
    
    local function UpdateESP()
        if not ActiveFeatures.ESP then return end
        if not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not hrp or not humanoid then return end
        
        if not espData.Highlight or not espData.Highlight.Parent then
            espData.Highlight = Instance.new("Highlight")
            espData.Highlight.Name = "KlimboESP"
            espData.Highlight.FillTransparency = 0.5
            espData.Highlight.OutlineTransparency = 0
            espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            espData.Highlight.Adornee = player.Character
            espData.Highlight.Parent = player.Character
        end
        
        local isEnemy = true
        if player.Team and LocalPlayer.Team then
            isEnemy = player.Team ~= LocalPlayer.Team
        end
        
        espData.Highlight.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        espData.Highlight.OutlineColor = isEnemy and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
        
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
        
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local distance = myHRP and (hrp.Position - myHRP.Position).Magnitude or 0
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        
        espData.BillboardGui.NameLabel.Text = player.Name
        espData.BillboardGui.InfoLabel.Text = string.format("❤️ %d/%d | 📏 %dm", math.floor(health), math.floor(maxHealth), math.floor(distance))
        
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
            pcall(UpdateESP)
        end
    end)
    
    ESPObjects[player] = espData
end

function ESP.RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end end)
        pcall(function() if ESPObjects[player].BillboardGui then ESPObjects[player].BillboardGui:Destroy() end end)
        pcall(function() if ESPObjects[player].Connection then ESPObjects[player].Connection:Disconnect() end end)
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
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    
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
    
    print("👻 Invisibility Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📷 VIEW PLAYER CAMERA
-- ═══════════════════════════════════════════════════════════════════════
local ViewCamera = {}

function ViewCamera.ViewPlayer(player)
    if not player or not player.Character then return end
    ViewingPlayer = player
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
    
    for _, child in ipairs(player.Character:GetChildren()) do
        if child:IsA("Tool") then
            pcall(function()
                child.Parent = LocalPlayer.Backpack
                print("🔫 Stole: " .. child.Name)
            end)
        end
    end
    
    if player:FindFirstChild("Backpack") then
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    tool.Parent = LocalPlayer.Backpack
                end)
            end
        end
    end
end

function StealTool.StealFromAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            StealTool.StealFromPlayer(player)
        end
    end
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
    
    pcall(function() hrp.Anchored = true end)
    
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
        pcall(function() FreezePlayer.FrozenPlayers[player].hrp.Anchored = false end)
        if FreezePlayer.FrozenPlayers[player].effect then
            FreezePlayer.FrozenPlayers[player].effect:Destroy()
        end
        FreezePlayer.FrozenPlayers[player] = nil
    end
end

function FreezePlayer.UnfreezeAll()
    for player, _ in pairs(FreezePlayer.FrozenPlayers) do
        FreezePlayer.Unfreeze(player)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📍 SAFE TELEPORT
-- ═══════════════════════════════════════════════════════════════════════
local SafeTeleport = {}

function SafeTeleport.ToPosition(position)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not ActiveFeatures.AntiKick then AntiKick.Enable() end
    
    local distance = (hrp.Position - position).Magnitude
    local steps = math.max(5, math.floor(distance / 50))
    
    for i = 1, steps do
        local alpha = i / steps
        local newPos = hrp.Position:Lerp(position, alpha)
        hrp.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end
    
    hrp.CFrame = CFrame.new(position)
    print("📍 Teleported!")
end

function SafeTeleport.ToPlayer(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    SafeTeleport.ToPosition(hrp.Position + Vector3.new(5, 0, 0))
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
        if humanoid then humanoid.WalkSpeed = speed end
    end
    
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
    print("⚡ Speed: " .. speed)
end

function PlayerMods.SetJump(power)
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.JumpPower = power end
    end
end

function PlayerMods.InfiniteJump()
    ActiveFeatures.InfiniteJump = true
    PlayerMods.JumpConnection = UserInputService.JumpRequest:Connect(function()
        if ActiveFeatures.InfiniteJump then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
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
                    if part:IsA("BasePart") then part.CanCollide = false end
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
        if ActiveFeatures.Fly and hrp and hrp.Parent then
            local direction = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
            
            bodyVelocity.Velocity = direction * FlySpeed
            bodyGyro.CFrame = Camera.CFrame
        end
    end)
    
    print("🚀 Fly Enabled!")
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
    if PlayerMods.FlyConnection then PlayerMods.FlyConnection:Disconnect() end
    print("🚀 Fly Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 GAME DETECTION
-- ═══════════════════════════════════════════════════════════════════════
local GameSpecific = {}

function GameSpecific.DetectGame()
    local placeId = game.PlaceId
    local gameName = "Unknown"
    
    if placeId == 2753915549 or placeId == 4442272183 then
        gameName = "Blox Fruits"
    elseif placeId == 4924922222 then
        gameName = "Brookhaven"
    elseif placeId == 142823291 then
        gameName = "MM2"
    elseif placeId == 920587237 then
        gameName = "Adopt Me"
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

-- ═══════════════════════════════════════════════════════════════════════════
-- 🖥️ CREATE KLIMBO MENU UI (الإصلاح الرئيسي)
-- ═══════════════════════════════════════════════════════════════════════════
function KlimboMenu.Create(parent)
    if not parent then
        warn("❌ KlimboMenu.Create: parent is nil!")
        return nil
    end
    
    local gameName, placeId = GameSpecific.DetectGame()
    
    -- ═══════════════════════════════════════════════════════════════════
    -- 🔧 الإصلاح: ZIndex الأساسي = 51 (أعلى من KlimboContainer الذي = 50)
    -- ═══════════════════════════════════════════════════════════════════
    local BASE_ZINDEX = 51
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "KlimboMenu"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Theme.Dark
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = BASE_ZINDEX
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
    Header.Size = UDim2.new(1, 0, 0, 65)
    Header.BackgroundColor3 = Theme.Darker
    Header.BorderSizePixel = 0
    Header.ZIndex = BASE_ZINDEX + 1
    Header.Parent = MainFrame
    
    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    })
    HeaderGradient.Transparency = NumberSequence.new(0.8)
    HeaderGradient.Parent = Header
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 32)
    Logo.Position = UDim2.new(0, 0, 0, 5)
    Logo.Text = "👑 KLIMBO MENU 👑"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 22
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.ZIndex = BASE_ZINDEX + 2
    Logo.Parent = Header
    
    local GameLabel = Instance.new("TextLabel")
    GameLabel.Size = UDim2.new(1, 0, 0, 18)
    GameLabel.Position = UDim2.new(0, 0, 0, 38)
    GameLabel.Text = "🎮 " .. gameName .. " | ID: " .. placeId
    GameLabel.TextColor3 = Theme.TextDim
    GameLabel.TextSize = 11
    GameLabel.Font = Enum.Font.Gotham
    GameLabel.BackgroundTransparency = 1
    GameLabel.ZIndex = BASE_ZINDEX + 2
    GameLabel.Parent = Header
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -16, 1, -80)
    Content.Position = UDim2.new(0, 8, 0, 72)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = Theme.Primary
    Content.CanvasSize = UDim2.new(0, 0, 0, 1200)
    Content.ZIndex = BASE_ZINDEX + 1
    Content.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Content
    
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingLeft = UDim.new(0, 4)
    ContentPad.PaddingRight = UDim.new(0, 4)
    ContentPad.PaddingTop = UDim.new(0, 4)
    ContentPad.Parent = Content
    
    -- ═══════════════════════════════════════════════════════════════════
    -- دوال إنشاء العناصر
    -- ═══════════════════════════════════════════════════════════════════
    local function CreateButton(name, icon, color, callback, isToggle)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -8, 0, 48)
        Btn.BackgroundColor3 = Theme.Card
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.ZIndex = BASE_ZINDEX + 2
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = color
        BtnStroke.Thickness = 1.5
        BtnStroke.Transparency = 0.5
        BtnStroke.Parent = Btn
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 38, 0, 38)
        IconLbl.Position = UDim2.new(0, 8, 0.5, -19)
        IconLbl.Text = icon
        IconLbl.TextSize = 22
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = BASE_ZINDEX + 3
        IconLbl.Parent = Btn
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -115, 1, 0)
        NameLbl.Position = UDim2.new(0, 50, 0, 0)
        NameLbl.Text = name
        NameLbl.TextColor3 = Theme.Text
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = BASE_ZINDEX + 3
        NameLbl.Parent = Btn
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(0, 48, 0, 24)
        Status.Position = UDim2.new(1, -56, 0.5, -12)
        Status.Text = isToggle and "OFF" or "▶"
        Status.TextColor3 = isToggle and Theme.Danger or color
        Status.TextSize = 11
        Status.Font = Enum.Font.GothamBold
        Status.BackgroundColor3 = Theme.Darker
        Status.ZIndex = BASE_ZINDEX + 3
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
        
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 60)}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
        end)
        
        return Btn
    end
    
    local function CreateSection(name)
        local Section = Instance.new("TextLabel")
        Section.Size = UDim2.new(1, -8, 0, 28)
        Section.Text = "━━━ " .. name .. " ━━━"
        Section.TextColor3 = Theme.Primary
        Section.TextSize = 13
        Section.Font = Enum.Font.GothamBold
        Section.BackgroundTransparency = 1
        Section.ZIndex = BASE_ZINDEX + 2
        Section.Parent = Content
        return Section
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- الأزرار
    -- ═══════════════════════════════════════════════════════════════════
    
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
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                ViewCamera.ViewPlayer(p)
                break
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
            if nearest then FreezePlayer.Freeze(nearest) end
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
        local otherPlayers = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(otherPlayers, p) end
        end
        if #otherPlayers > 0 then
            SafeTeleport.ToPlayer(otherPlayers[math.random(1, #otherPlayers)])
        end
    end, false)
    
    CreateSection("🛡️ PROTECTION")
    
    CreateButton("Anti-Kick", "🛡️", Theme.Success, function(enabled)
        if enabled then AntiKick.Enable() else AntiKick.Disable() end
    end, true)
    
    -- Game specific
    if gameName == "Blox Fruits" then
        CreateSection("🍎 BLOX FRUITS")
        for _, feature in ipairs(GameSpecific.BloxFruitsFeatures()) do
            CreateButton(feature.name, "🍎", Color3.fromRGB(255, 100, 100), feature.callback, false)
        end
    end
    
    -- Update canvas size
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    
    print("✅ KlimboMenu UI created with " .. #Content:GetChildren() .. " elements")
    
    return MainFrame
end

return KlimboMenu
