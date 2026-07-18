local FileViewer = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

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

local function ShowNotification(parent, message, color)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 280, 0, 50)
    Notif.Position = UDim2.new(0.5, -140, 0, -60)
    Notif.BackgroundColor3 = color or Color3.fromRGB(0, 200, 100)
    Notif.ZIndex = 300
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
    Label.ZIndex = 301
    Label.Parent = Notif
    
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -140, 0, 10)
    }):Play()
    
    spawn(function()
        wait(2.5)
        TweenService:Create(Notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -140, 0, -60)
        }):Play()
        wait(0.3)
        Notif:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════
-- ⭐ المحرر الكامل (Fullscreen Code Editor)
-- ═══════════════════════════════════════════════════════
function FileViewer.OpenCodeEditor(mainParent, instance, sourceData, onExit)
    -- خلفية سوداء كاملة
    local FullScreen = Instance.new("Frame")
    FullScreen.Name = "CodeEditorFullscreen"
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.Position = UDim2.new(0, 0, 0, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
    FullScreen.BorderSizePixel = 0
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent
    
    -- ═══ الشريط العلوي ═══
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen
    
    local TopStroke = Instance.new("Frame")
    TopStroke.Size = UDim2.new(1, 0, 0, 2)
    TopStroke.Position = UDim2.new(0, 0, 1, 0)
    TopStroke.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    TopStroke.BorderSizePixel = 0
    TopStroke.ZIndex = 502
    TopStroke.Parent = TopBar
    
    -- الأيقونة
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 45, 0, 45)
    Icon.Position = UDim2.new(0, 10, 0.5, -22)
    Icon.Text = "📜"
    Icon.TextSize = 28
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 502
    Icon.Parent = TopBar
    
    -- اسم السكريبت
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Size = UDim2.new(0.5, 0, 0, 22)
    ScriptName.Position = UDim2.new(0, 60, 0, 8)
    ScriptName.Text = instance.Name
    ScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptName.TextSize = 16
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.TextXAlignment = Enum.TextXAlignment.Left
    ScriptName.TextTruncate = Enum.TextTruncate.AtEnd
    ScriptName.BackgroundTransparency = 1
    ScriptName.ZIndex = 502
    ScriptName.Parent = TopBar
    
    -- معلومات
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(0.5, 0, 0, 18)
    InfoLabel.Position = UDim2.new(0, 60, 0, 30)
    InfoLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.ZIndex = 502
    InfoLabel.Parent = TopBar
    
    -- حساب عدد الأسطر
    local function CountLines(text)
        local count = 1
        for _ in text:gmatch("\n") do count = count + 1 end
        return count
    end
    
    local totalLines = CountLines(sourceData.source)
    local methodText = ""
    if sourceData.method == "direct" then
        methodText = "✅ Direct"
    elseif sourceData.method == "decompile" then
        methodText = "🔓 Decompiled"
    elseif sourceData.method == "bytecode" then
        methodText = "⚡ Bytecode"
    else
        methodText = "🔒 Protected"
    end
    
    InfoLabel.Text = instance.ClassName .. " • " .. totalLines .. " lines • " .. methodText
    
    -- زر النسخ (في الأعلى)
    local CopyTopBtn = Instance.new("TextButton")
    CopyTopBtn.Size = UDim2.new(0, 90, 0, 38)
    CopyTopBtn.Position = UDim2.new(1, -300, 0.5, -19)
    CopyTopBtn.Text = "📋 Copy"
    CopyTopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyTopBtn.TextSize = 13
    CopyTopBtn.Font = Enum.Font.GothamBold
    CopyTopBtn.BackgroundColor3 = Color3.fromRGB(0, 152, 219)
    CopyTopBtn.ZIndex = 502
    CopyTopBtn.Parent = TopBar
    Instance.new("UICorner", CopyTopBtn).CornerRadius = UDim.new(0, 8)
    
    -- زر الحفظ (بارز)
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0, 90, 0, 38)
    SaveBtn.Position = UDim2.new(1, -200, 0.5, -19)
    SaveBtn.Text = "💾 Save"
    SaveBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    SaveBtn.TextSize = 14
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    SaveBtn.ZIndex = 502
    SaveBtn.Parent = TopBar
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
    
    -- زر الخروج
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 90, 0, 38)
    ExitBtn.Position = UDim2.new(1, -100, 0.5, -19)
    ExitBtn.Text = "✕ Exit"
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.TextSize = 14
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    -- ═══ منطقة الكود (Fullscreen) ═══
    local CodeScroll = Instance.new("ScrollingFrame")
    CodeScroll.Size = UDim2.new(1, 0, 1, -55)
    CodeScroll.Position = UDim2.new(0, 0, 0, 55)
    CodeScroll.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    CodeScroll.BorderSizePixel = 0
    CodeScroll.ScrollBarThickness = 8
    CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    CodeScroll.ZIndex = 501
    CodeScroll.Parent = FullScreen
    
    -- صندوق الكود
    local CodeBox = Instance.new("TextBox")
    CodeBox.Size = UDim2.new(1, -20, 0, 5000)
    CodeBox.Position = UDim2.new(0, 10, 0, 10)
    CodeBox.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    CodeBox.TextColor3 = Color3.fromRGB(200, 220, 255)
    CodeBox.Font = Enum.Font.Code
    CodeBox.TextSize = 15
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.TextWrapped = true
    CodeBox.ClearTextOnFocus = false
    CodeBox.MultiLine = true
    CodeBox.Text = sourceData.source
    CodeBox.ZIndex = 502
    CodeBox.Parent = CodeScroll
    
    if sourceData.method == "none" or not sourceData.success then
        CodeBox.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
    
    -- تحديث الحجم تلقائياً
    local function UpdateSize()
        local bounds = CodeBox.TextBounds
        local newHeight = math.max(bounds.Y + 100, 1000)
        CodeBox.Size = UDim2.new(1, -20, 0, newHeight)
        CodeScroll.CanvasSize = UDim2.new(0, 0, 0, newHeight + 50)
        
        -- تحديث عداد الأسطر
        local lines = CountLines(CodeBox.Text)
        InfoLabel.Text = instance.ClassName .. " • " .. lines .. " lines • " .. methodText
    end
    
    UpdateSize()
    CodeBox:GetPropertyChangedSignal("Text"):Connect(UpdateSize)
    CodeBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSize)
    
    -- ═══ حالة الحفظ ═══
    local isModified = false
    local originalText = sourceData.source
    
    CodeBox:GetPropertyChangedSignal("Text"):Connect(function()
        if CodeBox.Text ~= originalText then
            isModified = true
            SaveBtn.Text = "💾 Save *"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        else
            isModified = false
            SaveBtn.Text = "💾 Save"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)
    
    -- ═══ زر النسخ ═══
    CopyTopBtn.MouseButton1Click:Connect(function()
        if CopyToClipboard(CodeBox.Text) then
            ShowNotification(FullScreen, "✅ Code copied to clipboard!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "❌ Copy failed", Color3.fromRGB(200, 50, 70))
        end
    end)
    
    -- ═══ زر الحفظ ═══
    SaveBtn.MouseButton1Click:Connect(function()
        local saveResult = FileScanner.SetSource(instance, CodeBox.Text)
        
        if saveResult.success then
            ShowNotification(FullScreen, "✅ Saved via " .. saveResult.method, Color3.fromRGB(0, 200, 100))
            originalText = CodeBox.Text
            isModified = false
            SaveBtn.Text = "💾 Saved"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            wait(1)
            SaveBtn.Text = "💾 Save"
        else
            ShowNotification(FullScreen, "❌ Save failed: " .. saveResult.error, Color3.fromRGB(200, 50, 70))
        end
    end)
    
    -- ═══ زر الخروج (مع تحذير لو فيه تعديلات) ═══
    ExitBtn.MouseButton1Click:Connect(function()
        if isModified then
            -- نافذة تأكيد
            local Confirm = Instance.new("Frame")
            Confirm.Size = UDim2.new(1, 0, 1, 0)
            Confirm.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Confirm.BackgroundTransparency = 0.5
            Confirm.ZIndex = 600
            Confirm.Parent = FullScreen
            
            local Dialog = Instance.new("Frame")
            Dialog.Size = UDim2.new(0, 350, 0, 200)
            Dialog.Position = UDim2.new(0.5, -175, 0.5, -100)
            Dialog.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
            Dialog.ZIndex = 601
            Dialog.Parent = Confirm
            Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 15)
            
            local DStroke = Instance.new("UIStroke")
            DStroke.Color = Color3.fromRGB(255, 200, 50)
            DStroke.Thickness = 2
            DStroke.Parent = Dialog
            
            local WarnIcon = Instance.new("TextLabel")
            WarnIcon.Size = UDim2.new(1, 0, 0, 40)
            WarnIcon.Position = UDim2.new(0, 0, 0, 15)
            WarnIcon.Text = "⚠️"
            WarnIcon.TextSize = 32
            WarnIcon.BackgroundTransparency = 1
            WarnIcon.ZIndex = 602
            WarnIcon.Parent = Dialog
            
            local WarnTitle = Instance.new("TextLabel")
            WarnTitle.Size = UDim2.new(1, -20, 0, 25)
            WarnTitle.Position = UDim2.new(0, 10, 0, 55)
            WarnTitle.Text = "Unsaved Changes"
            WarnTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
            WarnTitle.TextSize = 18
            WarnTitle.Font = Enum.Font.GothamBold
            WarnTitle.BackgroundTransparency = 1
            WarnTitle.ZIndex = 602
            WarnTitle.Parent = Dialog
            
            local WarnText = Instance.new("TextLabel")
            WarnText.Size = UDim2.new(1, -20, 0, 30)
            WarnText.Position = UDim2.new(0, 10, 0, 85)
            WarnText.Text = "Do you want to save before exiting?"
            WarnText.TextColor3 = Color3.fromRGB(255, 255, 255)
            WarnText.TextSize = 13
            WarnText.Font = Enum.Font.Gotham
            WarnText.TextWrapped = true
            WarnText.BackgroundTransparency = 1
            WarnText.ZIndex = 602
            WarnText.Parent = Dialog
            
            -- زر الحفظ والخروج
            local SaveExitBtn = Instance.new("TextButton")
            SaveExitBtn.Size = UDim2.new(0, 100, 0, 35)
            SaveExitBtn.Position = UDim2.new(0, 15, 1, -50)
            SaveExitBtn.Text = "💾 Save & Exit"
            SaveExitBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
            SaveExitBtn.TextSize = 12
            SaveExitBtn.Font = Enum.Font.GothamBold
            SaveExitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            SaveExitBtn.ZIndex = 602
            SaveExitBtn.Parent = Dialog
            Instance.new("UICorner", SaveExitBtn).CornerRadius = UDim.new(0, 8)
            
            -- زر الخروج بدون حفظ
            local DiscardBtn = Instance.new("TextButton")
            DiscardBtn.Size = UDim2.new(0, 110, 0, 35)
            DiscardBtn.Position = UDim2.new(0, 120, 1, -50)
            DiscardBtn.Text = "🗑️ Discard"
            DiscardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            DiscardBtn.TextSize = 12
            DiscardBtn.Font = Enum.Font.GothamBold
            DiscardBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            DiscardBtn.ZIndex = 602
            DiscardBtn.Parent = Dialog
            Instance.new("UICorner", DiscardBtn).CornerRadius = UDim.new(0, 8)
            
            -- زر إلغاء
            local CancelBtn = Instance.new("TextButton")
            CancelBtn.Size = UDim2.new(0, 90, 0, 35)
            CancelBtn.Position = UDim2.new(1, -105, 1, -50)
            CancelBtn.Text = "Cancel"
            CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CancelBtn.TextSize = 12
            CancelBtn.Font = Enum.Font.GothamBold
            CancelBtn.BackgroundColor3 = Color3.fromRGB(80, 90, 130)
            CancelBtn.ZIndex = 602
            CancelBtn.Parent = Dialog
            Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 8)
            
            SaveExitBtn.MouseButton1Click:Connect(function()
                local saveResult = FileScanner.SetSource(instance, CodeBox.Text)
                if saveResult.success then
                    ShowNotification(FullScreen, "✅ Saved!", Color3.fromRGB(0, 200, 100))
                    wait(0.5)
                    FullScreen:Destroy()
                    if onExit then onExit() end
                else
                    ShowNotification(FullScreen, "❌ Save failed", Color3.fromRGB(200, 50, 70))
                    Confirm:Destroy()
                end
            end)
            
            DiscardBtn.MouseButton1Click:Connect(function()
                FullScreen:Destroy()
                if onExit then onExit() end
            end)
            
            CancelBtn.MouseButton1Click:Connect(function()
                Confirm:Destroy()
            end)
        else
            FullScreen:Destroy()
            if onExit then onExit() end
        end
    end)
end

-- ═══════════════════════════════════════════════════════
-- الواجهة الأساسية (Info + Children)
-- ═══════════════════════════════════════════════════════
function FileViewer.Open(mainParent, instance, onClose)
    local info = FileScanner.GetInfo(instance)
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "FileViewerOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.BorderSizePixel = 0
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

    -- Header
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

    -- ═══ زر VIEW CODE بارز (لو سكريبت) ═══
    if info.IsScript then
        local BigCodeBtn = Instance.new("TextButton")
        BigCodeBtn.Size = UDim2.new(1, -20, 0, 80)
        BigCodeBtn.Position = UDim2.new(0, 10, 0, 80)
        BigCodeBtn.Text = "📜  VIEW & EDIT CODE"
        BigCodeBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
        BigCodeBtn.TextSize = 22
        BigCodeBtn.Font = Enum.Font.GothamBold
        BigCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        BigCodeBtn.ZIndex = 92
        BigCodeBtn.Parent = Window
        Instance.new("UICorner", BigCodeBtn).CornerRadius = UDim.new(0, 12)
        
        local BCStroke = Instance.new("UIStroke")
        BCStroke.Color = Color3.fromRGB(0, 255, 200)
        BCStroke.Thickness = 2
        BCStroke.Parent = BigCodeBtn
        
        -- تأثير نبض
        spawn(function()
            while BigCodeBtn.Parent do
                TweenService:Create(BCStroke, TweenInfo.new(1), {Thickness = 4, Transparency = 0.3}):Play()
                wait(1)
                TweenService:Create(BCStroke, TweenInfo.new(1), {Thickness = 2, Transparency = 0}):Play()
                wait(1)
            end
        end)
        
        BigCodeBtn.MouseButton1Click:Connect(function()
            local sourceData = FileScanner.GetSource(instance)
            
            -- إخفاء النافذة الحالية
            Overlay.Visible = false
            
            -- فتح المحرر الكامل
            FileViewer.OpenCodeEditor(mainParent, instance, sourceData, function()
                -- عند الخروج من المحرر: أظهر النافذة
                Overlay.Visible = true
            end)
        end)
    end
    -- ═══════════════════════════════
    -- زر SOUND EDITOR (للأصوات)
    -- ═══════════════════════════════
    if instance:IsA("Sound") then
        local SoundBtn = Instance.new("TextButton")
        SoundBtn.Size = UDim2.new(1, -20, 0, 80)
        SoundBtn.Position = UDim2.new(0, 10, 0, 80)
        SoundBtn.Text = "🔊  SOUND EDITOR"
        SoundBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
        SoundBtn.TextSize = 22
        SoundBtn.Font = Enum.Font.GothamBold
        SoundBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        SoundBtn.ZIndex = 92
        SoundBtn.Parent = Window
        Instance.new("UICorner", SoundBtn).CornerRadius = UDim.new(0, 12)
        
        local SBStroke = Instance.new("UIStroke")
        SBStroke.Color = Color3.fromRGB(255, 230, 100)
        SBStroke.Thickness = 2
        SBStroke.Parent = SoundBtn
        
        spawn(function()
            while SoundBtn.Parent do
                TweenService:Create(SBStroke, TweenInfo.new(1), {Thickness = 4, Transparency = 0.3}):Play()
                wait(1)
                TweenService:Create(SBStroke, TweenInfo.new(1), {Thickness = 2, Transparency = 0}):Play()
                wait(1)
            end
        end)

        SoundBtn.MouseButton1Click:Connect(function()
            Overlay.Visible = false
            local SoundEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/SoundEditor.lua", true))()
            SoundEditor.Open(mainParent, instance, function()
                Overlay.Visible = true
            end)
        end)
    end

    -- ═══════════════════════════════
    -- زر IMAGE EDITOR (للصور)
    -- ═══════════════════════════════
    if instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        local ImageBtn = Instance.new("TextButton")
        ImageBtn.Size = UDim2.new(1, -20, 0, 80)
        ImageBtn.Position = UDim2.new(0, 10, 0, 80)
        ImageBtn.Text = "🖼️  IMAGE EDITOR"
        ImageBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
        ImageBtn.TextSize = 22
        ImageBtn.Font = Enum.Font.GothamBold
        ImageBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
        ImageBtn.ZIndex = 92
        ImageBtn.Parent = Window
        Instance.new("UICorner", ImageBtn).CornerRadius = UDim.new(0, 12)
        
        local IBStroke = Instance.new("UIStroke")
        IBStroke.Color = Color3.fromRGB(255, 150, 200)
        IBStroke.Thickness = 2
        IBStroke.Parent = ImageBtn
        
        spawn(function()
            while ImageBtn.Parent do
                TweenService:Create(IBStroke, TweenInfo.new(1), {Thickness = 4, Transparency = 0.3}):Play()
                wait(1)
                TweenService:Create(IBStroke, TweenInfo.new(1), {Thickness = 2, Transparency = 0}):Play()
                wait(1)
            end
        end)

        ImageBtn.MouseButton1Click:Connect(function()
            Overlay.Visible = false
            local ImageEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/ImageEditor.lua", true))()
            ImageEditor.Open(mainParent, instance, function()
                Overlay.Visible = true
            end)
        end)
    end
    -- ═══ المحتوى (Info + Children) ═══
    local ContentArea = Instance.new("Frame")
    if info.IsScript then
        ContentArea.Size = UDim2.new(1, -20, 1, -260)
        ContentArea.Position = UDim2.new(0, 10, 0, 170)
    else
        ContentArea.Size = UDim2.new(1, -20, 1, -160)
        ContentArea.Position = UDim2.new(0, 10, 0, 80)
    end
    ContentArea.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.ZIndex = 92
    ContentArea.Parent = Window
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 10)

    -- تبويبات
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

    -- Info Tab
    local InfoContent = Instance.new("ScrollingFrame")
    InfoContent.Size = UDim2.new(1, -10, 1, -50)
    InfoContent.Position = UDim2.new(0, 5, 0, 45)
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

    -- Children Tab
    local ChildrenContent = Instance.new("ScrollingFrame")
    ChildrenContent.Size = UDim2.new(1, -10, 1, -50)
    ChildrenContent.Position = UDim2.new(0, 5, 0, 45)
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
        
        -- شارة إذا كان سكريبت
        if cInfo.IsScript then
            local Badge = Instance.new("TextLabel")
            Badge.Size = UDim2.new(0, 50, 0, 22)
            Badge.Position = UDim2.new(1, -60, 0.5, -11)
            Badge.Text = "CODE"
            Badge.TextColor3 = Color3.fromRGB(11, 13, 26)
            Badge.TextSize = 10
            Badge.Font = Enum.Font.GothamBold
            Badge.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            Badge.ZIndex = 96
            Badge.Parent = ChItem
            Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
        end

        ChItem.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            FileViewer.Open(mainParent, child, onClose)
        end)
    end

    ChildrenContent.CanvasSize = UDim2.new(0, 0, 0, ChLayout.AbsoluteContentSize.Y + 20)

    -- إنشاء التبويبات
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

    -- الشريط السفلي
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

    print("FileViewer opened: " .. instance:GetFullName())
end

return FileViewer
