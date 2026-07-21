--[[
    ═══════════════════════════════════════════════════════════════════════════
    🌐 WiliExplorer - HTTP Helper v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ طلبات HTTP مبسطة
    ✅ معالجة الأخطاء
    ✅ إعادة المحاولة
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local HTTPHelper = {}

-- Services
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════════════
-- 🌐 GET Request
-- ═══════════════════════════════════════════════════════════════════════
function HTTPHelper.Get(url, headers)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success then
        return true, result
    else
        return false, tostring(result)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📤 POST Request
-- ═══════════════════════════════════════════════════════════════════════
function HTTPHelper.Post(url, data, contentType)
    local success, result = pcall(function()
        return game:HttpPost(url, data, contentType or "application/json")
    end)
    
    if success then
        return true, result
    else
        return false, tostring(result)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 مع إعادة المحاولة
-- ═══════════════════════════════════════════════════════════════════════
function HTTPHelper.GetWithRetry(url, maxRetries, delay)
    maxRetries = maxRetries or 3
    delay = delay or 1
    
    for i = 1, maxRetries do
        local success, result = HTTPHelper.Get(url)
        if success then return true, result end
        
        if i < maxRetries then
            task.wait(delay)
        end
    end
    
    return false, "Max retries reached"
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 JSON
-- ═══════════════════════════════════════════════════════════════════════
function HTTPHelper.DecodeJSON(json)
    local success, result = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    return success, result
end

function HTTPHelper.EncodeJSON(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    return success, result
end

print("🌐 HTTP Helper v1.0 Loaded!")

return HTTPHelper
