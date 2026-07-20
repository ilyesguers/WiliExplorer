--[[
    ═══════════════════════════════════════════════════════════════════════════
    👑 WiliExplorer - KLIMBO MENU v4.0 (Cosmic Ultimate Edition)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ الميزات:
    • تصميم فضائي مع أنيميشن متقدم
    • السرعة القابلة للتعديل
    • القفز القابل للتعديل
    • سرقة الملابس (مُصلح)
    • ESP متقدم مع خيارات
    • Aimbot ذكي
    • الطيران (مُصلح)
    • التحكم بـ NPC/Player
    • وأكثر...
    
    📱 متوافق مع: Delta, Synapse, Fluxus, Arceus X
    ═══════════════════════════════════════════════════════════════════════════
]]

local KlimboMenu = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🔧 الخدمات
-- ═══════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════
-- 📊 المتغيرات العامة
-- ═══════════════════════════════════════════════════════════════════════════

local KlimboUI = nil
local IsOpen = false
local CurrentTab = "Speed"
local Connections = {}

-- إعدادات الميزات
local Settings = {
    -- السرعة
    Speed = {
        Enabled = false,
        Value = 16,
        Min = 0,
        Max = 500
    },
    -- القفز
    Jump = {
        Enabled = false,
        Value = 50,
        Min = 0,
        Max = 500
    },
    -- الطيران
    Fly = {
        Enabled = false,
        Speed = 50
    },
    -- القفزات المتتالية
    InfiniteJump = {
        Enabled = false
    },
    -- التجميد
    Freeze = {
        Enabled = false,
        FrozenPlayers = {}
    },
    -- ESP
    ESP = {
        Enabled = false,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBoxes = true,
        ShowTracers = false,
        TeamCheck = false,
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 255, 0),
        TracerColor = Color3.fromRGB(255, 0, 0),
        HealthBarColor = Color3.fromRGB(0, 255, 0)
    },
    -- Aimbot
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        AimPart = "Head",
        Smoothness = 0.5,
        FOV = 200,
        ShowFOV = true
    },
    -- التحكم
    Control = {
        Enabled = false,
        Target = nil
    },
    -- Noclip
    Noclip = {
        Enabled = false
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 الألوان الفضائية
-- ═══════════════════════════════════════════════════════════════════════════

local Colors = {
    BG_Primary = Color3.fromRGB(8, 10, 25),
    BG_Secondary = Color3.fromRGB(15, 18, 45),
    BG_Tertiary = Color3.fromRGB(25, 30, 70),
    BG_Card = Color3.fromRGB(20, 25, 55),
    
    Accent = Color3.fromRGB(255, 0, 128),
    AccentAlt = Color3.fromRGB(0, 255, 255),
    AccentGold = Color3.fromRGB(255, 215, 0),
    
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 160, 200),
    
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 71, 87),
    Warning = Color3.fromRGB(255, 165, 2),
    
    GradientStart = Color3.fromRGB(255, 0, 128),
    GradientEnd = Color3.fromRGB(0, 255, 255)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateTween(object, props, duration, style, direction)
    return TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function AddGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    if type(colors) == "table" then
        local keypoints = {}
        for i, color in ipairs(colors) do
            table.insert(keypoints, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
        end
        gradient.Color = ColorSequence.new(keypoints)
    else
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.GradientStart),
            ColorSequenceKeypoint.new(1, Colors.GradientEnd)
        })
    end
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ⭐ إنشاء النجوم المتحركة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateStars(parent, count)
    local container = Instance.new("Frame")
    container.Name = "StarsContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 0
    container.Parent = parent
    
    for i = 1, count do
        local star = Instance.new("Frame")
        star.Name = "Star" .. i
        local size = math.random(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(math.random() , 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.ZIndex = 1
        star.Parent = container
        AddCorner(star, size)
        
        -- تأثير التلألؤ
        spawn(function()
            while star.Parent do
                local duration = math.random(10, 25) / 10
                CreateTween(star, {BackgroundTransparency = math.random(30, 80) / 100}, duration):Play()
                wait(duration)
                CreateTween(star, {BackgroundTransparency = 0}, duration):Play()
                wait(duration)
            end
        end)
    end
    
    -- شهب متحركة
    spawn(function()
        while container.Parent do
            wait(math.random(3, 8))
            
            local meteor = Instance.new("Frame")
            meteor.Size = UDim2.new(0, math.random(30, 60), 0, 2)
            meteor.Position = UDim2.new(math.random(), 0, -0.1, 0)
            meteor.Rotation = 45
            meteor.BackgroundColor3 = Colors.AccentAlt
            meteor.BorderSizePixel = 0
            meteor.ZIndex = 2
            meteor.Parent = container
            AddCorner(meteor, 2)
            AddGradient(meteor)
            
            CreateTween(meteor, {
                Position = UDim2.new(meteor.Position.X.Scale + 0.5, 0, 1.1, 0),
                BackgroundTransparency = 1
            }, 1, Enum.EasingStyle.Linear):Play()
            
            game:GetService("Debris"):AddItem(meteor, 1.5)
        end
    end)
    
    return container
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎛️ إنشاء عناصر الواجهة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateToggle(parent, name, description, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 60)
    toggle.BackgroundColor3 = Colors.BG_Card
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    AddCorner(toggle, 12)
    AddStroke(toggle, Colors.BG_Tertiary, 1, 0.5)
    
    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -70, 1, 0)
    info.Position = UDim2.new(0, 15, 0, 0)
    info.BackgroundTransparency = 1
    info.Parent = toggle
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = info
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 20)
    desc.Position = UDim2.new(0, 0, 0, 32)
    desc.Text = description
    desc.TextColor3 = Colors.TextSecondary
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    desc.Parent = info
    
    local btn = Instance.new("Frame")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -60, 0.5, -13)
    btn.BackgroundColor3 = default and Colors.Success or Colors.BG_Tertiary
    btn.BorderSizePixel = 0
    btn.Parent = toggle
    AddCorner(btn, 13)
    
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Colors.TextPrimary
    circle.BorderSizePixel = 0
    circle.Parent = btn
    AddCorner(circle, 10)
    
    local enabled = default
    
    local function UpdateToggle()
        CreateTween(btn, {BackgroundColor3 = enabled and Colors.Success or Colors.BG_Tertiary}, 0.2):Play()
        CreateTween(circle, {Position = enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}, 0.2):Play()
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            UpdateToggle()
            if callback then callback(enabled) end
        end
    end)
    
    return toggle, function() return enabled end, function(val) enabled = val UpdateToggle() end
end

local function CreateSlider(parent, name, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(1, -20, 0, 70)
    slider.BackgroundColor3 = Colors.BG_Card
    slider.BorderSizePixel = 0
    slider.Parent = parent
    AddCorner(slider, 12)
    AddStroke(slider, Colors.BG_Tertiary, 1, 0.5)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.55, 0, 0, 8)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Colors.AccentAlt
    valueLabel.TextSize = 16
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 8)
    track.Position = UDim2.new(0, 15, 0, 45)
    track.BackgroundColor3 = Colors.BG_Tertiary
    track.BorderSizePixel = 0
    track.Parent = slider
    AddCorner(track, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    AddCorner(fill, 4)
    AddGradient(fill)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    knob.BackgroundColor3 = Colors.TextPrimary
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    AddCorner(knob, 10)
    AddStroke(knob, Colors.Accent, 2)
    
    local dragging = false
    local value = default
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        valueLabel.Text = tostring(value)
        CreateTween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1):Play()
        CreateTween(knob, {Position = UDim2.new(pos, -10, 0.5, -10)}, 0.1):Play()
        if callback then callback(value) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return slider, function() return value end, function(val) 
        value = val
        valueLabel.Text = tostring(val)
        local pos = (val - min) / (max - min)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -10, 0.5, -10)
    end
end

local function CreateButton(parent, name, description, callback)
    local btn = Instance.new("Frame")
    btn.Name = name .. "Button"
    btn.Size = UDim2.new(1, -20, 0, 55)
    btn.BackgroundColor3 = Colors.BG_Card
    btn.BorderSizePixel = 0
    btn.Parent = parent
    AddCorner(btn, 12)
    AddStroke(btn, Colors.BG_Tertiary, 1, 0.5)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = btn
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -80, 0, 18)
    desc.Position = UDim2.new(0, 15, 0, 30)
    desc.Text = description
    desc.TextColor3 = Colors.TextSecondary
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    desc.Parent = btn
    
    local actionBtn = Instance.new("TextButton")
    actionBtn.Size = UDim2.new(0, 50, 0, 30)
    actionBtn.Position = UDim2.new(1, -60, 0.5, -15)
    actionBtn.Text = "➤"
    actionBtn.TextColor3 = Colors.TextPrimary
    actionBtn.TextSize = 16
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.BackgroundColor3 = Colors.Accent
    actionBtn.BorderSizePixel = 0
    actionBtn.Parent = btn
    AddCorner(actionBtn, 8)
    AddGradient(actionBtn)
    
    actionBtn.MouseButton1Click:Connect(function()
        CreateTween(actionBtn, {Size = UDim2.new(0, 45, 0, 28)}, 0.1):Play()
        wait(0.1)
        CreateTween(actionBtn, {Size = UDim2.new(0, 50, 0, 30)}, 0.1):Play()
        if callback then callback() end
    end)
    
    return btn
end

local function CreateDropdown(parent, name, options, default, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = name .. "Dropdown"
    dropdown.Size = UDim2.new(1, -20, 0, 55)
    dropdown.BackgroundColor3 = Colors.BG_Card
    dropdown.BorderSizePixel = 0
    dropdown.ClipsDescendants = true
    dropdown.Parent = parent
    AddCorner(dropdown, 12)
    AddStroke(dropdown, Colors.BG_Tertiary, 1, 0.5)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 55)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = dropdown
    
    local selected = Instance.new("TextButton")
    selected.Size = UDim2.new(0.45, -10, 0, 35)
    selected.Position = UDim2.new(0.5, 5, 0, 10)
    selected.Text = default .. " ▼"
    selected.TextColor3 = Colors.AccentAlt
    selected.TextSize = 13
    selected.Font = Enum.Font.GothamBold
    selected.BackgroundColor3 = Colors.BG_Tertiary
    selected.BorderSizePixel = 0
    selected.Parent = dropdown
    AddCorner(selected, 8)
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, -20, 0, #options * 35 + 10)
    optionsFrame.Position = UDim2.new(0, 10, 0, 55)
    optionsFrame.BackgroundColor3 = Colors.BG_Tertiary
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = dropdown
    AddCorner(optionsFrame, 8)
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = optionsFrame
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingLeft = UDim.new(0, 5)
    pad.PaddingRight = UDim.new(0, 5)
    pad.Parent = optionsFrame
    
    local isOpen = false
    local currentValue = default
    
    for _, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 30)
        optBtn.Text = option
        optBtn.TextColor3 = Colors.TextPrimary
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BackgroundColor3 = Colors.BG_Card
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 11
        optBtn.Parent = optionsFrame
        AddCorner(optBtn, 6)
        
        optBtn.MouseButton1Click:Connect(function()
            currentValue = option
            selected.Text = option .. " ▼"
            isOpen = false
            optionsFrame.Visible = false
            CreateTween(dropdown, {Size = UDim2.new(1, -20, 0, 55)}, 0.2):Play()
            if callback then callback(option) end
        end)
    end
    
    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        CreateTween(dropdown, {Size = UDim2.new(1, -20, 0, isOpen and (55 + #options * 35 + 20) or 55)}, 0.2):Play()
    end)
    
    return dropdown, function() return currentValue end
end

local function CreateColorPicker(parent, name, default, callback)
    local picker = Instance.new("Frame")
    picker.Name = name .. "ColorPicker"
    picker.Size = UDim2.new(1, -20, 0, 55)
    picker.BackgroundColor3 = Colors.BG_Card
    picker.BorderSizePixel = 0
    picker.Parent = parent
    AddCorner(picker, 12)
    AddStroke(picker, Colors.BG_Tertiary, 1, 0.5)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = picker
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 80, 0, 35)
    colorDisplay.Position = UDim2.new(1, -95, 0.5, -17)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = picker
    AddCorner(colorDisplay, 8)
    AddStroke(colorDisplay, Colors.TextPrimary, 2, 0.5)
    
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 128, 255),
        Color3.fromRGB(128, 0, 255),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 255, 255)
    }
    
    local colorIndex = 1
    local currentColor = default
    
    colorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            colorIndex = colorIndex % #colors + 1
            currentColor = colors[colorIndex]
            CreateTween(colorDisplay, {BackgroundColor3 = currentColor}, 0.2):Play()
            if callback then callback(currentColor) end
        end
    end)
    
    return picker, function() return currentColor end
end

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 35)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "═══ " .. title .. " ═══"
    label.TextColor3 = Colors.AccentGold
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎯 وظائف الميزات
-- ═══════════════════════════════════════════════════════════════════════════

-- السرعة
local function SetSpeed(enabled, value)
    Settings.Speed.Enabled = enabled
    Settings.Speed.Value = value or Settings.Speed.Value
    
    local humanoid = GetHumanoid()
    if humanoid then
        if enabled then
            humanoid.WalkSpeed = Settings.Speed.Value
        else
            humanoid.WalkSpeed = 16
        end
    end
end

-- القفز
local function SetJump(enabled, value)
    Settings.Jump.Enabled = enabled
    Settings.Jump.Value = value or Settings.Jump.Value
    
    local humanoid = GetHumanoid()
    if humanoid then
        if enabled then
            humanoid.JumpPower = Settings.Jump.Value
        else
            humanoid.JumpPower = 50
        end
    end
end

-- الطيران (مُصلح)
local flyBodyVelocity = nil
local flyBodyGyro = nil

local function SetFly(enabled)
    Settings.Fly.Enabled = enabled
    
    local root = GetRootPart()
    local humanoid = GetHumanoid()
    
    if not root or not humanoid then return end
    
    if enabled then
        -- إزالة القديم
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Name = "KlimboFly"
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = root
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "KlimboFlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.P = 9e4
        flyBodyGyro.D = 500
        flyBodyGyro.Parent = root
        
        humanoid.PlatformStand = true
        
        Connections["Fly"] = RunService.RenderStepped:Connect(function()
            if not Settings.Fly.Enabled then return end
            
            local camera = Camera
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end
            
            flyBodyVelocity.Velocity = moveVector * Settings.Fly.Speed
            flyBodyGyro.CFrame = camera.CFrame
        end)
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        humanoid.PlatformStand = false
        
        if Connections["Fly"] then
            Connections["Fly"]:Disconnect()
            Connections["Fly"] = nil
        end
    end
end

-- القفزات المتتالية
local function SetInfiniteJump(enabled)
    Settings.InfiniteJump.Enabled = enabled
    
    if enabled then
        Connections["InfiniteJump"] = UserInputService.JumpRequest:Connect(function()
            if Settings.InfiniteJump.Enabled then
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections["InfiniteJump"] then
            Connections["InfiniteJump"]:Disconnect()
            Connections["InfiniteJump"] = nil
        end
    end
end

-- Noclip
local function SetNoclip(enabled)
    Settings.Noclip.Enabled = enabled
    
    if enabled then
        Connections["Noclip"] = RunService.Stepped:Connect(function()
            if Settings.Noclip.Enabled then
                local char = GetCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if Connections["Noclip"] then
            Connections["Noclip"]:Disconnect()
            Connections["Noclip"] = nil
        end
        -- إعادة التصادم
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- سرقة الملابس (مُصلح)
local function StealOutfit(targetPlayer)
    local myChar = GetCharacter()
    local targetChar = targetPlayer.Character
    
    if not myChar or not targetChar then return false end
    
    local humanoidDesc = nil
    
    pcall(function()
        local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then
            humanoidDesc = targetHumanoid:GetAppliedDescription()
        end
    end)
    
    if humanoidDesc then
        pcall(function()
            local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
            if myHumanoid then
                myHumanoid:ApplyDescription(humanoidDesc)
            end
        end)
        return true
    end
    
    -- طريقة بديلة
    pcall(function()
        -- نسخ الملابس يدوياً
        for _, item in ipairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                local existing = myChar:FindFirstChildOfClass(item.ClassName)
                if existing then existing:Destroy() end
                item:Clone().Parent = myChar
            end
            if item:IsA("Accessory") then
                item:Clone().Parent = myChar
            end
        end
        
        -- نسخ ألوان الجسم
        local targetBC = targetChar:FindFirstChildOfClass("BodyColors")
        if targetBC then
            local myBC = myChar:FindFirstChildOfClass("BodyColors")
            if myBC then myBC:Destroy() end
            targetBC:Clone().Parent = myChar
        end
    end)
    
    return true
end

-- ESP
local ESPFolder = nil

local function CreateESP()
    if ESPFolder then ESPFolder:Destroy() end
    ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "KlimboESP"
    ESPFolder.Parent = game:GetService("CoreGui")
end

local function UpdateESP()
    if not Settings.ESP.Enabled then
        if ESPFolder then ESPFolder:Destroy() ESPFolder = nil end
        return
    end
    
    if not ESPFolder then CreateESP() end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                
                if humanoid and root and head and humanoid.Health > 0 then
                    local espName = "ESP_" .. player.Name
                    local billboard = ESPFolder:FindFirstChild(espName)
                    
                    if not billboard then
                        billboard = Instance.new("BillboardGui")
                        billboard.Name = espName
                        billboard.Size = UDim2.new(0, 150, 0, 80)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = ESPFolder
                        
                        if Settings.ESP.ShowNames then
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Name = "Name"
                            nameLabel.Size = UDim2.new(1, 0, 0, 20)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Settings.ESP.NameColor
                            nameLabel.TextSize = 14
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextStrokeTransparency = 0.5
                            nameLabel.Parent = billboard
                        end
                        
                        if Settings.ESP.ShowDistance then
                            local distLabel = Instance.new("TextLabel")
                            distLabel.Name = "Distance"
                            distLabel.Size = UDim2.new(1, 0, 0, 15)
                            distLabel.Position = UDim2.new(0, 0, 0, 20)
                            distLabel.BackgroundTransparency = 1
                            distLabel.TextColor3 = Colors.AccentAlt
                            distLabel.TextSize = 12
                            distLabel.Font = Enum.Font.Gotham
                            distLabel.TextStrokeTransparency = 0.5
                            distLabel.Parent = billboard
                        end
                        
                        if Settings.ESP.ShowHealth then
                            local healthBar = Instance.new("Frame")
                            healthBar.Name = "HealthBar"
                            healthBar.Size = UDim2.new(0.8, 0, 0, 6)
                            healthBar.Position = UDim2.new(0.1, 0, 0, 38)
                            healthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            healthBar.BorderSizePixel = 0
                            healthBar.Parent = billboard
                            AddCorner(healthBar, 3)
                            
                            local healthFill = Instance.new("Frame")
                            healthFill.Name = "Fill"
                            healthFill.Size = UDim2.new(1, 0, 1, 0)
                            healthFill.BackgroundColor3 = Settings.ESP.HealthBarColor
                            healthFill.BorderSizePixel = 0
                            healthFill.Parent = healthBar
                            AddCorner(healthFill, 3)
                        end
                        
                        if Settings.ESP.ShowBoxes then
                            local box = Instance.new("BoxHandleAdornment")
                            box.Name = "Box"
                            box.Color3 = Settings.ESP.BoxColor
                            box.Transparency = 0.7
                            box.Size = Vector3.new(4, 6, 2)
                            box.AlwaysOnTop = true
                            box.ZIndex = 1
                            box.Parent = billboard
                        end
                    end
                    
                    billboard.Adornee = head
                    
                    -- تحديث
                    if Settings.ESP.ShowNames then
                        local nameLabel = billboard:FindFirstChild("Name")
                        if nameLabel then
                            nameLabel.Text = player.Name
                            nameLabel.TextColor3 = Settings.ESP.NameColor
                        end
                    end
                    
                    if Settings.ESP.ShowDistance then
                        local distLabel = billboard:FindFirstChild("Distance")
                        local myRoot = GetRootPart()
                        if distLabel and myRoot then
                            local dist = (root.Position - myRoot.Position).Magnitude
                            distLabel.Text = string.format("%.0f studs", dist)
                        end
                    end
                    
                    if Settings.ESP.ShowHealth then
                        local healthBar = billboard:FindFirstChild("HealthBar")
                        if healthBar then
                            local fill = healthBar:FindFirstChild("Fill")
                            if fill then
                                fill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                                -- لون حسب الصحة
                                local healthPercent = humanoid.Health / humanoid.MaxHealth
                                if healthPercent > 0.6 then
                                    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                                elseif healthPercent > 0.3 then
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                                else
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                                end
                            end
                        end
                    end
                    
                    if Settings.ESP.ShowBoxes then
                        local box = billboard:FindFirstChild("Box")
                        if box then
                            box.Adornee = root
                            box.Color3 = Settings.ESP.BoxColor
                        end
                    end
                else
                    local billboard = ESPFolder:FindFirstChild(espName)
                    if billboard then billboard:Destroy() end
                end
            end
        end
    end
end

local function SetESP(enabled)
    Settings.ESP.Enabled = enabled
    
    if enabled then
        CreateESP()
        Connections["ESP"] = RunService.RenderStepped:Connect(UpdateESP)
    else
        if Connections["ESP"] then
            Connections["ESP"]:Disconnect()
            Connections["ESP"] = nil
        end
        if ESPFolder then ESPFolder:Destroy() ESPFolder = nil end
    end
end

-- Aimbot
local FOVCircle = nil

local function SetAimbot(enabled)
    Settings.Aimbot.Enabled = enabled
    
    if enabled then
        -- إنشاء دائرة FOV
        if Settings.Aimbot.ShowFOV then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Visible = true
            FOVCircle.Radius = Settings.Aimbot.FOV
            FOVCircle.Color = Colors.Accent
            FOVCircle.Thickness = 2
            FOVCircle.Filled = false
            FOVCircle.Transparency = 0.8
        end
        
        Connections["Aimbot"] = RunService.RenderStepped:Connect(function()
            if not Settings.Aimbot.Enabled then return end
            
            -- تحديث موقع الدائرة
            if FOVCircle then
                local center = Camera.ViewportSize / 2
                FOVCircle.Position = Vector2.new(center.X, center.Y)
                FOVCircle.Radius = Settings.Aimbot.FOV
            end
            
            -- التصويب عند الضغط
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local closestPlayer = nil
                local closestDistance = Settings.Aimbot.FOV
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local char = player.Character
                        if char then
                            local aimPart = char:FindFirstChild(Settings.Aimbot.AimPart) or char:FindFirstChild("Head")
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            
                            if aimPart and humanoid and humanoid.Health > 0 then
                                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                                
                                if onScreen then
                                    local center = Camera.ViewportSize / 2
                                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(center.X, center.Y)).Magnitude
                                    
                                    if distance < closestDistance then
                                        closestDistance = distance
                                        closestPlayer = aimPart
                                    end
                                end
                            end
                        end
                    end
                end
                
                if closestPlayer then
                    local targetCFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Aimbot.Smoothness)
                end
            end
        end)
    else
        if FOVCircle then FOVCircle:Remove() FOVCircle = nil end
        if Connections["Aimbot"] then
            Connections["Aimbot"]:Disconnect()
            Connections["Aimbot"] = nil
        end
    end
end

-- التحكم بـ NPC/Player
local ControlConnection = nil
local OriginalCharacter = nil

local function SetControl(target)
    if not target or not target.Character then return false end
    
    local targetChar = target.Character
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    
    if not targetHumanoid or not targetRoot then return false end
    
    -- حفظ الشخصية الأصلية
    OriginalCharacter = LocalPlayer.Character
    
    -- التحكم بالكاميرا
    Camera.CameraSubject = targetHumanoid
    
    -- التحكم بالحركة
    ControlConnection = RunService.RenderStepped:Connect(function()
        if not Settings.Control.Enabled or not targetRoot.Parent then
            if ControlConnection then
                ControlConnection:Disconnect()
                ControlConnection = nil
            end
            -- إرجاع الكاميرا
            local myHumanoid = GetHumanoid()
            if myHumanoid then
                Camera.CameraSubject = myHumanoid
            end
            return
        end
        
        -- نسخ الحركة
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + Camera.CFrame.RightVector
        end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * 16
            targetRoot.CFrame = targetRoot.CFrame + moveDir * 0.05
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            targetHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    Settings.Control.Target = target
    Settings.Control.Enabled = true
    return true
end

local function StopControl()
    Settings.Control.Enabled = false
    Settings.Control.Target = nil
    
    if ControlConnection then
        ControlConnection:Disconnect()
        ControlConnection = nil
    end
    
    -- إرجاع الكاميرا
    local myHumanoid = GetHumanoid()
    if myHumanoid then
        Camera.CameraSubject = myHumanoid
    end
end

-- التجميد
local function FreezePlayer(player)
    if not player or not player.Character then return end
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = true
        Settings.Freeze.FrozenPlayers[player.Name] = true
    end
end

local function UnfreezePlayer(player)
    if not player or not player.Character then return end
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = false
        Settings.Freeze.FrozenPlayers[player.Name] = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 إنشاء الواجهة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Create(parentGui)
    if KlimboUI then KlimboUI:Destroy() end
    
    -- الإطار الرئيسي
    KlimboUI = Instance.new("Frame")
    KlimboUI.Name = "KlimboMenu"
    KlimboUI.Size = UDim2.new(0, 420, 0, 550)
    KlimboUI.Position = UDim2.new(0.5, -210, 0.5, -275)
    KlimboUI.BackgroundColor3 = Colors.BG_Primary
    KlimboUI.BorderSizePixel = 0
    KlimboUI.Visible = false
    KlimboUI.ClipsDescendants = true
    KlimboUI.Parent = parentGui
    AddCorner(KlimboUI, 20)
    
    -- الحدود المتوهجة
    local glowStroke = AddStroke(KlimboUI, Colors.Accent, 2)
    
    -- أنيميشن الحدود
    spawn(function()
        while KlimboUI.Parent do
            CreateTween(glowStroke, {Color = Colors.AccentAlt}, 1.5):Play()
            wait(1.5)
            CreateTween(glowStroke, {Color = Colors.Accent}, 1.5):Play()
            wait(1.5)
        end
    end)
    
    -- التدرج الفضائي
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.BG_Primary),
        ColorSequenceKeypoint.new(0.5, Colors.BG_Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = KlimboUI
    
    -- النجوم
    CreateStars(KlimboUI, 80)
    
    -- ═══ الشريط العلوي ═══
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 60)
    topBar.BackgroundColor3 = Colors.BG_Secondary
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 50
    topBar.Parent = KlimboUI
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 20)
    topCorner.Parent = topBar
    
    -- الشعار
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0.7, 0, 1, 0)
    logo.Position = UDim2.new(0, 20, 0, 0)
    logo.Text = "👑 KLIMBO MENU"
    logo.TextSize = 22
    logo.Font = Enum.Font.GothamBlack
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.BackgroundTransparency = 1
    logo.ZIndex = 51
    logo.Parent = topBar
    
    -- تدرج للنص
    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.AccentGold),
        ColorSequenceKeypoint.new(0.5, Colors.Accent),
        ColorSequenceKeypoint.new(1, Colors.AccentAlt)
    })
    logoGradient.Parent = logo
    
    -- أنيميشن الشعار
    spawn(function()
        while logo.Parent do
            CreateTween(logoGradient, {Rotation = 360}, 3, Enum.EasingStyle.Linear):Play()
            wait(3)
            logoGradient.Rotation = 0
        end
    end)
    
    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.TextPrimary
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Colors.Error
    closeBtn.ZIndex = 51
    closeBtn.Parent = topBar
    AddCorner(closeBtn, 10)
    
    closeBtn.MouseButton1Click:Connect(function()
        KlimboMenu.Toggle()
    end)
    
    -- ═══ شريط التبويبات ═══
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -20, 0, 45)
    tabBar.Position = UDim2.new(0, 10, 0, 65)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 30
    tabBar.Parent = KlimboUI
    
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, 0, 1, 0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
    tabScroll.CanvasSize = UDim2.new(0, 600, 0, 0)
    tabScroll.Parent = tabBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabScroll
    
    -- ═══ منطقة المحتوى ═══
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -130)
    contentArea.Position = UDim2.new(0, 10, 0, 115)
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 4
    contentArea.ScrollBarImageColor3 = Colors.Accent
    contentArea.ZIndex = 20
    contentArea.Parent = KlimboUI
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentArea
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.Parent = contentArea
    
    -- ═══ التبويبات والمحتوى ═══
    local tabs = {
        {name = "⚡ Speed", id = "Speed"},
        {name = "🎯 Combat", id = "Combat"},
        {name = "👁️ ESP", id = "ESP"},
        {name = "✈️ Movement", id = "Movement"},
        {name = "👤 Players", id = "Players"},
        {name = "🎮 Control", id = "Control"},
        {name = "⚙️ Misc", id = "Misc"}
    }
    
    local tabButtons = {}
    local tabContents = {}
    
    -- إنشاء التبويبات
    for _, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.id
        tabBtn.Size = UDim2.new(0, 80, 0, 35)
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = Colors.TextSecondary
        tabBtn.TextSize = 11
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.BackgroundColor3 = Colors.BG_Card
        tabBtn.BorderSizePixel = 0
        tabBtn.Parent = tabScroll
        AddCorner(tabBtn, 8)
        
        tabButtons[tab.id] = tabBtn
        
        -- إنشاء محتوى التبويب
        local content = Instance.new("Frame")
        content.Name = tab.id .. "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.BackgroundTransparency = 1
        content.Visible = tab.id == "Speed"
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = contentArea
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = content
        
        tabContents[tab.id] = content
        
        tabBtn.MouseButton1Click:Connect(function()
            for id, btn in pairs(tabButtons) do
                CreateTween(btn, {BackgroundColor3 = Colors.BG_Card, TextColor3 = Colors.TextSecondary}, 0.2):Play()
            end
            for id, cont in pairs(tabContents) do
                cont.Visible = false
            end
            
            CreateTween(tabBtn, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.TextPrimary}, 0.2):Play()
            tabContents[tab.id].Visible = true
            CurrentTab = tab.id
        end)
    end
    
    -- تحديد أول تبويب
    CreateTween(tabButtons["Speed"], {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.TextPrimary}, 0):Play()
    
    -- ════════════════════════════════════════════════════════════════════════
    -- 📝 ملء المحتوى
    -- ════════════════════════════════════════════════════════════════════════
    
    -- ═══ تبويب السرعة ═══
    local speedContent = tabContents["Speed"]
    
    CreateSection(speedContent, "SPEED SETTINGS")
    
    local speedToggle, getSpeedEnabled, setSpeedEnabled = CreateToggle(speedContent, "Enable Speed", "تفعيل السرعة المخصصة", false, function(enabled)
        SetSpeed(enabled, Settings.Speed.Value)
    end)
    
    local speedSlider, getSpeedValue, setSpeedValue = CreateSlider(speedContent, "Walk Speed", 0, 500, 16, function(value)
        Settings.Speed.Value = value
        if Settings.Speed.Enabled then
            SetSpeed(true, value)
        end
    end)
    
    CreateSection(speedContent, "JUMP SETTINGS")
    
    local jumpToggle, getJumpEnabled, setJumpEnabled = CreateToggle(speedContent, "Enable Jump Power", "تفعيل قوة القفز المخصصة", false, function(enabled)
        SetJump(enabled, Settings.Jump.Value)
    end)
    
    local jumpSlider, getJumpValue, setJumpValue = CreateSlider(speedContent, "Jump Power", 0, 500, 50, function(value)
        Settings.Jump.Value = value
        if Settings.Jump.Enabled then
            SetJump(true, value)
        end
    end)
    
    -- ═══ تبويب القتال ═══
    local combatContent = tabContents["Combat"]
    
    CreateSection(combatContent, "AIMBOT")
    
    local aimbotToggle = CreateToggle(combatContent, "Enable Aimbot", "التصويب التلقائي (زر الماوس الأيمن)", false, function(enabled)
        SetAimbot(enabled)
    end)
    
    local aimbotFOV = CreateSlider(combatContent, "FOV Radius", 50, 500, 200, function(value)
        Settings.Aimbot.FOV = value
    end)
    
    local aimbotSmooth = CreateSlider(combatContent, "Smoothness", 1, 100, 50, function(value)
        Settings.Aimbot.Smoothness = value / 100
    end)
    
    local aimbotPart = CreateDropdown(combatContent, "Aim Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(part)
        Settings.Aimbot.AimPart = part
    end)
    
    local showFOV = CreateToggle(combatContent, "Show FOV Circle", "إظهار دائرة FOV", true, function(enabled)
        Settings.Aimbot.ShowFOV = enabled
        if FOVCircle then
            FOVCircle.Visible = enabled
        end
    end)
    
    -- ═══ تبويب ESP ═══
    local espContent = tabContents["ESP"]
    
    CreateSection(espContent, "ESP SETTINGS")
    
    local espToggle = CreateToggle(espContent, "Enable ESP", "رؤية اللاعبين عبر الجدران", false, function(enabled)
        SetESP(enabled)
    end)
    
    CreateSection(espContent, "DISPLAY OPTIONS")
    
    local showNames = CreateToggle(espContent, "Show Names", "إظهار أسماء اللاعبين", true, function(enabled)
        Settings.ESP.ShowNames = enabled
    end)
    
    local showDistance = CreateToggle(espContent, "Show Distance", "إظهار المسافة", true, function(enabled)
        Settings.ESP.ShowDistance = enabled
    end)
    
    local showHealth = CreateToggle(espContent, "Show Health", "إظهار شريط الصحة", true, function(enabled)
        Settings.ESP.ShowHealth = enabled
    end)
    
    local showBoxes = CreateToggle(espContent, "Show Boxes", "إظهار صناديق حول اللاعبين", true, function(enabled)
        Settings.ESP.ShowBoxes = enabled
    end)
    
    local showTracers = CreateToggle(espContent, "Show Tracers", "إظهار خطوط التتبع", false, function(enabled)
        Settings.ESP.ShowTracers = enabled
    end)
    
    CreateSection(espContent, "COLORS")
    
    local nameColor = CreateColorPicker(espContent, "Name Color", Colors.TextPrimary, function(color)
        Settings.ESP.NameColor = color
    end)
    
    local boxColor = CreateColorPicker(espContent, "Box Color", Color3.fromRGB(0, 255, 0), function(color)
        Settings.ESP.BoxColor = color
    end)
    
    -- ═══ تبويب الحركة ═══
    local movementContent = tabContents["Movement"]
    
    CreateSection(movementContent, "FLIGHT")
    
    local flyToggle = CreateToggle(movementContent, "Enable Fly", "الطيران (WASD + Space/Ctrl)", false, function(enabled)
        SetFly(enabled)
    end)
    
    local flySpeed = CreateSlider(movementContent, "Fly Speed", 10, 200, 50, function(value)
        Settings.Fly.Speed = value
    end)
    
    CreateSection(movementContent, "OTHER")
    
    local infJump = CreateToggle(movementContent, "Infinite Jump", "القفز اللانهائي", false, function(enabled)
        SetInfiniteJump(enabled)
    end)
    
    local noclip = CreateToggle(movementContent, "Noclip", "المرور عبر الجدران", false, function(enabled)
        SetNoclip(enabled)
    end)
    
    -- ═══ تبويب اللاعبين ═══
    local playersContent = tabContents["Players"]
    
    CreateSection(playersContent, "OUTFIT STEALER")
    
    -- قائمة اللاعبين للسرقة
    local playerList = Instance.new("Frame")
    playerList.Size = UDim2.new(1, -20, 0, 200)
    playerList.BackgroundColor3 = Colors.BG_Card
    playerList.BorderSizePixel = 0
    playerList.Parent = playersContent
    AddCorner(playerList, 12)
    
    local playerScroll = Instance.new("ScrollingFrame")
    playerScroll.Size = UDim2.new(1, -10, 1, -10)
    playerScroll.Position = UDim2.new(0, 5, 0, 5)
    playerScroll.BackgroundTransparency = 1
    playerScroll.ScrollBarThickness = 3
    playerScroll.ScrollBarImageColor3 = Colors.Accent
    playerScroll.Parent = playerList
    
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.Padding = UDim.new(0, 5)
    playerLayout.Parent = playerScroll
    
    local function RefreshPlayerList()
        for _, child in ipairs(playerScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerFrame = Instance.new("Frame")
                playerFrame.Size = UDim2.new(1, -10, 0, 40)
                playerFrame.BackgroundColor3 = Colors.BG_Tertiary
                playerFrame.BorderSizePixel = 0
                playerFrame.Parent = playerScroll
                AddCorner(playerFrame, 8)
                
                local playerName = Instance.new("TextLabel")
                playerName.Size = UDim2.new(0.6, 0, 1, 0)
                playerName.Position = UDim2.new(0, 10, 0, 0)
                playerName.Text = "👤 " .. player.Name
                playerName.TextColor3 = Colors.TextPrimary
                playerName.TextSize = 13
                playerName.Font = Enum.Font.GothamBold
                playerName.TextXAlignment = Enum.TextXAlignment.Left
                playerName.BackgroundTransparency = 1
                playerName.Parent = playerFrame
                
                local stealBtn = Instance.new("TextButton")
                stealBtn.Size = UDim2.new(0, 70, 0, 28)
                stealBtn.Position = UDim2.new(1, -80, 0.5, -14)
                stealBtn.Text = "👕 Steal"
                stealBtn.TextColor3 = Colors.TextPrimary
                stealBtn.TextSize = 11
                stealBtn.Font = Enum.Font.GothamBold
                stealBtn.BackgroundColor3 = Colors.Accent
                stealBtn.BorderSizePixel = 0
                stealBtn.Parent = playerFrame
                AddCorner(stealBtn, 6)
                
                stealBtn.MouseButton1Click:Connect(function()
                    if StealOutfit(player) then
                        stealBtn.Text = "✓ Done!"
                        stealBtn.BackgroundColor3 = Colors.Success
                        wait(1)
                        stealBtn.Text = "👕 Steal"
                        stealBtn.BackgroundColor3 = Colors.Accent
                    else
                        stealBtn.Text = "✕ Failed"
                        stealBtn.BackgroundColor3 = Colors.Error
                        wait(1)
                        stealBtn.Text = "👕 Steal"
                        stealBtn.BackgroundColor3 = Colors.Accent
                    end
                end)
            end
        end
        
        playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y + 10)
    end
    
    RefreshPlayerList()
    
    local refreshBtn = CreateButton(playersContent, "🔄 Refresh List", "تحديث قائمة اللاعبين", RefreshPlayerList)
    
    CreateSection(playersContent, "FREEZE PLAYERS")
    
    -- قائمة التجميد
    local freezeList = Instance.new("Frame")
    freezeList.Size = UDim2.new(1, -20, 0, 150)
    freezeList.BackgroundColor3 = Colors.BG_Card
    freezeList.BorderSizePixel = 0
    freezeList.Parent = playersContent
    AddCorner(freezeList, 12)
    
    local freezeScroll = Instance.new("ScrollingFrame")
    freezeScroll.Size = UDim2.new(1, -10, 1, -10)
    freezeScroll.Position = UDim2.new(0, 5, 0, 5)
    freezeScroll.BackgroundTransparency = 1
    freezeScroll.ScrollBarThickness = 3
    freezeScroll.Parent = freezeList
    
    local freezeLayout = Instance.new("UIListLayout")
    freezeLayout.Padding = UDim.new(0, 5)
    freezeLayout.Parent = freezeScroll
    
    local function RefreshFreezeList()
        for _, child in ipairs(freezeScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerFrame = Instance.new("Frame")
                playerFrame.Size = UDim2.new(1, -10, 0, 35)
                playerFrame.BackgroundColor3 = Colors.BG_Tertiary
                playerFrame.BorderSizePixel = 0
                playerFrame.Parent = freezeScroll
                AddCorner(playerFrame, 8)
                
                local playerName = Instance.new("TextLabel")
                playerName.Size = UDim2.new(0.6, 0, 1, 0)
                playerName.Position = UDim2.new(0, 10, 0, 0)
                playerName.Text = player.Name
                playerName.TextColor3 = Colors.TextPrimary
                playerName.TextSize = 12
                playerName.Font = Enum.Font.Gotham
                playerName.TextXAlignment = Enum.TextXAlignment.Left
                playerName.BackgroundTransparency = 1
                playerName.Parent = playerFrame
                
                local frozen = Settings.Freeze.FrozenPlayers[player.Name]
                
                local freezeBtn = Instance.new("TextButton")
                freezeBtn.Size = UDim2.new(0, 60, 0, 25)
                freezeBtn.Position = UDim2.new(1, -70, 0.5, -12)
                freezeBtn.Text = frozen and "🔓" or "🧊"
                freezeBtn.TextSize = 14
                freezeBtn.BackgroundColor3 = frozen and Colors.Success or Colors.AccentAlt
                freezeBtn.TextColor3 = Colors.TextPrimary
                freezeBtn.Font = Enum.Font.GothamBold
                freezeBtn.BorderSizePixel = 0
                freezeBtn.Parent = playerFrame
                AddCorner(freezeBtn, 6)
                
                freezeBtn.MouseButton1Click:Connect(function()
                    if Settings.Freeze.FrozenPlayers[player.Name] then
                        UnfreezePlayer(player)
                        freezeBtn.Text = "🧊"
                        freezeBtn.BackgroundColor3 = Colors.AccentAlt
                    else
                        FreezePlayer(player)
                        freezeBtn.Text = "🔓"
                        freezeBtn.BackgroundColor3 = Colors.Success
                    end
                end)
            end
        end
        
        freezeScroll.CanvasSize = UDim2.new(0, 0, 0, freezeLayout.AbsoluteContentSize.Y + 10)
    end
    
    RefreshFreezeList()
    
    -- ═══ تبويب التحكم ═══
    local controlContent = tabContents["Control"]
    
    CreateSection(controlContent, "PLAYER/NPC CONTROL")
    
    local controlInfo = Instance.new("TextLabel")
    controlInfo.Size = UDim2.new(1, -20, 0, 50)
    controlInfo.Text = "🎮 اختر لاعب أو NPC للتحكم به\nستتحكم بالكاميرا والحركة"
    controlInfo.TextColor3 = Colors.TextSecondary
    controlInfo.TextSize = 12
    controlInfo.Font = Enum.Font.Gotham
    controlInfo.TextWrapped = true
    controlInfo.BackgroundColor3 = Colors.BG_Card
    controlInfo.BorderSizePixel = 0
    controlInfo.Parent = controlContent
    AddCorner(controlInfo, 10)
    
    -- قائمة التحكم
    local controlList = Instance.new("Frame")
    controlList.Size = UDim2.new(1, -20, 0, 250)
    controlList.BackgroundColor3 = Colors.BG_Card
    controlList.BorderSizePixel = 0
    controlList.Parent = controlContent
    AddCorner(controlList, 12)
    
    local controlScroll = Instance.new("ScrollingFrame")
    controlScroll.Size = UDim2.new(1, -10, 1, -10)
    controlScroll.Position = UDim2.new(0, 5, 0, 5)
    controlScroll.BackgroundTransparency = 1
    controlScroll.ScrollBarThickness = 3
    controlScroll.Parent = controlList
    
    local controlLayout = Instance.new("UIListLayout")
    controlLayout.Padding = UDim.new(0, 5)
    controlLayout.Parent = controlScroll
    
    local function RefreshControlList()
        for _, child in ipairs(controlScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        -- اللاعبين
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -10, 0, 40)
                frame.BackgroundColor3 = Colors.BG_Tertiary
                frame.BorderSizePixel = 0
                frame.Parent = controlScroll
                AddCorner(frame, 8)
                
                local name = Instance.new("TextLabel")
                name.Size = UDim2.new(0.6, 0, 1, 0)
                name.Position = UDim2.new(0, 10, 0, 0)
                name.Text = "👤 " .. player.Name
                name.TextColor3 = Colors.TextPrimary
                name.TextSize = 12
                name.Font = Enum.Font.GothamBold
                name.TextXAlignment = Enum.TextXAlignment.Left
                name.BackgroundTransparency = 1
                name.Parent = frame
                
                local controlBtn = Instance.new("TextButton")
                controlBtn.Size = UDim2.new(0, 70, 0, 28)
                controlBtn.Position = UDim2.new(1, -80, 0.5, -14)
                controlBtn.Text = "🎮 Control"
                controlBtn.TextColor3 = Colors.TextPrimary
                controlBtn.TextSize = 10
                controlBtn.Font = Enum.Font.GothamBold
                controlBtn.BackgroundColor3 = Colors.Accent
                controlBtn.BorderSizePixel = 0
                controlBtn.Parent = frame
                AddCorner(controlBtn, 6)
                
                controlBtn.MouseButton1Click:Connect(function()
                    if SetControl(player) then
                        controlBtn.Text = "✓ Active"
                        controlBtn.BackgroundColor3 = Colors.Success
                    end
                end)
            end
        end
        
        -- NPCs
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, -10, 0, 40)
                    frame.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
                    frame.BorderSizePixel = 0
                    frame.Parent = controlScroll
                    AddCorner(frame, 8)
                    
                    local name = Instance.new("TextLabel")
                    name.Size = UDim2.new(0.6, 0, 1, 0)
                    name.Position = UDim2.new(0, 10, 0, 0)
                    name.Text = "🤖 " .. model.Name
                    name.TextColor3 = Colors.AccentAlt
                    name.TextSize = 12
                    name.Font = Enum.Font.GothamBold
                    name.TextXAlignment = Enum.TextXAlignment.Left
                    name.BackgroundTransparency = 1
                    name.Parent = frame
                    
                    local controlBtn = Instance.new("TextButton")
                    controlBtn.Size = UDim2.new(0, 70, 0, 28)
                    controlBtn.Position = UDim2.new(1, -80, 0.5, -14)
                    controlBtn.Text = "🎮 Control"
                    controlBtn.TextColor3 = Colors.TextPrimary
                    controlBtn.TextSize = 10
                    controlBtn.Font = Enum.Font.GothamBold
                    controlBtn.BackgroundColor3 = Colors.AccentAlt
                    controlBtn.BorderSizePixel = 0
                    controlBtn.Parent = frame
                    AddCorner(controlBtn, 6)
                    
                    controlBtn.MouseButton1Click:Connect(function()
                        -- التحكم بالـ NPC
                        local fakePlayer = {
                            Character = model,
                            Name = model.Name
                        }
                        if SetControl(fakePlayer) then
                            controlBtn.Text = "✓ Active"
                            controlBtn.BackgroundColor3 = Colors.Success
                        end
                    end)
                end
            end
        end
        
        controlScroll.CanvasSize = UDim2.new(0, 0, 0, controlLayout.AbsoluteContentSize.Y + 10)
    end
    
    RefreshControlList()
    
    local stopControlBtn = CreateButton(controlContent, "🛑 Stop Control", "إيقاف التحكم والعودة لشخصيتك", function()
        StopControl()
    end)
    
    local refreshControl = CreateButton(controlContent, "🔄 Refresh", "تحديث القائمة", RefreshControlList)
    
    -- ═══ تبويب متفرقات ═══
    local miscContent = tabContents["Misc"]
    
    CreateSection(miscContent, "CHARACTER")
    
    local resetBtn = CreateButton(miscContent, "💀 Reset Character", "إعادة تعيين الشخصية", function()
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.Health = 0
        end
    end)
    
    local godMode = CreateToggle(miscContent, "God Mode (Client)", "الخلود (جانب العميل فقط)", false, function(enabled)
        local humanoid = GetHumanoid()
        if humanoid then
            if enabled then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end)
    
    CreateSection(miscContent, "TELEPORT")
    
    local tpToPlayer = CreateDropdown(miscContent, "Teleport to Player", {}, "Select...", function(playerName)
        local player = Players:FindFirstChild(playerName)
        if player and player.Character then
            local root = GetRootPart()
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
    
    CreateSection(miscContent, "TOOLS")
    
    local btools = CreateButton(miscContent, "🔨 Give BTools", "أدوات البناء", function()
        pcall(function()
            local tool1 = Instance.new("HopperBin", LocalPlayer.Backpack)
            tool1.BinType = Enum.BinType.Hammer
            local tool2 = Instance.new("HopperBin", LocalPlayer.Backpack)
            tool2.BinType = Enum.BinType.Clone
            local tool3 = Instance.new("HopperBin", LocalPlayer.Backpack)
            tool3.BinType = Enum.BinType.Grab
        end)
    end)
    
    -- تحديث قائمة اللاعبين للتلبورت
    spawn(function()
        while KlimboUI.Parent do
            wait(3)
            -- يمكن إضافة تحديث تلقائي هنا
        end
    end)
    
    -- تحديث حجم المحتوى
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- السحب
    local dragging = false
    local dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = KlimboUI.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            KlimboUI.Position = UDim2.new(
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
    
    return KlimboUI
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎛️ التبديل والتحكم
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Toggle()
    if not KlimboUI then return end
    
    IsOpen = not IsOpen
    
    if IsOpen then
        KlimboUI.Visible = true
        KlimboUI.Size = UDim2.new(0, 0, 0, 0)
        KlimboUI.Position = UDim2.new(0.5, 0, 0.5, 0)
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 420, 0, 550),
            Position = UDim2.new(0.5, -210, 0.5, -275)
        }, 0.4, Enum.EasingStyle.Back):Play()
    else
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Quart):Play()
        wait(0.3)
        KlimboUI.Visible = false
    end
end

function KlimboMenu.Show()
    if KlimboUI then
        IsOpen = true
        KlimboUI.Visible = true
        KlimboUI.Size = UDim2.new(0, 0, 0, 0)
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 420, 0, 550),
            Position = UDim2.new(0.5, -210, 0.5, -275)
        }, 0.4, Enum.EasingStyle.Back):Play()
    end
end

function KlimboMenu.Hide()
    if KlimboUI then
        IsOpen = false
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3):Play()
        wait(0.3)
        KlimboUI.Visible = false
    end
end

function KlimboMenu.IsVisible()
    return IsOpen
end

function KlimboMenu.Destroy()
    -- تنظيف كل الـ connections
    for name, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    Connections = {}
    
    -- تنظيف ESP
    if ESPFolder then ESPFolder:Destroy() end
    
    -- تنظيف Aimbot
    if FOVCircle then FOVCircle:Remove() end
    
    -- تنظيف الطيران
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    
    -- حذف UI
    if KlimboUI then KlimboUI:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 إنشاء زر KLIMBO الجميل
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.CreateButton(parent)
    local btn = Instance.new("TextButton")
    btn.Name = "KlimboButton"
    btn.Size = UDim2.new(0, 100, 0, 36)
    btn.Position = UDim2.new(1, -290, 0.5, -18)
    btn.Text = "👑 KLIMBO"
    btn.TextColor3 = Colors.AccentGold
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBlack
    btn.BackgroundColor3 = Colors.BG_Secondary
    btn.BorderSizePixel = 0
    btn.ZIndex = 100
    btn.Parent = parent
    AddCorner(btn, 10)
    
    -- تأثير متوهج
    local glow = AddStroke(btn, Colors.AccentGold, 2, 0.3)
    
    -- تدرج للزر
    local btnGradient = Instance.new("UIGradient")
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(0.5, Colors.BG_Secondary),
        ColorSequenceKeypoint.new(1, Colors.AccentAlt)
    })
    btnGradient.Rotation = 45
    btnGradient.Parent = btn
    
    -- أنيميشن
    spawn(function()
        while btn.Parent do
            CreateTween(glow, {Color = Colors.Accent, Transparency = 0}, 1):Play()
            wait(1)
            CreateTween(glow, {Color = Colors.AccentAlt, Transparency = 0.3}, 1):Play()
            wait(1)
            CreateTween(glow, {Color = Colors.AccentGold, Transparency = 0}, 1):Play()
            wait(1)
        end
    end)
    
    -- تأثير الـ hover
    btn.MouseEnter:Connect(function()
        CreateTween(btn, {Size = UDim2.new(0, 110, 0, 40)}, 0.2):Play()
        CreateTween(glow, {Thickness = 3, Transparency = 0}, 0.2):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        CreateTween(btn, {Size = UDim2.new(0, 100, 0, 36)}, 0.2):Play()
        CreateTween(glow, {Thickness = 2, Transparency = 0.3}, 0.2):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        CreateTween(btn, {Size = UDim2.new(0, 95, 0, 34)}, 0.1):Play()
        wait(0.1)
        CreateTween(btn, {Size = UDim2.new(0, 100, 0, 36)}, 0.1):Play()
        KlimboMenu.Toggle()
    end)
    
    return btn
end

-- ═══════════════════════════════════════════════════════════════════════════

print("👑 KlimboMenu v4.0 Loaded!")

return KlimboMenu
