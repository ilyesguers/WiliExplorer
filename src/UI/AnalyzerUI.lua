local AnalyzerUI = {}

local TweenService = game:GetService("TweenService")

function AnalyzerUI.Create(parent, onBack)
    local GameAnalyzer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/GameAnalyzer.lua", true))()
    
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
    Title.Text = "🔬 GAME ANALYZER"
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
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
    -- الزر الرئيسي للفحص
    -- ═══════════════��═══════════════
    local ScanButton = Instance.new("TextButton")
    ScanButton.Size = UDim2.new(1, 0, 0, 120)
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    ScanButton.Text = ""
    ScanButton.AutoButtonColor = false
    ScanButton.ZIndex = 16
    ScanButton.Parent = Content
    Instance.new("UICorner", ScanButton).CornerRadius = UDim.new(0, 15)

    local ScanGrad = Instance.new("UIGradient")
    ScanGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 152, 219))
    })
    ScanGrad.Rotation = 90
    ScanGrad.Parent = ScanButton

    local ScanIcon = Instance.new("TextLabel")
    ScanIcon.Size = UDim2.new(0, 60, 0, 60)
    ScanIcon.Position = UDim2.new(0, 15, 0.5, -30)
    ScanIcon.Text = "🔍"
    ScanIcon.TextSize = 42
    ScanIcon.BackgroundTransparency = 1
    ScanIcon.ZIndex = 17
    ScanIcon.Parent = ScanButton

    local ScanName = Instance.new("TextLabel")
    ScanName.Size = UDim2.new(1, -85, 0, 30)
    ScanName.Position = UDim2.new(0, 85, 0, 15)
    ScanName.Text = "START FULL SCAN"
    ScanName.TextColor3 = Color3.fromRGB(11, 13, 26)
    ScanName.TextSize = 18
    ScanName.Font = Enum.Font.GothamBold
    ScanName.TextXAlignment = Enum.TextXAlignment.Left
    ScanName.BackgroundTransparency = 1
    ScanName.ZIndex = 17
    ScanName.Parent = ScanButton

    local ScanDesc = Instance.new("TextLabel")
    ScanDesc.Size = UDim2.new(1, -85, 0, 55)
    ScanDesc.Position = UDim2.new(0, 85, 0, 45)
    ScanDesc.Text = "فحص شامل للعبة لاكتشاف جميع القيم والـ Remotes والـ Scripts"
    ScanDesc.TextColor3 = Color3.fromRGB(50, 100, 150)
    ScanDesc.TextSize = 12
    ScanDesc.Font = Enum.Font.Gotham
    ScanDesc.TextXAlignment = Enum.TextXAlignment.Left
    ScanDesc.TextWrapped = true
    ScanDesc.BackgroundTransparency = 1
    ScanDesc.ZIndex = 17
    ScanDesc.Parent = ScanButton

    -- حالة الفحص
    local scanRunning = false
    local scanResults = nil

    ScanButton.MouseEnter:Connect(function()
        if not scanRunning then
            TweenService:Create(ScanButton, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 125)
            }):Play()
        end
    end)
    ScanButton.MouseLeave:Connect(function()
        if not scanRunning then
            TweenService:Create(ScanButton, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 120)
            }):Play()
        end
    end)

    ScanButton.MouseButton1Click:Connect(function()
        if scanRunning then return end
        scanRunning = true
        ScanName.Text = "🔄 SCANNING..."
        ScanDesc.Text = "الفحص جاري... يرجى الانتظار"

        task.spawn(function()
            local result = GameAnalyzer.Scan(
                function(progress)
                    ScanDesc.Text = "الفحص جاري: " .. progress.currentService .. "\n📊 تم فحص: " .. progress.scanned .. " عنصر"
                end,
                function(results)
                    scanResults = results
                    scanRunning = false
                    ScanName.Text = "✅ SCAN COMPLETE"
                    ScanDesc.Text = "تم اكتشاف:\n• " .. #results.values .. " قيم\n• " .. results.summary.totalRemotes .. " Remotes\n• " .. #results.scripts .. " Scripts"
                end
            )
        end)
    end)

    -- ═══════════════════════════════
    -- دالة لإنشاء بطاقة نتيجة
    -- ═══════════════════════════════
    local function CreateResultCard(title, icon, count, color)
        local Card = Instance.new("TextButton")
        Card.Size = UDim2.new(0.5, -10, 0, 90)
        Card.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Card.Text = ""
        Card.AutoButtonColor = false
        Card.ZIndex = 16
        Card.Parent = Content
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)

        local CStroke = Instance.new("UIStroke")
        CStroke.Color = color
        CStroke.Thickness = 1.5
        CStroke.Transparency = 0.5
        CStroke.Parent = Card

        local CIcon = Instance.new("TextLabel")
        CIcon.Size = UDim2.new(1, 0, 0, 35)
        CIcon.Position = UDim2.new(0, 0, 0, 10)
        CIcon.Text = icon
        CIcon.TextSize = 24
        CIcon.BackgroundTransparency = 1
        CIcon.ZIndex = 17
        CIcon.Parent = Card

        local CName = Instance.new("TextLabel")
        CName.Size = UDim2.new(1, -10, 0, 20)
        CName.Position = UDim2.new(0, 5, 0, 45)
        CName.Text = title
        CName.TextColor3 = Color3.fromRGB(255, 255, 255)
        CName.TextSize = 12
        CName.Font = Enum.Font.GothamBold
        CName.BackgroundTransparency = 1
        CName.TextWrapped = true
        CName.ZIndex = 17
        CName.Parent = Card

        local CCount = Instance.new("TextLabel")
        CCount.Size = UDim2.new(1, -10, 0, 20)
        CCount.Position = UDim2.new(0, 5, 1, -25)
        CCount.Text = count .. ""
        CCount.TextColor3 = color
        CCount.TextSize = 16
        CCount.Font = Enum.Font.GothamBold
        CCount.BackgroundTransparency = 1
        CCount.ZIndex = 17
        CCount.Parent = Card

        Card.MouseEnter:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 40, 80)
            }):Play()
        end)
        Card.MouseLeave:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 55)
            }):Play()
        end)

        return Card
    end

    -- ═══════════════════════════════
    -- قسم معلومات الفحص
    -- ═══════════════════════════════
    local InfoSection = Instance.new("Frame")
    InfoSection.Size = UDim2.new(1, 0, 0, 40)
    InfoSection.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    InfoSection.BackgroundTransparency = 0.5
    InfoSection.BorderSizePixel = 0
    InfoSection.ZIndex = 16
    InfoSection.Parent = Content
    Instance.new("UICorner", InfoSection).CornerRadius = UDim.new(0, 10)

    local InfoStroke = Instance.new("UIStroke")
    InfoStroke.Color = Color3.fromRGB(0, 212, 255)
    InfoStroke.Thickness = 1
    InfoStroke.Transparency = 0.6
    InfoStroke.Parent = InfoSection

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 1, 0)
    InfoLabel.Position = UDim2.new(0, 10, 0, 0)
    InfoLabel.Text = "📊 SCAN CATEGORIES"
    InfoLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    InfoLabel.TextSize = 14
    InfoLabel.Font = Enum.Font.GothamBold
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.ZIndex = 17
    InfoLabel.Parent = InfoSection

    -- ═══════════════════════════════
    -- بطاقات النتائج
    -- ═══════════════════════════════
    CreateResultCard("Values", "💾", 0, Color3.fromRGB(0, 255, 150))
    CreateResultCard("Remotes", "🌐", 0, Color3.fromRGB(100, 200, 255))
    CreateResultCard("Scripts", "📝", 0, Color3.fromRGB(255, 200, 50))
    CreateResultCard("Protected", "🔒", 0, Color3.fromRGB(255, 100, 100))

    -- ═══════════════════════════════
    -- قسم الأدوات المتقدمة
    -- ═══════════════════════════════
    local ToolsSection = Instance.new("Frame")
    ToolsSection.Size = UDim2.new(1, 0, 0, 40)
    ToolsSection.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    ToolsSection.BackgroundTransparency = 0.5
    ToolsSection.BorderSizePixel = 0
    ToolsSection.ZIndex = 16
    ToolsSection.Parent = Content
    Instance.new("UICorner", ToolsSection).CornerRadius = UDim.new(0, 10)

    local ToolsStroke = Instance.new("UIStroke")
    ToolsStroke.Color = Color3.fromRGB(138, 43, 226)
    ToolsStroke.Thickness = 1
    ToolsStroke.Transparency = 0.6
    ToolsStroke.Parent = ToolsSection

    local ToolsLabel = Instance.new("TextLabel")
    ToolsLabel.Size = UDim2.new(1, -20, 1, 0)
    ToolsLabel.Position = UDim2.new(0, 10, 0, 0)
    ToolsLabel.Text = "🛠️ ANALYSIS TOOLS"
    ToolsLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    ToolsLabel.TextSize = 14
    ToolsLabel.Font = Enum.Font.GothamBold
    ToolsLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToolsLabel.BackgroundTransparency = 1
    ToolsLabel.ZIndex = 17
    ToolsLabel.Parent = ToolsSection

    -- ═══════════════════════════════
    -- أزرار الأدوات
    -- ═══════════════════════════════
    local function CreateToolBtn(name, icon, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 50)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 30, 65)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.ZIndex = 16
        Btn.Parent = Content
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = Color3.fromRGB(138, 43, 226)
        BStroke.Thickness = 1.5
        BStroke.Transparency = 0.5
        BStroke.Parent = Btn

        local BIcon = Instance.new("TextLabel")
        BIcon.Size = UDim2.new(0, 40, 0, 40)
        BIcon.Position = UDim2.new(0, 10, 0.5, -20)
        BIcon.Text = icon
        BIcon.TextSize = 20
        BIcon.BackgroundTransparency = 1
        BIcon.ZIndex = 17
        BIcon.Parent = Btn

        local BName = Instance.new("TextLabel")
        BName.Size = UDim2.new(1, -60, 0, 40)
        BName.Position = UDim2.new(0, 60, 0, 0)
        BName.Text = name
        BName.TextColor3 = Color3.fromRGB(255, 255, 255)
        BName.TextSize = 13
        BName.Font = Enum.Font.GothamBold
        BName.TextXAlignment = Enum.TextXAlignment.Left
        BName.BackgroundTransparency = 1
        BName.ZIndex = 17
        BName.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 45, 90)
            }):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 30, 65)
            }):Play()
        end)

        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    CreateToolBtn("Analyze Values", "💾", function()
        if scanResults then
            print("=== VALUES ===")
            for i, val in ipairs(scanResults.values) do
                if i > 10 then break end
                print(val.name .. " = " .. val.value .. " (" .. val.className .. ")")
            end
        else
            print("Run scan first!")
        end
    end)

    CreateToolBtn("Find Cooldowns", "⏱️", function()
        if scanResults then
            print("=== COOLDOWNS FOUND ===")
            for i, cd in ipairs(scanResults.cooldowns) do
                if i > 5 then break end
                print(cd.name .. " at " .. cd.path)
            end
        else
            print("Run scan first!")
        end
    end)

    CreateToolBtn("Find Speed Values", "⚡", function()
        if scanResults then
            print("=== SPEED VALUES ===")
            for i, spd in ipairs(scanResults.speeds) do
                if i > 5 then break end
                print(spd.name .. " = " .. spd.value)
            end
        else
            print("Run scan first!")
        end
    end)

    CreateToolBtn("Find Currency", "💰", function()
        if scanResults then
            print("=== CURRENCY ===")
            for i, cur in ipairs(scanResults.currencies) do
                if i > 5 then break end
                print(cur.name .. " = " .. cur.value)
            end
        else
            print("Run scan first!")
        end
    end)

    CreateToolBtn("View Remotes", "🌐", function()
        if scanResults then
            print("=== REMOTES FOUND: " .. results.summary.totalRemotes .. " ===")
            for i, remote in ipairs(scanResults.remotes) do
                if i > 5 then break end
                print((remote.interesting and "⭐ " or "") .. remote.name .. " (" .. remote.className .. ")")
            end
        else
            print("Run scan first!")
        end
    end)

    CreateToolBtn("View Scripts", "📝", function()
        if scanResults then
            print("=== READABLE SCRIPTS ===")
            for i, script in ipairs(scanResults.scripts) do
                if script.readable and i <= 5 then
                    print("✅ " .. script.name .. " (" .. script.className .. ")")
                end
            end
        else
            print("Run scan first!")
        end
    end)

    -- تحديث CanvasSize
    Content.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
    end)
end

return AnalyzerUI
