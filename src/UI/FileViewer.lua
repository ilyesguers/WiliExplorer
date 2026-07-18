local FileViewer = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════
-- دالة نسخ للحافظة
-- ═══════════════════════════════
local function CopyToClipboard(text)
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        elseif toclipboard then
            toclipboard(text)
            success = true
        end
    end)
    return success
end

-- ═══════════════════════════════
-- دالة إشعار سريع
-- ═══════════════════════════════
local function ShowNotification(parent, message, color)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 250, 0, 50)
    Notif.Position = UDim2.new(0.5, -125, 0, -60)
    Notif.BackgroundColor3 = color or Color3.fromRGB(0, 200, 100)
    Notif.ZIndex = 100
    Notif.Parent = parent
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = Notif
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Text = message
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.BackgroundTransparency = 1
    Label.ZIndex = 101
    Label.Parent = Notif
    
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -125, 0, 10)
    }):Play()
    
    wait(2)
    
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -125, 0, -60)
    }):Play()
    
    wait(0.3)
    Notif:Destroy()
end

-- ═══════════════════════════════
-- الدالة الرئيسية
-- ═══════════════════════════════
function FileViewer.Open(mainParent, instance, onClose)
    local info = FileScanner.GetInfo(instance)
    
    -- الخلفية المعتمة
    local Overlay = Instance.new("Frame")
    Overlay.Name = "FileViewerOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 90
    Overlay.Parent = mainParent

    -- النافذة الرئيسية
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0.95, 0, 0.9, 0)
    Window.Position = UDim2.new(0.025, 0, 0.05, 0)
    Window.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.ZIndex = 91
    Window.Parent = Overlay
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 15)

    local WStroke = Instance.new("UIStroke")
    WStroke.Color = Color3.fromRGB(0, 212, 255)
    WStroke.Thickness = 2
    WStroke.Parent = Window

    local WGrad = Instance.new("UIGradient")
    WGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 18, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 50))
    })
    WGrad.Rotation = 135
    WGrad.Parent = Window

    -- ═══════════════════════════════
    -- الشريط العلوي
    -- ═══════════════════════════════
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    Header.BackgroundTransparency = 0.3
    Header.ZIndex = 92
    Header.Parent = Window

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 50, 0, 50)
    IconLabel.Position = UDim2.new(0, 10, 0.5, -25)
    IconLabel.Text = info.Icon
    IconLabel.TextSize = 32
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.BackgroundTransparency = 1
    IconLabel.ZIndex = 93
    IconLabel.Parent = Header

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -130, 0, 22)
    NameLabel.Position = UDim2.new(0, 65, 0, 10)
    NameLabel.Text = info.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 18
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.BackgroundTransparency = 1
    NameLabel.ZIndex = 93
    NameLabel.Parent = Header

    local ClassLabel = Instance.new("TextLabel")
    ClassLabel.Size = UDim2.new(1, -130, 0, 18)
    ClassLabel.Position = UDim2.new(0, 65, 0, 32)
    ClassLabel.Text = info.ClassName .. " • " .. info.Descendants .. " " .. Language.Get("Items")
    ClassLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    ClassLabel.TextSize = 13
    ClassLabel.Font = Enum.Font.Gotham
    ClassLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClassLabel.BackgroundTransparency = 1
    ClassLabel.ZIndex = 93
    ClassLabel.Parent = Header

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -50, 0.5, -20)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    CloseBtn.ZIndex = 93
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    CloseBtn.MouseButton1Click:Connect(function()
        Overlay:Destroy()
        if onClose then onClose() end
    end)

    -- ═══════════════════════════════
    -- شريط التبويبات (Tabs)
    -- ═══════════════════════════════
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.new(0, 10, 0, 70)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    TabBar.BackgroundTransparency = 0.4
    TabBar.ZIndex = 92
    TabBar.Parent = Window
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 5)
    TabPadding.Parent = TabBar

    -- منطقة المحتوى
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -20, 1, -180)
    ContentArea.Position = UDim2.new(0, 10, 0, 120)
    ContentArea.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.ZIndex = 92
    ContentArea.Parent = Window
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 10)

    local CAStroke = Instance.new("UIStroke")
    CAStroke.Color = Color3.fromRGB(0, 212, 255)
    CAStroke.Thickness = 1
    CAStroke.Transparency = 0.7
    CAStroke.Parent = ContentArea

    -- ═══════════════════════════════
    -- شريط الأزرار السفلي
    -- ═══════════════════════════════
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, -20, 0, 50)
    BottomBar.Position = UDim2.new(0, 10, 1, -55)
    BottomBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    BottomBar.BackgroundTransparency = 0.3
    BottomBar.ZIndex = 92
    BottomBar.Parent = Window
    Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 10)

    local BLayout = Instance.new("UIListLayout")
    BLayout.FillDirection = Enum.FillDirection.Horizontal
    BLayout.Padding = UDim.new(0, 5)
    BLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BLayout.Parent = BottomBar

    -- دالة لإنشاء زر
    local function CreateActionBtn(text, icon, color, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 100, 0, 40)
        Btn.Text = icon .. " " .. text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 13
        Btn.Font = Enum.Font.GothamBold
        Btn.BackgroundColor3 = color
        Btn.ZIndex = 93
        Btn.Parent = BottomBar
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    -- ═══════════════════════════════
    -- التبويبات
    -- ═══════════════════════════════
    local tabs = {}
    local currentTab = nil

    local function CreateTab(name, icon, order)
        local Tab = Instance.new("TextButton")
        Tab.Size = UDim2.new(0, 110, 1, 0)
        Tab.Text = icon .. " " .. name
        Tab.TextColor3 = Color3.fromRGB(150, 170, 200)
        Tab.TextSize = 13
        Tab.Font = Enum.Font.GothamBold
        Tab.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Tab.LayoutOrder = order
        Tab.ZIndex = 93
        Tab.Parent = TabBar
        Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 8)
        
        return Tab
    end

    local function SwitchTab(tabName)
        currentTab = tabName
        for name, data in pairs(tabs) do
            if name == tabName then
                data.button.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
                data.button.TextColor3 = Color3.fromRGB(11, 13, 26)
                data.content.Visible = true
            else
                data.button.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
                data.button.TextColor3 = Color3.fromRGB(150, 170, 200)
                data.content.Visible = false
            end
        end
    end

    -- ═══════════════════════════════
    -- تبويب: المعلومات (Info)
    -- ═══════════════════════════════
    local InfoContent = Instance.new("ScrollingFrame")
    InfoContent.Size = UDim2.new(1, -10, 1, -10)
    InfoContent.Position = UDim2.new(0, 5, 0, 5)
    InfoContent.BackgroundTransparency = 1
    InfoContent.BorderSizePixel = 0
    InfoContent.ScrollBarThickness = 4
    InfoContent.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    InfoContent.Visible = false
    InfoContent.ZIndex = 93
    InfoContent.Parent = ContentArea

    local InfoLayout = Instance.new("UIListLayout")
    InfoLayout.Padding = UDim.new(0, 8)
    InfoLayout.Parent = InfoContent

    local InfoPadding = Instance.new("UIPadding")
    InfoPadding.PaddingTop = UDim.new(0, 10)
    InfoPadding.PaddingLeft = UDim.new(0, 10)
    InfoPadding.PaddingRight = UDim.new(0, 10)
    InfoPadding.Parent = InfoContent

    -- دالة إضافة معلومة
    local function AddInfoRow(key, value, order)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 50)
        Row.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Row.LayoutOrder = order
        Row.ZIndex = 94
        Row.Parent = InfoContent
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

        local Key = Instance.new("TextLabel")
        Key.Size = UDim2.new(1, -10, 0, 20)
        Key.Position = UDim2.new(0, 10, 0, 5)
        Key.Text = key
        Key.TextColor3 = Color3.fromRGB(0, 212, 255)
        Key.TextSize = 12
        Key.Font = Enum.Font.GothamBold
        Key.TextXAlignment = Enum.TextXAlignment.Left
        Key.BackgroundTransparency = 1
        Key.ZIndex = 95
        Key.Parent = Row

        local Value = Instance.new("TextLabel")
        Value.Size = UDim2.new(1, -10, 0, 20)
        Value.Position = UDim2.new(0, 10, 0, 25)
        Value.Text = tostring(value)
        Value.TextColor3 = Color3.fromRGB(255, 255, 255)
        Value.TextSize = 13
        Value.Font = Enum.Font.Gotham
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.BackgroundTransparency = 1
        Value.ZIndex = 95
        Value.Parent = Row
    end

    -- إضافة كل المعلومات
    AddInfoRow("📛 Name", info.Name, 1)
    AddInfoRow("🏷️ Class Name", info.ClassName, 2)
    AddInfoRow("📁 Full Path", info.FullName, 3)
    AddInfoRow("👨‍👦 Parent", info.Parent, 4)
    AddInfoRow("📂 Direct Children", info.Children, 5)
    AddInfoRow("🌳 Total Descendants", info.Descendants, 6)
    
    if info.IsScript then
        AddInfoRow("📜 Is Script", "Yes", 7)
        AddInfoRow("💾 Has Source", info.HasSource and "Yes" or "Protected", 8)
        if info.SourceLength then
            AddInfoRow("📏 Source Length", info.SourceLength .. " characters", 9)
        end
    end

    -- خصائص إضافية (Properties)
    local propOrder = 10
    local function TryAddProperty(propName)
        pcall(function()
            local val = instance[propName]
            if val ~= nil then
                AddInfoRow("⚙️ " .. propName, tostring(val), propOrder)
                propOrder = propOrder + 1
            end
        end)
    end

    TryAddProperty("Position")
    TryAddProperty("Size")
    TryAddProperty("CFrame")
    TryAddProperty("Anchored")
    TryAddProperty("CanCollide")
    TryAddProperty("Transparency")
    TryAddProperty("Material")
    TryAddProperty("BrickColor")
    TryAddProperty("Color")
    TryAddProperty("Value")
    TryAddProperty("Text")
    TryAddProperty("SoundId")
    TryAddProperty("Volume")
    TryAddProperty("Pitch")
    TryAddProperty("Playing")
    TryAddProperty("Looped")
    TryAddProperty("Image")
    TryAddProperty("ImageColor3")
    TryAddProperty("Enabled")
    TryAddProperty("Visible")

    InfoContent.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 20)

    -- ═══════════════════════════════
    -- تبويب: الكود (Code) - للسكريبتات فقط
    -- ═══════════════════════════════
    local CodeContent = Instance.new("Frame")
    CodeContent.Size = UDim2.new(1, -10, 1, -10)
    CodeContent.Position = UDim2.new(0, 5, 0, 5)
    CodeContent.BackgroundTransparency = 1
    CodeContent.Visible = false
    CodeContent.ZIndex = 93
    CodeContent.Parent = ContentArea

    local CodeBox = Instance.new("TextBox")
    CodeBox.Size = UDim2.new(1, 0, 1, 0)
    CodeBox.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    CodeBox.TextColor3 = Color3.fromRGB(200, 220, 255)
    CodeBox.Font = Enum.Font.Code
    CodeBox.TextSize = 13
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.TextWrapped = false
    CodeBox.ClearTextOnFocus = false
    CodeBox.MultiLine = true
    CodeBox.Text = ""
    CodeBox.PlaceholderText = "// No source code available"
    CodeBox.ZIndex = 94
    CodeBox.Parent = CodeContent
    Instance.new("UICorner", CodeBox).CornerRadius = UDim.new(0, 8)

    local CodePad = Instance.new("UIPadding")
    CodePad.PaddingTop = UDim.new(0, 10)
    CodePad.PaddingLeft = UDim.new(0, 10)
    CodePad.PaddingRight = UDim.new(0, 10)
    CodePad.PaddingBottom = UDim.new(0, 10)
    CodePad.Parent = CodeBox

    -- تحميل الكود
    local sourceCode = ""
    if info.IsScript then
        pcall(function()
            sourceCode = instance.Source or ""
        end)
        if sourceCode == "" then
            CodeBox.Text = "-- Script is protected or empty"
            CodeBox.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            CodeBox.Text = sourceCode
        end
    end

    -- ═══════════════════════════════
    -- تبويب: الأبناء (Children)
    -- ═══════════════════════════════
    local ChildrenContent = Instance.new("ScrollingFrame")
    ChildrenContent.Size = UDim2.new(1, -10, 1, -10)
    ChildrenContent.Position = UDim2.new(0, 5, 0, 5)
    ChildrenContent.BackgroundTransparency = 1
    ChildrenContent.BorderSizePixel = 0
    ChildrenContent.ScrollBarThickness = 4
    ChildrenContent.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    ChildrenContent.Visible = false
    ChildrenContent.ZIndex = 93
    ChildrenContent.Parent = ContentArea

    local ChLayout = Instance.new("UIListLayout")
    ChLayout.Padding = UDim.new(0, 5)
    ChLayout.Parent = ChildrenContent

    local ChPad = Instance.new("UIPadding")
    ChPad.PaddingTop = UDim.new(0, 5)
    ChPad.PaddingLeft = UDim.new(0, 5)
    ChPad.PaddingRight = UDim.new(0, 5)
    ChPad.Parent = ChildrenContent

    local children = FileScanner.GetChildren(instance)
    for i, child in ipairs(children) do
        local childInfo = FileScanner.GetInfo(child)
        
        local ChItem = Instance.new("TextButton")
        ChItem.Size = UDim2.new(1, -10, 0, 45)
        ChItem.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        ChItem.Text = ""
        ChItem.LayoutOrder = i
        ChItem.ZIndex = 94
        ChItem.Parent = ChildrenContent
        Instance.new("UICorner", ChItem).CornerRadius = UDim.new(0, 8)

        local ChIcon = Instance.new("TextLabel")
        ChIcon.Size = UDim2.new(0, 40, 1, 0)
        ChIcon.Position = UDim2.new(0, 5, 0, 0)
        ChIcon.Text = childInfo.Icon
        ChIcon.TextSize = 20
        ChIcon.BackgroundTransparency = 1
        ChIcon.ZIndex = 95
        ChIcon.Parent = ChItem

        local ChName = Instance.new("TextLabel")
        ChName.Size = UDim2.new(1, -50, 0, 20)
        ChName.Position = UDim2.new(0, 45, 0, 5)
        ChName.Text = childInfo.Name
        ChName.TextColor3 = Color3.fromRGB(255, 255, 255)
        ChName.TextSize = 13
        ChName.Font = Enum.Font.GothamBold
        ChName.TextXAlignment = Enum.TextXAlignment.Left
        ChName.BackgroundTransparency = 1
        ChName.ZIndex = 95
        ChName.Parent = ChItem

        local ChClass = Instance.new("TextLabel")
        ChClass.Size = UDim2.new(1, -50, 0, 15)
        ChClass.Position = UDim2.new(0, 45, 0, 25)
        ChClass.Text = childInfo.ClassName .. " • " .. childInfo.Children .. " items"
        ChClass.TextColor3 = Color3.fromRGB(150, 170, 200)
        ChClass.TextSize = 11
        ChClass.Font = Enum.Font.Gotham
        ChClass.TextXAlignment = Enum.TextXAlignment.Left
        ChClass.BackgroundTransparency = 1
        ChClass.ZIndex = 95
        ChClass.Parent = ChItem

        ChItem.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            FileViewer.Open(mainParent, child, onClose)
        end)
    end

    ChildrenContent.CanvasSize = UDim2.new(0, 0, 0, ChLayout.AbsoluteContentSize.Y + 20)

    -- ═══════════════════════════════
    -- إنشاء التبويبات
    -- ═══════════════════════════════
    tabs["Info"] = {button = CreateTab("Info", "ℹ️", 1), content = InfoContent}
    
    if info.IsScript then
        tabs["Code"] = {button = CreateTab("Code", "📜", 2), content = CodeContent}
    end
    
    if info.Children > 0 then
        tabs["Children"] = {button = CreateTab("Children", "📂", 3), content = ChildrenContent}
    end

    -- ربط التبويبات
    for name, data in pairs(tabs) do
        data.button.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    -- افتراضياً: افتح أول تبويب
    if info.IsScript and info.HasSource then
        SwitchTab("Code")
    else
        SwitchTab("Info")
    end

    -- ═══════════════════════════════
    -- الأزرار السفلية
    -- ═══════════════════════════════
    
    -- زر نسخ المحتوى
    CreateActionBtn("Copy", "📋", Color3.fromRGB(0, 152, 219), function()
        local textToCopy = ""
        if currentTab == "Code" then
            textToCopy = CodeBox.Text
        elseif currentTab == "Info" then
            textToCopy = info.FullName
        end
        
        if CopyToClipboard(textToCopy) then
            ShowNotification(Window, "✅ Copied to clipboard!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(Window, "❌ Copy failed", Color3.fromRGB(200, 50, 70))
        end
    end)

    -- زر نسخ المسار
    CreateActionBtn("Path", "🔗", Color3.fromRGB(100, 100, 200), function()
        if CopyToClipboard(info.FullName) then
            ShowNotification(Window, "✅ Path copied!", Color3.fromRGB(0, 200, 100))
        end
    end)

    -- زر الحفظ (للسكريبتات فقط)
    if info.IsScript then
        CreateActionBtn("Save", "💾", Color3.fromRGB(0, 200, 100), function()
            local newSource = CodeBox.Text
            local success, err = pcall(function()
                instance.Source = newSource
            end)
            
            if success then
                ShowNotification(Window, "✅ Saved successfully!", Color3.fromRGB(0, 200, 100))
            else
                ShowNotification(Window, "❌ " .. tostring(err), Color3.fromRGB(200, 50, 70))
            end
        end)
    end

    -- زر النسخ المكرر (Clone)
    CreateActionBtn("Clone", "📑", Color3.fromRGB(200, 150, 50), function()
        local success = pcall(function()
            local clone = instance:Clone()
            clone.Parent = instance.Parent
            clone.Name = instance.Name .. "_Copy"
        end)
        
        if success then
            ShowNotification(Window, "✅ Cloned!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(Window, "❌ Clone failed", Color3.fromRGB(200, 50, 70))
        end
    end)

    -- زر الحذف
    CreateActionBtn("Delete", "🗑️", Color3.fromRGB(200, 50, 70), function()
        local success = pcall(function()
            instance:Destroy()
        end)
        
        if success then
            ShowNotification(Window, "✅ Deleted!", Color3.fromRGB(0, 200, 100))
            wait(1)
            Overlay:Destroy()
            if onClose then onClose() end
        else
            ShowNotification(Window, "❌ Delete failed", Color3.fromRGB(200, 50, 70))
        end
    end)

    print("FileViewer opened for: " .. instance:GetFullName())
end

return FileViewer
