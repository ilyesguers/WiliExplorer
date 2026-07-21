--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ██╗  ██╗██╗     ██╗███╗   ███╗██████╗  ██████╗                       ║
    ║  ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗██╔═══██╗                      ║
    ║  █████╔╝ ██║     ██║██╔████╔██║██████╔╝██║   ██║                      ║
    ║  ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██╗██║   ██║                      ║
    ║  ██║  ██╗███████╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝                      ║
    ║  ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝                       ║
    ║                                                                        ║
    ║  🔥 KLIMBO MENU v3.0 - Ultimate Game Tools 🔥                         ║
    ║  ✅ Fixed: Aimbot (Screen Center Lock)                                 ║
    ║  ✅ Fixed: Fly System                                                  ║
    ║  ✅ Fixed: Steal Tools                                                 ║
    ║  ✅ New: ESP Options Menu                                              ║
    ║  ✅ New: Speed/Jump Slider                                             ║
    ║  ✅ New: NPC Control                                                   ║
    ║  ✅ New: Disable All Button                                            ║
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
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 ثيم KLIMBO الفضائي
-- ═══════════════════════════════════════════════════════════════════════
local Theme = {
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(0, 255, 255),
    Accent = Color3.fromRGB(255, 215, 0),
    Purple = Color3.fromRGB(138, 43, 226),
    Dark = Color3.fromRGB(10, 10, 20),
    Darker = Color3.fromRGB(5, 5, 15),
    Card = Color3.fromRGB(18, 18, 38),
    CardHover = Color3.fromRGB(28, 28, 55),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 المتغيرات العامة
-- ═══════════════════════════════════════════════════════════════════════
local ActiveFeatures = {
    ESP = false,
    ESP_Box = false,
    ESP_Name = false,
    ESP_Health = false,
    ESP_Distance = false,
    ESP_Tracer = false,
    ESP_Highlight = false,
    Aimbot = false,
    AimbotTeam = false,
    Invisible = false,
    Noclip = false,
    InfiniteJump = false,
    Speed = false,
    Fly = false,
    AntiKick = false,
    GodMode = false,
    AutoJump = false,
    SpinBot = false,
    BigHead = false,
    TinyCharacter = false,
    NoFog = false,
    FullBright = false,
    XRay = false
}

local ESPObjects = {}
local Connections = {}
local FlySpeed = 50
local WalkSpeedValue = 16
local JumpPowerValue = 50
local AimbotFOV = 200
local AimbotSmoothness = 0.5
local AimbotTargetPart = "Head"
local NPCControlTarget = nil

-- ═══════════════════════════════════════════════════════════════════════
-- 🛡️ UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════
local function SafeConnect(event, callback)
    local conn = event:Connect(callback)
    table.insert(Connections, conn)
    return conn
end

local function DisconnectAll()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function GetHRP()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Klimbo",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

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
        
        if setreadonly then setreadonly(mt, true) end
    end)
    
    pcall(function()
        for _, connection in pairs(getconnections(LocalPlayer.OnTeleport)) do
            if connection.Function then connection:Disable() end
        end
    end)
    
    Notify("🛡️ Anti-Kick", "Enabled!")
end

function AntiKick.Disable()
    ActiveFeatures.AntiKick = false
    Notify("🛡️ Anti-Kick", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👁️ ESP SYSTEM (متقدم مع خيارات)
-- ═══════════════════════════════════════════════════════════════════════
local ESP = {}

function ESP.CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espData = {
        Highlight = nil,
        BillboardGui = nil,
        Tracer = nil,
        Box = nil,
        Connection = nil
    }
    
    local function UpdateESP()
        if not ActiveFeatures.ESP then return end
        if not player.Character then return end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        if not hrp or not humanoid then return end
        
        -- Highlight
        if ActiveFeatures.ESP_Highlight then
            if not espData.Highlight or not espData.Highlight.Parent then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = "KlimboESP"
                espData.Highlight.FillTransparency = 0.5
                espData.Highlight.OutlineTransparency = 0
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Parent = player.Character
            end
            
            local isEnemy = true
            if player.Team and LocalPlayer.Team then
                isEnemy = player.Team ~= LocalPlayer.Team
            end
            
            espData.Highlight.Adornee = player.Character
            espData.Highlight.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
            espData.Highlight.OutlineColor = isEnemy and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
        elseif espData.Highlight then
            espData.Highlight:Destroy()
            espData.Highlight = nil
        end
        
        -- Billboard (Name, Health, Distance)
        if ActiveFeatures.ESP_Name or ActiveFeatures.ESP_Health or ActiveFeatures.ESP_Distance then
            if not espData.BillboardGui or not espData.BillboardGui.Parent then
                local adorneePart = head or hrp
                
                espData.BillboardGui = Instance.new("BillboardGui")
                espData.BillboardGui.Name = "KlimboInfo"
                espData.BillboardGui.Size = UDim2.new(0, 200, 0, 60)
                espData.BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                espData.BillboardGui.AlwaysOnTop = true
                espData.BillboardGui.Adornee = adorneePart
                espData.BillboardGui.Parent = adorneePart
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                nameLabel.Parent = espData.BillboardGui
                
                local infoLabel = Instance.new("TextLabel")
                infoLabel.Name = "InfoLabel"
                infoLabel.Size = UDim2.new(1, 0, 0.3, 0)
                infoLabel.Position = UDim2.new(0, 0, 0.4, 0)
                infoLabel.BackgroundTransparency = 1
                infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                infoLabel.TextSize = 11
                infoLabel.Font = Enum.Font.Gotham
                infoLabel.TextStrokeTransparency = 0
                infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                infoLabel.Parent = espData.BillboardGui
                
                local healthLabel = Instance.new("TextLabel")
                healthLabel.Name = "HealthLabel"
                healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
                healthLabel.Position = UDim2.new(0, 0, 0.7, 0)
                healthLabel.BackgroundTransparency = 1
                healthLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                healthLabel.TextSize = 11
                healthLabel.Font = Enum.Font.Gotham
                healthLabel.TextStrokeTransparency = 0
                healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                healthLabel.Parent = espData.BillboardGui
            end
            
            local myHRP = GetHRP()
            local distance = myHRP and math.floor((hrp.Position - myHRP.Position).Magnitude) or 0
            local health = math.floor(humanoid.Health)
            local maxHealth = math.floor(humanoid.MaxHealth)
            
            if ActiveFeatures.ESP_Name then
                espData.BillboardGui.NameLabel.Text = player.Name
                espData.BillboardGui.NameLabel.Visible = true
            else
                espData.BillboardGui.NameLabel.Visible = false
            end
            
            local infoText = ""
            if ActiveFeatures.ESP_Distance then
                infoText = infoText .. "📏 " .. distance .. "m"
            end
            if ActiveFeatures.ESP_Health then
                if infoText ~= "" then infoText = infoText .. " | " end
                infoText = infoText .. "❤️ " .. health .. "/" .. maxHealth
            end
            espData.BillboardGui.InfoLabel.Text = infoText
            espData.BillboardGui.InfoLabel.Visible = (infoText ~= "")
            
            local healthPercent = health / maxHealth
            if healthPercent > 0.5 then
                espData.BillboardGui.HealthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif healthPercent > 0.25 then
                espData.BillboardGui.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            else
                espData.BillboardGui.HealthLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
            espData.BillboardGui.HealthLabel.Visible = false
        elseif espData.BillboardGui then
            espData.BillboardGui:Destroy()
            espData.BillboardGui = nil
        end
        
        -- Tracer (خط منك للاعب)
        if ActiveFeatures.ESP_Tracer then
            if not espData.Tracer then
                espData.Tracer = Drawing and Drawing.new("Line")
                if espData.Tracer then
                    espData.Tracer.Thickness = 2
                    espData.Tracer.Color = Color3.fromRGB(255, 0, 0)
                    espData.Tracer.Transparency = 0.7
                end
            end
            
            if espData.Tracer and Drawing then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    espData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espData.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    espData.Tracer.Visible = true
                else
                    espData.Tracer.Visible = false
                end
            end
        elseif espData.Tracer then
            espData.Tracer.Visible = false
        end
    end
    
    espData.Connection = SafeConnect(RunService.RenderStepped, function()
        pcall(UpdateESP)
    end)
    
    ESPObjects[player] = espData
end

function ESP.RemoveESP(player)
    if ESPObjects[player] then
        pcall(function() if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end end)
        pcall(function() if ESPObjects[player].BillboardGui then ESPObjects[player].BillboardGui:Destroy() end end)
        pcall(function() if ESPObjects[player].Tracer then ESPObjects[player].Tracer.Visible = false end end)
        pcall(function() if ESPObjects[player].Connection then ESPObjects[player].Connection:Disconnect() end end)
        ESPObjects[player] = nil
    end
end

function ESP.Enable()
    ActiveFeatures.ESP = true
    ActiveFeatures.ESP_Highlight = true
    ActiveFeatures.ESP_Name = true
    ActiveFeatures.ESP_Health = true
    ActiveFeatures.ESP_Distance = true
    
    for _, player in ipairs(Players:GetPlayers()) do
        ESP.CreateESP(player)
    end
    
    SafeConnect(Players.PlayerAdded, function(player)
        task.wait(1)
        if ActiveFeatures.ESP then ESP.CreateESP(player) end
    end)
    
    SafeConnect(Players.PlayerRemoving, function(player)
        ESP.RemoveESP(player)
    end)
    
    Notify("👁️ ESP", "Enabled!")
end

function ESP.Disable()
    ActiveFeatures.ESP = false
    ActiveFeatures.ESP_Box = false
    ActiveFeatures.ESP_Name = false
    ActiveFeatures.ESP_Health = false
    ActiveFeatures.ESP_Distance = false
    ActiveFeatures.ESP_Tracer = false
    ActiveFeatures.ESP_Highlight = false
    
    for player, _ in pairs(ESPObjects) do
        ESP.RemoveESP(player)
    end
    Notify("👁️ ESP", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 AIMBOT SYSTEM (مُصلح - يوجه منتصف الشاشة)
-- ═══════════════════════════════════════════════════════════════════════
local Aimbot = {}

function Aimbot.GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotFOV
    
    local screenSize = Camera.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            local targetPart = char:FindFirstChild(AimbotTargetPart) or hrp
            
            if hrp and humanoid and humanoid.Health > 0 and targetPart then
                -- فحص الفريق
                if not ActiveFeatures.AimbotTeam then
                    local isEnemy = true
                    if player.Team and LocalPlayer.Team then
                        isEnemy = player.Team ~= LocalPlayer.Team
                    end
                    if not isEnemy then continue end
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function Aimbot.AimAt(player)
    if not player or not player.Character then return end
    local targetPart = player.Character:FindFirstChild(AimbotTargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
    
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, AimbotSmoothness)
end

function Aimbot.Enable()
    ActiveFeatures.Aimbot = true
    
    SafeConnect(RunService.RenderStepped, function()
        if ActiveFeatures.Aimbot then
            -- يعمل عند الضغط على زر الفأرة الأيمن
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local target = Aimbot.GetClosestPlayer()
                if target then
                    Aimbot.AimAt(target)
                end
            end
        end
    end)
    
    Notify("🎯 Aimbot", "Enabled! Hold Right Click to aim")
end

function Aimbot.Disable()
    ActiveFeatures.Aimbot = false
    Notify("🎯 Aimbot", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👻 INVISIBILITY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local Invisibility = {}

function Invisibility.Enable()
    ActiveFeatures.Invisible = true
    local char = GetCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end
    
    Notify("👻 Invisibility", "Enabled (Local)")
end

function Invisibility.Disable()
    ActiveFeatures.Invisible = false
    local char = GetCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end
    
    Notify("👻 Invisibility", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📷 VIEW PLAYER CAMERA
-- ═══════════════════════════════════════════════════════════════════════
local ViewCamera = {}

function ViewCamera.ViewPlayer(player)
    if not player or not player.Character then return end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        Camera.CameraSubject = humanoid
        Notify("📷 Camera", "Viewing: " .. player.Name)
    end
end

function ViewCamera.StopViewing()
    local humanoid = GetHumanoid()
    if humanoid then
        Camera.CameraSubject = humanoid
    end
    Notify("📷 Camera", "Back to your character")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔫 STEAL TOOL (مُصلح)
-- ═══════════════════════════════════════════════════════════════════════
local StealTool = {}

function StealTool.StealFromPlayer(player)
    if not player then return 0 end
    local count = 0
    
    -- من الشخصية
    pcall(function()
        if player.Character then
            for _, child in ipairs(player.Character:GetChildren()) do
                if child:IsA("Tool") then
                    local clone = child:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    count = count + 1
                end
            end
        end
    end)
    
    -- من الحقيبة
    pcall(function()
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local clone = tool:Clone()
                    clone.Parent = LocalPlayer.Backpack
                    count = count + 1
                end
            end
        end
    end)
    
    return count
end

function StealTool.StealFromAll()
    local totalStolen = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            totalStolen = totalStolen + StealTool.StealFromPlayer(player)
        end
    end
    Notify("🔫 Steal", "Stole " .. totalStolen .. " tools!")
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
    Notify("❄️ Freeze", "Froze: " .. player.Name)
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
    Notify("❄️ Freeze", "Unfroze all!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📍 SAFE TELEPORT
-- ═══════════════════════════════════════════════════════════════════════
local SafeTeleport = {}

function SafeTeleport.ToPosition(position)
    local hrp = GetHRP()
    if not hrp then return end
    
    if not ActiveFeatures.AntiKick then AntiKick.Enable() end
    
    local distance = (hrp.Position - position).Magnitude
    local steps = math.max(3, math.floor(distance / 50))
    
    for i = 1, steps do
        local alpha = i / steps
        hrp.CFrame = CFrame.new(hrp.Position:Lerp(position, alpha))
        task.wait(0.03)
    end
    
    hrp.CFrame = CFrame.new(position)
    Notify("📍 Teleport", "Teleported!")
end

function SafeTeleport.ToPlayer(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        SafeTeleport.ToPosition(hrp.Position + Vector3.new(3, 0, 3))
    end
end

function SafeTeleport.ToMouse()
    if Mouse.Hit then
        SafeTeleport.ToPosition(Mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 PLAYER MODS (مُصلح)
-- ═══════════════════════════════════════════════════════════════════════
local PlayerMods = {}

function PlayerMods.SetSpeed(speed)
    WalkSpeedValue = speed
    local humanoid = GetHumanoid()
    if humanoid then humanoid.WalkSpeed = speed end
    ActiveFeatures.Speed = true
    Notify("⚡ Speed", "Set to: " .. speed)
end

function PlayerMods.SetJump(power)
    JumpPowerValue = power
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.JumpPower = power
        humanoid.UseJumpPower = true
    end
    Notify("🦘 Jump", "Power: " .. power)
end

function PlayerMods.InfiniteJump()
    ActiveFeatures.InfiniteJump = true
    
    SafeConnect(UserInputService.JumpRequest, function()
        if ActiveFeatures.InfiniteJump then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    Notify("🦘 Infinite Jump", "Enabled!")
end

function PlayerMods.Noclip()
    ActiveFeatures.Noclip = true
    
    SafeConnect(RunService.Stepped, function()
        if ActiveFeatures.Noclip then
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    Notify("👻 Noclip", "Enabled!")
end

function PlayerMods.Fly()
    ActiveFeatures.Fly = true
    
    local hrp = GetHRP()
    if not hrp then 
        Notify("🚀 Fly", "Error: No HumanoidRootPart!")
        return 
    end
    
    -- إزالة القوى القديمة
    pcall(function()
        local old1 = hrp:FindFirstChild("KlimboFly")
        local old2 = hrp:FindFirstChild("KlimboGyro")
        if old1 then old1:Destroy() end
        if old2 then old2:Destroy() end
    end)
    
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
    
    SafeConnect(RunService.RenderStepped, function()
        if ActiveFeatures.Fly and hrp and hrp.Parent then
            local bv = hrp:FindFirstChild("KlimboFly")
            local bg = hrp:FindFirstChild("KlimboGyro")
            if not bv or not bg then return end
            
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
            
            bv.Velocity = direction * FlySpeed
            bg.CFrame = Camera.CFrame
        end
    end)
    
    -- إيقاف الطيران عند القفز
    SafeConnect(UserInputService.JumpRequest, function()
        if ActiveFeatures.Fly then
            -- لا نسمح بالقفز العادي أثناء الطيران
        end
    end)
    
    Notify("🚀 Fly", "Enabled! WASD + Space/Ctrl")
end

function PlayerMods.StopFly()
    ActiveFeatures.Fly = false
    
    local hrp = GetHRP()
    if hrp then
        local bv = hrp:FindFirstChild("KlimboFly")
        local bg = hrp:FindFirstChild("KlimboGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    
    Notify("🚀 Fly", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🤖 NPC CONTROL SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local NPCControl = {}

function NPCControl.FindNPCs()
    local npcs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            table.insert(npcs, obj)
        end
    end
    return npcs
end

function NPCControl.ControlNPC(npc)
    if not npc then return end
    NPCControlTarget = npc
    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        Camera.CameraSubject = humanoid
        Notify("🤖 NPC Control", "Controlling: " .. npc.Name)
    end
end

function NPCControl.StopControl()
    NPCControlTarget = nil
    local humanoid = GetHumanoid()
    if humanoid then
        Camera.CameraSubject = humanoid
    end
    Notify("🤖 NPC Control", "Stopped!")
end

function NPCControl.MoveNPCTo(position)
    if not NPCControlTarget then return end
    local humanoid = NPCControlTarget:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(position)
    end
end

function NPCControl.MakeNPCFollow()
    if not NPCControlTarget then return end
    local humanoid = NPCControlTarget:FindFirstChild("Humanoid")
    if humanoid then
        SafeConnect(RunService.Heartbeat, function()
            if NPCControlTarget and ActiveFeatures.NPCFollow then
                local myHRP = GetHRP()
                local npcHRP = NPCControlTarget:FindFirstChild("HumanoidRootPart")
                if myHRP and npcHRP then
                    humanoid:MoveTo(myHRP.Position)
                end
            end
        end)
        ActiveFeatures.NPCFollow = true
        Notify("🤖 NPC", "Following you!")
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 GAME DETECTION
-- ═══════════════════════════════════════════════════════════════════════
local GameSpecific = {}

function GameSpecific.DetectGame()
    local placeId = game.PlaceId
    local gameName = "Universal"
    
    if placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635 then
        gameName = "Blox Fruits"
    elseif placeId == 4924922222 then
        gameName = "Brookhaven"
    elseif placeId == 142823291 then
        gameName = "MM2"
    elseif placeId == 920587237 then
        gameName = "Adopt Me"
    elseif placeId == 606849621 then
        gameName = "Jailbreak"
    elseif placeId == 286090429 then
        gameName = "Arsenal"
    elseif placeId == 6872265039 then
        gameName = "BedWars"
    end
    
    return gameName, placeId
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 DISABLE ALL FEATURES
-- ═══════════════════════════════════════════════════════════════════════
function KlimboMenu.DisableAll()
    -- إيقاف ESP
    ESP.Disable()
    
    -- إيقاف Aimbot
    Aimbot.Disable()
    
    -- إيقاف Invisibility
    Invisibility.Disable()
    
    -- إيقاف Fly
    PlayerMods.StopFly()
    
    -- إيقاف Noclip
    ActiveFeatures.Noclip = false
    
    -- إيقاف Infinite Jump
    ActiveFeatures.InfiniteJump = false
    
    -- إيقاف Speed
    ActiveFeatures.Speed = false
    local humanoid = GetHumanoid()
    if humanoid then humanoid.WalkSpeed = 16 end
    
    -- إيقاف Freeze
    FreezePlayer.UnfreezeAll()
    
    -- إيقاف NPC Control
    NPCControl.StopControl()
    ActiveFeatures.NPCFollow = false
    
    -- إيقاف Anti-Kick
    AntiKick.Disable()
    
    Notify("🔄 Disable All", "All features disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🖥️ CREATE KLIMBO MENU UI (النسخة المحسنة)
-- ═══════════════════════════════════════════════════════════════════════════
function KlimboMenu.Create(parent)
    if not parent then
        warn("❌ KlimboMenu.Create: parent is nil!")
        return nil
    end
    
    local gameName, placeId = GameSpecific.DetectGame()
    local BASE_ZINDEX = 51
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "KlimboMenu"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Theme.Dark
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = BASE_ZINDEX
    MainFrame.Parent = parent
    
    -- خلفية فضائية
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 0, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 15, 30))
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
    
    local HeaderGrad = Instance.new("UIGradient")
    HeaderGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    })
    HeaderGrad.Transparency = NumberSequence.new(0.85)
    HeaderGrad.Parent = Header
    
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 2)
    HeaderLine.Position = UDim2.new(0, 0, 1, -2)
    HeaderLine.BackgroundColor3 = Theme.Accent
    HeaderLine.BorderSizePixel = 0
    HeaderLine.ZIndex = BASE_ZINDEX + 2
    HeaderLine.Parent = Header
    
    -- أنيميشن الخط
    task.spawn(function()
        while HeaderLine and HeaderLine.Parent do
            TweenService:Create(HeaderLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Primary}):Play()
            task.wait(1.5)
            if not HeaderLine or not HeaderLine.Parent then break end
            TweenService:Create(HeaderLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Secondary}):Play()
            task.wait(1.5)
            if not HeaderLine or not HeaderLine.Parent then break end
            TweenService:Create(HeaderLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Accent}):Play()
            task.wait(1.5)
        end
    end)
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0.5, 0, 0, 30)
    Logo.Position = UDim2.new(0, 10, 0, 5)
    Logo.Text = "👑 KLIMBO MENU"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 20
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = BASE_ZINDEX + 2
    Logo.Parent = Header
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(0, 50, 0, 16)
    Version.Position = UDim2.new(0, 155, 0, 8)
    Version.Text = "v3.0"
    Version.TextColor3 = Theme.Dark
    Version.TextSize = 9
    Version.Font = Enum.Font.GothamBold
    Version.BackgroundColor3 = Theme.Accent
    Version.ZIndex = BASE_ZINDEX + 3
    Version.Parent = Header
    Instance.new("UICorner", Version).CornerRadius = UDim.new(0, 4)
    
    local GameLabel = Instance.new("TextLabel")
    GameLabel.Size = UDim2.new(0.5, 0, 0, 18)
    GameLabel.Position = UDim2.new(0, 10, 0, 38)
    GameLabel.Text = "🎮 " .. gameName
    GameLabel.TextColor3 = Theme.TextDim
    GameLabel.TextSize = 11
    GameLabel.Font = Enum.Font.Gotham
    GameLabel.BackgroundTransparency = 1
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameLabel.ZIndex = BASE_ZINDEX + 2
    GameLabel.Parent = Header
    
    -- زر Disable All
    local DisableAllBtn = Instance.new("TextButton")
    DisableAllBtn.Size = UDim2.new(0, 100, 0, 30)
    DisableAllBtn.Position = UDim2.new(1, -110, 0, 5)
    DisableAllBtn.Text = "🔄 DISABLE ALL"
    DisableAllBtn.TextColor3 = Theme.Text
    DisableAllBtn.TextSize = 10
    DisableAllBtn.Font = Enum.Font.GothamBold
    DisableAllBtn.BackgroundColor3 = Theme.Danger
    DisableAllBtn.ZIndex = BASE_ZINDEX + 3
    DisableAllBtn.Parent = Header
    Instance.new("UICorner", DisableAllBtn).CornerRadius = UDim.new(0, 8)
    
    DisableAllBtn.MouseButton1Click:Connect(function()
        KlimboMenu.DisableAll()
    end)
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -12, 1, -72)
    Content.Position = UDim2.new(0, 6, 0, 68)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Theme.Primary
    Content.ZIndex = BASE_ZINDEX + 1
    Content.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.Parent = Content
    
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingLeft = UDim.new(0, 3)
    ContentPad.PaddingRight = UDim.new(0, 3)
    ContentPad.PaddingTop = UDim.new(0, 3)
    ContentPad.PaddingBottom = UDim.new(0, 10)
    ContentPad.Parent = Content
    
    -- ═══════════════════════════════════════════════════════════════════
    -- دوال إنشاء العناصر
    -- ═══════════════════════════════════════════════════════════════════
    local function CreateButton(name, icon, color, callback, isToggle)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -6, 0, 44)
        Btn.BackgroundColor3 = Theme.Card
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.ZIndex = BASE_ZINDEX + 2
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = color
        BtnStroke.Thickness = 1
        BtnStroke.Transparency = 0.6
        BtnStroke.Parent = Btn
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 35, 0, 35)
        IconLbl.Position = UDim2.new(0, 6, 0.5, -17)
        IconLbl.Text = icon
        IconLbl.TextSize = 20
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = BASE_ZINDEX + 3
        IconLbl.Parent = Btn
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -105, 1, 0)
        NameLbl.Position = UDim2.new(0, 45, 0, 0)
        NameLbl.Text = name
        NameLbl.TextColor3 = Theme.Text
        NameLbl.TextSize = 12
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = BASE_ZINDEX + 3
        NameLbl.Parent = Btn
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(0, 44, 0, 22)
        Status.Position = UDim2.new(1, -50, 0.5, -11)
        Status.Text = isToggle and "OFF" or "▶"
        Status.TextColor3 = isToggle and Theme.Danger or color
        Status.TextSize = 10
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
                BtnStroke.Transparency = isEnabled and 0 or 0.6
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = isEnabled and Color3.fromRGB(25, 30, 50) or Theme.Card}):Play()
            end
            callback(isEnabled)
        end)
        
        Btn.MouseEnter:Connect(function()
            if not isEnabled then
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not isEnabled then
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
            end
        end)
        
        return Btn
    end
    
    local function CreateSection(name, icon)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -6, 0, 28)
        Section.BackgroundTransparency = 1
        Section.ZIndex = BASE_ZINDEX + 2
        Section.Parent = Content
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, 0, 1, 0)
        SectionLabel.Text = (icon or "━━━") .. " " .. name
        SectionLabel.TextColor3 = Theme.Primary
        SectionLabel.TextSize = 12
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.ZIndex = BASE_ZINDEX + 3
        SectionLabel.Parent = Section
        
        return Section
    end
    
    local function CreateSlider(name, icon, color, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, -6, 0, 55)
        SliderFrame.BackgroundColor3 = Theme.Card
        SliderFrame.ZIndex = BASE_ZINDEX + 2
        SliderFrame.Parent = Content
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)
        
        local SliderStroke = Instance.new("UIStroke")
        SliderStroke.Color = color
        SliderStroke.Thickness = 1
        SliderStroke.Transparency = 0.6
        SliderStroke.Parent = SliderFrame
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 30, 0, 30)
        IconLbl.Position = UDim2.new(0, 5, 0, 3)
        IconLbl.Text = icon
        IconLbl.TextSize = 18
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = BASE_ZINDEX + 3
        IconLbl.Parent = SliderFrame
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -80, 0, 20)
        NameLbl.Position = UDim2.new(0, 38, 0, 5)
        NameLbl.Text = name
        NameLbl.TextColor3 = Theme.Text
        NameLbl.TextSize = 11
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = BASE_ZINDEX + 3
        NameLbl.Parent = SliderFrame
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 40, 0, 20)
        ValueLabel.Position = UDim2.new(1, -45, 0, 5)
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = color
        ValueLabel.TextSize = 12
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.ZIndex = BASE_ZINDEX + 3
        ValueLabel.Parent = SliderFrame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, -16, 0, 12)
        SliderBg.Position = UDim2.new(0, 8, 0, 35)
        SliderBg.BackgroundColor3 = Theme.Darker
        SliderBg.ZIndex = BASE_ZINDEX + 3
        SliderBg.Parent = SliderFrame
        Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 6)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        SliderFill.BackgroundColor3 = color
        SliderFill.ZIndex = BASE_ZINDEX + 4
        SliderFill.Parent = SliderBg
        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 6)
        
        local SliderBtn = Instance.new("TextButton")
        SliderBtn.Size = UDim2.new(0, 16, 0, 16)
        SliderBtn.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        SliderBtn.BackgroundColor3 = Theme.Text
        SliderBtn.Text = ""
        SliderBtn.ZIndex = BASE_ZINDEX + 5
        SliderBtn.Parent = SliderBg
        Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        local currentValue = default
        
        local function UpdateSlider(input)
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * pos)
            ValueLabel.Text = tostring(currentValue)
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderBtn.Position = UDim2.new(pos, -8, 0.5, -8)
            callback(currentValue)
        end
        
        SliderBtn.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider(input)
            end
        end)
        
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                UpdateSlider(input)
            end
        end)
        
        return SliderFrame
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- الأزرار والميزات
    -- ═══════════════════════════════════════════════════════════════════
    
    -- ══════════════ ESP SECTION ══════════════
    CreateSection("👁️ ESP OPTIONS", "🔹")
    
    CreateButton("ESP Master Toggle", "👁️", Theme.Secondary, function(enabled)
        if enabled then
            ESP.Enable()
        else
            ESP.Disable()
        end
    end, true)
    
    CreateButton("ESP - Player Names", "📛", Color3.fromRGB(100, 200, 255), function(enabled)
        ActiveFeatures.ESP_Name = enabled
    end, true)
    
    CreateButton("ESP - Health Bar", "❤️", Color3.fromRGB(255, 100, 100), function(enabled)
        ActiveFeatures.ESP_Health = enabled
    end, true)
    
    CreateButton("ESP - Distance", "📏", Color3.fromRGB(255, 200, 100), function(enabled)
        ActiveFeatures.ESP_Distance = enabled
    end, true)
    
    CreateButton("ESP - Highlight", "✨", Color3.fromRGB(200, 100, 255), function(enabled)
        ActiveFeatures.ESP_Highlight = enabled
    end, true)
    
    CreateButton("ESP - Tracers", "〰️", Color3.fromRGB(255, 150, 50), function(enabled)
        ActiveFeatures.ESP_Tracer = enabled
    end, true)
    
    -- ══════════════ AIMBOT SECTION ══════════════
    CreateSection("🎯 AIMBOT", "🔹")
    
    CreateButton("Aimbot (Hold Right Click)", "🎯", Theme.Danger, function(enabled)
        if enabled then
            Aimbot.Enable()
        else
            Aimbot.Disable()
        end
    end, true)
    
    CreateButton("Aimbot - Target Teammates", "👥", Color3.fromRGB(150, 150, 255), function(enabled)
        ActiveFeatures.AimbotTeam = enabled
    end, true)
    
    CreateSlider("Aimbot FOV", "🎯", Theme.Danger, 50, 500, AimbotFOV, function(value)
        AimbotFOV = value
    end)
    
    CreateSlider("Aimbot Smoothness", "🎯", Color3.fromRGB(255, 150, 150), 1, 100, 50, function(value)
        AimbotSmoothness = value / 100
    end)
    
    -- ══════════════ PLAYER SECTION ══════════════
    CreateSection("👻 PLAYER MODS", "🔹")
    
    CreateButton("Invisibility (Local)", "👻", Theme.Secondary, function(enabled)
        if enabled then Invisibility.Enable() else Invisibility.Disable() end
    end, true)
    
    CreateButton("Noclip (Walk Through Walls)", "🚪", Color3.fromRGB(150, 100, 255), function(enabled)
        if enabled then 
            PlayerMods.Noclip() 
        else 
            ActiveFeatures.Noclip = false
        end
    end, true)
    
    CreateButton("Fly (WASD + Space/Ctrl)", "🚀", Color3.fromRGB(100, 200, 255), function(enabled)
        if enabled then PlayerMods.Fly() else PlayerMods.StopFly() end
    end, true)
    
    CreateButton("Infinite Jump", "🦘", Color3.fromRGB(255, 200, 100), function(enabled)
        if enabled then 
            PlayerMods.InfiniteJump() 
        else 
            ActiveFeatures.InfiniteJump = false
        end
    end, true)
    
    CreateSlider("Walk Speed", "⚡", Theme.Accent, 1, 200, 16, function(value)
        PlayerMods.SetSpeed(value)
    end)
    
    CreateSlider("Jump Power", "🦘", Color3.fromRGB(255, 200, 100), 1, 300, 50, function(value)
        PlayerMods.SetJump(value)
    end)
    
    CreateSlider("Fly Speed", "🚀", Color3.fromRGB(100, 200, 255), 10, 300, 50, function(value)
        FlySpeed = value
    end)
    
    -- ══════════════ CAMERA SECTION ══════════════
    CreateSection("📷 CAMERA", "🔹")
    
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
    
    -- ══════════════ PLAYERS SECTION ══════════════
    CreateSection("🎮 PLAYERS", "🔹")
    
    CreateButton("Steal All Tools", "🔫", Theme.Danger, function()
        StealTool.StealFromAll()
    end, false)
    
    CreateButton("Freeze Nearest Player", "❄️", Color3.fromRGB(100, 200, 255), function()
        local nearest = nil
        local minDist = math.huge
        local myPos = GetHRP() and GetHRP().Position
        
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
    
    -- ══════════════ NPC SECTION ══════════════
    CreateSection("🤖 NPC CONTROL", "🔹")
    
    CreateButton("Control Nearest NPC", "🤖", Theme.Purple, function()
        local npcs = NPCControl.FindNPCs()
        if #npcs > 0 then
            local nearest = nil
            local minDist = math.huge
            local myPos = GetHRP() and GetHRP().Position
            
            if myPos then
                for _, npc in ipairs(npcs) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (hrp.Position - myPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearest = npc
                        end
                    end
                end
            end
            
            if nearest then
                NPCControl.ControlNPC(nearest)
            else
                Notify("🤖 NPC", "No NPC found!")
            end
        else
            Notify("🤖 NPC", "No NPCs in this game!")
        end
    end, false)
    
    CreateButton("Make NPC Follow You", "🤖👤", Color3.fromRGB(200, 150, 255), function()
        if NPCControlTarget then
            NPCControl.MakeNPCFollow()
        else
            Notify("🤖 NPC", "Control an NPC first!")
        end
    end, false)
    
    CreateButton("Stop NPC Control", "🤖❌", Color3.fromRGB(150, 100, 150), function()
        NPCControl.StopControl()
        ActiveFeatures.NPCFollow = false
    end, false)
    
    -- ══════════════ TELEPORT SECTION ══════════════
    CreateSection("📍 TELEPORT", "🔹")
    
    CreateButton("TP to Mouse Click", "🖱️", Theme.Success, function()
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
    
    -- ══════════════ PROTECTION SECTION ══════════════
    CreateSection("🛡️ PROTECTION", "🔹")
    
    CreateButton("Anti-Kick", "🛡️", Theme.Success, function(enabled)
        if enabled then AntiKick.Enable() else AntiKick.Disable() end
    end, true)
    
    -- Update canvas
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
    end)
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
    
    print("✅ KlimboMenu v3.0 created!")
    return MainFrame
end

return KlimboMenu
