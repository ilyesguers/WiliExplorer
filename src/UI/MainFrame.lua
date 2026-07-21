local MainFrame = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🚀 WiliExplorer - MainFrame v3.2 (KLIMBO MENU FIX - COMPLETE)
-- ═══════════════════════════════════════════════════════════════════════════

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Security/KeySystem.lua", true))()
local Stars = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Theme/Stars.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 الألوان الفخمة
-- ═══════════════════════════════════════════════════════════════════════════
local Colors = {
    Primary = Color3.fromRGB(11, 13, 26),
    Secondary = Color3.fromRGB(17, 20, 50),
    Tertiary = Color3.fromRGB(25, 30, 70),
    Accent = Color3.fromRGB(0, 212, 255),
    AccentDark = Color3.fromRGB(0, 152, 219),
    Gold = Color3.fromRGB(255, 215, 0),
    Pink = Color3.fromRGB(255, 0, 128),
    Cyan = Color3.fromRGB(0, 255, 255),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 71, 87),
    Warning = Color3.fromRGB(255, 165, 2),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 170, 200)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════════
local function CreateTween(obj, props, duration, style, direction)
    return TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out), props)
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Accent
    s.Thickness = thickness or 2
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function AddGlow(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color or Colors.Accent
    glow.ImageTransparency = 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(24, 24, 276, 276)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎆 إنشاء تأثيرات بصرية
-- ═══════════════════════════════════════════════════════════════════════════
local function CreateParticles(parent)
    local container = Instance.new("Frame")
    container.Name = "Particles"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 1
    container.Parent = parent
    
    -- جزيئات متحركة
    spawn(function()
        while container.Parent do
            for i = 1, 3 do
                local particle = Instance.new("Frame")
                particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
                particle.Position = UDim2.new(math.random(), 0, 1.1, 0)
                particle.BackgroundColor3 = i % 2 == 0 and Colors.Accent or Colors.Gold
                particle.BackgroundTransparency = 0.3
                particle.BorderSizePixel = 0
                particle.ZIndex = 2
                particle.Parent = container
                AddCorner(particle, 10)
                
                local duration = math.random(30, 60) / 10
                CreateTween(particle, {
                    Position = UDim2.new(math.random(), 0, -0.1, 0),
                    BackgroundTransparency = 1,
                    Rotation = math.random(-180, 180)
                }, duration, Enum.EasingStyle.Linear):Play()
                
                game:GetService("Debris"):AddItem(particle, duration)
            end
            wait(0.5)
        end
    end)
    
    return container
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📢 نظام الإشعارات
-- ═══════════════════════════════════════════════════════════════════════════
local function ShowNotification(parent, message, notifType, duration)
    local colors = {
        success = Colors.Success,
        error = Colors.Error,
        warning = Colors.Warning,
        info = Colors.Accent
    }
    local icons = {
        success = "✅",
        error = "❌",
        warning = "⚠️",
        info = "ℹ️"
    }
    
    local color = colors[notifType] or Colors.Accent
    local icon = icons[notifType] or "ℹ️"
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 60)
    notif.Position = UDim2.new(0.5, -160, 0, -70)
    notif.BackgroundColor3 = Colors.Primary
    notif.BorderSizePixel = 0
    notif.ZIndex = 999
    notif.Parent = parent
    AddCorner(notif, 12)
    local stroke = AddStroke(notif, color, 2)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 50, 1, 0)
    iconLabel.Text = icon
    iconLabel.TextSize = 28
    iconLabel.BackgroundTransparency = 1
    iconLabel.ZIndex = 1000
    iconLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -60, 1, 0)
    msgLabel.Position = UDim2.new(0, 55, 0, 0)
    msgLabel.Text = message
    msgLabel.TextColor3 = Colors.TextPrimary
    msgLabel.TextSize = 14
    msgLabel.Font = Enum.Font.GothamBold
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.BackgroundTransparency = 1
    msgLabel.ZIndex = 1000
    msgLabel.Parent = notif
    
    -- أنيميشن الدخول
    CreateTween(notif, {Position = UDim2.new(0.5, -160, 0, 15)}, 0.4, Enum.EasingStyle.Back):Play()
    
    -- أنيميشن الخروج
    delay(duration or 3, function()
        CreateTween(notif, {Position = UDim2.new(0.5, -160, 0, -70)}, 0.3):Play()
        wait(0.3)
        notif:Destroy()
    end)
    
    return notif
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎭 شاشة التحميل الفخمة
-- ═══════════════════════════════════════════════════════════════════════════
local function CreateLoadingScreen(parent)
    local loading = Instance.new("Frame")
    loading.Name = "LoadingScreen"
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.BackgroundColor3 = Colors.Primary
    loading.ZIndex = 100
    loading.Parent = parent
    
    -- تدرج
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 10, 35))
    })
    grad.Rotation = 135
    grad.Parent = loading
    
    -- الشعار
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 80)
    logo.Position = UDim2.new(0, 0, 0.35, 0)
    logo.Text = "🚀 WiliExplorer"
    logo.TextColor3 = Colors.Accent
    logo.TextSize = 42
    logo.Font = Enum.Font.GothamBlack
    logo.BackgroundTransparency = 1
    logo.ZIndex = 101
    logo.Parent = loading
    
    -- تأثير توهج النص
    spawn(function()
        while logo.Parent do
            CreateTween(logo, {TextColor3 = Colors.Cyan}, 1):Play()
            wait(1)
            CreateTween(logo, {TextColor3 = Colors.Accent}, 1):Play()
            wait(1)
        end
    end)
    
    -- نص التحميل
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 40)
    loadingText.Position = UDim2.new(0, 0, 0.5, 0)
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Colors.TextSecondary
    loadingText.TextSize = 18
    loadingText.Font = Enum.Font.Gotham
    loadingText.BackgroundTransparency = 1
    loadingText.ZIndex = 101
    loadingText.Parent = loading
    
    -- شريط التحميل
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0.6, 0, 0, 6)
    progressBar.Position = UDim2.new(0.2, 0, 0.55, 0)
    progressBar.BackgroundColor3 = Colors.Tertiary
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 101
    progressBar.Parent = loading
    AddCorner(progressBar, 3)
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = Colors.Accent
    progress.BorderSizePixel = 0
    progress.ZIndex = 102
    progress.Parent = progressBar
    AddCorner(progress, 3)
    
    -- أنيميشن التحميل
    CreateTween(progress, {Size = UDim2.new(1, 0, 1, 0)}, 2):Play()
    
    return loading
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 إنشاء الواجهة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════════

function MainFrame.Create(Modules)
    print("🚀 [MainFrame] Creating WiliExplorer UI...")
    
    -- إنشاء ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui
    
    -- الإطار الرئيسي
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    mainFrame.BackgroundColor3 = Colors.Primary
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 5
    mainFrame.Parent = ScreenGui
    AddCorner(mainFrame, 20)
    AddStroke(mainFrame, Colors.Accent, 3)
    
    -- الخلفية المتحركة
    if Stars and Stars.Create then
        Stars.Create(mainFrame, 60)
    end
    CreateParticles(mainFrame)
    
    -- الشريط العلوي
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 70)
    topBar.BackgroundColor3 = Colors.Secondary
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 50
    topBar.Parent = mainFrame
    AddCorner(topBar, 20)
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0.6, 0, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.Text = "🚀 WiliExplorer"
    logo.TextSize = 26
    logo.Font = Enum.Font.GothamBlack
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.TextColor3 = Colors.Gold
    logo.BackgroundTransparency = 1
    logo.ZIndex = 51
    logo.Parent = topBar
    
    -- تأثير توهج للشعار
    local logoGlow = Instance.new("UIGradient")
    logoGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Gold),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.Cyan)
    })
    logoGlow.Parent = logo
    
    -- أنيميشن الشعار
    spawn(function()
        while logo.Parent do
            CreateTween(logoGlow, {Rotation = 360}, 4, Enum.EasingStyle.Linear):Play()
            wait(4)
            logoGlow.Rotation = 0
        end
    end)
    
    -- زر اللغة
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 50, 0, 50)
    langBtn.Position = UDim2.new(1, -130, 0.5, -25)
    langBtn.Text = "🌐"
    langBtn.TextSize = 24
    langBtn.Font = Enum.Font.GothamBold
    langBtn.BackgroundColor3 = Colors.Tertiary
    langBtn.TextColor3 = Colors.TextPrimary
    langBtn.BorderSizePixel = 0
    langBtn.ZIndex = 51
    langBtn.Parent = topBar
    AddCorner(langBtn, 12)
    
    langBtn.MouseButton1Click:Connect(function()
        if Language and Language.Toggle then
            Language.Toggle()
            ShowNotification(mainFrame, "Language Changed!", "success", 2)
        end
    end)
    
    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 50, 0, 50)
    closeBtn.Position = UDim2.new(1, -65, 0.5, -25)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.TextPrimary
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Colors.Error
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 51
    closeBtn.Parent = topBar
    AddCorner(closeBtn, 12)
    
    closeBtn.MouseButton1Click:Connect(function()
        CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- منطقة المحتوى
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Content"
    scrollFrame.Size = UDim2.new(1, -30, 1, -90)
    scrollFrame.Position = UDim2.new(0, 15, 0, 75)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Colors.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)
    scrollFrame.ZIndex = 20
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = scrollFrame
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- دالة إنشاء زر
    local function CreateButton(parent, icon, title, description, callback)
        local btn = Instance.new("Frame")
        btn.Size = UDim2.new(1, -10, 0, 75)
        btn.BackgroundColor3 = Colors.Secondary
        btn.BorderSizePixel = 0
        btn.ZIndex = 21
        btn.Parent = parent
        AddCorner(btn, 12)
        AddStroke(btn, Colors.Accent, 2, 0.5)
        
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 60, 1, 0)
        iconLabel.Text = icon
        iconLabel.TextSize = 32
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.BackgroundTransparency = 1
        iconLabel.ZIndex = 22
        iconLabel.Parent = btn
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -140, 0, 30)
        titleLabel.Position = UDim2.new(0, 65, 0, 12)
        titleLabel.Text = title
        titleLabel.TextColor3 = Colors.TextPrimary
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BackgroundTransparency = 1
        titleLabel.ZIndex = 22
        titleLabel.Parent = btn
        
        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -140, 0, 20)
        descLabel.Position = UDim2.new(0, 65, 0, 42)
        descLabel.Text = description
        descLabel.TextColor3 = Colors.TextSecondary
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.BackgroundTransparency = 1
        descLabel.ZIndex = 22
        descLabel.Parent = btn
        
        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(0, 55, 0, 55)
        clickBtn.Position = UDim2.new(1, -65, 0.5, -27)
        clickBtn.Text = "▶"
        clickBtn.TextColor3 = Colors.TextPrimary
        clickBtn.TextSize = 20
        clickBtn.Font = Enum.Font.GothamBold
        clickBtn.BackgroundColor3 = Colors.Accent
        clickBtn.BorderSizePixel = 0
        clickBtn.ZIndex = 22
        clickBtn.Parent = btn
        AddCorner(clickBtn, 12)
        
        -- تأثير Hover
        btn.MouseEnter:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Colors.Tertiary}, 0.2):Play()
            CreateTween(clickBtn, {Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(1, -67, 0.5, -30)}, 0.2):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {BackgroundColor3 = Colors.Secondary}, 0.2):Play()
            CreateTween(clickBtn, {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(1, -65, 0.5, -27)}, 0.2):Play()
        end)
        
        clickBtn.MouseButton1Click:Connect(function()
            CreateTween(clickBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.1):Play()
            wait(0.1)
            CreateTween(clickBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.1):Play()
            if callback then 
                pcall(function()
                    callback()
                end)
            end
        end)
        
        return btn
    end
    
    -- ════════════════════════════════════════════════════════════════════════
    -- 📝 إنشاء الأزرار
    -- ════════════════════════════════════════════════════════════════════════
    
    -- زر File Explorer
    CreateButton(scrollFrame, "📁", "File Explorer", "Browse and edit game files", function()
        ShowNotification(mainFrame, "Opening File Explorer...", "info", 2)
        -- سيتم إضافة الكود هنا
        if Modules and Modules.FileViewer and Modules.FileViewer.Create then
            Modules.FileViewer.Create()
        end
    end)
    
    -- زر Image Editor
    CreateButton(scrollFrame, "🖼️", "Image Editor", "Edit and view images", function()
        ShowNotification(mainFrame, "Opening Image Editor...", "info", 2)
        if Modules and Modules.ImageEditor and Modules.ImageEditor.Create then
            Modules.ImageEditor.Create()
        end
    end)
    
    -- ⭐⭐⭐ زر KLIMBO MENU (المُحدّث والمُصلح) ⭐⭐⭐
    CreateButton(scrollFrame, "👑", "Klimbo Menu", "Advanced Features & Cheats", function()
        print("🔥 [KLIMBO] Button clicked!")
        ShowNotification(mainFrame, "Loading KLIMBO Menu...", "info", 1)
        
        -- تحميل KLIMBO Menu
        print("📥 [KLIMBO] Loading from GitHub...")
        local success, KlimboMenu = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/KlimboMenu.lua", true))()
        end)
        
        if not success then
            warn("❌ [KLIMBO] Failed to load:", KlimboMenu)
            ShowNotification(mainFrame, "Failed to load KLIMBO Menu!", "error", 3)
            return
        end
        
        if not KlimboMenu then
            warn("❌ [KLIMBO] Module is nil!")
            ShowNotification(mainFrame, "KLIMBO Menu not found!", "error", 3)
            return
        end
        
        print("✅ [KLIMBO] Module loaded successfully!")
        
        -- إنشاء القائمة (مرة واحدة فقط)
        if not _G.KlimboMenuCreated then
            print("🔧 [KLIMBO] Creating menu for the first time...")
            local createSuccess = pcall(function()
                KlimboMenu.Create(game.CoreGui, mainFrame)
                _G.KlimboMenuCreated = true
                _G.KlimboMenuInstance = KlimboMenu
                print("✅ [KLIMBO] Menu created successfully!")
            end)
            
            if not createSuccess then
                warn("❌ [KLIMBO] Failed to create menu!")
                ShowNotification(mainFrame, "Failed to create KLIMBO Menu!", "error", 3)
                return
            end
        else
            print("ℹ️ [KLIMBO] Menu already exists, using cached instance")
            KlimboMenu = _G.KlimboMenuInstance
        end
        
        -- عرض رسالة النجاح
        task.wait(0.5)
        ShowNotification(mainFrame, "KLIMBO Menu Ready!", "success", 2)
        print("✅ [KLIMBO] Ready message shown")
        
        -- فتح القائمة
        task.wait(0.3)
        if KlimboMenu and KlimboMenu.Show then
            print("🔓 [KLIMBO] Opening menu...")
            local showSuccess = pcall(function()
                KlimboMenu.Show()
            end)
            
            if showSuccess then
                print("✅ [KLIMBO] Menu opened successfully!")
            else
                warn("❌ [KLIMBO] Failed to show menu!")
                ShowNotification(mainFrame, "Failed to open KLIMBO Menu!", "error", 3)
            end
        else
            warn("❌ [KLIMBO] Show function not found!")
            ShowNotification(mainFrame, "KLIMBO Menu error!", "error", 3)
        end
    end)
    
    -- زر Sound Editor
    CreateButton(scrollFrame, "🔊", "Sound Editor", "Edit and play sounds", function()
        ShowNotification(mainFrame, "Opening Sound Editor...", "info", 2)
        -- سيتم إضافة الكود هنا
    end)
    
    -- زر Game Analyzer
    CreateButton(scrollFrame, "🎮", "Game Analyzer", "Analyze game structure", function()
        ShowNotification(mainFrame, "Opening Game Analyzer...", "info", 2)
        if Modules and Modules.GameAnalyzer and Modules.GameAnalyzer.Analyze then
            Modules.GameAnalyzer.Analyze()
        end
    end)
    
    -- زر Advanced Tools
    CreateButton(scrollFrame, "🛠️", "Advanced Tools", "Developer utilities", function()
        ShowNotification(mainFrame, "Opening Advanced Tools...", "info", 2)
        if Modules and Modules.AdvancedTools and Modules.AdvancedTools.Create then
            Modules.AdvancedTools.Create()
        end
    end)
    
    -- زر Settings
    CreateButton(scrollFrame, "⚙️", "Settings", "Configure WiliExplorer", function()
        ShowNotification(mainFrame, "Opening Settings...", "info", 2)
        -- سيتم إضافة الكود هنا
    end)
    
    -- زر About
    CreateButton(scrollFrame, "ℹ️", "About", "Version and credits", function()
        ShowNotification(mainFrame, "WiliExplorer v2.0 - By ilyesguers", "info", 3)
    end)
    
    -- السحب
    local dragging = false
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- شاشة التحميل
    local loadingScreen = CreateLoadingScreen(mainFrame)
    wait(2)
    CreateTween(loadingScreen, {BackgroundTransparency = 1}, 0.5):Play()
    for _, child in ipairs(loadingScreen:GetDescendants()) do
        if child:IsA("GuiObject") then
            CreateTween(child, {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}, 0.5):Play()
        end
    end
    wait(0.5)
    loadingScreen:Destroy()
    
    -- أنيميشن الفتح
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(mainFrame, {
        Size = UDim2.new(0, 450, 0, 600),
        Position = UDim2.new(0.5, -225, 0.5, -300)
    }, 0.5, Enum.EasingStyle.Back):Play()
    
    print("✅ [MainFrame] WiliExplorer UI Created Successfully!")
    ShowNotification(mainFrame, "WiliExplorer Ready!", "success", 2)
    
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════════════════

print("👑 MainFrame v3.2 - KLIMBO FIX COMPLETE Ready!")

return MainFrame
