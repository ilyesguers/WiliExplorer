local VERSION = "1.0.3"
local BASE_URL = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/"

print("WiliExplorer v" .. VERSION .. " starting...")

local function LoadModule(path)
    local url = BASE_URL .. path
    print("Loading: " .. path)

    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success or not response then
        warn("Failed to download: " .. path)
        return nil
    end

    local func, err = loadstring(response)
    if not func then
        warn("loadstring error in: " .. path)
        warn(err)
        return nil
    end

    local ok, result = pcall(func)
    if ok then
        print("Loaded: " .. path)
        return result
    else
        warn("Execution error in: " .. path)
        warn(result)
        return nil
    end
end

local Config    = LoadModule("Config.lua")
local Colors    = LoadModule("Theme/Colors.lua")
local Icons     = LoadModule("Utils/Icons.lua")
local Language  = LoadModule("Utils/Language.lua")
local MainFrame = LoadModule("UI/MainFrame.lua")

print("Creating UI...")

if MainFrame and type(MainFrame) == "table" and MainFrame.Create then
    local ok, gui = pcall(MainFrame.Create)
    if ok then
        print("UI Created Successfully!")
    else
        warn("UI Creation Failed:")
        warn(gui)
    end
else
    warn("MainFrame not loaded correctly!")
    warn("MainFrame type: " .. type(MainFrame))
end

print("WiliExplorer Ready!")
