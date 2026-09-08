--[[
    ═══════════════════════════════════════════════════════════════════════════
    🚀 WiliExplorer - MainFrame v6.1 (Developer Edition)
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

local function SafeLoadModule(_, name)
    return GetModule(name)
end

local KeySystem = SafeLoadModule("Security/KeySystem.lua", "KeySystem")
local Stars = SafeLoadModule("Theme/Stars.lua", "Stars")
local Language = SafeLoadModule("Utils/Language.lua", "Language")
local Colors = SafeLoadModule("Theme/Colors.lua", "Colors")
local Design = SafeLoadModule("Utils/DesignSystem.lua", "DesignSystem")

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
        success = "✓", error = "×", warning = "!", info = "i"
    }
    
    local color = colorMap[notifType] or C.Accent
    local icon = iconMap[notifType] or "i"
    
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
    logo.Text = "◈ WiliExplorer"
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
    vipBadge.Text = "✦ " .. Lang.Get("VIPLabel")
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
        {text = "▦ " .. Lang.Get("LoadingModules"), progress = 0.15},
        {text = "◇ " .. Lang.Get("SecurityCheck"), progress = 0.3},
        {text = "◐ " .. Lang.Get("LoadingTheme"), progress = 0.45},
        {text = "⚙ " .. Lang.Get("InitSystem"), progress = 0.6},
        {text = "▣ " .. Lang.Get("BuildingUI"), progress = 0.8},
        {text = "✦ " .. Lang.Get("AlmostReady"), progress = 0.95},
        {text = "◈ " .. Lang.Get("Welcome"), progress = 1}
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

    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local isMobile = viewport.X < 800
    local initialSize = Design and Design.WindowSize(viewport) or Vector2.new(
        isMobile and math.max(300, viewport.X - 18) or math.min(960, viewport.X - 60),
        isMobile and math.max(300, viewport.Y - 24) or math.min(680, viewport.Y - 60)
    )
    local frameWidth = initialSize.X
    local frameHeight = initialSize.Y

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

    local SaveSystem = GetModule("SaveSystem")
    local savedPowerMode = SaveSystem and SaveSystem.Get and SaveSystem.Get("powerSaver", "auto") or "auto"
    local powerSaver = savedPowerMode == "auto" and isMobile or savedPowerMode == true
    if Stars and Stars.Create and not powerSaver then
        Stars.Create(Frame, isMobile and 20 or 50)
    end
    
    -- Preserve frame rate and battery on phones/power-saver mode.
    if not isMobile and not powerSaver then CreateParticles(Frame) end
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
    Logo.Text = "◈ WiliExplorer"
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
    -- مجموعة أزرار النافذة (ترتيب تلقائي — بلا مواضع عشوائية)
    -- ═══════════════════════════════
    local IconGlyphs = GetModule("Icons")

    local TopControls = Instance.new("Frame")
    TopControls.Name = "TopControls"
    TopControls.AutomaticSize = Enum.AutomaticSize.X
    TopControls.Size = UDim2.new(0, 0, 0, 44)
    TopControls.AnchorPoint = Vector2.new(1, 0)
    TopControls.Position = UDim2.new(1, -8, 0, 2)
    TopControls.BackgroundTransparency = 1
    TopControls.ZIndex = 101
    TopControls.Parent = TopBar

    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 6)
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.Parent = TopControls

    -- تلميح موحّد يظهر عند التمرير فوق أي زر
    local Tooltip = Instance.new("Frame")
    Tooltip.Name = "Tooltip"
    Tooltip.Size = UDim2.new(0, 130, 0, 24)
    Tooltip.Position = UDim2.new(1, -8, 1, 6)
    Tooltip.BackgroundColor3 = C.BG_Card
    Tooltip.ZIndex = 110
    Tooltip.Visible = false
    Tooltip.Parent = TopBar
    AddCorner(Tooltip, 7)
    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Size = UDim2.new(1, -8, 1, 0)
    TooltipLabel.Position = UDim2.new(0, 4, 0, 0)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.TextColor3 = C.Text_Primary
    TooltipLabel.TextSize = 10
    TooltipLabel.Font = Enum.Font.GothamBold
    TooltipLabel.TextXAlignment = Enum.TextXAlignment.Center
    TooltipLabel.ZIndex = 111
    TooltipLabel.Parent = Tooltip

    local function BindTooltip(button, key)
        button.MouseEnter:Connect(function()
            TooltipLabel.Text = Lang.Get(key)
            Tooltip.Visible = true
            Tween(Tooltip, {BackgroundTransparency = 0.05}, 0.1)
        end)
        button.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
    end

    -- زر أيقوني قياسي: أيقونة منفصلة تماماً عن النص
    local function WindowButton(name, glyph, bgColor, order, tooltipKey)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 36, 0, 34)
        btn.BackgroundColor3 = bgColor
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        btn.ZIndex = 101
        btn.Parent = TopControls
        AddCorner(btn, 9)
        AddStroke(btn, C.Border, 1, 0.4)
        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(1, 0, 1, 0)
        ic.BackgroundTransparency = 1
        ic.Text = glyph
        ic.TextColor3 = C.Text_Primary
        ic.TextSize = 16
        ic.Font = Enum.Font.GothamBold
        ic.ZIndex = 102
        ic.Parent = btn
        local hover = Color3.fromRGB(
            math.clamp(math.floor(bgColor.R * 255) + 26, 0, 255),
            math.clamp(math.floor(bgColor.G * 255) + 26, 0, 255),
            math.clamp(math.floor(bgColor.B * 255) + 26, 0, 255)
        )
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = hover}, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = bgColor}, 0.12)
        end)
        if tooltipKey then BindTooltip(btn, tooltipKey) end
        return btn, ic
    end

    -- ═══ زر المطوّر (DEV) ═══
    local KlimboBtn = Instance.new("TextButton")
    KlimboBtn.Name = "KlimboBtn"
    KlimboBtn.Size = UDim2.new(0, 78, 0, 34)
    KlimboBtn.BackgroundColor3 = C.BG_Secondary
    KlimboBtn.Text = ""
    KlimboBtn.AutoButtonColor = false
    KlimboBtn.LayoutOrder = 2
    KlimboBtn.ZIndex = 101
    KlimboBtn.Visible = false
    KlimboBtn.Parent = TopControls
    AddCorner(KlimboBtn, 9)

    local DevIcon = Instance.new("TextLabel")
    DevIcon.Size = UDim2.new(0, 20, 1, 0)
    DevIcon.Position = UDim2.new(0, 8, 0, 0)
    DevIcon.BackgroundTransparency = 1
    DevIcon.Text = "◈"
    DevIcon.TextColor3 = C.Gold
    DevIcon.TextSize = 14
    DevIcon.Font = Enum.Font.GothamBlack
    DevIcon.ZIndex = 102
    DevIcon.Parent = KlimboBtn

    local DevLabel = Instance.new("TextLabel")
    DevLabel.Size = UDim2.new(1, -30, 1, 0)
    DevLabel.Position = UDim2.new(0, 30, 0, 0)
    DevLabel.BackgroundTransparency = 1
    DevLabel.Text = "DEV"
    DevLabel.TextColor3 = C.Gold
    DevLabel.TextSize = 10
    DevLabel.Font = Enum.Font.GothamBlack
    DevLabel.TextXAlignment = Enum.TextXAlignment.Left
    DevLabel.ZIndex = 102
    DevLabel.Parent = KlimboBtn

    local function SetDevText(text)
        DevLabel.Text = text
    end

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
        Tween(KlimboBtn, {BackgroundColor3 = C.BG_CardActive}, 0.12)
    end)
    KlimboBtn.MouseLeave:Connect(function()
        Tween(KlimboBtn, {BackgroundColor3 = C.BG_Secondary}, 0.12)
    end)
    BindTooltip(KlimboBtn, "TooltipDev")

    -- ═══ زر اللغة ═══
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 92, 0, 34)
    LangBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 170)
    LangBtn.Text = ""
    LangBtn.AutoButtonColor = false
    LangBtn.LayoutOrder = 2
    LangBtn.ZIndex = 101
    LangBtn.Parent = TopControls
    AddCorner(LangBtn, 9)
    AddStroke(LangBtn, C.Accent, 1, 0.5)

    local LangIcon = Instance.new("TextLabel")
    LangIcon.Size = UDim2.new(0, 20, 1, 0)
    LangIcon.Position = UDim2.new(0, 8, 0, 0)
    LangIcon.BackgroundTransparency = 1
    LangIcon.Text = "Aa"
    LangIcon.TextSize = 13
    LangIcon.ZIndex = 102
    LangIcon.Parent = LangBtn

    local LangLabel = Instance.new("TextLabel")
    LangLabel.Size = UDim2.new(1, -32, 1, 0)
    LangLabel.Position = UDim2.new(0, 30, 0, 0)
    LangLabel.BackgroundTransparency = 1
    LangLabel.Text = Lang.Current == "en" and "العربية" or "English"
    LangLabel.TextColor3 = C.Text_Primary
    LangLabel.TextSize = 10
    LangLabel.Font = Enum.Font.GothamBold
    LangLabel.TextXAlignment = Enum.TextXAlignment.Left
    LangLabel.ZIndex = 102
    LangLabel.Parent = LangBtn

    LangBtn.MouseEnter:Connect(function()
        Tween(LangBtn, {BackgroundColor3 = Color3.fromRGB(0, 150, 205)}, 0.12)
    end)
    LangBtn.MouseLeave:Connect(function()
        Tween(LangBtn, {BackgroundColor3 = Color3.fromRGB(0, 120, 170)}, 0.12)
    end)
    BindTooltip(LangBtn, "TooltipLanguage")

    -- ═══ زر الإعدادات ═══
    local SettingsBtn = WindowButton("SettingsBtn", "⚙", Color3.fromRGB(40, 50, 80), 3, "TooltipSettings")

    SettingsBtn.MouseButton1Click:Connect(function()
        if not explorerRouter then return end
        if not ExplorerScreen.Visible then return end
        explorerRouter.Push(BuildSettingsPage())
    end)

    -- ═══ زر التصغير ═══
    local MinBtn, MinIcon = WindowButton("MinBtn", "−", Color3.fromRGB(55, 65, 110), 4, "TooltipMinimize")

    -- ═══ زر الإغلاق ═══
    local CloseBtn, CloseIcon = WindowButton("CloseBtn", "×", C.Error, 5, "TooltipClose")

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
            MinIcon.Text = "+"
        else
            Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
            MinIcon.Text = "−"
        end
    end)

    -- ═══ معلومات المستخدم ═══
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.Size = UDim2.new(0, 124, 0, 32)
    UserInfo.BackgroundColor3 = Color3.fromRGB(22, 22, 45)
    UserInfo.BackgroundTransparency = 0.4
    UserInfo.LayoutOrder = 1
    UserInfo.ZIndex = 101
    UserInfo.Visible = false
    UserInfo.Parent = TopControls
    AddCorner(UserInfo, 8)

    local UserAvatar = Instance.new("ImageLabel")
    UserAvatar.Size = UDim2.new(0, 24, 0, 24)
    UserAvatar.Position = UDim2.new(0, 4, 0.5, -12)
    UserAvatar.BackgroundColor3 = C.Accent
    UserAvatar.ZIndex = 102
    UserAvatar.Parent = UserInfo
    AddCorner(UserAvatar, 12)
    pcall(function()
        UserAvatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)

    local UserName = Instance.new("TextLabel")
    UserName.Size = UDim2.new(1, -32, 1, 0)
    UserName.Position = UDim2.new(0, 32, 0, 0)
    UserName.Text = LocalPlayer.Name:sub(1, 10)
    UserName.TextColor3 = C.Text_Primary
    UserName.TextSize = 9
    UserName.Font = Enum.Font.GothamBold
    UserName.TextXAlignment = Enum.TextXAlignment.Left
    UserName.BackgroundTransparency = 1
    UserName.ZIndex = 102
    UserName.Parent = UserInfo
    BindTooltip(UserInfo, "TooltipUser")

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
    Title.Text = "◈ WiliExplorer"
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
    VIPLabel.Text = "✦ " .. Lang.Get("VIPLabel")
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
    KeyIcon.Text = "◆"
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
    LoginBtn.Text = ""
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 45)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.57, 0)
    LoginBtn.BackgroundColor3 = C.Accent
    LoginBtn.TextColor3 = C.BG_Primary
    LoginBtn.Font = Enum.Font.GothamBlack
    LoginBtn.TextSize = 15
    LoginBtn.ZIndex = 51
    LoginBtn.Parent = KeyScreen
    AddCorner(LoginBtn, 12)

    -- أيقونة ونص منفصلان — لا تشابك مع RTL
    local LoginIcon = Instance.new("TextLabel")
    LoginIcon.Size = UDim2.new(0, 26, 1, 0)
    LoginIcon.Position = UDim2.new(0, 12, 0, 0)
    LoginIcon.BackgroundTransparency = 1
    LoginIcon.Text = "◇"
    LoginIcon.TextSize = 15
    LoginIcon.ZIndex = 52
    LoginIcon.Parent = LoginBtn

    local LoginLabel = Instance.new("TextLabel")
    LoginLabel.Size = UDim2.new(1, -40, 1, 0)
    LoginLabel.Position = UDim2.new(0, 40, 0, 0)
    LoginLabel.BackgroundTransparency = 1
    LoginLabel.Text = Lang.Get("Verify")
    LoginLabel.TextColor3 = C.BG_Primary
    LoginLabel.TextSize = 15
    LoginLabel.Font = Enum.Font.GothamBlack
    LoginLabel.TextXAlignment = Enum.TextXAlignment.Left
    LoginLabel.ZIndex = 52
    LoginLabel.Parent = LoginBtn

    local function SetLoginText(icon, text)
        LoginIcon.Text = icon
        LoginLabel.Text = text
    end

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
    HelpText.Text = "◉ " .. Lang.Get("NeedKeyHelp")
    HelpText.TextColor3 = C.Text_Secondary
    HelpText.TextSize = 10
    HelpText.Font = Enum.Font.Gotham
    HelpText.BackgroundTransparency = 1
    HelpText.ZIndex = 51
    HelpText.Parent = KeyScreen
    
    local Copyright = Instance.new("TextLabel")
    Copyright.Size = UDim2.new(1, 0, 0, 16)
    Copyright.Position = UDim2.new(0, 0, 0.92, 0)
    Copyright.Text = "© 2026 WiliExplorer • Responsive Edition"
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
    local authenticated = false

    -- ═══════════════════════════════
    -- نظام التنقل بالصفحات (كل ميزة صفحة مستقلة + رجوع)
    -- ═══════════════════════════════
    local RouterModule = GetModule("Router")
    local explorerRouter = RouterModule and RouterModule.Create(ExplorerScreen, function(msg, kind)
        ShowNotification(tostring(msg), kind == "Error" and "error" or kind == "Warning" and "warning" or "info", 2)
    end)

    local function BuildSettingsPage()
        return {
            name = "settings",
            title = Lang.Get("SettingsTitle"),
            subtitle = Lang.Get("SettingsSubtitle"),
            icon = "⚙",
            color = C.Warning,
            builder = function(c)
                local SettingsPanel = GetModule("SettingsPanel")
                if SettingsPanel then
                    SettingsPanel.Create(c, {
                        router = explorerRouter,
                        notify = function(msg, kind)
                            ShowNotification(tostring(msg), kind == "Error" and "error" or kind == "Warning" and "warning" or "info", 2)
                        end,
                        onLanguageChanged = function() end,
                        onThemeChanged = function() end
                    })
                end
            end
        }
    end

    local function RebuildHome()
        if not explorerRouter then
            ExplorerScreen:ClearAllChildren()
            local Sidebar = GetModule("Sidebar")
            if Sidebar and Sidebar.Create then Sidebar.Create(ExplorerScreen) end
            return
        end
        local Sidebar = GetModule("Sidebar")
        if Sidebar and Sidebar.GetPage then
            explorerRouter.Reset(Sidebar.GetPage({
                router = explorerRouter,
                viewerParent = Frame,
                settingsPage = BuildSettingsPage
            }))
        end
    end

    -- تخطيط تكيفي حقيقي: يعاد حسابه عند تدوير الهاتف أو تغيير حجم النافذة.
    local function ApplyResponsiveLayout(mode, currentViewport)
        local nextSize = Design and Design.WindowSize(currentViewport) or Vector2.new(
            math.max(300, currentViewport.X - 18), math.max(300, currentViewport.Y - 24)
        )
        frameWidth, frameHeight = nextSize.X, nextSize.Y
        local targetHeight = minimized and 48 or frameHeight
        Frame.Size = UDim2.new(0, frameWidth, 0, targetHeight)
        Frame.Position = UDim2.new(0.5, -frameWidth / 2, 0.5, -targetHeight / 2)

        local compact = mode == "compact"
        local mobile = compact or mode == "mobile"
        Logo.Text = compact and "◈ Wili" or "◈ WiliExplorer"
        Logo.Size = UDim2.new(0, compact and 105 or 165, 1, 0)
        Logo.TextSize = compact and 15 or 18
        LogoVIP.Visible = not mobile
        UserInfo.Visible = authenticated and not mobile
        Title.TextSize = compact and 25 or (mobile and 30 or 38)
        KeyInputContainer.Size = UDim2.new(mobile and 0.9 or 0.72, 0, 0, mobile and 52 or 50)
        KeyInputContainer.Position = UDim2.new(mobile and 0.05 or 0.14, 0, 0.42, 0)
        LoginBtn.Size = UDim2.new(mobile and 0.9 or 0.5, 0, 0, 46)
        LoginBtn.Position = UDim2.new(mobile and 0.05 or 0.25, 0, 0.57, 0)

        -- أزرار الشريط تُرتَّب تلقائياً بواسطة TopControls — لا مواضع عشوائية
        LangLabel.Text = compact
            and (Lang.Current == "en" and "AR" or "EN")
            or (Lang.Current == "en" and "العربية" or "English")
        LangLabel.Visible = not compact
        if compact then
            LangBtn.Size = UDim2.new(0, 36, 0, 34)
            KlimboBtn.Size = UDim2.new(0, 44, 0, 34)
            DevLabel.Visible = false
            SetDevText("DEV")
        else
            LangBtn.Size = UDim2.new(0, 92, 0, 34)
            KlimboBtn.Size = UDim2.new(0, 78, 0, 34)
            DevLabel.Visible = true
            SetDevText(KlimboContainer.Visible and "‹ BACK" or "DEV")
        end
    end

    if Design and Design.BindResponsive then
        Design.BindResponsive(ScreenGui, ApplyResponsiveLayout)
    else
        ApplyResponsiveLayout(isMobile and "mobile" or "desktop", viewport)
    end

    local launched = false
    local function LaunchExplorer(animated)
        if launched then return end
        launched = true
        authenticated = true
        KeyScreen.Visible = false
        KlimboBtn.Visible = true
        UserInfo.Visible = true
        ExplorerScreen.Visible = true
        ExplorerScreen:ClearAllChildren()
        ApplyResponsiveLayout(Design and Design.GetMode() or (isMobile and "mobile" or "desktop"), Design and Design.GetViewport() or viewport)
        if animated then
            KlimboBtn.Size = UDim2.new(0, 0, 0, 34)
            Tween(KlimboBtn, {Size = UDim2.new(0, 78, 0, 34)}, 0.35, Enum.EasingStyle.Back)
            ExplorerScreen.Position = UDim2.new(0, 0, 1, 0)
            Tween(ExplorerScreen, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back)
        else
            ExplorerScreen.Position = UDim2.new(0, 0, 0, 0)
        end
        local Sidebar = GetModule("Sidebar")
        if Sidebar and Sidebar.Create then
            Sidebar.Create(ExplorerScreen, {
                router = explorerRouter,
                viewerParent = Frame,
                settingsPage = BuildSettingsPage
            })
        end
    end

    local securityConfig = (_G.WiliConfig and _G.WiliConfig.Security) or {}
    if securityConfig.RequireKey ~= true then
        task.defer(function() LaunchExplorer(false) end)
    end

    -- تحديث اللغة
    if LangBtn and Lang.Toggle then
        LangBtn.MouseButton1Click:Connect(function()
            Lang.Toggle()
            ApplyResponsiveLayout(Design and Design.GetMode() or (isMobile and "mobile" or "desktop"), Design and Design.GetViewport() or viewport)
            Subtitle.Text = Lang.Get("Welcome")
            KeyInput.PlaceholderText = Lang.Get("EnterKey")
            SetLoginText("◇", Lang.Get("Verify"))
            if Lang.Apply then Lang.Apply(Frame) end
            ShowNotification(Lang.Current == "ar" and "تم تغيير اللغة" or "Language changed", "info", 2)
            
            if ExplorerScreen.Visible then
                RebuildHome()
            end
        end)
    end

    -- التحقق من المفتاح
    LoginBtn.MouseButton1Click:Connect(function()
        Tween(LoginBtn, {Size = UDim2.new(0.58, 0, 0, 42)}, 0.1)
        task.wait(0.1)
        Tween(LoginBtn, {Size = UDim2.new(0.6, 0, 0, 45)}, 0.1)
        
        SetLoginText("◔", Lang.Get("Verifying"))
        Tween(LoginBtn, {BackgroundColor3 = Color3.fromRGB(90, 140, 190)}, 0.3)
        Tween(KeyInputStroke, {Color = C.Warning}, 0.3)
        task.wait(0.8)
        
        local keySuccess, data = KeySystem.Verify(KeyInput.Text)
        
        if keySuccess then
            SetLoginText("✓", Lang.Get("Launching"))
            Tween(LoginBtn, {BackgroundColor3 = C.Success}, 0.3)
            Tween(KeyInputStroke, {Color = C.Success}, 0.3)
            ShowNotification(Lang.Get("WelcomeVIP"), "success", 3)
            
            task.wait(0.6)
            Tween(KeyScreen, {Position = UDim2.new(0, 0, -1, 0)}, 0.35, Enum.EasingStyle.Back)
            task.wait(0.35)
            LaunchExplorer(true)
        else
            SetLoginText("×", Lang.Get("Invalid"))
            Tween(LoginBtn, {BackgroundColor3 = C.Error}, 0.3)
            Tween(KeyInputStroke, {Color = C.Error}, 0.3)
            
            for i = 1, 3 do
                Tween(KeyInputContainer, {Position = UDim2.new(0.1, 8, 0.42, 0)}, 0.04)
                task.wait(0.04)
                Tween(KeyInputContainer, {Position = UDim2.new(0.1, -8, 0.42, 0)}, 0.04)
                task.wait(0.04)
            end
            Tween(KeyInputContainer, {Position = UDim2.new(0.1, 0, 0.42, 0)}, 0.04)
            
            ShowNotification(tostring(data or Lang.Get("Invalid")), "error", 4)
            
            task.wait(2)
            SetLoginText("◇", Lang.Get("Verify"))
            Tween(LoginBtn, {BackgroundColor3 = C.Accent}, 0.3)
            Tween(KeyInputStroke, {Color = C.Accent, Transparency = 0.3}, 0.3)
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════════════
    -- 👑 زر KLIMBO
    -- ═══════════════════════════════════════════════════════════════════════
    local function ToggleDeveloperConsole()
        Tween(KlimboBtn, {BackgroundColor3 = C.BG_CardActive}, 0.1)
        task.wait(0.1)
        Tween(KlimboBtn, {BackgroundColor3 = C.BG_Secondary}, 0.1)
        
        if KlimboContainer.Visible then
            KlimboContainer:ClearAllChildren()
            KlimboContainer.Visible = false
            ExplorerScreen.Visible = true
            SetDevText("DEV")
            return
        end
        
        if klimboLoading then return end
        klimboLoading = true
        
        SetDevText("⏳")
        ShowNotification("Loading Developer Console...", "info", 2)
        
        task.spawn(function()
            -- الوحدة محمّلة مسبقاً بواسطة Loader؛ لا تنزيل أو تنفيذ خارجي عند كل نقرة.
            local KlimboMenu = GetModule("KlimboMenu")
            local loadSuccess = KlimboMenu and type(KlimboMenu.Create) == "function"
            
            if loadSuccess then
                KlimboContainer.Visible = true
                ExplorerScreen.Visible = false
                SetDevText("‹ BACK")
                
                local createOk = pcall(function()
                    KlimboMenu.Create(KlimboContainer)
                end)
                
                if createOk then
                    ShowNotification(Lang.Get("ConsoleReady"), "success", 2)
                else
                    KlimboContainer:ClearAllChildren()
                    KlimboContainer.Visible = false
                    ExplorerScreen.Visible = true
                    SetDevText("DEV")
                    ShowNotification(Lang.Get("ConsoleLoadFailed"), "error", 3)
                end
            else
                ShowNotification(Lang.Get("ConsoleLoadFailed"), "error", 3)
                KlimboContainer.Visible = false
                ExplorerScreen.Visible = true
                SetDevText("DEV")
            end
            
            klimboLoading = false
        end)
    end
    KlimboBtn.MouseButton1Click:Connect(ToggleDeveloperConsole)

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
    
    local dragInputConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- اختصارات لوحة المفاتيح
    local shortcutConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Escape then
            if KlimboContainer.Visible then
                KlimboContainer:ClearAllChildren()
                KlimboContainer.Visible = false
                ExplorerScreen.Visible = true
                SetDevText("DEV")
            elseif explorerRouter and explorerRouter.Depth() > 1 then
                explorerRouter.Back()
            else
                minimized = not minimized
                if minimized then
                    Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, 48)}, 0.3, Enum.EasingStyle.Back)
                    MinIcon.Text = "+"
                else
                    Tween(Frame, {Size = UDim2.new(0, frameWidth, 0, frameHeight)}, 0.3, Enum.EasingStyle.Back)
                    MinIcon.Text = "−"
                end
            end
        end
        
        if input.KeyCode == Enum.KeyCode.K and KlimboBtn.Visible then
            ToggleDeveloperConsole()
        end
    end)

    ScreenGui.Destroying:Connect(function()
        if dragInputConnection then dragInputConnection:Disconnect() end
        if shortcutConnection then shortcutConnection:Disconnect() end
        local Analyzer = GetModule("GameAnalyzer")
        if Analyzer and Analyzer.Destroy then pcall(Analyzer.Destroy) end
        local Saves = GetModule("SaveSystem")
        if Saves and Saves.Destroy then pcall(Saves.Destroy) end
    end)

    if Lang.Apply then Lang.Apply(Frame) end
    print("WiliExplorer UI ready")
    
    return ScreenGui
end

return MainFrame
