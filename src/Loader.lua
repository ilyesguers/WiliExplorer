--[[
    🚀 WiliExplorer - Loader v3.0 (Optimized)
    
    ✅ إصلاحات:
    • تحميل Modules مرة واحدة فقط
    • تخزين في _G.WiliModules للاستخدام لاحقاً
    • معالجة أخطاء محسنة
    • تحسين الأداء
]]

local VERSION = "3.0.0"
local BASE_URL = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/"

print("🚀 WiliExplorer v" .. VERSION .. " Loading...")

local Modules = {}

local function LoadModule(path, name)
    local url = BASE_URL .. path
    print("📥 Loading: " .. (name or path))
    
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not response or response == "" then
        warn("❌ Failed to download: " .. path)
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("❌ Parse error in " .. path .. ": " .. tostring(err))
        return nil
    end
    
    local ok, result = pcall(func)
    if not ok then
        warn("❌ Execution error in " .. path .. ": " .. tostring(result))
        return nil
    end
    
    print("✅ Loaded: " .. (name or path))
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- تحميل الملفات بالترتيب الصحيح
-- ═══════════════════════════════════════════════════════════════════════

-- الملفات الأساسية أولاً
Modules.Config = LoadModule("Config.lua", "Config")
task.wait(0.05)

Modules.Colors = LoadModule("Theme/Colors.lua", "Colors")
task.wait(0.05)

Modules.Language = LoadModule("Utils/Language.lua", "Language")
task.wait(0.05)

Modules.Icons = LoadModule("Utils/Icons.lua", "Icons")
task.wait(0.05)

-- نظام الأمان
Modules.KeySystem = LoadModule("Security/KeySystem.lua", "KeySystem")
task.wait(0.05)

-- الملفات الأساسية
Modules.GameAnalyzer = LoadModule("Core/GameAnalyzer.lua", "GameAnalyzer")
task.wait(0.1)

Modules.AdvancedTools = LoadModule("Core/AdvancedTools.lua", "AdvancedTools")
task.wait(0.1)

Modules.FileScanner = LoadModule("Core/FileScanner.lua", "FileScanner")
task.wait(0.1)

-- المظهر البصري
Modules.Stars = LoadModule("Theme/Stars.lua", "Stars")
task.wait(0.05)

-- واجهة المستخدم
Modules.ImageEditor = LoadModule("UI/ImageEditor.lua", "ImageEditor")
task.wait(0.05)

Modules.FileViewer = LoadModule("UI/FileViewer.lua", "FileViewer")
task.wait(0.1)

-- ═══════════════════════════════════════════════════════════════════════
-- تخزين Modules عالمياً للاستخدام في أي مكان
-- ═══════════════════════════════════════════════════════════════════════
_G.WiliModules = Modules

print("📦 All modules loaded! Creating UI...")

-- تحميل MainFrame أخيراً
Modules.MainFrame = LoadModule("UI/MainFrame.lua", "MainFrame")
task.wait(0.1)

-- إنشاء الواجهة
if Modules.MainFrame and Modules.MainFrame.Create then
    local ok, err = pcall(function()
        Modules.MainFrame.Create()
    end)
    if ok then
        print("🎉 WiliExplorer Ready!")
    else
        warn("❌ Failed to create UI: " .. tostring(err))
    end
else
    warn("❌ MainFrame module not loaded!")
end

return Modules
