-- WiliExplorer bootstrap loader v6.1
-- Config-driven, cache-aware, and free of artificial per-module delays.

if _G.WiliExplorerLoaded then
    warn("WiliExplorer is already loaded")
    return _G.WiliModules
end
_G.WiliExplorerLoaded = true

local BOOTSTRAP_REF = "main"
local REPOSITORY = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/"
local BASE_URL = REPOSITORY .. BOOTSTRAP_REF .. "/src/"
local Modules, LoadOrder, LoadErrors = {}, {}, {}
local startedAt = tick()

local function cacheSupported()
    return writefile and readfile and isfile and isfolder and makefolder
end

local function ensureFolder(path)
    if cacheSupported() and not isfolder(path) then pcall(function() makefolder(path) end) end
end

local function cachePath(path)
    local version = (_G.WiliConfig and _G.WiliConfig.Version) or "bootstrap"
    return "WiliExplorer/cache/" .. version .. "/" .. path:gsub("/", "_")
end

local function fetch(path)
    local url = BASE_URL .. path
    local ok, source = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(source) == "string" and #source > 0 then return source, true end
    local pathToCache = cachePath(path)
    if cacheSupported() and isfile(pathToCache) then
        local cacheOk, cached = pcall(function() return readfile(pathToCache) end)
        if cacheOk and type(cached) == "string" and #cached > 0 then return cached, false end
    end
    return nil, false, tostring(source)
end

local function writeCache(path, source)
    if not cacheSupported() then return end
    ensureFolder("WiliExplorer")
    ensureFolder("WiliExplorer/cache")
    ensureFolder("WiliExplorer/cache/" .. ((_G.WiliConfig and _G.WiliConfig.Version) or "bootstrap"))
    pcall(function() writefile(cachePath(path), source) end)
end

local function loadModule(path, name, required)
    if Modules[name] ~= nil then return Modules[name] end
    local source, fromNetwork, fetchError = fetch(path)
    if not source then
        LoadErrors[name] = "Fetch failed: " .. tostring(fetchError)
        if required then warn("Required module failed: " .. name) end
        return nil
    end
    local chunk, parseError = loadstring(source)
    if not chunk then
        LoadErrors[name] = "Parse failed: " .. tostring(parseError)
        if required then warn("Required module has invalid syntax: " .. name) end
        return nil
    end
    if fromNetwork then writeCache(path, source) end
    local ok, result = pcall(chunk)
    if not ok then
        LoadErrors[name] = "Runtime failed: " .. tostring(result)
        if required then warn("Required module crashed: " .. name .. " - " .. tostring(result)) end
        return nil
    end
    Modules[name] = result
    table.insert(LoadOrder, name)
    return result
end

-- Bootstrap the single source of truth first.
Modules.Config = loadModule("Config.lua", "Config", true)
if not Modules.Config then
    _G.WiliExplorerLoaded = false
    error("WiliExplorer cannot start without Config")
end
_G.WiliConfig = Modules.Config

-- A release can pin this to a tag/commit in Config without changing the loader.
local distribution = Modules.Config.Distribution or {}
if distribution.Repository then REPOSITORY = distribution.Repository end
if distribution.Ref and distribution.Ref ~= "" then BOOTSTRAP_REF = distribution.Ref end
BASE_URL = REPOSITORY .. BOOTSTRAP_REF .. "/src/"

local required = {Colors = true, Language = true, KeySystem = true, FileScanner = true, MainFrame = true}
local folders = {Security = "Security", Theme = "Theme", Utils = "Utils", Core = "Core", UI = "UI"}
local configOrder = {"Theme", "Utils", "Security", "Core", "UI"}

-- Publish early so modules can resolve already-loaded dependencies without re-fetching.
_G.WiliModules = Modules

for _, category in ipairs(configOrder) do
    local names = Modules.Config.Modules and Modules.Config.Modules[category] or {}
    for _, name in ipairs(names) do
        if name ~= "MainFrame" then
            loadModule(folders[category] .. "/" .. name .. ".lua", name, required[name] == true)
        end
    end
end

-- Apply persisted preferences once, after all support modules exist.
if Modules.SaveSystem and Modules.SaveSystem.Init then
    pcall(function()
        local saved = Modules.SaveSystem.Init()
        if Modules.Language and Modules.Language.Set and saved.language then Modules.Language.Set(saved.language) end
        if Modules.Colors and Modules.Colors.SetTheme and saved.theme then
            local themeName = saved.theme:sub(1, 1):upper() .. saved.theme:sub(2):lower()
            Modules.Colors.SetTheme(themeName)
        end
    end)
end

-- MainFrame is intentionally last; all optional capabilities are available by then.
Modules.MainFrame = loadModule("UI/MainFrame.lua", "MainFrame", true)
Modules.LoadReport = {
    version = Modules.Config.Version,
    ref = BOOTSTRAP_REF,
    loaded = LoadOrder,
    errors = LoadErrors,
    duration = tick() - startedAt
}

if not Modules.MainFrame or type(Modules.MainFrame.Create) ~= "function" then
    _G.WiliExplorerLoaded = false
    error("WiliExplorer UI failed to load")
end

local ok, uiOrError = pcall(Modules.MainFrame.Create)
if not ok then
    _G.WiliExplorerLoaded = false
    warn("WiliExplorer UI error: " .. tostring(uiOrError))
    return Modules
end

print(string.format("WiliExplorer %s ready • %d modules • %.2fs", Modules.Config.Version, #LoadOrder, tick() - startedAt))
return Modules
