local TreeView = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

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
    CountLabel.Text = FileScanner.CountDescendants(rootInstance) .. " " .. Language.Get("Items")
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

    -- ===================================
    -- منطقة الشجرة
    -- ===================================
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

    local function GetTypeColor(className)
        if className:find("Script") or className == "ModuleScript" then
            return Color3.fromRGB(0, 255, 136)
        elseif className:find("Part") or className == "Model" or className == "UnionOperation" then
            return Color3.fromRGB(0, 212, 255)
        elseif className:find("Sound") then
            return Color3.fromRGB(255, 200, 50)
        elseif className:find("Decal") or className:find("Texture") or className:find("Image") then
            return Color3.fromRGB(255, 100, 150)
        elseif className:find("Gui") or className:find("Frame") or className:find("Text") then
            return Color3.fromRGB(200, 150, 255)
        elseif className:find("Light") then
            return Color3.fromRGB(255, 255, 100)
        elseif className:find("Value") then
            return Color3.fromRGB(150, 200, 255)
        elseif className == "Folder" then
            return Color3.fromRGB(255, 200, 50)
        elseif className:find("Remote") or className:find("Bindable") then
            return Color3.fromRGB(255, 150, 50)
        else
            return Color3.fromRGB(180, 190, 210)
        end
    end

    local function GetBadge(instance, hasChildren)
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            local ok, src = pcall(function() return instance.Source end)
            if ok and src and #src > 0 then
                return "CODE", Color3.fromRGB(0, 255, 136)
            else
                return "LOCKED", Color3.fromRGB(255, 80, 80)
            end
        elseif instance:IsA("Sound") then
            return "SOUND", Color3.fromRGB(255, 200, 50)
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            return "IMAGE", Color3.fromRGB(255, 100, 150)
        elseif instance:IsA("BasePart") then
            return "PART", Color3.fromRGB(0, 180, 255)
        elseif instance:IsA("GuiObject") then
            return "GUI", Color3.fromRGB(200, 150, 255)
        elseif hasChildren then
            return "FOLDER", Color3.fromRGB(255, 200, 50)
        elseif instance:IsA("ValueBase") then
            return "VALUE", Color3.fromRGB(150, 200, 255)
        end
        return "", Color3.fromRGB(100, 100, 100)
    end

    local function SortChildren(children)
        table.sort(children, function(a, b)
            local aFolder = #a:GetChildren() > 0
            local bFolder = #b:GetChildren() > 0
            if aFolder ~= bFolder then return aFolder end
            return a.Name:lower() < b.Name:lower()
        end)
        return children
    end

    local function UpdateCanvasSize()
        wait()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end

    -- ===================================
    -- إنشاء عنصر واحد
    -- ===================================
    local function CreateItem(instance, depth, layoutOrder)
        local info = FileScanner.GetInfo(instance)
        local hasChildren = info.Children > 0
        local typeColor = GetTypeColor(info.ClassName)
        local badgeText, badgeColor = GetBadge(instance, hasChildren)

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
                        Arrow.TextColor3 = GetTypeColor(child.ClassName)
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
                    local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
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
                    Arrow.TextColor3 = GetTypeColor(child.ClassName)
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
                local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                FileViewer.Open(parent.Parent, child)
            end)
        end
    end

    UpdateCanvasSize()

    -- ===================================
    -- البحث
    -- ===================================
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, entry in ipairs(allItems) do
            if query == "" then
                entry.frame.Visible = true
            else
                local name = entry.instance.Name:lower()
                local className = entry.instance.ClassName:lower()
                entry.frame.Visible = (name:find(query) ~= nil) or (className:find(query) ~= nil)
            end
        end
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
