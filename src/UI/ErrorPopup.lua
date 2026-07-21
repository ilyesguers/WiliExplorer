--[[
    ═══════════════════════════════════════════════════════════════════════════
    ❌ WiliExplorer - Error Popup v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ نافذة خطأ جميلة
    ✅ تفاصيل الخطأ كاملة
    ✅ زر نسخ الخطأ
    ✅ زر إعادة المحاولة
    ✅ زر إغلاق
    ✅ أنيميشن ظهور
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local ErrorPopup = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    BG = Color3.fromRGB(20, 15, 30),
    Header = Color3.fromRGB(30, 10, 10),
    Body = Color3.fromRGB(15, 15, 30),
    Border = Color3.fromRGB(200, 50, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    Error = Color3.fromRGB(255, 70, 70),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Success = Color3.fromRGB(0, 255, 100),
    Button = Color3.fromRGB(40, 40, 70),
    ButtonHover = Color3.fromRGB(50, 50, 85)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration, style)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart), props):Play()
end

local function CreateGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliErrorPopup"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    return gui
end

-- ═══════════════════════════════════════════════════════════════════════
-- ❌ إظهار نافذة الخطأ
-- ═══════════════════════════════════════════════════════════════════════
function ErrorPopup.Show(options)
    options = options or {}
    
    local title = options.title or "Error"
    local message = options.message or "An unknown error occurred"
    local details = options.details or ""
    local errorType = options.type or "error" -- error, warning, info, success
    local onRetry = options.onRetry
    local onClose = options.onClose
    local showDetails = options.showDetails ~= false
    
    -- تحديد الألوان حسب النوع
    local typeColors = {
        error = {icon = "❌", color = Colors.Error, header = Color3.fromRGB(30, 10, 10)},
        warning = {icon = "⚠️", color = Colors.Warning, header = Color3.fromRGB(30, 25, 10)},
        info = {icon = "ℹ️", color = Colors.Info, header = Color3.fromRGB(10, 20, 30)},
        success = {icon = "✅", color = Colors.Success, header = Color3.fromRGB(10, 30, 15)}
    }
    
    local typeData = typeColors[errorType] or typeColors.error
    
    -- إنشاء الواجهة
    local gui = CreateGui()
    
    -- خلفية شفافة
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.ZIndex = 9998
    overlay.Parent = gui
    Tween(overlay, {BackgroundTransparency = 0.5}, 0.3)
    
    -- النافذة الرئيسية
    local popup = Instance.new("Frame")
    popup.Name = "Popup"
    popup.Size = UDim2.new(0, 0, 0, 0)
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    popup.BackgroundColor3 = Colors.BG
    popup.BorderSizePixel = 0
    popup.ClipsDescendants = true
    popup.ZIndex = 9999
    popup.Parent = gui
    
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 15)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = typeData.color
    stroke.Thickness = 2
    stroke.Parent = popup
    
    -- الشريط العلوي
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = typeData.header
    header.BorderSizePixel = 0
    header.ZIndex = 10000
    header.Parent = popup
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    -- شريط سفلي للـ header
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = typeData.header
    headerBottom.BorderSizePixel = 0
    headerBottom.ZIndex = 10000
    headerBottom.Parent = header
    
    -- الأيقونة
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0, 5)
    icon.Text = typeData.icon
    icon.TextSize = 24
    icon.BackgroundTransparency = 1
    icon.ZIndex = 10001
    icon.Parent = header
    
    -- العنوان
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -60, 0, 25)
    titleLbl.Position = UDim2.new(0, 55, 0, 5)
    titleLbl.Text = title
    titleLbl.TextColor3 = typeData.color
    titleLbl.TextSize = 16
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.ZIndex = 10001
    titleLbl.Parent = header
    
    -- زر إغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.TextDim
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 10001
    closeBtn.Parent = header
    
    -- المحتوى
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -120)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.ZIndex = 10000
    content.Parent = popup
    
    -- الرسالة
    local messageLbl = Instance.new("TextLabel")
    messageLbl.Size = UDim2.new(1, 0, 0, 0)
    messageLbl.Position = UDim2.new(0, 0, 0, 0)
    messageLbl.Text = message
    messageLbl.TextColor3 = Colors.Text
    messageLbl.TextSize = 13
    messageLbl.Font = Enum.Font.Gotham
    messageLbl.TextXAlignment = Enum.TextXAlignment.Left
    messageLbl.TextWrapped = true
    messageLbl.BackgroundTransparency = 1
    messageLbl.AutomaticSize = Enum.AutomaticSize.Y
    messageLbl.ZIndex = 10001
    messageLbl.Parent = content
    
    -- التفاصيل (اختياري)
    local detailsFrame = nil
    if showDetails and details ~= "" then
        detailsFrame = Instance.new("Frame")
        detailsFrame.Name = "Details"
        detailsFrame.Size = UDim2.new(1, 0, 0, 80)
        detailsFrame.Position = UDim2.new(0, 0, 0, messageLbl.TextBounds.Y + 10)
        detailsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
        detailsFrame.BorderSizePixel = 0
        detailsFrame.ZIndex = 10001
        detailsFrame.Parent = content
        Instance.new("UICorner", detailsFrame).CornerRadius = UDim.new(0, 8)
        
        local detailsStroke = Instance.new("UIStroke")
        detailsStroke.Color = Color3.fromRGB(40, 40, 70)
        detailsStroke.Thickness = 1
        detailsStroke.Parent = detailsFrame
        
        local detailsScroll = Instance.new("ScrollingFrame")
        detailsScroll.Size = UDim2.new(1, -10, 1, -10)
        detailsScroll.Position = UDim2.new(0, 5, 0, 5)
        detailsScroll.BackgroundTransparency = 1
        detailsScroll.ScrollBarThickness = 3
        detailsScroll.ScrollBarImageColor3 = Colors.Error
        detailsScroll.ZIndex = 10002
        detailsScroll.Parent = detailsFrame
        
        local detailsText = Instance.new("TextLabel")
        detailsText.Size = UDim2.new(1, -5, 0, 0)
        detailsText.Text = details
        detailsText.TextColor3 = Colors.TextDim
        detailsText.TextSize = 10
        detailsText.Font = Enum.Font.Code
        detailsText.TextXAlignment = Enum.TextXAlignment.Left
        detailsText.TextYAlignment = Enum.TextYAlignment.Top
        detailsText.TextWrapped = true
        detailsText.BackgroundTransparency = 1
        detailsText.AutomaticSize = Enum.AutomaticSize.Y
        detailsText.ZIndex = 10003
        detailsText.Parent = detailsScroll
        
        detailsScroll.CanvasSize = UDim2.new(0, 0, 0, detailsText.TextBounds.Y + 10)
    end
    
    -- الأزرار
    local buttons = Instance.new("Frame")
    buttons.Name = "Buttons"
    buttons.Size = UDim2.new(1, -20, 0, 40)
    buttons.Position = UDim2.new(0, 10, 1, -50)
    buttons.BackgroundTransparency = 1
    buttons.ZIndex = 10000
    buttons.Parent = popup
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.Parent = buttons
    
    -- دالة إنشاء زر
    local function CreateButton(text, icon, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 35)
        btn.BackgroundColor3 = color or Colors.Button
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 10001
        btn.Parent = buttons
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = color or Colors.Button
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.5
        btnStroke.Parent = btn
        
        local btnIcon = Instance.new("TextLabel")
        btnIcon.Size = UDim2.new(0, 25, 1, 0)
        btnIcon.Position = UDim2.new(0, 5, 0, 0)
        btnIcon.Text = icon
        btnIcon.TextSize = 14
        btnIcon.BackgroundTransparency = 1
        btnIcon.ZIndex = 10002
        btnIcon.Parent = btn
        
        local btnText = Instance.new("TextLabel")
        btnText.Size = UDim2.new(1, -35, 1, 0)
        btnText.Position = UDim2.new(0, 30, 0, 0)
        btnText.Text = text
        btnText.TextColor3 = Colors.Text
        btnText.TextSize = 12
        btnText.Font = Enum.Font.GothamBold
        btnText.BackgroundTransparency = 1
        btnText.ZIndex = 10002
        btnText.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.ButtonHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = color or Colors.Button}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
            -- إغلاق النافذة
            Tween(popup, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.2)
            Tween(overlay, {BackgroundTransparency = 1}, 0.2)
            task.delay(0.25, function()
                gui:Destroy()
            end)
        end)
        
        return btn
    end
    
    -- زر نسخ
    CreateButton("Copy", "📋", Colors.Button, function()
        local textToCopy = title .. "\n" .. message
        if details ~= "" then textToCopy = textToCopy .. "\n\n" .. details end
        pcall(function()
            if setclipboard then setclipboard(textToCopy) end
        end)
    end)
    
    -- زر إعادة المحاولة (اختياري)
    if onRetry then
        CreateButton("Retry", "🔄", Color3.fromRGB(0, 100, 200), function()
            onRetry()
        end)
    end
    
    -- زر إغلاق
    CreateButton("Close", "✕", Colors.Button, function()
        if onClose then onClose() end
    end)
    
    -- ═══ أنيميشن الظهور ═══
    local popupWidth = 350
    local popupHeight = 200
    if detailsFrame then popupHeight = popupHeight + 90 end
    
    popup.Position = UDim2.new(0.5, 0, 0.5, 0)
    popup.Size = UDim2.new(0, 0, 0, 0)
    
    Tween(popup, {
        Size = UDim2.new(0, popupWidth, 0, popupHeight),
        Position = UDim2.new(0.5, -popupWidth/2, 0.5, -popupHeight/2)
    }, 0.4, Enum.EasingStyle.Back)
    
    -- ═══ إغلاق عند النقر على الخلفية ═══
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if onClose then onClose() end
            Tween(popup, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.2)
            Tween(overlay, {BackgroundTransparency = 1}, 0.2)
            task.delay(0.25, function()
                gui:Destroy()
            end)
        end
    end)
    
    -- زر الإغلاق
    closeBtn.MouseButton1Click:Connect(function()
        if onClose then onClose() end
        Tween(popup, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.2)
        Tween(overlay, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.25, function()
            gui:Destroy()
        end)
    end)
    
    return {
        close = function()
            Tween(popup, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.2)
            Tween(overlay, {BackgroundTransparency = 1}, 0.2)
            task.delay(0.25, function()
                gui:Destroy()
            end)
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- ❌ اختصارات سريعة
-- ═══════════════════════════════════════════════════════════════════════
function ErrorPopup.Error(title, message, details, onRetry)
    return ErrorPopup.Show({
        title = title,
        message = message,
        details = details,
        type = "error",
        onRetry = onRetry
    })
end

function ErrorPopup.Warning(title, message, details)
    return ErrorPopup.Show({
        title = title,
        message = message,
        details = details,
        type = "warning"
    })
end

function ErrorPopup.Info(title, message, details)
    return ErrorPopup.Show({
        title = title,
        message = message,
        details = details,
        type = "info"
    })
end

function ErrorPopup.Success(title, message, details)
    return ErrorPopup.Show({
        title = title,
        message = message,
        details = details,
        type = "success"
    })
end

print("❌ Error Popup v1.0 Loaded!")

return ErrorPopup
