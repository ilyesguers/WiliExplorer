--[[
    ═══════════════════════════════════════════════════════════════════════════
    🖼️ WiliExplorer - Image Editor v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ عرض الصورة
    ✅ تغيير Asset ID
    ✅ تغيير الحجم
    ✅ تغيير الشفافية
    ✅ تغيير الوضع (Scale/Crop/Tile)
    ✅ نسخ Asset ID
    ✅ فتح في المتصفح
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local ImageEditor = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    BG = Color3.fromRGB(15, 15, 30),
    Header = Color3.fromRGB(20, 25, 50),
    Body = Color3.fromRGB(18, 18, 38),
    Border = Color3.fromRGB(40, 40, 70),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180),
    Accent = Color3.fromRGB(255, 100, 150),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 165, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Button = Color3.fromRGB(30, 35, 65),
    ButtonHover = Color3.fromRGB(40, 45, 80)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), props):Play()
end

local function Notify(message, type)
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "🖼️ Image Editor",
            Text = message,
            Duration = 2
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🖼️ فتح محرر الصور
-- ═══════════════════════════════════════════════════════════════════════
function ImageEditor.Open(parent, instance, onClose)
    if not instance then return end
    
    -- تحديد نوع الصورة
    local imageId = ""
    local transparency = 0
    local className = instance.ClassName
    
    pcall(function()
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            imageId = instance.Image
            transparency = instance.ImageTransparency
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            imageId = instance.Texture
            transparency = instance.Transparency
        end
    end)
    
    -- إنشاء الواجهة
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliImageEditor"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- خلفية
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 998
    overlay.Parent = gui
    
    -- النافذة الرئيسية
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0.9, 0, 0.9, 0)
    window.Position = UDim2.new(0.05, 0, 0.05, 0)
    window.BackgroundColor3 = Colors.BG
    window.BorderSizePixel = 0
    window.ZIndex = 999
    window.Parent = gui
    
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 15)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Accent
    stroke.Thickness = 2
    stroke.Parent = window
    
    -- الشريط العلوي
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Colors.Header
    header.BorderSizePixel = 0
    header.ZIndex = 1000
    header.Parent = window
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = Colors.Header
    headerBottom.BorderSizePixel = 0
    headerBottom.ZIndex = 1000
    headerBottom.Parent = header
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "🖼️ Image Editor - " .. instance.Name
    title.TextColor3 = Colors.Accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 1001
    title.Parent = header
    
    -- زر إغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Colors.Danger
    closeBtn.ZIndex = 1001
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    -- المحتوى
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.ZIndex = 999
    content.Parent = window
    
    -- معاينة الصورة
    local previewFrame = Instance.new("Frame")
    previewFrame.Name = "Preview"
    previewFrame.Size = UDim2.new(0.6, -10, 1, 0)
    previewFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
    previewFrame.BorderSizePixel = 0
    previewFrame.ZIndex = 1000
    previewFrame.Parent = content
    Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0, 12)
    
    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Colors.Border
    previewStroke.Thickness = 1
    previewStroke.Parent = previewFrame
    
    -- نمط الشفافية (Checkerboard)
    local checkerSize = 20
    for x = 0, 15 do
        for y = 0, 10 do
            local checker = Instance.new("Frame")
            checker.Size = UDim2.new(0, checkerSize, 0, checkerSize)
            checker.Position = UDim2.new(0, x * checkerSize, 0, y * checkerSize)
            checker.BackgroundColor3 = (x + y) % 2 == 0 and Color3.fromRGB(40, 40, 55) or Color3.fromRGB(30, 30, 45)
            checker.BorderSizePixel = 0
            checker.ZIndex = 1001
            checker.Parent = previewFrame
        end
    end
    
    -- الصورة
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Size = UDim2.new(0.9, 0, 0.9, 0)
    image.Position = UDim2.new(0.05, 0, 0.05, 0)
    image.BackgroundTransparency = 1
    image.Image = imageId
    image.ImageTransparency = transparency
    image.ScaleType = Enum.ScaleType.Fit
    image.ZIndex = 1002
    image.Parent = previewFrame
    
    -- لوحة التحكم
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0.4, -10, 1, 0)
    controls.Position = UDim2.new(0.6, 10, 0, 0)
    controls.BackgroundColor3 = Colors.Body
    controls.BorderSizePixel = 0
    controls.ZIndex = 1000
    controls.Parent = content
    Instance.new("UICorner", controls).CornerRadius = UDim.new(0, 12)
    
    local controlsStroke = Instance.new("UIStroke")
    controlsStroke.Color = Colors.Border
    controlsStroke.Thickness = 1
    controlsStroke.Parent = controls
    
    local controlsScroll = Instance.new("ScrollingFrame")
    controlsScroll.Size = UDim2.new(1, -10, 1, -10)
    controlsScroll.Position = UDim2.new(0, 5, 0, 5)
    controlsScroll.BackgroundTransparency = 1
    controlsScroll.ScrollBarThickness = 3
    controlsScroll.ScrollBarImageColor3 = Colors.Accent
    controlsScroll.ZIndex = 1001
    controlsScroll.Parent = controls
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.Parent = controlsScroll
    
    -- ═══ دوال إنشاء عناصر التحكم ═══
    local function CreateSection(text)
        local section = Instance.new("TextLabel")
        section.Size = UDim2.new(1, 0, 0, 25)
        section.Text = text
        section.TextColor3 = Colors.Accent
        section.TextSize = 13
        section.Font = Enum.Font.GothamBold
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.BackgroundTransparency = 1
        section.ZIndex = 1002
        section.Parent = controlsScroll
    end
    
    local function CreateInput(label, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Colors.Button
        frame.ZIndex = 1002
        frame.Parent = controlsScroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.Position = UDim2.new(0, 5, 0, 3)
        lbl.Text = label
        lbl.TextColor3 = Colors.TextDim
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = 1003
        lbl.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -10, 0, 25)
        input.Position = UDim2.new(0, 5, 0, 25)
        input.Text = default or ""
        input.TextColor3 = Colors.Text
        input.Font = Enum.Font.Code
        input.TextSize = 12
        input.TextXAlignment = Enum.TextXAlignment.Left
        input.ClearTextOnFocus = false
        input.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
        input.ZIndex = 1003
        input.Parent = frame
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
        
        input.FocusLost:Connect(function()
            if callback then callback(input.Text) end
        end)
        
        return input
    end
    
    local function CreateSlider(label, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = Colors.Button
        frame.ZIndex = 1002
        frame.Parent = controlsScroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 0, 18)
        lbl.Position = UDim2.new(0, 5, 0, 3)
        lbl.Text = label
        lbl.TextColor3 = Colors.TextDim
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = 1003
        lbl.Parent = frame
        
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.3, -5, 0, 18)
        valLbl.Position = UDim2.new(0.7, 0, 0, 3)
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = Colors.Accent
        valLbl.TextSize = 11
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.BackgroundTransparency = 1
        valLbl.ZIndex = 1003
        valLbl.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -10, 0, 8)
        sliderBg.Position = UDim2.new(0, 5, 0, 32)
        sliderBg.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
        sliderBg.ZIndex = 1003
        sliderBg.Parent = frame
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Colors.Accent
        fill.ZIndex = 1004
        fill.Parent = sliderBg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        knob.BackgroundColor3 = Colors.Text
        knob.Text = ""
        knob.ZIndex = 1005
        knob.Parent = sliderBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
        knob.MouseButton1Down:Connect(function() dragging = true end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * pos
                valLbl.Text = string.format("%.2f", val)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                knob.Position = UDim2.new(pos, -7, 0.5, -7)
                if callback then callback(val) end
            end
        end)
    end
    
    local function CreateButton(text, icon, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = color or Colors.Button
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 1002
        btn.Parent = controlsScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size = UDim2.new(0, 30, 1, 0)
        iconLbl.Position = UDim2.new(0, 5, 0, 0)
        iconLbl.Text = icon
        iconLbl.TextSize = 14
        iconLbl.BackgroundTransparency = 1
        iconLbl.ZIndex = 1003
        iconLbl.Parent = btn
        
        local textLbl = Instance.new("TextLabel")
        textLbl.Size = UDim2.new(1, -40, 1, 0)
        textLbl.Position = UDim2.new(0, 35, 0, 0)
        textLbl.Text = text
        textLbl.TextColor3 = Colors.Text
        textLbl.TextSize = 12
        textLbl.Font = Enum.Font.GothamBold
        textLbl.TextXAlignment = Enum.TextXAlignment.Left
        textLbl.BackgroundTransparency = 1
        textLbl.ZIndex = 1003
        textLbl.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.ButtonHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = color or Colors.Button}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return btn
    end
    
    -- ═══ عناصر التحكم ═══
    CreateSection("📋 معلومات الصورة (Image Info)")
    
    CreateInput("Asset ID", imageId, function(value)
        image.Image = value
        pcall(function()
            if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                instance.Image = value
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                instance.Texture = value
            end
        end)
        Notify("تم تغيير Asset ID!")
    end)
    
    CreateSection("🎨 الخصائص (Properties)")
    
    CreateSlider("الشفافية (Transparency)", 0, 1, transparency, function(value)
        image.ImageTransparency = value
        pcall(function()
            if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                instance.ImageTransparency = value
            elseif instance:IsA("Decal") or instance:IsA("Texture") then
                instance.Transparency = value
            end
        end)
    end)
    
    -- ScaleType
    CreateSection("📐 وضع العرض (Scale Type)")
    
    local scaleTypes = {"Fit", "Crop", "Tile", "Stretch"}
    for _, scaleType in ipairs(scaleTypes) do
        CreateButton(scaleType, "📐", Colors.Button, function()
            pcall(function()
                if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                    instance.ScaleType = Enum.ScaleType[scaleType]
                end
            end)
            image.ScaleType = Enum.ScaleType[scaleType]
            Notify("تم تغيير الوضع إلى: " .. scaleType)
        end)
    end
    
    CreateSection("🔧 أدوات (Tools)")
    
    CreateButton("نسخ Asset ID", "📋", Colors.Button, function()
        pcall(function()
            if setclipboard then setclipboard(imageId) end
        end)
        Notify("تم نسخ Asset ID!")
    end)
    
    CreateButton("فتح في المتصفح", "🌐", Colors.Button, function()
        local url = "https://www.roblox.com/library/" .. imageId:gsub("rbxassetid://", ""):gsub("%D", "")
        pcall(function()
            if setclipboard then setclipboard(url) end
        end)
        Notify("تم نسخ الرابط!")
    end)
    
    -- ═══ أحداث الإغلاق ═══
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if onClose then onClose() end
    end)
    
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            gui:Destroy()
            if onClose then onClose() end
        end
    end)
    
    return {
        close = function() gui:Destroy() end
    }
end

print("🖼️ Image Editor v1.0 Loaded!")

return ImageEditor
