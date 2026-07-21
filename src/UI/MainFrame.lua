--[[
    ═══════════════════════════════════════════════════════════════════════════
    🚀 WiliExplorer - MainFrame v5.0 (Ultimate Edition)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ واجهة موحدة ومتناسقة
    ✅ دعم كامل للهاتف
    ✅ أنيميشنات سلسة
    ✅ نظام ثيمات
    ✅ معالجة أخطاء محسنة
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local MainFrame = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 تحميل Modules من الذاكرة
-- ═══════════════════════════════════════════════════════════════════════
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
    return nil
end

local KeySystem = SafeLoadModule("Security/KeySystem.lua", "KeySystem")
local Stars = SafeLoadModule("Theme/Stars.lua", "Stars")
local Language = SafeLoadModule("Utils/Language.lua", "Language")
local Colors = SafeLoadModule("Theme/Colors.lua", "Colors")

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان (من Theme System)
-- ═══════════════════════════════════════════════════════════════════════
local C = Colors and Colors.Current or {
    BG_Primary = Color3.fromRGB(8, 8, 18),
    BG_Secondary = Color3.fromRGB(12, 12, 28),
    BG_Header = Color3.fromRGB(10, 10, 25),
    Accent = Color3.fromRGB(0, 212, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Primary = Color3.fromRGB(255, 0, 128),
    Secondary = Color3.fromRGB(0, 255, 255),
    Success = Color3.fromRGB(0, 255, 100),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Text_Primary = Color3.fromRGB(255, 255, 255),
    Text_Secondary = Color3.fromRGB(150, 170, 200),
    Border = Color3.fromRGB(40, 40, 70),
    Separator = Color3.fromRGB(35, 35, 65)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local activeTweens = {}

local function Tween(obj, props, duration, style, direction)
    if not obj or not obj.Parent then return nil end
    local tween = TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    ), props)
    table.insert(activeTweens, tween)
    tween:Play()
    tween.Completed:Connect(function()
        for i, t in ipairs(activeTweens) do
            if t == tween then table.remove(activeTweens, i); break end
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
    s.Color = color or C.Accent
    s.Thickness = thickness or 2
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local Lang = Language or {Get = function(k) return k end, Current = "en"}

-- ═══════════════════════════════════════════════════════════════════════
-- 📢 نظام الإشعارات المدمج
-- ═══════════════════════════════════════════════════════════════════════
local NotifContainer = nil

local function ShowNotification(message, notifType, duration)
    local colorMap = {
        success = C.Success, error = C.Error,
        warning = C.Warning, info = C.Accent
    }
    local iconMap = {
        success = "✅", error = "❌", warning = "⚠️", info = "ℹ️"
    }
    
    local color = colorMap[notifType] or C.Accent
    local icon = iconMap[notifType] or "ℹ️"
    
    if not NotifContainer or not NotifContainer.Parent then
        local gui = Instance.new("ScreenGui")
        gui.Name = "WiliNotifs"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
        
        NotifContainer = Instance.new("Frame")
        NotifContainer.Size = UDim2.new(0, 250, 1, 0)
        NotifContainer.Position = UDim2.new(1, -260, 0, 0)
        NotifContainer.BackgroundTransparency = 1
        NotifContainer.Parent = gui
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 4)
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Parent = NotifContainer
        
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 5)
        pad.Parent = NotifContainer
    end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 32)
    notif.BackgroundColor3 = C.BG_Primary
    notif.BorderSizePixel = 0
    notif.ZIndex = 9999
    notif.Parent = NotifContainer
    AddCorner(notif, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = notif
    
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 2, 0, 0)
    iconLbl.Text = icon
    iconLbl.TextSize = 14
    iconLbl.BackgroundTransparency = 1
    iconLbl.ZIndex = 10000
    iconLbl.Parent = notif
    
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -32, 1, 0)
    msgLbl.Position = UDim2.new(0, 30, 0, 0)
    msgLbl.Text = message
    msgLbl.TextColor3 = C.Text_Primary
    msgLbl.TextSize = 11
    msgLbl.Font = Enum.Font.GothamBold
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextTruncate = Enum.TextTruncate.AtEnd
    msgLbl.BackgroundTransparency = 1
    msgLbl.ZIndex = 10000
    msgLbl.Parent = notif
    
    notif.Position = UDim2.new(1, 0, 0, 0)
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back)
    
    task.delay(duration or 2.5, function()
        if notif and notif.Parent then
            Tween(notif, {BackgroundTransparency = 1}, 0.2)
            task.wait(0.25)
            if notif and notif.Parent then notif:Destroy() end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎆 إنشاء تأثيرات بصرية
-- ═══════════════════════════════════════════════════════════════════════
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
            for i = 1, 2 do
                if not container or not container.Parent then break end
                
                local particle = Instance.new("Frame")
                particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
                particle.Position = UDim2.new(math.random(), 0, 1.1, 0)
                particle.BackgroundColor3 = i % 2 == 0 and C.Accent or C.Gold
                particle.BackgroundTransparency = 0.4
                particle.BorderSizePixel = 0
                particle.ZIndex = 2
                particle.Parent = container
                AddCorner(particle, 10)
                
                local duration = math.random(40, 80) / 10
                Tween(particle, {
                    Position = UDim2.new(math.random(), 0, -0.1, 0),
                    BackgroundTransparency = 1,
                    Rotation = math.random(-180, 180)
                }, duration, Enum.EasingStyle.Linear)
                
                game:GetService("Debris"):AddItem(particle, duration + 1)
            end
            task.wait(1)
        end
    end)
    
    return container
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎭 شاشة التحميل
-- ═══════════════════════════════════════════════════════════════════════
local function CreateLoadingScreen(parent)
    local loading = Instance.new("Frame")
    loading.Name = "LoadingScreen"
    loading.Size = UDim2.new(1, 0, 1, 0)
    loading.BackgroundColor3 = C.BG_Primary
    loading.ZIndex = 500
    loading.Parent = parent
    
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.BG_Primary),
        ColorSequenceKeypoint.new(0.5, C.BG_Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 10, 35))
    })
    grad.Rotation = 135
    grad.Parent = loading
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, 0, 0, 65)
    logo.Position = UDim2.new(0, 0, 0.3, 0)
    logo.Text = "🚀 WiliExplorer"
    logo.TextColor3 = C.Accent
    logo.TextSize = 38
    logo.Font = Enum.Font.GothamBlack
    logo.BackgroundTransparency = 1
    logo.ZIndex = 501
    logo.Parent = loading
    
    task.spawn(function()
        while logo and logo.Parent do
            Tween(logo, {TextColor3 = C.Secondary}, 1.2)
            task.wait(1.2)
            if not logo or not logo.Parent then break end
            Tween(logo, {TextColor3 = C.Accent}, 1.2)
            task.wait(1.2)
        end
    end)
    
    local vipBadge = Instance.new("TextLabel")
    vipBadge.Size = UDim2.new(0, 125, 0, 30)
    vipBadge.Position = UDim2.new(0.5, -62, 0.44, 0)
    vipBadge.Text = "👑 VIP ACCESS"
    vipBadge.TextColor3 = C.Gold
    vipBadge.TextSize = 12
    vipBadge.Font = Enum.Font.GothamBlack
    vipBadge.BackgroundColor3 = Color3.fromRGB(30, 25, 15)
    vipBadge.ZIndex = 501
    vipBadge.Parent = loading
    AddCorner(vipBadge, 8)
    AddStroke(vipBadge, C.Gold, 2)
    
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0.5, 0, 0, 6)
    progressBg.Position = UDim2.new(0.25, 0, 0.55, 0)
    progressBg.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    progressBg.ZIndex = 501
    progressBg.Parent = loading
    AddCorner(progressBg, 3)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = C.Accent
    progressFill.ZIndex = 502
    progressFill.Parent = progressBg
    AddCorner(progressFill, 3)
    
    local progGrad = Instance.new("UIGradient")
    progGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Primary),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1, C.Secondary)
    })
    progGrad.Parent = progressFill
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 20)
    loadingText.Position = UDim2.new(0, 0, 0.6, 0)
    loadingText.Text = "جاري التحميل..."
    loadingText.TextColor3 = C.Text_Secondary
    loadingText.TextSize = 12
    loadingText.Font = Enum.Font.Gotham
    loadingText.BackgroundTransparency = 1
    loadingText.ZIndex = 501
    loadingText.Parent = loading
    
    local loadSteps = {
        {text = "📦 جاري تحميل الوحدات...", progress = 0.15},
        {text = "🔐 فحص الأمان...", progress = 0.3},
        {text = "🎨 تحميل المظهر...", progress = 0.45},
        {text = "⚙️ تهيئة النظام...", progress = 0.6},
        {text = "🖥️ إنشاء الواجهة...", progress = 0.8},
        {text = "✨ تقريباً جاهز...", progress = 0.95},
        {text = "🚀 مرحباً بك!", progress = 1}
    }
    
    task.spawn(function()
        for _, step in ipairs(loadSteps) do
            if not loading or not loading.Parent then break end
            loadingText.Text = step.text
            Tween(progressFill, {Size = UDim2.new(step.progress, 0, 1, 0)}, 0.35)
            task.wait(0.35)
        end
        task.wait(0.3)
        if loading and loading.Parent then
            Tween(loading, {BackgroundTransparency = 1}, 0.4)
            task.wait(0.45)
            if loading and loading.Parent then loading:Destroy() end
        end
    end)
    
    return loading
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎮 الدالة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════
function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
    Frame.BackgroundColor3 = C.BG_Primary
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    AddCorner(Frame, 16)
    
    local MainStroke = AddStroke(Frame, C.Accent, 2)
    task.spawn(function()
        while Frame and Frame.Parent do
            Tween(MainStroke, {Color = C.Secondary}, 2)
            task.wait(2)
            if not Frame or not Frame.Parent then break end
            Tween(MainStroke, {Color = C.Accent}, 2)
            task.wait(2)
        end
    end)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.BG_Primary),
        ColorSequenceKeypoint.new(0.5, C.BG_Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 45))
    })
    Gradient.Rotation = 135
    Gradient.Parent = Frame

    if Stars and Stars.Create then
        Stars.Create(Frame, 70)
    end
    
    CreateParticles(Frame)
    CreateLoadingScreen(Frame)

    -- ═══════════════════════════════
    -- الشريط العلوي
    -- ═══════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = C.BG_Header
    TopBar.BackgroundTransparency = 0.1
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 100
    TopBar.Parent = Frame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 16)
    TopCorner.Parent = TopBar
    
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, -2)
    TopLine.BackgroundColor3 = C.Accent
    TopLine.BorderSizePixel = 0
    TopLine.ZIndex = 101
    TopLine.Parent = TopBar
    
    task.spawn(function()
        while TopLine and TopLine.Parent do
            Tween(TopLine, {BackgroundColor3 = C.Primary}, 1.5)
            task.wait(1.5)
            if not TopLine or not TopLine.Parent then break end
            Tween(TopLine, {BackgroundColor3 = C.Secondary}, 1.5)
            task.wait(1.5)
            if not TopLine or not TopLine.Parent then break end
            Tween(TopLine, {BackgroundColor3 = C.Accent}, 1.5)
            task.wait(1.5)
        end
    end)

    -- الشعار
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 170, 1, 0)
    Logo.Position = UDim2.new(0, 10, 0, 0)
    Logo.Text = "🚀 WiliExplorer"
    Logo.TextColor3 = C.Accent
    Logo.TextSize = 18
    Logo.Font = Enum.Font.GothamBlack
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = 101
    Logo.Parent = TopBar
    
    local LogoVIP = Instance.new("TextLabel")
    LogoVIP.Size = UDim2.new(0, 30, 0, 14)
    LogoVIP.Position = UDim2.new(0, 158, 0.5, -7)
    LogoVIP.Text = "VIP"
    LogoVIP.TextColor3 = C.BG_Primary
    LogoVIP.TextSize = 8
    LogoVIP.Font = Enum.Font.GothamBlack
    LogoVIP.BackgroundColor3 = C.Gold
    LogoVIP.ZIndex = 102
    LogoVIP.Parent = TopBar
    AddCorner(LogoVIP, 4)

    -- ═══════════════════════════════
    -- زر KLIMBO
    -- ═══════════════════════════════
    local KlimboBtn = Instance.new("TextButton")
    KlimboBtn.Name = "KlimboBtn"
    KlimboBtn.Size = UDim2.new(0, 90, 0, 30)
    KlimboBtn.Position = UDim2.new(1, -350, 0.5, -15)
    KlimboBtn.Text = "👑 KLIMBO"
    KlimboBtn.TextColor3 = C.Gold
    KlimboBtn.TextSize = 10
    KlimboBtn.Font = Enum.Font.GothamBlack
    KlimboBtn.BackgroundColor3 = C.BG_Secondary
    KlimboBtn.ZIndex = 101
    KlimboBtn.Visible = false
    KlimboBtn.Parent = TopBar
    AddCorner(KlimboBtn, 8)
    
    local KlimboStroke = AddStroke(KlimboBtn, C.Gold, 2)
    
    task.spawn(function()
        while KlimboBtn and KlimboBtn.Parent do
            Tween(KlimboStroke, {Color = C.Primary}, 1)
            task.wait(1)
            if not KlimboBtn or not KlimboBtn.Parent then break end
            Tween(KlimboStroke, {Color = C.Secondary}, 1)
            task.wait(1)
            if not KlimboBtn or not KlimboBtn.Parent then break end
            Tween(KlimboStroke, {Color = C.Gold}, 1)
            task.wait(1)
        end
    end)
    
    KlimboBtn.MouseEnter:Connect(function()
        Tween(KlimboBtn, {Size = UDim2.new(0, 100, 0, 34)}, 0.15)
    end)
    KlimboBtn.MouseLeave:Connect(function()
        Tween(KlimboBtn, {Size = UDim2.new(0, 90, 0, 30)}, 0.15)
    end)

    -- زر اللغة
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 75, 0, 30)
    LangBtn.Position = UDim2.new(1, -250, 0.5, -15)
    LangBtn.Text = "🌐 عربي"
    LangBtn.TextColor3 = C.Text_Primary
    LangBtn.TextSize = 11
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 170)
    LangBtn.ZIndex = 101
    LangBtn.Parent = TopBar
    AddCorner(LangBtn, 8)
    AddStroke(LangBtn, C.Accent, 1, 0.5)

    -- زر التصغير
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -165, 0.5, -15)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = C.Text_Primary
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 110)
    MinBtn.ZIndex = 101
    MinBtn.Parent = TopBar
    AddCorner(MinBtn, 8)
    
    MinBtn.MouseEnter:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(70, 80, 130)}, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(55, 65, 110)}, 0.15)
    end)

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -125, 0.5, -15)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = C.Text_Primary
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = C.Error
    CloseBtn.ZIndex = 101
    CloseBtn.Parent = TopBar
    AddCorner(CloseBtn, 8)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 90, 100)}, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = C.Error}, 0.15)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Frame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
        task.wait(0.35)
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, 48)}, 0.3, Enum.EasingStyle.Back)
            MinBtn.Text = "+"
        else
            Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
            MinBtn.Text = "—"
        end
    end)

    -- معلومات المستخدم
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.Size = UDim2.new(0, 130, 0, 30)
    UserInfo.Position = UDim2.new(1, -65, 0.5, -15)
    UserInfo.BackgroundColor3 = Color3.fromRGB(22, 22, 45)
    UserInfo.BackgroundTransparency = 0.4
    UserInfo.ZIndex = 101
    UserInfo.Visible = false
    UserInfo.Parent = TopBar
    AddCorner(UserInfo, 8)
    
    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Size = UDim2.new(0, 24, 0, 24)
    UserAvatar.Position = UDim2.new(0, 3, 0.5, -12)
    UserAvatar.BackgroundColor3 = C.Accent
    UserAvatar.ZIndex = 102
    UserAvatar.Parent = UserInfo
    AddCorner(UserAvatar, 12)
    pcall(function()
        UserAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    
    local UserName = Instance.new("TextLabel")
    UserName.Size = UDim2.new(1, -30, 1, 0)
    UserName.Position = UDim2.new(0, 30, 0, 0)
    UserName.Text = LocalPlayer.Name:sub(1, 10)
    UserName.TextColor3 = C.Text_Primary
    UserName.TextSize = 9
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
    Content.Size = UDim2.new(1, 0, 1, -48)
    Content.Position = UDim2.new(0, 0, 0, 48)
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
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Position = UDim2.new(0, 0, 0.08, 0)
    Title.TextColor3 = C.Accent
    Title.TextSize = isMobile and 28 or 38
    Title.Font = Enum.Font.GothamBlack
    Title.BackgroundTransparency = 1
    Title.ZIndex = 51
    Title.Parent = KeyScreen
    
    task.spawn(function()
        while Title and Title.Parent do
            Tween(Title, {TextColor3 = C.Secondary}, 1.5)
            task.wait(1.5)
            if not Title or not Title.Parent then break end
            Tween(Title, {TextColor3 = C.Accent}, 1.5)
            task.wait(1.5)
        end
    end)

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = Lang.Get("Welcome")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0.22, 0)
    Subtitle.TextColor3 = C.Text_Secondary
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 51
    Subtitle.Parent = KeyScreen
    
    local VIPLabel = Instance.new("TextLabel")
    VIPLabel.Size = UDim2.new(0, 130, 0, 28)
    VIPLabel.Position = UDim2.new(0.5, -65, 0.3, 0)
    VIPLabel.Text = "👑 VIP EXCLUSIVE"
    VIPLabel.TextColor3 = C.Gold
    VIPLabel.TextSize = 11
    VIPLabel.Font = Enum.Font.GothamBlack
    VIPLabel.BackgroundColor3 = Color3.fromRGB(35, 30, 18)
    VIPLabel.ZIndex = 51
    VIPLabel.Parent = KeyScreen
    AddCorner(VIPLabel, 8)
    AddStroke(VIPLabel, C.Gold, 2)

    local KeyInputContainer = Instance.new("Frame")
    KeyInputContainer.Size = UDim2.new(0.8, 0, 0, 50)
    KeyInputContainer.Position = UDim2.new(0.1, 0, 0.42, 0)
    KeyInputContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 48)
    KeyInputContainer.ZIndex = 51
    KeyInputContainer.Parent = KeyScreen
    AddCorner(KeyInputContainer, 12)
    
    local KeyInputStroke = AddStroke(KeyInputContainer, C.Accent, 2, 0.3)
    
    local KeyIcon = Instance.new("TextLabel")
    KeyIcon.Size = UDim2.new(0, 40, 1, 0)
    KeyIcon.Text = "🔑"
    KeyIcon.TextSize = 20
    KeyIcon.BackgroundTransparency = 1
    KeyIcon.ZIndex = 52
    KeyIcon.Parent = KeyInputContainer
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -48, 1, 0)
    KeyInput.Position = UDim2.new(0, 44, 0, 0)
    KeyInput.PlaceholderText = Lang.Get("EnterKey")
    KeyInput.Text = ""
    KeyInput.TextColor3 = C.Text_Primary
    KeyInput.PlaceholderColor3 = C.Text_Secondary
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 14
    KeyInput.ClearTextOnFocus = false
    KeyInput.BackgroundTransparency = 1
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.ZIndex = 52
    KeyInput.Parent = KeyInputContainer
    
    local KeyPad = Instance.new("UIPadding")
    KeyPad.PaddingRight = UDim.new(0, 8)
    KeyPad.Parent = KeyInput
    
    KeyInput.Focused:Connect(function()
        Tween(KeyInputStroke, {Color = C.Accent, Transparency = 0}, 0.2)
    end)
    KeyInput.FocusLost:Connect(function()
        Tween(KeyInputStroke, {Transparency = 0.3}, 0.2)
    end)

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "🔓 " .. Lang.Get("Verify")
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 45)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.57, 0)
    LoginBtn.BackgroundColor3 = C.Accent
    LoginBtn.TextColor3 = C.BG_Primary
    LoginBtn.Font = Enum.Font.GothamBlack
    LoginBtn.TextSize = 15
    LoginBtn.ZIndex = 51
    LoginBtn.Parent = KeyScreen
    AddCorner(LoginBtn, 12)

    local LoginGrad = Instance.new("UIGradient")
    LoginGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 200))
    })
    LoginGrad.Rotation = 90
    LoginGrad.Parent = LoginBtn
    
    LoginBtn.MouseEnter:Connect(function()
        Tween(LoginBtn, {Size = UDim2.new(0.62, 0, 0, 48)}, 0.15)
    end)
    LoginBtn.MouseLeave:Connect(function()
        Tween(LoginBtn, {Size = UDim2.new(0.6, 0, 0, 45)}, 0.15)
    end)
    
    local HelpText = Instance.new("TextLabel")
    HelpText.Size = UDim2.new(1, 0, 0, 20)
    HelpText.Position = UDim2.new(0, 0, 0.74, 0)
    HelpText.Text = "💬 Need a key? Contact: @WiliExplorer"
    HelpText.TextColor3 = C.Text_Secondary
    HelpText.TextSize = 10
    HelpText.Font = Enum.Font.Gotham
    HelpText.BackgroundTransparency = 1
    HelpText.ZIndex = 51
    HelpText.Parent = KeyScreen
    
    local Copyright = Instance.new("TextLabel")
    Copyright.Size = UDim2.new(1, 0, 0, 16)
    Copyright.Position = UDim2.new(0, 0, 0.92, 0)
    Copyright.Text = "© 2025 WiliExplorer - All Rights Reserved"
    Copyright.TextColor3 = Color3.fromRGB(70, 80, 110)
    Copyright.TextSize = 9
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
    
    -- ═══════════════════════════════
    -- حاوية KlimboMenu
    -- ═══════════════════════════════
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
            ShowNotification(Lang.Current == "ar" and "تم تغيير اللغة" or "Language changed", "info", 2)
            
            if ExplorerScreen.Visible then
                ExplorerScreen:ClearAllChildren()
                local Sidebar = SafeLoadModule("UI/Sidebar.lua", "Sidebar")
                if Sidebar and Sidebar.Create then Sidebar.Create(ExplorerScreen) end
            end
        end)
    end

    -- التحقق من المفتاح
    LoginBtn.MouseButton1Click:Connect(function()
        Tween(LoginBtn, {Size = UDim2.new(0.58, 0, 0, 42)}, 0.1)
        task.wait(0.1)
        Tween(LoginBtn, {Size = UDim2.new(0.6, 0, 0, 45)}, 0.1)
        
        LoginBtn.Text = "⏳ " .. Lang.Get("Verifying")
        Tween(LoginBtn, {BackgroundColor3 = Color3.fromRGB(90, 140, 190)}, 0.3)
        Tween(KeyInputStroke, {Color = C.Warning}, 0.3)
        task.wait(0.8)
        
        local keySuccess, data = KeySystem.Verify(KeyInput.Text)
        
        if keySuccess then
            LoginBtn.Text = "✅ " .. Lang.Get("Launching")
            Tween(LoginBtn, {BackgroundColor3 = C.Success}, 0.3)
            Tween(KeyInputStroke, {Color = C.Success}, 0.3)
            ShowNotification("🎉 Welcome VIP!", "success", 3)
            
            task.wait(1)
            
            Tween(KeyScreen, {Position = UDim2.new(0, 0, -1, 0)}, 0.5, Enum.EasingStyle.Back)
            task.wait(0.5)
            KeyScreen.Visible = false
            
            KlimboBtn.Visible = true
            KlimboBtn.Size = UDim2.new(0, 0, 0, 30)
            Tween(KlimboBtn, {Size = UDim2.new(0, 90, 0, 30)}, 0.4, Enum.EasingStyle.Back)
            
            UserInfo.Visible = true
            LangBtn.Position = UDim2.new(1, -440, 0.5, -15)
            MinBtn.Position = UDim2.new(1, -88, 0.5, -15)
            CloseBtn.Position = UDim2.new(1, -50, 0.5, -15)
            
            ExplorerScreen.Visible = true
            ExplorerScreen.Position = UDim2.new(0, 0, 1, 0)
            Tween(ExplorerScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back)
            
            local Sidebar = SafeLoadModule("UI/Sidebar.lua", "Sidebar")
            if Sidebar and Sidebar.Create then Sidebar.Create(ExplorerScreen) end
        else
            LoginBtn.Text = "❌ " .. Lang.Get("Invalid")
            Tween(LoginBtn, {BackgroundColor3 = C.Error}, 0.3)
            Tween(KeyInputStroke, {Color = C.Error}, 0.3)
            
            for i = 1, 3 do
                Tween(KeyInputContainer, {Position = UDim2.new(0.1, 8, 0.42, 0)}, 0.04)
                task.wait(0.04)
                Tween(KeyInputContainer, {Position = UDim2.new(0.1, -8, 0.42, 0)}, 0.04)
                task.wait(0.04)
            end
            Tween(KeyInputContainer, {Position = UDim2.new(0.1, 0, 0.42, 0)}, 0.04)
            
            ShowNotification("Invalid key!", "error", 3)
            
            task.wait(2)
            LoginBtn.Text = "🔓 " .. Lang.Get("Verify")
            Tween(LoginBtn, {BackgroundColor3 = C.Accent}, 0.3)
            Tween(KeyInputStroke, {Color = C.Accent, Transparency = 0.3}, 0.3)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- 👑 زر KLIMBO
    -- ═══════════════════════════════════════════════════════════════════════
    KlimboBtn.MouseButton1Click:Connect(function()
        Tween(KlimboBtn, {Size = UDim2.new(0, 85, 0, 28)}, 0.1)
        task.wait(0.1)
        Tween(KlimboBtn, {Size = UDim2.new(0, 90, 0, 30)}, 0.1)
        
        if KlimboContainer.Visible then
            KlimboContainer:ClearAllChildren()
            KlimboContainer.Visible = false
            ExplorerScreen.Visible = true
            KlimboBtn.Text = "👑 KLIMBO"
            return
        end
        
        if klimboLoading then return end
        klimboLoading = true
        
        KlimboBtn.Text = "⏳ Loading"
        ShowNotification("👑 Loading KLIMBO...", "info", 2)
        
        task.spawn(function()
            local KlimboMenu = nil
            local loadSuccess = false
            
            for attempt = 1, 3 do
                local ok, result = pcall(function()
                    local code = game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/KlimboMenu.lua", true)
                    if not code or #code < 2000 then error("Incomplete") end
                    return loadstring(code)()
                end)
                
                if ok and result and type(result) == "table" and type(result.Create) == "function" then
                    KlimboMenu = result
                    loadSuccess = true
                    break
                end
                
                if attempt < 3 then task.wait(1) end
            end
            
            if loadSuccess and KlimboMenu then
                KlimboContainer.Visible = true
                ExplorerScreen.Visible = false
                KlimboBtn.Text = "◀ BACK"
                
                local createOk = pcall(function()
                    KlimboMenu.Create(KlimboContainer)
                end)
                
                if createOk then
                    ShowNotification("👑 KLIMBO Ready!", "success", 2)
                else
                    KlimboContainer:ClearAllChildren()
                    KlimboContainer.Visible = false
                    ExplorerScreen.Visible = true
                    KlimboBtn.Text = "👑 KLIMBO"
                    ShowNotification("❌ Error loading menu", "error", 3)
                end
            else
                ShowNotification("❌ Failed to load KLIMBO", "error", 3)
                KlimboContainer.Visible = false
                ExplorerScreen.Visible = true
                KlimboBtn.Text = "👑 KLIMBO"
            end
            
            klimboLoading = false
        end)
    end)

    -- سحب النافذة
    local dragging, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
                    Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, 48)}, 0.3, Enum.EasingStyle.Back)
                    MinBtn.Text = "+"
                else
                    Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
                    MinBtn.Text = "—"
                end
            end
        end
        
        if input.KeyCode == Enum.KeyCode.K and KlimboBtn.Visible then
            KlimboBtn.MouseButton1Click:Fire()
        end
    end)

    print("🚀 WiliExplorer VIP UI Ready!")
    
    return ScreenGui
end

return MainFrame
