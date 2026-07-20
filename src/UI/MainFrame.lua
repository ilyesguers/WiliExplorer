local MainFrame = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🚀 WiliExplorer - MainFrame v3.1 (VIP Ultimate Edition - KlimboMenu Fix)
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
    
    -- VIP Badge
    local vipBadge = Instance.new("TextLabel")
    vipBadge.Size = UDim2.new(0, 120, 0, 35)
    vipBadge.Position = UDim2.new(0.5, -60, 0.48, 0)
    vipBadge.Text = "👑 VIP ACCESS"
    vipBadge.TextColor3 = Colors.Gold
    vipBadge.TextSize = 14
    vipBadge.Font = Enum.Font.GothamBlack
    vipBadge.BackgroundColor3 = Color3.fromRGB(30, 25, 15)
    vipBadge.ZIndex = 101
    vipBadge.Parent = loading
    AddCorner(vipBadge, 8)
    AddStroke(vipBadge, Colors.Gold, 2)
    
    -- شريط التحميل
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.6, 0, 0, 8)
    progressBg.Position = UDim2.new(0.2, 0, 0.6, 0)
    progressBg.BackgroundColor3 = Colors.Tertiary
    progressBg.ZIndex = 101
    progressBg.Parent = loading
    AddCorner(progressBg, 4)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Colors.Accent
    progressFill.ZIndex = 102
    progressFill.Parent = progressBg
    AddCorner(progressFill, 4)
    
    local progGrad = Instance.new("UIGradient")
    progGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Pink),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.Cyan)
    })
    progGrad.Parent = progressFill
    
    -- نص التحميل
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 25)
    loadingText.Position = UDim2.new(0, 0, 0.65, 0)
    loadingText.Text = "جاري التحميل..."
    loadingText.TextColor3 = Colors.TextSecondary
    loadingText.TextSize = 14
    loadingText.Font = Enum.Font.Gotham
    loadingText.BackgroundTransparency = 1
    loadingText.ZIndex = 101
    loadingText.Parent = loading
    
    -- أنيميشن التحميل
    local loadSteps = {
        {text = "📦 Loading modules...", progress = 0.2},
        {text = "🎨 Initializing UI...", progress = 0.4},
        {text = "🔐 Checking security...", progress = 0.6},
        {text = "⚡ Optimizing performance...", progress = 0.8},
        {text = "✨ Almost ready...", progress = 0.95},
        {text = "🚀 Welcome to WiliExplorer!", progress = 1}
    }
    
    spawn(function()
        for _, step in ipairs(loadSteps) do
            loadingText.Text = step.text
            CreateTween(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.4):Play()
            wait(0.5)
        end
        wait(0.5)
        CreateTween(loading, {BackgroundTransparency = 1}, 0.5):Play()
        CreateTween(logo, {TextTransparency = 1}, 0.5):Play()
        CreateTween(vipBadge, {BackgroundTransparency = 1, TextTransparency = 1}, 0.5):Play()
        CreateTween(progressBg, {BackgroundTransparency = 1}, 0.5):Play()
        CreateTween(progressFill, {BackgroundTransparency = 1}, 0.5):Play()
        CreateTween(loadingText, {TextTransparency = 1}, 0.5):Play()
        wait(0.5)
        loading:Destroy()
    end)
    
    return loading
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎮 الدالة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════════
function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- كشف حجم الشاشة
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < 800
    
    -- حجم مناسب للهاتف
    local frameWidth = isMobile and viewport.X * 0.95 or 700
    local frameHeight = isMobile and viewport.Y * 0.85 or 500

    -- ═══════════════════════════════
    -- الإطار الرئيسي
    -- ═══════════════════════════════
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    Frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    Frame.BackgroundColor3 = Colors.Primary
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    AddCorner(Frame, 20)
    
    -- حدود متوهجة متحركة
    local MainStroke = AddStroke(Frame, Colors.Accent, 2)
    spawn(function()
        while Frame.Parent do
            CreateTween(MainStroke, {Color = Colors.Cyan}, 2):Play()
            wait(2)
            CreateTween(MainStroke, {Color = Colors.Accent}, 2):Play()
            wait(2)
        end
    end)

    -- تدرج فضائي
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 60))
    })
    Gradient.Rotation = 135
    Gradient.Parent = Frame

    -- النجوم في الخلفية
    Stars.Create(Frame, 100)
    
    -- الجزيئات
    CreateParticles(Frame)
    
    -- شاشة التحميل
    CreateLoadingScreen(Frame)

    -- ═══════════════════════════════
    -- الشريط العلوي (Top Bar)
    -- ═══════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.BackgroundTransparency = 0.2
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 50
    TopBar.Parent = Frame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 20)
    TopCorner.Parent = TopBar
    
    -- خط سفلي متوهج
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, -2)
    TopLine.BackgroundColor3 = Colors.Accent
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 51
    TopLine.Parent = TopBar
    
    spawn(function()
        while TopLine.Parent do
            CreateTween(TopLine, {BackgroundColor3 = Colors.Pink}, 1.5):Play()
            wait(1.5)
            CreateTween(TopLine, {BackgroundColor3 = Colors.Cyan}, 1.5):Play()
            wait(1.5)
            CreateTween(TopLine, {BackgroundColor3 = Colors.Accent}, 1.5):Play()
            wait(1.5)
        end
    end)

    -- شعار التطبيق
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 200, 1, 0)
    Logo.Position = UDim2.new(0, 15, 0, 0)
    Logo.Text = "🚀 WiliExplorer"
    Logo.TextColor3 = Colors.Accent
    Logo.TextSize = 22
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = 51
    Logo.Parent = TopBar
    
    -- VIP Badge في الشعار
    local LogoVIP = Instance.new("TextLabel")
    LogoVIP.Size = UDim2.new(0, 35, 0, 18)
    LogoVIP.Position = UDim2.new(0, 175, 0.5, -9)
    LogoVIP.Text = "VIP"
    LogoVIP.TextColor3 = Colors.Primary
    LogoVIP.TextSize = 10
    LogoVIP.Font = Enum.Font.GothamBlack
    LogoVIP.BackgroundColor3 = Colors.Gold
    LogoVIP.ZIndex = 52
    LogoVIP.Parent = TopBar
    AddCorner(LogoVIP, 4)

    -- ═══════════════════════════════
    -- 👑 زر KLIMBO MENU (مخفي في البداية)
    -- ═══════════════════════════════
    local KlimboBtn = Instance.new("TextButton")
    KlimboBtn.Name = "KlimboBtn"
    KlimboBtn.Size = UDim2.new(0, 100, 0, 36)
    KlimboBtn.Position = UDim2.new(1, -370, 0.5, -18)
    KlimboBtn.Text = "👑 KLIMBO"
    KlimboBtn.TextColor3 = Colors.Gold
    KlimboBtn.TextSize = 12
    KlimboBtn.Font = Enum.Font.GothamBlack
    KlimboBtn.BackgroundColor3 = Colors.Secondary
    KlimboBtn.ZIndex = 51
    KlimboBtn.Visible = false -- مخفي حتى يدخل المفتاح
    KlimboBtn.Parent = TopBar
    AddCorner(KlimboBtn, 10)
    
    -- تدرج جميل للزر
    local KlimboGradient = Instance.new("UIGradient")
    KlimboGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Pink),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 150)),
        ColorSequenceKeypoint.new(1, Colors.Cyan)
    })
    KlimboGradient.Rotation = 45
    KlimboGradient.Parent = KlimboBtn
    
    local KlimboStroke = AddStroke(KlimboBtn, Colors.Gold, 2)
    
    -- أنيميشن توهج الزر
    spawn(function()
        while KlimboBtn.Parent do
            CreateTween(KlimboStroke, {Color = Colors.Pink, Transparency = 0}, 1):Play()
            wait(1)
            CreateTween(KlimboStroke, {Color = Colors.Cyan, Transparency = 0}, 1):Play()
            wait(1)
            CreateTween(KlimboStroke, {Color = Colors.Gold, Transparency = 0}, 1):Play()
            wait(1)
        end
    end)
    
    -- تأثير hover
    KlimboBtn.MouseEnter:Connect(function()
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 110, 0, 40)}, 0.2):Play()
        CreateTween(KlimboStroke, {Thickness = 3}, 0.2):Play()
    end)
    KlimboBtn.MouseLeave:Connect(function()
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 100, 0, 36)}, 0.2):Play()
        CreateTween(KlimboStroke, {Thickness = 2}, 0.2):Play()
    end)

    -- زر اللغة
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 85, 0, 36)
    LangBtn.Position = UDim2.new(1, -260, 0.5, -18)
    LangBtn.Text = "🌐 عربي"
    LangBtn.TextColor3 = Colors.TextPrimary
    LangBtn.TextSize = 13
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 180)
    LangBtn.ZIndex = 51
    LangBtn.Parent = TopBar
    AddCorner(LangBtn, 10)
    AddStroke(LangBtn, Colors.Accent, 1, 0.5)

    -- زر التصغير
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 36, 0, 36)
    MinBtn.Position = UDim2.new(1, -165, 0.5, -18)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Colors.TextPrimary
    MinBtn.TextSize = 22
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
    MinBtn.ZIndex = 51
    MinBtn.Parent = TopBar
    AddCorner(MinBtn, 10)
    
    MinBtn.MouseEnter:Connect(function()
        CreateTween(MinBtn, {BackgroundColor3 = Color3.fromRGB(80, 90, 140)}, 0.2):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        CreateTween(MinBtn, {BackgroundColor3 = Color3.fromRGB(60, 70, 120)}, 0.2):Play()
    end)

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -120, 0.5, -18)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.TextPrimary
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Colors.Error
    CloseBtn.ZIndex = 51
    CloseBtn.Parent = TopBar
    AddCorner(CloseBtn, 10)
    
    CloseBtn.MouseEnter:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 110)}, 0.2):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Colors.Error}, 0.2):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        -- أنيميشن إغلاق
        CreateTween(Frame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, 55)}, 0.3, Enum.EasingStyle.Back):Play()
            MinBtn.Text = "+"
        else
            CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back):Play()
            MinBtn.Text = "—"
        end
    end)

    -- ═══════════════════════════════
    -- معلومات المستخدم (تظهر بعد الدخول)
    -- ═══════════════════════════════
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.Size = UDim2.new(0, 150, 0, 36)
    UserInfo.Position = UDim2.new(1, -75, 0.5, -18)
    UserInfo.BackgroundColor3 = Colors.Tertiary
    UserInfo.BackgroundTransparency = 0.5
    UserInfo.ZIndex = 51
    UserInfo.Visible = false
    UserInfo.Parent = TopBar
    AddCorner(UserInfo, 10)
    
    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Size = UDim2.new(0, 28, 0, 28)
    UserAvatar.Position = UDim2.new(0, 4, 0.5, -14)
    UserAvatar.BackgroundColor3 = Colors.Accent
    UserAvatar.ZIndex = 52
    UserAvatar.Parent = UserInfo
    AddCorner(UserAvatar, 14)
    pcall(function()
        UserAvatar.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    
    local UserName = Instance.new("TextLabel")
    UserName.Size = UDim2.new(1, -40, 1, 0)
    UserName.Position = UDim2.new(0, 36, 0, 0)
    UserName.Text = Players.LocalPlayer.Name:sub(1, 10)
    UserName.TextColor3 = Colors.TextPrimary
    UserName.TextSize = 11
    UserName.Font = Enum.Font.GothamBold
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.ZIndex = 52
    UserName.Parent = UserInfo

    -- ═══════════════════════════════
    -- منطقة المحتوى
    -- ═══════════════════════════════
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -55)
    Content.Position = UDim2.new(0, 0, 0, 55)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 10
    Content.Parent = Frame

    -- ═══════════════════════════════
    -- شاشة المفتاح
    -- ═══════════════════════════════
    local KeyScreen = Instance.new("Frame")
    KeyScreen.Name = "KeyScreen"
    KeyScreen.Size = UDim2.new(1, 0, 1, 0)
    KeyScreen.BackgroundTransparency = 1
    KeyScreen.ZIndex = 15
    KeyScreen.Parent = Content

    -- العنوان الرئيسي مع أنيميشن
    local Title = Instance.new("TextLabel")
    Title.Text = "🌌 WiliExplorer"
    Title.Size = UDim2.new(1, 0, 0, 70)
    Title.Position = UDim2.new(0, 0, 0.12, 0)
    Title.TextColor3 = Colors.Accent
    Title.TextSize = isMobile and 32 or 42
    Title.Font = Enum.Font.GothamBlack
    Title.BackgroundTransparency = 1
    Title.ZIndex = 16
    Title.Parent = KeyScreen
    
    -- تأثير توهج العنوان
    spawn(function()
        while Title.Parent do
            CreateTween(Title, {TextColor3 = Colors.Cyan}, 1.5):Play()
            wait(1.5)
            CreateTween(Title, {TextColor3 = Colors.Accent}, 1.5):Play()
            wait(1.5)
        end
    end)

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = Language.Get("Welcome")
    Subtitle.Size = UDim2.new(1, 0, 0, 30)
    Subtitle.Position = UDim2.new(0, 0, 0.25, 0)
    Subtitle.TextColor3 = Colors.TextSecondary
    Subtitle.TextSize = 16
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 16
    Subtitle.Parent = KeyScreen
    
    -- VIP Badge
    local VIPLabel = Instance.new("TextLabel")
    VIPLabel.Size = UDim2.new(0, 140, 0, 35)
    VIPLabel.Position = UDim2.new(0.5, -70, 0.32, 0)
    VIPLabel.Text = "👑 VIP EXCLUSIVE"
    VIPLabel.TextColor3 = Colors.Gold
    VIPLabel.TextSize = 13
    VIPLabel.Font = Enum.Font.GothamBlack
    VIPLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 20)
    VIPLabel.ZIndex = 16
    VIPLabel.Parent = KeyScreen
    AddCorner(VIPLabel, 8)
    AddStroke(VIPLabel, Colors.Gold, 2)

    -- حقل إدخال المفتاح
    local KeyInputContainer = Instance.new("Frame")
    KeyInputContainer.Size = UDim2.new(0.85, 0, 0, 60)
    KeyInputContainer.Position = UDim2.new(0.075, 0, 0.45, 0)
    KeyInputContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    KeyInputContainer.ZIndex = 16
    KeyInputContainer.Parent = KeyScreen
    AddCorner(KeyInputContainer, 15)
    
    local KeyInputStroke = AddStroke(KeyInputContainer, Colors.Accent, 2, 0.3)
    
    local KeyIcon = Instance.new("TextLabel")
    KeyIcon.Size = UDim2.new(0, 50, 1, 0)
    KeyIcon.Text = "🔑"
    KeyIcon.TextSize = 24
    KeyIcon.BackgroundTransparency = 1
    KeyIcon.ZIndex = 17
    KeyIcon.Parent = KeyInputContainer
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -60, 1, 0)
    KeyInput.Position = UDim2.new(0, 55, 0, 0)
    KeyInput.PlaceholderText = Language.Get("EnterKey")
    KeyInput.Text = ""
    KeyInput.TextColor3 = Colors.TextPrimary
    KeyInput.PlaceholderColor3 = Colors.TextSecondary
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 16
    KeyInput.ClearTextOnFocus = false
    KeyInput.BackgroundTransparency = 1
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.ZIndex = 17
    KeyInput.Parent = KeyInputContainer
    
    -- تأثير عند التركيز
    KeyInput.Focused:Connect(function()
        CreateTween(KeyInputStroke, {Color = Colors.Accent, Transparency = 0}, 0.2):Play()
    end)
    KeyInput.FocusLost:Connect(function()
        CreateTween(KeyInputStroke, {Transparency = 0.3}, 0.2):Play()
    end)

    -- زر تسجيل الدخول
    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "🔓 " .. Language.Get("Verify")
    LoginBtn.Size = UDim2.new(0.7, 0, 0, 55)
    LoginBtn.Position = UDim2.new(0.15, 0, 0.62, 0)
    LoginBtn.BackgroundColor3 = Colors.Accent
    LoginBtn.TextColor3 = Colors.Primary
    LoginBtn.Font = Enum.Font.GothamBlack
    LoginBtn.TextSize = 18
    LoginBtn.ZIndex = 16
    LoginBtn.Parent = KeyScreen
    AddCorner(LoginBtn, 15)

    local LoginGradient = Instance.new("UIGradient")
    LoginGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 152, 219))
    })
    LoginGradient.Rotation = 90
    LoginGradient.Parent = LoginBtn
    
    -- تأثير hover للزر
    LoginBtn.MouseEnter:Connect(function()
        CreateTween(LoginBtn, {Size = UDim2.new(0.72, 0, 0, 58)}, 0.2):Play()
    end)
    LoginBtn.MouseLeave:Connect(function()
        CreateTween(LoginBtn, {Size = UDim2.new(0.7, 0, 0, 55)}, 0.2):Play()
    end)
    
    -- نص المساعدة
    local HelpText = Instance.new("TextLabel")
    HelpText.Size = UDim2.new(1, 0, 0, 25)
    HelpText.Position = UDim2.new(0, 0, 0.78, 0)
    HelpText.Text = "💬 Need a key? Contact: @WiliExplorer"
    HelpText.TextColor3 = Colors.TextSecondary
    HelpText.TextSize = 12
    HelpText.Font = Enum.Font.Gotham
    HelpText.BackgroundTransparency = 1
    HelpText.ZIndex = 16
    HelpText.Parent = KeyScreen
    
    -- حقوق الطبع
    local Copyright = Instance.new("TextLabel")
    Copyright.Size = UDim2.new(1, 0, 0, 20)
    Copyright.Position = UDim2.new(0, 0, 0.92, 0)
    Copyright.Text = "© 2025 WiliExplorer - All Rights Reserved"
    Copyright.TextColor3 = Color3.fromRGB(80, 90, 120)
    Copyright.TextSize = 11
    Copyright.Font = Enum.Font.Gotham
    Copyright.BackgroundTransparency = 1
    Copyright.ZIndex = 16
    Copyright.Parent = KeyScreen

    -- ═══════════════════════════════
    -- شاشة المتصفح
    -- ═══════════════════════════════
    local ExplorerScreen = Instance.new("Frame")
    ExplorerScreen.Name = "ExplorerScreen"
    ExplorerScreen.Size = UDim2.new(1, 0, 1, 0)
    ExplorerScreen.BackgroundTransparency = 1
    ExplorerScreen.Visible = false
    ExplorerScreen.ZIndex = 15
    ExplorerScreen.Parent = Content
    
    -- ═══════════════════════════════
    -- حاوية KlimboMenu (منفصلة)
    -- ═══════════════════════════════
    local KlimboContainer = Instance.new("Frame")
    KlimboContainer.Name = "KlimboContainer"
    KlimboContainer.Size = UDim2.new(1, 0, 1, 0)
    KlimboContainer.BackgroundTransparency = 1
    KlimboContainer.Visible = false
    KlimboContainer.ZIndex = 200
    KlimboContainer.Parent = Frame
    
    -- متغير لتتبع حالة Klimbo
    local klimboLoaded = false
    local klimboLoading = false
    local KlimboModule = nil

    -- تحديث اللغة
    LangBtn.MouseButton1Click:Connect(function()
        Language.Toggle()
        LangBtn.Text = Language.Current == "en" and "🌐 عربي" or "🌐 English"
        
        Subtitle.Text = Language.Get("Welcome")
        KeyInput.PlaceholderText = Language.Get("EnterKey")
        LoginBtn.Text = "🔓 " .. Language.Get("Verify")
        
        ShowNotification(Frame, Language.Current == "ar" and "تم تغيير اللغة للعربية" or "Language changed to English", "info", 2)
        
        -- إعادة تحميل المتصفح لو مفتوح
        if ExplorerScreen.Visible then
            ExplorerScreen:ClearAllChildren()
            local Sidebar = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/Sidebar.lua", true))()
            Sidebar.Create(ExplorerScreen)
        end
    end)

    -- التحقق من المفتاح
    LoginBtn.MouseButton1Click:Connect(function()
        -- تأثير الضغط
        CreateTween(LoginBtn, {Size = UDim2.new(0.68, 0, 0, 52)}, 0.1):Play()
        wait(0.1)
        CreateTween(LoginBtn, {Size = UDim2.new(0.7, 0, 0, 55)}, 0.1):Play()
        
        LoginBtn.Text = "⏳ " .. Language.Get("Verifying")
        CreateTween(LoginBtn, {BackgroundColor3 = Color3.fromRGB(100, 150, 200)}, 0.3):Play()
        CreateTween(KeyInputStroke, {Color = Colors.Warning}, 0.3):Play()
        wait(0.8)
        
        local keySuccess, data = KeySystem.Verify(KeyInput.Text)
        
        if keySuccess then
            -- نجاح!
            LoginBtn.Text = "✅ " .. Language.Get("Launching")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Success}, 0.3):Play()
            CreateTween(KeyInputStroke, {Color = Colors.Success}, 0.3):Play()
            
            ShowNotification(Frame, "🎉 Welcome VIP! Access Granted", "success", 3)
            
            wait(1)
            
            -- إخفاء شاشة المفتاح بأنيميشن
            CreateTween(KeyScreen, {Position = UDim2.new(0, 0, -1, 0)}, 0.5, Enum.EasingStyle.Back):Play()
            wait(0.5)
            KeyScreen.Visible = false
            
            -- إظهار عناصر VIP
            KlimboBtn.Visible = true
            KlimboBtn.Size = UDim2.new(0, 0, 0, 36)
            CreateTween(KlimboBtn, {Size = UDim2.new(0, 100, 0, 36)}, 0.4, Enum.EasingStyle.Back):Play()
            
            UserInfo.Visible = true
            -- نقل أزرار أخرى
            LangBtn.Position = UDim2.new(1, -470, 0.5, -18)
            MinBtn.Position = UDim2.new(1, -100, 0.5, -18)
            CloseBtn.Position = UDim2.new(1, -55, 0.5, -18)
            
            -- إظهار المتصفح
            ExplorerScreen.Visible = true
            ExplorerScreen.Position = UDim2.new(0, 0, 1, 0)
            CreateTween(ExplorerScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back):Play()
            
            local Sidebar = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/Sidebar.lua", true))()
            Sidebar.Create(ExplorerScreen)
            
        else
            -- فشل
            LoginBtn.Text = "❌ " .. Language.Get("Invalid")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Error}, 0.3):Play()
            CreateTween(KeyInputStroke, {Color = Colors.Error}, 0.3):Play()
            
            -- اهتزاز حقل الإدخال
            for i = 1, 3 do
                CreateTween(KeyInputContainer, {Position = UDim2.new(0.075, 10, 0.45, 0)}, 0.05):Play()
                wait(0.05)
                CreateTween(KeyInputContainer, {Position = UDim2.new(0.075, -10, 0.45, 0)}, 0.05):Play()
                wait(0.05)
            end
            CreateTween(KeyInputContainer, {Position = UDim2.new(0.075, 0, 0.45, 0)}, 0.05):Play()
            
            ShowNotification(Frame, "Invalid key! Please try again.", "error", 3)
            
            wait(2)
            LoginBtn.Text = "🔓 " .. Language.Get("Verify")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Accent}, 0.3):Play()
            CreateTween(KeyInputStroke, {Color = Colors.Accent, Transparency = 0.3}, 0.3):Play()
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- 👑 زر KLIMBO - الوظيفة (مُصلح v3.1)
    -- ═══════════════════════════════════════════════════════════════════════
    KlimboBtn.MouseButton1Click:Connect(function()
        -- تأثير الضغط
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 95, 0, 34)}, 0.1):Play()
        wait(0.1)
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 100, 0, 36)}, 0.1):Play()
        
        if KlimboContainer.Visible then
            -- ═══ إغلاق Klimbo ═══
            CreateTween(KlimboContainer, {BackgroundTransparency = 1}, 0.3):Play()
            wait(0.1)
            for _, child in ipairs(KlimboContainer:GetChildren()) do
                if child:IsA("Frame") then
                    CreateTween(child, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3):Play()
                end
            end
            wait(0.3)
            KlimboContainer.Visible = false
            KlimboContainer:ClearAllChildren()
            KlimboBtn.Text = "👑 KLIMBO"
            
            -- إظهار Explorer
            ExplorerScreen.Visible = true
        else
            -- ═══ فتح Klimbo (مُصلح) ═══
            -- منع الضغط المتكرر أثناء التحميل
            if klimboLoading then return end
            klimboLoading = true
            
            KlimboBtn.Text = "⏳ Loading"
            ShowNotification(Frame, "👑 Loading KLIMBO Menu...", "info", 2)
            
            -- التحميل في thread منفصل حتى لا يجمّد الواجهة
            spawn(function()
                local KlimboMenu = nil
                local loadSuccess = false
                
                -- محاولة التحميل مع إعادة المحاولة 3 مرات
                for attempt = 1, 3 do
                    local ok, result = pcall(function()
                        local code = game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/KlimboMenu.lua", true)
                        
                        -- التحقق من اكتمال الملف (الملف الأصلي ~80KB)
                        if not code or #code < 5000 then
                            error("Incomplete download: " .. tostring(code and #code or 0) .. " bytes")
                        end
                        
                        local fn = loadstring(code)
                        if not fn then
                            error("loadstring failed - file may be corrupted")
                        end
                        
                        return fn()
                    end)
                    
                    if ok and result and type(result) == "table" and type(result.Create) == "function" then
                        KlimboMenu = result
                        loadSuccess = true
                        print("✅ KlimboMenu loaded successfully (attempt " .. attempt .. ")")
                        break
                    else
                        warn("⚠️ KlimboMenu load attempt " .. attempt .. "/3 failed: " .. tostring(result))
                    end
                    
                    if attempt < 3 then
                        task.wait(1)
                    end
                end
                
                if loadSuccess and KlimboMenu then
                    -- ✅ التحميل نجح - الآن نُظهر الحاوية
                    KlimboContainer.Visible = true
                    ExplorerScreen.Visible = false
                    KlimboBtn.Text = "◀ BACK"
                    
                    -- إنشاء القائمة مع حماية pcall
                    local createOk, createErr = pcall(function()
                        KlimboMenu.Create(KlimboContainer)
                    end)
                    
                    if createOk then
                        ShowNotification(Frame, "👑 KLIMBO Menu Ready!", "success", 2)
                        print("🎉 KlimboMenu created successfully!")
                    else
                        -- فشل Create - نعود للحالة الطبيعية
                        warn("❌ KlimboMenu.Create error: " .. tostring(createErr))
                        ShowNotification(Frame, "❌ Menu error - try again", "error", 4)
                        KlimboContainer.Visible = false
                        KlimboContainer:ClearAllChildren()
                        ExplorerScreen.Visible = true
                        KlimboBtn.Text = "👑 KLIMBO"
                    end
                else
                    -- ❌ فشل التحميل بعد 3 محاولات
                    ShowNotification(Frame, "❌ Failed to load KLIMBO Menu after 3 attempts", "error", 4)
                    KlimboContainer.Visible = false
                    ExplorerScreen.Visible = true
                    KlimboBtn.Text = "👑 KLIMBO"
                end
                
                klimboLoading = false
            end)
        end
    end)

    -- جعل النافذة قابلة للسحب
    local dragging, dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ═══════════════════════════════
    -- ⌨️ اختصارات لوحة المفاتيح
    -- ═══════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Escape لإغلاق/تصغير
        if input.KeyCode == Enum.KeyCode.Escape then
            if KlimboContainer.Visible then
                -- إغلاق Klimbo
                KlimboBtn.MouseButton1Click:Fire()
            else
                minimized = not minimized
                MinBtn.MouseButton1Click:Fire()
            end
        end
        
        -- K لفتح Klimbo
        if input.KeyCode == Enum.KeyCode.K and KlimboBtn.Visible then
            KlimboBtn.MouseButton1Click:Fire()
        end
    end)

    print("🚀 WiliExplorer VIP UI Ready!")
    print("👑 Press K to toggle KLIMBO Menu")
    
    return ScreenGui
end

return MainFrame
