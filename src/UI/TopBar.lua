--[[
    ═══════════════════════════════════════════════════════════════════════════
    📊 WiliExplorer - Top Bar v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ الشريط العلوي
    ✅ أزرار التحكم
    ✅ معلومات التطبيق
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local TopBar = {}

-- Services
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 إنشاء الشريط العلوي
-- ═══════════════════════════════════════════════════════════════════════
function TopBar.Create(parent, options)
    options = options or {}
    
    local bar = Instance.new("Frame")
    bar.Name = "TopBar"
    bar.Size = UDim2.new(1, 0, 0, options.height or 50)
    bar.BackgroundColor3 = options.bgColor or Color3.fromRGB(15, 18, 40)
    bar.BorderSizePixel = 0
    bar.ZIndex = options.zIndex or 100
    bar.Parent = parent
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = options.title or "WiliExplorer"
    title.TextColor3 = options.titleColor or Color3.fromRGB(0, 212, 255)
    title.TextSize = options.titleSize or 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = (options.zIndex or 100) + 1
    title.Parent = bar
    
    -- زر إغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    closeBtn.ZIndex = (options.zIndex or 100) + 1
    closeBtn.Parent = bar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    return {
        bar = bar,
        title = title,
        closeBtn = closeBtn
    }
end

print("📊 Top Bar v1.0 Loaded!")

return TopBar
