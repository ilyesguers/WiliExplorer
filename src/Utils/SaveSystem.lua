--[[
    ═══════════════════════════════════════════════════════════════════════════
    💾 WiliExplorer - Save System v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ حفظ إعدادات المستخدم
    ✅ حفظ حالة القائمة
    ✅ حفظ المفاتيح المفضلة
    ✅ تصدير/استيراد الإعدادات
    ✅ نسخ احتياطي تلقائي
    ✅ متوافق مع الهاتف (writefile/readfile)
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local SaveSystem = {}

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 📁 المسارات
-- ═══════════════════════════════════════════════════════════════════════
local SaveFolder = "WiliExplorer"
local SaveFile = SaveFolder .. "/settings.json"
local BackupFile = SaveFolder .. "/backup.json"
local HistoryFile = SaveFolder .. "/history.json"

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 الإعدادات الافتراضية
-- ═══════════════════════════════════════════════════════════════════════
local DefaultSettings = {
    -- عام
    language = "ar",
    theme = "space",
    version = "1.0.0",
    
    -- الواجهة
    uiScale = 1,
    showNotifications = true,
    notificationDuration = 3,
    showFloatingButton = true,
    
    -- KlimboMenu
    klimboPosition = {x = 0.5, y = 0.5},
    klimboSize = {w = 700, h = 500},
    klimboMinimized = false,
    lastTab = "Secrets",
    
    -- ESP
    espEnabled = false,
    espNames = true,
    espHealth = true,
    espDistance = true,
    espHighlight = true,
    
    -- Aimbot
    aimbotEnabled = false,
    aimbotFOV = 200,
    aimbotSmoothness = 0.5,
    aimbotTargetPart = "Head",
    
    -- Player
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 50,
    
    -- مفاتيح مفضلة
    favoriteKeys = {},
    
    -- سكريبتات محفوظة
    savedScripts = {},
    
    -- إحصائيات
    totalLaunches = 0,
    totalTime = 0,
    lastLaunch = ""
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 البيانات الحالية
-- ═══════════════════════════════════════════════════════════════════════
local CurrentSettings = {}
local IsDirty = false
local AutoSaveInterval = 60 -- ثانية

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function CheckWriteFile()
    return writefile ~= nil and readfile ~= nil and isfile ~= nil and isfolder ~= nil and makefolder ~= nil
end

local function EnsureFolder()
    if not isfolder(SaveFolder) then
        pcall(function() makefolder(SaveFolder) end)
    end
end

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function MergeTables(default, saved)
    local result = DeepCopy(default)
    for k, v in pairs(saved) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = MergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- 💾 حفظ وتحميل
-- ═══════════════════════════════════════════════════════════════════════

-- حفظ الإعدادات
function SaveSystem.Save()
    if not CheckWriteFile() then
        warn("⚠️ SaveSystem: writefile not supported!")
        return false
    end
    
    EnsureFolder()
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(CurrentSettings)
        writefile(SaveFile, json)
    end)
    
    if success then
        IsDirty = false
        return true
    else
        warn("⚠️ SaveSystem: Failed to save - " .. tostring(err))
        return false
    end
end

-- تحميل الإعدادات
function SaveSystem.Load()
    if not CheckWriteFile() then
        warn("⚠️ SaveSystem: readfile not supported!")
        CurrentSettings = DeepCopy(DefaultSettings)
        return CurrentSettings
    end
    
    EnsureFolder()
    
    -- محاولة تحميل الملف الرئيسي
    if isfile(SaveFile) then
        local success, data = pcall(function()
            local json = readfile(SaveFile)
            return HttpService:JSONDecode(json)
        end)
        
        if success and data then
            CurrentSettings = MergeTables(DefaultSettings, data)
            print("✅ SaveSystem: Settings loaded!")
        else
            warn("⚠️ SaveSystem: Failed to parse settings, using defaults")
            CurrentSettings = DeepCopy(DefaultSettings)
        end
    else
        print("ℹ️ SaveSystem: No save file found, using defaults")
        CurrentSettings = DeepCopy(DefaultSettings)
    end
    
    -- تحديث إحصائيات
    CurrentSettings.totalLaunches = (CurrentSettings.totalLaunches or 0) + 1
    CurrentSettings.lastLaunch = os.date("%Y-%m-%d %H:%M:%S")
    
    -- حفظ تلقائي
    SaveSystem.Save()
    
    return CurrentSettings
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📖 قراءة وكتابة القيم
-- ═══════════════════════════════════════════════════════════════════════

-- الحصول على قيمة
function SaveSystem.Get(key, default)
    if key == nil then return CurrentSettings end
    
    local keys = string.split(key, ".")
    local current = CurrentSettings
    
    for _, k in ipairs(keys) do
        if type(current) == "table" then
            current = current[k]
        else
            return default
        end
    end
    
    return current ~= nil and current or default
end

-- تعيين قيمة
function SaveSystem.Set(key, value)
    if key == nil then return end
    
    local keys = string.split(key, ".")
    local current = CurrentSettings
    
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(current[k]) ~= "table" then
            current[k] = {}
        end
        current = current[k]
    end
    
    current[keys[#keys]] = value
    IsDirty = true
    
    -- حفظ تلقائي عند التغيير
    task.spawn(function()
        task.wait(1)
        if IsDirty then
            SaveSystem.Save()
        end
    end)
end

-- حذف قيمة
function SaveSystem.Delete(key)
    local keys = string.split(key, ".")
    local current = CurrentSettings
    
    for i = 1, #keys - 1 do
        if type(current) ~= "table" then return end
        current = current[keys[i]]
    end
    
    if type(current) == "table" then
        current[keys[#keys]] = nil
        IsDirty = true
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 إدارة القوائم (مفاتيح مفضلة، سكريبتات محفوظة)
-- ═══════════════════════════════════════════════════════════════════════

-- إضافة إلى المفضلة
function SaveSystem.AddFavorite(key, data)
    local favorites = SaveSystem.Get("favoriteKeys", {})
    
    -- التحقق من عدم التكرار
    for _, fav in ipairs(favorites) do
        if fav.key == key then return false end
    end
    
    table.insert(favorites, {
        key = key,
        data = data,
        addedAt = os.date("%Y-%m-%d %H:%M:%S")
    })
    
    SaveSystem.Set("favoriteKeys", favorites)
    return true
end

-- حذف من المفضلة
function SaveSystem.RemoveFavorite(key)
    local favorites = SaveSystem.Get("favoriteKeys", {})
    local newFavorites = {}
    
    for _, fav in ipairs(favorites) do
        if fav.key ~= key then
            table.insert(newFavorites, fav)
        end
    end
    
    SaveSystem.Set("favoriteKeys", newFavorites)
end

-- الحصول على المفضلة
function SaveSystem.GetFavorites()
    return SaveSystem.Get("favoriteKeys", {})
end

-- حفظ سكريبت
function SaveSystem.SaveScript(name, code, description)
    local scripts = SaveSystem.Get("savedScripts", {})
    
    -- تحديث إذا كان موجود
    for i, script in ipairs(scripts) do
        if script.name == name then
            scripts[i] = {
                name = name,
                code = code,
                description = description or "",
                updatedAt = os.date("%Y-%m-%d %H:%M:%S")
            }
            SaveSystem.Set("savedScripts", scripts)
            return true
        end
    end
    
    -- إضافة جديد
    table.insert(scripts, {
        name = name,
        code = code,
        description = description or "",
        createdAt = os.date("%Y-%m-%d %H:%M:%S"),
        updatedAt = os.date("%Y-%m-%d %H:%M:%S")
    })
    
    SaveSystem.Set("savedScripts", scripts)
    return true
end

-- حذف سكريبت
function SaveSystem.DeleteScript(name)
    local scripts = SaveSystem.Get("savedScripts", {})
    local newScripts = {}
    
    for _, script in ipairs(scripts) do
        if script.name ~= name then
            table.insert(newScripts, script)
        end
    end
    
    SaveSystem.Set("savedScripts", newScripts)
end

-- الحصول على السكريبتات
function SaveSystem.GetScripts()
    return SaveSystem.Get("savedScripts", {})
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📤 تصدير واستيراد
-- ═══════════════════════════════════════════════════════════════════════

-- تصدير الإعدادات
function SaveSystem.Export()
    if not CheckWriteFile() then return nil end
    
    EnsureFolder()
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(CurrentSettings)
    end)
    
    if success then
        local exportFile = SaveFolder .. "/export_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
        pcall(function() writefile(exportFile, json) end)
        return json
    end
    
    return nil
end

-- استيراد الإعدادات
function SaveSystem.Import(json)
    if not json or json == "" then return false end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if success and data then
        CurrentSettings = MergeTables(DefaultSettings, data)
        SaveSystem.Save()
        print("✅ SaveSystem: Settings imported!")
        return true
    end
    
    warn("⚠️ SaveSystem: Failed to import settings")
    return false
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 نسخ احتياطي
-- ═══════════════════════════════════════════════════════════════════════

-- إنشاء نسخة احتياطية
function SaveSystem.CreateBackup()
    if not CheckWriteFile() then return false end
    
    EnsureFolder()
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(CurrentSettings)
        writefile(BackupFile, json)
    end)
    
    return success
end

-- استعادة النسخة الاحتياطية
function SaveSystem.RestoreBackup()
    if not CheckWriteFile() then return false end
    
    if not isfile(BackupFile) then
        warn("⚠️ SaveSystem: No backup file found")
        return false
    end
    
    local success, data = pcall(function()
        local json = readfile(BackupFile)
        return HttpService:JSONDecode(json)
    end)
    
    if success and data then
        CurrentSettings = MergeTables(DefaultSettings, data)
        SaveSystem.Save()
        print("✅ SaveSystem: Backup restored!")
        return true
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 إحصائيات
-- ═══════════════════════════════════════════════════════════════════════
function SaveSystem.GetStats()
    return {
        totalLaunches = SaveSystem.Get("totalLaunches", 0),
        totalTime = SaveSystem.Get("totalTime", 0),
        lastLaunch = SaveSystem.Get("lastLaunch", "Never"),
        savedScripts = #SaveSystem.Get("savedScripts", {}),
        favorites = #SaveSystem.Get("favoriteKeys", {}),
        hasBackup = CheckWriteFile() and isfile(BackupFile) or false
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 حفظ تلقائي
-- ═══════════════════════════════════════════════════════════════════════
function SaveSystem.StartAutoSave(interval)
    AutoSaveInterval = interval or 60
    
    task.spawn(function()
        while true do
            task.wait(AutoSaveInterval)
            if IsDirty then
                SaveSystem.Save()
                SaveSystem.CreateBackup()
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🗑️ مسح كل البيانات
-- ═══════════════════════════════════════════════════════════════════════
function SaveSystem.ClearAll()
    CurrentSettings = DeepCopy(DefaultSettings)
    IsDirty = true
    SaveSystem.Save()
    print("🗑️ SaveSystem: All data cleared!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 تهيئة النظام
-- ═══════════════════════════════════════════════════════════════════════
function SaveSystem.Init()
    SaveSystem.Load()
    SaveSystem.StartAutoSave()
    print("💾 Save System v1.0 Initialized!")
    return CurrentSettings
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 API
-- ═══════════════════════════════════════════════════════════════════════
SaveSystem.Settings = CurrentSettings
SaveSystem.DefaultSettings = DefaultSettings

print("💾 Save System v1.0 Loaded!")

return SaveSystem
