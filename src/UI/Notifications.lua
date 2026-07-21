--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔔 WiliExplorer - Notification System v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ إشعارات صغيرة وجميلة
    ✅ ألوان حسب النوع (نجاح/خطأ/تحذير/معلومات)
    ✅ أنيميشن دخول/خروج سلس
    ✅ صف انتظار (Queue)
    ✅ تختفي تلقائياً
    ✅ عداد الإشعارات
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Notifications = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان والأيقونات
-- ═══════════════════════════════════════════════════════════════════════
local NotifTypes = {
    success = {
        icon = "✅",
        color = Color3.fromRGB(0, 255, 100),
        bgColor = Color3.fromRGB(10, 40, 25),
        borderColor = Color3.fromRGB(0, 200, 80)
    },
    error = {
        icon = "❌",
        color = Color3.fromRGB(255, 50, 50),
        bgColor = Color3.fromRGB(40, 10, 10),
        borderColor = Color3.fromRGB(200, 40, 40)
    },
    warning = {
        icon = "⚠️",
        color = Color3.fromRGB(255, 165, 0),
        bgColor = Color3.fromRGB(40, 30, 10),
        borderColor = Color3.fromRGB(200, 130, 0)
    },
    info = {
        icon = "ℹ️",
        color = Color3.fromRGB(100, 200, 255),
        bgColor = Color3.fromRGB(10, 25, 40),
        borderColor = Color3.fromRGB(80, 160, 200)
    },
    vip = {
        icon = "👑",
        color = Color3.fromRGB(255, 215, 0),
        bgColor = Color3.fromRGB(40, 35, 15),
        borderColor = Color3.fromRGB(200, 170, 0)
    },
    game = {
        icon = "🎮",
        color = Color3.fromRGB(138, 43, 226),
        bgColor = Color3.fromRGB(30, 15, 45),
        borderColor = Color3.fromRGB(110, 35, 180)
    }
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local NotifContainer = nil
local NotifQueue = {}
local ActiveNotifs = {}
local MaxNotifs = 5
local NotifCount = 0

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function CreateContainer()
    if NotifContainer and NotifContainer.Parent then return NotifContainer end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliNotifications"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "Container"
    NotifContainer.Size = UDim2.new(0, 280, 1, -20)
    NotifContainer.Position = UDim2.new(1, -290, 0, 10)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = gui
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotifContainer
    
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 5)
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = NotifContainer
    
    return NotifContainer
end

local function Tween(obj, props, duration, style, direction)
    if not obj or not obj.Parent then return end
    return TweenService:Create(obj, TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    ), props):Play()
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔔 إنشاء إشعار واحد
-- ═══════════════════════════════════════════════════════════════════════
local function CreateSingleNotif(message, notifType, duration, title)
    local container = CreateContainer()
    local typeData = NotifTypes[notifType] or NotifTypes.info
    
    NotifCount = NotifCount + 1
    local notifId = NotifCount
    
    -- الإطار الرئيسي
    local notif = Instance.new("Frame")
    notif.Name = "Notif_" .. notifId
    notif.Size = UDim2.new(1, 0, 0, 0) -- يبدأ بحجم 0
    notif.BackgroundColor3 = typeData.bgColor
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.ZIndex = 1000
    notif.LayoutOrder = -notifId
    notif.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notif
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = typeData.borderColor
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = notif
    
    -- شريط جانبي ملون
    local sideBar = Instance.new("Frame")
    sideBar.Size = UDim2.new(0, 4, 1, 0)
    sideBar.BackgroundColor3 = typeData.color
    sideBar.BorderSizePixel = 0
    sideBar.ZIndex = 1001
    sideBar.Parent = notif
    
    -- الأيقونة
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Position = UDim2.new(0, 10, 0.5, -17)
    icon.Text = typeData.icon
    icon.TextSize = 20
    icon.BackgroundTransparency = 1
    icon.ZIndex = 1002
    icon.Parent = notif
    
    -- العنوان (اختياري)
    local titleLbl = nil
    if title and title ~= "" then
        titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -55, 0, 16)
        titleLbl.Position = UDim2.new(0, 50, 0, 5)
        titleLbl.Text = title
        titleLbl.TextColor3 = typeData.color
        titleLbl.TextSize = 11
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        titleLbl.BackgroundTransparency = 1
        titleLbl.ZIndex = 1002
        titleLbl.Parent = notif
    end
    
    -- الرسالة
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -55, 0, 35)
    msg.Position = UDim2.new(0, 50, title and 22 or 0, 0)
    msg.Text = message
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextSize = 12
    msg.Font = Enum.Font.Gotham
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.TextTruncate = Enum.TextTruncate.AtEnd
    msg.BackgroundTransparency = 1
    msg.ZIndex = 1002
    msg.Parent = notif
    
    -- شريط التقدم
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -8, 0, 3)
    progressBg.Position = UDim2.new(0, 4, 1, -5)
    progressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = 1002
    progressBg.Parent = notif
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1, 0)
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = typeData.color
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 1003
    progressFill.Parent = progressBg
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
    
    -- زر إغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 3)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 1003
    closeBtn.Parent = notif
    
    -- ═══ أنيميشن الدخول ═══
    local targetHeight = title and 60 or 45
    
    -- تحديد الحجم الأولي
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.BackgroundTransparency = 1
    stroke.Transparency = 1
    icon.TextTransparency = 1
    msg.TextTransparency = 1
    if titleLbl then titleLbl.TextTransparency = 1 end
    progressFill.BackgroundTransparency = 1
    
    -- أنيميشن الظهور
    task.spawn(function()
        Tween(notif, {
            Size = UDim2.new(1, 0, 0, targetHeight),
            BackgroundTransparency = 0
        }, 0.4, Enum.EasingStyle.Back)
        
        Tween(stroke, {Transparency = 0.3}, 0.3)
        Tween(icon, {TextTransparency = 0}, 0.3)
        Tween(msg, {TextTransparency = 0}, 0.3)
        if titleLbl then Tween(titleLbl, {TextTransparency = 0}, 0.3) end
        Tween(progressFill, {BackgroundTransparency = 0}, 0.3)
    end)
    
    -- ═══ شريط التقدم ═══
    local dur = duration or 3
    Tween(progressFill, {Size = UDim2.new(0, 0, 1, 0)}, dur, Enum.EasingStyle.Linear)
    
    -- ═══ زر الإغلاق ═══
    local function RemoveNotif()
        Tween(notif, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3)
        Tween(stroke, {Transparency = 1}, 0.2)
        Tween(icon, {TextTransparency = 1}, 0.2)
        Tween(msg, {TextTransparency = 1}, 0.2)
        if titleLbl then Tween(titleLbl, {TextTransparency = 1}, 0.2) end
        
        task.delay(0.35, function()
            if notif and notif.Parent then
                notif:Destroy()
            end
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(RemoveNotif)
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.1)
    end)
    
    -- ═══ إزالة تلقائية ═══
    task.delay(dur, function()
        RemoveNotif()
    end)
    
    -- تأثير Hover
    notif.MouseEnter:Connect(function()
        Tween(notif, {BackgroundColor3 = Color3.fromRGB(
            typeData.bgColor.R * 255 + 10,
            typeData.bgColor.G * 255 + 10,
            typeData.bgColor.B * 255 + 10
        )}, 0.2)
    end)
    notif.MouseLeave:Connect(function()
        Tween(notif, {BackgroundColor3 = typeData.bgColor}, 0.2)
    end)
    
    return notif
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔔 API العامة
-- ═══════════════════════════════════════════════════════════════════════

-- إشعار نجاح
function Notifications.Success(message, title, duration)
    return CreateSingleNotif(message, "success", duration or 3, title)
end

-- إشعار خطأ
function Notifications.Error(message, title, duration)
    return CreateSingleNotif(message, "error", duration or 4, title)
end

-- إشعار تحذير
function Notifications.Warning(message, title, duration)
    return CreateSingleNotif(message, "warning", duration or 3, title)
end

-- إشعار معلومات
function Notifications.Info(message, title, duration)
    return CreateSingleNotif(message, "info", duration or 3, title)
end

-- إشعار VIP
function Notifications.VIP(message, title, duration)
    return CreateSingleNotif(message, "vip", duration or 4, title)
end

-- إشعار لعبة
function Notifications.Game(message, title, duration)
    return CreateSingleNotif(message, "game", duration or 3, title)
end

-- إشعار مخصص
function Notifications.Custom(message, icon, color, duration, title)
    NotifTypes.custom = {
        icon = icon or "📢",
        color = color or Color3.fromRGB(200, 200, 200),
        bgColor = Color3.fromRGB(25, 25, 40),
        borderColor = color or Color3.fromRGB(150, 150, 150)
    }
    return CreateSingleNotif(message, "custom", duration or 3, title)
end

-- إشعار سريع
function Notifications.Quick(message)
    return CreateSingleNotif(message, "info", 1.5)
end

-- مسح كل الإشعارات
function Notifications.ClearAll()
    if NotifContainer then
        for _, child in ipairs(NotifContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
end

-- تحديث عدد الإشعارات
function Notifications.GetCount()
    if NotifContainer then
        local count = 0
        for _, child in ipairs(NotifContainer:GetChildren()) do
            if child:IsA("Frame") then count = count + 1 end
        end
        return count
    end
    return 0
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📱 دعم الهاتف - إشعار عائم
-- ═══════════════════════════════════════════════════════════════════════
local FloatingBtn = nil

function Notifications.CreateFloatingButton(callback)
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliFloating"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    FloatingBtn = Instance.new("ImageButton")
    FloatingBtn.Name = "FloatingBtn"
    FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    FloatingBtn.Position = UDim2.new(1, -65, 0.5, -25)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.Image = ""
    FloatingBtn.Parent = gui
    
    Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Parent = FloatingBtn
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.Text = "👑"
    icon.TextSize = 24
    icon.BackgroundTransparency = 1
    icon.ZIndex = 10
    icon.Parent = FloatingBtn
    
    -- تأثير نبضي
    task.spawn(function()
        while FloatingBtn and FloatingBtn.Parent do
            TweenService:Create(stroke, TweenInfo.new(1), {Thickness = 3, Transparency = 0.3}):Play()
            task.wait(1)
            if not FloatingBtn or not FloatingBtn.Parent then break end
            TweenService:Create(stroke, TweenInfo.new(1), {Thickness = 2, Transparency = 0}):Play()
            task.wait(1)
        end
    end)
    
    -- سحب الزر
    local dragging, dragStart, startPos
    
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = FloatingBtn.Position
        end
    end)
    
    FloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            FloatingBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    FloatingBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    -- Hover effects
    FloatingBtn.MouseEnter:Connect(function()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)}):Play()
    end)
    FloatingBtn.MouseLeave:Connect(function()
        TweenService:Create(FloatingBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)
    
    return FloatingBtn
end

-- إزالة الزر العائم
function Notifications.RemoveFloatingButton()
    if FloatingBtn and FloatingBtn.Parent then
        FloatingBtn.Parent:Destroy()
        FloatingBtn = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 تهيئة النظام
-- ═══════════════════════════════════════════════════════════════════════
Notifications.NotifTypes = NotifTypes

print("🔔 Notification System v1.0 Loaded!")

return Notifications
