local TreeView = {}

local function GetModule(name)
    return assert(_G.WiliModules and _G.WiliModules[name], "TreeView dependency missing: " .. name)
end
local FileScanner = GetModule("FileScanner")
local Language = GetModule("Language")

local TweenService = game:GetService("TweenService")

function TreeView.Create(parent, rootInstance, onBack)
    -- ===================================
    -- الشريط العلوي
    -- ===================================
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, -20, 0, 55)
    TopBar.Position = UDim2.new(0, 10, 0, 10)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    TopBar.BackgroundTransparency = 0.3
    TopBar.ZIndex = 25
    TopBar.Parent = parent
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

    local TStroke = Instance.new("UIStroke")
    TStroke.Color = Color3.fromRGB(0, 212, 255)
    TStroke.Thickness = 1
    TStroke.Transparency = 0.5
    TStroke.Parent = TopBar

    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 80, 0, 35)
    BackBtn.Position = UDim2.new(0, 10, 0.5, -17)
    BackBtn.Text = "< " .. Language.Get("Back")
    BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackBtn.TextSize = 14
    BackBtn.Font = Enum.Font.GothamBold
    BackBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    BackBtn.ZIndex = 26
    BackBtn.Parent = TopBar
    Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 8)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 0, 20)
    TitleLabel.Position = UDim2.new(0, 100, 0, 5)
    TitleLabel.Text = FileScanner.GetIcon(rootInstance) .. " " .. rootInstance.Name
    TitleLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 26
    TitleLabel.Parent = TopBar

    local CountLabel = Instance.new("TextLabel")
    CountLabel.Size = UDim2.new(0, 200, 0, 15)
    CountLabel.Position = UDim2.new(0, 100, 0, 28)
    CountLabel.Text = #rootInstance:GetChildren() .. " " .. Language.Get("DirectItems")
    CountLabel.TextColor3 = Color3.fromRGB(150, 170, 200)
    CountLabel.TextSize = 12
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.TextXAlignment = Enum.TextXAlignment.Left
    CountLabel.BackgroundTransparency = 1
    CountLabel.ZIndex = 26
    CountLabel.Parent = TopBar

    -- ===================================
    -- شريط البحث
    -- ===================================
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 40)
    SearchBox.Position = UDim2.new(0, 10, 0, 75)
    SearchBox.PlaceholderText = "Search files..."
    SearchBox.Text = ""
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 160)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 25
    SearchBox.Parent = parent
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local SStroke = Instance.new("UIStroke")
    SStroke.Color = Color3.fromRGB(0, 212, 255)
    SStroke.Thickness = 1
    SStroke.Transparency = 0.6
    SStroke.Parent = SearchBox

    -- فلاتر سريعة قابلة للتمرير ومناسبة للمس
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
        {id = "all", text = "● All"}, {id = "script", text = "⌘ Scripts"},
        {id = "model", text = "◆ Models"}, {id = "image", text = "▧ Images"},
        {id = "sound", text = "♫ Sounds"}, {id = "value", text = "# Values"}
    }

    -- ===================================
    -- منطقة الشجرة
    -- ===================================
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -174)
    Scroll.Position = UDim2.new(0, 10, 0, 164)
    Scroll.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    Scroll.BackgroundTransparency = 0.5
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Scroll.ZIndex = 25
    Scroll.Parent = parent
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 12)

    local SearchResults = Instance.new("ScrollingFrame")
    SearchResults.Name = "CompleteSearchResults"
    SearchResults.Size = Scroll.Size
    SearchResults.Position = Scroll.Position
    SearchResults.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    SearchResults.BackgroundTransparency = 0.1
    SearchResults.BorderSizePixel = 0
    SearchResults.ScrollBarThickness = 5
    SearchResults.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    SearchResults.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SearchResults.CanvasSize = UDim2.new()
    SearchResults.Visible = false
    SearchResults.ZIndex = 35
    SearchResults.Parent = parent
    Instance.new("UICorner", SearchResults).CornerRadius = UDim.new(0, 12)
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

    -- ===================================
    -- المتغيرات
    -- ===================================
    local allItems = {}
    local orderCounter = 0
    local UpdateCanvasSize
    local RenderCompleteSearch

    local function MatchesCategory(instance, category)
        if category == "all" then return true end
        if category == "script" then return instance:IsA("BaseScript") or instance:IsA("ModuleScript") end
        if category == "model" then return instance:IsA("Model") or instance:IsA("BasePart") end
        if category == "image" then return instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") end
        if category == "sound" then return instance:IsA("Sound") end
        if category == "value" then return instance:IsA("ValueBase") end
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

    for _, filter in ipairs(filters) do
        local button = Instance.new("TextButton")
        button.AutomaticSize = Enum.AutomaticSize.X
        button.Size = UDim2.new(0, 0, 0, 32)
        button.BackgroundColor3 = filter.id == "all" and Color3.fromRGB(0, 150, 210) or Color3.fromRGB(25, 32, 58)
        button.Text = filter.text
        button.TextColor3 = Color3.fromRGB(240, 245, 255)
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.ZIndex = 26
        button.Parent = FilterBar
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
        padding.Parent = button
        filterButtons[filter.id] = button
        button.MouseButton1Click:Connect(function()
            activeFilter = filter.id
            for id, filterButton in pairs(filterButtons) do
                TweenService:Create(filterButton, TweenInfo.new(0.14), {
                    BackgroundColor3 = id == activeFilter and Color3.fromRGB(0, 150, 210) or Color3.fromRGB(25, 32, 58)
                }):Play()
            end
            if SearchBox.Text ~= "" and RenderCompleteSearch then
                RenderCompleteSearch(SearchBox.Text:lower())
            else
                ApplyFilters()
            end
        end)
    end

    local function SortChildren(children)
        local childCounts = setmetatable({}, {__mode = "k"})
        for _, child in ipairs(children) do childCounts[child] = #child:GetChildren() end
        table.sort(children, function(a, b)
            local aFolder = childCounts[a] > 0
            local bFolder = childCounts[b] > 0
            if aFolder ~= bFolder then return aFolder end
            return a.Name:lower() < b.Name:lower()
        end)
        return children
    end

    UpdateCanvasSize = function()
        task.wait()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end

    -- ===================================
    -- إنشاء عنصر واحد
    -- ===================================
    local function CreateItem(instance, depth, layoutOrder)
        local info = FileScanner.GetBasicInfo(instance)
        local hasChildren = info.Children > 0
        local typeColor = info.Color
        local badgeText = hasChildren and "FOLDER" or tostring(info.Category or info.ClassName):upper():sub(1, 10)
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
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 10)

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
        NameLbl.Size = UDim2.new(1, -indent - 180, 0, 20)
        NameLbl.Position = UDim2.new(0, indent + 62, 0, 5)
        NameLbl.Text = info.Name
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.TextSize = 14
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = 27
        NameLbl.Parent = Item

        local TypeLbl = Instance.new("TextLabel")
        TypeLbl.Size = UDim2.new(1, -indent - 180, 0, 15)
        TypeLbl.Position = UDim2.new(0, indent + 62, 0, 27)
        local typeText = info.ClassName
        if hasChildren then
            typeText = typeText .. " | " .. info.Children .. " children"
        end
        TypeLbl.Text = typeText
        TypeLbl.TextColor3 = Color3.fromRGB(150, 170, 200)
        TypeLbl.TextSize = 11
        TypeLbl.Font = Enum.Font.Gotham
        TypeLbl.TextXAlignment = Enum.TextXAlignment.Left
        TypeLbl.BackgroundTransparency = 1
        TypeLbl.ZIndex = 27
        TypeLbl.Parent = Item

        if badgeText ~= "" then
            local Badge = Instance.new("TextLabel")
            Badge.Size = UDim2.new(0, 60, 0, 22)
            Badge.Position = UDim2.new(1, -70, 0.5, -11)
            Badge.Text = badgeText
            Badge.TextColor3 = Color3.fromRGB(11, 13, 26)
            Badge.TextSize = 10
            Badge.Font = Enum.Font.GothamBold
            Badge.BackgroundColor3 = badgeColor
            Badge.ZIndex = 28
            Badge.Parent = Item
            Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
        end

        Item.MouseEnter:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 45, 90), BackgroundTransparency = 0}):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {Transparency = 0.2, Thickness = 2}):Play()
        end)
        Item.MouseLeave:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 25, 55), BackgroundTransparency = 0.2}):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {Transparency = 0.7, Thickness = 1}):Play()
        end)

        return Item, Arrow, hasChildren, info
    end

    -- ===================================
    -- إدراج أبناء بعد عنصر معين (الإصلاح الرئيسي)
    -- ===================================
    local function InsertChildrenAfter(parentItem, parentInstance, depth)
        local children = FileScanner.GetChildren(parentInstance)
        children = SortChildren(children)

        -- إيجاد ترتيب العنصر الأب
        local parentOrder = parentItem.LayoutOrder

        -- إزاحة كل العناصر التي بعده
        local shift = #children
        for _, entry in ipairs(allItems) do
            if entry.frame.LayoutOrder > parentOrder then
                entry.frame.LayoutOrder = entry.frame.LayoutOrder + shift
            end
        end

        -- إدراج الأبناء مباشرة بعد الأب
        local childEntries = {}
        for i, child in ipairs(children) do
            local childOrder = parentOrder + i
            local Item, Arrow, hasChildren, info = CreateItem(child, depth, childOrder)

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

            if hasChildren then
                Item.MouseButton1Click:Connect(function()
                    if entry.expanded then
                        -- إغلاق
                        entry.expanded = false
                        Arrow.Text = "+"
                        Arrow.TextColor3 = FileScanner.GetTypeData(child).color
                        RemoveDescendantItems(child)
                        UpdateCanvasSize()
                    else
                        -- فتح
                        entry.expanded = true
                        Arrow.Text = "-"
                        Arrow.TextColor3 = Color3.fromRGB(0, 255, 136)
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

    -- ===================================
    -- حذف كل أبناء عنصر
    -- ===================================
    function RemoveDescendantItems(parentInstance)
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

    -- ===================================
    -- عرض المستوى الأول
    -- ===================================
    local rootChildren = FileScanner.GetChildren(rootInstance)
    rootChildren = SortChildren(rootChildren)

    for i, child in ipairs(rootChildren) do
        orderCounter = orderCounter + 1
        local Item, Arrow, hasChildren, info = CreateItem(child, 0, orderCounter)

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
                    Arrow.TextColor3 = Color3.fromRGB(0, 255, 136)
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

    UpdateCanvasSize()

    -- ===================================
    -- البحث
    -- ===================================
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
        if query == "" then SearchResults.Visible = false ApplyFilters() return end
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
                    row.Text = info.Icon .. "  " .. info.Name .. "\n    " .. info.ClassName .. "  •  " .. info.FullName
                    row.TextColor3 = Color3.fromRGB(242, 247, 255)
                    row.TextSize = 11
                    row.Font = Enum.Font.Gotham
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.TextTruncate = Enum.TextTruncate.AtEnd
                    row.AutoButtonColor = false
                    row.ZIndex = 36
                    row.Parent = SearchResults
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)
                    local padding = Instance.new("UIPadding")
                    padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
                    padding.Parent = row
                    row.MouseButton1Click:Connect(function()
                        FileViewer.Open(parent.Parent, instance)
                    end)
                end
            end
        end)
    end
    SearchBox.PlaceholderText = Language.Get("SearchAll")
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RenderCompleteSearch(SearchBox.Text:lower():match("^%s*(.-)%s*$"))
    end)

    -- ===================================
    -- زر الرجوع
    -- ===================================
    BackBtn.MouseButton1Click:Connect(function()
        parent:ClearAllChildren()
        if onBack then onBack() end
    end)

    print("TreeView loaded for: " .. rootInstance.Name)
end

return TreeView
