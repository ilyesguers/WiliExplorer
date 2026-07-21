--[[
    ═══════════════════════════════════════════════════════════════════════════
    ✏️ WiliExplorer - File Editor v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ قراءة السورس
    ✅ كتابة السورس
    ✅ تعديل الخصائص
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local FileEditor = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 📖 قراءة السورس
-- ═══════════════════════════════════════════════════════════════════════
function FileEditor.ReadSource(instance)
    if not instance then return nil end
    
    local source = nil
    pcall(function()
        source = instance.Source
    end)
    
    return source
end

-- ═══════════════════════════════════════════════════════════════════════
-- ✏️ كتابة السورس
-- ═══════════════════════════════════════════════════════════════════════
function FileEditor.WriteSource(instance, newSource)
    if not instance or not newSource then return false end
    
    local success = false
    
    -- محاولة 1: كتابة مباشرة
    pcall(function()
        instance.Source = newSource
        success = true
    end)
    
    -- محاولة 2: setscriptable
    if not success then
        pcall(function()
            if setscriptable then
                setscriptable(instance, "Source", true)
                instance.Source = newSource
                success = true
            end
        end)
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- ⚙️ تعديل خاصية
-- ═══════════════════════════════════════════════════════════════════════
function FileEditor.SetProperty(instance, property, value)
    if not instance or not property then return false end
    
    local success = pcall(function()
        instance[property] = value
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function FileEditor.CanEdit(instance)
    if not instance then return false end
    
    local canEdit = false
    pcall(function()
        if instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
            canEdit = true
        end
    end)
    
    return canEdit
end

print("✏️ File Editor v1.0 Loaded!")

return FileEditor
