local Logger = {Level = "info", Entries = {}, MaxEntries = 250}
local order = {debug = 1, info = 2, warn = 3, error = 4}

function Logger.SetLevel(level)
    if order[level] then Logger.Level = level end
end

function Logger.Log(level, scope, message, context)
    level = order[level] and level or "info"
    local entry = {time = os.time(), level = level, scope = scope or "App", message = tostring(message), context = context}
    table.insert(Logger.Entries, entry)
    while #Logger.Entries > Logger.MaxEntries do table.remove(Logger.Entries, 1) end
    if order[level] >= order[Logger.Level] then
        local line = string.format("[WiliExplorer][%s][%s] %s", level:upper(), entry.scope, entry.message)
        if level == "warn" or level == "error" then warn(line) else print(line) end
    end
    return entry
end

function Logger.Debug(scope, message, context) return Logger.Log("debug", scope, message, context) end
function Logger.Info(scope, message, context) return Logger.Log("info", scope, message, context) end
function Logger.Warn(scope, message, context) return Logger.Log("warn", scope, message, context) end
function Logger.Error(scope, message, context) return Logger.Log("error", scope, message, context) end
function Logger.GetEntries(level)
    if not level then return Logger.Entries end
    local result = {}
    for _, entry in ipairs(Logger.Entries) do if entry.level == level then table.insert(result, entry) end end
    return result
end
function Logger.Clear() table.clear(Logger.Entries) end

return Logger
