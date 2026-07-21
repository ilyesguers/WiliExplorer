--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔍 WiliExplorer - Search Bar v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ بحث فوري (Instant Search)
    ✅ اقتراحات ذكية
    ✅ فلترة حسب النوع
    ✅ تاريخ البحث
    ✅ بحث متقدم (Regex)
    ✅ تمييز النتائج
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local SearchBar = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    BG = Color3.fromRGB(15, 15, 30),
    BGFocus = Color3.fromRGB(20, 20, 40),
    Border = Color3.fromRGB(40, 40, 70),
    BorderFocus = Color3.fromRGB(0, 212, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(120, 130, 160),
    Accent = Color3.fromRGB(0, 212, 255),
    Suggestion = Color3.fromRGB(25, 25, 50),
    SuggestionHover = Color3.fromRGB(35, 35, 65),
    Highlight = Color3.fromRGB(255, 215, 0)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local SearchHistory = {}
local MaxHistory = 10

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), props):Play()
end

local function AddToHistory(query)
    if not query or query == "" then return end
    
    -- إزالة إذا كان موجود
    for i, h in ipairs(SearchHistory) do
        if h == query then
            table.remove(SearchHistory, i)
            break
        end
    end
    
    -- إضافة في البداية
    table.insert(SearchHistory, 1, query)
    
    -- حد أقصى
    if #SearchHistory > MaxHistory then
        table.remove(SearchHistory)
    end
end

local function HighlightText(text, query)
    if not query or query == "" then return text end
    
    local lowerText = text:lower()
    local lowerQuery = query:lower()
    local start = lowerText:find(lowerQuery, 1, true)
    
    if start then
        local before = text:sub(1, start - 1)
        local match = text:sub(start, start + #query - 1)
        local after = text:sub(start + #query)
        return before .. "«" .. match .. "»" .. after
    end
    
    return text
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 إنشاء شريط البحث
-- ═══════════════════════════════════════════════════════════════════════
function SearchBar.Create(parent, options)
    options = options or {}
    
    -- الإطار الرئيسي
    local container = Instance.new("Frame")
    container.Name = "SearchContainer"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Colors.BG
    container.BorderSizePixel = 0
    container.Parent = parent
    
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1.5
    stroke.Parent = container
    
    -- أيقونة البحث
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 35, 1, 0)
    searchIcon.Position = UDim2.new(0, 5, 0, 0)
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 16
    searchIcon.BackgroundTransparency = 1
    searchIcon.ZIndex = 10
    searchIcon.Parent = container
    
    -- حقل الإدخال
    local input = Instance.new("TextBox")
    input.Name = "SearchInput"
    input.Size = UDim2.new(1, -90, 1, -8)
    input.Position = UDim2.new(0, 40, 0, 4)
    input.PlaceholderText = options.placeholder or "🔍 Search..."
    input.Text = ""
    input.TextColor3 = Colors.Text
    input.PlaceholderColor3 = Colors.Placeholder
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.BackgroundTransparency = 1
    input.ZIndex = 10
    input.Parent = container
    
    -- زر مسح
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 25, 0, 25)
    clearBtn.Position = UDim2.new(1, -30, 0.5, -12)
    clearBtn.Text = "✕"
    clearBtn.TextColor3 = Colors.Placeholder
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.BackgroundTransparency = 1
    clearBtn.Visible = false
    clearBtn.ZIndex = 10
    clearBtn.Parent = container
    
    -- زر فلتر
    local filterBtn = Instance.new("TextButton")
    filterBtn.Size = UDim2.new(0, 25, 0, 25)
    filterBtn.Position = UDim2.new(1, -55, 0.5, -12)
    filterBtn.Text = "⚙️"
    filterBtn.TextSize = 14
    filterBtn.BackgroundTransparency = 1
    filterBtn.ZIndex = 10
    filterBtn.Parent = container
    
    -- قائمة الاقتراحات
    local suggestionsFrame = Instance.new("Frame")
    suggestionsFrame.Name = "Suggestions"
    suggestionsFrame.Size = UDim2.new(1, 0, 0, 0)
    suggestionsFrame.Position = UDim2.new(0, 0, 1, 5)
    suggestionsFrame.BackgroundColor3 = Colors.BG
    suggestionsFrame.BorderSizePixel = 0
    suggestionsFrame.ClipsDescendants = true
    suggestionsFrame.Visible = false
    suggestionsFrame.ZIndex = 100
    suggestionsFrame.Parent = container
    
    Instance.new("UICorner", suggestionsFrame).CornerRadius = UDim.new(0, 10)
    
    local sugStroke = Instance.new("UIStroke")
    sugStroke.Color = Colors.Border
    sugStroke.Thickness = 1
    sugStroke.Parent = suggestionsFrame
    
    local sugLayout = Instance.new("UIListLayout")
    sugLayout.Padding = UDim.new(0, 2)
    sugLayout.Parent = suggestionsFrame
    
    local sugPad = Instance.new("UIPadding")
    sugPad.PaddingTop = UDim.new(0, 4)
    sugPad.PaddingBottom = UDim.new(0, 4)
    sugPad.PaddingLeft = UDim.new(0, 4)
    sugPad.PaddingRight = UDim.new(0, 4)
    sugPad.Parent = suggestionsFrame

    -- ═══ المنطق ═══
    local lastQuery = ""
    local suggestions = {}
    
    local function ShowSuggestions(query)
        -- مسح الاقتراحات القديمة
        for _, child in ipairs(suggestionsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        if not query or query == "" then
            -- عرض التاريخ
            if #SearchHistory > 0 then
                suggestions = SearchHistory
            else
                suggestionsFrame.Visible = false
                return
            end
        else
            -- تصفية حسب الاستعلام
            suggestions = {}
            if options.suggestions then
                for _, s in ipairs(options.suggestions) do
                    if s:lower():find(query:lower(), 1, true) then
                        table.insert(suggestions, s)
                    end
                    if #suggestions >= 8 then break end
                end
            end
            
            -- إضافة من التاريخ
            for _, h in ipairs(SearchHistory) do
                if h:lower():find(query:lower(), 1, true) then
                    local found = false
                    for _, s in ipairs(suggestions) do
                        if s == h then found = true; break end
                    end
                    if not found then
                        table.insert(suggestions, h)
                    end
                end
                if #suggestions >= 8 then break end
            end
        end
        
        if #suggestions == 0 then
            suggestionsFrame.Visible = false
            return
        end
        
        -- إنشاء عناصر الاقتراحات
        local totalHeight = 0
        for i, sug in ipairs(suggestions) do
            local btn = Instance.new("TextButton")
            btn.Name = "Sug_" .. i
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.BackgroundColor3 = Colors.Suggestion
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 101
            btn.Parent = suggestionsFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 25, 1, 0)
            icon.Position = UDim2.new(0, 5, 0, 0)
            icon.Text = i <= #SearchHistory and "🕐" or "🔍"
            icon.TextSize = 12
            icon.BackgroundTransparency = 1
            icon.ZIndex = 102
            icon.Parent = btn
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, -35, 1, 0)
            text.Position = UDim2.new(0, 30, 0, 0)
            text.Text = HighlightText(sug, query)
            text.TextColor3 = Colors.Text
            text.TextSize = 12
            text.Font = Enum.Font.Gotham
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.TextTruncate = Enum.TextTruncate.AtEnd
            text.BackgroundTransparency = 1
            text.ZIndex = 102
            text.Parent = btn
            
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundTransparency = 0}, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundTransparency = 1}, 0.1)
            end)
            
            btn.MouseButton1Click:Connect(function()
                input.Text = sug
                AddToHistory(sug)
                suggestionsFrame.Visible = false
                if options.onSearch then options.onSearch(sug) end
            end)
            
            totalHeight = totalHeight + 32
        end
        
        suggestionsFrame.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 200))
        suggestionsFrame.Visible = true
        
        Tween(suggestionsFrame, {Size = UDim2.new(1, 0, 0, math.min(totalHeight, 200))}, 0.2)
    end
    
    local function HideSuggestions()
        Tween(suggestionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        task.delay(0.2, function()
            suggestionsFrame.Visible = false
        end)
    end
    
    -- ═══ الأحداث ═══
    input.Focused:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.BGFocus}, 0.2)
        Tween(stroke, {Color = Colors.BorderFocus}, 0.2)
        ShowSuggestions(input.Text)
    end)
    
    input.FocusLost:Connect(function()
        Tween(container, {BackgroundColor3 = Colors.BG}, 0.2)
        Tween(stroke, {Color = Colors.Border}, 0.2)
        task.delay(0.2, function()
            HideSuggestions()
        end)
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        local query = input.Text
        clearBtn.Visible = query ~= ""
        
        if query ~= lastQuery then
            lastQuery = query
            ShowSuggestions(query)
            
            if options.onSearch then
                options.onSearch(query)
            end
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        input.Text = ""
        clearBtn.Visible = false
        if options.onSearch then options.onSearch("") end
    end)
    
    filterBtn.MouseButton1Click:Connect(function()
        if options.onFilter then options.onFilter() end
    end)
    
    -- ═══ API ═══
    local api = {}
    
    function api:GetText()
        return input.Text
    end
    
    function api:SetText(text)
        input.Text = text
    end
    
    function api:Focus()
        input:CaptureFocus()
    end
    
    function api:ClearHistory()
        SearchHistory = {}
    end
    
    function api:GetHistory()
        return SearchHistory
    end
    
    function api:SetSuggestions(sugs)
        options.suggestions = sugs
    end
    
    function api:Destroy()
        container:Destroy()
    end
    
    return api, container
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 بحث متقدم (Filter)
-- ═══════════════════════════════════════════════════════════════════════
function SearchBar.CreateFilter(parent, filters)
    local container = Instance.new("Frame")
    container.Name = "FilterContainer"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    container.BorderSizePixel = 0
    container.Parent = parent
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = container
    
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingTop = UDim.new(0, 4)
    pad.Parent = container
    
    local activeFilters = {}
    
    for i, filter in ipairs(filters) do
        local btn = Instance.new("TextButton")
        btn.Name = "Filter_" .. i
        btn.Size = UDim2.new(0, 70, 0, 25)
        btn.Text = filter.icon .. " " .. filter.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 10
        btn.Font = Enum.Font.Gotham
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        btn.ZIndex = 10
        btn.Parent = container
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local isActive = false
        
        btn.MouseButton1Click:Connect(function()
            isActive = not isActive
            activeFilters[filter.name] = isActive
            
            if isActive then
                Tween(btn, {BackgroundColor3 = filter.color or Colors.Accent}, 0.15)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(25, 25, 50)}, 0.15)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
    end
    
    return container, activeFilters
end

print("🔍 Search Bar v1.0 Loaded!")

return SearchBar
