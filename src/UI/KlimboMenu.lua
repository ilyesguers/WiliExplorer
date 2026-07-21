--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ██╗  ██╗██╗     ██╗███╗   ███╗██████╗  ██████╗                       ║
    ║  ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗██╔═══██╗                      ║
    ║  █████╔╝ ██║     ██║██╔████╔██║██████╔╝██║   ██║                      ║
    ║  ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██╗██║   ██║                      ║
    ║  ██║  ██╗███████╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝                      ║
    ║  ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝                       ║
    ║                                                                        ║
    ║  🔥 KLIMBO MENU v4.0 - ULTIMATE EXPLOIT SUITE 🔥                      ║
    ║  ✅ Remote Spy                                                          ║
    ║  ✅ Script Scanner                                                      ║
    ║  ✅ Server Tools (Hop/Rejoin/Private)                                   ║
    ║  ✅ Console Logger                                                      ║
    ║  ✅ Instance Scanner                                                    ║
    ║  ✅ Script Hub                                                          ║
    ║  ✅ Anti-AFK                                                            ║
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

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
    Green = Color3.fromRGB(0, 200, 100),
    Orange = Color3.fromRGB(255, 165, 0),
    Dark = Color3.fromRGB(10, 10, 20),
    Darker = Color3.fromRGB(5, 5, 15),
    Card = Color3.fromRGB(18, 18, 38),
    CardHover = Color3.fromRGB(28, 28, 55),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 المتغيرات العامة
-- ═══════════════════════════════════════════════════════════════════════
local ActiveFeatures = {
    ESP = false, ESP_Box = false, ESP_Name = false, ESP_Health = false,
    ESP_Distance = false, ESP_Tracer = false, ESP_Highlight = false,
    Aimbot = false, AimbotTeam = false, Invisible = false, Noclip = false,
    InfiniteJump = false, Speed = false, Fly = false, AntiKick = false,
    AntiAFK = false, NPCFollow = false, RemoteSpy = false,
    ConsoleLog = false, XRay = false
}

local ESPObjects = {}
local Connections = {}
local ConsoleLogs = {}
local RemoteSpyLogs = {}
local FlySpeed = 50
local WalkSpeedValue = 16
local JumpPowerValue = 50
local AimbotFOV = 200
local AimbotSmoothness = 0.5
local AimbotTargetPart = "Head"
local NPCControlTarget = nil
local MaxConsoleLogs = 200
local MaxRemoteLogs = 100

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

local function AddLog(logTable, logType, message, data)
    local log = {
        time = os.date("%H:%M:%S"),
        type = logType,
        message = message,
        data = data
    }
    table.insert(logTable, 1, log)
    if #logTable > MaxConsoleLogs then
        table.remove(logTable)
    end
    return log
end

local function FormatArgs(args)
    local parts = {}
    for i, v in ipairs(args) do
        table.insert(parts, tostring(v))
    end
    return table.concat(parts, ", ")
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
            if method == "Kick" and ActiveFeatures.AntiKick then return nil end
            return oldNamecall(self, ...)
        end)
        if setreadonly then setreadonly(mt, true) end
    end)
    Notify("🛡️ Anti-Kick", "Enabled!")
end

function AntiKick.Disable()
    ActiveFeatures.AntiKick = false
    Notify("🛡️ Anti-Kick", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🕵️ REMOTE SPY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local RemoteSpy = {}

function RemoteSpy.Enable()
    ActiveFeatures.RemoteSpy = true
    RemoteSpyLogs = {}
    
    pcall(function()
        local mt = getrawmetatable(game)
        if setreadonly then setreadonly(mt, false) end
        
        local oldNamecall = mt.__namecall
        RemoteSpy.Hook = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if ActiveFeatures.RemoteSpy then
                if method == "FireServer" or method == "InvokeServer" then
                    local remotePath = ""
                    pcall(function() remotePath = self:GetFullName() end)
                    
                    AddLog(RemoteSpyLogs, method == "FireServer" and "SEND" or "INVOKE", 
                        self.Name, {
                            path = remotePath,
                            method = method,
                            args = FormatArgs(args)
                        })
                elseif method == "FireClient" or method == "InvokeClient" then
                    local remotePath = ""
                    pcall(function() remotePath = self:GetFullName() end)
                    
                    AddLog(RemoteSpyLogs, method == "FireClient" and "RECEIVE" or "INVOKE_CLIENT",
                        self.Name, {
                            path = remotePath,
                            method = method,
                            args = FormatArgs(args)
                        })
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        mt.__namecall = RemoteSpy.Hook
        
        if setreadonly then setreadonly(mt, true) end
    end)
    
    AddLog(ConsoleLogs, "SYSTEM", "Remote Spy Enabled!")
    Notify("🕵️ Remote Spy", "Enabled! Check logs in menu")
end

function RemoteSpy.Disable()
    ActiveFeatures.RemoteSpy = false
    AddLog(ConsoleLogs, "SYSTEM", "Remote Spy Disabled!")
    Notify("🕵️ Remote Spy", "Disabled!")
end

function RemoteSpy.ClearLogs()
    RemoteSpyLogs = {}
    Notify("🕵️ Remote Spy", "Logs cleared!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📜 SCRIPT SCANNER
-- ═══════════════════════════════════════════════════════════════════════
local ScriptScanner = {}

function ScriptScanner.ScanForSensitiveScripts()
    local sensitiveKeywords = {
        "remote", "fire", "invoke", "server", "client",
        "admin", "mod", "kick", "ban", "teleport",
        "purchase", "buy", "sell", "trade", "money",
        "health", "damage", "kill", "heal", "spawn",
        "data", "save", "load", "inventory", "item",
        "key", "password", "token", "auth", "login"
    }
    
    local found = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local source = ""
            pcall(function() source = obj.Source end)
            
            if source and #source > 0 then
                local matches = {}
                local lowerSource = source:lower()
                
                for _, keyword in ipairs(sensitiveKeywords) do
                    if lowerSource:find(keyword) then
                        table.insert(matches, keyword)
                    end
                end
                
                if #matches > 0 then
                    table.insert(found, {
                        instance = obj,
                        name = obj.Name,
                        path = obj:GetFullName(),
                        className = obj.ClassName,
                        keywords = matches,
                        sourceLength = #source
                    })
                end
            end
        end
    end
    
    table.sort(found, function(a, b) return #a.keywords > #b.keywords end)
    
    AddLog(ConsoleLogs, "SCAN", "Found " .. #found .. " sensitive scripts!")
    return found
end

function ScriptScanner.GetEditableScripts()
    local editable = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local canRead = false
            pcall(function()
                local src = obj.Source
                canRead = src ~= nil and #src > 0
            end)
            
            if canRead then
                table.insert(editable, {
                    instance = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    className = obj.ClassName,
                    canEdit = obj:IsA("LocalScript") or obj:IsA("ModuleScript")
                })
            end
        end
    end
    
    return editable
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖥️ SERVER TOOLS
-- ═══════════════════════════════════════════════════════════════════════
local ServerTools = {}

function ServerTools.ServerHop()
    Notify("🖥️ Server", "Hopping to new server...")
    
    local servers = {}
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

function ServerTools.Rejoin()
    Notify("🖥️ Server", "Rejoining...")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

function ServerTools.CreatePrivateServer()
    Notify("🖥️ Server", "Creating private server...")
    
    pcall(function()
        local privateServer = TeleportService:TeleportToPrivateServer(game.PlaceId)
        AddLog(ConsoleLogs, "SERVER", "Private server created!")
    end)
end

function ServerTools.CopyJobId()
    pcall(function()
        if setclipboard then
            setclipboard(game.JobId)
            Notify("🖥️ Server", "Job ID copied!")
        end
    end)
end

function ServerTools.GetServerInfo()
    local info = {
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        Players = #Players:GetPlayers() .. "/" .. Players.MaxPlayers,
        Ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms",
        FPS = math.floor(1 / RunService.RenderStepped:Wait()),
        Time = os.date("%H:%M:%S")
    }
    return info
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 ANTI-AFK
-- ═══════════════════════════════════════════════════════════════════════
local AntiAFK = {}

function AntiAFK.Enable()
    ActiveFeatures.AntiAFK = true
    
    SafeConnect(RunService.Heartbeat, function()
        if ActiveFeatures.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
    
    AddLog(ConsoleLogs, "SYSTEM", "Anti-AFK Enabled!")
    Notify("💤 Anti-AFK", "Enabled!")
end

function AntiAFK.Disable()
    ActiveFeatures.AntiAFK = false
    Notify("💤 Anti-AFK", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 INSTANCE SCANNER
-- ═══════════════════════════════════════════════════════════════════════
local InstanceScanner = {}

function InstanceScanner.Search(className, namePattern)
    local results = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        local matchClass = not className or obj:IsA(className)
        local matchName = not namePattern or obj.Name:lower():find(namePattern:lower())
        
        if matchClass and matchName then
            table.insert(results, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                className = obj.ClassName
            })
        end
        
        if #results >= 100 then break end
    end
    
    return results
end

function InstanceScanner.FindRemotes()
    local remotes = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj:IsA("RemoteEvent") and "Event" or "Function"
            })
        end
    end
    
    AddLog(ConsoleLogs, "SCAN", "Found " .. #remotes .. " remotes!")
    return remotes
end

function InstanceScanner.FindValues()
    local values = {}
    
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ValueBase") then
            local value = nil
            pcall(function() value = obj.Value end)
            
            table.insert(values, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                className = obj.ClassName,
                value = tostring(value)
            })
        end
    end
    
    return values
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📜 SCRIPT HUB (سكريبتات جاهزة)
-- ═══════════════════════════════════════════════════════════════════════
local ScriptHub = {}

ScriptHub.Scripts = {
    {
        name = "Infinite Yield",
        icon = "⚡",
        description = "Admin commands script",
        url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
    },
    {
        name = "Dex Explorer",
        icon = "🔍",
        description = "Game explorer",
        url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
    },
    {
        name = "Remote Spy",
        icon = "🕵️",
        description = "Monitor remote calls",
        url = "https://raw.githubusercontent.com/infyiff/backup/main/remotespy.lua"
    },
    {
        name = "Dark Dex",
        icon = "🌙",
        description = "Dark theme explorer",
        url = "https://raw.githubusercontent.com/infyiff/backup/main/dark.dex.lua"
    },
    {
        name = "Unnamed ESP",
        icon = "👁️",
        description = "Advanced ESP script",
        url = "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua"
    },
    {
        name = "Aimbot",
        icon = "🎯",
        description = "Universal aimbot",
        url = "https://raw.githubusercontent.com/Aimbot-V2/Aimbot-V2/main/Aimbot.lua"
    },
    {
        name = "Chat Bypass",
        icon = "💬",
        description = "Bypass chat filter",
        url = "https://raw.githubusercontent.com/Synergy-Networks/Chat-Bypass/main/bypass.lua"
    },
    {
        name = "Anti-Cheat Bypass",
        icon = "🛡️",
        description = "Bypass anti-cheat",
        url = "https://raw.githubusercontent.com/AntiBypass/Anti-Cheat/main/bypass.lua"
    }
}

function ScriptHub.ExecuteScript(scriptInfo)
    Notify("📜 Script Hub", "Loading: " .. scriptInfo.name)
    
    task.spawn(function()
        local success, err = pcall(function()
            local code = game:HttpGet(scriptInfo.url)
            loadstring(code)()
        end)
        
        if success then
            Notify("📜 Script Hub", scriptInfo.name .. " loaded!")
            AddLog(ConsoleLogs, "SCRIPT", "Loaded: " .. scriptInfo.name)
        else
            Notify("📜 Script Hub", "Failed: " .. tostring(err))
            AddLog(ConsoleLogs, "ERROR", "Failed: " .. scriptInfo.name)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👁️ ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local ESP = {}

function ESP.CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local espData = {
        Highlight = nil, BillboardGui = nil, Tracer = nil, Connection = nil
    }
    
    local function UpdateESP()
        if not ActiveFeatures.ESP then return end
        if not player.Character then return end
        
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        if not hrp or not humanoid then return end
        
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
        elseif espData.Highlight then
            espData.Highlight:Destroy()
            espData.Highlight = nil
        end
        
        if ActiveFeatures.ESP_Name or ActiveFeatures.ESP_Health or ActiveFeatures.ESP_Distance then
            if not espData.BillboardGui or not espData.BillboardGui.Parent then
                espData.BillboardGui = Instance.new("BillboardGui")
                espData.BillboardGui.Name = "KlimboInfo"
                espData.BillboardGui.Size = UDim2.new(0, 200, 0, 50)
                espData.BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
                espData.BillboardGui.AlwaysOnTop = true
                espData.BillboardGui.Adornee = head or hrp
                espData.BillboardGui.Parent = head or hrp
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 14
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeTransparency = 0
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
                infoLabel.Parent = espData.BillboardGui
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
            if ActiveFeatures.ESP_Distance then infoText = "📏 " .. distance .. "m" end
            if ActiveFeatures.ESP_Health then
                if infoText ~= "" then infoText = infoText .. " | " end
                infoText = infoText .. "❤️ " .. health .. "/" .. maxHealth
            end
            espData.BillboardGui.InfoLabel.Text = infoText
        elseif espData.BillboardGui then
            espData.BillboardGui:Destroy()
            espData.BillboardGui = nil
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
    
    Notify("👁️ ESP", "Enabled!")
end

function ESP.Disable()
    ActiveFeatures.ESP = false
    for player, _ in pairs(ESPObjects) do
        ESP.RemoveESP(player)
    end
    Notify("👁️ ESP", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 AIMBOT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local Aimbot = {}

function Aimbot.GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotFOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local targetPart = player.Character:FindFirstChild(AimbotTargetPart) or hrp
            
            if hrp and humanoid and humanoid.Health > 0 and targetPart then
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
    
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSmoothness)
end

function Aimbot.Enable()
    ActiveFeatures.Aimbot = true
    SafeConnect(RunService.RenderStepped, function()
        if ActiveFeatures.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = Aimbot.GetClosestPlayer()
            if target then Aimbot.AimAt(target) end
        end
    end)
    Notify("🎯 Aimbot", "Hold Right Click!")
end

function Aimbot.Disable()
    ActiveFeatures.Aimbot = false
    Notify("🎯 Aimbot", "Disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👻 PLAYER MODS
-- ═══════════════════════════════════════════════════════════════════════
local PlayerMods = {}

function PlayerMods.SetSpeed(speed)
    WalkSpeedValue = speed
    local humanoid = GetHumanoid()
    if humanoid then humanoid.WalkSpeed = speed end
    ActiveFeatures.Speed = true
end

function PlayerMods.SetJump(power)
    JumpPowerValue = power
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.JumpPower = power
        humanoid.UseJumpPower = true
    end
end

function PlayerMods.InfiniteJump()
    ActiveFeatures.InfiniteJump = true
    SafeConnect(UserInputService.JumpRequest, function()
        if ActiveFeatures.InfiniteJump then
            local humanoid = GetHumanoid()
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    Notify("🦘 Inf Jump", "Enabled!")
end

function PlayerMods.Noclip()
    ActiveFeatures.Noclip = true
    SafeConnect(RunService.Stepped, function()
        if ActiveFeatures.Noclip then
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
    Notify("👻 Noclip", "Enabled!")
end

function PlayerMods.Fly()
    ActiveFeatures.Fly = true
    local hrp = GetHRP()
    if not hrp then return end
    
    pcall(function()
        if hrp:FindFirstChild("KlimboFly") then hrp.KlimboFly:Destroy() end
        if hrp:FindFirstChild("KlimboGyro") then hrp.KlimboGyro:Destroy() end
    end)
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "KlimboFly"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "KlimboGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.Parent = hrp
    
    SafeConnect(RunService.RenderStepped, function()
        if ActiveFeatures.Fly and hrp and hrp.Parent then
            local bv2 = hrp:FindFirstChild("KlimboFly")
            local bg2 = hrp:FindFirstChild("KlimboGyro")
            if not bv2 or not bg2 then return end
            
            local dir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            
            bv2.Velocity = dir * FlySpeed
            bg2.CFrame = Camera.CFrame
        end
    end)
    
    Notify("🚀 Fly", "WASD + Space/Ctrl")
end

function PlayerMods.StopFly()
    ActiveFeatures.Fly = false
    local hrp = GetHRP()
    if hrp then
        pcall(function()
            if hrp:FindFirstChild("KlimboFly") then hrp.KlimboFly:Destroy() end
            if hrp:FindFirstChild("KlimboGyro") then hrp.KlimboGyro:Destroy() end
        end)
    end
    Notify("🚀 Fly", "Disabled!")
end

function PlayerMods.Invisibility()
    ActiveFeatures.Invisible = not ActiveFeatures.Invisible
    local char = GetCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = ActiveFeatures.Invisible and 1 or 0
        elseif part:IsA("Decal") then
            part.Transparency = ActiveFeatures.Invisible and 1 or 0
        end
    end
    
    Notify("👻 Invisibility", ActiveFeatures.Invisible and "Enabled" or "Disabled")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🤖 NPC CONTROL
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
        Notify("🤖 NPC", "Controlling: " .. npc.Name)
    end
end

function NPCControl.StopControl()
    NPCControlTarget = nil
    local humanoid = GetHumanoid()
    if humanoid then Camera.CameraSubject = humanoid end
    Notify("🤖 NPC", "Stopped!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📍 TELEPORT
-- ═══════════════════════════════════════════════════════════════════════
local Teleport = {}

function Teleport.ToPosition(position)
    local hrp = GetHRP()
    if not hrp then return end
    if not ActiveFeatures.AntiKick then AntiKick.Enable() end
    
    local distance = (hrp.Position - position).Magnitude
    local steps = math.max(3, math.floor(distance / 50))
    
    for i = 1, steps do
        hrp.CFrame = CFrame.new(hrp.Position:Lerp(position, i / steps))
        task.wait(0.03)
    end
    hrp.CFrame = CFrame.new(position)
end

function Teleport.ToPlayer(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then Teleport.ToPosition(hrp.Position + Vector3.new(3, 0, 3)) end
end

function Teleport.ToMouse()
    if Mouse.Hit then Teleport.ToPosition(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
end

-- ═══════════════════════════════════════════════════════════════════════
-- ❄️ FREEZE
-- ═══════════════════════════════════════════════════════════════════════
local FreezePlayer = {}
FreezePlayer.FrozenPlayers = {}

function FreezePlayer.Freeze(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    pcall(function() hrp.Anchored = true end)
    
    local effect = Instance.new("Part")
    effect.Name = "KlimboFreeze"
    effect.Size = Vector3.new(5, 7, 5)
    effect.Position = hrp.Position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.5
    effect.Material = Enum.Material.Ice
    effect.Parent = Workspace
    
    FreezePlayer.FrozenPlayers[player] = {hrp = hrp, effect = effect}
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
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔫 STEAL TOOLS
-- ═══════════════════════════════════════════════════════════════════════
local StealTool = {}

function StealTool.StealFromAll()
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                if player.Character then
                    for _, child in ipairs(player.Character:GetChildren()) do
                        if child:IsA("Tool") then
                            child:Clone().Parent = LocalPlayer.Backpack
                            count = count + 1
                        end
                    end
                end
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Clone().Parent = LocalPlayer.Backpack
                            count = count + 1
                        end
                    end
                end
            end)
        end
    end
    Notify("🔫 Steal", "Stole " .. count .. " tools!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 DISABLE ALL
-- ═══════════════════════════════════════════════════════════════════════
function KlimboMenu.DisableAll()
    ESP.Disable()
    Aimbot.Disable()
    PlayerMods.StopFly()
    ActiveFeatures.Noclip = false
    ActiveFeatures.InfiniteJump = false
    ActiveFeatures.Speed = false
    ActiveFeatures.Invisible = false
    ActiveFeatures.AntiAFK = false
    ActiveFeatures.RemoteSpy = false
    ActiveFeatures.NPCFollow = false
    
    local humanoid = GetHumanoid()
    if humanoid then humanoid.WalkSpeed = 16 end
    
    FreezePlayer.UnfreezeAll()
    NPCControl.StopControl()
    AntiKick.Disable()
    
    Notify("🔄 Disable All", "All features disabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 GAME DETECTION
-- ═══════════════════════════════════════════════════════════════════════
local function DetectGame()
    local placeId = game.PlaceId
    local games = {
        [2753915549] = "Blox Fruits", [4442272183] = "Blox Fruits", [7449423635] = "Blox Fruits",
        [4924922222] = "Brookhaven", [142823291] = "MM2", [920587237] = "Adopt Me",
        [606849621] = "Jailbreak", [286090429] = "Arsenal", [6872265039] = "BedWars",
        [3260590327] = "Tower of Hell", [1962086868] = "Tower of Hell",
        [2809202155] = "Ro-Ghoul", [4623386862] = "Pet Simulator X"
    }
    return games[placeId] or "Universal", placeId
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖥️ KLIMBO MENU UI
-- ═══════════════════════════════════════════════════════════════════════
function KlimboMenu.Create(parent)
    if not parent then return nil end
    
    local gameName, placeId = DetectGame()
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 0, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 15, 30))
    })
    Gradient.Rotation = 135
    Gradient.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = Theme.Darker
    Header.BorderSizePixel = 0
    Header.ZIndex = BASE_ZINDEX + 1
    Header.Parent = MainFrame
    
    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 2)
    HeaderLine.Position = UDim2.new(0, 0, 1, -2)
    HeaderLine.BackgroundColor3 = Theme.Accent
    HeaderLine.BorderSizePixel = 0
    HeaderLine.ZIndex = BASE_ZINDEX + 2
    HeaderLine.Parent = Header
    
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
    Logo.Size = UDim2.new(0.4, 0, 0, 28)
    Logo.Position = UDim2.new(0, 10, 0, 5)
    Logo.Text = "👑 KLIMBO v4.0"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 18
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = BASE_ZINDEX + 2
    Logo.Parent = Header
    
    local GameLabel = Instance.new("TextLabel")
    GameLabel.Size = UDim2.new(0.5, 0, 0, 18)
    GameLabel.Position = UDim2.new(0, 10, 0, 35)
    GameLabel.Text = "🎮 " .. gameName .. " | " .. #Players:GetPlayers() .. " players"
    GameLabel.TextColor3 = Theme.TextDim
    GameLabel.TextSize = 10
    GameLabel.Font = Enum.Font.Gotham
    GameLabel.BackgroundTransparency = 1
    GameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameLabel.ZIndex = BASE_ZINDEX + 2
    GameLabel.Parent = Header
    
    -- Disable All Button
    local DisableBtn = Instance.new("TextButton")
    DisableBtn.Size = UDim2.new(0, 90, 0, 28)
    DisableBtn.Position = UDim2.new(1, -100, 0, 5)
    DisableBtn.Text = "🔄 DISABLE ALL"
    DisableBtn.TextColor3 = Theme.Text
    DisableBtn.TextSize = 9
    DisableBtn.Font = Enum.Font.GothamBold
    DisableBtn.BackgroundColor3 = Theme.Danger
    DisableBtn.ZIndex = BASE_ZINDEX + 3
    DisableBtn.Parent = Header
    Instance.new("UICorner", DisableBtn).CornerRadius = UDim.new(0, 6)
    
    DisableBtn.MouseButton1Click:Connect(function()
        KlimboMenu.DisableAll()
    end)
    
    -- Content
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -10, 1, -68)
    Content.Position = UDim2.new(0, 5, 0, 63)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Theme.Primary
    Content.ZIndex = BASE_ZINDEX + 1
    Content.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Content
    
    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 2)
    Pad.PaddingRight = UDim.new(0, 2)
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingBottom = UDim.new(0, 10)
    Pad.Parent = Content
    
    -- ═══════════════════════════════════════════════════════════════════
    -- UI Helper Functions
    -- ═══════════════════════════════════════════════════════════════════
    local function CreateSection(name, icon)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, -4, 0, 25)
        Section.BackgroundTransparency = 1
        Section.ZIndex = BASE_ZINDEX + 2
        Section.Parent = Content
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.Text = (icon or "🔹") .. " " .. name
        Label.TextColor3 = Theme.Primary
        Label.TextSize = 11
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1
        Label.ZIndex = BASE_ZINDEX + 3
        Label.Parent = Section
        
        return Section
    end
    
    local function CreateButton(name, icon, color, callback, isToggle)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, -4, 0, 40)
        Btn.BackgroundColor3 = Theme.Card
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.ZIndex = BASE_ZINDEX + 2
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = color
        Stroke.Thickness = 1
        Stroke.Transparency = 0.7
        Stroke.Parent = Btn
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 32, 0, 32)
        IconLbl.Position = UDim2.new(0, 5, 0.5, -16)
        IconLbl.Text = icon
        IconLbl.TextSize = 18
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = BASE_ZINDEX + 3
        IconLbl.Parent = Btn
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -95, 1, 0)
        NameLbl.Position = UDim2.new(0, 40, 0, 0)
        NameLbl.Text = name
        NameLbl.TextColor3 = Theme.Text
        NameLbl.TextSize = 11
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = BASE_ZINDEX + 3
        NameLbl.Parent = Btn
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(0, 40, 0, 20)
        Status.Position = UDim2.new(1, -45, 0.5, -10)
        Status.Text = isToggle and "OFF" or "▶"
        Status.TextColor3 = isToggle and Theme.Danger or color
        Status.TextSize = 9
        Status.Font = Enum.Font.GothamBold
        Status.BackgroundColor3 = Theme.Darker
        Status.ZIndex = BASE_ZINDEX + 3
        Status.Parent = Btn
        Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 5)
        
        local isEnabled = false
        
        Btn.MouseButton1Click:Connect(function()
            if isToggle then
                isEnabled = not isEnabled
                Status.Text = isEnabled and "ON" or "OFF"
                Status.TextColor3 = isEnabled and Theme.Success or Theme.Danger
                Stroke.Transparency = isEnabled and 0 or 0.7
            end
            callback(isEnabled)
        end)
        
        Btn.MouseEnter:Connect(function()
            if not isEnabled then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.CardHover}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not isEnabled then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Card}):Play()
            end
        end)
        
        return Btn
    end
    
    local function CreateSlider(name, icon, color, min, max, default, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -4, 0, 50)
        Frame.BackgroundColor3 = Theme.Card
        Frame.ZIndex = BASE_ZINDEX + 2
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = color
        Stroke.Thickness = 1
        Stroke.Transparency = 0.7
        Stroke.Parent = Frame
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 28, 0, 28)
        IconLbl.Position = UDim2.new(0, 4, 0, 2)
        IconLbl.Text = icon
        IconLbl.TextSize = 16
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = BASE_ZINDEX + 3
        IconLbl.Parent = Frame
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -75, 0, 18)
        NameLbl.Position = UDim2.new(0, 35, 0, 4)
        NameLbl.Text = name
        NameLbl.TextColor3 = Theme.Text
        NameLbl.TextSize = 10
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = BASE_ZINDEX + 3
        NameLbl.Parent = Frame
        
        local ValueLbl = Instance.new("TextLabel")
        ValueLbl.Size = UDim2.new(0, 35, 0, 18)
        ValueLbl.Position = UDim2.new(1, -40, 0, 4)
        ValueLbl.Text = tostring(default)
        ValueLbl.TextColor3 = color
        ValueLbl.TextSize = 11
        ValueLbl.Font = Enum.Font.GothamBold
        ValueLbl.BackgroundTransparency = 1
        ValueLbl.ZIndex = BASE_ZINDEX + 3
        ValueLbl.Parent = Frame
        
        local SliderBg = Instance.new("Frame")
        SliderBg.Size = UDim2.new(1, -12, 0, 10)
        SliderBg.Position = UDim2.new(0, 6, 0, 32)
        SliderBg.BackgroundColor3 = Theme.Darker
        SliderBg.ZIndex = BASE_ZINDEX + 3
        SliderBg.Parent = Frame
        Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 5)
        
        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = color
        Fill.ZIndex = BASE_ZINDEX + 4
        Fill.Parent = SliderBg
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 5)
        
        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 14, 0, 14)
        Knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        Knob.BackgroundColor3 = Theme.Text
        Knob.Text = ""
        Knob.ZIndex = BASE_ZINDEX + 5
        Knob.Parent = SliderBg
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
        local function Update(input)
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            ValueLbl.Text = tostring(val)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Knob.Position = UDim2.new(pos, -7, 0.5, -7)
            callback(val)
        end
        
        Knob.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
        end)
        SliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(input) end
        end)
        
        return Frame
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- MENU ITEMS
    -- ═══════════════════════════════════════════════════════════════════
    
    -- ===== ESP =====
    CreateSection("👁️ ESP OPTIONS")
    
    CreateButton("ESP Master Toggle", "👁️", Theme.Secondary, function(on)
        if on then ESP.Enable() else ESP.Disable() end
    end, true)
    
    CreateButton("Player Names", "📛", Theme.Info, function(on) ActiveFeatures.ESP_Name = on end, true)
    CreateButton("Health Bar", "❤️", Color3.fromRGB(255, 100, 100), function(on) ActiveFeatures.ESP_Health = on end, true)
    CreateButton("Distance", "📏", Color3.fromRGB(255, 200, 100), function(on) ActiveFeatures.ESP_Distance = on end, true)
    CreateButton("Highlight", "✨", Color3.fromRGB(200, 100, 255), function(on) ActiveFeatures.ESP_Highlight = on end, true)
    
    -- ===== AIMBOT =====
    CreateSection("🎯 AIMBOT")
    
    CreateButton("Aimbot (Hold RMB)", "🎯", Theme.Danger, function(on)
        if on then Aimbot.Enable() else Aimbot.Disable() end
    end, true)
    
    CreateButton("Target Teammates", "👥", Color3.fromRGB(150, 150, 255), function(on) ActiveFeatures.AimbotTeam = on end, true)
    CreateSlider("Aimbot FOV", "🎯", Theme.Danger, 50, 500, AimbotFOV, function(v) AimbotFOV = v end)
    CreateSlider("Smoothness", "🎯", Color3.fromRGB(255, 150, 150), 1, 100, 50, function(v) AimbotSmoothness = v / 100 end)
    
    -- ===== PLAYER =====
    CreateSection("👻 PLAYER MODS")
    
    CreateButton("Noclip", "🚪", Color3.fromRGB(150, 100, 255), function(on)
        if on then PlayerMods.Noclip() else ActiveFeatures.Noclip = false end
    end, true)
    
    CreateButton("Fly (WASD+Space)", "🚀", Color3.fromRGB(100, 200, 255), function(on)
        if on then PlayerMods.Fly() else PlayerMods.StopFly() end
    end, true)
    
    CreateButton("Infinite Jump", "🦘", Color3.fromRGB(255, 200, 100), function(on)
        if on then PlayerMods.InfiniteJump() else ActiveFeatures.InfiniteJump = false end
    end, true)
    
    CreateButton("Invisibility", "👻", Theme.Secondary, function(on)
        PlayerMods.Invisibility()
    end, true)
    
    CreateSlider("Walk Speed", "⚡", Theme.Accent, 1, 200, 16, function(v) PlayerMods.SetSpeed(v) end)
    CreateSlider("Jump Power", "🦘", Color3.fromRGB(255, 200, 100), 1, 300, 50, function(v) PlayerMods.SetJump(v) end)
    CreateSlider("Fly Speed", "🚀", Color3.fromRGB(100, 200, 255), 10, 300, 50, function(v) FlySpeed = v end)
    
    -- ===== TOOLS =====
    CreateSection("🔧 TOOLS")
    
    CreateButton("Steal All Tools", "🔫", Theme.Danger, function() StealTool.StealFromAll() end, false)
    CreateButton("Freeze Nearest", "❄️", Color3.fromRGB(100, 200, 255), function()
        local nearest, minDist = nil, math.huge
        local myPos = GetHRP() and GetHRP().Position
        if myPos then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - myPos).Magnitude < minDist then
                        minDist = (hrp.Position - myPos).Magnitude
                        nearest = p
                    end
                end
            end
            if nearest then FreezePlayer.Freeze(nearest) end
        end
    end, false)
    
    CreateButton("Unfreeze All", "❄️✅", Theme.Success, function() FreezePlayer.UnfreezeAll() end, false)
    
    -- ===== REMOTE SPY =====
    CreateSection("🕵️ REMOTE SPY")
    
    CreateButton("Remote Spy", "🕵️", Theme.Purple, function(on)
        if on then RemoteSpy.Enable() else RemoteSpy.Disable() end
    end, true)
    
    CreateButton("Clear Spy Logs", "🗑️", Theme.Danger, function() RemoteSpy.ClearLogs() end, false)
    
    CreateButton("Show Logs (" .. #RemoteSpyLogs .. ")", "📋", Theme.Info, function()
        if #RemoteSpyLogs == 0 then
            Notify("🕵️ Spy", "No logs yet!")
        else
            local logText = "Last 5 Remotes:\n"
            for i = 1, math.min(5, #RemoteSpyLogs) do
                local log = RemoteSpyLogs[i]
                logText = logText .. log.time .. " [" .. log.type .. "] " .. log.message .. "\n"
            end
            Notify("🕵️ Spy Logs", logText)
        end
    end, false)
    
    -- ===== SCRIPT SCANNER =====
    CreateSection("📜 SCRIPT SCANNER")
    
    CreateButton("Scan Sensitive Scripts", "🔍", Theme.Warning, function()
        local found = ScriptScanner.ScanForSensitiveScripts()
        Notify("📜 Scanner", "Found " .. #found .. " scripts!")
    end, false)
    
    CreateButton("Find Editable Scripts", "✏️", Theme.Success, function()
        local editable = ScriptScanner.GetEditableScripts()
        Notify("📜 Scanner", #editable .. " editable scripts!")
    end, false)
    
    CreateButton("Find All Remotes", "📡", Color3.fromRGB(255, 150, 50), function()
        local remotes = InstanceScanner.FindRemotes()
        Notify("📡 Remotes", #remotes .. " found!")
    end, false)
    
    CreateButton("Find All Values", "📊", Theme.Info, function()
        local values = InstanceScanner.FindValues()
        Notify("📊 Values", #values .. " found!")
    end, false)
    
    -- ===== SERVER TOOLS =====
    CreateSection("🖥️ SERVER TOOLS")
    
    CreateButton("Server Hop", "🔄", Theme.Accent, function() ServerTools.ServerHop() end, false)
    CreateButton("Rejoin Server", "🔁", Theme.Success, function() ServerTools.Rejoin() end, false)
    CreateButton("Copy Job ID", "📋", Theme.Info, function() ServerTools.CopyJobId() end, false)
    
    CreateButton("Anti-AFK", "💤", Color3.fromRGB(200, 150, 255), function(on)
        if on then AntiAFK.Enable() else AntiAFK.Disable() end
    end, true)
    
    CreateButton("Anti-Kick", "🛡️", Theme.Success, function(on)
        if on then AntiKick.Enable() else AntiKick.Disable() end
    end, true)
    
    -- ===== NPC CONTROL =====
    CreateSection("🤖 NPC CONTROL")
    
    CreateButton("Control Nearest NPC", "🤖", Theme.Purple, function()
        local npcs = NPCControl.FindNPCs()
        if #npcs > 0 then
            local nearest, minDist = nil, math.huge
            local myPos = GetHRP() and GetHRP().Position
            if myPos then
                for _, npc in ipairs(npcs) do
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - myPos).Magnitude < minDist then
                        minDist = (hrp.Position - myPos).Magnitude
                        nearest = npc
                    end
                end
            end
            if nearest then NPCControl.ControlNPC(nearest) end
        else
            Notify("🤖 NPC", "No NPCs found!")
        end
    end, false)
    
    CreateButton("Stop NPC Control", "🤖❌", Color3.fromRGB(150, 100, 150), function()
        NPCControl.StopControl()
    end, false)
    
    -- ===== TELEPORT =====
    CreateSection("📍 TELEPORT")
    
    CreateButton("TP to Mouse", "🖱️", Theme.Success, function() Teleport.ToMouse() end, false)
    CreateButton("TP to Random Player", "👤", Color3.fromRGB(200, 150, 255), function()
        local others = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(others, p) end
        end
        if #others > 0 then Teleport.ToPlayer(others[math.random(1, #others)]) end
    end, false)
    
    -- ===== SCRIPT HUB =====
    CreateSection("📜 SCRIPT HUB")
    
    for _, scriptInfo in ipairs(ScriptHub.Scripts) do
        CreateButton(scriptInfo.name, scriptInfo.icon, Theme.Info, function()
            ScriptHub.ExecuteScript(scriptInfo)
        end, false)
    end
    
    -- Update canvas
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
    end)
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
    
    print("✅ KlimboMenu v4.0 created with " .. #Content:GetChildren() .. " elements!")
    return MainFrame
end

return KlimboMenu
