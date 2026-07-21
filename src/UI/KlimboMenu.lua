--[[
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ██╗  ██╗██╗     ██╗███╗   ███╗██████╗  ██████╗                       ║
    ║  ██║ ██╔╝██║     ██║████╗ ████║██╔══██╗██╔═══██╗                      ║
    ║  █████╔╝ ██║     ██║██╔████╔██║██████╔╝██║   ██║                      ║
    ║  ██╔═██╗ ██║     ██║██║╚██╔╝██║██╔══██╗██║   ██║                      ║
    ║  ██║  ██╗███████╗██║██║ ╚═╝ ██║██████╔╝╚██████╔╝                      ║
    ║  ╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝                       ║
    ║                                                                        ║
    ║  🔥 KLIMBO MENU v5.0 - ULTIMATE SECRETS EDITION 🔥                    ║
    ║  ✅ Secrets Panel - Full Game Secrets Scanner                          ║
    ║  ✅ PC Optimized - Keyboard Navigation                                 ║
    ║  ✅ Bilingual - Arabic/English                                          ║
    ║  ✅ Mini Notifications                                                  ║
    ║  ✅ Beautiful Space Theme                                               ║
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
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- 🌐 LANGUAGE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local Lang = {
    Current = "ar",
    ar = {
        -- القائمة الرئيسية
        Secrets = "🔮 الأسرار", ESP = "👁️ الرؤية", Aimbot = "🎯 التصويب",
        Player = "👻 اللاعب", Tools = "🔧 الأدوات", Server = "🖥️ السيرفر",
        ScriptHub = "📜 المكتبة", Teleport = "📍 الانتقال", NPC = "🤖 التحكم",
        DisableAll = "🔄 إيقاف الكل", Settings = "⚙️ الإعدادات",
        
        -- Secrets Panel
        SecretsPanel = "🔮 لوحة الأسرار", ScanAll = "🔍 فحص شامل",
        Remotes = "📡 الاتصالات", Scripts = "📜 السكريبتات",
        Values = "📊 القيم", Instances = "📦 العناصر",
        SensitiveScripts = "⚠️ سكريبتات حساسة", EditableScripts = "✏️ قابلة للتعديل",
        RemoteEvents = "📡 أحداث", RemoteFunctions = "📞 دوال",
        AllValues = "📊 كل القيم", Search = "🔍 بحث...",
        Edit = "✏️ تعديل", Copy = "📋 نسخ", Fire = "🔥 إطلاق",
        Refresh = "🔄 تحديث", Export = "📤 تصدير",
        
        -- ESP
        MasterToggle = "👁️ تشغيل ESP", Names = "📛 الأسماء",
        Health = "❤️ الصحة", Distance = "📏 المسافة",
        Highlight = "✨ التمييز", Tracers = "〰️ الخطوط",
        
        -- Aimbot
        AimbotToggle = "🎯 تشغيل التصويب", TargetTeam = "👥 استهداف الفريق",
        FOV = "🎯 مجال الرؤية", Smooth = "🎯 السلاسة",
        
        -- Player
        Noclip = "👻 اختراق الجدران", Fly = "🚀 الطيران",
        InfJump = "🦘 قفز لا نهائي", Invisible = "👻 الاختفاء",
        Speed = "⚡ السرعة", JumpPower = "🦘 قوة القفز", FlySpeed = "🚀 سرعة الطيران",
        
        -- Tools
        StealTools = "🔫 سرقة الأدوات", Freeze = "❄️ تجميد",
        Unfreeze = "❄️✅ إلغاء التجميد", CopyPath = "📋 نسخ المسار",
        
        -- Server
        ServerHop = "🔄 تبديل السيرفر", Rejoin = "🔁 إعادة الدخول",
        CopyJobId = "📋 نسخ Job ID", AntiAFK = "💤 منع الخمول",
        AntiKick = "🛡️ منع الطرد",
        
        -- NPC
        ControlNPC = "🤖 التحكم بـ NPC", StopNPC = "🤖❌ إيقاف التحكم",
        
        -- Teleport
        TpMouse = "🖱️ TP للفأرة", TpRandom = "👤 TP لاعب عشوائي",
        TpAll = "👥 TP للكل",
        
        -- Status
        ON = "✅", OFF = "❌", Enabled = "مفعّل", Disabled = "معطّل",
        Loading = "جاري التحميل...", Error = "خطأ", Success = "نجاح",
        NoData = "لا توجد بيانات", Found = "تم العثور على",
        Copied = "تم النسخ", Fired = "تم الإطلاق",
        
        -- Notifications
        Welcome = "مرحباً بك في Klimbo!", Scanning = "جاري الفحص...",
        ScanComplete = "اكتمل الفحص", NoSecrets = "لا أسرار!",
        RemoteFired = "تم إطلاق الـ Remote", ScriptLoaded = "تم تحميل السكريبت"
    },
    en = {
        Secrets = "🔮 Secrets", ESP = "👁️ ESP", Aimbot = "🎯 Aimbot",
        Player = "👻 Player", Tools = "🔧 Tools", Server = "🖥️ Server",
        ScriptHub = "📜 Scripts", Teleport = "📍 Teleport", NPC = "🤖 NPC",
        DisableAll = "🔄 Disable All", Settings = "⚙️ Settings",
        
        SecretsPanel = "🔮 Secrets Panel", ScanAll = "🔍 Full Scan",
        Remotes = "📡 Remotes", Scripts = "📜 Scripts",
        Values = "📊 Values", Instances = "📦 Instances",
        SensitiveScripts = "⚠️ Sensitive Scripts", EditableScripts = "✏️ Editable",
        RemoteEvents = "📡 Events", RemoteFunctions = "📞 Functions",
        AllValues = "📊 All Values", Search = "🔍 Search...",
        Edit = "✏️ Edit", Copy = "📋 Copy", Fire = "🔥 Fire",
        Refresh = "🔄 Refresh", Export = "📤 Export",
        
        MasterToggle = "👁️ Toggle ESP", Names = "📛 Names",
        Health = "❤️ Health", Distance = "📏 Distance",
        Highlight = "✨ Highlight", Tracers = "〰️ Tracers",
        
        AimbotToggle = "🎯 Toggle Aimbot", TargetTeam = "👥 Target Team",
        FOV = "🎯 FOV", Smooth = "🎯 Smoothness",
        
        Noclip = "👻 Noclip", Fly = "🚀 Fly",
        InfJump = "🦘 Infinite Jump", Invisible = "👻 Invisibility",
        Speed = "⚡ Speed", JumpPower = "🦘 Jump Power", FlySpeed = "🚀 Fly Speed",
        
        StealTools = "🔫 Steal Tools", Freeze = "❄️ Freeze",
        Unfreeze = "❄️✅ Unfreeze", CopyPath = "📋 Copy Path",
        
        ServerHop = "🔄 Server Hop", Rejoin = "🔁 Rejoin",
        CopyJobId = "📋 Copy Job ID", AntiAFK = "💤 Anti-AFK",
        AntiKick = "🛡️ Anti-Kick",
        
        ControlNPC = "🤖 Control NPC", StopNPC = "🤖❌ Stop NPC",
        
        TpMouse = "🖱️ TP to Mouse", TpRandom = "👤 TP Random",
        TpAll = "👥 TP All",
        
        ON = "✅", OFF = "❌", Enabled = "Enabled", Disabled = "Disabled",
        Loading = "Loading...", Error = "Error", Success = "Success",
        NoData = "No data", Found = "Found",
        Copied = "Copied", Fired = "Fired",
        
        Welcome = "Welcome to Klimbo!", Scanning = "Scanning...",
        ScanComplete = "Scan Complete", NoSecrets = "No secrets!",
        RemoteFired = "Remote Fired", ScriptLoaded = "Script Loaded"
    }
}

local function T(key)
    return Lang[Lang.Current][key] or key
end

local function ToggleLang()
    Lang.Current = Lang.Current == "ar" and "en" or "ar"
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 THEME (فضائي جذاب)
-- ═══════════════════════════════════════════════════════════════════════
local Theme = {
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(0, 255, 255),
    Accent = Color3.fromRGB(255, 215, 0),
    Purple = Color3.fromRGB(138, 43, 226),
    Green = Color3.fromRGB(0, 200, 100),
    Orange = Color3.fromRGB(255, 165, 0),
    Dark = Color3.fromRGB(8, 8, 18),
    Darker = Color3.fromRGB(4, 4, 12),
    Card = Color3.fromRGB(15, 15, 32),
    CardHover = Color3.fromRGB(22, 22, 45),
    CardActive = Color3.fromRGB(30, 30, 55),
    Success = Color3.fromRGB(0, 255, 100),
    Danger = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 170),
    Border = Color3.fromRGB(40, 40, 70)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 VARIABLES
-- ═══════════════════════════════════════════════════════════════════════
local Active = {}
local ESPObjects, Connections, RemoteLogs = {}, {}, {}
local FlySpeed, WalkSpeed, JumpPower = 50, 16, 50
local AimbotFOV, AimbotSmooth, AimbotPart = 200, 0.5, "Head"
local NPCControlTarget, CurrentTab = nil, "Secrets"

-- ═══════════════════════════════════════════════════════════════════════
-- 🛡️ UTILITIES
-- ═══════════════════════════════════════════════════════════════════════
local function SafeConnect(event, cb)
    local c = event:Connect(cb)
    table.insert(Connections, c)
    return c
end

local function GetChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function GetHum() local c = GetChar(); return c and c:FindFirstChild("Humanoid") end
local function GetHRP() local c = GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ═══════════════════════════════════════════════════════════════════════
-- 📢 MINI NOTIFICATIONS (صغيرة وجميلة)
-- ═══════════════════════════════════════════════════════════════════════
local NotifContainer = nil

local function CreateNotifContainer()
    if NotifContainer and NotifContainer.Parent then return NotifContainer end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "KlimboNotifs"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 220, 1, 0)
    NotifContainer.Position = UDim2.new(1, -230, 0, 0)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = gui
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotifContainer
    
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = NotifContainer
    
    return NotifContainer
end

local function MiniNotif(message, icon, color, duration)
    local container = CreateNotifContainer()
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 32)
    notif.BackgroundColor3 = Theme.Darker
    notif.BorderSizePixel = 0
    notif.ZIndex = 9999
    notif.Parent = container
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Info
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = notif
    
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 2, 0, 0)
    iconLbl.Text = icon or "ℹ️"
    iconLbl.TextSize = 14
    iconLbl.BackgroundTransparency = 1
    iconLbl.ZIndex = 10000
    iconLbl.Parent = notif
    
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -32, 1, 0)
    msgLbl.Position = UDim2.new(0, 30, 0, 0)
    msgLbl.Text = message
    msgLbl.TextColor3 = Theme.Text
    msgLbl.TextSize = 11
    msgLbl.Font = Enum.Font.GothamBold
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
    msgLbl.BackgroundTransparency = 1
    msgLbl.ZIndex = 10000
    msgLbl.Parent = notif
    
    -- Slide in
    notif.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Fade out
    task.delay(duration or 2, function()
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.2), {
                Transparency = 1
            }):Play()
            TweenService:Create(msgLbl, TweenInfo.new(0.2), {
                TextTransparency = 1
            }):Play()
            TweenService:Create(iconLbl, TweenInfo.new(0.2), {
                TextTransparency = 1
            }):Play()
            task.wait(0.25)
            if notif and notif.Parent then notif:Destroy() end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔮 SECRETS SCANNER (الميزة الرئيسية)
-- ═══════════════════════════════════════════════════════════════════════
local Secrets = {}

Secrets.ScanResults = {
    remotes = {},
    sensitiveScripts = {},
    editableScripts = {},
    values = {},
    hiddenInstances = {},
    connections = {}
}

function Secrets.FullScan()
    MiniNotif(T("Scanning"), "🔍", Theme.Warning, 2)
    
    local results = {
        remotes = {},
        sensitiveScripts = {},
        editableScripts = {},
        values = {},
        hiddenInstances = {},
        connections = {}
    }
    
    -- Keywords حساسة
    local sensitiveKeywords = {
        "admin", "mod", "kick", "ban", "teleport", "purchase", "buy", "sell",
        "trade", "money", "coin", "gem", "robux", "health", "damage", "kill",
        "heal", "spawn", "data", "save", "load", "inventory", "item", "weapon",
        "key", "password", "token", "auth", "login", "secret", "hidden",
        "god", "godmode", "speed", "fly", "noclip", "aimbot", "esp",
        "exploit", "hack", "cheat", "bypass", "anti", "remote", "fire",
        "invoke", "server", "client", "replicated", "storage"
    }
    
    -- فحص كل العناصر
    for _, obj in ipairs(game:GetDescendants()) do
        -- Remotes
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(results.remotes, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj:IsA("RemoteEvent") and "Event" or "Function"
            })
        end
        
        -- Values
        if obj:IsA("ValueBase") then
            local val = nil
            pcall(function() val = obj.Value end)
            table.insert(results.values, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                className = obj.ClassName,
                value = tostring(val)
            })
        end
        
        -- Scripts
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            local source = ""
            pcall(function() source = obj.Source or "" end)
            
            if source and #source > 0 then
                local matches = {}
                local lower = source:lower()
                
                for _, kw in ipairs(sensitiveKeywords) do
                    if lower:find(kw) then
                        table.insert(matches, kw)
                    end
                end
                
                if #matches > 0 then
                    table.insert(results.sensitiveScripts, {
                        instance = obj,
                        name = obj.Name,
                        path = obj:GetFullName(),
                        className = obj.ClassName,
                        keywords = matches,
                        sourceLen = #source
                    })
                end
                
                table.insert(results.editableScripts, {
                    instance = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    className = obj.ClassName,
                    sourceLen = #source
                })
            end
        end
        
        -- Hidden/Interesting Instances
        if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") or obj:IsA("TouchTransmitter") then
            table.insert(results.hiddenInstances, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                className = obj.ClassName
            })
        end
        
        -- Connections (BindableEvents)
        if obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            table.insert(results.connections, {
                instance = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                type = obj:IsA("BindableEvent") and "Event" or "Function"
            })
        end
    end
    
    -- ترتيب النتائج
    table.sort(results.sensitiveScripts, function(a, b) return #a.keywords > #b.keywords end)
    
    Secrets.ScanResults = results
    
    local total = #results.remotes + #results.sensitiveScripts + #results.editableScripts + #results.values
    MiniNotif(T("ScanComplete") .. ": " .. total, "✅", Theme.Success, 3)
    
    return results
end

function Secrets.FireRemote(remote, args)
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args or {}))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args or {}))
        end
        MiniNotif(T("RemoteFired") .. ": " .. remote.Name, "🔥", Theme.Success)
    end)
end

function Secrets.CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text) end
        if toclipboard then toclipboard(text) end
    end)
    MiniNotif(T("Copied"), "📋", Theme.Info)
end

function Secrets.GetSource(instance)
    local result = ""
    pcall(function() result = instance.Source or "" end)
    return result
end

function Secrets.SetSource(instance, newSource)
    local ok = false
    pcall(function()
        instance.Source = newSource
        ok = true
    end)
    if not ok then
        pcall(function()
            if setscriptable then setscriptable(instance, "Source", true) end
            instance.Source = newSource
            ok = true
        end)
    end
    return ok
end

-- ═══════════════════════════════════════════════════════════════════════
-- REMOTE SPY
-- ═══════════════════════════════════════════════════════════════════════
local RemoteSpy = {}

function RemoteSpy.Enable()
    Active.RemoteSpy = true
    RemoteLogs = {}
    
    pcall(function()
        local mt = getrawmetatable(game)
        if setreadonly then setreadonly(mt, false) end
        
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if Active.RemoteSpy then
                if method == "FireServer" or method == "InvokeServer" then
                    local path = ""
                    pcall(function() path = self:GetFullName() end)
                    table.insert(RemoteLogs, 1, {
                        time = os.date("%H:%M:%S"),
                        type = method == "FireServer" and "SEND" or "INVOKE",
                        name = self.Name,
                        path = path,
                        method = method,
                        args = tostring(#args) .. " args"
                    })
                    if #RemoteLogs > 100 then table.remove(RemoteLogs) end
                end
            end
            
            return old(self, ...)
        end)
        
        if setreadonly then setreadonly(mt, true) end
    end)
    
    MiniNotif("Remote Spy ON", "🕵️", Theme.Purple)
end

function RemoteSpy.Disable()
    Active.RemoteSpy = false
    MiniNotif("Remote Spy OFF", "🕵️", Theme.Danger)
end

-- ═══════════════════════════════════════════════════════════════════════
-- OTHER SYSTEMS (ESP, Aimbot, PlayerMods, etc.)
-- ═══════════════════════════════════════════════════════════════════════
-- [Previous implementations remain the same, just updating notifications to use MiniNotif]
local ESP = {}
local Aimbot = {}
local PlayerMods = {}
local ServerTools = {}
local FreezePlayer = { FrozenPlayers = {} }
local StealTool = {}
local Teleport = {}
local NPCControl = {}
local AntiAFK = {}
local AntiKick = {}

-- ESP
function ESP.Enable()
    Active.ESP = true
    Active.ESP_Highlight = true
    Active.ESP_Name = true
    Active.ESP_Health = true
    Active.ESP_Distance = true
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            -- Create ESP
            if not ESPObjects[p] then
                local data = { Highlight = nil, Billboard = nil, Connection = nil }
                data.Connection = SafeConnect(RunService.RenderStepped, function()
                    if not Active.ESP or not p.Character then return end
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if not hrp or not hum then return end
                    
                    if Active.ESP_Highlight then
                        if not data.Highlight or not data.Highlight.Parent then
                            data.Highlight = Instance.new("Highlight")
                            data.Highlight.FillTransparency = 0.6
                            data.Highlight.OutlineTransparency = 0
                            data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            data.Highlight.Parent = p.Character
                        end
                        data.Highlight.Adornee = p.Character
                        data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                    
                    if Active.ESP_Name or Active.ESP_Health or Active.ESP_Distance then
                        local head = p.Character:FindFirstChild("Head")
                        if not data.Billboard or not data.Billboard.Parent then
                            data.Billboard = Instance.new("BillboardGui")
                            data.Billboard.Size = UDim2.new(0, 180, 0, 45)
                            data.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                            data.Billboard.AlwaysOnTop = true
                            data.Billboard.Parent = head or hrp
                            
                            local name = Instance.new("TextLabel")
                            name.Name = "Name"
                            name.Size = UDim2.new(1, 0, 0.5, 0)
                            name.BackgroundTransparency = 1
                            name.TextColor3 = Color3.fromRGB(255, 255, 255)
                            name.TextSize = 13
                            name.Font = Enum.Font.GothamBold
                            name.TextStrokeTransparency = 0
                            name.Parent = data.Billboard
                            
                            local info = Instance.new("TextLabel")
                            info.Name = "Info"
                            info.Size = UDim2.new(1, 0, 0.5, 0)
                            info.Position = UDim2.new(0, 0, 0.5, 0)
                            info.BackgroundTransparency = 1
                            info.TextColor3 = Color3.fromRGB(200, 200, 200)
                            info.TextSize = 10
                            info.Font = Enum.Font.Gotham
                            info.TextStrokeTransparency = 0
                            info.Parent = data.Billboard
                        end
                        
                        local myHRP = GetHRP()
                        local dist = myHRP and math.floor((hrp.Position - myHRP.Position).Magnitude) or 0
                        local hp = math.floor(hum.Health)
                        local maxHp = math.floor(hum.MaxHealth)
                        
                        data.Billboard.Name.Text = Active.ESP_Name and p.Name or ""
                        local infoText = ""
                        if Active.ESP_Distance then infoText = "📏" .. dist .. "m" end
                        if Active.ESP_Health then infoText = infoText .. " ❤️" .. hp .. "/" .. maxHp end
                        data.Billboard.Info.Text = infoText
                    end
                end)
                ESPObjects[p] = data
            end
        end
    end
    MiniNotif("ESP ON", "👁️", Theme.Success)
end

function ESP.Disable()
    Active.ESP = false
    for p, data in pairs(ESPObjects) do
        pcall(function() if data.Highlight then data.Highlight:Destroy() end end)
        pcall(function() if data.Billboard then data.Billboard:Destroy() end end)
        pcall(function() if data.Connection then data.Connection:Disconnect() end end)
    end
    ESPObjects = {}
    MiniNotif("ESP OFF", "👁️", Theme.Danger)
end

-- Aimbot
function Aimbot.Enable()
    Active.Aimbot = true
    SafeConnect(RunService.RenderStepped, function()
        if not Active.Aimbot then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        
        local closest, closestDist = nil, AimbotFOV
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChild("Humanoid")
                local part = p.Character:FindFirstChild(AimbotPart) or hrp
                if hrp and hum and hum.Health > 0 and part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = p
                        end
                    end
                end
            end
        end
        
        if closest then
            local part = closest.Character:FindFirstChild(AimbotPart) or closest.Character:FindFirstChild("HumanoidRootPart")
            if part then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), AimbotSmooth)
            end
        end
    end)
    MiniNotif("Aimbot ON (RMB)", "🎯", Theme.Success)
end

function Aimbot.Disable()
    Active.Aimbot = false
    MiniNotif("Aimbot OFF", "🎯", Theme.Danger)
end

-- PlayerMods
function PlayerMods.Noclip()
    Active.Noclip = not Active.Noclip
    if Active.Noclip then
        SafeConnect(RunService.Stepped, function()
            if Active.Noclip then
                local c = GetChar()
                if c then
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end
        end)
    end
    MiniNotif("Noclip " .. (Active.Noclip and T("Enabled") or T("Disabled")), "🚪", Active.Noclip and Theme.Success or Theme.Danger)
end

function PlayerMods.Fly()
    Active.Fly = not Active.Fly
    local hrp = GetHRP()
    if not hrp then return end
    
    if Active.Fly then
        pcall(function()
            if hrp:FindFirstChild("KlimboFly") then hrp.KlimboFly:Destroy() end
            if hrp:FindFirstChild("KlimboGyro") then hrp.KlimboGyro:Destroy() end
        end)
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "KlimboFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "KlimboGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9000
        bg.Parent = hrp
        
        SafeConnect(RunService.RenderStepped, function()
            if not Active.Fly then return end
            local bv2 = hrp:FindFirstChild("KlimboFly")
            local bg2 = hrp:FindFirstChild("KlimboGyro")
            if not bv2 or not bg2 then return end
            
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
            
            bv2.Velocity = dir * FlySpeed
            bg2.CFrame = Camera.CFrame
        end)
    else
        pcall(function()
            if hrp:FindFirstChild("KlimboFly") then hrp.KlimboFly:Destroy() end
            if hrp:FindFirstChild("KlimboGyro") then hrp.KlimboGyro:Destroy() end
        end)
    end
    MiniNotif("Fly " .. (Active.Fly and T("Enabled") or T("Disabled")), "🚀", Active.Fly and Theme.Success or Theme.Danger)
end

function PlayerMods.InfJump()
    Active.InfJump = not Active.InfJump
    if Active.InfJump then
        SafeConnect(UserInputService.JumpRequest, function()
            if Active.InfJump then
                local h = GetHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
    MiniNotif("Inf Jump " .. (Active.InfJump and T("Enabled") or T("Disabled")), "🦘", Active.InfJump and Theme.Success or Theme.Danger)
end

function PlayerMods.Invisible()
    Active.Invisible = not Active.Invisible
    local c = GetChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = Active.Invisible and 1 or 0
            elseif p:IsA("Decal") then p.Transparency = Active.Invisible and 1 or 0 end
        end
    end
    MiniNotif("Invisible " .. (Active.Invisible and T("Enabled") or T("Disabled")), "👻", Active.Invisible and Theme.Success or Theme.Danger)
end

function PlayerMods.SetSpeed(v) WalkSpeed = v; local h = GetHum(); if h then h.WalkSpeed = v end end
function PlayerMods.SetJump(v) JumpPower = v; local h = GetHum(); if h then h.JumpPower = v; h.UseJumpPower = true end end

-- Server
function ServerTools.ServerHop()
    MiniNotif(T("Loading"), "🔄", Theme.Warning)
    pcall(function()
        local servers = {}
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and result and result.data then
            for _, s in ipairs(result.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

function ServerTools.Rejoin()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end

function ServerTools.CopyJobId()
    pcall(function() if setclipboard then setclipboard(game.JobId) end end)
    MiniNotif(T("Copied"), "📋", Theme.Info)
end

-- Anti-AFK
function AntiAFK.Toggle()
    Active.AntiAFK = not Active.AntiAFK
    if Active.AntiAFK then
        SafeConnect(RunService.Heartbeat, function()
            if Active.AntiAFK then
                pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.zero) end)
            end
        end)
    end
    MiniNotif("Anti-AFK " .. (Active.AntiAFK and T("Enabled") or T("Disabled")), "💤", Active.AntiAFK and Theme.Success or Theme.Danger)
end

-- Anti-Kick
function AntiKick.Toggle()
    Active.AntiKick = not Active.AntiKick
    if Active.AntiKick then
        pcall(function()
            local mt = getrawmetatable(game)
            if setreadonly then setreadonly(mt, false) end
            local old = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "Kick" and Active.AntiKick then return nil end
                return old(self, ...)
            end)
            if setreadonly then setreadonly(mt, true) end
        end)
    end
    MiniNotif("Anti-Kick " .. (Active.AntiKick and T("Enabled") or T("Disabled")), "🛡️", Active.AntiKick and Theme.Success or Theme.Danger)
end

-- Freeze
function FreezePlayer.Freeze(player)
    if not player or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() hrp.Anchored = true end)
    local fx = Instance.new("Part")
    fx.Size = Vector3.new(5, 7, 5)
    fx.Position = hrp.Position
    fx.Anchored = true
    fx.CanCollide = false
    fx.Transparency = 0.5
    fx.Material = Enum.Material.Ice
    fx.Parent = Workspace
    FreezePlayer.FrozenPlayers[player] = { hrp = hrp, fx = fx }
    MiniNotif("Froze: " .. player.Name, "❄️", Theme.Info)
end

function FreezePlayer.UnfreezeAll()
    for p, d in pairs(FreezePlayer.FrozenPlayers) do
        pcall(function() d.hrp.Anchored = false end)
        if d.fx then d.fx:Destroy() end
    end
    FreezePlayer.FrozenPlayers = {}
    MiniNotif(T("Unfreeze"), "❄️", Theme.Success)
end

-- Steal
function StealTool.StealAll()
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            pcall(function()
                if p.Character then
                    for _, c in ipairs(p.Character:GetChildren()) do
                        if c:IsA("Tool") then c:Clone().Parent = LocalPlayer.Backpack; count = count + 1 end
                    end
                end
                local bp = p:FindFirstChild("Backpack")
                if bp then
                    for _, t in ipairs(bp:GetChildren()) do
                        if t:IsA("Tool") then t:Clone().Parent = LocalPlayer.Backpack; count = count + 1 end
                    end
                end
            end)
        end
    end
    MiniNotif("Stole " .. count .. " tools!", "🔫", Theme.Success)
end

-- Teleport
function Teleport.ToMouse()
    local hrp = GetHRP()
    if hrp and Mouse.Hit then
        hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        MiniNotif("Teleported!", "📍", Theme.Success)
    end
end

function Teleport.ToRandom()
    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(others, p) end
    end
    if #others > 0 then
        local target = others[math.random(1, #others)]
        local hrp = GetHRP()
        local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if hrp and tHRP then
            hrp.CFrame = CFrame.new(tHRP.Position + Vector3.new(3, 0, 3))
            MiniNotif("TP: " .. target.Name, "📍", Theme.Success)
        end
    end
end

-- NPC
function NPCControl.Find()
    local npcs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            table.insert(npcs, obj)
        end
    end
    return npcs
end

function NPCControl.Control()
    local npcs = NPCControl.Find()
    if #npcs == 0 then MiniNotif("No NPCs!", "🤖", Theme.Warning); return end
    
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
    
    if nearest then
        NPCControlTarget = nearest
        Camera.CameraSubject = nearest:FindFirstChild("Humanoid")
        MiniNotif("Controlling: " .. nearest.Name, "🤖", Theme.Success)
    end
end

function NPCControl.Stop()
    NPCControlTarget = nil
    Camera.CameraSubject = GetHum()
    MiniNotif("NPC Stopped", "🤖", Theme.Danger)
end

-- Script Hub
local ScriptHub = {
    { name = "Infinite Yield", icon = "⚡", url = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source" },
    { name = "Dex Explorer", icon = "🔍", url = "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua" },
    { name = "Remote Spy", icon = "🕵️", url = "https://raw.githubusercontent.com/infyiff/backup/main/remotespy.lua" },
    { name = "Unnamed ESP", icon = "👁️", url = "https://raw.githubusercontent.com/ic3w0lf22/Unnamed-ESP/master/UnnamedESP.lua" }
}

-- Disable All
function KlimboMenu.DisableAll()
    ESP.Disable()
    Aimbot.Disable()
    if Active.Fly then PlayerMods.Fly() end
    Active.Noclip = false; Active.InfJump = false; Active.Invisible = false
    Active.AntiAFK = false; Active.AntiKick = false; Active.RemoteSpy = false
    local h = GetHum(); if h then h.WalkSpeed = 16 end
    FreezePlayer.UnfreezeAll()
    NPCControl.Stop()
    MiniNotif("All Disabled!", "🔄", Theme.Danger)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖥️ MAIN UI (مُحسّن للكمبيوتر)
-- ═══════════════════════════════════════════════════════════════════════
function KlimboMenu.Create(parent)
    if not parent then return nil end
    
    local BI = 51
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "KlimboMenu"
    Main.Size = UDim2.new(1, 0, 1, 0)
    Main.BackgroundColor3 = Theme.Dark
    Main.BorderSizePixel = 0
    Main.ZIndex = BI
    Main.Parent = parent
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 0, 25)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(6, 6, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 10, 25))
    })
    grad.Rotation = 135
    grad.Parent = Main
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Theme.Darker
    Header.BorderSizePixel = 0
    Header.ZIndex = BI + 1
    Header.Parent = Main
    
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(1, 0, 0, 2)
    hLine.Position = UDim2.new(0, 0, 1, -2)
    hLine.BackgroundColor3 = Theme.Accent
    hLine.BorderSizePixel = 0
    hLine.ZIndex = BI + 2
    hLine.Parent = Header
    
    task.spawn(function()
        while hLine and hLine.Parent do
            TweenService:Create(hLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Primary}):Play()
            task.wait(1.5)
            if not hLine or not hLine.Parent then break end
            TweenService:Create(hLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Secondary}):Play()
            task.wait(1.5)
            if not hLine or not hLine.Parent then break end
            TweenService:Create(hLine, TweenInfo.new(1.5), {BackgroundColor3 = Theme.Accent}):Play()
            task.wait(1.5)
        end
    end)
    
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 160, 0, 24)
    Logo.Position = UDim2.new(0, 8, 0, 4)
    Logo.Text = "👑 KLIMBO v5.0"
    Logo.TextColor3 = Theme.Accent
    Logo.TextSize = 16
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = BI + 2
    Logo.Parent = Header
    
    local GameLbl = Instance.new("TextLabel")
    GameLbl.Size = UDim2.new(0, 200, 0, 14)
    GameLbl.Position = UDim2.new(0, 8, 0, 30)
    GameLbl.Text = "🎮 " .. (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown")
    GameLbl.TextColor3 = Theme.TextDim
    GameLbl.TextSize = 9
    GameLbl.Font = Enum.Font.Gotham
    GameLbl.BackgroundTransparency = 1
    GameLbl.TextXAlignment = Enum.TextXAlignment.Left
    GameLbl.ZIndex = BI + 2
    GameLbl.Parent = Header
    
    -- Header Buttons
    local function HeaderBtn(text, pos, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = pos
        btn.Text = text
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = color
        btn.ZIndex = BI + 3
        btn.Parent = Header
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Language Toggle
    HeaderBtn("🌐", UDim2.new(1, -150, 0.5, -16), Color3.fromRGB(0, 130, 180), function()
        ToggleLang()
        MiniNotif(Lang.Current == "ar" and "عربي" or "English", "🌐", Theme.Info)
        -- Rebuild UI would go here
    end)
    
    -- Disable All
    HeaderBtn("🔄", UDim2.new(1, -110, 0.5, -16), Theme.Danger, function()
        KlimboMenu.DisableAll()
    end)
    
    -- Minimize
    HeaderBtn("—", UDim2.new(1, -70, 0.5, -16), Color3.fromRGB(60, 70, 120), function()
        Main.Visible = false
    end)
    
    -- Close
    HeaderBtn("✕", UDim2.new(1, -35, 0.5, -16), Theme.Danger, function()
        parent.Parent.Parent:Destroy()
    end)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -8, 0, 30)
    TabBar.Position = UDim2.new(0, 4, 0, 52)
    TabBar.BackgroundTransparency = 1
    TabBar.ZIndex = BI + 1
    TabBar.Parent = Main
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.Parent = TabBar
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -8, 1, -88)
    Content.Position = UDim2.new(0, 4, 0, 84)
    Content.BackgroundTransparency = 1
    Content.ZIndex = BI + 1
    Content.Parent = Main
    
    -- Tab Pages
    local Pages = {}
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Theme.Primary
        page.Visible = false
        page.ZIndex = BI + 2
        page.Parent = Content
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.Parent = page
        
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 2)
        pad.PaddingRight = UDim.new(0, 2)
        pad.PaddingTop = UDim.new(0, 2)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.Parent = page
        
        Pages[name] = page
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end)
        
        return page
    end
    
    -- Tab Buttons
    local TabButtons = {}
    local function CreateTab(name, icon, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 1, 0)
        btn.Text = icon
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = Theme.Card
        btn.ZIndex = BI + 2
        btn.Parent = TabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        stroke.Parent = btn
        
        TabButtons[name] = { btn = btn, stroke = stroke, color = color }
        
        btn.MouseButton1Click:Connect(function()
            CurrentTab = name
            for n, page in pairs(Pages) do
                page.Visible = (n == name)
            end
            for n, data in pairs(TabButtons) do
                if n == name then
                    data.btn.BackgroundColor3 = data.color
                    data.stroke.Transparency = 0
                else
                    data.btn.BackgroundColor3 = Theme.Card
                    data.stroke.Transparency = 0.7
                end
            end
        end)
        
        return btn
    end
    
    -- UI Helpers
    local function Section(parent, text)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, -4, 0, 22)
        s.BackgroundTransparency = 1
        s.ZIndex = BI + 3
        s.Parent = parent
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.Text = text
        lbl.TextColor3 = Theme.Primary
        lbl.TextSize = 10
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = BI + 4
        lbl.Parent = s
        
        return s
    end
    
    local function Button(parent, text, icon, color, callback, isToggle)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -4, 0, 36)
        btn.BackgroundColor3 = Theme.Card
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = BI + 3
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        stroke.Parent = btn
        
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size = UDim2.new(0, 28, 0, 28)
        iconLbl.Position = UDim2.new(0, 4, 0.5, -14)
        iconLbl.Text = icon
        iconLbl.TextSize = 16
        iconLbl.BackgroundTransparency = 1
        iconLbl.ZIndex = BI + 4
        iconLbl.Parent = btn
        
        local textLbl = Instance.new("TextLabel")
        textLbl.Size = UDim2.new(1, -85, 1, 0)
        textLbl.Position = UDim2.new(0, 35, 0, 0)
        textLbl.Text = text
        textLbl.TextColor3 = Theme.Text
        textLbl.TextSize = 10
        textLbl.Font = Enum.Font.GothamBold
        textLbl.TextXAlignment = Enum.TextXAlignment.Left
        textLbl.BackgroundTransparency = 1
        textLbl.ZIndex = BI + 4
        textLbl.Parent = btn
        
        local status = Instance.new("TextLabel")
        status.Size = UDim2.new(0, 36, 0, 18)
        status.Position = UDim2.new(1, -40, 0.5, -9)
        status.Text = isToggle and "OFF" or "▶"
        status.TextColor3 = isToggle and Theme.Danger or color
        status.TextSize = 8
        status.Font = Enum.Font.GothamBold
        status.BackgroundColor3 = Theme.Darker
        status.ZIndex = BI + 4
        status.Parent = btn
        Instance.new("UICorner", status).CornerRadius = UDim.new(0, 5)
        
        local on = false
        btn.MouseButton1Click:Connect(function()
            if isToggle then
                on = not on
                status.Text = on and "ON" or "OFF"
                status.TextColor3 = on and Theme.Success or Theme.Danger
                stroke.Transparency = on and 0 or 0.7
                TweenService:Create(btn, TweenInfo.new(0.1), {
                    BackgroundColor3 = on and Theme.CardActive or Theme.Card
                }):Play()
            end
            callback(on)
        end)
        
        btn.MouseEnter:Connect(function()
            if not on then TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.CardHover}):Play() end
        end)
        btn.MouseLeave:Connect(function()
            if not on then TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Card}):Play() end
        end)
        
        return btn
    end
    
    local function Slider(parent, text, icon, color, min, max, default, cb)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -4, 0, 45)
        frame.BackgroundColor3 = Theme.Card
        frame.ZIndex = BI + 3
        frame.Parent = parent
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = 0.7
        stroke.Parent = frame
        
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size = UDim2.new(0, 24, 0, 24)
        iconLbl.Position = UDim2.new(0, 3, 0, 1)
        iconLbl.Text = icon
        iconLbl.TextSize = 14
        iconLbl.BackgroundTransparency = 1
        iconLbl.ZIndex = BI + 4
        iconLbl.Parent = frame
        
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -65, 0, 16)
        nameLbl.Position = UDim2.new(0, 30, 0, 3)
        nameLbl.Text = text
        nameLbl.TextColor3 = Theme.Text
        nameLbl.TextSize = 9
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.BackgroundTransparency = 1
        nameLbl.ZIndex = BI + 4
        nameLbl.Parent = frame
        
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 30, 0, 16)
        valLbl.Position = UDim2.new(1, -35, 0, 3)
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = color
        valLbl.TextSize = 10
        valLbl.Font = Enum.Font.GothamBold
        valLbl.BackgroundTransparency = 1
        valLbl.ZIndex = BI + 4
        valLbl.Parent = frame
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -10, 0, 8)
        bg.Position = UDim2.new(0, 5, 0, 28)
        bg.BackgroundColor3 = Theme.Darker
        bg.ZIndex = BI + 4
        bg.Parent = frame
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = color
        fill.ZIndex = BI + 5
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
        knob.BackgroundColor3 = Theme.Text
        knob.Text = ""
        knob.ZIndex = BI + 6
        knob.Parent = bg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -6, 0.5, -6)
            cb(val)
        end
        
        knob.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
        bg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
        end)
        
        return frame
    end
    
    -- ═══════════════════════════════════════════════════════════════════
    -- CREATE TABS & PAGES
    -- ═══════════════════════════════════════════════════════════════════
    
    -- 🔮 Secrets Tab
    local SecretsPage = CreatePage("Secrets")
    CreateTab("Secrets", "🔮", Theme.Purple)
    
    Section(SecretsPage, "🔮 " .. T("SecretsPanel"))
    
    Button(SecretsPage, T("ScanAll"), "🔍", Theme.Warning, function()
        local results = Secrets.FullScan()
        -- Update UI with results
        task.wait(0.5)
        MiniNotif(#results.remotes .. " Remotes, " .. #results.sensitiveScripts .. " Scripts", "📊", Theme.Info, 3)
    end, false)
    
    Button(SecretsPage, "📡 Remote Spy", "🕵️", Theme.Purple, function(on)
        if on then RemoteSpy.Enable() else RemoteSpy.Disable() end
    end, true)
    
    Button(SecretsPage, T("EditableScripts"), "✏️", Theme.Success, function()
        local editable = ScriptScanner_GetEditable()
        MiniNotif(#editable .. " editable!", "✏️", Theme.Success)
    end, false)
    
    Button(SecretsPage, T("AllValues"), "📊", Theme.Info, function()
        local values = Secrets.ScanResults.values
        MiniNotif(#values .. " values!", "📊", Theme.Info)
    end, false)
    
    Button(SecretsPage, T("RemoteEvents"), "📡", Color3.fromRGB(255, 150, 50), function()
        local events = {}
        for _, r in ipairs(Secrets.ScanResults.remotes) do
            if r.type == "Event" then table.insert(events, r) end
        end
        MiniNotif(#events .. " events!", "📡", Theme.Info)
    end, false)
    
    Button(SecretsPage, T("RemoteFunctions"), "📞", Color3.fromRGB(200, 100, 255), function()
        local funcs = {}
        for _, r in ipairs(Secrets.ScanResults.remotes) do
            if r.type == "Function" then table.insert(funcs, r) end
        end
        MiniNotif(#funcs .. " functions!", "📞", Theme.Info)
    end, false)
    
    -- 👁️ ESP Tab
    local ESPPage = CreatePage("ESP")
    CreateTab("ESP", "👁️", Theme.Secondary)
    
    Section(ESPPage, "👁️ ESP OPTIONS")
    
    Button(ESPPage, T("MasterToggle"), "👁️", Theme.Secondary, function(on)
        if on then ESP.Enable() else ESP.Disable() end
    end, true)
    
    Button(ESPPage, T("Names"), "📛", Theme.Info, function(on) Active.ESP_Name = on end, true)
    Button(ESPPage, T("Health"), "❤️", Color3.fromRGB(255, 100, 100), function(on) Active.ESP_Health = on end, true)
    Button(ESPPage, T("Distance"), "📏", Color3.fromRGB(255, 200, 100), function(on) Active.ESP_Distance = on end, true)
    Button(ESPPage, T("Highlight"), "✨", Color3.fromRGB(200, 100, 255), function(on) Active.ESP_Highlight = on end, true)
    
    -- 🎯 Aimbot Tab
    local AimbotPage = CreatePage("Aimbot")
    CreateTab("Aimbot", "🎯", Theme.Danger)
    
    Section(AimbotPage, "🎯 AIMBOT")
    
    Button(AimbotPage, T("AimbotToggle"), "🎯", Theme.Danger, function(on)
        if on then Aimbot.Enable() else Aimbot.Disable() end
    end, true)
    
    Button(AimbotPage, T("TargetTeam"), "👥", Color3.fromRGB(150, 150, 255), function(on) Active.AimbotTeam = on end, true)
    
    Slider(AimbotPage, T("FOV"), "🎯", Theme.Danger, 50, 500, AimbotFOV, function(v) AimbotFOV = v end)
    Slider(AimbotPage, T("Smooth"), "🎯", Color3.fromRGB(255, 150, 150), 1, 100, 50, function(v) AimbotSmooth = v / 100 end)
    
    -- 👻 Player Tab
    local PlayerPage = CreatePage("Player")
    CreateTab("Player", "👻", Color3.fromRGB(150, 100, 255))
    
    Section(PlayerPage, "👻 PLAYER MODS")
    
    Button(PlayerPage, T("Noclip"), "🚪", Color3.fromRGB(150, 100, 255), function() PlayerMods.Noclip() end, true)
    Button(PlayerPage, T("Fly"), "🚀", Color3.fromRGB(100, 200, 255), function() PlayerMods.Fly() end, true)
    Button(PlayerPage, T("InfJump"), "🦘", Color3.fromRGB(255, 200, 100), function() PlayerMods.InfJump() end, true)
    Button(PlayerPage, T("Invisible"), "👻", Theme.Secondary, function() PlayerMods.Invisible() end, true)
    
    Slider(PlayerPage, T("Speed"), "⚡", Theme.Accent, 1, 200, 16, function(v) PlayerMods.SetSpeed(v) end)
    Slider(PlayerPage, T("JumpPower"), "🦘", Color3.fromRGB(255, 200, 100), 1, 300, 50, function(v) PlayerMods.SetJump(v) end)
    Slider(PlayerPage, T("FlySpeed"), "🚀", Color3.fromRGB(100, 200, 255), 10, 300, 50, function(v) FlySpeed = v end)
    
    -- 🔧 Tools Tab
    local ToolsPage = CreatePage("Tools")
    CreateTab("Tools", "🔧", Theme.Orange)
    
    Section(ToolsPage, "🔧 TOOLS")
    
    Button(ToolsPage, T("StealTools"), "🔫", Theme.Danger, function() StealTool.StealAll() end, false)
    Button(ToolsPage, T("Freeze"), "❄️", Color3.fromRGB(100, 200, 255), function()
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
    
    Button(ToolsPage, T("Unfreeze"), "❄️✅", Theme.Success, function() FreezePlayer.UnfreezeAll() end, false)
    Button(ToolsPage, T("CopyPath"), "📋", Theme.Info, function()
        local hrp = GetHRP()
        if hrp then Secrets.CopyToClipboard(hrp:GetFullName()) end
    end, false)
    
    -- 🖥️ Server Tab
    local ServerPage = CreatePage("Server")
    CreateTab("Server", "🖥️", Color3.fromRGB(100, 150, 255))
    
    Section(ServerPage, "🖥️ SERVER")
    
    Button(ServerPage, T("ServerHop"), "🔄", Theme.Accent, function() ServerTools.ServerHop() end, false)
    Button(ServerPage, T("Rejoin"), "🔁", Theme.Success, function() ServerTools.Rejoin() end, false)
    Button(ServerPage, T("CopyJobId"), "📋", Theme.Info, function() ServerTools.CopyJobId() end, false)
    Button(ServerPage, T("AntiAFK"), "💤", Color3.fromRGB(200, 150, 255), function() AntiAFK.Toggle() end, true)
    Button(ServerPage, T("AntiKick"), "🛡️", Theme.Success, function() AntiKick.Toggle() end, true)
    
    -- 📜 Script Hub Tab
    local HubPage = CreatePage("Hub")
    CreateTab("Hub", "📜", Theme.Info)
    
    Section(HubPage, "📜 SCRIPT HUB")
    
    for _, script in ipairs(ScriptHub) do
        Button(HubPage, script.name, script.icon, Theme.Info, function()
            MiniNotif(T("Loading") .. ": " .. script.name, "📜", Theme.Warning)
            task.spawn(function()
                local ok, err = pcall(function()
                    loadstring(game:HttpGet(script.url))()
                end)
                if ok then MiniNotif(script.name .. " ✓", "✅", Theme.Success)
                else MiniNotif("Failed!", "❌", Theme.Danger) end
            end)
        end, false)
    end
    
    -- 🤖 NPC Tab
    local NPCPage = CreatePage("NPC")
    CreateTab("NPC", "🤖", Theme.Purple)
    
    Section(NPCPage, "🤖 NPC CONTROL")
    
    Button(NPCPage, T("ControlNPC"), "🤖", Theme.Purple, function() NPCControl.Control() end, false)
    Button(NPCPage, T("StopNPC"), "🤖❌", Color3.fromRGB(150, 100, 150), function() NPCControl.Stop() end, false)
    
    -- 📍 Teleport Tab
    local TPPage = CreatePage("Teleport")
    CreateTab("TP", "📍", Theme.Green)
    
    Section(TPPage, "📍 TELEPORT")
    
    Button(TPPage, T("TpMouse"), "🖱️", Theme.Success, function() Teleport.ToMouse() end, false)
    Button(TPPage, T("TpRandom"), "👤", Color3.fromRGB(200, 150, 255), function() Teleport.ToRandom() end, false)
    
    -- Default tab
    Pages["Secrets"].Visible = true
    TabButtons["Secrets"].btn.BackgroundColor3 = TabButtons["Secrets"].color
    TabButtons["Secrets"].stroke.Transparency = 0
    
    -- Keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.K then Main.Visible = not Main.Visible end
    end)
    
    MiniNotif(T("Welcome"), "👑", Theme.Accent, 3)
    print("✅ KlimboMenu v5.0 Created!")
    
    return Main
end

return KlimboMenu
