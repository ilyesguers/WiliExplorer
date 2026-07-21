--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔬 WiliExplorer - Game Analyzer v4.0 (Ultimate)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ الميزات:
    • فحص تدريجي (Batch Scanning) - لا كراش
    • يجد كل السكريبتات والأصوات والصور والRemotes والValues
    • كشف السكريبتات الحساسة
    • 9 تabs للتصنيفات
    • أزرار أكشن لكل عنصر
    • واجهة عرض كاملة
    
    📱 مُحسّن لـ: Delta, Fluxus, Arceus X, Hydrogen
    ═══════════════════════════════════════════════════════════════════════════
]]

local GameAnalyzer = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- ⚙️ الإعدادات
-- ═══════════════════════════════════════════════════════════════════════
local CONFIG = {
    BATCH_SIZE = 20,
    BATCH_DELAY = 0.03,
    MAX_SCAN_TIME = 45,
    MAX_INSTANCES = 150000,
    SKIP_SERVICES = {"CoreGui", "CorePackages", "RobloxPluginGuiService", "TestService", "VRService"},
    SKIP_PATTERNS = {"Anti", "Detect", "Security", "Kick", "Ban", "Check", "Validate", "Monitor"}
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG = Color3.fromRGB(8, 8, 18),
    BG2 = Color3.fromRGB(12, 12, 28),
    Card = Color3.fromRGB(15, 15, 32),
    CardHover = Color3.fromRGB(22, 22, 45),
    Accent = Color3.fromRGB(0, 212, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Green = Color3.fromRGB(0, 255, 100),
    Red = Color3.fromRGB(255, 50, 50),
    Orange = Color3.fromRGB(255, 165, 0),
    Purple = Color3.fromRGB(138, 43, 226),
    Pink = Color3.fromRGB(255, 0, 128),
    Cyan = Color3.fromRGB(0, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 170, 200),
    Border = Color3.fromRGB(40, 40, 70)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 الكلمات المفتاحية
-- ═══════════════════════════════════════════════════════════════════════
local SensitiveKeywords = {
    {word = "admin", category = "security", severity = "high"},
    {word = "mod", category = "security", severity = "high"},
    {word = "kick", category = "security", severity = "high"},
    {word = "ban", category = "security", severity = "high"},
    {word = "password", category = "security", severity = "critical"},
    {word = "token", category = "security", severity = "critical"},
    {word = "auth", category = "security", severity = "high"},
    {word = "secret", category = "security", severity = "high"},
    {word = "bypass", category = "security", severity = "high"},
    {word = "anticheat", category = "security", severity = "high"},
    {word = "anti-cheat", category = "security", severity = "high"},
    {word = "money", category = "economy", severity = "high"},
    {word = "coin", category = "economy", severity = "high"},
    {word = "gem", category = "economy", severity = "high"},
    {word = "diamond", category = "economy", severity = "high"},
    {word = "cash", category = "economy", severity = "high"},
    {word = "currency", category = "economy", severity = "high"},
    {word = "purchase", category = "economy", severity = "high"},
    {word = "trade", category = "economy", severity = "high"},
    {word = "inventory", category = "economy", severity = "high"},
    {word = "health", category = "player", severity = "medium"},
    {word = "damage", category = "player", severity = "medium"},
    {word = "speed", category = "player", severity = "medium"},
    {word = "walkspeed", category = "player", severity = "medium"},
    {word = "godmode", category = "player", severity = "high"},
    {word = "teleport", category = "player", severity = "medium"},
    {word = "datastore", category = "data", severity = "high"},
    {word = "playerdata", category = "data", severity = "high"},
    {word = "fireserver", category = "network", severity = "high"},
    {word = "invokeserver", category = "network", severity = "high"},
    {word = "vip", category = "premium", severity = "high"},
    {word = "premium", category = "premium", severity = "high"},
    {word = "gamepass", category = "premium", severity = "high"}
}

local Keywords = {
    cooldown = {"cooldown", "cool", "cd", "delay", "wait", "timer", "timeout", "debounce"},
    speed = {"speed", "walkspeed", "runspeed", "spd", "velocity", "sprint"},
    currency = {"coin", "cash", "money", "gold", "gem", "diamond", "credit", "point", "score", "kill", "death", "level", "xp", "exp", "power", "strength", "rebirth", "damage", "health", "mana", "energy"},
    important = {"admin", "vip", "premium", "gamepass", "owner", "ban", "kick", "fly", "noclip", "god", "infinite", "unlimited", "bypass", "teleport", "invisible"}
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
GameAnalyzer.Results = {scripts = {}, sounds = {}, images = {}, remotes = {}, values = {}, sensitive = {}, editable = {}, modules = {}, players = {}, gameInfo = {}}

local function Notify(message, icon, color)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = icon or "🔬", Text = message, Duration = 2})
    end)
end

local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), props):Play()
end

local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text) end
        if toclipboard then toclipboard(text) end
    end)
end

local function GetSource(instance)
    local source = ""
    pcall(function() source = instance.Source or "" end)
    return source
end

local function CheckSensitive(source)
    local matches = {}
    local lower = source:lower()
    for _, kw in ipairs(SensitiveKeywords) do
        if lower:find(kw.word) then table.insert(matches, kw) end
    end
    return matches
end

local function MatchKeywords(name, category)
    if not name or not Keywords[category] then return false, nil end
    local lowerName = name:lower()
    for _, keyword in ipairs(Keywords[category]) do
        if lowerName:find(keyword) then return true, keyword end
    end
    return false, nil
end

local function FormatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then return string.format("%.1fK", n/1000)
    else return tostring(n) end
end

local function IsProtected(instance)
    if not instance then return true end
    local name = ""
    pcall(function() name = instance.Name end)
    for _, pattern in ipairs(CONFIG.SKIP_PATTERNS) do
        if name:lower():find(pattern:lower()) then return true end
    end
    local canAccess = pcall(function() local _ = instance.ClassName; local _ = instance.Parent end)
    return not canAccess
end

local function GetSourceSafe(instance)
    local result = {source = "", method = "none", success = false, isProtected = false}
    if not instance then return result end
    local isScript = false
    pcall(function() isScript = instance:IsA("BaseScript") or instance:IsA("ModuleScript") end)
    if not isScript then return result end
    local ok1, src1 = pcall(function() return instance.Source end)
    if ok1 and src1 and #src1 > 0 then result.source = src1; result.method = "direct"; result.success = true; return result end
    if decompile then
        local ok2, src2 = pcall(function() return decompile(instance) end)
        if ok2 and src2 and #src2 > 0 then result.source = src2; result.method = "decompile"; result.success = true; return result end
    end
    if getscriptbytecode then
        local ok3, bytecode = pcall(function() return getscriptbytecode(instance) end)
        if ok3 and bytecode then result.source = "-- [BYTECODE] Length: " .. #bytecode; result.method = "bytecode"; result.success = true; return result end
    end
    result.isProtected = true
    result.source = "-- ⚠️ Protected Script"
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 الفحص الشامل (مع Batch Processing)
-- ═══════════════════════════════════════════════════════════════════════
function GameAnalyzer.Scan(onProgress)
    local results = {
        scripts = {}, sounds = {}, images = {}, remotes = {}, values = {},
        sensitive = {}, editable = {}, modules = {}, players = {}, gameInfo = {},
        cooldowns = {}, speeds = {}, currencies = {}, important = {},
        summary = {
            totalScanned = 0, totalScripts = 0, totalSounds = 0, totalImages = 0,
            totalRemotes = 0, totalValues = 0, totalSensitive = 0, totalEditable = 0,
            totalProtected = 0, scanTime = 0
        },
        errors = {}
    }

    local startTime = tick()
    local scannedCount = 0
    local batchCount = 0

    -- معلومات اللعبة
    pcall(function()
        results.gameInfo = {
            name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown",
            placeId = game.PlaceId, jobId = game.JobId,
            playerCount = #Players:GetPlayers(), maxPlayers = Players.MaxPlayers,
            serverTime = math.floor(workspace.DistributedGameTime),
            fps = math.floor(1/RunService.RenderStepped:Wait())
        }
    end)

    -- معلومات اللاعبين
    for _, player in ipairs(Players:GetPlayers()) do
        local playerInfo = {name = player.Name, displayName = player.DisplayName, userId = player.UserId, accountAge = player.AccountAge, team = player.Team and player.Team.Name or "None"}
        pcall(function()
            if player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then playerInfo.health = math.floor(hum.Health); playerInfo.maxHealth = math.floor(hum.MaxHealth); playerInfo.walkSpeed = hum.WalkSpeed; playerInfo.jumpPower = hum.JumpPower end
            end
        end)
        table.insert(results.players, playerInfo)
    end

    -- جمع الخدمات
    local servicesToScan = {}
    local function AddService(name)
        for _, skip in ipairs(CONFIG.SKIP_SERVICES) do if name == skip then return end end
        local ok, service = pcall(function() return game:GetService(name) end)
        if ok and service then table.insert(servicesToScan, {name = name, service = service}) end
    end

    AddService("Workspace"); AddService("ReplicatedStorage"); AddService("ReplicatedFirst")
    AddService("Lighting"); AddService("StarterGui"); AddService("StarterPack"); AddService("StarterPlayer")
    AddService("Teams"); AddService("SoundService"); AddService("MaterialService"); AddService("Chat")

    pcall(function()
        local player = Players.LocalPlayer
        if player then
            table.insert(servicesToScan, {name = "LocalPlayer", service = player})
            if player.Character then table.insert(servicesToScan, {name = "Character", service = player.Character}) end
            local pg = player:FindFirstChild("PlayerGui"); if pg then table.insert(servicesToScan, {name = "PlayerGui", service = pg}) end
            local bp = player:FindFirstChild("Backpack"); if bp then table.insert(servicesToScan, {name = "Backpack", service = bp}) end
        end
    end)

    -- معالجة عنصر واحد
    local function ProcessInstance(instance)
        if IsProtected(instance) then results.summary.totalProtected = results.summary.totalProtected + 1; return end

        local name, className, fullName = "", "", ""
        pcall(function() name = instance.Name; className = instance.ClassName; fullName = instance:GetFullName() end)

        -- Values
        local isValue = false
        pcall(function() isValue = instance:IsA("ValueBase") end)
        if isValue then
            local valStr, canEdit = "", false
            pcall(function() valStr = tostring(instance.Value); local old = instance.Value; instance.Value = old; canEdit = true end)
            local entry = {instance = instance, name = name, className = className, path = fullName, value = valStr, valueStr = valStr, editable = canEdit, parentName = instance.Parent and instance.Parent.Name or "Unknown"}
            table.insert(results.values, entry)
            if canEdit then results.summary.totalEditable = results.summary.totalEditable + 1 end
            local isCD, cdKey = MatchKeywords(name, "cooldown"); if isCD then entry.keyword = cdKey; entry.category = "Cooldown"; table.insert(results.cooldowns, entry) end
            local isSP, spKey = MatchKeywords(name, "speed"); if isSP then entry.keyword = spKey; entry.category = "Speed"; table.insert(results.speeds, entry) end
            local isCU, cuKey = MatchKeywords(name, "currency"); if isCU then entry.keyword = cuKey; entry.category = "Currency"; table.insert(results.currencies, entry) end
            local isIM, imKey = MatchKeywords(name, "important"); if isIM then entry.keyword = imKey; entry.category = "Important"; table.insert(results.important, entry) end
            results.summary.totalValues = results.summary.totalValues + 1
        end

        -- Remotes
        local isRemote = false
        pcall(function() isRemote = instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") end)
        if isRemote then
            local remoteEntry = {instance = instance, name = name, className = className, path = fullName, isEvent = instance:IsA("RemoteEvent"), isFunction = instance:IsA("RemoteFunction"), parentName = instance.Parent and instance.Parent.Name or "Unknown", interesting = false}
            for category, _ in pairs(Keywords) do
                local match, _ = MatchKeywords(name, category); if match then remoteEntry.interesting = true; break end
            end
            table.insert(results.remotes, remoteEntry)
            results.summary.totalRemotes = results.summary.totalRemotes + 1
        end

        -- Scripts
        local isScript = false
        pcall(function() isScript = instance:IsA("LocalScript") or instance:IsA("ModuleScript") or instance:IsA("Script") end)
        if isScript then
            local sourceData = GetSourceSafe(instance)
            local scriptInfo = {instance = instance, name = name, className = className, path = fullName, readable = sourceData.success, sourceLength = #sourceData.source, method = sourceData.method, keywords = {}, isSensitive = false, severity = "none", editable = false}
            if sourceData.success and #sourceData.source > 0 then
                local matches = CheckSensitive(sourceData.source)
                if #matches > 0 then
                    scriptInfo.isSensitive = true; scriptInfo.keywords = matches
                    for _, m in ipairs(matches) do
                        if m.severity == "critical" then scriptInfo.severity = "critical"
                        elseif m.severity == "high" and scriptInfo.severity ~= "critical" then scriptInfo.severity = "high"
                        elseif m.severity == "medium" and scriptInfo.severity == "none" then scriptInfo.severity = "medium" end
                    end
                    table.insert(results.sensitive, scriptInfo)
                    results.summary.totalSensitive = results.summary.totalSensitive + 1
                end
                if instance:IsA("LocalScript") or instance:IsA("ModuleScript") then scriptInfo.editable = true; table.insert(results.editable, scriptInfo); results.summary.totalEditable = results.summary.totalEditable + 1 end
            end
            table.insert(results.scripts, scriptInfo)
            results.summary.totalScripts = results.summary.totalScripts + 1
            if instance:IsA("ModuleScript") then table.insert(results.modules, scriptInfo) end
        end

        -- Sounds
        local isSound = false
        pcall(function() isSound = instance:IsA("Sound") end)
        if isSound then
            table.insert(results.sounds, {instance = instance, name = name, path = fullName, soundId = instance.SoundId, volume = instance.Volume, pitch = instance.PlaybackSpeed, looped = instance.Looped, isPlaying = instance.IsPlaying, timeLength = instance.TimeLength, parentName = instance.Parent and instance.Parent.Name or "Unknown"})
            results.summary.totalSounds = results.summary.totalSounds + 1
        end

        -- Images
        local isImage = false
        pcall(function() isImage = instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") end)
        if isImage then
            local imageId = ""
            pcall(function() if instance:IsA("Decal") or instance:IsA("Texture") then imageId = instance.Texture else imageId = instance.Image end end)
            table.insert(results.images, {instance = instance, name = name, className = className, path = fullName, imageId = imageId, parentName = instance.Parent and instance.Parent.Name or "Unknown"})
            results.summary.totalImages = results.summary.totalImages + 1
        end
    end

    -- الفحص التدريجي
    for _, serviceData in ipairs(servicesToScan) do
        if (tick() - startTime) > CONFIG.MAX_SCAN_TIME then table.insert(results.errors, "Scan timeout"); break end
        if scannedCount >= CONFIG.MAX_INSTANCES then table.insert(results.errors, "Max instances limit"); break end

        if onProgress then pcall(function() onProgress({current = scannedCount, total = CONFIG.MAX_INSTANCES, percent = math.floor((scannedCount/CONFIG.MAX_INSTANCES)*100), currentService = serviceData.name}) end) end

        local descendants = {}
        pcall(function() descendants = serviceData.service:GetDescendants() end)

        for i, instance in ipairs(descendants) do
            if (tick() - startTime) > CONFIG.MAX_SCAN_TIME then break end
            pcall(function() ProcessInstance(instance) end)
            scannedCount = scannedCount + 1
            batchCount = batchCount + 1
            if batchCount >= CONFIG.BATCH_SIZE then batchCount = 0; task.wait(CONFIG.BATCH_DELAY) end
        end
        task.wait(CONFIG.BATCH_DELAY * 2)
    end

    -- ترتيب السكريبتات الحساسة
    table.sort(results.sensitive, function(a, b)
        local severityOrder = {critical = 1, high = 2, medium = 3, low = 4, none = 5}
        return (severityOrder[a.severity] or 5) < (severityOrder[b.severity] or 5)
    end)

    results.summary.totalScanned = scannedCount
    results.summary.scanTime = tick() - startTime
    GameAnalyzer.Results = results
    return results
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖥️ واجهة العرض
-- ═══════════════════════════════════════════════════════════════════════
function GameAnalyzer.OpenUI(parent)
    local results = GameAnalyzer.Results
    if results.summary.totalScanned == 0 then Notify("قم بعمل Scan أولاً!", "⚠️", C.Orange); return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliAnalyzerUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local overlay = Instance.new("Frame"); overlay.Size = UDim2.new(1, 0, 1, 0); overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0); overlay.BackgroundTransparency = 0.4; overlay.ZIndex = 998; overlay.Parent = gui

    local window = Instance.new("Frame"); window.Size = UDim2.new(0.95, 0, 0.92, 0); window.Position = UDim2.new(0.025, 0, 0.04, 0); window.BackgroundColor3 = C.BG; window.BorderSizePixel = 0; window.ZIndex = 999; window.Parent = gui
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 14)
    local ws = Instance.new("UIStroke"); ws.Color = C.Accent; ws.Thickness = 2; ws.Parent = window

    -- Header
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 45); header.BackgroundColor3 = C.BG2; header.BorderSizePixel = 0; header.ZIndex = 1000; header.Parent = window
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
    local hl = Instance.new("Frame"); hl.Size = UDim2.new(1, 0, 0, 2); hl.Position = UDim2.new(0, 0, 1, -2); hl.BackgroundColor3 = C.Accent; hl.BorderSizePixel = 0; hl.ZIndex = 1001; hl.Parent = header

    local title = Instance.new("TextLabel"); title.Size = UDim2.new(0.5, 0, 1, 0); title.Position = UDim2.new(0, 12, 0, 0); title.Text = "🔬 Game Analyzer - " .. results.gameInfo.name; title.TextColor3 = C.Accent; title.TextSize = 16; title.Font = Enum.Font.GothamBold; title.TextXAlignment = Enum.TextXAlignment.Left; title.TextTruncate = Enum.TextTruncate.AtEnd; title.BackgroundTransparency = 1; title.ZIndex = 1001; title.Parent = header

    local infoLbl = Instance.new("TextLabel"); infoLbl.Size = UDim2.new(0.4, 0, 1, 0); infoLbl.Position = UDim2.new(0.5, 0, 0, 0)
    infoLbl.Text = string.format("📊 %s | 📜 %s | 🔊 %s | 🖼️ %s", FormatNumber(results.summary.totalScanned), results.summary.totalScripts, results.summary.totalSounds, results.summary.totalImages)
    infoLbl.TextColor3 = C.TextDim; infoLbl.TextSize = 10; infoLbl.Font = Enum.Font.Gotham; infoLbl.BackgroundTransparency = 1; infoLbl.ZIndex = 1001; infoLbl.Parent = header

    local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -38, 0.5, -15); closeBtn.Text = "✕"; closeBtn.TextColor3 = C.Text; closeBtn.TextSize = 14; closeBtn.Font = Enum.Font.GothamBold; closeBtn.BackgroundColor3 = C.Red; closeBtn.ZIndex = 1001; closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Tabs
    local tabBar = Instance.new("Frame"); tabBar.Size = UDim2.new(1, -16, 0, 28); tabBar.Position = UDim2.new(0, 8, 0, 48); tabBar.BackgroundTransparency = 1; tabBar.ZIndex = 1000; tabBar.Parent = window
    local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 4); tl.Parent = tabBar

    local content = Instance.new("Frame"); content.Size = UDim2.new(1, -16, 1, -85); content.Position = UDim2.new(0, 8, 0, 80); content.BackgroundTransparency = 1; content.ZIndex = 1000; content.Parent = window

    local pages, tabButtons = {}, {}

    local function CreateTab(name, icon, color, count)
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(0, 85, 1, 0); btn.Text = icon .. " " .. tostring(count or 0); btn.TextSize = 10; btn.Font = Enum.Font.GothamBold; btn.BackgroundColor3 = C.Card; btn.ZIndex = 1001; btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = 1; s.Transparency = 0.6; s.Parent = btn
        local page = Instance.new("ScrollingFrame"); page.Name = name; page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = color; page.Visible = false; page.ZIndex = 1001; page.Parent = content
        local pl = Instance.new("UIListLayout"); pl.Padding = UDim.new(0, 4); pl.Parent = page
        local pp = Instance.new("UIPadding"); pp.PaddingLeft = UDim.new(0, 2); pp.PaddingRight = UDim.new(0, 2); pp.PaddingTop = UDim.new(0, 2); pp.PaddingBottom = UDim.new(0, 8); pp.Parent = page
        pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 10) end)
        pages[name] = page; tabButtons[name] = {btn = btn, stroke = s, color = color}
        btn.MouseButton1Click:Connect(function()
            for n, p in pairs(pages) do p.Visible = (n == name) end
            for n, d in pairs(tabButtons) do d.btn.BackgroundColor3 = (n == name) and d.color or C.Card; d.btn.TextColor3 = (n == name) and C.BG or C.Text; d.stroke.Transparency = (n == name) and 0 or 0.6 end
        end)
        return page
    end

    local function CreateItemCard(page, item, itemType)
        local card = Instance.new("Frame"); card.Size = UDim2.new(1, -4, 0, 48); card.BackgroundColor3 = C.Card; card.ZIndex = 1002; card.Parent = page
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cs = Instance.new("UIStroke"); cs.Color = C.Border; cs.Thickness = 1; cs.Transparency = 0.5; cs.Parent = card

        local ti = Instance.new("TextLabel"); ti.Size = UDim2.new(0, 30, 0, 30); ti.Position = UDim2.new(0, 5, 0.5, -15); ti.TextSize = 16; ti.BackgroundTransparency = 1; ti.ZIndex = 1003; ti.Parent = card
        local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(0.45, 0, 0, 18); nl.Position = UDim2.new(0, 38, 0, 4); nl.TextColor3 = C.Text; nl.TextSize = 11; nl.Font = Enum.Font.GothamBold; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.TextTruncate = Enum.TextTruncate.AtEnd; nl.BackgroundTransparency = 1; nl.ZIndex = 1003; nl.Parent = card
        local pl2 = Instance.new("TextLabel"); pl2.Size = UDim2.new(0.45, 0, 0, 14); pl2.Position = UDim2.new(0, 38, 0, 24); pl2.TextColor3 = C.TextDim; pl2.TextSize = 8; pl2.Font = Enum.Font.Gotham; pl2.TextXAlignment = Enum.TextXAlignment.Left; pl2.TextTruncate = Enum.TextTruncate.AtEnd; pl2.BackgroundTransparency = 1; pl2.ZIndex = 1003; pl2.Parent = card
        local badge = Instance.new("TextLabel"); badge.Size = UDim2.new(0, 55, 0, 18); badge.Position = UDim2.new(0.5, 5, 0.5, -9); badge.TextSize = 8; badge.Font = Enum.Font.GothamBold; badge.TextColor3 = C.BG; badge.ZIndex = 1003; badge.Parent = card
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)

        local function AB(text, posX, color, cb)
            local b = Instance.new("TextButton"); b.Size = UDim2.new(0, 45, 0, 20); b.Position = UDim2.new(0.7, posX, 0.5, -10); b.Text = text; b.TextColor3 = C.Text; b.TextSize = 8; b.Font = Enum.Font.GothamBold; b.BackgroundColor3 = color; b.ZIndex = 1003; b.Parent = card
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); b.MouseButton1Click:Connect(cb)
        end

        if itemType == "script" then
            ti.Text = item.className == "LocalScript" and "📱" or item.className == "ModuleScript" and "📦" or "📜"
            nl.Text = item.name; pl2.Text = item.path
            if item.isSensitive then badge.Text = item.severity:upper(); badge.BackgroundColor3 = item.severity == "critical" and C.Red or item.severity == "high" and C.Orange or C.Gold; cs.Color = badge.BackgroundColor3
            elseif item.readable then badge.Text = item.editable and "EDIT" or "READ"; badge.BackgroundColor3 = item.editable and C.Green or C.Accent
            else badge.Text = "LOCKED"; badge.BackgroundColor3 = Color3.fromRGB(100, 100, 130) end
            if item.readable then AB("👁️", 0, C.Accent, function() CopyToClipboard(GetSource(item.instance)); Notify("تم نسخ الكود!", "📋", C.Green) end) end
            AB("📋", 50, Color3.fromRGB(60, 70, 110), function() CopyToClipboard(item.path); Notify("تم نسخ المسار!", "📋", C.Green) end)
        elseif itemType == "sound" then
            ti.Text = "🔊"; nl.Text = item.name; pl2.Text = item.soundId ~= "" and item.soundId or item.path
            badge.Text = item.isPlaying and "▶ PLAY" or "STOP"; badge.BackgroundColor3 = item.isPlaying and C.Green or Color3.fromRGB(100, 100, 130)
            AB("▶", 0, C.Green, function() pcall(function() if item.instance.IsPlaying then item.instance:Stop(); badge.Text = "STOP"; badge.BackgroundColor3 = Color3.fromRGB(100, 100, 130) else item.instance:Play(); badge.Text = "▶ PLAY"; badge.BackgroundColor3 = C.Green end end) end)
            AB("📋", 50, Color3.fromRGB(60, 70, 110), function() CopyToClipboard(item.soundId); Notify("تم نسخ Sound ID!", "📋", C.Green) end)
        elseif itemType == "image" then
            ti.Text = "🖼️"; nl.Text = item.name; pl2.Text = item.imageId ~= "" and item.imageId or item.path
            badge.Text = item.className; badge.BackgroundColor3 = C.Pink
            AB("📋", 0, Color3.fromRGB(60, 70, 110), function() CopyToClipboard(item.imageId); Notify("تم نسخ Image ID!", "📋", C.Green) end)
        elseif itemType == "remote" then
            ti.Text = item.isEvent and "📡" or "📞"; nl.Text = item.name; pl2.Text = item.path
            badge.Text = item.isEvent and "EVENT" or "FUNC"; badge.BackgroundColor3 = item.isEvent and C.Orange or C.Purple
            AB("🔥", 0, C.Red, function() pcall(function() if item.isEvent then item.instance:FireServer(); Notify("تم إطلاق الـ Remote!", "🔥", C.Orange) else local r = item.instance:InvokeServer(); Notify("النتيجة: " .. tostring(r):sub(1, 30), "📞", C.Accent) end end) end)
            AB("📋", 50, Color3.fromRGB(60, 70, 110), function() CopyToClipboard(item.path); Notify("تم نسخ المسار!", "📋", C.Green) end)
        elseif itemType == "value" then
            ti.Text = "📊"; nl.Text = item.name; pl2.Text = item.className .. " = " .. item.valueStr
            badge.Text = item.className:gsub("Value", ""); badge.BackgroundColor3 = C.Cyan
            AB("✏️", 0, C.Accent, function() pcall(function() if item.instance:IsA("NumberValue") or item.instance:IsA("IntValue") then item.instance.Value = tonumber(item.valueStr) or item.value elseif item.instance:IsA("BoolValue") then item.instance.Value = not item.value end end); Notify("تم التعديل!", "✅", C.Green) end)
            AB("📋", 50, Color3.fromRGB(60, 70, 110), function() CopyToClipboard(item.valueStr); Notify("تم نسخ القيمة!", "📋", C.Green) end)
        end

        card.MouseEnter:Connect(function() Tween(card, {BackgroundColor3 = C.CardHover}, 0.15) end)
        card.MouseLeave:Connect(function() Tween(card, {BackgroundColor3 = C.Card}, 0.15) end)
    end

    -- إنشاء التabs
    CreateTab("Sensitive", "🔒", C.Red, #results.sensitive)
    CreateTab("Editable", "✏️", C.Green, #results.editable)
    CreateTab("Scripts", "📜", C.Accent, #results.scripts)
    CreateTab("Sounds", "🔊", C.Green, #results.sounds)
    CreateTab("Images", "🖼️", C.Pink, #results.images)
    CreateTab("Remotes", "📡", C.Orange, #results.remotes)
    CreateTab("Values", "📊", C.Cyan, #results.values)
    CreateTab("Game", "🎮", C.Gold, 1)
    CreateTab("Players", "👥", C.Accent, #results.players)

    -- ملء المحتوى
    for _, s in ipairs(results.sensitive) do CreateItemCard(pages["Sensitive"], s, "script") end
    for _, s in ipairs(results.editable) do CreateItemCard(pages["Editable"], s, "script") end
    for _, s in ipairs(results.scripts) do CreateItemCard(pages["Scripts"], s, "script") end
    for _, s in ipairs(results.sounds) do CreateItemCard(pages["Sounds"], s, "sound") end
    for _, s in ipairs(results.images) do CreateItemCard(pages["Images"], s, "image") end
    for _, s in ipairs(results.remotes) do CreateItemCard(pages["Remotes"], s, "remote") end
    for _, s in ipairs(results.values) do CreateItemCard(pages["Values"], s, "value") end

    -- معلومات اللعبة
    local gc = Instance.new("Frame"); gc.Size = UDim2.new(1, -4, 0, 180); gc.BackgroundColor3 = C.Card; gc.ZIndex = 1002; gc.Parent = pages["Game"]
    Instance.new("UICorner", gc).CornerRadius = UDim.new(0, 10)
    local gt = Instance.new("TextLabel"); gt.Size = UDim2.new(1, -16, 1, -10); gt.Position = UDim2.new(0, 8, 0, 5)
    gt.Text = string.format("🎮 Game: %s\n📍 Place ID: %s\n👥 Players: %d/%d\n⏱️ Server Time: %ds\n🎯 FPS: %d\n\n📊 Scan Results:\n• Total: %s | Scripts: %d | Sounds: %d\n• Images: %d | Remotes: %d | Values: %d\n• Sensitive: %d | Editable: %d", results.gameInfo.name, results.gameInfo.placeId, results.gameInfo.playerCount, results.gameInfo.maxPlayers, results.gameInfo.serverTime, results.gameInfo.fps, FormatNumber(results.summary.totalScanned), results.summary.totalScripts, results.summary.totalSounds, results.summary.totalImages, results.summary.totalRemotes, results.summary.totalValues, results.summary.totalSensitive, results.summary.totalEditable)
    gt.TextColor3 = C.Text; gt.TextSize = 11; gt.Font = Enum.Font.Gotham; gt.TextXAlignment = Enum.TextXAlignment.Left; gt.TextYAlignment = Enum.TextYAlignment.Top; gt.BackgroundTransparency = 1; gt.ZIndex = 1003; gt.Parent = gc

    -- اللاعبين
    for _, p in ipairs(results.players) do
        local pc = Instance.new("Frame"); pc.Size = UDim2.new(1, -4, 0, 50); pc.BackgroundColor3 = C.Card; pc.ZIndex = 1002; pc.Parent = pages["Players"]
        Instance.new("UICorner", pc).CornerRadius = UDim.new(0, 8)
        local pn = Instance.new("TextLabel"); pn.Size = UDim2.new(0.5, 0, 0, 16); pn.Position = UDim2.new(0, 8, 0, 4); pn.Text = "👤 " .. p.name; pn.TextColor3 = C.Text; pn.TextSize = 10; pn.Font = Enum.Font.GothamBold; pn.TextXAlignment = Enum.TextXAlignment.Left; pn.BackgroundTransparency = 1; pn.ZIndex = 1003; pn.Parent = pc
        local pi = Instance.new("TextLabel"); pi.Size = UDim2.new(1, -12, 0, 12); pi.Position = UDim2.new(0, 8, 0, 24)
        pi.Text = string.format("ID: %d | Team: %s | HP: %s/%s | Speed: %s", p.userId, p.team, p.health or "?", p.maxHealth or "?", p.walkSpeed or "?")
        pi.TextColor3 = C.TextDim; pi.TextSize = 8; pi.Font = Enum.Font.Gotham; pi.TextXAlignment = Enum.TextXAlignment.Left; pi.BackgroundTransparency = 1; pi.ZIndex = 1003; pi.Parent = pc
    end

    if tabButtons["Sensitive"] then tabButtons["Sensitive"].btn.MouseButton1Click:Fire() end
    overlay.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then gui:Destroy() end end)
    return gui
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 دوال مساعدة إضافية
-- ═══════════════════════════════════════════════════════════════════════
function GameAnalyzer.QuickScan()
    local oldBatch, oldMax, oldTime = CONFIG.BATCH_SIZE, CONFIG.MAX_INSTANCES, CONFIG.MAX_SCAN_TIME
    CONFIG.BATCH_SIZE = 50; CONFIG.MAX_INSTANCES = 5000; CONFIG.MAX_SCAN_TIME = 10
    local results = GameAnalyzer.Scan()
    CONFIG.BATCH_SIZE = oldBatch; CONFIG.MAX_INSTANCES = oldMax; CONFIG.MAX_SCAN_TIME = oldTime
    return results
end

function GameAnalyzer.SetValueSafe(instance, newValue)
    local result = {success = false, error = ""}
    if not instance then result.error = "Instance is nil"; return result end
    local isValue = false
    pcall(function() isValue = instance:IsA("ValueBase") end)
    if not isValue then result.error = "Not a ValueBase"; return result end
    local ok, err = pcall(function() instance.Value = newValue end)
    if ok then result.success = true else result.error = tostring(err) end
    return result
end

function GameAnalyzer.FreezeValue(instance, value)
    if not _G.WiliFrozenValues then _G.WiliFrozenValues = {} end
    local id = tostring(instance)
    if _G.WiliFrozenValues[id] then _G.WiliFrozenValues[id].active = false end
    local freezeData = {active = true, instance = instance, value = value}
    _G.WiliFrozenValues[id] = freezeData
    task.spawn(function() while freezeData.active and instance and instance.Parent do pcall(function() instance.Value = value end); task.wait(0.1) end end)
    return true
end

function GameAnalyzer.UnfreezeValue(instance)
    if not _G.WiliFrozenValues then return false end
    local id = tostring(instance)
    if _G.WiliFrozenValues[id] then _G.WiliFrozenValues[id].active = false; _G.WiliFrozenValues[id] = nil; return true end
    return false
end

function GameAnalyzer.UnfreezeAll()
    if not _G.WiliFrozenValues then return end
    for id, data in pairs(_G.WiliFrozenValues) do data.active = false end
    _G.WiliFrozenValues = {}
end

function GameAnalyzer.GetResults() return GameAnalyzer.Results end
function GameAnalyzer.GetSummary() return GameAnalyzer.Results.summary end
function GameAnalyzer.GetSensitive() return GameAnalyzer.Results.sensitive end
function GameAnalyzer.GetEditable() return GameAnalyzer.Results.editable end
function GameAnalyzer.GetSounds() return GameAnalyzer.Results.sounds end
function GameAnalyzer.GetImages() return GameAnalyzer.Results.images end
function GameAnalyzer.GetRemotes() return GameAnalyzer.Results.remotes end
function GameAnalyzer.GetValues() return GameAnalyzer.Results.values end
function GameAnalyzer.GetModules() return GameAnalyzer.Results.modules end
function GameAnalyzer.GetConfig() return CONFIG end

function GameAnalyzer.SetConfig(newConfig)
    for key, value in pairs(newConfig) do
        if CONFIG[key] ~= nil then CONFIG[key] = value end
    end
end

print("🔬 Game Analyzer v4.0 Loaded!")

return GameAnalyzer
