--[[
    ═══════════════════════════════════════════════════════════════════════════
    🎨 WiliExplorer - Theme System v2.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ نظام ألوان موحد لكل المشروع
    ✅ ثيمات متعددة (Space, Cyber, Ocean, Sunset)
    ✅ ألوان متناسقة وجميلة
    ✅ سهولة التبديل بين الثيمات
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Colors = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 🌌 ثيم Space (الافتراضي)
-- ═══════════════════════════════════════════════════════════════════════
Colors.Space = {
    -- الخلفيات
    BG_Primary = Color3.fromRGB(8, 8, 18),
    BG_Secondary = Color3.fromRGB(12, 12, 28),
    BG_Tertiary = Color3.fromRGB(18, 18, 38),
    BG_Card = Color3.fromRGB(15, 15, 32),
    BG_CardHover = Color3.fromRGB(22, 22, 45),
    BG_CardActive = Color3.fromRGB(28, 28, 55),
    BG_Header = Color3.fromRGB(10, 10, 25),
    
    -- الألوان الرئيسية
    Accent = Color3.fromRGB(0, 212, 255),
    AccentDark = Color3.fromRGB(0, 152, 219),
    AccentGlow = Color3.fromRGB(0, 245, 255),
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(0, 255, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Purple = Color3.fromRGB(138, 43, 226),
    Pink = Color3.fromRGB(255, 0, 128),
    Cyan = Color3.fromRGB(0, 255, 255),
    
    -- ألوان الحالة
    Success = Color3.fromRGB(0, 255, 100),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    
    -- النصوص
    Text_Primary = Color3.fromRGB(255, 255, 255),
    Text_Secondary = Color3.fromRGB(150, 170, 200),
    Text_Dim = Color3.fromRGB(120, 130, 160),
    Text_Accent = Color3.fromRGB(0, 212, 255),
    
    -- الحدود
    Border = Color3.fromRGB(40, 40, 70),
    Border_Light = Color3.fromRGB(50, 50, 85),
    Border_Accent = Color3.fromRGB(0, 212, 255),
    
    -- أخرى
    Shadow = Color3.fromRGB(0, 0, 0),
    Hover = Color3.fromRGB(30, 35, 60),
    Selected = Color3.fromRGB(0, 80, 120),
    Scrollbar = Color3.fromRGB(0, 152, 219),
    Separator = Color3.fromRGB(35, 35, 65)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🌊 ثيم Ocean
-- ═══════════════════════════════════════════════════════════════════════
Colors.Ocean = {
    BG_Primary = Color3.fromRGB(5, 15, 30),
    BG_Secondary = Color3.fromRGB(8, 20, 40),
    BG_Tertiary = Color3.fromRGB(12, 28, 55),
    BG_Card = Color3.fromRGB(10, 22, 45),
    BG_CardHover = Color3.fromRGB(15, 30, 55),
    BG_CardActive = Color3.fromRGB(20, 38, 65),
    BG_Header = Color3.fromRGB(8, 18, 35),
    
    Accent = Color3.fromRGB(0, 180, 255),
    AccentDark = Color3.fromRGB(0, 130, 200),
    AccentGlow = Color3.fromRGB(50, 200, 255),
    Primary = Color3.fromRGB(0, 150, 255),
    Secondary = Color3.fromRGB(0, 255, 200),
    Gold = Color3.fromRGB(255, 220, 100),
    Purple = Color3.fromRGB(100, 100, 255),
    Pink = Color3.fromRGB(200, 100, 255),
    Cyan = Color3.fromRGB(0, 220, 255),
    
    Success = Color3.fromRGB(0, 220, 150),
    Error = Color3.fromRGB(255, 80, 80),
    Warning = Color3.fromRGB(255, 200, 50),
    Info = Color3.fromRGB(80, 180, 255),
    
    Text_Primary = Color3.fromRGB(220, 240, 255),
    Text_Secondary = Color3.fromRGB(130, 160, 200),
    Text_Dim = Color3.fromRGB(100, 130, 170),
    Text_Accent = Color3.fromRGB(0, 180, 255),
    
    Border = Color3.fromRGB(30, 50, 80),
    Border_Light = Color3.fromRGB(40, 60, 95),
    Border_Accent = Color3.fromRGB(0, 180, 255),
    
    Shadow = Color3.fromRGB(0, 5, 15),
    Hover = Color3.fromRGB(15, 30, 55),
    Selected = Color3.fromRGB(0, 60, 100),
    Scrollbar = Color3.fromRGB(0, 130, 200),
    Separator = Color3.fromRGB(25, 45, 75)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🌅 ثيم Sunset
-- ═══════════════════════════════════════════════════════════════════════
Colors.Sunset = {
    BG_Primary = Color3.fromRGB(20, 10, 15),
    BG_Secondary = Color3.fromRGB(30, 15, 25),
    BG_Tertiary = Color3.fromRGB(40, 20, 35),
    BG_Card = Color3.fromRGB(35, 18, 30),
    BG_CardHover = Color3.fromRGB(45, 25, 40),
    BG_CardActive = Color3.fromRGB(55, 30, 48),
    BG_Header = Color3.fromRGB(25, 12, 20),
    
    Accent = Color3.fromRGB(255, 100, 50),
    AccentDark = Color3.fromRGB(200, 70, 30),
    AccentGlow = Color3.fromRGB(255, 150, 80),
    Primary = Color3.fromRGB(255, 80, 50),
    Secondary = Color3.fromRGB(255, 180, 100),
    Gold = Color3.fromRGB(255, 200, 50),
    Purple = Color3.fromRGB(180, 50, 150),
    Pink = Color3.fromRGB(255, 50, 100),
    Cyan = Color3.fromRGB(255, 150, 100),
    
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 180, 0),
    Info = Color3.fromRGB(255, 150, 100),
    
    Text_Primary = Color3.fromRGB(255, 230, 220),
    Text_Secondary = Color3.fromRGB(200, 160, 150),
    Text_Dim = Color3.fromRGB(160, 120, 110),
    Text_Accent = Color3.fromRGB(255, 100, 50),
    
    Border = Color3.fromRGB(60, 30, 45),
    Border_Light = Color3.fromRGB(75, 40, 55),
    Border_Accent = Color3.fromRGB(255, 100, 50),
    
    Shadow = Color3.fromRGB(10, 0, 5),
    Hover = Color3.fromRGB(50, 25, 40),
    Selected = Color3.fromRGB(100, 40, 60),
    Scrollbar = Color3.fromRGB(200, 70, 30),
    Separator = Color3.fromRGB(50, 25, 40)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🌲 ثيم Forest
-- ═══════════════════════════════════════════════════════════════════════
Colors.Forest = {
    BG_Primary = Color3.fromRGB(8, 15, 10),
    BG_Secondary = Color3.fromRGB(12, 22, 15),
    BG_Tertiary = Color3.fromRGB(18, 30, 22),
    BG_Card = Color3.fromRGB(15, 25, 18),
    BG_CardHover = Color3.fromRGB(22, 35, 25),
    BG_CardActive = Color3.fromRGB(28, 42, 32),
    BG_Header = Color3.fromRGB(10, 18, 12),
    
    Accent = Color3.fromRGB(0, 200, 100),
    AccentDark = Color3.fromRGB(0, 150, 75),
    AccentGlow = Color3.fromRGB(50, 255, 130),
    Primary = Color3.fromRGB(0, 180, 80),
    Secondary = Color3.fromRGB(100, 255, 150),
    Gold = Color3.fromRGB(200, 255, 100),
    Purple = Color3.fromRGB(100, 200, 150),
    Pink = Color3.fromRGB(150, 255, 180),
    Cyan = Color3.fromRGB(50, 255, 150),
    
    Success = Color3.fromRGB(0, 255, 100),
    Error = Color3.fromRGB(200, 50, 50),
    Warning = Color3.fromRGB(200, 180, 0),
    Info = Color3.fromRGB(80, 200, 150),
    
    Text_Primary = Color3.fromRGB(220, 255, 230),
    Text_Secondary = Color3.fromRGB(140, 180, 150),
    Text_Dim = Color3.fromRGB(100, 140, 110),
    Text_Accent = Color3.fromRGB(0, 200, 100),
    
    Border = Color3.fromRGB(25, 50, 35),
    Border_Light = Color3.fromRGB(35, 60, 45),
    Border_Accent = Color3.fromRGB(0, 200, 100),
    
    Shadow = Color3.fromRGB(0, 5, 0),
    Hover = Color3.fromRGB(20, 35, 25),
    Selected = Color3.fromRGB(0, 60, 40),
    Scrollbar = Color3.fromRGB(0, 150, 75),
    Separator = Color3.fromRGB(20, 40, 30)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 الثيم الحالي (الافتراضي)
-- ═══════════════════════════════════════════════════════════════════════
Colors.Current = Colors.Space

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 تبديل الثيم
-- ═══════════════════════════════════════════════════════════════════════
function Colors.SetTheme(themeName)
    if Colors[themeName] then
        Colors.Current = Colors[themeName]
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 قائمة الثيمات
-- ═══════════════════════════════════════════════════════════════════════
function Colors.GetThemes()
    return {
        {name = "Space", icon = "🌌", description = "ثيم فضائي غامق"},
        {name = "Ocean", icon = "🌊", description = "ثيم محيطي أزرق"},
        {name = "Sunset", icon = "🌅", description = "ثيم غروب دافئ"},
        {name = "Forest", icon = "🌲", description = "ثيم غابة أخضر"}
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 اختصارات سريعة
-- ═══════════════════════════════════════════════════════════════════════
function Colors.Get(key)
    return Colors.Current[key] or Color3.fromRGB(255, 255, 255)
end

function Colors.Lerp(color1, color2, alpha)
    return Color3.new(
        color1.R + (color2.R - color1.R) * alpha,
        color1.G + (color2.G - color1.G) * alpha,
        color1.B + (color2.B - color1.B) * alpha
    )
end

function Colors.WithAlpha(color, alpha)
    return Color3.new(color.R, color.G, color.B)
end

print("🎨 Theme System v2.0 Loaded!")

return Colors
