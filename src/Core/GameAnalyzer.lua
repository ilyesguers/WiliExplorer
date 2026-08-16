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
local FrozenValues = setmetatable({}, {__mode = "k"})

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

    -- معلومات اللعبة: لا نوقف خيط الفحص لانتظار RenderStepped.
    local experienceName = "Unknown"
    local productOk, productInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if productOk and productInfo and productInfo.Name then experienceName = productInfo.Name end
    local measuredFPS = 60
    pcall(function() measuredFPS = math.floor(workspace:GetRealPhysicsFPS() + 0.5) end)
    results.gameInfo = {
        name = experienceName,
        placeId = game.PlaceId, jobId = game.JobId,
        playerCount = #Players:GetPlayers(), maxPlayers = Players.MaxPlayers,
        serverTime = math.floor(workspace.DistributedGameTime),
        fps = measuredFPS
    }

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

        -- اجتياز تدريجي لا يبني مصفوفة GetDescendants ضخمة في الذاكرة.
        local queue = {}
        pcall(function() queue = serviceData.service:GetChildren() end)
        while #queue > 0 do
            if (tick() - startTime) > CONFIG.MAX_SCAN_TIME or scannedCount >= CONFIG.MAX_INSTANCES then break end
            local instance = table.remove(queue)
            pcall(function()
                ProcessInstance(instance)
                for _, child in ipairs(instance:GetChildren()) do table.insert(queue, child) end
            end)
            scannedCount = scannedCount + 1
            batchCount = batchCount + 1
            if batchCount >= CONFIG.BATCH_SIZE then
                batchCount = 0
                if onProgress then pcall(function() onProgress({current = scannedCount, total = CONFIG.MAX_INSTANCES, percent = math.floor((scannedCount / CONFIG.MAX_INSTANCES) * 100), currentService = serviceData.name}) end) end
                task.wait(CONFIG.BATCH_DELAY)
            end
        end
        table.clear(queue)
        task.wait(CONFIG.BATCH_DELAY)
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
function GameAnalyzer.OpenUI(parent, onBack)
    local AnalyzerUI = _G.WiliModules and _G.WiliModules.AnalyzerUI
    if not AnalyzerUI or type(AnalyzerUI.Create) ~= "function" then
        return nil, "AnalyzerUI module is not loaded"
    end
    return AnalyzerUI.Create(parent, onBack)
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
    if not instance then return false end
    if FrozenValues[instance] then FrozenValues[instance].active = false end
    local freezeData = {active = true, value = value}
    FrozenValues[instance] = freezeData
    task.spawn(function()
        while freezeData.active and instance.Parent do
            pcall(function() instance.Value = freezeData.value end)
            task.wait(0.15)
        end
        FrozenValues[instance] = nil
    end)
    return true
end

function GameAnalyzer.UnfreezeValue(instance)
    local data = instance and FrozenValues[instance]
    if not data then return false end
    data.active = false
    FrozenValues[instance] = nil
    return true
end

function GameAnalyzer.UnfreezeAll()
    for instance, data in pairs(FrozenValues) do
        data.active = false
        FrozenValues[instance] = nil
    end
end

function GameAnalyzer.Destroy()
    GameAnalyzer.UnfreezeAll()
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
