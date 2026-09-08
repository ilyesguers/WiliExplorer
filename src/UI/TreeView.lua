--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - TreeView v3.0
    ═══════════════════════════════════════════════════════════════════════════
    شجرة تصفح كاملة:
    • فلاتر تغطي كل الفئات (سكربتات/مجسمات/أجزاء/صور/أصوات/واجهات/تأثيرات/...)
    • فرز بالاسم أو بالنوع
    • قائمة سياق (ضغط مطوّل) للنسخ/الاستنساخ/الحذف
    • زر فتح للمجلدات لعرضها في العارض الشامل
    • أيقونة مستقلة عن النص دائماً + نصوص مترجمة
    ═══════════════════════════════════════════════════════════════════════════
]]

local TreeView = {}

local function GetModule(name)
    return assert(_G.WiliModules and _G.WiliModules[name], "TreeView dependency missing: " .. name)
end
local FileScanner = GetModule("FileScanner")
local Language = GetModule("Language")
local Icons = GetModule("Icons")
local ContextMenu = GetModule("ContextMenu")

local TweenService = game:GetService("TweenService")

local function T(key) return Language.Get(key, key) end

local P = {
    BG = Color3.fromRGB(8, 10, 22),
    Surface = Color3.fromRGB(15, 20, 40),
    Raised = Color3.fromRGB(22, 28, 52),
    Hover = Color3.fromRGB(30, 38, 68),
    Text = Color3.fromRGB(242, 247, 255),
    Muted = Color3.fromRGB(150, 168, 197),
    Dim = Color3.fromRGB(110, 125, 155),
    Accent = Color3.fromRGB(0, 212, 255),
    Success = Color3.fromRGB(0, 255, 136)
}

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function Tween(obj, props, duration)
    if obj and obj.Parent then
        TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end
end

function TreeView.Create(parent, rootInstance, onBack)
    -- ═══════════════════════════════
    -- الشريط العلوي
    -- ═══════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, -20, 0, 55)
    TopBar.Position = UDim2.new(0, 10, 0, 10)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    TopBar.BackgroundTransparency = 0.3
    TopBar.ZIndex = 25
    TopBar.Parent = parent
    Corner(TopBar, 12)

    local TStroke = Instance.new("UIStroke")
    TStroke.Color = P.Accent
    TStroke.Thickness = 1
    TStroke.Transparency = 0.5
    TStroke.Parent = TopBar

    -- زر رجوع: أيقونة مستقلة + نص مستقل
    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 86, 0, 35)
    BackBtn.Position = UDim2.new(0, 10, 0.5, -17)
    BackBtn.Text = ""
    BackBtn.AutoButtonColor = false
    BackBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    BackBtn.ZIndex = 26
    BackBtn.Parent = TopBar
    Corner(BackBtn, 8)

    local BackIcon = Instance.new("TextLabel")
    BackIcon.Size = UDim2.new(0, 22, 1, 0)
    BackIcon.Position = UDim2.new(0, 7, 0, 0)
    BackIcon.BackgroundTransparency = 1
    BackIcon.Text = Icons.UI.Back
    BackIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackIcon.TextSize = 18
    BackIcon.Font = Enum.Font.GothamBold
    BackIcon.ZIndex = 27
    BackIcon.Parent = BackBtn

    local BackLabel = Instance.new("TextLabel")
    BackLabel.Size = UDim2.new(1, -32, 1, 0)
    BackLabel.Position = UDim2.new(0, 30, 0, 0)
    BackLabel.BackgroundTransparency = 1
    BackLabel.Text = T("Back")
    BackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackLabel.TextSize = 13
    BackLabel.Font = Enum.Font.GothamBold
    BackLabel.TextXAlignment = Language.Alignment()
    BackLabel.ZIndex = 27
    BackLabel.Parent = BackBtn

    BackBtn.MouseEnter:Connect(function()
        Tween(BackBtn, {BackgroundColor3 = Color3.fromRGB(65, 78, 125)}, 0.12)
    end)
    BackBtn.MouseLeave:Connect(function()
        Tween(BackBtn, {BackgroundColor3 = Color3.fromRGB(50, 60, 100)}, 0.12)
    end)

    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Size = UDim2.new(0, 28, 0, 28)
    TitleIcon.Position = UDim2.new(0, 106, 0.5, -14)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Text = FileScanner.GetIcon(rootInstance)
    TitleIcon.TextSize = 20
    TitleIcon.ZIndex = 26
    TitleIcon.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -300, 0, 20)
    TitleLabel.Position = UDim2.new(0, 140, 0, 5)
    TitleLabel.Text = rootInstance.Name
    TitleLabel.TextColor3 = P.Accent
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Language.Alignment()
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 26
    TitleLabel.Parent = TopBar

    local CountLabel = Instance.new("TextLabel")
    CountLabel.Size = UDim2.new(1, -300, 0, 15)
    CountLabel.Position = UDim2.new(0, 140, 0, 28)
    CountLabel.Text = #FileScanner.GetChildren(rootInstance) .. " " .. T("DirectItems")
    CountLabel.TextColor3 = P.Muted
    CountLabel.TextSize = 12
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.TextXAlignment = Language.Alignment()
    CountLabel.BackgroundTransparency = 1
    CountLabel.ZIndex = 26
    CountLabel.Parent = TopBar

    -- زر الفرز
    local SortBtn = Instance.new("TextButton")
    SortBtn.Size = UDim2.new(0, 92, 0, 35)
    SortBtn.Position = UDim2.new(1, -102, 0.5, -17)
    SortBtn.Text = ""
    SortBtn.AutoButtonColor = false
    SortBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 70)
    SortBtn.ZIndex = 26
    SortBtn.Parent = TopBar
    Corner(SortBtn, 8)

    local SortIcon = Instance.new("TextLabel")
    SortIcon.Size = UDim2.new(0, 22, 1, 0)
    SortIcon.Position = UDim2.new(0, 7, 0, 0)
    SortIcon.BackgroundTransparency = 1
    SortIcon.Text = Icons.UI.Sort
    SortIcon.TextColor3 = P.Accent
    SortIcon.TextSize = 15
    SortIcon.Font = Enum.Font.GothamBold
    SortIcon.ZIndex = 27
    SortIcon.Parent = SortBtn

    local SortLabel = Instance.new("TextLabel")
    SortLabel.Size = UDim2.new(1, -32, 1, 0)
    SortLabel.Position = UDim2.new(0, 28, 0, 0)
    SortLabel.BackgroundTransparency = 1
    SortLabel.Text = T("Name")
    SortLabel.TextColor3 = P.Text
    SortLabel.TextSize = 11
    SortLabel.Font = Enum.Font.GothamBold
    SortLabel.TextXAlignment = Language.Alignment()
    SortLabel.ZIndex = 27
    SortLabel.Parent = SortBtn

    SortBtn.MouseEnter:Connect(function()
        Tween(SortBtn, {BackgroundColor3 = Color3.fromRGB(42, 52, 95)}, 0.12)
    end)
    SortBtn.MouseLeave:Connect(function()
        Tween(SortBtn, {BackgroundColor3 = Color3.fromRGB(30, 38, 70)}, 0.12)
    end)

    -- ═══════════════════════════════
    -- شريط البحث
    -- ═══════════════════════════════
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 40)
    SearchBox.Position = UDim2.new(0, 10, 0, 75)
    SearchBox.PlaceholderText = T("SearchAll")
    SearchBox.Text = ""
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    SearchBox.TextColor3 = P.Text
    SearchBox.PlaceholderColor3 = P.Dim
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 25
    SearchBox.Parent = parent
    Corner(SearchBox, 10)

    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size = UDim2.new(0, 34, 1, 0)
    SearchIcon.Position = UDim2.new(1, -38, 0, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text = Icons.UI.Search
    SearchIcon.TextColor3 = P.Dim
    SearchIcon.TextSize = 16
    SearchIcon.ZIndex = 26
    SearchIcon.Parent = SearchBox

    local SStroke = Instance.new("UIStroke")
    SStroke.Color = P.Accent
    SStroke.Thickness = 1
    SStroke.Transparency = 0.6
    SStroke.Parent = SearchBox

    SearchBox.Focused:Connect(function()
        Tween(SStroke, {Transparency = 0.1, Thickness = 2}, 0.15)
    end)
    SearchBox.FocusLost:Connect(function()
        Tween(SStroke, {Transparency = 0.6, Thickness = 1}, 0.15)
    end)

    -- ═══════════════════════════════
    -- فلاتر شاملة قابلة للتمرير
    -- ═══════════════════════════════
    local FilterBar = Instance.new("ScrollingFrame")
    FilterBar.Size = UDim2.new(1, -20, 0, 36)
    FilterBar.Position = UDim2.new(0, 10, 0, 120)
    FilterBar.BackgroundTransparency = 1
    FilterBar.BorderSizePixel = 0
    FilterBar.ScrollBarThickness = 0
    FilterBar.ScrollingDirection = Enum.ScrollingDirection.X
    FilterBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    FilterBar.ZIndex = 25
    FilterBar.Parent = parent

    local FilterLayout = Instance.new("UIListLayout")
    FilterLayout.FillDirection = Enum.FillDirection.Horizontal
    FilterLayout.Padding = UDim.new(0, 6)
    FilterLayout.Parent = FilterBar

    local activeFilter = "all"
    local filterButtons = {}
    local filters = {
        {id = "all", icon = "◉", text = T("FilterAll"), categories = {}},
        {id = "scripts", icon = "⌘", text = T("FilterScripts"), categories = {"Scripts"}},
        {id = "models", icon = "⬡", text = T("FilterModels"), categories = {"Models", "Characters", "Clothing"}},
        {id = "parts", icon = "◫", text = T("FilterParts"), categories = {"Parts", "Physics", "Constraints"}},
        {id = "images", icon = "▧", text = T("FilterImages"), categories = {"Images"}},
        {id = "audio", icon = "♫", text = T("FilterSounds"), categories = {"Audio"}},
        {id = "gui", icon = "▣", text = T("FilterGui"), categories = {"GUI", "UILayout"}},
        {id = "effects", icon = "✦", text = T("FilterEffects"), categories = {"Effects", "PostEffects"}},
        {id = "values", icon = "#", text = T("FilterValues"), categories = {"Values"}},
        {id = "remotes", icon = "↯", text = T("FilterRemotes"), categories = {"Networking"}},
        {id = "lighting", icon = "☼", text = T("FilterLighting"), categories = {"Lighting"}},
        {id = "animations", icon = "♢", text = T("FilterAnimations"), categories = {"Animation"}},
        {id = "other", icon = "?", text = T("FilterOther"), categories = {"Organization", "Services", "Tools", "Interaction", "Players", "Teams", "Camera", "Unknown"}}
    }

    -- ═══════════════════════════════
    -- منطقة الشجرة
    -- ═══════════════════════════════
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -174)
    Scroll.Position = UDim2.new(0, 10, 0, 164)
    Scroll.BackgroundColor3 = P.BG
    Scroll.BackgroundTransparency = 0.5
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = P.Accent
    Scroll.ZIndex = 25
    Scroll.Parent = parent
    Corner(Scroll, 12)

    local SearchResults = Instance.new("ScrollingFrame")
    SearchResults.Name = "CompleteSearchResults"
    SearchResults.Size = Scroll.Size
    SearchResults.Position = Scroll.Position
    SearchResults.BackgroundColor3 = P.BG
    SearchResults.BackgroundTransparency = 0.1
    SearchResults.BorderSizePixel = 0
    SearchResults.ScrollBarThickness = 5
    SearchResults.ScrollBarImageColor3 = P.Accent
    SearchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SearchResults.CanvasSize = UDim2.new()
    SearchResults.Visible = false
    SearchResults.ZIndex = 35
    SearchResults.Parent = parent
    Corner(SearchResults, 12)
    local SearchLayout = Instance.new("UIListLayout")
    SearchLayout.Padding = UDim.new(0, 6)
    SearchLayout.Parent = SearchResults
    local SearchPadding = Instance.new("UIPadding")
    SearchPadding.PaddingTop, SearchPadding.PaddingBottom = UDim.new(0, 7), UDim.new(0, 10)
    SearchPadding.PaddingLeft, SearchPadding.PaddingRight = UDim.new(0, 7), UDim.new(0, 7)
    SearchPadding.Parent = SearchResults

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingTop = UDim.new(0, 5)
    ScrollPad.PaddingLeft = UDim.new(0, 5)
    ScrollPad.PaddingRight = UDim.new(0, 5)
    ScrollPad.PaddingBottom = UDim.new(0, 5)
    ScrollPad.Parent = Scroll

    -- ═══════════════════════════════
    -- الحالة
    -- ═══════════════════════════════
    local allItems = {}
    local orderCounter = 0
    local sortMode = "name" -- name / nameDesc / type
    local UpdateCanvasSize
    local RenderCompleteSearch

    local function MatchesCategory(instance, filterId)
        if filterId == "all" then return true end
        for _, f in ipairs(filters) do
            if f.id == filterId then
                local category = FileScanner.GetCategory(instance)
                for _, c in ipairs(f.categories) do
                    if category == c then return true end
                end
                return false
            end
        end
        return true
    end

    local function ApplyFilters()
        local query = SearchBox.Text:lower():match("^%s*(.-)%s*$")
        for _, entry in ipairs(allItems) do
            local instance = entry.instance
            local path = ""
            pcall(function() path = instance:GetFullName() end)
            local matchesQuery = query == ""
                or instance.Name:lower():find(query, 1, true) ~= nil
                or instance.ClassName:lower():find(query, 1, true) ~= nil
                or path:lower():find(query, 1, true) ~= nil
            entry.frame.Visible = matchesQuery and MatchesCategory(instance, activeFilter)
        end
        UpdateCanvasSize()
    end

    -- أزرار الفلاتر: أيقونة + نص منفصلان
    for _, filter in ipairs(filters) do
        local button = Instance.new("TextButton")
        button.AutomaticSize = Enum.AutomaticSize.X
        button.Size = UDim2.new(0, 0, 0, 32)
        button.BackgroundColor3 = filter.id == "all" and Color3.fromRGB(0, 150, 210) or Color3.fromRGB(25, 32, 58)
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 26
        button.Parent = FilterBar
        Corner(button, 8)

        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(0, 20, 1, 0)
        ic.Position = UDim2.new(0, 10, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Text = filter.icon
        ic.TextColor3 = filter.id == "all" and Color3.fromRGB(10, 20, 30) or P.Accent
        ic.TextSize = 14
        ic.Font = Enum.Font.GothamBold
        ic.ZIndex = 27
        ic.Parent = button

        local lbl = Instance.new("TextLabel")
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = filter.text
        lbl.TextColor3 = Color3.fromRGB(240, 245, 255)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 27
        lbl.Parent = button
        local lblPad = Instance.new("UIPadding")
        lblPad.PaddingRight = UDim.new(0, 14)
        lblPad.Parent = lbl

        button.AutomaticSize = Enum.AutomaticSize.X
        button.MouseEnter:Connect(function()
            if filter.id ~= activeFilter then
                Tween(button, {BackgroundColor3 = Color3.fromRGB(38, 48, 88)}, 0.12)
            end
        end)
        button.MouseLeave:Connect(function()
            if filter.id ~= activeFilter then
                Tween(button, {BackgroundColor3 = Color3.fromRGB(25, 32, 58)}, 0.12)
            end
        end)
        filterButtons[filter.id] = button
        button.MouseButton1Click:Connect(function()
            activeFilter = filter.id
            for id, filterButton in pairs(filterButtons) do
                Tween(filterButton, {
                    BackgroundColor3 = id == activeFilter and Color3.fromRGB(0, 150, 210) or Color3.fromRGB(25, 32, 58)
                }, 0.14)
                local fIcon = filterButton:FindFirstChildOfClass("TextLabel")
                if fIcon then
                    Tween(fIcon, {
                        TextColor3 = id == activeFilter and Color3.fromRGB(10, 20, 30) or P.Accent
                    }, 0.14)
                end
            end
            if SearchBox.Text ~= "" and RenderCompleteSearch then
                RenderCompleteSearch(SearchBox.Text:lower())
            else
                ApplyFilters()
            end
        end)
    end

    local function SortChildren(children, mode)
        local childCounts = setmetatable({}, {__mode = "k"})
        for _, child in ipairs(children) do childCounts[child] = #child:GetChildren() end
        table.sort(children, function(a, b)
            if mode == "type" then
                local ca = FileScanner.GetCategory(a)
                local cb = FileScanner.GetCategory(b)
                if ca ~= cb then return tostring(ca) < tostring(cb) end
            end
            local aFolder = childCounts[a] > 0
            local bFolder = childCounts[b] > 0
            if aFolder ~= bFolder then return aFolder end
            local an, bn = a.Name:lower(), b.Name:lower()
            if mode == "nameDesc" then return an > bn end
            return an < bn
        end)
        return children
    end

    UpdateCanvasSize = function()
        task.wait()
        if Scroll and Scroll.Parent then
            Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
        end
    end

    -- ═══════════════════════════════
    -- إنشاء عنصر واحد
    -- ═══════════════════════════════
    local function CreateItem(instance, depth, layoutOrder)
        local info = FileScanner.GetBasicInfo(instance)
        local hasChildren = info.Children > 0
        local typeColor = info.Color
        local badgeText = hasChildren and "▰" or tostring(info.Category or info.ClassName):upper():sub(1, 10)
        local badgeColor = info.Color

        local Item = Instance.new("TextButton")
        Item.Name = "Item_" .. layoutOrder
        Item.Size = UDim2.new(1, -10, 0, 55)
        Item.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Item.BackgroundTransparency = 0.2
        Item.Text = ""
        Item.AutoButtonColor = false
        Item.LayoutOrder = layoutOrder
        Item.ZIndex = 26
        Item.Parent = Scroll
        Corner(Item, 10)

        local IStroke = Instance.new("UIStroke")
        IStroke.Color = typeColor
        IStroke.Thickness = 1
        IStroke.Transparency = 0.7
        IStroke.Parent = Item

        local indent = depth * 25

        if depth > 0 then
            local IndentLine = Instance.new("Frame")
            IndentLine.Size = UDim2.new(0, 2, 1, -10)
            IndentLine.Position = UDim2.new(0, indent - 10, 0, 5)
            IndentLine.BackgroundColor3 = typeColor
            IndentLine.BackgroundTransparency = 0.7
            IndentLine.BorderSizePixel = 0
            IndentLine.ZIndex = 27
            IndentLine.Parent = Item
        end

        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 0, 20)
        Arrow.Position = UDim2.new(0, indent + 5, 0.5, -10)
        Arrow.Text = hasChildren and "+" or ""
        Arrow.TextColor3 = typeColor
        Arrow.TextSize = 18
        Arrow.Font = Enum.Font.GothamBold
        Arrow.BackgroundTransparency = 1
        Arrow.ZIndex = 27
        Arrow.Parent = Item

        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 30, 0, 30)
        IconLbl.Position = UDim2.new(0, indent + 28, 0.5, -15)
        IconLbl.Text = info.Icon
        IconLbl.TextSize = 22
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = 27
        IconLbl.Parent = Item

        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -indent - 200, 0, 20)
        NameLbl.Position = UDim2.new(0, indent + 62, 0, 5)
        NameLbl.Text = info.Name
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.TextSize = 14
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Language.Alignment()
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = 27
        NameLbl.Parent = Item

        local TypeLbl = Instance.new("TextLabel")
        TypeLbl.Size = UDim2.new(1, -indent - 200, 0, 15)
        TypeLbl.Position = UDim2.new(0, indent + 62, 0, 27)
        local typeText = info.ClassName
        if hasChildren then
            typeText = typeText .. " | " .. info.Children .. " " .. T("ItemsCount")
        end
        TypeLbl.Text = typeText
        TypeLbl.TextColor3 = P.Muted
        TypeLbl.TextSize = 11
        TypeLbl.Font = Enum.Font.Gotham
        TypeLbl.TextXAlignment = Language.Alignment()
        TypeLbl.BackgroundTransparency = 1
        TypeLbl.ZIndex = 27
        TypeLbl.Parent = Item

        if badgeText ~= "" then
            local Badge = Instance.new("TextLabel")
            Badge.Size = UDim2.new(0, 74, 0, 22)
            Badge.Position = UDim2.new(1, -118, 0.5, -11)
            Badge.Text = badgeText
            Badge.TextColor3 = Color3.fromRGB(11, 13, 26)
            Badge.TextSize = 10
            Badge.Font = Enum.Font.GothamBold
            Badge.BackgroundColor3 = badgeColor
            Badge.ZIndex = 28
            Badge.Parent = Item
            Corner(Badge, 6)
        end

        -- زر فتح (للمجلدات أيضاً)
        local OpenBtn = Instance.new("TextButton")
        OpenBtn.Size = UDim2.new(0, 30, 0, 30)
        OpenBtn.Position = UDim2.new(1, -38, 0.5, -15)
        OpenBtn.Text = ""
        OpenBtn.AutoButtonColor = false
        OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 70)
        OpenBtn.ZIndex = 28
        OpenBtn.Parent = Item
        Corner(OpenBtn, 8)
        local OpenIcon = Instance.new("TextLabel")
        OpenIcon.Size = UDim2.new(1, 0, 1, 0)
        OpenIcon.BackgroundTransparency = 1
        OpenIcon.Text = Icons.UI.Forward
        OpenIcon.TextColor3 = P.Accent
        OpenIcon.TextSize = 14
        OpenIcon.Font = Enum.Font.GothamBold
        OpenIcon.ZIndex = 29
        OpenIcon.Parent = OpenBtn

        Item.MouseEnter:Connect(function()
            Tween(Item, {BackgroundColor3 = Color3.fromRGB(35, 45, 90), BackgroundTransparency = 0}, 0.15)
            Tween(IStroke, {Transparency = 0.2, Thickness = 2}, 0.15)
        end)
        Item.MouseLeave:Connect(function()
            Tween(Item, {BackgroundColor3 = Color3.fromRGB(20, 25, 55), BackgroundTransparency = 0.2}, 0.15)
            Tween(IStroke, {Transparency = 0.7, Thickness = 1}, 0.15)
        end)
        Item.MouseButton1Down:Connect(function()
            Tween(Item, {BackgroundColor3 = Color3.fromRGB(25, 60, 110), BackgroundTransparency = 0}, 0.06)
        end)
        Item.MouseButton1Up:Connect(function()
            Tween(Item, {BackgroundColor3 = Color3.fromRGB(35, 45, 90), BackgroundTransparency = 0}, 0.1)
        end)

        -- قائمة سياق (ضغط مطوّل) — نسخ/استنساخ/حذف/عرض
        if ContextMenu and ContextMenu.AddLongPress and ContextMenu.GeneralMenu then
            ContextMenu.AddLongPress(Item, function()
                ContextMenu.GeneralMenu(instance, {
                    viewInfo = function()
                        local FileViewer = GetModule("FileViewer")
                        FileViewer.Open(parent.Parent, instance)
                    end,
                    copyName = function()
                        local ok = pcall(function()
                            if setclipboard then setclipboard(instance.Name) end
                        end)
                        if not ok and toclipboard then pcall(function() toclipboard(instance.Name) end) end
                    end,
                    copyPath = function()
                        local path = ""
                        pcall(function() path = instance:GetFullName() end)
                        pcall(function()
                            if setclipboard then setclipboard(path) end
                        end)
                    end,
                    copyClassName = function()
                        pcall(function()
                            if setclipboard then setclipboard(instance.ClassName) end
                        end)
                    end,
                    clone = function()
                        pcall(function()
                            local clone = instance:Clone()
                            clone.Parent = instance.Parent
                            clone.Name = instance.Name .. "_Copy"
                        end)
                    end,
                    delete = function()
                        pcall(function() instance:Destroy() end)
                    end
                })
            end, 0.5)
        end

        return Item, Arrow, OpenBtn, hasChildren, info
    end

    -- ═══════════════════════════════
    -- إدراج أبناء بعد عنصر معين
    -- ═══════════════════════════════
    local function InsertChildrenAfter(parentItem, parentInstance, depth)
        local children = FileScanner.GetChildren(parentInstance)
        children = SortChildren(children, sortMode)

        local parentOrder = parentItem.LayoutOrder
        local shift = #children
        for _, entry in ipairs(allItems) do
            if entry.frame.LayoutOrder > parentOrder then
                entry.frame.LayoutOrder = entry.frame.LayoutOrder + shift
            end
        end

        local childEntries = {}
        for i, child in ipairs(children) do
            local childOrder = parentOrder + i
            local Item, Arrow, OpenBtn, hasChildren, info = CreateItem(child, depth, childOrder)

            local entry = {
                frame = Item,
                instance = child,
                depth = depth,
                parentInstance = parentInstance,
                expanded = false,
                arrow = Arrow,
                hasChildren = hasChildren
            }
            table.insert(allItems, entry)
            table.insert(childEntries, entry)

            OpenBtn.MouseButton1Click:Connect(function()
                local FileViewer = GetModule("FileViewer")
                FileViewer.Open(parent.Parent, child)
            end)

            if hasChildren then
                Item.MouseButton1Click:Connect(function()
                    if entry.expanded then
                        entry.expanded = false
                        Arrow.Text = "+"
                        Arrow.TextColor3 = FileScanner.GetTypeData(child).color
                        RemoveDescendantItems(child)
                        UpdateCanvasSize()
                    else
                        entry.expanded = true
                        Arrow.Text = "-"
                        Arrow.TextColor3 = P.Success
                        InsertChildrenAfter(Item, child, depth + 1)
                        UpdateCanvasSize()
                    end
                end)
            else
                Item.MouseButton1Click:Connect(function()
                    local FileViewer = GetModule("FileViewer")
                    FileViewer.Open(parent.Parent, child)
                end)
            end
        end

        UpdateCanvasSize()
        return childEntries
    end

    -- ═══════════════════════════════
    -- حذف كل أبناء عنصر
    -- ═══════════════════════════════
    local function RemoveDescendantItems(parentInstance)
        local i = 1
        while i <= #allItems do
            local entry = allItems[i]
            local isDescendant = false

            pcall(function()
                local p = entry.instance.Parent
                while p do
                    if p == parentInstance then
                        isDescendant = true
                        break
                    end
                    p = p.Parent
                end
            end)

            if isDescendant then
                entry.frame:Destroy()
                entry.expanded = false
                table.remove(allItems, i)
            else
                i = i + 1
            end
        end
    end

    -- ═══════════════════════════════
    -- إعادة بناء الشجرة بالكامل (للفرز)
    -- ═══════════════════════════════
    local function RebuildTree()
        for _, entry in ipairs(allItems) do
            if entry.frame and entry.frame.Parent then
                entry.frame:Destroy()
            end
        end
        table.clear(allItems)
        orderCounter = 0
        local rootChildren = FileScanner.GetChildren(rootInstance)
        rootChildren = SortChildren(rootChildren, sortMode)
        for _, child in ipairs(rootChildren) do
            orderCounter = orderCounter + 1
            local Item, Arrow, OpenBtn, hasChildren, info = CreateItem(child, 0, orderCounter)
            local entry = {
                frame = Item,
                instance = child,
                depth = 0,
                parentInstance = rootInstance,
                expanded = false,
                arrow = Arrow,
                hasChildren = hasChildren
            }
            table.insert(allItems, entry)
            OpenBtn.MouseButton1Click:Connect(function()
                local FileViewer = GetModule("FileViewer")
                FileViewer.Open(parent.Parent, child)
            end)
            if hasChildren then
                Item.MouseButton1Click:Connect(function()
                    if entry.expanded then
                        entry.expanded = false
                        Arrow.Text = "+"
                        Arrow.TextColor3 = FileScanner.GetTypeData(child).color
                        RemoveDescendantItems(child)
                        UpdateCanvasSize()
                    else
                        entry.expanded = true
                        Arrow.Text = "-"
                        Arrow.TextColor3 = P.Success
                        InsertChildrenAfter(Item, child, 1)
                        UpdateCanvasSize()
                    end
                end)
            else
                Item.MouseButton1Click:Connect(function()
                    local FileViewer = GetModule("FileViewer")
                    FileViewer.Open(parent.Parent, child)
                end)
            end
        end
        ApplyFilters()
    end

    -- زر الفرز: الاسم → الاسم تنازلي → النوع
    SortBtn.MouseButton1Click:Connect(function()
        if sortMode == "name" then
            sortMode = "nameDesc"
            SortLabel.Text = T("Name") .. " ↓"
        elseif sortMode == "nameDesc" then
            sortMode = "type"
            SortLabel.Text = T("Type")
        else
            sortMode = "name"
            SortLabel.Text = T("Name")
        end
        RebuildTree()
    end)

    -- ═══════════════════════════
    -- البحث
    -- ═══════════════════════════
    local searchGeneration = 0
    local activeSearchToken
    local function ClearSearchResults()
        for _, child in ipairs(SearchResults:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end
    RenderCompleteSearch = function(query)
        searchGeneration = searchGeneration + 1
        local generation = searchGeneration
        if activeSearchToken then activeSearchToken.cancelled = true end
        if query == "" then
            SearchResults.Visible = false
            ApplyFilters()
            return
        end
        SearchResults.Visible = true
        ClearSearchResults()
        task.spawn(function()
            local token = {cancelled = false}
            activeSearchToken = token
            local results = FileScanner.Search(rootInstance, query, {
                searchIn = "both", maxResults = 150, batchSize = 120,
                scanLimit = 25000, token = token
            })
            if generation ~= searchGeneration or not SearchResults.Parent then token.cancelled = true return end
            for _, instance in ipairs(results) do
                if MatchesCategory(instance, activeFilter) then
                    local info = FileScanner.GetBasicInfo(instance)
                    local row = Instance.new("TextButton")
                    row.Size = UDim2.new(1, -4, 0, 52)
                    row.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
                    row.Text = ""
                    row.AutoButtonColor = false
                    row.ZIndex = 36
                    row.Parent = SearchResults
                    Corner(row, 9)

                    local ic = Instance.new("TextLabel")
                    ic.Size = UDim2.new(0, 30, 0, 30)
                    ic.Position = UDim2.new(0, 10, 0.5, -15)
                    ic.BackgroundTransparency = 1
                    ic.Text = info.Icon
                    ic.TextSize = 20
                    ic.ZIndex = 37
                    ic.Parent = row

                    local name = Instance.new("TextLabel")
                    name.Size = UDim2.new(1, -56, 0, 22)
                    name.Position = UDim2.new(0, 48, 0, 5)
                    name.BackgroundTransparency = 1
                    name.Text = info.Name
                    name.TextColor3 = Color3.fromRGB(242, 247, 255)
                    name.TextSize = 12
                    name.Font = Enum.Font.GothamBold
                    name.TextXAlignment = Language.Alignment()
                    name.TextTruncate = Enum.TextTruncate.AtEnd
                    name.ZIndex = 37
                    name.Parent = row

                    local sub = Instance.new("TextLabel")
                    sub.Size = UDim2.new(1, -56, 0, 15)
                    sub.Position = UDim2.new(0, 48, 0, 30)
                    sub.BackgroundTransparency = 1
                    sub.Text = info.ClassName .. "  •  " .. info.FullName
                    sub.TextColor3 = P.Muted
                    sub.TextSize = 10
                    sub.Font = Enum.Font.Gotham
                    sub.TextXAlignment = Language.Alignment()
                    sub.TextTruncate = Enum.TextTruncate.AtEnd
                    sub.ZIndex = 37
                    sub.Parent = row

                    row.MouseEnter:Connect(function()
                        Tween(row, {BackgroundColor3 = Color3.fromRGB(35, 45, 90)}, 0.12)
                    end)
                    row.MouseLeave:Connect(function()
                        Tween(row, {BackgroundColor3 = Color3.fromRGB(20, 25, 55)}, 0.12)
                    end)
                    row.MouseButton1Click:Connect(function()
                        local FileViewer = GetModule("FileViewer")
                        FileViewer.Open(parent.Parent, instance)
                    end)
                end
            end
        end)
    end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RenderCompleteSearch(SearchBox.Text:lower():match("^%s*(.-)%s*$"))
    end)

    -- ═══════════════════════════════
    -- زر الرجوع
    -- ═══════════════════════════════
    BackBtn.MouseButton1Click:Connect(function()
        parent:ClearAllChildren()
        if onBack then onBack() end
    end)

    -- العرض الأول
    RebuildTree()
    if Language.Apply then Language.Apply(parent) end

    print("TreeView loaded for: " .. rootInstance.Name)
end

return TreeView
