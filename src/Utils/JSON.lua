--[[
    ═══════════════════════════════════════════════════════════════════════════
    📄 WiliExplorer - JSON Helper v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تحليل JSON
    ✅ تحويل إلى JSON
    ✅ معالجة الأخطاء
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local JSONHelper = {}

-- Services
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════════════
-- 📄 تحليل JSON
-- ═══════════════════════════════════════════════════════════════════════
function JSONHelper.Decode(json)
    if not json or json == "" then return nil, "Empty JSON" end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    
    if success then
        return result
    else
        return nil, tostring(result)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📤 تحويل إلى JSON
-- ═══════════════════════════════════════════════════════════════════════
function JSONHelper.Encode(data)
    if data == nil then return "null" end
    
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if success then
        return result
    else
        return "{}"
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function JSONHelper.IsValid(json)
    local success = pcall(function()
        HttpService:JSONDecode(json)
    end)
    return success
end

print("📄 JSON Helper v1.0 Loaded!")

return JSONHelper
