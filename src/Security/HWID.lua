--[[
    ═══════════════════════════════════════════════════════════════════════════
    💻 WiliExplorer - HWID System v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ ربط الجهاز بالمفتاح
    ✅ منع استخدام المفتاح على أجهزة متعددة
    ✅ حماية من الابتزاز
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local HWID = {}

-- Services
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 💻 الحصول على HWID
-- ═══════════════════════════════════════════════════════════════════════
function HWID.GetHWID()
    local hwid = ""
    
    -- محاولة 1: استخدام gethwid
    pcall(function()
        if gethwid then
            hwid = gethwid()
        end
    end)
    
    -- محاولة 2: استخدام executor
    if hwid == "" then
        pcall(function()
            local executor = identifyexecutor()
            if executor then
                hwid = executor .. "_" .. tostring(LocalPlayer.UserId)
            end
        end)
    end
    
    -- محاولة 3: استخدام UserId
    if hwid == "" then
        hwid = "USER_" .. tostring(LocalPlayer.UserId)
    end
    
    return hwid
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 التحقق من HWID
-- ═══════════════════════════════════════════════════════════════════════
function HWID.Verify(storedHWID)
    local currentHWID = HWID.GetHWID()
    return currentHWID == storedHWID
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function HWID.GetInfo()
    return {
        hwid = HWID.GetHWID(),
        userId = LocalPlayer.UserId,
        username = LocalPlayer.Name
    }
end

print("💻 HWID System v1.0 Loaded!")

return HWID
