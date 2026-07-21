--[[
    ═══════════════════════════════════════════════════════════════════════════
    📄 WiliExplorer - Content Panel v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ لوحة المحتوى الرئيسية
    ✅ إدارة الصفحات
    ✅ تبديل الصفحات
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local ContentPanel = {}

-- Services
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════════════════
-- 📄 إنشاء لوحة المحتوى
-- ═══════════════════════════════════════════════════════════════════════
function ContentPanel.Create(parent)
    local panel = Instance.new("Frame")
    panel.Name = "ContentPanel"
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.Parent = parent
    
    local pages = {}
    local currentPage = nil
    
    -- ═══ إنشاء صفحة ═══
    local function CreatePage(name)
        local page = Instance.new("Frame")
        page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = panel
        
        pages[name] = page
        return page
    end
    
    -- ═══ تبديل الصفحة ═══
    local function SwitchPage(name)
        if currentPage == name then return end
        
        for pageName, page in pairs(pages) do
            if pageName == name then
                page.Visible = true
                TweenService:Create(page, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            else
                page.Visible = false
            end
        end
        
        currentPage = name
    end
    
    return {
        panel = panel,
        createPage = CreatePage,
        switchPage = SwitchPage,
        getPages = function() return pages end,
        getCurrentPage = function() return currentPage end
    }
end

print("📄 Content Panel v1.0 Loaded!")

return ContentPanel
