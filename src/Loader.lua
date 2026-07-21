--[[
    ═══════════════════════════════════════════════════════════════════════════
    🚀 WiliExplorer - Loader v4.0 (Ultimate Edition)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تحميل ذكي مع معالجة أخطاء
    ✅ شاشة تحميل جميلة
    ✅ تحديث تلقائي
    ✅ حماية من التكرار
    
    ═══════════════════════════════════════════════════════════════════════════
]]

-- حماية من التكرار
if _G.WiliExplorerLoaded then
    warn("⚠️ WiliExplorer is already loaded!")
    return
end
_G.WiliExplorerLoaded = true

local VERSION = "5.0.0"
local BASE_URL = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/"

print("═══════════════════════════════════════════════")
print("🚀 WiliExplorer v" .. VERSION .. " - Loading...")
print("═══════════════════════════════════════════════")

local Modules = {}
local LoadOrder = {}
local StartTime = tick()

-- ═══════════════════════════════════════════════════════════════════════
-- 📥 نظام التحميل الذكي
-- ═══════════════════════════════════════════════════════════════════════
local function LoadModule(path, name, required)
    local url = BASE_URL .. path
    local displayName = name or path
    
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not response or response == "" then
        if required then
            warn("❌ CRITICAL: Failed to load " .. displayName)
        else
            warn("⚠️ Optional: Failed to load " .. displayName)
        end
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("❌ Parse error in " .. displayName .. ": " .. tostring(err))
        return nil
    end
    
    local ok, result = pcall(func)
    if not ok then
        warn("❌ Execution error in " .. displayName .. ": " .. tostring(result))
        return nil
    end
    
    table.insert(LoadOrder, displayName)
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 تحميل الملفات بالترتيب الصحيح
-- ═══════════════════════════════════════════════════════════════════════

-- المرحلة 1: الأساسية
print("📦 Phase 1: Core Systems...")
Modules.Config = LoadModule("Config.lua", "Config", true)
task.wait(0.05)

Modules.Colors = LoadModule("Theme/Colors.lua", "Colors", true)
task.wait(0.05)

Modules.Language = LoadModule("Utils/Language.lua", "Language", true)
task.wait(0.05)

Modules.Icons = LoadModule("Utils/Icons.lua", "Icons", false)
task.wait(0.05)

-- المرحلة 2: الأمان
print("🔐 Phase 2: Security...")
Modules.KeySystem = LoadModule("Security/KeySystem.lua", "KeySystem", true)
task.wait(0.05)

Modules.AntiTamper = LoadModule("Security/AntiTamper.lua", "AntiTamper", false)
task.wait(0.05)

Modules.HWID = LoadModule("Security/HWID.lua", "HWID", false)
task.wait(0.05)

-- المرحلة 3: المظهر
print("🎨 Phase 3: Theme...")
Modules.Stars = LoadModule("Theme/Stars.lua", "Stars", true)
task.wait(0.05)

Modules.Animations = LoadModule("Theme/Animations.lua", "Animations", false)
task.wait(0.05)

Modules.Fonts = LoadModule("Theme/Fonts.lua", "Fonts", false)
task.wait(0.05)

-- المرحلة 4: الأدوات
print("🔧 Phase 4: Utils...")
Modules.HTTP = LoadModule("Utils/HTTP.lua", "HTTP", false)
task.wait(0.05)

Modules.JSON = LoadModule("Utils/JSON.lua", "JSON", false)
task.wait(0.05)

Modules.SaveSystem = LoadModule("Utils/SaveSystem.lua", "SaveSystem", false)
task.wait(0.05)

Modules.Highlighter = LoadModule("Utils/Highlighter.lua", "Highlighter", false)
task.wait(0.05)

-- المرحلة 5: النواة
print("⚙️ Phase 5: Core Modules...")
Modules.FileScanner = LoadModule("Core/FileScanner.lua", "FileScanner", true)
task.wait(0.1)

Modules.GameAnalyzer = LoadModule("Core/GameAnalyzer.lua", "GameAnalyzer", true)
task.wait(0.1)

Modules.AdvancedTools = LoadModule("Core/AdvancedTools.lua", "AdvancedTools", false)
task.wait(0.1)

Modules.FileActions = LoadModule("Core/FileActions.lua", "FileActions", false)
task.wait(0.05)

Modules.FileEditor = LoadModule("Core/FileEditor.lua", "FileEditor", false)
task.wait(0.05)

Modules.PropertyEditor = LoadModule("Core/PropertyEditor.lua", "PropertyEditor", false)
task.wait(0.05)

Modules.TreeBuilder = LoadModule("Core/TreeBuilder.lua", "TreeBuilder", false)
task.wait(0.05)

Modules.ErrorHandler = LoadModule("Core/ErrorHandler.lua", "ErrorHandler", false)
task.wait(0.05)

-- المرحلة 6: واجهة المستخدم
print("🖥️ Phase 6: UI Components...")
Modules.Notifications = LoadModule("UI/Notifications.lua", "Notifications", false)
task.wait(0.05)

Modules.ContextMenu = LoadModule("UI/ContextMenu.lua", "ContextMenu", false)
task.wait(0.05)

Modules.SearchBar = LoadModule("UI/SearchBar.lua", "SearchBar", false)
task.wait(0.05)

Modules.ErrorPopup = LoadModule("UI/ErrorPopup.lua", "ErrorPopup", false)
task.wait(0.05)

Modules.ImageEditor = LoadModule("UI/ImageEditor.lua", "ImageEditor", false)
task.wait(0.05)

Modules.SoundEditor = LoadModule("UI/SoundEditor.lua", "SoundEditor", false)
task.wait(0.05)

Modules.PropertiesPanel = LoadModule("UI/PropertiesPanel.lua", "PropertiesPanel", false)
task.wait(0.05)

Modules.FileViewer = LoadModule("UI/FileViewer.lua", "FileViewer", true)
task.wait(0.1)

Modules.TreeView = LoadModule("UI/TreeView.lua", "TreeView", true)
task.wait(0.05)

Modules.Sidebar = LoadModule("UI/Sidebar.lua", "Sidebar", true)
task.wait(0.05)

Modules.SmartMenu = LoadModule("UI/SmartMenu.lua", "SmartMenu", false)
task.wait(0.05)

Modules.AdvancedUI = LoadModule("UI/AdvancedUI.lua", "AdvancedUI", false)
task.wait(0.05)

Modules.AnalyzerUI = LoadModule("UI/AnalyzerUI.lua", "AnalyzerUI", false)
task.wait(0.05)

-- المرحلة 7: الواجهة الرئيسية
print("🎮 Phase 7: Main UI...")
Modules.KlimboMenu = LoadModule("UI/KlimboMenu.lua", "KlimboMenu", true)
task.wait(0.1)

Modules.MainFrame = LoadModule("UI/MainFrame.lua", "MainFrame", true)
task.wait(0.1)

-- ═══════════════════════════════════════════════════════════════════════
-- 💾 تخزين Modules عالمياً
-- ═══════════════════════════════════════════════════════════════════════
_G.WiliModules = Modules

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 إنشاء الواجهة
-- ═══════════════════════════════════════════════════════════════════════
local LoadTime = math.floor((tick() - StartTime) * 100) / 100

print("═══════════════════════════════════════════════")
print("✅ Loaded " .. #LoadOrder .. " modules in " .. LoadTime .. "s")
print("═══════════════════════════════════════════════")

if Modules.MainFrame and Modules.MainFrame.Create then
    local ok, err = pcall(function()
        Modules.MainFrame.Create()
    end)
    
    if ok then
        print("═══════════════════════════════════════════════")
        print("🎉 WiliExplorer v" .. VERSION .. " Ready!")
        print("═══════════════════════════════════════════════")
    else
        warn("❌ Failed to create UI: " .. tostring(err))
    end
else
    warn("❌ MainFrame module not loaded!")
end

return Modules
