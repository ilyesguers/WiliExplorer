-- 🚀 WiliExplorer Loader
-- Version 1.0.0

local VERSION = "1.0.0"
local REPO_OWNER = "ilyesguers"
local REPO_NAME = "WiliExplorer"
local BRANCH = "main"

local BASE_URL = "https://raw.githubusercontent.com/"
    .. REPO_OWNER .. "/"
    .. REPO_NAME .. "/"
    .. BRANCH .. "/src/"

print("🚀 WiliExplorer v"..VERSION.." Loading...")

-- Services
local HttpService = game:GetService("HttpService")

-- Simple module loader
local function LoadModule(path)
    local url = BASE_URL .. path
    print("📥 Loading:", path)

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success and response then
        local moduleFunc = loadstring(response)
        if moduleFunc then
            return moduleFunc()
        else
            warn("❌ Failed to loadstring:", path)
        end
    else
        warn("❌ Failed to fetch:", path)
    end
end

-- Load Config
local Config = LoadModule("Config.lua")

-- Load Theme
local Colors = LoadModule("Theme/Colors.lua")

-- Load Language
local Language = LoadModule("Utils/Language.lua")

-- Load Icons
local Icons = LoadModule("Utils/Icons.lua")

print("✅ Core modules loaded!")

-- Placeholder start
print("🌌 WiliExplorer initialized successfully!")
-- في نهاية ملف Loader.lua
local MainFrame = LoadModule("UI/MainFrame.lua")
if MainFrame then
    MainFrame.Create()
    print("🚀 WiliExplorer GUI is now visible!")
end
