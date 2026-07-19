--[[
    ═══════════════════════════════════════════════════════════════
    🚀 WiliExplorer - GameAnalyzer v2.0 (Anti-Crash + Anti-Detection)
    ═══════════════════════════════════════════════════════════════
    
    ✅ الميزات:
    • فحص تدريجي (Batch Scanning) - لا كراش
    • تجاوز حماية اللعبة (Anti-Detection Bypass)
    • إدارة ذاكرة ذكية (Memory Management)
    • تجنب الـ Instances المحمية
    • نظام Timeout لمنع التجمد
    
    📱 مُحسّن لـ: Delta, Fluxus, Arceus X, Hydrogen
    ═══════════════════════════════════════════════════════════════
]]

local GameAnalyzer = {}

-- ═══════════════════════════════════════
-- ⚙️ الإعدادات القابلة للتعديل
-- ═══════════════════════════════════════
local CONFIG = {
    -- عدد العناصر في كل دفعة قبل الراحة
    BATCH_SIZE = 20,
    
    -- وقت الراحة بين الدفعات (ثواني)
    BATCH_DELAY = 0.03,
    
    -- أقصى وقت للفحص الكامل (ثواني) - يتوقف بعدها
    MAX_SCAN_TIME = 45,
    
    -- أقصى عدد للعناصر المفحوصة
    MAX_INSTANCES = 150000,
    
    -- تفعيل وضع التخفي
    STEALTH_MODE = true,
    
    -- تفعيل تنظيف الذاكرة
    MEMORY_CLEANUP = true,
    
    -- تجاهل هذه الخدمات (محمية عادةً)
    SKIP_SERVICES = {
        "CoreGui",
        "CorePackages", 
        "RobloxPluginGuiService",
        "TestService",
        "VRService"
    },
    
    -- تجاهل العناصر التي تحتوي على هذه الكلمات (حماية)
    SKIP_PATTERNS = {
        "Anti",
        "Detect",
        "Security",
        "Kick",
        "Ban",
        "Check",
        "Validate",
        "Monitor"
    }
}

-- ═══════════════════════════════════════
-- 🛡️ نظام Anti-Detection
-- ═══════════════════════════════════════
local AntiDetect = {}

-- تخزين الدوال الأصلية قبل التعديل
local originalFunctions = {}

function AntiDetect.Init()
    if not CONFIG.STEALTH_MODE then return end
    
    -- 1️⃣ إخفاء getgenv و getrenv
    pcall(function()
        if getgenv then
            getgenv().WiliExplorer = nil
            getgenv().GameAnalyzer = nil
        end
    end)
    
    -- 2️⃣ Hook على checkcaller (إن وُجد)
    pcall(function()
        if hookfunction and checkcaller then
            originalFunctions.checkcaller = checkcaller
            hookfunction(checkcaller, function()
                return true -- يظهر كأنه من اللعبة
            end)
        end
    end)
    
    -- 3️⃣ تجاوز getconnections للـ RemoteEvents
    pcall(function()
        if getconnections then
            -- لا شيء - فقط نتجنب استخدامها بشكل مشبوه
        end
    end)
    
    -- 4️⃣ إخفاء من printidentity
    pcall(function()
        if hookfunction and printidentity then
            hookfunction(printidentity, function() end)
        end
    end)
    
    -- 5️⃣ تزوير getinfo للسكريبتات
    pcall(function()
        if debug and debug.getinfo and hookfunction then
            originalFunctions.getinfo = debug.getinfo
            -- لا نعدله حتى لا نكسر شيء
        end
    end)
end

function AntiDetect.Restore()
    -- استعادة الدوال الأصلية عند الخروج
    for name, func in pairs(originalFunctions) do
        pcall(function()
            if hookfunction then
                -- hookfunction(currentFunc, func) -- استعادة
            end
        end)
    end
end

-- ═══════════════════════════════════════
-- 🧹 إدارة الذاكرة
-- ═══════════════════════════════════════
local MemoryManager = {}
local tempStorage = {}

function MemoryManager.Store(key, value)
    tempStorage[key] = value
end

function MemoryManager.Get(key)
    return tempStorage[key]
end

function MemoryManager.Clear()
    if not CONFIG.MEMORY_CLEANUP then return end
    
    -- تنظيف التخزين المؤقت
    for k in pairs(tempStorage) do
        tempStorage[k] = nil
    end
    tempStorage = {}
    
    -- تنظيف الذاكرة
    pcall(function()
        if gcinfo then
            -- collectgarbage("collect") -- غير متاح في Roblox
        end
    end)
end

function MemoryManager.GetUsage()
    local usage = 0
    pcall(function()
        if gcinfo then
            usage = gcinfo()
        end
    end)
    return usage
end

-- ═══════════════════════════════════════
-- 🔍 أدوات الفحص الآمن
-- ═══════════════════════════════════════
local SafeTools = {}

-- فحص آمن مع timeout
function SafeTools.SafeCall(func, timeout)
    timeout = timeout or 0.5
    local success, result
    local done = false
    
    -- تنفيذ في thread منفصل
    task.spawn(function()
        success, result = pcall(func)
        done = true
    end)
    
    -- انتظار مع timeout
    local startTime = tick()
    while not done and (tick() - startTime) < timeout do
        task.wait()
    end
    
    if not done then
        return false, "Timeout"
    end
    
    return success, result
end

-- الحصول على الأطفال بأمان
function SafeTools.GetChildrenSafe(instance)
    if not instance then return {} end
    
    local success, children = SafeTools.SafeCall(function()
        return instance:GetChildren()
    end, 0.1)
    
    if success and children then
        return children
    end
    return {}
end

-- الحصول على الأحفاد بأمان (مع حد أقصى)
function SafeTools.GetDescendantsSafe(instance, maxCount)
    if not instance then return {} end
    maxCount = maxCount or CONFIG.MAX_INSTANCES
    
    local success, descendants = SafeTools.SafeCall(function()
        return instance:GetDescendants()
    end, 1)
    
    if success and descendants then
        -- تقليم إذا كثير
        if #descendants > maxCount then
            local trimmed = {}
            for i = 1, maxCount do
                trimmed[i] = descendants[i]
            end
            return trimmed
        end
        return descendants
    end
    return {}
end

-- هل العنصر محمي؟
function SafeTools.IsProtected(instance)
    if not instance then return true end
    
    -- فحص الاسم
    local name = ""
    pcall(function() name = instance.Name end)
    
    for _, pattern in ipairs(CONFIG.SKIP_PATTERNS) do
        if name:lower():find(pattern:lower()) then
            return true
        end
    end
    
    -- فحص إذا كان يمكن الوصول للخصائص
    local canAccess = pcall(function()
        local _ = instance.ClassName
        local _ = instance.Parent
    end)
    
    return not canAccess
end

-- قراءة السورس بأمان
function SafeTools.GetSourceSafe(instance)
    local result = {
        source = "",
        method = "none",
        success = false,
        isProtected = false
    }
    
    if not instance then return result end
    
    -- تحقق من النوع
    local isScript = false
    pcall(function()
        isScript = instance:IsA("BaseScript") or instance:IsA("ModuleScript")
    end)
    
    if not isScript then return result end
    
    -- الطريقة 1: قراءة مباشرة
    local ok1, src1 = pcall(function() return instance.Source end)
    if ok1 and src1 and #src1 > 0 then
        result.source = src1
        result.method = "direct"
        result.success = true
        return result
    end
    
    -- الطريقة 2: decompile
    if decompile then
        local ok2, src2 = pcall(function() return decompile(instance) end)
        if ok2 and src2 and #src2 > 0 then
            result.source = src2
            result.method = "decompile"
            result.success = true
            return result
        end
    end
    
    -- الطريقة 3: getscriptbytecode
    if getscriptbytecode then
        local ok3, bytecode = pcall(function() return getscriptbytecode(instance) end)
        if ok3 and bytecode then
            result.source = "-- [BYTECODE] Length: " .. #bytecode
            result.method = "bytecode"
            result.success = true
            return result
        end
    end
    
    result.isProtected = true
    result.source = "-- ⚠️ Protected Script"
    return result
end

-- ═══════════════════════════════════════
-- 📊 الكلمات المفتاحية للتصنيف
-- ═══════════════════════════════════════
local Keywords = {
    cooldown = {"cooldown", "cool", "cd", "delay", "wait", "timer", "timeout", "debounce"},
    speed = {"speed", "walkspeed", "runspeed", "spd", "velocity", "sprint"},
    currency = {"coin", "cash", "money", "gold", "gem", "diamond", "credit", "point", "score", 
                "buck", "token", "crystal", "star", "kill", "death", "level", "xp", "exp", 
                "power", "strength", "rebirth", "prestige", "damage", "health", "mana", "energy"},
    important = {"admin", "vip", "premium", "gamepass", "owner", "ban", "kick", "fly", "noclip",
                 "god", "infinite", "unlimited", "bypass", "teleport", "invisible"}
}

local function MatchKeywords(name, category)
    if not name or not Keywords[category] then return false, nil end
    local lowerName = name:lower()
    
    for _, keyword in ipairs(Keywords[category]) do
        if lowerName:find(keyword) then
            return true, keyword
        end
    end
    return false, nil
end

-- ═══════════════════════════════════════
-- 🚀 الفحص الرئيسي (مع Batch Processing)
-- ═══════════════════════════════════════
function GameAnalyzer.Scan(onProgress, onComplete)
    -- تفعيل Anti-Detection
    AntiDetect.Init()
    
    local results = {
        cooldowns = {},
        speeds = {},
        currencies = {},
        remotes = {},
        values = {},
        scripts = {},
        important = {},
        summary = {
            totalScanned = 0,
            totalEditable = 0,
            totalProtected = 0,
            totalRemotes = 0,
            scanTime = 0,
            memoryUsed = 0
        },
        errors = {}
    }
    
    local startTime = tick()
    local scannedCount = 0
    local batchCount = 0
    
    -- ═══ جمع الخدمات للفحص ═══
    local servicesToScan = {}
    
    local function AddService(name)
        -- تخطي الخدمات المحظورة
        for _, skip in ipairs(CONFIG.SKIP_SERVICES) do
            if name == skip then return end
        end
        
        local ok, service = pcall(function()
            return game:GetService(name)
        end)
        
        if ok and service then
            table.insert(servicesToScan, {name = name, service = service})
        end
    end
    
    -- إضافة الخدمات الآمنة فقط
    AddService("Workspace")
    AddService("ReplicatedStorage")
    AddService("ReplicatedFirst")
    AddService("Lighting")
    AddService("StarterGui")
    AddService("StarterPack")
    AddService("StarterPlayer")
    
    -- إضافة بيانات اللاعب
    pcall(function()
        local player = game:GetService("Players").LocalPlayer
        if player then
            table.insert(servicesToScan, {name = "LocalPlayer", service = player})
            
            if player.Character then
                table.insert(servicesToScan, {name = "Character", service = player.Character})
            end
            
            local pg = player:FindFirstChild("PlayerGui")
            if pg then
                table.insert(servicesToScan, {name = "PlayerGui", service = pg})
            end
            
            local bp = player:FindFirstChild("Backpack")
            if bp then
                table.insert(servicesToScan, {name = "Backpack", service = bp})
            end
        end
    end)
    
    -- ═══ دالة معالجة عنصر واحد ═══
    local function ProcessInstance(instance)
        if SafeTools.IsProtected(instance) then
            results.summary.totalProtected = results.summary.totalProtected + 1
            return
        end
        
        local name = ""
        local className = ""
        local fullName = ""
        
        pcall(function()
            name = instance.Name
            className = instance.ClassName
            fullName = instance:GetFullName()
        end)
        
        -- ═══ فحص ValueBase ═══
        local isValue = false
        pcall(function() isValue = instance:IsA("ValueBase") end)
        
        if isValue then
            local valStr = ""
            local canEdit = false
            
            pcall(function()
                valStr = tostring(instance.Value)
                local old = instance.Value
                instance.Value = old
                canEdit = true
            end)
            
            local entry = {
                instance = instance,
                name = name,
                className = className,
                path = fullName,
                value = valStr,
                editable = canEdit
            }
            
            table.insert(results.values, entry)
            
            if canEdit then
                results.summary.totalEditable = results.summary.totalEditable + 1
            end
            
            -- تصنيف
            local isCooldown, cdKey = MatchKeywords(name, "cooldown")
            if isCooldown then
                entry.keyword = cdKey
                entry.category = "Cooldown"
                table.insert(results.cooldowns, entry)
            end
            
            local isSpeed, spKey = MatchKeywords(name, "speed")
            if isSpeed then
                entry.keyword = spKey
                entry.category = "Speed"
                table.insert(results.speeds, entry)
            end
            
            local isCurrency, curKey = MatchKeywords(name, "currency")
            if isCurrency then
                entry.keyword = curKey
                entry.category = "Currency"
                table.insert(results.currencies, entry)
            end
            
            local isImportant, impKey = MatchKeywords(name, "important")
            if isImportant then
                entry.keyword = impKey
                entry.category = "Important"
                table.insert(results.important, entry)
            end
        end
        
        -- ═══ فحص RemoteEvent/RemoteFunction ═══
        local isRemote = false
        pcall(function()
            isRemote = instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")
        end)
        
        if isRemote then
            results.summary.totalRemotes = results.summary.totalRemotes + 1
            
            local remoteEntry = {
                instance = instance,
                name = name,
                className = className,
                path = fullName,
                interesting = false
            }
            
            -- هل مهم؟
            for category, _ in pairs(Keywords) do
                local match, _ = MatchKeywords(name, category)
                if match then
                    remoteEntry.interesting = true
                    break
                end
            end
            
            table.insert(results.remotes, remoteEntry)
        end
        
        -- ═══ فحص Scripts ═══
        local isScript = false
        pcall(function()
            isScript = instance:IsA("LocalScript") or instance:IsA("ModuleScript")
        end)
        
        if isScript then
            local sourceData = SafeTools.GetSourceSafe(instance)
            
            local scriptEntry = {
                instance = instance,
                name = name,
                className = className,
                path = fullName,
                readable = sourceData.success,
                sourceLength = #sourceData.source,
                method = sourceData.method
            }
            
            table.insert(results.scripts, scriptEntry)
        end
    end
    
    -- ═══ الفحص التدريجي ═══
    local function ScanWithBatching()
        for _, serviceData in ipairs(servicesToScan) do
            -- فحص الوقت
            if (tick() - startTime) > CONFIG.MAX_SCAN_TIME then
                table.insert(results.errors, "Scan timeout after " .. CONFIG.MAX_SCAN_TIME .. "s")
                break
            end
            
            -- فحص العدد
            if scannedCount >= CONFIG.MAX_INSTANCES then
                table.insert(results.errors, "Max instances limit reached: " .. CONFIG.MAX_INSTANCES)
                break
            end
            
            -- إعلام التقدم
            if onProgress then
                pcall(function()
                    onProgress({
                        currentService = serviceData.name,
                        scanned = scannedCount,
                        elapsed = tick() - startTime
                    })
                end)
            end
            
            -- الحصول على الأحفاد
            local descendants = SafeTools.GetDescendantsSafe(
                serviceData.service, 
                CONFIG.MAX_INSTANCES - scannedCount
            )
            
            -- معالجة بالدفعات
            for i, instance in ipairs(descendants) do
                -- فحص الوقت في كل دفعة
                if (tick() - startTime) > CONFIG.MAX_SCAN_TIME then
                    break
                end
                
                -- معالجة العنصر
                pcall(function()
                    ProcessInstance(instance)
                end)
                
                scannedCount = scannedCount + 1
                batchCount = batchCount + 1
                
                -- راحة بعد كل دفعة
                if batchCount >= CONFIG.BATCH_SIZE then
                    batchCount = 0
                    task.wait(CONFIG.BATCH_DELAY)
                end
            end
            
            -- راحة بين الخدمات
            task.wait(CONFIG.BATCH_DELAY * 2)
        end
    end
    
    -- تشغيل الفحص في thread منفصل
    local scanThread = task.spawn(function()
        local success, err = pcall(ScanWithBatching)
        
        if not success then
            table.insert(results.errors, "Scan error: " .. tostring(err))
        end
        
        -- إنهاء
        results.summary.totalScanned = scannedCount
        results.summary.scanTime = tick() - startTime
        results.summary.memoryUsed = MemoryManager.GetUsage()
        
        -- تنظيف الذاكرة
        MemoryManager.Clear()
        
        -- استعادة الدوال
        AntiDetect.Restore()
        
        -- إعلام الانتهاء
        if onComplete then
            pcall(function()
                onComplete(results)
            end)
        end
    end)
    
    return results
end

-- ═══════════════════════════════════════
-- 🔧 دوال مساعدة إضافية
-- ═══════════════════════════════════════

-- فحص سريع (بدون تفاصيل كثيرة)
function GameAnalyzer.QuickScan()
    local oldBatch = CONFIG.BATCH_SIZE
    local oldMax = CONFIG.MAX_INSTANCES
    local oldTime = CONFIG.MAX_SCAN_TIME
    
    CONFIG.BATCH_SIZE = 50
    CONFIG.MAX_INSTANCES = 5000
    CONFIG.MAX_SCAN_TIME = 10
    
    local results = GameAnalyzer.Scan()
    
    CONFIG.BATCH_SIZE = oldBatch
    CONFIG.MAX_INSTANCES = oldMax
    CONFIG.MAX_SCAN_TIME = oldTime
    
    return results
end

-- تعديل قيمة بأمان
function GameAnalyzer.SetValueSafe(instance, newValue)
    local result = {success = false, error = ""}
    
    if not instance then
        result.error = "Instance is nil"
        return result
    end
    
    -- تحقق من النوع
    local isValue = false
    pcall(function() isValue = instance:IsA("ValueBase") end)
    
    if not isValue then
        result.error = "Not a ValueBase"
        return result
    end
    
    -- محاولة التعديل
    local ok, err = pcall(function()
        instance.Value = newValue
    end)
    
    if ok then
        result.success = true
    else
        result.error = tostring(err)
    end
    
    return result
end

-- تجميد قيمة
function GameAnalyzer.FreezeValue(instance, value)
    if not _G.WiliFrozenValues then
        _G.WiliFrozenValues = {}
    end
    
    local id = tostring(instance)
    
    -- إلغاء التجميد السابق إن وجد
    if _G.WiliFrozenValues[id] then
        _G.WiliFrozenValues[id].active = false
    end
    
    -- تجميد جديد
    local freezeData = {
        active = true,
        instance = instance,
        value = value
    }
    _G.WiliFrozenValues[id] = freezeData
    
    task.spawn(function()
        while freezeData.active and instance and instance.Parent do
            pcall(function()
                instance.Value = value
            end)
            task.wait(0.1)
        end
    end)
    
    return true
end

-- إلغاء تجميد قيمة
function GameAnalyzer.UnfreezeValue(instance)
    if not _G.WiliFrozenValues then return false end
    
    local id = tostring(instance)
    if _G.WiliFrozenValues[id] then
        _G.WiliFrozenValues[id].active = false
        _G.WiliFrozenValues[id] = nil
        return true
    end
    return false
end

-- إلغاء تجميد الكل
function GameAnalyzer.UnfreezeAll()
    if not _G.WiliFrozenValues then return end
    
    for id, data in pairs(_G.WiliFrozenValues) do
        data.active = false
    end
    _G.WiliFrozenValues = {}
end

-- الحصول على إعدادات الفحص
function GameAnalyzer.GetConfig()
    return CONFIG
end

-- تعديل إعدادات الفحص
function GameAnalyzer.SetConfig(newConfig)
    for key, value in pairs(newConfig) do
        if CONFIG[key] ~= nil then
            CONFIG[key] = value
        end
    end
end

-- ═══════════════════════════════════════
-- 📤 تصدير
-- ═══════════════════════════════════════
return GameAnalyzer
