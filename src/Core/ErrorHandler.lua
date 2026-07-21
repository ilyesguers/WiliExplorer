--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚠️ WiliExplorer - Error Handler v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ معالجة الأخطاء بشكل جميل
    ✅ تسجيل الأخطاء
    ✅ إعادة المحاولة التلقائية
    ✅ إشعارات الأخطاء
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local ErrorHandler = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local ErrorLog = {}
local MaxErrors = 100

-- ═══════════════════════════════════════════════════════════════════════
-- ⚠️ تسجيل الخطأ
-- ═══════════════════════════════════════════════════════════════════════
function ErrorHandler.Log(source, message, stackTrace)
    local error = {
        source = source or "Unknown",
        message = message or "Unknown error",
        stackTrace = stackTrace or "",
        time = os.date("%H:%M:%S"),
        timestamp = tick()
    }
    
    table.insert(ErrorLog, 1, error)
    
    -- حد أقصى
    if #ErrorLog > MaxErrors then
        table.remove(ErrorLog)
    end
    
    return error
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 إعادة المحاولة
-- ═══════════════════════════════════════════════════════════════════════
function ErrorHandler.Retry(func, maxRetries, delay)
    maxRetries = maxRetries or 3
    delay = delay or 0.5
    
    for i = 1, maxRetries do
        local success, result = pcall(func)
        
        if success then
            return true, result
        end
        
        if i < maxRetries then
            task.wait(delay)
        end
    end
    
    return false, "Max retries reached"
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🛡️ تشغيل آمن
-- ═══════════════════════════════════════════════════════════════════════
function ErrorHandler.SafeCall(func, fallback)
    local success, result = pcall(func)
    
    if success then
        return result
    else
        ErrorHandler.Log("SafeCall", tostring(result))
        if fallback then
            return fallback()
        end
        return nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function ErrorHandler.GetLog()
    return ErrorLog
end

function ErrorHandler.ClearLog()
    ErrorLog = {}
end

function ErrorHandler.GetCount()
    return #ErrorLog
end

print("⚠️ Error Handler v1.0 Loaded!")

return ErrorHandler
