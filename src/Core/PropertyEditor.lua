--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚙️ WiliExplorer - Property Editor v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تعديل خصائص العناصر
    ✅ قراءة الخصائص
    ✅ مقارنة القيم
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local PropertyEditor = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 📖 قراءة الخاصية
-- ═══════════════════════════════════════════════════════════════════════
function PropertyEditor.Get(instance, property)
    if not instance or not property then return nil end
    
    local success, value = pcall(function()
        return instance[property]
    end)
    
    if success then return value end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- ✏️ تعديل الخاصية
-- ═══════════════════════════════════════════════════════════════════════
function PropertyEditor.Set(instance, property, value)
    if not instance or not property then return false end
    
    local success = pcall(function()
        instance[property] = value
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 قراءة كل الخصائص
-- ═══════════════════════════════════════════════════════════════════════
function PropertyEditor.GetAll(instance)
    if not instance then return {} end
    
    local properties = {}
    
    local commonProps = {
        "Name", "ClassName", "Parent",
        "Position", "Size", "CFrame", "Orientation",
        "Color", "Material", "Transparency", "Reflectance",
        "Anchored", "CanCollide", "CanTouch", "CanQuery",
        "Text", "TextColor3", "TextSize", "Font",
        "Visible", "BackgroundColor3", "BackgroundTransparency",
        "Image", "ImageColor3", "ImageTransparency",
        "SoundId", "Volume", "Pitch", "PlaybackSpeed", "Looped",
        "Value", "Enabled", "Disabled"
    }
    
    for _, prop in ipairs(commonProps) do
        local success, value = pcall(function()
            return instance[prop]
        end)
        
        if success and value ~= nil then
            properties[prop] = value
        end
    end
    
    return properties
end

print("⚙️ Property Editor v1.0 Loaded!")

return PropertyEditor
