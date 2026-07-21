--[[
    ═══════════════════════════════════════════════════════════════════════════
    📁 WiliExplorer - File Actions v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ نسخ الملفات
    ✅ حذف الملفات
    ✅ نقل الملفات
    ✅ إعادة التسمية
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local FileActions = {}

-- Services
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 نسخ العنصر
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.Clone(instance)
    if not instance then return nil end
    
    local success, clone = pcall(function()
        return instance:Clone()
    end)
    
    if success then
        return clone
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🗑️ حذف العنصر
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.Delete(instance)
    if not instance then return false end
    
    local success = pcall(function()
        instance:Destroy()
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📝 إعادة التسمية
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.Rename(instance, newName)
    if not instance or not newName then return false end
    
    local success = pcall(function()
        instance.Name = newName
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📂 نقل العنصر
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.Move(instance, newParent)
    if not instance or not newParent then return false end
    
    local success = pcall(function()
        instance.Parent = newParent
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 نسخ المسار
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.CopyPath(instance)
    if not instance then return false end
    
    local path = instance:GetFullName()
    
    pcall(function()
        if setclipboard then setclipboard(path) end
    end)
    
    return true
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function FileActions.GetInfo(instance)
    if not instance then return {} end
    
    return {
        name = instance.Name,
        className = instance.ClassName,
        path = instance:GetFullName(),
        parent = instance.Parent and instance.Parent.Name or "nil",
        children = #instance:GetChildren(),
        descendants = #instance:GetDescendants()
    }
end

print("📁 File Actions v1.0 Loaded!")

return FileActions
