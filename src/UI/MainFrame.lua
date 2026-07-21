--[[
    ═══════════════════════════════════════════════════════════════════════════
    🚀 WiliExplorer - MainFrame v4.0 (Fixed Edition)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ إصلاحات:
    • مشكلة KlimboMenu لا تظهر (ZIndex Fix)
    • تحميل Modules مرة واحدة فقط
    • تحسين تداخل النصوص والأزرار
    • تنظيف الأنيميشنات المتسربة
    • تحسين الأداء العام
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local MainFrame = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 📦 تحميل Modules من الذاكرة (بدون إعادة تحميل)
-- ═══════════════════════════════════════════════════════════════════════════
local function GetModule(name)
    if _G.WiliModules and _G.WiliModules[name] then
        return _G.WiliModules[name]
    end
    return nil
end

local function SafeLoadModule(path, name)
    local cached = GetModule(name)
    if cached then return cached end
    
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/" .. path, true))()
    end)
    if ok and result then return result end
    warn("⚠️ Failed to load: " .. path)
    return nil
end

local KeySystem = SafeLoadModule("Security/KeySystem.lua", "KeySystem")
local Stars = SafeLoadModule("Theme/Stars.lua", "Stars")
local Language = SafeLoadModule("Utils/Language.lua", "Language")

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
local activeTweens = {}

local function CreateTween(obj, props, duration, style, direction)
    if not obj or not obj.Parent then return nil end
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out), props)
    table.insert(activeTweens, tween)
    tween:Play()
    tween.Completed:Connect(function()
        for i, t in ipairs(activeTweens) do
            if t == tween then
                table.remove(activeTweens, i)
                break
            end
        end
    end)
    return tween
end

local function AddCorner(parent, radius)
    if not parent then return nil end
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, transparency)
    if not parent then return nil end
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Accent
    s.Thickness = thickness or 2
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📢 نظام الإشعارات
-- ═══════════════════════════════════════════════════════════════════════════
local function ShowNotification(parent, message, notifType, duration)
    if not parent or not parent.Parent then return nil end
    
    local colorMap = {
        success = Colors.Success,
        error = Colors.Error,
        warning = Colors.Warning,
        info = Colors.Accent
    }
    local iconMap = {
        success = "✅",
        error = "❌",
        warning = "⚠️",
        info = "ℹ️"
    }
    
    local color = colorMap[notifType] or Colors.Accent
    local icon = iconMap[notifType] or "ℹ️"
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 340, 0, 55)
    notif.Position = UDim2.new(0.5, -170, 0, -65)
    notif.BackgroundColor3 = Colors.Primary
    notif.BorderSizePixel = 0
    notif.ZIndex = 9999
    notif.Parent = parent
    AddCorner(notif, 12)
    AddStroke(notif, color, 2)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 45, 1, 0)
    iconLabel.Position = UDim2.new(0, 5, 0, 0)
    iconLabel.Text = icon
    iconLabel.TextSize = 24
    iconLabel.BackgroundTransparency = 1
    iconLabel.ZIndex = 10000
    iconLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -60, 1, 0)
    msgLabel.Position = UDim2.new(0, 55, 0, 0)
    msgLabel.Text = message
    msgLabel.TextColor3 = Colors.TextPrimary
    msgLabel.TextSize = 13
    msgLabel.Font = Enum.Font.GothamBold
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.BackgroundTransparency = 1
    msgLabel.ZIndex = 10000
    msgLabel.Parent = notif
    
    CreateTween(notif, {Position = UDim2.new(0.5, -170, 0, 15)}, 0.4, Enum.EasingStyle.Back)
    
    task.delay(duration or 3, function()
        if notif and notif.Parent then
            CreateTween(notif, {Position = UDim2.new(0.5, -170, 0, -65)}, 0.3)
            task.wait(0.35)
            if notif and notif.Parent then
                notif:Destroy()
            end
        end
    end)
    
    return notif
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
    
    task.spawn(function()
        while container and container.Parent do
            for i = 1, 3 do
                if not container or not container.Parent then break end
                
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
                }, duration, Enum.EasingStyle.Linear)
                
                game:GetService("Debris"):AddItem(particle, duration + 1)
            end
            task.wait(0.8)
        end
    end)
    
    return container
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎭 شاشة التحميل الفخمة
-- ═══════════════════════════════════════════════════════════════════════════
local function CreateLoadingScreen(parent)
    local loading = Instance.new("Frame")
    loading.Name = "LoadingScreen"
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.BackgroundColor3 = Colors.Primary
    loading.ZIndex = 500
    loading.Parent = parent
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 10, 35))
    })
    grad.Rotation = 135
    grad.Parent = loading
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 70)
    logo.Position = UDim2.new(0, 0, 0.32, 0)
    logo.Text = "🚀 WiliExplorer"
    logo.TextColor3 = Colors.Accent
    logo.TextSize = 40
    logo.Font = Enum.Font.GothamBlack
    logo.BackgroundTransparency = 1
    logo.ZIndex = 501
    logo.Parent = loading
    
    task.spawn(function()
        while logo and logo.Parent do
            CreateTween(logo, {TextColor3 = Colors.Cyan}, 1)
            task.wait(1)
            if not logo or not logo.Parent then break end
            CreateTween(logo, {TextColor3 = Colors.Accent}, 1)
            task.wait(1)
        end
    end)
    
    local vipBadge = Instance.new("TextLabel")
    vipBadge.Size = UDim2.new(0, 130, 0, 32)
    vipBadge.Position = UDim2.new(0.5, -65, 0.46, 0)
    vipBadge.Text = "👑 VIP ACCESS"
    vipBadge.TextColor3 = Colors.Gold
    vipBadge.TextSize = 13
    vipBadge.Font = Enum.Font.GothamBlack
    vipBadge.BackgroundColor3 = Color3.fromRGB(30, 25, 15)
    vipBadge.ZIndex = 501
    vipBadge.Parent = loading
    AddCorner(vipBadge, 8)
    AddStroke(vipBadge, Colors.Gold, 2)
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.55, 0, 0, 7)
    progressBg.Position = UDim2.new(0.225, 0, 0.57, 0)
    progressBg.BackgroundColor3 = Colors.Tertiary
    progressBg.ZIndex = 501
    progressBg.Parent = loading
    AddCorner(progressBg, 4)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Colors.Accent
    progressFill.ZIndex = 502
    progressFill.Parent = progressBg
    AddCorner(progressFill, 4)
    
    local progGrad = Instance.new("UIGradient")
    progGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Pink),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.Cyan)
    })
    progGrad.Parent = progressFill
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 22)
    loadingText.Position = UDim2.new(0, 0, 0.63, 0)
    loadingText.Text = "جاري التحميل..."
    loadingText.TextColor3 = Colors.TextSecondary
    loadingText.TextSize = 13
    loadingText.Font = Enum.Font.Gotham
    loadingText.BackgroundTransparency = 1
    loadingText.ZIndex = 501
    loadingText.Parent = loading
    
    local loadSteps = {
        {text = "📦 جاري تحميل الوحدات...", progress = 0.2},
        {text = "🎨 تهيئة الواجهة...", progress = 0.4},
        {text = "🔐 فحص الأمان...", progress = 0.6},
        {text = "⚡ تحسين الأداء...", progress = 0.8},
        {text = "✨ تقريباً جاهز...", progress = 0.95},
        {text = "🚀 مرحباً بك في WiliExplorer!", progress = 1}
    }
    
    task.spawn(function()
        for _, step in ipairs(loadSteps) do
            if not loading or not loading.Parent then break end
            loadingText.Text = step.text
            CreateTween(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.4)
            task.wait(0.4)
        end
        task.wait(0.4)
        if loading and loading.Parent then
            CreateTween(loading, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.4)
            if loading and loading.Parent then
                loading:Destroy()
            end
        end
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

    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < 800
    
    local frameWidth = isMobile and viewport.X * 0.95 or 720
    local frameHeight = isMobile and viewport.Y * 0.85 or 520

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
    
    AddCorner(Frame, 18)
    
    local MainStroke = AddStroke(Frame, Colors.Accent, 2)
    task.spawn(function()
        while Frame and Frame.Parent do
            CreateTween(MainStroke, {Color = Colors.Cyan}, 2)
            task.wait(2)
            if not Frame or not Frame.Parent then break end
            CreateTween(MainStroke, {Color = Colors.Accent}, 2)
            task.wait(2)
        end
    end)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 60))
    })
    Gradient.Rotation = 135
    Gradient.Parent = Frame

    if Stars and Stars.Create then
        Stars.Create(Frame, 80)
    end
    
    CreateParticles(Frame)
    CreateLoadingScreen(Frame)

    -- ═══════════════════════════════
    -- الشريط العلوي
    -- ═══════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 52)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.BackgroundTransparency = 0.15
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 100
    TopBar.Parent = Frame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 18)
    TopCorner.Parent = TopBar
    
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, -2)
    TopLine.BackgroundColor3 = Colors.Accent
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 101
    TopLine.Parent = TopBar
    
    task.spawn(function()
        while TopLine and TopLine.Parent do
            CreateTween(TopLine, {BackgroundColor3 = Colors.Pink}, 1.5)
            task.wait(1.5)
            if not TopLine or not TopLine.Parent then break end
            CreateTween(TopLine, {BackgroundColor3 = Colors.Cyan}, 1.5)
            task.wait(1.5)
            if not TopLine or not TopLine.Parent then break end
            CreateTween(TopLine, {BackgroundColor3 = Colors.Accent}, 1.5)
            task.wait(1.5)
        end
    end)

    -- الشعار
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 180, 1, 0)
    Logo.Position = UDim2.new(0, 12, 0, 0)
    Logo.Text = "🚀 WiliExplorer"
    Logo.TextColor3 = Colors.Accent
    Logo.TextSize = 20
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = 101
    Logo.Parent = TopBar
    
    local LogoVIP = Instance.new("TextLabel")
    LogoVIP.Size = UDim2.new(0, 32, 0, 16)
    LogoVIP.Position = UDim2.new(0, 168, 0.5, -8)
    LogoVIP.Text = "VIP"
    LogoVIP.TextColor3 = Colors.Primary
    LogoVIP.TextSize = 9
    LogoVIP.Font = Enum.Font.GothamBlack
    LogoVIP.BackgroundColor3 = Colors.Gold
    LogoVIP.ZIndex = 102
    LogoVIP.Parent = TopBar
    AddCorner(LogoVIP, 4)

    -- ═══════════════════════════════
    -- زر KLIMBO
    -- ═══════════════════════════════
    local KlimboBtn = Instance.new("TextButton")
    KlimboBtn.Name = "KlimboBtn"
    KlimboBtn.Size = UDim2.new(0, 95, 0, 34)
    KlimboBtn.Position = UDim2.new(1, -360, 0.5, -17)
    KlimboBtn.Text = "👑 KLIMBO"
    KlimboBtn.TextColor3 = Colors.Gold
    KlimboBtn.TextSize = 11
    KlimboBtn.Font = Enum.Font.GothamBlack
    KlimboBtn.BackgroundColor3 = Colors.Secondary
    KlimboBtn.ZIndex = 101
    KlimboBtn.Visible = false
    KlimboBtn.Parent = TopBar
    AddCorner(KlimboBtn, 10)
    
    local KlimboGradient = Instance.new("UIGradient")
    KlimboGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Pink),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 50, 150)),
        ColorSequenceKeypoint.new(1, Colors.Cyan)
    })
    KlimboGradient.Rotation = 45
    KlimboGradient.Parent = KlimboBtn
    
    local KlimboStroke = AddStroke(KlimboBtn, Colors.Gold, 2)
    
    task.spawn(function()
        while KlimboBtn and KlimboBtn.Parent do
            CreateTween(KlimboStroke, {Color = Colors.Pink}, 1)
            task.wait(1)
            if not KlimboBtn or not KlimboBtn.Parent then break end
            CreateTween(KlimboStroke, {Color = Colors.Cyan}, 1)
            task.wait(1)
            if not KlimboBtn or not KlimboBtn.Parent then break end
            CreateTween(KlimboStroke, {Color = Colors.Gold}, 1)
            task.wait(1)
        end
    end)
    
    KlimboBtn.MouseEnter:Connect(function()
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 105, 0, 38)}, 0.2)
    end)
    KlimboBtn.MouseLeave:Connect(function()
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 95, 0, 34)}, 0.2)
    end)

    -- زر اللغة
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 80, 0, 34)
    LangBtn.Position = UDim2.new(1, -255, 0.5, -17)
    LangBtn.Text = "🌐 عربي"
    LangBtn.TextColor3 = Colors.TextPrimary
    LangBtn.TextSize = 12
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 180)
    LangBtn.ZIndex = 101
    LangBtn.Parent = TopBar
    AddCorner(LangBtn, 10)
    AddStroke(LangBtn, Colors.Accent, 1, 0.5)

    -- زر التصغير
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 34, 0, 34)
    MinBtn.Position = UDim2.new(1, -165, 0.5, -17)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Colors.TextPrimary
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
    MinBtn.ZIndex = 101
    MinBtn.Parent = TopBar
    AddCorner(MinBtn, 10)
    
    MinBtn.MouseEnter:Connect(function()
        CreateTween(MinBtn, {BackgroundColor3 = Color3.fromRGB(80, 90, 140)}, 0.2)
    end)
    MinBtn.MouseLeave:Connect(function()
        CreateTween(MinBtn, {BackgroundColor3 = Color3.fromRGB(60, 70, 120)}, 0.2)
    end)

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 34, 0, 34)
    CloseBtn.Position = UDim2.new(1, -120, 0.5, -17)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.TextPrimary
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Colors.Error
    CloseBtn.ZIndex = 101
    CloseBtn.Parent = TopBar
    AddCorner(CloseBtn, 10)
    
    CloseBtn.MouseEnter:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 110)}, 0.2)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CreateTween(CloseBtn, {BackgroundColor3 = Colors.Error}, 0.2)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        CreateTween(Frame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        task.wait(0.35)
        if ScreenGui and ScreenGui.Parent then
            ScreenGui:Destroy()
        end
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, 52)}, 0.3, Enum.EasingStyle.Back)
            MinBtn.Text = "+"
        else
            CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
            MinBtn.Text = "—"
        end
    end)

    -- معلومات المستخدم
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.Size = UDim2.new(0, 140, 0, 34)
    UserInfo.Position = UDim2.new(1, -70, 0.5, -17)
    UserInfo.BackgroundColor3 = Colors.Tertiary
    UserInfo.BackgroundTransparency = 0.5
    UserInfo.ZIndex = 101
    UserInfo.Visible = false
    UserInfo.Parent = TopBar
    AddCorner(UserInfo, 10)
    
    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Size = UDim2.new(0, 26, 0, 26)
    UserAvatar.Position = UDim2.new(0, 4, 0.5, -13)
    UserAvatar.BackgroundColor3 = Colors.Accent
    UserAvatar.ZIndex = 102
    UserAvatar.Parent = UserInfo
    AddCorner(UserAvatar, 13)
    pcall(function()
        UserAvatar.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    
    local UserName = Instance.new("TextLabel")
    UserName.Size = UDim2.new(1, -35, 1, 0)
    UserName.Position = UDim2.new(0, 34, 0, 0)
    UserName.Text = Players.LocalPlayer.Name:sub(1, 10)
    UserName.TextColor3 = Colors.TextPrimary
    UserName.TextSize = 10
    UserName.Font = Enum.Font.GothamBold
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.ZIndex = 102
    UserName.Parent = UserInfo

    -- ═══════════════════════════════
    -- منطقة المحتوى
    -- ═══════════════════════════════
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -52)
    Content.Position = UDim2.new(0, 0, 0, 52)
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
    KeyScreen.ZIndex = 50
    KeyScreen.Parent = Content

    local Title = Instance.new("TextLabel")
    Title.Text = "🌌 WiliExplorer"
    Title.Size = UDim2.new(1, 0, 0, 65)
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.TextColor3 = Colors.Accent
    Title.TextSize = isMobile and 30 or 40
    Title.Font = Enum.Font.GothamBlack
    Title.BackgroundTransparency = 1
    Title.ZIndex = 51
    Title.Parent = KeyScreen
    
    task.spawn(function()
        while Title and Title.Parent do
            CreateTween(Title, {TextColor3 = Colors.Cyan}, 1.5)
            task.wait(1.5)
            if not Title or not Title.Parent then break end
            CreateTween(Title, {TextColor3 = Colors.Accent}, 1.5)
            task.wait(1.5)
        end
    end)

    local Lang = Language or {Get = function(k) return k end, Current = "en"}
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = Lang.Get("Welcome")
    Subtitle.Size = UDim2.new(1, 0, 0, 28)
    Subtitle.Position = UDim2.new(0, 0, 0.23, 0)
    Subtitle.TextColor3 = Colors.TextSecondary
    Subtitle.TextSize = 15
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 51
    Subtitle.Parent = KeyScreen
    
    local VIPLabel = Instance.new("TextLabel")
    VIPLabel.Size = UDim2.new(0, 135, 0, 32)
    VIPLabel.Position = UDim2.new(0.5, -67, 0.31, 0)
    VIPLabel.Text = "👑 VIP EXCLUSIVE"
    VIPLabel.TextColor3 = Colors.Gold
    VIPLabel.TextSize = 12
    VIPLabel.Font = Enum.Font.GothamBlack
    VIPLabel.BackgroundColor3 = Color3.fromRGB(40, 35, 20)
    VIPLabel.ZIndex = 51
    VIPLabel.Parent = KeyScreen
    AddCorner(VIPLabel, 8)
    AddStroke(VIPLabel, Colors.Gold, 2)

    local KeyInputContainer = Instance.new("Frame")
    KeyInputContainer.Size = UDim2.new(0.8, 0, 0, 55)
    KeyInputContainer.Position = UDim2.new(0.1, 0, 0.43, 0)
    KeyInputContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    KeyInputContainer.ZIndex = 51
    KeyInputContainer.Parent = KeyScreen
    AddCorner(KeyInputContainer, 14)
    
    local KeyInputStroke = AddStroke(KeyInputContainer, Colors.Accent, 2, 0.3)
    
    local KeyIcon = Instance.new("TextLabel")
    KeyIcon.Size = UDim2.new(0, 45, 1, 0)
    KeyIcon.Text = "🔑"
    KeyIcon.TextSize = 22
    KeyIcon.BackgroundTransparency = 1
    KeyIcon.ZIndex = 52
    KeyIcon.Parent = KeyInputContainer
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -55, 1, 0)
    KeyInput.Position = UDim2.new(0, 50, 0, 0)
    KeyInput.PlaceholderText = Lang.Get("EnterKey")
    KeyInput.Text = ""
    KeyInput.TextColor3 = Colors.TextPrimary
    KeyInput.PlaceholderColor3 = Colors.TextSecondary
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 15
    KeyInput.ClearTextOnFocus = false
    KeyInput.BackgroundTransparency = 1
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.ZIndex = 52
    KeyInput.Parent = KeyInputContainer
    
    local KeyInputPad = Instance.new("UIPadding")
    KeyInputPad.PaddingRight = UDim.new(0, 10)
    KeyInputPad.Parent = KeyInput
    
    KeyInput.Focused:Connect(function()
        CreateTween(KeyInputStroke, {Color = Colors.Accent, Transparency = 0}, 0.2)
    end)
    KeyInput.FocusLost:Connect(function()
        CreateTween(KeyInputStroke, {Transparency = 0.3}, 0.2)
    end)

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "🔓 " .. Lang.Get("Verify")
    LoginBtn.Size = UDim2.new(0.65, 0, 0, 50)
    LoginBtn.Position = UDim2.new(0.175, 0, 0.59, 0)
    LoginBtn.BackgroundColor3 = Colors.Accent
    LoginBtn.TextColor3 = Colors.Primary
    LoginBtn.Font = Enum.Font.GothamBlack
    LoginBtn.TextSize = 16
    LoginBtn.ZIndex = 51
    LoginBtn.Parent = KeyScreen
    AddCorner(LoginBtn, 14)

    local LoginGradient = Instance.new("UIGradient")
    LoginGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 152, 219))
    })
    LoginGradient.Rotation = 90
    LoginGradient.Parent = LoginBtn
    
    LoginBtn.MouseEnter:Connect(function()
        CreateTween(LoginBtn, {Size = UDim2.new(0.67, 0, 0, 53)}, 0.2)
    end)
    LoginBtn.MouseLeave:Connect(function()
        CreateTween(LoginBtn, {Size = UDim2.new(0.65, 0, 0, 50)}, 0.2)
    end)
    
    local HelpText = Instance.new("TextLabel")
    HelpText.Size = UDim2.new(1, 0, 0, 22)
    HelpText.Position = UDim2.new(0, 0, 0.76, 0)
    HelpText.Text = "💬 Need a key? Contact: @WiliExplorer"
    HelpText.TextColor3 = Colors.TextSecondary
    HelpText.TextSize = 11
    HelpText.Font = Enum.Font.Gotham
    HelpText.BackgroundTransparency = 1
    HelpText.ZIndex = 51
    HelpText.Parent = KeyScreen
    
    local Copyright = Instance.new("TextLabel")
    Copyright.Size = UDim2.new(1, 0, 0, 18)
    Copyright.Position = UDim2.new(0, 0, 0.92, 0)
    Copyright.Text = "© 2025 WiliExplorer - All Rights Reserved"
    Copyright.TextColor3 = Color3.fromRGB(80, 90, 120)
    Copyright.TextSize = 10
    Copyright.Font = Enum.Font.Gotham
    Copyright.BackgroundTransparency = 1
    Copyright.ZIndex = 51
    Copyright.Parent = KeyScreen

    -- ═══════════════════════════════
    -- شاشة المتصفح
    -- ═══════════════════════════════
    local ExplorerScreen = Instance.new("Frame")
    ExplorerScreen.Name = "ExplorerScreen"
    ExplorerScreen.Size = UDim2.new(1, 0, 1, 0)
    ExplorerScreen.BackgroundTransparency = 1
    ExplorerScreen.Visible = false
    ExplorerScreen.ZIndex = 50
    ExplorerScreen.Parent = Content
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- 🎯 حاوية KlimboMenu (الإصلاح الرئيسي)
    -- ZIndex = 50 لتطابق ExplorerScreen وليس أعلى منه
    -- ═══════════════════════════════════════════════════════════════════════
    local KlimboContainer = Instance.new("Frame")
    KlimboContainer.Name = "KlimboContainer"
    KlimboContainer.Size = UDim2.new(1, 0, 1, 0)
    KlimboContainer.BackgroundTransparency = 1
    KlimboContainer.Visible = false
    KlimboContainer.ZIndex = 50
    KlimboContainer.Parent = Content
    
    local klimboLoading = false

    -- تحديث اللغة
    if LangBtn and Lang.Toggle then
        LangBtn.MouseButton1Click:Connect(function()
            Lang.Toggle()
            LangBtn.Text = Lang.Current == "en" and "🌐 عربي" or "🌐 English"
            
            Subtitle.Text = Lang.Get("Welcome")
            KeyInput.PlaceholderText = Lang.Get("EnterKey")
            LoginBtn.Text = "🔓 " .. Lang.Get("Verify")
            
            ShowNotification(Frame, Lang.Current == "ar" and "تم تغيير اللغة للعربية" or "Language changed to English", "info", 2)
            
            if ExplorerScreen.Visible then
                ExplorerScreen:ClearAllChildren()
                local Sidebar = SafeLoadModule("UI/Sidebar.lua", "Sidebar")
                if Sidebar and Sidebar.Create then
                    Sidebar.Create(ExplorerScreen)
                end
            end
        end)
    end

    -- التحقق من المفتاح
    LoginBtn.MouseButton1Click:Connect(function()
        CreateTween(LoginBtn, {Size = UDim2.new(0.63, 0, 0, 47)}, 0.1)
        task.wait(0.1)
        CreateTween(LoginBtn, {Size = UDim2.new(0.65, 0, 0, 50)}, 0.1)
        
        LoginBtn.Text = "⏳ " .. Lang.Get("Verifying")
        CreateTween(LoginBtn, {BackgroundColor3 = Color3.fromRGB(100, 150, 200)}, 0.3)
        CreateTween(KeyInputStroke, {Color = Colors.Warning}, 0.3)
        task.wait(0.8)
        
        local keySuccess, data = KeySystem.Verify(KeyInput.Text)
        
        if keySuccess then
            LoginBtn.Text = "✅ " .. Lang.Get("Launching")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Success}, 0.3)
            CreateTween(KeyInputStroke, {Color = Colors.Success}, 0.3)
            
            ShowNotification(Frame, "🎉 Welcome VIP! Access Granted", "success", 3)
            
            task.wait(1)
            
            CreateTween(KeyScreen, {Position = UDim2.new(0, 0, -1, 0)}, 0.5, Enum.EasingStyle.Back)
            task.wait(0.5)
            KeyScreen.Visible = false
            
            KlimboBtn.Visible = true
            KlimboBtn.Size = UDim2.new(0, 0, 0, 34)
            CreateTween(KlimboBtn, {Size = UDim2.new(0, 95, 0, 34)}, 0.4, Enum.EasingStyle.Back)
            
            UserInfo.Visible = true
            LangBtn.Position = UDim2.new(1, -455, 0.5, -17)
            MinBtn.Position = UDim2.new(1, -95, 0.5, -17)
            CloseBtn.Position = UDim2.new(1, -52, 0.5, -17)
            
            ExplorerScreen.Visible = true
            ExplorerScreen.Position = UDim2.new(0, 0, 1, 0)
            CreateTween(ExplorerScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
            
            local Sidebar = SafeLoadModule("UI/Sidebar.lua", "Sidebar")
            if Sidebar and Sidebar.Create then
                Sidebar.Create(ExplorerScreen)
            end
            
        else
            LoginBtn.Text = "❌ " .. Lang.Get("Invalid")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Error}, 0.3)
            CreateTween(KeyInputStroke, {Color = Colors.Error}, 0.3)
            
            for i = 1, 3 do
                CreateTween(KeyInputContainer, {Position = UDim2.new(0.1, 10, 0.43, 0)}, 0.05)
                task.wait(0.05)
                CreateTween(KeyInputContainer, {Position = UDim2.new(0.1, -10, 0.43, 0)}, 0.05)
                task.wait(0.05)
            end
            CreateTween(KeyInputContainer, {Position = UDim2.new(0.1, 0, 0.43, 0)}, 0.05)
            
            ShowNotification(Frame, "Invalid key! Please try again.", "error", 3)
            
            task.wait(2)
            LoginBtn.Text = "🔓 " .. Lang.Get("Verify")
            CreateTween(LoginBtn, {BackgroundColor3 = Colors.Accent}, 0.3)
            CreateTween(KeyInputStroke, {Color = Colors.Accent, Transparency = 0.3}, 0.3)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- 👑 زر KLIMBO - الإصلاح الكامل
    -- ═══════════════════════════════════════════════════════════════════════
    KlimboBtn.MouseButton1Click:Connect(function()
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 90, 0, 32)}, 0.1)
        task.wait(0.1)
        CreateTween(KlimboBtn, {Size = UDim2.new(0, 95, 0, 34)}, 0.1)
        
        if KlimboContainer.Visible then
            -- ═══ إغلاق Klimbo ═══
            KlimboContainer:ClearAllChildren()
            KlimboContainer.Visible = false
            ExplorerScreen.Visible = true
            KlimboBtn.Text = "👑 KLIMBO"
            return
        end
        
        -- ═══ فتح Klimbo ═══
        if klimboLoading then return end
        klimboLoading = true
        
        KlimboBtn.Text = "⏳ Loading"
        ShowNotification(Frame, "👑 Loading KLIMBO Menu...", "info", 2)
        
        task.spawn(function()
            local KlimboMenu = nil
            local loadSuccess = false
            
            for attempt = 1, 3 do
                local ok, result = pcall(function()
                    local code = game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/KlimboMenu.lua", true)
                    
                    if not code or #code < 2000 then
                        error("Incomplete download: " .. tostring(code and #code or 0) .. " bytes")
                    end
                    
                    local fn = loadstring(code)
                    if not fn then
                        error("loadstring failed")
                    end
                    
                    return fn()
                end)
                
                if ok and result and type(result) == "table" and type(result.Create) == "function" then
                    KlimboMenu = result
                    loadSuccess = true
                    print("✅ KlimboMenu loaded (attempt " .. attempt .. ")")
                    break
                else
                    warn("⚠️ KlimboMenu attempt " .. attempt .. "/3 failed: " .. tostring(result))
                end
                
                if attempt < 3 then
                    task.wait(1)
                end
            end
            
            if loadSuccess and KlimboMenu then
                -- ═══ الإصلاح الرئيسي: إظهار الحاوية أولاً ثم إنشاء القائمة ═══
                KlimboContainer.Visible = true
                ExplorerScreen.Visible = false
                KlimboBtn.Text = "◀ BACK"
                
                local createOk, createErr = pcall(function()
                    KlimboMenu.Create(KlimboContainer)
                end)
                
                if createOk then
                    ShowNotification(Frame, "👑 KLIMBO Menu Ready!", "success", 2)
                    print("🎉 KlimboMenu created successfully!")
                    
                    -- ═══ التحقق من أن العناصر فعلاً تظهر ═══
                    task.wait(0.5)
                    local childCount = #KlimboContainer:GetChildren()
                    if childCount == 0 then
                        warn("⚠️ KlimboContainer has no children! UI may not render.")
                        ShowNotification(Frame, "⚠️ Menu loaded but may be empty", "warning", 3)
                    else
                        print("✅ KlimboContainer has " .. childCount .. " children")
                    end
                else
                    warn("❌ KlimboMenu.Create error: " .. tostring(createErr))
                    ShowNotification(Frame, "❌ Menu error: " .. tostring(createErr):sub(1, 50), "error", 4)
                    KlimboContainer:ClearAllChildren()
                    KlimboContainer.Visible = false
                    ExplorerScreen.Visible = true
                    KlimboBtn.Text = "👑 KLIMBO"
                end
            else
                ShowNotification(Frame, "❌ Failed to load KLIMBO Menu", "error", 4)
                KlimboContainer.Visible = false
                ExplorerScreen.Visible = true
                KlimboBtn.Text = "👑 KLIMBO"
            end
            
            klimboLoading = false
        end)
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

    -- اختصارات لوحة المفاتيح
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Escape then
            if KlimboContainer.Visible then
                KlimboContainer:ClearAllChildren()
                KlimboContainer.Visible = false
                ExplorerScreen.Visible = true
                KlimboBtn.Text = "👑 KLIMBO"
            else
                minimized = not minimized
                if minimized then
                    CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, 52)}, 0.3, Enum.EasingStyle.Back)
                    MinBtn.Text = "+"
                else
                    CreateTween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
                    MinBtn.Text = "—"
                end
            end
        end
        
        if input.KeyCode == Enum.KeyCode.K and KlimboBtn.Visible then
            KlimboBtn.MouseButton1Click:Fire()
        end
    end)

    print("🚀 WiliExplorer VIP UI Ready!")
    print("👑 Press K to toggle KLIMBO Menu")
    
    return ScreenGui
end

return MainFrame
