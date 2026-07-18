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
    -- تتبع المتغيرات
    -- ===================================
    local allItems = {}
    local expandedFolders = {}
    local globalOrder = 0

    -- ===================================
    -- دالة تحديد لون حسب النوع
    -- ===================================
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
        elseif className:find("Light") or className == "Lighting" then
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

    -- ===================================
    -- دالة فحص إمكانية القراءة
    -- ===================================
    local function GetReadStatus(instance)
        local status = {
            canRead = true,
            canReadSource = false,
            isProtected = false,
            readableProps = 0
        }

        -- فحص السكريبتات
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            local ok, src = pcall(function()
                return instance.Source
            end)
            if ok and src and #src > 0 then
                status.canReadSource = true
            else
                status.isProtected = true
            end
        end

        -- عد الخصائص القابلة للقراءة
        local testProps = {"Name", "ClassName", "Position", "Size", "Color", "Transparency", "Value", "Text", "SoundId", "Image"}
        for _, prop in ipairs(testProps) do
            pcall(function()
                local val = instance[prop]
                if val ~= nil then
                    status.readableProps = status.readableProps + 1
                end
            end)
        end

        return status
    end

    -- ===================================
    -- إنشاء عنصر في الشجرة
    -- ===================================
    local function CreateTreeItem(instance, depth, order)
        local info = FileScanner.GetInfo(instance)
        local hasChildren = info.Children > 0
        local typeColor = GetTypeColor(info.ClassName)
        local readStatus = GetReadStatus(instance)

        local Item = Instance.new("TextButton")
        Item.Name = "TreeItem_" .. order
        Item.Size = UDim2.new(1, -10, 0, 55)
        Item.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Item.BackgroundTransparency = 0.2
        Item.Text = ""
        Item.AutoButtonColor = false
        Item.LayoutOrder = order
        Item.ZIndex = 26
        Item.Parent = Scroll
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 10)

        local IStroke = Instance.new("UIStroke")
        IStroke.Color = typeColor
        IStroke.Thickness = 1
        IStroke.Transparency = 0.7
        IStroke.Parent = Item

        -- خط المسافة البادئة
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

        -- سهم الفتح/الإغلاق
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

        -- الأيقونة
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 30, 0, 30)
        Icon.Position = UDim2.new(0, indent + 28, 0.5, -15)
        Icon.Text = info.Icon
        Icon.TextSize = 22
        Icon.Font = Enum.Font.Gotham
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 27
        Icon.Parent = Item

        -- الاسم
        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -indent - 180, 0, 20)
        Name.Position = UDim2.new(0, indent + 62, 0, 5)
        Name.Text = info.Name
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.TextSize = 14
        Name.Font = Enum.Font.GothamBold
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Name.TextTruncate = Enum.TextTruncate.AtEnd
        Name.BackgroundTransparency = 1
        Name.ZIndex = 27
        Name.Parent = Item

        -- النوع + عدد الأبناء
        local TypeLabel = Instance.new("TextLabel")
        TypeLabel.Size = UDim2.new(1, -indent - 180, 0, 15)
        TypeLabel.Position = UDim2.new(0, indent + 62, 0, 27)
        local typeText = info.ClassName
        if hasChildren then
            typeText = typeText .. " | " .. info.Children .. " children | " .. info.Descendants .. " total"
        end
        TypeLabel.Text = typeText
        TypeLabel.TextColor3 = Color3.fromRGB(150, 170, 200)
        TypeLabel.TextSize = 11
        TypeLabel.Font = Enum.Font.Gotham
        TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
        TypeLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TypeLabel.BackgroundTransparency = 1
        TypeLabel.ZIndex = 27
        TypeLabel.Parent = Item

        -- شارة حسب النوع
        local badgeText = ""
        local badgeColor = Color3.fromRGB(100, 100, 100)

        if info.IsScript then
            if readStatus.canReadSource then
                badgeText = "CODE"
                badgeColor = Color3.fromRGB(0, 255, 136)
            else
                badgeText = "LOCKED"
                badgeColor = Color3.fromRGB(255, 80, 80)
            end
        elseif instance:IsA("Sound") then
            badgeText = "SOUND"
            badgeColor = Color3.fromRGB(255, 200, 50)
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            badgeText = "IMAGE"
            badgeColor = Color3.fromRGB(255, 100, 150)
        elseif instance:IsA("BasePart") then
            badgeText = "PART"
            badgeColor = Color3.fromRGB(0, 180, 255)
        elseif instance:IsA("GuiObject") then
            badgeText = "GUI"
            badgeColor = Color3.fromRGB(200, 150, 255)
        elseif hasChildren then
            badgeText = "FOLDER"
            badgeColor = Color3.fromRGB(255, 200, 50)
        elseif instance:IsA("ValueBase") then
            badgeText = "VALUE"
            badgeColor = Color3.fromRGB(150, 200, 255)
        elseif instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
            badgeText = "REMOTE"
            badgeColor = Color3.fromRGB(255, 150, 50)
        end

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

        -- شارة القراءة (يمكن قراءته / محمي)
        local StatusDot = Instance.new("Frame")
        StatusDot.Size = UDim2.new(0, 8, 0, 8)
        StatusDot.Position = UDim2.new(1, -80, 0.5, -4)
        if readStatus.isProtected then
            StatusDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        elseif readStatus.canReadSource then
            StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        else
            StatusDot.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
        end
        StatusDot.BorderSizePixel = 0
        StatusDot.ZIndex = 28
        StatusDot.Parent = Item
        Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(1, 0)

        -- تأثيرات Hover
        Item.MouseEnter:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 45, 90),
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {
                Transparency = 0.2,
                Thickness = 2
            }):Play()
        end)
        Item.MouseLeave:Connect(function()
            TweenService:Create(Item, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 55),
                BackgroundTransparency = 0.2
            }):Play()
            TweenService:Create(IStroke, TweenInfo.new(0.15), {
                Transparency = 0.7,
                Thickness = 1
            }):Play()
        end)

        return Item, Arrow, hasChildren
    end

    -- ===================================
    -- ترتيب الأبناء
    -- ===================================
    local function SortChildren(children)
        table.sort(children, function(a, b)
            local aFolder = #a:GetChildren() > 0
            local bFolder = #b:GetChildren() > 0
            if aFolder ~= bFolder then return aFolder end
            return a.Name:lower() < b.Name:lower()
        end)
        return children
    end

    -- ===================================
    -- رسم الشجرة
    -- ===================================
    local function RenderChildren(parentInstance, depth)
        local children = FileScanner.GetChildren(parentInstance)
        children = SortChildren(children)

        for _, child in ipairs(children) do
            globalOrder = globalOrder + 1
            local myOrder = globalOrder

            local Item, Arrow, hasChildren = CreateTreeItem(child, depth, myOrder)

            local entry = {
                frame = Item,
                instance = child,
                depth = depth,
                order = myOrder,
                expanded = false,
                childFrames = {}
            }
            table.insert(allItems, entry)

            if hasChildren then
                -- النقر يفتح/يغلق المجلد
                Item.MouseButton1Click:Connect(function()
                    if entry.expanded then
                        -- اغلاق: احذف كل الأبناء المعروضين
                        entry.expanded = false
                        Arrow.Text = "+"
                        Arrow.TextColor3 = GetTypeColor(child.ClassName)

                        -- حذف كل الأبناء التابعين
                        local function RemoveDescendantFrames(inst)
                            local i = 1
                            while i <= #allItems do
                                local e = allItems[i]
                                local isChild = false
                                pcall(function()
                                    local p = e.instance.Parent
                                    while p do
                                        if p == inst then
                                            isChild = true
                                            break
                                        end
                                        p = p.Parent
                                    end
                                end)

                                if isChild then
                                    e.frame:Destroy()
                                    expandedFolders[e.instance] = nil
                                    table.remove(allItems, i)
                                else
                                    i = i + 1
                                end
                            end
                        end

                        RemoveDescendantFrames(child)
                        expandedFolders[child] = nil

                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                    else
                        -- فتح: أضف الأبناء المباشرين
                        entry.expanded = true
                        Arrow.Text = "-"
                        Arrow.TextColor3 = Color3.fromRGB(0, 255, 136)
                        expandedFolders[child] = true

                        -- أضف الأبناء
                        local subChildren = FileScanner.GetChildren(child)
                        subChildren = SortChildren(subChildren)

                        for _, subChild in ipairs(subChildren) do
                            globalOrder = globalOrder + 1
                            local subOrder = globalOrder

                            local SubItem, SubArrow, subHasChildren = CreateTreeItem(subChild, depth + 1, subOrder)

                            local subEntry = {
                                frame = SubItem,
                                instance = subChild,
                                depth = depth + 1,
                                order = subOrder,
                                expanded = false,
                                childFrames = {}
                            }
                            table.insert(allItems, subEntry)

                            if subHasChildren then
                                SubItem.MouseButton1Click:Connect(function()
                                    if subEntry.expanded then
                                        subEntry.expanded = false
                                        SubArrow.Text = "+"
                                        SubArrow.TextColor3 = GetTypeColor(subChild.ClassName)

                                        local function RemoveSubDescendants(inst)
                                            local j = 1
                                            while j <= #allItems do
                                                local se = allItems[j]
                                                local isSub = false
                                                pcall(function()
                                                    local pp = se.instance.Parent
                                                    while pp do
                                                        if pp == inst then
                                                            isSub = true
                                                            break
                                                        end
                                                        pp = pp.Parent
                                                    end
                                                end)

                                                if isSub then
                                                    se.frame:Destroy()
                                                    expandedFolders[se.instance] = nil
                                                    table.remove(allItems, j)
                                                else
                                                    j = j + 1
                                                end
                                            end
                                        end

                                        RemoveSubDescendants(subChild)
                                        expandedFolders[subChild] = nil
                                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                                    else
                                        subEntry.expanded = true
                                        SubArrow.Text = "-"
                                        SubArrow.TextColor3 = Color3.fromRGB(0, 255, 136)
                                        expandedFolders[subChild] = true

                                        local deepChildren = FileScanner.GetChildren(subChild)
                                        deepChildren = SortChildren(deepChildren)

                                        for _, deepChild in ipairs(deepChildren) do
                                            globalOrder = globalOrder + 1
                                            local deepOrder = globalOrder

                                            local DeepItem, DeepArrow, deepHasChildren = CreateTreeItem(deepChild, depth + 2, deepOrder)

                                            local deepEntry = {
                                                frame = DeepItem,
                                                instance = deepChild,
                                                depth = depth + 2,
                                                order = deepOrder,
                                                expanded = false,
                                                childFrames = {}
                                            }
                                            table.insert(allItems, deepEntry)

                                            if deepHasChildren then
                                                DeepItem.MouseButton1Click:Connect(function()
                                                    if deepEntry.expanded then
                                                        deepEntry.expanded = false
                                                        DeepArrow.Text = "+"

                                                        local k = 1
                                                        while k <= #allItems do
                                                            local de = allItems[k]
                                                            local isDeepChild = false
                                                            pcall(function()
                                                                local dp = de.instance.Parent
                                                                while dp do
                                                                    if dp == deepChild then
                                                                        isDeepChild = true
                                                                        break
                                                                    end
                                                                    dp = dp.Parent
                                                                end
                                                            end)

                                                            if isDeepChild then
                                                                de.frame:Destroy()
                                                                table.remove(allItems, k)
                                                            else
                                                                k = k + 1
                                                            end
                                                        end

                                                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                                                    else
                                                        deepEntry.expanded = true
                                                        DeepArrow.Text = "-"

                                                        local deepest = FileScanner.GetChildren(deepChild)
                                                        deepest = SortChildren(deepest)

                                                        for _, dd in ipairs(deepest) do
                                                            globalOrder = globalOrder + 1
                                                            local ddItem = CreateTreeItem(dd, depth + 3, globalOrder)
                                                            table.insert(allItems, {
                                                                frame = ddItem,
                                                                instance = dd,
                                                                depth = depth + 3,
                                                                order = globalOrder,
                                                                expanded = false
                                                            })

                                                            -- فتح FileViewer عند النقر
                                                            ddItem.MouseButton1Click:Connect(function()
                                                                local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                                                                FileViewer.Open(parent.Parent, dd)
                                                            end)
                                                        end

                                                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                                                    end
                                                end)
                                            else
                                                DeepItem.MouseButton1Click:Connect(function()
                                                    local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                                                    FileViewer.Open(parent.Parent, deepChild)
                                                end)
                                            end
                                        end

                                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                                    end
                                end)
                            else
                                -- عنصر بدون أبناء - يفتح FileViewer
                                SubItem.MouseButton1Click:Connect(function()
                                    local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                                    FileViewer.Open(parent.Parent, subChild)
                                end)
                            end
                        end

                        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
                    end
                end)
            else
                -- عنصر نهائي (بدون أبناء) - يفتح FileViewer
                Item.MouseButton1Click:Connect(function()
                    local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                    FileViewer.Open(parent.Parent, child)
                end)
            end
        end
    end

    -- ===================================
    -- عرض المستوى الأول
    -- ===================================
    RenderChildren(rootInstance, 0)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)

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
