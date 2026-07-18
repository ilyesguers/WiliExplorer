-- =============================================
-- 🚀 WiliExplorer Loader - النسخة الكاملة
-- Version: 1.0.1
-- =============================================

local VERSION = "1.0.1"
local REPO_OWNER = "ilyesguers"
local REPO_NAME = "WiliExplorer"
local BRANCH = "main"

local BASE_URL = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/" .. BRANCH .. "/src/"

print("🚀 WiliExplorer v" .. VERSION .. " is starting...")

local HttpService = game:GetService("HttpService")

-- دالة تحميل الملفات من GitHub (محسنة)
local function LoadModule(path)
    local url = BASE_URL .. path
    print("📥 Loading: " .. path)

    local success, response = pcall(function()
        return HttpService:GetAsync(url, true)
    end)

    if not success then
        warn("❌ Failed to download: " .. path)
        warn("Error:", response)
        return nil
    end

    local func, err = loadstring(response)
    if not func then
        warn("❌ Failed to loadstring: " .. path)
        warn("Error:", err)
        return nil
    end

    local success2, result = pcall(func)
    if success2 then
        print("✅ Loaded: " .. path)
        return result
    else
        warn("❌ Error while executing: " .. path)
        warn("Error:", result)
        return nil
    end
end

-- ====================== تحميل المكونات ======================

local Config       = LoadModule("Config.lua") or {}
local Colors       = LoadModule("Theme/Colors.lua")
local Icons        = LoadModule("Utils/Icons.lua")
local Language     = LoadModule("Utils/Language.lua")
local MainFrame    = LoadModule("UI/MainFrame.lua")

-- ====================== تشغيل الواجهة ======================

print("\n🌌 Initializing UI...")

if MainFrame and MainFrame.Create then
    local success, gui = pcall(function()
        return MainFrame.Create()
    end)
    
    if success and gui then
        print("✅ WiliExplorer UI Created Successfully!")
        print("🌠 Welcome to WiliExplorer v" .. VERSION)
    else
        warn("❌ Failed to create UI")
        if gui then warn(gui) end
    end
else
    warn("❌ MainFrame module not loaded correctly")
end

print("🚀 WiliExplorer v" .. VERSION .. " Loaded!")
