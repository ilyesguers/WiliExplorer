local KeySystem = {}

local BASE_URL = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/"

function KeySystem.LoadKeys()
    local success, response = pcall(function()
        return game:HttpGet(BASE_URL .. "Security/Keys.lua", true)
    end)
    
    if not success then
        warn("Failed to load keys")
        return {}
    end
    
    local func = loadstring(response)
    if not func then return {} end
    
    local ok, keys = pcall(func)
    if ok then return keys end
    return {}
end

function KeySystem.Verify(inputKey)
    if not inputKey or inputKey == "" then
        return false, "Empty key"
    end
    
    local keys = KeySystem.LoadKeys()
    local keyData = keys[inputKey]
    
    if not keyData then
        return false, "Invalid key"
    end
    
    if not keyData.active then
        return false, "Key disabled"
    end
    
    return true, keyData
end

return KeySystem
