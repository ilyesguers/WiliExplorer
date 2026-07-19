local AdvancedUI = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

function AdvancedUI.Create(parent, onBack)
    local AdvancedTools = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/AdvancedTools.lua", true))()
    
    -- ═══════════════════════════════
    -- الإطار الرئيسي
    -- ═══════════════════════════════
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 10
    MainFrame.Parent = parent

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 13, 26)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(17, 20, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 60))
    })
    Gradient.Rotation = 135
    Gradient.Parent = MainFrame

    -- ═══════════════════════════════
    -- شريط الأدوات العلوي
    -- ═══════════════════════════════
    local ToolBar = Instance.new("Frame")
    ToolBar.Size = UDim2.new(1, 0, 0, 60)
    ToolBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    ToolBar.BackgroundTransparency = 0.3
    ToolBar.BorderSizePixel = 0
    ToolBar.ZIndex = 20
    ToolBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 0, 60)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "⚡ ADVANCED TOOLS"
    Title.TextColor3 = Color3.fromRGB(138, 43, 226)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 21
    Title.Parent = ToolBar

    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 80, 0, 40)
    BackBtn.Position = UDim2.new(1, -95, 0.5, -20)
    BackBtn.Text = "◀ Back"
    BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BackBtn.TextSize = 14
    BackBtn.Font = Enum.Font.GothamBold
    BackBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    BackBtn.ZIndex = 21
    BackBtn.Parent = ToolBar
    Instance.new("UICorner", BackBtn).CornerRadius = UDim.new(0, 8)

    BackBtn.MouseButton1Click:Connect(function()
        parent:ClearAllChildren()
        onBack()
    end)

    -- ═══════════════════════════════
    -- منطقة المحتوى
    -- ═══════════════════════════════
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -80)
    Content.Position = UDim2.new(0, 10, 0, 70)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 8
    Content.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Content.ZIndex = 15
    Content.Parent = MainFrame

    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 15)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = Content

    -- ═══════════════════════════════
    -- دالة لإنشاء قسم
    -- ═══════════════════════════════
    local function CreateSection(title, icon)
        local Section = Instance.new("Frame")
        Section.Size = UDim2.new(1, 0, 0, 45)
        Section.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
        Section.BackgroundTransparency = 0.3
        Section.BorderSizePixel = 0
        Section.ZIndex = 16
        Section.Parent = Content
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 10)

        local SStroke = Instance.new("UIStroke")
        SStroke.Color = Color3.fromRGB(138, 43, 226)
        SStroke.Thickness = 1
        SStroke.Transparency = 0.6
        SStroke.Parent = Section

        local SIcon = Instance.new("TextLabel")
        SIcon.Size = UDim2.new(0, 40, 0, 40)
        SIcon.Position = UDim2.new(0, 5, 0.5, -20)
        SIcon.Text = icon
        SIcon.TextSize = 24
        SIcon.BackgroundTransparency = 1
        SIcon.ZIndex = 17
        SIcon.Parent = Section

        local STitle = Instance.new("TextLabel")
        STitle.Size = UDim2.new(1, -50, 0, 40)
        STitle.Position = UDim2.new(0, 50, 0, 0)
        STitle.Text = title
        STitle.TextColor3 = Color3.fromRGB(200, 150, 255)
        STitle.TextSize = 16
        STitle.Font = Enum.Font.GothamBold
        STitle.TextXAlignment = Enum.TextXAlignment.Left
        STitle.BackgroundTransparency = 1
        STitle.ZIndex = 17
        STitle.Parent = Section

        return Section
    end

    -- ═══════════════════════════════
    -- دالة لإنشاء زر أداة
    -- ═══════════════════════════════
    local function CreateToolButton(name, icon, description, callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 0, 90)
        Button.BackgroundColor3 = Color3.fromRGB(25, 30, 65)
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.ZIndex = 16
        Button.Parent = Content
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 12)

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Color3.fromRGB(0, 212, 255)
        BStroke.Thickness = 1.5
        BStroke.Transparency = 0.5
        BStroke.Parent = Button

        local BIcon = Instance.new("TextLabel")
        BIcon.Size = UDim2.new(0, 60, 0, 60)
        BIcon.Position = UDim2.new(0, 15, 0.5, -30)
        BIcon.Text = icon
        BIcon.TextSize = 32
        BIcon.BackgroundTransparency = 1
        BIcon.ZIndex = 17
        BIcon.Parent = Button

        local BName = Instance.new("TextLabel")
        BName.Size = UDim2.new(1, -85, 0, 25)
        BName.Position = UDim2.new(0, 85, 0, 10)
        BName.Text = name
        BName.TextColor3 = Color3.fromRGB(255, 255, 255)
        BName.TextSize = 14
        BName.Font = Enum.Font.GothamBold
        BName.TextXAlignment = Enum.TextXAlignment.Left
        BName.BackgroundTransparency = 1
        BName.ZIndex = 17
        BName.Parent = Button

        local BDesc = Instance.new("TextLabel")
        BDesc.Size = UDim2.new(1, -85, 0, 45)
        BDesc.Position = UDim2.new(0, 85, 0, 35)
        BDesc.Text = description
        BDesc.TextColor3 = Color3.fromRGB(150, 170, 200)
        BDesc.TextSize = 11
        BDesc.Font = Enum.Font.Gotham
        BDesc.TextXAlignment = Enum.TextXAlignment.Left
        BDesc.TextWrapped = true
        BDesc.BackgroundTransparency = 1
        BDesc.ZIndex = 17
        BDesc.Parent = Button

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 40, 85)
            }):Play()
            TweenService:Create(BStroke, TweenInfo.new(0.2), {
                Transparency = 0,
                Thickness = 2.5
            }):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 30, 65)
            }):Play()
            TweenService:Create(BStroke, TweenInfo.new(0.2), {
                Transparency = 0.5,
                Thickness = 1.5
            }):Play()
        end)

        Button.MouseButton1Click:Connect(callback)

        return Button
    end

    -- ═══════════════════════════════
    -- قسم محرر النماذج
    -- ═══════════════════════════════
    CreateSection("Model Editor", "🧱")

    CreateToolButton(
        "Edit Model Properties",
        "🎨",
        "تعديل خصائص النماذج والأجزاء والألوان والمواد",
        function()
            local char = Players.LocalPlayer.Character
            if char then
                local info = AdvancedTools.ModelEditor.GetInfo(char)
                print("Model Info:", info)
            end
        end
    )

    CreateToolButton(
        "Move Object",
        "➡️",
        "نقل الأشياء في جميع الاتجاهات",
        function()
            print("Move tool selected - Select an object and use arrow keys")
        end
    )

    CreateToolButton(
        "Rotate Object",
        "🔄",
        "تدوير الأشياء حول محاور مختلفة",
        function()
            print("Rotate tool selected")
        end
    )

    CreateToolButton(
        "Scale Object",
        "📏",
        "تكبير أو تصغير حجم الأشياء",
        function()
            print("Scale tool selected")
        end
    )

    CreateToolButton(
        "Clone Object",
        "📋",
        "نسخ الأشياء وإنشاء نسخ منها",
        function()
            print("Clone tool selected")
        end
    )

    -- ═══════════════════════════════
    -- قسم نظام التفعيل
    -- ═══════════════════════════════
    CreateSection("Activator System", "⚡")

    CreateToolButton(
        "Activate Objects",
        "🎯",
        "تفعيل ProximityPrompt و ClickDetector و الأشياء التفاعلية",
        function()
            local result = AdvancedTools.Activator.FindAll(workspace)
            print("Found " .. #result .. " activatable objects")
        end
    )

    CreateToolButton(
        "Toggle Prompts",
        "🔘",
        "تفعيل أو تعطيل ProximityPrompts",
        function()
            print("Toggle prompts - Select target")
        end
    )

    CreateToolButton(
        "Equip Tools",
        "🛠️",
        "تجهيز الأدوات من StarterPack",
        function()
            print("Tool equip mode active")
        end
    )

    -- ═══════════════════════════════
    -- قسم نظام التصور
    -- ═══════════════════════════════
    CreateSection("Visualizer", "👁️")

    CreateToolButton(
        "Highlight Objects",
        "✨",
        "تمييز الأشياء بألوان مختلفة لسهولة الرؤية",
        function()
            print("Highlight mode - hover over objects to highlight")
        end
    )

    CreateToolButton(
        "Show Bounding Boxes",
        "📦",
        "عرض صناديق الحدود حول الأشياء",
        function()
            local descendants = workspace:GetDescendants()
            for _, obj in ipairs(descendants) do
                if obj:IsA("BasePart") then
                    AdvancedTools.Visualizer.ShowBoundingBox(obj)
                end
            end
        end
    )

    CreateToolButton(
        "Add Labels",
        "🏷️",
        "إضافة تسميات توضيحية على الأشياء",
        function()
            print("Label mode active")
        end
    )

    CreateToolButton(
        "Clear Visuals",
        "🗑️",
        "حذف جميع المؤشرات والتمييزات",
        function()
            AdvancedTools.Visualizer.ClearAll()
            print("All visuals cleared")
        end
    )

    -- ═══════════════════════════════
    -- قسم التخصيص
    -- ═══════════════════════════════
    CreateSection("Customization", "🎨")

    CreateToolButton(
        "Change Colors",
        "🎨",
        "تغيير ألوان الأشياء والأجزاء",
        function()
            print("Color picker mode active")
        end
    )

    CreateToolButton(
        "Change Materials",
        "✨",
        "تطبيق مواد مختلفة (Neon, Metal, Glass, إلخ)",
        function()
            print("Material selector active")
        end
    )

    CreateToolButton(
        "Set Transparency",
        "👻",
        "التحكم في شفافية الأشياء",
        function()
            print("Transparency adjuster active")
        end
    )

    CreateToolButton(
        "Toggle CanCollide",
        "🚫",
        "تفعيل/تعطيل التصادم للأجزاء",
        function()
            print("Collision toggle mode")
        end
    )

    -- ═══════════════════════════════
    -- قسم أدوات أخرى
    -- ═══════════════════════════════
    CreateSection("Additional Tools", "🔧")

    CreateToolButton(
        "Teleporter",
        "📍",
        "النقل الفوري إلى الأماكن المختلفة",
        function()
            print("Teleporter activated")
        end
    )

    CreateToolButton(
        "Property Panel",
        "⚙️",
        "عرض جميع خصائص الكائن وتعديلها",
        function()
            print("Property panel mode")
        end
    )

    CreateToolButton(
        "Animations",
        "🎬",
        "تطبيق تأثيرات حركية على الأشياء",
        function()
            print("Animation selector active")
        end
    )

    CreateToolButton(
        "Show Notifications",
        "🔔",
        "اختبار نظام الإشعارات الجميل",
        function()
            AdvancedTools.Notifications.Init(MainFrame)
            AdvancedTools.Notifications.Show("Test Title", "This is a test notification", "success", 3)
        end
    )

    -- تحديث CanvasSize
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
    end)
end

return AdvancedUI
