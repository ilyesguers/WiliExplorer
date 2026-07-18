local TreeView = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

local TweenService = game:GetService("TweenService")

function TreeView.Create(parent, rootInstance, onBack)
    -- ═══════════════════════════════
    -- الشريط العلوي (Back + Search)
    -- ═══════════════════════════════
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

    -- زر الرجوع
    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 80, 0, 35)
    BackBtn.Position = UDim2.new(0, 10, 0.5, -17)
    BackBtn.Text = "← " .. Language.Get("Back")
    BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackBtn.TextSize = 14
    BackBtn.Font = Enum.Font.GothamBold
    BackBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    BackBtn.ZIndex = 26
    BackBtn.Parent = TopBar
    Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 8)

    -- عنوان الخدمة
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

    -- عداد العناصر
    local CountLabel = Instance.new("TextLabel")
    CountLabel.Size = UDim2.new(0, 200, 0, 15)
    CountLabel.Position = UDim2.new(0, 100, 0, 28)
    CountLabel.Text = FileScanner.CountDescendants(rootInstance) .. " " .. Language.Get("Items")
    CountLabel.TextColor3 = Color3.fromRGB(150, 170, 200)
    CountLabel.TextSize = 12
    CountLabel.Font = Enum.Font.Gotham
    CountLabel.TextXAlignment = Enum.TextXAlignment.Left
    CountLabel.BackgroundTransparency = 1
    CountLabel.ZIndex = 26
    CountLabel.Parent = TopBar

    -- ═══════════════════════════════
    -- شريط البحث
    -- ═══════════════════════════════
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 40)
    SearchBox.Position = UDim2.new(0, 10, 0, 75)
    SearchBox.PlaceholderText = "🔎 " .. Language.Get("Search")
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

    -- ═══════════════════════════════
    -- منطقة الشجرة (ScrollingFrame)
    -- ═══════════════════════════════
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -135)
    Scroll.Position = UDim2.new(0, 10, 0, 125)
    Scroll.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    Scroll.BackgroundTransparency = 0.5
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Scroll.ZIndex = 25
    Scroll.Parent = parent
    Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 12)

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingLeft = UDim.new(0, 5)
    Padding.PaddingRight = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)
    Padding.Parent = Scroll

    -- ═══════════════════════════════
    -- تتبع العناصر المفتوحة
    -- ═══════════════════════════════
    local expandedItems = {}
    local allItemFrames = {}

    -- ═══════════════════════════════
    -- إنشاء عنصر في الشجرة
    -- ═══════════════════════════════
    local function CreateTreeItem(instance, depth, order)
        local info = FileScanner.GetInfo(instance)
        local hasChildren = info.Children > 0
        
        local Item = Instance.new("TextButton")
        Item.Size = UDim2.new(1, -10, 0, 40)
        Item.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Item.BackgroundTransparency = 0.3
        Item.Text = ""
        Item.AutoButtonColor = false
        Item.LayoutOrder = order
        Item.ZIndex = 26
        Item.Parent = Scroll
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 8)

        local IStroke = Instance.new("UIStroke")
        IStroke.Color = Color3.fromRGB(0, 212, 255)
        IStroke.Thickness = 1
        IStroke.Transparency = 0.8
        IStroke.Parent = Item

        -- المسافة (indent) حسب العمق
        local indent = depth * 20
        
        -- سهم الفتح/الإغلاق
        local Arrow = Instance.new("TextLabel")
        Arrow.Size = UDim2.new(0, 20, 1, 0)
        Arrow.Position = UDim2.new(0, indent + 5, 0, 0)
        Arrow.Text = hasChildren and "▶" or " "
        Arrow.TextColor3 = Color3.fromRGB(0, 212, 255)
        Arrow.TextSize = 12
        Arrow.Font = Enum.Font.GothamBold
        Arrow.BackgroundTransparency = 1
        Arrow.ZIndex = 27
        Arrow.Parent = Item

        -- الأيقونة
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 30, 1, 0)
        Icon.Position = UDim2.new(0, indent + 25, 0, 0)
        Icon.Text = info.Icon
        Icon.TextSize = 20
        Icon.Font = Enum.Font.Gotham
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 27
        Icon.Parent = Item

        -- الاسم
        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -indent - 130, 0, 20)
        Name.Position = UDim2.new(0, indent + 55, 0, 2)
        Name.Text = info.Name
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.TextSize = 14
        Name.Font = Enum.Font.GothamBold
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Name.TextTruncate = Enum.TextTruncate.AtEnd
        Name.BackgroundTransparency = 1
        Name.ZIndex = 27
        Name.Parent = Item

        -- النوع
        local Type = Instance.new("TextLabel")
        Type.Size = UDim2.new(1, -indent - 130, 0, 15)
        Type.Position = UDim2.new(0, indent + 55, 0, 22)
        Type.Text = info.ClassName .. (info.Children > 0 and " • " .. info.Children .. " " .. Language.Get("Items") or "")
        Type.TextColor3 = Color3.fromRGB(150, 170, 200)
        Type.TextSize = 11
        Type.Font = Enum.Font.Gotham
        Type.TextXAlignment = Enum.TextXAlignment.Left
        Type.TextTruncate = Enum.TextTruncate.AtEnd
        Type.BackgroundTransparency = 1
        Type.ZIndex = 27
        Type.Parent = Item

        -- شارة السكريبت
        if info.IsScript then
            local ScriptBadge = Instance.new("TextLabel")
            ScriptBadge.Size = UDim2.new(0, 50, 0, 20)
            ScriptBadge.Position = UDim2.new(1, -60, 0.5, -10)
            ScriptBadge.Text = "CODE"
            ScriptBadge.TextColor3 = Color3.fromRGB(11, 13, 26)
            ScriptBadge.TextSize = 10
            ScriptBadge.Font = Enum.Font.GothamBold
            ScriptBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            ScriptBadge.ZIndex = 27
            ScriptBadge.Parent = Item
            Instance.new("UICorner", ScriptBadge).CornerRadius = UDim.new(0, 5)
        end

        -- تأثيرات
        Item.MouseEnter:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 45, 90)
            }):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play()
        end)
        Item.MouseLeave:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 55)
            }):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
        end)

        return Item, Arrow, hasChildren
    end

    -- ═══════════════════════════════
    -- إعادة رسم الشجرة
    -- ═══════════════════════════════
    local currentOrder = 0
    
    local function RenderTree(instance, depth)
        currentOrder = currentOrder + 1
        local myOrder = currentOrder
        local Item, Arrow, hasChildren = CreateTreeItem(instance, depth, myOrder)
        
        table.insert(allItemFrames, {frame = Item, instance = instance, depth = depth})

        if hasChildren then
            Item.MouseButton1Click:Connect(function()
                local isExpanded = expandedItems[instance] or false
                expandedItems[instance] = not isExpanded

                if not isExpanded then
                    -- فتح
                    Arrow.Text = "▼"
                    local children = FileScanner.GetChildren(instance)
                    -- ترتيب: مجلدات أولاً، ثم أبجدياً
                    table.sort(children, function(a, b)
                        local aHas = #a:GetChildren() > 0
                        local bHas = #b:GetChildren() > 0
                        if aHas ~= bHas then return aHas end
                        return a.Name < b.Name
                    end)
                    
                    -- إدراج العناصر بعد الحالي
                    for _, child in ipairs(children) do
                        RenderTree(child, depth + 1)
                    end
                    
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                else
                    -- إغلاق - نحذف كل الأبناء بعده
                    Arrow.Text = "▶"
                    local i = 1
                    while i <= #allItemFrames do
                        local entry = allItemFrames[i]
                        if entry.depth > depth then
                            local check = entry.instance
                            local isDescendant = false
                            local parent = check.Parent
                            while parent do
                                if parent == instance then
                                    isDescendant = true
                                    break
                                end
                                parent = parent.Parent
                            end
                            
                            if isDescendant then
                                entry.frame:Destroy()
                                expandedItems[entry.instance] = nil
                                table.remove(allItemFrames, i)
                            else
                                i = i + 1
                            end
                        else
                            i = i + 1
                        end
                    end
                    
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                end
            end)
        else
            -- عنصر بدون أبناء - عند الضغط يعرض تفاصيله
            Item.MouseButton1Click:Connect(function()
                print("Selected leaf: " .. instance:GetFullName())
                -- سنضيف عرض التفاصيل لاحقاً
            end)
        end
    end

    -- عرض الأبناء المباشرين لـ Root
    local rootChildren = FileScanner.GetChildren(rootInstance)
    table.sort(rootChildren, function(a, b)
        local aHas = #a:GetChildren() > 0
        local bHas = #b:GetChildren() > 0
        if aHas ~= bHas then return aHas end
        return a.Name < b.Name
    end)
    
    for _, child in ipairs(rootChildren) do
        RenderTree(child, 0)
    end

    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

    -- ═══════════════════════════════
    -- البحث
    -- ═══════════════════════════════
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, entry in ipairs(allItemFrames) do
            if query == "" then
                entry.frame.Visible = true
            else
                local name = entry.instance.Name:lower()
                local className = entry.instance.ClassName:lower()
                entry.frame.Visible = name:find(query) ~= nil or className:find(query) ~= nil
            end
        end
    end)

    -- ═══════════════════════════════
    -- زر الرجوع
    -- ═══════════════════════════════
    BackBtn.MouseButton1Click:Connect(function()
        parent:ClearAllChildren()
        if onBack then onBack() end
    end)

    print("TreeView loaded for: " .. rootInstance.Name)
end

return TreeView
