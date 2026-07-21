--[[
    ═══════════════════════════════════════════════════════════════════════════
    ✍️ WiliExplorer - Fonts System v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ خطوط متنوعة للواجهة
    ✅ أحجام مختلفة
    ✅ أنماط مختلفة
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Fonts = {}

-- ═══════════════════════════════════════════════════════════════════════
-- ✍️ الخطوط المتاحة
-- ═══════════════════════════════════════════════════════════════════════
Fonts.Default = {
    Title = Enum.Font.GothamBlack,
    Subtitle = Enum.Font.GothamBold,
    Body = Enum.Font.Gotham,
    Code = Enum.Font.Code,
    Mono = Enum.Font.RobotoMono
}

Fonts.Sizes = {
    Title = 24,
    Subtitle = 18,
    Body = 14,
    Small = 12,
    Tiny = 10,
    Code = 13
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function Fonts.GetFont(style)
    return Fonts.Default[style] or Enum.Font.Gotham
end

function Fonts.GetSize(size)
    return Fonts.Sizes[size] or 14
end

print("✍️ Fonts System v1.0 Loaded!")

return Fonts
