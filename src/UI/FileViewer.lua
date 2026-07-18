local FileViewer = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()

local TweenService = game:GetService("TweenService")

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

local function PasteFromClipboard()
    local text = ""
    pcall(function()
        if getclipboard then
            text = getclipboard()
        end
    end)
    return text
end

local function ShowNotification(parent, message, color)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 50)
    Notif.Position = UDim2.new(0.5, -150, 0, -60)
    Notif.BackgroundColor3 = color or Color3.fromRGB(0, 200, 100)
    Notif.ZIndex = 999
    Notif.Parent = parent
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.Text = message
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.BackgroundTransparency = 1
    Label.TextWrapped = true
    Label.ZIndex = 1000
    Label.Parent = Notif
    
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -150, 0, 10)
    }):Play()
    
    spawn(function()
        wait(2.5)
        TweenService:Create(Notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -150, 0, -60)
        }):Play()
        wait(0.3)
        Notif:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════
-- Value Editor (لتعديل NumberValue, StringValue, BoolValue, IntValue)
-- ═══════════════════════════════════════════════════════
function FileViewer.OpenValueEditor(mainParent, instance, onExit)
    -- تخزين حالة الـ Freeze
    if not _G.WiliFrozenValues then
        _G.WiliFrozenValues = {}
    end
    
    local FullScreen = Instance.new("Frame")
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent
    
    -- ═══ الشريط العلوي ═══
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(0, 10, 0.5, -25)
    Icon.Text = "⚙️"
    Icon.TextSize = 32
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 502
    Icon.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 400, 0, 25)
    Title.Position = UDim2.new(0, 70, 0, 8)
    Title.Text = instance.Name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 502
    Title.Parent = TopBar
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 400, 0, 20)
    Subtitle.Position = UDim2.new(0, 70, 0, 33)
    Subtitle.Text = instance.ClassName .. " Editor"
    Subtitle.TextColor3 = Color3.fromRGB(0, 212, 255)
    Subtitle.TextSize = 13
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 502
    Subtitle.Parent = TopBar
    
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 70, 0, 40)
    ExitBtn.Position = UDim2.new(1, -80, 0.5, -20)
    ExitBtn.Text = "✕"
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.TextSize = 20
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    ExitBtn.MouseButton1Click:Connect(function()
        FullScreen:Destroy()
        if onExit then onExit() end
    end)
    
    -- ═══ ScrollingFrame للمحتوى ═══
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -80)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 70)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
    ScrollFrame.ZIndex = 501
    ScrollFrame.Parent = FullScreen
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 12)
    Layout.Parent = ScrollFrame
    
    local LPad = Instance.new("UIPadding")
    LPad.PaddingTop = UDim.new(0, 5)
    LPad.PaddingLeft = UDim.new(0, 10)
    LPad.PaddingRight = UDim.new(0, 10)
    LPad.Parent = ScrollFrame
    
    -- ═══ بطاقة القيمة الحالية ═══
    local CurrentCard = Instance.new("Frame")
    CurrentCard.Size = UDim2.new(1, -20, 0, 100)
    CurrentCard.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    CurrentCard.LayoutOrder = 1
    CurrentCard.ZIndex = 502
    CurrentCard.Parent = ScrollFrame
    Instance.new("UICorner", CurrentCard).CornerRadius = UDim.new(0, 12)
    
    local CurLabel = Instance.new("TextLabel")
    CurLabel.Size = UDim2.new(1, -20, 0, 25)
    CurLabel.Position = UDim2.new(0, 10, 0, 10)
    CurLabel.Text = "📊 Current Value (Live):"
    CurLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    CurLabel.TextSize = 14
    CurLabel.Font = Enum.Font.GothamBold
    CurLabel.TextXAlignment = Enum.TextXAlignment.Left
    CurLabel.BackgroundTransparency = 1
    CurLabel.ZIndex = 503
    CurLabel.Parent = CurrentCard
    
    local CurValueBox = Instance.new("TextLabel")
    CurValueBox.Size = UDim2.new(1, -20, 0, 45)
    CurValueBox.Position = UDim2.new(0, 10, 0, 40)
    CurValueBox.Text = ""
    CurValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurValueBox.TextSize = 22
    CurValueBox.Font = Enum.Font.Code
    CurValueBox.TextXAlignment = Enum.TextXAlignment.Left
    CurValueBox.BackgroundColor3 = Color3.fromRGB(30, 35, 70)
    CurValueBox.ZIndex = 503
    CurValueBox.Parent = CurrentCard
    Instance.new("UICorner", CurValueBox).CornerRadius = UDim.new(0, 8)
    
    local CVPad = Instance.new("UIPadding")
    CVPad.PaddingLeft = UDim.new(0, 12)
    CVPad.Parent = CurValueBox
    
    -- تحديث القيمة الحالية باستمرار
    local function UpdateCurrentValue()
        pcall(function()
            CurValueBox.Text = tostring(instance.Value)
        end)
    end
    UpdateCurrentValue()
    
    -- ═══ بطاقة القيمة الجديدة ═══
    local NewCard = Instance.new("Frame")
    NewCard.Size = UDim2.new(1, -20, 0, 110)
    NewCard.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    NewCard.LayoutOrder = 2
    NewCard.ZIndex = 502
    NewCard.Parent = ScrollFrame
    Instance.new("UICorner", NewCard).CornerRadius = UDim.new(0, 12)
    
    local NewLabel = Instance.new("TextLabel")
    NewLabel.Size = UDim2.new(1, -20, 0, 25)
    NewLabel.Position = UDim2.new(0, 10, 0, 10)
    NewLabel.Text = "✏️ New Value:"
    NewLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    NewLabel.TextSize = 14
    NewLabel.Font = Enum.Font.GothamBold
    NewLabel.TextXAlignment = Enum.TextXAlignment.Left
    NewLabel.BackgroundTransparency = 1
    NewLabel.ZIndex = 503
    NewLabel.Parent = NewCard
    
    local ValueInput = Instance.new("TextBox")
    ValueInput.Size = UDim2.new(1, -20, 0, 50)
    ValueInput.Position = UDim2.new(0, 10, 0, 45)
    ValueInput.Text = ""
    ValueInput.PlaceholderText = "Enter new value..."
    ValueInput.BackgroundColor3 = Color3.fromRGB(30, 35, 70)
    ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueInput.Font = Enum.Font.Code
    ValueInput.TextSize = 20
    ValueInput.ClearTextOnFocus = false
    ValueInput.TextEditable = true
    ValueInput.TextXAlignment = Enum.TextXAlignment.Left
    ValueInput.ZIndex = 503
    ValueInput.Parent = NewCard
    Instance.new("UICorner", ValueInput).CornerRadius = UDim.new(0, 8)
    
    local IIPad = Instance.new("UIPadding")
    IIPad.PaddingLeft = UDim.new(0, 12)
    IIPad.Parent = ValueInput
    
    pcall(function()
        ValueInput.Text = tostring(instance.Value)
    end)
    
    -- ═══ صف الأزرار الرئيسية (Apply + Reset) ═══
    local MainBtns = Instance.new("Frame")
    MainBtns.Size = UDim2.new(1, -20, 0, 55)
    MainBtns.BackgroundTransparency = 1
    MainBtns.LayoutOrder = 3
    MainBtns.ZIndex = 502
    MainBtns.Parent = ScrollFrame
    
    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Size = UDim2.new(0.65, -5, 1, 0)
    ApplyBtn.Position = UDim2.new(0, 0, 0, 0)
    ApplyBtn.Text = "✅ APPLY VALUE"
    ApplyBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    ApplyBtn.TextSize = 18
    ApplyBtn.Font = Enum.Font.GothamBold
    ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    ApplyBtn.ZIndex = 503
    ApplyBtn.Parent = MainBtns
    Instance.new("UICorner", ApplyBtn).CornerRadius = UDim.new(0, 10)
    
    local ResetBtn = Instance.new("TextButton")
    ResetBtn.Size = UDim2.new(0.35, -5, 1, 0)
    ResetBtn.Position = UDim2.new(0.65, 5, 0, 0)
    ResetBtn.Text = "🔄 Reset"
    ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetBtn.TextSize = 15
    ResetBtn.Font = Enum.Font.GothamBold
    ResetBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    ResetBtn.ZIndex = 503
    ResetBtn.Parent = MainBtns
    Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 10)
    
    -- ═══ الميزات المتقدمة (خانات صغيرة) ═══
    local AdvancedTitle = Instance.new("TextLabel")
    AdvancedTitle.Size = UDim2.new(1, -20, 0, 30)
    AdvancedTitle.Text = "🔥 Advanced Features"
    AdvancedTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
    AdvancedTitle.TextSize = 16
    AdvancedTitle.Font = Enum.Font.GothamBold
    AdvancedTitle.TextXAlignment = Enum.TextXAlignment.Left
    AdvancedTitle.BackgroundTransparency = 1
    AdvancedTitle.LayoutOrder = 4
    AdvancedTitle.ZIndex = 502
    AdvancedTitle.Parent = ScrollFrame
    
    -- ═══ Grid للميزات ═══
    local FeaturesGrid = Instance.new("Frame")
    FeaturesGrid.Size = UDim2.new(1, -20, 0, 130)
    FeaturesGrid.BackgroundTransparency = 1
    FeaturesGrid.LayoutOrder = 5
    FeaturesGrid.ZIndex = 502
    FeaturesGrid.Parent = ScrollFrame
    
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -5, 0, 60)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = FeaturesGrid
    
    -- دالة إنشاء ميزة صغيرة
    local function CreateFeature(icon, name, description, defaultColor, order)
        local Feature = Instance.new("TextButton")
        Feature.LayoutOrder = order
        Feature.BackgroundColor3 = Color3.fromRGB(30, 35, 65)
        Feature.Text = ""
        Feature.AutoButtonColor = false
        Feature.ZIndex = 503
        Feature.Parent = FeaturesGrid
        Instance.new("UICorner", Feature).CornerRadius = UDim.new(0, 10)
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = defaultColor
        Stroke.Thickness = 1
        Stroke.Transparency = 0.6
        Stroke.Parent = Feature
        
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size = UDim2.new(0, 35, 1, 0)
        IconLbl.Position = UDim2.new(0, 5, 0, 0)
        IconLbl.Text = icon
        IconLbl.TextSize = 20
        IconLbl.BackgroundTransparency = 1
        IconLbl.ZIndex = 504
        IconLbl.Parent = Feature
        
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size = UDim2.new(1, -50, 0, 20)
        NameLbl.Position = UDim2.new(0, 42, 0, 8)
        NameLbl.Text = name
        NameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLbl.TextSize = 13
        NameLbl.Font = Enum.Font.GothamBold
        NameLbl.TextXAlignment = Enum.TextXAlignment.Left
        NameLbl.BackgroundTransparency = 1
        NameLbl.ZIndex = 504
        NameLbl.Parent = Feature
        
        local DescLbl = Instance.new("TextLabel")
        DescLbl.Size = UDim2.new(1, -50, 0, 15)
        DescLbl.Position = UDim2.new(0, 42, 0, 28)
        DescLbl.Text = description
        DescLbl.TextColor3 = Color3.fromRGB(150, 170, 200)
        DescLbl.TextSize = 10
        DescLbl.Font = Enum.Font.Gotham
        DescLbl.TextXAlignment = Enum.TextXAlignment.Left
        DescLbl.TextTruncate = Enum.TextTruncate.AtEnd
        DescLbl.BackgroundTransparency = 1
        DescLbl.ZIndex = 504
        DescLbl.Parent = Feature
        
        local Status = Instance.new("TextLabel")
        Status.Size = UDim2.new(1, -50, 0, 12)
        Status.Position = UDim2.new(0, 42, 1, -15)
        Status.Text = "OFF"
        Status.TextColor3 = Color3.fromRGB(150, 150, 150)
        Status.TextSize = 10
        Status.Font = Enum.Font.GothamBold
        Status.TextXAlignment = Enum.TextXAlignment.Left
        Status.BackgroundTransparency = 1
        Status.ZIndex = 504
        Status.Parent = Feature
        
        return Feature, Status, Stroke
    end
    
    -- ═══ Feature 1: FREEZE VALUE ═══
    local FreezeBtn, FreezeStatus, FreezeStroke = CreateFeature("🧊", "Freeze Value", "Prevent changes", Color3.fromRGB(100, 200, 255), 1)
    local freezeConnection = nil
    local frozenValue = nil
    
    FreezeBtn.MouseButton1Click:Connect(function()
        if _G.WiliFrozenValues[instance] then
            -- Unfreeze
            _G.WiliFrozenValues[instance] = nil
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
            FreezeBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 65)
            FreezeStatus.Text = "OFF"
            FreezeStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
            FreezeStroke.Transparency = 0.6
            ShowNotification(FullScreen, "❄️ Freeze DISABLED", Color3.fromRGB(150, 150, 150))
        else
            -- Freeze
            pcall(function()
                frozenValue = instance.Value
            end)
            _G.WiliFrozenValues[instance] = frozenValue
            
            freezeConnection = instance:GetPropertyChangedSignal("Value"):Connect(function()
                pcall(function()
                    if instance.Value ~= frozenValue then
                        instance.Value = frozenValue
                    end
                end)
            end)
            
            FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            FreezeStatus.Text = "🧊 FROZEN"
            FreezeStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
            FreezeStroke.Transparency = 0
            FreezeStroke.Thickness = 2
            ShowNotification(FullScreen, "🧊 Value FROZEN at: " .. tostring(frozenValue), Color3.fromRGB(100, 200, 255))
        end
    end)
    
    -- تحديث الحالة عند فتح النافذة
    if _G.WiliFrozenValues[instance] then
        frozenValue = _G.WiliFrozenValues[instance]
        FreezeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        FreezeStatus.Text = "🧊 FROZEN"
        FreezeStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
        FreezeStroke.Transparency = 0
        FreezeStroke.Thickness = 2
    end
    
    -- ═══ Feature 2: AUTO FIRE REMOTE ═══
    local AutoBtn, AutoStatus, AutoStroke = CreateFeature("🔄", "Auto Update", "Every 0.5s", Color3.fromRGB(255, 200, 50), 2)
    local autoConnection = nil
    local autoValue = nil
    
    AutoBtn.MouseButton1Click:Connect(function()
        if autoConnection then
            autoConnection:Disconnect()
            autoConnection = nil
            AutoBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 65)
            AutoStatus.Text = "OFF"
            AutoStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
            AutoStroke.Transparency = 0.6
            ShowNotification(FullScreen, "⏹️ Auto Update STOPPED", Color3.fromRGB(150, 150, 150))
        else
            autoValue = ValueInput.Text
            autoConnection = game:GetService("RunService").Heartbeat:Connect(function()
                pcall(function()
                    if instance:IsA("NumberValue") or instance:IsA("IntValue") then
                        local num = tonumber(autoValue)
                        if num then instance.Value = num end
                    elseif instance:IsA("BoolValue") then
                        instance.Value = (autoValue:lower() == "true")
                    else
                        instance.Value = autoValue
                    end
                end)
            end)
            AutoBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
            AutoStatus.Text = "🔄 RUNNING"
            AutoStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
            AutoStroke.Transparency = 0
            AutoStroke.Thickness = 2
            ShowNotification(FullScreen, "🔄 Auto Update ACTIVE", Color3.fromRGB(255, 200, 50))
        end
    end)
    
    -- ═══ Feature 3: BYPASS (Deep Override) ═══
    local BypassBtn, BypassStatus, BypassStroke = CreateFeature("⚡", "Deep Bypass", "Force override", Color3.fromRGB(255, 100, 150), 3)
    local bypassConnection = nil
    
    BypassBtn.MouseButton1Click:Connect(function()
        if bypassConnection then
            bypassConnection:Disconnect()
            bypassConnection = nil
            BypassBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 65)
            BypassStatus.Text = "OFF"
            BypassStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
            BypassStroke.Transparency = 0.6
            ShowNotification(FullScreen, "⏹️ Bypass STOPPED", Color3.fromRGB(150, 150, 150))
        else
            local targetVal = ValueInput.Text
            bypassConnection = game:GetService("RunService").RenderStepped:Connect(function()
                pcall(function()
                    -- محاولة setscriptable
                    if setscriptable then
                        setscriptable(instance, "Value", true)
                    end
                    
                    -- تعديل مباشر
                    if instance:IsA("NumberValue") or instance:IsA("IntValue") then
                        local num = tonumber(targetVal)
                        if num and instance.Value ~= num then 
                            instance.Value = num 
                        end
                    elseif instance:IsA("BoolValue") then
                        local b = (targetVal:lower() == "true")
                        if instance.Value ~= b then
                            instance.Value = b
                        end
                    else
                        if instance.Value ~= targetVal then
                            instance.Value = targetVal
                        end
                    end
                end)
            end)
            BypassBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
            BypassStatus.Text = "⚡ ACTIVE"
            BypassStatus.TextColor3 = Color3.fromRGB(255, 100, 150)
            BypassStroke.Transparency = 0
            BypassStroke.Thickness = 2
            ShowNotification(FullScreen, "⚡ DEEP BYPASS ACTIVATED!", Color3.fromRGB(255, 100, 150))
        end
    end)
    
    -- ═══ Feature 4: COPY VALUE ═══
    local CopyBtn, CopyStatus, CopyStroke = CreateFeature("📋", "Copy Value", "To clipboard", Color3.fromRGB(150, 200, 255), 4)
    CopyStatus.Text = "Ready"
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if CopyToClipboard(tostring(instance.Value)) then
                CopyStatus.Text = "✅ COPIED"
                CopyStatus.TextColor3 = Color3.fromRGB(0, 255, 136)
                ShowNotification(FullScreen, "📋 Value copied!", Color3.fromRGB(0, 200, 100))
                wait(1.5)
                CopyStatus.Text = "Ready"
                CopyStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
    end)
    
    -- ═══ Quick Values (للأرقام) ═══
    if instance:IsA("NumberValue") or instance:IsA("IntValue") then
        local QuickTitle = Instance.new("TextLabel")
        QuickTitle.Size = UDim2.new(1, -20, 0, 25)
        QuickTitle.Text = "⚡ Quick Values"
        QuickTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
        QuickTitle.TextSize = 14
        QuickTitle.Font = Enum.Font.GothamBold
        QuickTitle.TextXAlignment = Enum.TextXAlignment.Left
        QuickTitle.BackgroundTransparency = 1
        QuickTitle.LayoutOrder = 6
        QuickTitle.ZIndex = 502
        QuickTitle.Parent = ScrollFrame
        
        local QuickFrame = Instance.new("Frame")
        QuickFrame.Size = UDim2.new(1, -20, 0, 45)
        QuickFrame.BackgroundTransparency = 1
        QuickFrame.LayoutOrder = 7
        QuickFrame.ZIndex = 502
        QuickFrame.Parent = ScrollFrame
        
        local QLayout = Instance.new("UIListLayout")
        QLayout.FillDirection = Enum.FillDirection.Horizontal
        QLayout.Padding = UDim.new(0, 8)
        QLayout.Parent = QuickFrame
        
        local quickValues = {"0", "1", "100", "999", "9999", "999999"}
        for _, val in ipairs(quickValues) do
            local QBtn = Instance.new("TextButton")
            QBtn.Size = UDim2.new(0, 95, 1, 0)
            QBtn.Text = val
            QBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            QBtn.TextSize = 14
            QBtn.Font = Enum.Font.GothamBold
            QBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
            QBtn.ZIndex = 503
            QBtn.Parent = QuickFrame
            Instance.new("UICorner", QBtn).CornerRadius = UDim.new(0, 8)
            
            QBtn.MouseButton1Click:Connect(function()
                ValueInput.Text = val
            end)
        end
    end
    
    -- ═══ BoolValue Buttons ═══
    if instance:IsA("BoolValue") then
        local BoolTitle = Instance.new("TextLabel")
        BoolTitle.Size = UDim2.new(1, -20, 0, 25)
        BoolTitle.Text = "☑️ Quick Toggle"
        BoolTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
        BoolTitle.TextSize = 14
        BoolTitle.Font = Enum.Font.GothamBold
        BoolTitle.TextXAlignment = Enum.TextXAlignment.Left
        BoolTitle.BackgroundTransparency = 1
        BoolTitle.LayoutOrder = 6
        BoolTitle.ZIndex = 502
        BoolTitle.Parent = ScrollFrame
        
        local BoolFrame = Instance.new("Frame")
        BoolFrame.Size = UDim2.new(1, -20, 0, 60)
        BoolFrame.BackgroundTransparency = 1
        BoolFrame.LayoutOrder = 7
        BoolFrame.ZIndex = 502
        BoolFrame.Parent = ScrollFrame
        
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(0.5, -5, 1, 0)
        TBtn.Position = UDim2.new(0, 0, 0, 0)
        TBtn.Text = "✅ TRUE"
        TBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TBtn.TextSize = 20
        TBtn.Font = Enum.Font.GothamBold
        TBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        TBtn.ZIndex = 503
        TBtn.Parent = BoolFrame
        Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 10)
        
        local FBtn = Instance.new("TextButton")
        FBtn.Size = UDim2.new(0.5, -5, 1, 0)
        FBtn.Position = UDim2.new(0.5, 5, 0, 0)
        FBtn.Text = "❌ FALSE"
        FBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FBtn.TextSize = 20
        FBtn.Font = Enum.Font.GothamBold
        FBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
        FBtn.ZIndex = 503
        FBtn.Parent = BoolFrame
        Instance.new("UICorner", FBtn).CornerRadius = UDim.new(0, 10)
        
        TBtn.MouseButton1Click:Connect(function() ValueInput.Text = "true" end)
        FBtn.MouseButton1Click:Connect(function() ValueInput.Text = "false" end)
    end
    
    -- ═══ Live Update للقيمة الحالية ═══
    local liveUpdate = instance:GetPropertyChangedSignal("Value"):Connect(function()
        UpdateCurrentValue()
    end)
    
    -- ═══ Apply Button Logic ═══
    ApplyBtn.MouseButton1Click:Connect(function()
        local newVal = ValueInput.Text
        local success = false
        
        pcall(function()
            if instance:IsA("NumberValue") or instance:IsA("IntValue") then
                local num = tonumber(newVal)
                if num then
                    instance.Value = num
                    success = true
                end
            elseif instance:IsA("BoolValue") then
                if newVal:lower() == "true" then
                    instance.Value = true
                    success = true
                elseif newVal:lower() == "false" then
                    instance.Value = false
                    success = true
                end
            elseif instance:IsA("StringValue") then
                instance.Value = newVal
                success = true
            end
        end)
        
        if success then
            -- تحديث القيمة المجمدة
            if _G.WiliFrozenValues[instance] then
                pcall(function()
                    frozenValue = instance.Value
                    _G.WiliFrozenValues[instance] = frozenValue
                end)
            end
            ShowNotification(FullScreen, "✅ Value APPLIED!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "❌ Invalid value type", Color3.fromRGB(200, 50, 70))
        end
    end)
    
    ResetBtn.MouseButton1Click:Connect(function()
        pcall(function()
            ValueInput.Text = tostring(instance.Value)
        end)
        ShowNotification(FullScreen, "🔄 Reset done", Color3.fromRGB(255, 200, 50))
    end)
    
    -- ═══ تحديث ScrollingFrame Size ═══
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
    end)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
    
    -- ═══ تنظيف عند الخروج ═══
    FullScreen.AncestryChanged:Connect(function()
        if not FullScreen.Parent then
            if liveUpdate then liveUpdate:Disconnect() end
            if autoConnection then autoConnection:Disconnect() end
            if bypassConnection then bypassConnection:Disconnect() end
            -- Freeze يبقى نشطاً حتى بعد الخروج!
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- Code Editor (محسن)
-- ═══════════════════════════════════════════════════════
function FileViewer.OpenCodeEditor(mainParent, instance, sourceData, onExit)
    local FullScreen = Instance.new("Frame")
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent
    
    -- الشريط العلوي
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Position = UDim2.new(0, 8, 0.5, -20)
    Icon.Text = "📜"
    Icon.TextSize = 24
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 502
    Icon.Parent = TopBar
    
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Size = UDim2.new(0, 180, 0, 22)
    ScriptName.Position = UDim2.new(0, 55, 0, 6)
    ScriptName.Text = instance.Name
    ScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptName.TextSize = 15
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.TextXAlignment = Enum.TextXAlignment.Left
    ScriptName.TextTruncate = Enum.TextTruncate.AtEnd
    ScriptName.BackgroundTransparency = 1
    ScriptName.ZIndex = 502
    ScriptName.Parent = TopBar
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(0, 280, 0, 18)
    InfoLabel.Position = UDim2.new(0, 55, 0, 28)
    InfoLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    InfoLabel.TextSize = 11
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.ZIndex = 502
    InfoLabel.Parent = TopBar
    
    local function CountLines(text)
        local count = 1
        for _ in text:gmatch("\n") do count = count + 1 end
        return count
    end
    
    -- تحديد نوع السكريبت
    local canModify = false
    local scriptType = "Unknown"
    
    pcall(function()
        if instance:IsA("LocalScript") then
            scriptType = "LocalScript ✅"
            canModify = true
        elseif instance:IsA("ModuleScript") then
            scriptType = "ModuleScript ✅"
            canModify = true
        elseif instance:IsA("Script") then
            scriptType = "ServerScript ❌"
            canModify = false
        end
    end)
    
    InfoLabel.Text = scriptType .. " • " .. CountLines(sourceData.source) .. " lines"
    
    -- الأزرار العلوية (مبسطة)
    local PasteBtn = Instance.new("TextButton")
    PasteBtn.Size = UDim2.new(0, 70, 0, 36)
    PasteBtn.Position = UDim2.new(1, -390, 0.5, -18)
    PasteBtn.Text = "📥"
    PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasteBtn.TextSize = 20
    PasteBtn.Font = Enum.Font.GothamBold
    PasteBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    PasteBtn.ZIndex = 502
    PasteBtn.Parent = TopBar
    Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 8)
    
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 70, 0, 36)
    CopyBtn.Position = UDim2.new(1, -315, 0.5, -18)
    CopyBtn.Text = "📋"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextSize = 20
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 152, 219)
    CopyBtn.ZIndex = 502
    CopyBtn.Parent = TopBar
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 8)
    
    local RunBtn = Instance.new("TextButton")
    RunBtn.Size = UDim2.new(0, 70, 0, 36)
    RunBtn.Position = UDim2.new(1, -240, 0.5, -18)
    RunBtn.Text = "▶️ Run"
    RunBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    RunBtn.TextSize = 13
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    RunBtn.ZIndex = 502
    RunBtn.Parent = TopBar
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 8)
    
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0, 85, 0, 36)
    SaveBtn.Position = UDim2.new(1, -165, 0.5, -18)
    SaveBtn.Text = "💾 Save"
    SaveBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    SaveBtn.TextSize = 14
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    SaveBtn.ZIndex = 502
    SaveBtn.Parent = TopBar
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
    
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 65, 0, 36)
    ExitBtn.Position = UDim2.new(1, -75, 0.5, -18)
    ExitBtn.Text = "✕"
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.TextSize = 18
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    -- منطقة الكود (البسيطة - بدون ScrollingFrame معقد)
    local CodeContainer = Instance.new("Frame")
    CodeContainer.Size = UDim2.new(1, -20, 1, -75)
    CodeContainer.Position = UDim2.new(0, 10, 0, 65)
    CodeContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    CodeContainer.BorderSizePixel = 0
    CodeContainer.ZIndex = 501
    CodeContainer.Parent = FullScreen
    Instance.new("UICorner", CodeContainer).CornerRadius = UDim.new(0, 12)
    
    local CScroll = Instance.new("ScrollingFrame")
    CScroll.Size = UDim2.new(1, -10, 1, -10)
    CScroll.Position = UDim2.new(0, 5, 0, 5)
    CScroll.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    CScroll.BorderSizePixel = 0
    CScroll.ScrollBarThickness = 8
    CScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    CScroll.CanvasSize = UDim2.new(0, 0, 0, 5000)
    CScroll.ZIndex = 502
    CScroll.Parent = CodeContainer
    Instance.new("UICorner", CScroll).CornerRadius = UDim.new(0, 10)
    
    local CodeBox = Instance.new("TextBox")
    CodeBox.Size = UDim2.new(1, -20, 0, 5000)
    CodeBox.Position = UDim2.new(0, 10, 0, 10)
    CodeBox.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
    CodeBox.TextColor3 = Color3.fromRGB(220, 230, 255)
    CodeBox.Font = Enum.Font.Code
    CodeBox.TextSize = 14
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.TextWrapped = true
    CodeBox.ClearTextOnFocus = false
    CodeBox.MultiLine = true
    CodeBox.TextEditable = true
    CodeBox.Text = sourceData.source or "-- No source available"
    CodeBox.ZIndex = 503
    CodeBox.Parent = CScroll
    
    if not sourceData.success then
        CodeBox.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
    
    -- تحديث الحجم بشكل آمن
    local function UpdateSize()
        local textBounds = CodeBox.TextBounds
        local newHeight = math.max(textBounds.Y + 100, 1000)
        CodeBox.Size = UDim2.new(1, -20, 0, newHeight)
        CScroll.CanvasSize = UDim2.new(0, 0, 0, newHeight + 40)
        InfoLabel.Text = scriptType .. " • " .. CountLines(CodeBox.Text) .. " lines"
    end
    
    UpdateSize()
    
    local originalText = sourceData.source or ""
    local isModified = false
    
    CodeBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSize()
        if CodeBox.Text ~= originalText then
            isModified = true
            SaveBtn.Text = "💾 Save*"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        else
            isModified = false
            SaveBtn.Text = "💾 Save"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)
    
    -- الأزرار
    CopyBtn.MouseButton1Click:Connect(function()
        if CopyToClipboard(CodeBox.Text) then
            ShowNotification(FullScreen, "✅ Copied to clipboard!", Color3.fromRGB(0, 200, 100))
        end
    end)
    
    PasteBtn.MouseButton1Click:Connect(function()
        local pastedText = PasteFromClipboard()
        if pastedText and pastedText ~= "" then
            CodeBox.Text = pastedText
            ShowNotification(FullScreen, "✅ Pasted!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "⚠️ Clipboard empty", Color3.fromRGB(255, 200, 50))
        end
    end)
    
    RunBtn.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            local func = loadstring(CodeBox.Text)
            if func then
                func()
            end
        end)
        
        if success then
            ShowNotification(FullScreen, "✅ Code executed!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "❌ " .. tostring(err):sub(1, 80), Color3.fromRGB(200, 50, 70))
        end
    end)
    
    SaveBtn.MouseButton1Click:Connect(function()
        if not canModify then
            ShowNotification(FullScreen, "⚠️ Use Run for Server Scripts", Color3.fromRGB(255, 200, 50))
            return
        end
        
        local r = FileScanner.SetSource(instance, CodeBox.Text)
        if r.success then
            ShowNotification(FullScreen, "✅ Saved via " .. r.method, Color3.fromRGB(0, 200, 100))
            originalText = CodeBox.Text
            isModified = false
            SaveBtn.Text = "💾 Save"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        else
            ShowNotification(FullScreen, "❌ " .. r.error, Color3.fromRGB(200, 50, 70))
        end
    end)
    
    ExitBtn.MouseButton1Click:Connect(function()
        if isModified then
            local Conf = Instance.new("Frame")
            Conf.Size = UDim2.new(1, 0, 1, 0)
            Conf.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Conf.BackgroundTransparency = 0.5
            Conf.ZIndex = 700
            Conf.Parent = FullScreen
            
            local D = Instance.new("Frame")
            D.Size = UDim2.new(0, 350, 0, 180)
            D.Position = UDim2.new(0.5, -175, 0.5, -90)
            D.BackgroundColor3 = Color3.fromRGB(25, 30, 60)
            D.ZIndex = 701
            D.Parent = Conf
            Instance.new("UICorner", D).CornerRadius = UDim.new(0, 15)
            
            local T = Instance.new("TextLabel")
            T.Size = UDim2.new(1, -20, 0, 30)
            T.Position = UDim2.new(0, 10, 0, 20)
            T.Text = "⚠️ Unsaved Changes"
            T.TextColor3 = Color3.fromRGB(255, 200, 50)
            T.TextSize = 18
            T.Font = Enum.Font.GothamBold
            T.BackgroundTransparency = 1
            T.ZIndex = 702
            T.Parent = D
            
            local SE = Instance.new("TextButton")
            SE.Size = UDim2.new(0, 100, 0, 40)
            SE.Position = UDim2.new(0, 15, 1, -55)
            SE.Text = "💾 Save"
            SE.TextColor3 = Color3.fromRGB(11, 13, 26)
            SE.TextSize = 13
            SE.Font = Enum.Font.GothamBold
            SE.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            SE.ZIndex = 702
            SE.Parent = D
            Instance.new("UICorner", SE).CornerRadius = UDim.new(0, 8)
            
            local DC = Instance.new("TextButton")
            DC.Size = UDim2.new(0, 100, 0, 40)
            DC.Position = UDim2.new(0.5, -50, 1, -55)
            DC.Text = "🗑️ Discard"
            DC.TextColor3 = Color3.fromRGB(255, 255, 255)
            DC.TextSize = 13
            DC.Font = Enum.Font.GothamBold
            DC.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            DC.ZIndex = 702
            DC.Parent = D
            Instance.new("UICorner", DC).CornerRadius = UDim.new(0, 8)
            
            local CN = Instance.new("TextButton")
            CN.Size = UDim2.new(0, 100, 0, 40)
            CN.Position = UDim2.new(1, -115, 1, -55)
            CN.Text = "Cancel"
            CN.TextColor3 = Color3.fromRGB(255, 255, 255)
            CN.TextSize = 13
            CN.Font = Enum.Font.GothamBold
            CN.BackgroundColor3 = Color3.fromRGB(80, 90, 130)
            CN.ZIndex = 702
            CN.Parent = D
            Instance.new("UICorner", CN).CornerRadius = UDim.new(0, 8)
            
            SE.MouseButton1Click:Connect(function()
                if canModify then
                    FileScanner.SetSource(instance, CodeBox.Text)
                end
                FullScreen:Destroy()
                if onExit then onExit() end
            end)
            
            DC.MouseButton1Click:Connect(function()
                FullScreen:Destroy()
                if onExit then onExit() end
            end)
            
            CN.MouseButton1Click:Connect(function()
                Conf:Destroy()
            end)
        else
            FullScreen:Destroy()
            if onExit then onExit() end
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- الواجهة الأساسية
-- ═══════════════════════════════════════════════════════
function FileViewer.Open(mainParent, instance, onClose)
    local info = FileScanner.GetInfo(instance)
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "FileViewerOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.ZIndex = 90
    Overlay.Parent = mainParent

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0.96, 0, 0.92, 0)
    Window.Position = UDim2.new(0.02, 0, 0.04, 0)
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

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    Header.ZIndex = 92
    Header.Parent = Window

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 55, 0, 55)
    IconLabel.Position = UDim2.new(0, 10, 0.5, -27)
    IconLabel.Text = info.Icon
    IconLabel.TextSize = 36
    IconLabel.BackgroundTransparency = 1
    IconLabel.ZIndex = 93
    IconLabel.Parent = Header

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -140, 0, 25)
    NameLabel.Position = UDim2.new(0, 70, 0, 12)
    NameLabel.Text = info.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 20
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.BackgroundTransparency = 1
    NameLabel.ZIndex = 93
    NameLabel.Parent = Header

    local ClassLabel = Instance.new("TextLabel")
    ClassLabel.Size = UDim2.new(1, -140, 0, 18)
    ClassLabel.Position = UDim2.new(0, 70, 0, 40)
    ClassLabel.Text = info.ClassName .. " • " .. info.Descendants .. " items"
    ClassLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    ClassLabel.TextSize = 13
    ClassLabel.Font = Enum.Font.Gotham
    ClassLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClassLabel.BackgroundTransparency = 1
    ClassLabel.ZIndex = 93
    ClassLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 45, 0, 45)
    CloseBtn.Position = UDim2.new(1, -55, 0.5, -22)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    CloseBtn.ZIndex = 93
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

    CloseBtn.MouseButton1Click:Connect(function()
        Overlay:Destroy()
        if onClose then onClose() end
    end)

    local hasBigButton = false
    local buttonColor = Color3.fromRGB(0, 255, 136)
    local buttonText = ""
    local buttonAction = nil

    if info.IsScript then
        hasBigButton = true
        buttonColor = Color3.fromRGB(0, 255, 136)
        buttonText = "📜  VIEW & EDIT CODE"
        buttonAction = function(overlay)
            local sourceData = FileScanner.GetSource(instance)
            overlay.Visible = false
            FileViewer.OpenCodeEditor(mainParent, instance, sourceData, function()
                overlay.Visible = true
            end)
        end
    elseif instance:IsA("Sound") then
        hasBigButton = true
        buttonColor = Color3.fromRGB(255, 200, 50)
        buttonText = "🔊  SOUND EDITOR"
        buttonAction = function(overlay)
            overlay.Visible = false
            local SoundEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/SoundEditor.lua", true))()
            SoundEditor.Open(mainParent, instance, function()
                overlay.Visible = true
            end)
        end
    elseif instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        hasBigButton = true
        buttonColor = Color3.fromRGB(255, 100, 150)
        buttonText = "🖼️  IMAGE EDITOR"
        buttonAction = function(overlay)
            overlay.Visible = false
            local ImageEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/ImageEditor.lua", true))()
            ImageEditor.Open(mainParent, instance, function()
                overlay.Visible = true
            end)
        end
    elseif instance:IsA("ValueBase") then
        -- زر لتعديل الـ Values (NumberValue, StringValue, BoolValue, IntValue)
        hasBigButton = true
        buttonColor = Color3.fromRGB(100, 200, 255)
        buttonText = "⚙️  EDIT VALUE"
        buttonAction = function(overlay)
            overlay.Visible = false
            FileViewer.OpenValueEditor(mainParent, instance, function()
                overlay.Visible = true
            end)
        end
    end

    if hasBigButton then
        local BigBtn = Instance.new("TextButton")
        BigBtn.Size = UDim2.new(1, -30, 0, 85)
        BigBtn.Position = UDim2.new(0, 15, 0, 85)
        BigBtn.Text = buttonText
        BigBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
        BigBtn.TextSize = 24
        BigBtn.Font = Enum.Font.GothamBold
        BigBtn.BackgroundColor3 = buttonColor
        BigBtn.AutoButtonColor = false
        BigBtn.ZIndex = 200
        BigBtn.Parent = Window
        Instance.new("UICorner", BigBtn).CornerRadius = UDim.new(0, 15)

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = buttonColor
        BStroke.Thickness = 3
        BStroke.Parent = BigBtn

        spawn(function()
            while BigBtn.Parent do
                TweenService:Create(BStroke, TweenInfo.new(1), {Thickness = 5, Transparency = 0.4}):Play()
                wait(1)
                TweenService:Create(BStroke, TweenInfo.new(1), {Thickness = 3, Transparency = 0}):Play()
                wait(1)
            end
        end)

        BigBtn.MouseButton1Click:Connect(function()
            if buttonAction then
                buttonAction(Overlay)
            end
        end)
    end

    local ContentArea = Instance.new("Frame")
    if hasBigButton then
        ContentArea.Size = UDim2.new(1, -20, 1, -260)
        ContentArea.Position = UDim2.new(0, 10, 0, 185)
    else
        ContentArea.Size = UDim2.new(1, -20, 1, -160)
        ContentArea.Position = UDim2.new(0, 10, 0, 80)
    end
    ContentArea.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.ZIndex = 92
    ContentArea.Parent = Window
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 10)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    TabBar.ZIndex = 93
    TabBar.Parent = ContentArea
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingLeft = UDim.new(0, 5)
    TabPad.PaddingTop = UDim.new(0, 5)
    TabPad.PaddingBottom = UDim.new(0, 5)
    TabPad.Parent = TabBar

    local tabs = {}
    local function CreateTab(name, icon, order)
        local Tab = Instance.new("TextButton")
        Tab.Size = UDim2.new(0, 120, 1, 0)
        Tab.Text = icon .. " " .. name
        Tab.TextColor3 = Color3.fromRGB(150, 170, 200)
        Tab.TextSize = 13
        Tab.Font = Enum.Font.GothamBold
        Tab.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Tab.LayoutOrder = order
        Tab.ZIndex = 94
        Tab.Parent = TabBar
        Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 8)
        return Tab
    end

    local function SwitchTab(tabName)
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

    local InfoContent = Instance.new("ScrollingFrame")
    InfoContent.Size = UDim2.new(1, -10, 1, -50)
    InfoContent.Position = UDim2.new(0, 5, 0, 45)
    InfoContent.BackgroundTransparency = 1
    InfoContent.ScrollBarThickness = 4
    InfoContent.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    InfoContent.Visible = false
    InfoContent.ZIndex = 93
    InfoContent.Parent = ContentArea

    local InfoLayout = Instance.new("UIListLayout")
    InfoLayout.Padding = UDim.new(0, 8)
    InfoLayout.Parent = InfoContent

    local InfoPad = Instance.new("UIPadding")
    InfoPad.PaddingTop = UDim.new(0, 10)
    InfoPad.PaddingLeft = UDim.new(0, 10)
    InfoPad.PaddingRight = UDim.new(0, 10)
    InfoPad.Parent = InfoContent

    local function AddInfoRow(key, value, order)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 55)
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
        Value.Size = UDim2.new(1, -10, 0, 25)
        Value.Position = UDim2.new(0, 10, 0, 25)
        Value.Text = tostring(value)
        Value.TextColor3 = Color3.fromRGB(255, 255, 255)
        Value.TextSize = 14
        Value.Font = Enum.Font.Gotham
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.BackgroundTransparency = 1
        Value.ZIndex = 95
        Value.Parent = Row
    end

    AddInfoRow("📛 Name", info.Name, 1)
    AddInfoRow("🏷️ Class", info.ClassName, 2)
    AddInfoRow("📁 Full Path", info.FullName, 3)
    AddInfoRow("👨‍👦 Parent", info.Parent, 4)
    AddInfoRow("📂 Children", info.Children, 5)
    AddInfoRow("🌳 Descendants", info.Descendants, 6)
    
    if info.IsScript then
        AddInfoRow("📜 Script", "Yes (" .. info.SourceLength .. " chars)", 7)
    end

    local propOrder = 20
    local function TryProp(name)
        pcall(function()
            local v = instance[name]
            if v ~= nil then
                AddInfoRow("⚙️ " .. name, tostring(v), propOrder)
                propOrder = propOrder + 1
            end
        end)
    end
    
    for _, prop in ipairs({"Position", "Size", "Anchored", "Transparency", "Material", "Color", "Value", "Text", "SoundId", "Volume", "Image", "Enabled", "Visible"}) do
        TryProp(prop)
    end

    InfoContent.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 20)

    local ChildrenContent = Instance.new("ScrollingFrame")
    ChildrenContent.Size = UDim2.new(1, -10, 1, -50)
    ChildrenContent.Position = UDim2.new(0, 5, 0, 45)
    ChildrenContent.BackgroundTransparency = 1
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
        local cInfo = FileScanner.GetInfo(child)
        local ChItem = Instance.new("TextButton")
        ChItem.Size = UDim2.new(1, -10, 0, 50)
        ChItem.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        ChItem.Text = ""
        ChItem.LayoutOrder = i
        ChItem.ZIndex = 94
        ChItem.Parent = ChildrenContent
        Instance.new("UICorner", ChItem).CornerRadius = UDim.new(0, 8)

        local CIcon = Instance.new("TextLabel")
        CIcon.Size = UDim2.new(0, 40, 1, 0)
        CIcon.Position = UDim2.new(0, 5, 0, 0)
        CIcon.Text = cInfo.Icon
        CIcon.TextSize = 22
        CIcon.BackgroundTransparency = 1
        CIcon.ZIndex = 95
        CIcon.Parent = ChItem

        local CName = Instance.new("TextLabel")
        CName.Size = UDim2.new(1, -110, 0, 20)
        CName.Position = UDim2.new(0, 50, 0, 5)
        CName.Text = cInfo.Name
        CName.TextColor3 = Color3.fromRGB(255, 255, 255)
        CName.TextSize = 14
        CName.Font = Enum.Font.GothamBold
        CName.TextXAlignment = Enum.TextXAlignment.Left
        CName.BackgroundTransparency = 1
        CName.ZIndex = 95
        CName.Parent = ChItem

        local CClass = Instance.new("TextLabel")
        CClass.Size = UDim2.new(1, -110, 0, 15)
        CClass.Position = UDim2.new(0, 50, 0, 27)
        CClass.Text = cInfo.ClassName .. " • " .. cInfo.Children .. " items"
        CClass.TextColor3 = Color3.fromRGB(150, 170, 200)
        CClass.TextSize = 11
        CClass.Font = Enum.Font.Gotham
        CClass.TextXAlignment = Enum.TextXAlignment.Left
        CClass.BackgroundTransparency = 1
        CClass.ZIndex = 95
        CClass.Parent = ChItem

        ChItem.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            FileViewer.Open(mainParent, child, onClose)
        end)
    end

    ChildrenContent.CanvasSize = UDim2.new(0, 0, 0, ChLayout.AbsoluteContentSize.Y + 20)

    tabs["Info"] = {button = CreateTab("Info", "ℹ️", 1), content = InfoContent}
    if info.Children > 0 then
        tabs["Children"] = {button = CreateTab("Children", "📂", 2), content = ChildrenContent}
    end

    for name, data in pairs(tabs) do
        data.button.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Info")

    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, -20, 0, 50)
    BottomBar.Position = UDim2.new(0, 10, 1, -60)
    BottomBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    BottomBar.ZIndex = 92
    BottomBar.Parent = Window
    Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 10)

    local BLayout = Instance.new("UIListLayout")
    BLayout.FillDirection = Enum.FillDirection.Horizontal
    BLayout.Padding = UDim.new(0, 5)
    BLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BLayout.Parent = BottomBar

    local function ActionBtn(text, icon, color, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 100, 0, 38)
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

    ActionBtn("Copy Path", "🔗", Color3.fromRGB(100, 100, 200), function()
        if CopyToClipboard(info.FullName) then
            ShowNotification(Window, "✅ Path copied!", Color3.fromRGB(0, 200, 100))
        end
    end)

    ActionBtn("Clone", "📑", Color3.fromRGB(200, 150, 50), function()
        local success = pcall(function()
            local clone = instance:Clone()
            clone.Parent = instance.Parent
            clone.Name = instance.Name .. "_Copy"
        end)
        if success then
            ShowNotification(Window, "✅ Cloned!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(Window, "❌ Failed", Color3.fromRGB(200, 50, 70))
        end
    end)

    ActionBtn("Delete", "🗑️", Color3.fromRGB(200, 50, 70), function()
        local success = pcall(function() instance:Destroy() end)
        if success then
            ShowNotification(Window, "✅ Deleted!", Color3.fromRGB(0, 200, 100))
            wait(1)
            Overlay:Destroy()
            if onClose then onClose() end
        else
            ShowNotification(Window, "❌ Failed", Color3.fromRGB(200, 50, 70))
        end
    end)
end

return FileViewer
