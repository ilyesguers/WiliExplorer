--[[
    🚀 WiliExplorer - Loader v2.0
]]

local VERSION = "2.0.0"
local BASE_URL = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/"

print("🚀 WiliExplorer v" .. VERSION .. " Loading...")

local Modules = {}

local function LoadModule(path)
    local url = BASE_URL .. path
    print("📥 Loading: " .. path)
    
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not response or response == "" then
        warn("❌ Failed: " .. path)
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("❌ Parse error: " .. path)
        return nil
    end
    
    local ok, result = pcall(func)
    if not ok then
        warn("❌ Execution error: " .. path)
        return nil
    end
    
    print("✅ Loaded: " .. path)
    return result
end

-- تحميل الملفات
Modules.Config = LoadModule("Config.lua") task.wait(0.05)
Modules.Colors = LoadModule("Theme/Colors.lua") task.wait(0.05)
Modules.Language = LoadModule("Utils/Language.lua") task.wait(0.05)
Modules.Icons = LoadModule("Utils/Icons.lua") task.wait(0.05)
Modules.KeySystem = LoadModule("Security/KeySystem.lua") task.wait(0.05)

-- ⭐ الملفات الجديدة
Modules.GameAnalyzer = LoadModule("Core/GameAnalyzer.lua") task.wait(0.1)
Modules.AdvancedTools = LoadModule("Core/AdvancedTools.lua") task.wait(0.1)
Modules.FileScanner = LoadModule("Core/FileScanner.lua") task.wait(0.05)

Modules.Stars = LoadModule("Theme/Stars.lua") task.wait(0.05)
Modules.ImageEditor = LoadModule("UI/ImageEditor.lua") task.wait(0.05)
Modules.FileViewer = LoadModule("UI/FileViewer.lua") task.wait(0.1)
Modules.MainFrame = LoadModule("UI/MainFrame.lua") task.wait(0.05)

_G.WiliModules = Modules

print("🎮 Creating UI...")
if Modules.MainFrame and Modules.MainFrame.Create then
    pcall(function() Modules.MainFrame.Create(Modules) end)
end

print("🎉 WiliExplorer Ready!")
return Modules
