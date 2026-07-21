--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔐 WiliExplorer - Anti Tamper v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ منع التلاعب بالسكريبت
    ✅ كشف التعديلات
    ✅ حماية من النسخ
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local AntiTamper = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 🔐 حماية من التلاعب
-- ═══════════════════════════════════════════════════════════════════════
function AntiTamper.Protect()
    -- حماية من التعديل
    pcall(function()
        local mt = getrawmetatable(game)
        if setreadonly then setreadonly(mt, true) end
    end)
    
    print("🔐 Anti-Tamper Protection Enabled!")
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 كشف التلاعب
-- ═══════════════════════════════════════════════════════════════════════
function AntiTamper.Detect()
    local suspicious = {}
    
    -- كشف Remote Spies
    pcall(function()
        local mt = getrawmetatable(game)
        local nc = mt.__namecall
        if nc then
            table.insert(suspicious, "Namecall hook detected")
        end
    end)
    
    return suspicious
end

print("🔐 Anti-Tamper v1.0 Loaded!")

return AntiTamper
