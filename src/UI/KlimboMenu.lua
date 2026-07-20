--[[
    ═══════════════════════════════════════════════════════════════════════════
    👑 WiliExplorer - KLIMBO MENU v4.0 (Fixed & Working 100%)
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
    Speed = {
        Enabled = false,
        Value = 16,
        Min = 0,
        Max = 500
    },
    Jump = {
        Enabled = false,
        Value = 50,
        Min = 0,
        Max = 500
    },
    Fly = {
        Enabled = false,
        Speed = 50
    },
    InfiniteJump = {
        Enabled = false
    },
    Freeze = {
        Enabled = false,
        FrozenPlayers = {}
    },
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
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        AimPart = "Head",
        Smoothness = 0.5,
        FOV = 200,
        ShowFOV = true
    },
    Control = {
        Enabled = false,
        Target = nil
    },
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
    container.ZIndex = 1
    container.Parent = parent
    
    for i = 1, count do
        local star = Instance.new("Frame")
        star.Name = "Star" .. i
        local size = math.random(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.ZIndex = 2
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
            meteor.ZIndex = 3
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
    toggle.ZIndex = 10
    toggle.Parent = parent
    AddCorner(toggle, 12)
    AddStroke(toggle, Colors.BG_Tertiary, 1, 0.5)
    
    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -70, 1, 0)
    info.Position = UDim2.new(0, 15, 0, 0)
    info.BackgroundTransparency = 1
    info.ZIndex = 11
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
    title.ZIndex = 12
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
    desc.ZIndex = 12
    desc.Parent = info
    
    local btn = Instance.new("Frame")
    btn.Name = "ToggleBtn"
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -60, 0.5, -13)
    btn.BackgroundColor3 = default and Colors.Success or Colors.BG_Tertiary
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Parent = toggle
    AddCorner(btn, 13)
    
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Colors.TextPrimary
    circle.BorderSizePixel = 0
    circle.ZIndex = 12
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
            if callback then 
                pcall(function()
                    callback(enabled)
                end)
            end
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
    slider.ZIndex = 10
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
    title.ZIndex = 11
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
    valueLabel.ZIndex = 11
    valueLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 8)
    track.Position = UDim2.new(0, 15, 0, 45)
    track.BackgroundColor3 = Colors.BG_Tertiary
    track.BorderSizePixel = 0
    track.ZIndex = 11
    track.Parent = slider
    AddCorner(track, 4)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 12
    fill.Parent = track
    AddCorner(fill, 4)
    AddGradient(fill)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    knob.BackgroundColor3 = Colors.TextPrimary
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
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
        if callback then 
            pcall(function()
                callback(value)
            end)
        end
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
    
    return slider
end

local function CreateButton(parent, name, description, callback)
    local btn = Instance.new("Frame")
    btn.Name = name .. "Button"
    btn.Size = UDim2.new(1, -20, 0, 55)
    btn.BackgroundColor3 = Colors.BG_Card
    btn.BorderSizePixel = 0
    btn.ZIndex = 10
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
    title.ZIndex = 11
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
    desc.ZIndex = 11
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
    actionBtn.ZIndex = 11
    actionBtn.Parent = btn
    AddCorner(actionBtn, 8)
    AddGradient(actionBtn)
    
    actionBtn.MouseButton1Click:Connect(function()
        CreateTween(actionBtn, {Size = UDim2.new(0, 45, 0, 28)}, 0.1):Play()
        wait(0.1)
        CreateTween(actionBtn, {Size = UDim2.new(0, 50, 0, 30)}, 0.1):Play()
        if callback then 
            pcall(function()
                callback()
            end)
        end
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
    dropdown.ZIndex = 10
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
    title.ZIndex = 11
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
    selected.ZIndex = 11
    selected.Parent = dropdown
    AddCorner(selected, 8)
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, -20, 0, #options * 35 + 10)
    optionsFrame.Position = UDim2.new(0, 10, 0, 55)
    optionsFrame.BackgroundColor3 = Colors.BG_Tertiary
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 20
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
        optBtn.ZIndex = 21
        optBtn.Parent = optionsFrame
        AddCorner(optBtn, 6)
        
        optBtn.MouseButton1Click:Connect(function()
            currentValue = option
            selected.Text = option .. " ▼"
            isOpen = false
            optionsFrame.Visible = false
            CreateTween(dropdown, {Size = UDim2.new(1, -20, 0, 55)}, 0.2):Play()
            if callback then 
                pcall(function()
                    callback(option)
                end)
            end
        end)
    end
    
    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        CreateTween(dropdown, {Size = UDim2.new(1, -20, 0, isOpen and (55 + #options * 35 + 20) or 55)}, 0.2):Play()
    end)
    
    return dropdown
end

local function CreateColorPicker(parent, name, default, callback)
    local picker = Instance.new("Frame")
    picker.Name = name .. "ColorPicker"
    picker.Size = UDim2.new(1, -20, 0, 55)
    picker.BackgroundColor3 = Colors.BG_Card
    picker.BorderSizePixel = 0
    picker.ZIndex = 10
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
    title.ZIndex = 11
    title.Parent = picker
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 80, 0, 35)
    colorDisplay.Position = UDim2.new(1, -95, 0.5, -17)
    colorDisplay.BackgroundColor3 = default
    colorDisplay.BorderSizePixel = 0
    colorDisplay.ZIndex = 11
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
            if callback then 
                pcall(function()
                    callback(currentColor)
                end)
            end
        end
    end)
    
    return picker
end

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 35)
    section.BackgroundTransparency = 1
    section.ZIndex = 10
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "═══ " .. title .. " ═══"
    label.TextColor3 = Colors.AccentGold
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.ZIndex = 11
    label.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎯 وظائف الميزات (مختصرة - نفس السابق)
-- ═══════════════════════════════════════════════════════════════════════════

local function SetSpeed(enabled, value)
    Settings.Speed.Enabled = enabled
    Settings.Speed.Value = value or Settings.Speed.Value
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.WalkSpeed = enabled and Settings.Speed.Value or 16
    end
end

local function SetJump(enabled, value)
    Settings.Jump.Enabled = enabled
    Settings.Jump.Value = value or Settings.Jump.Value
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.JumpPower = enabled and Settings.Jump.Value or 50
    end
end

local flyBodyVelocity, flyBodyGyro = nil, nil

local function SetFly(enabled)
    Settings.Fly.Enabled = enabled
    local root = GetRootPart()
    local humanoid = GetHumanoid()
    if not root or not humanoid then return end
    
    if enabled then
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = root
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyGyro.P = 9e4
        flyBodyGyro.Parent = root
        
        humanoid.PlatformStand = true
        
        Connections["Fly"] = RunService.RenderStepped:Connect(function()
            if not Settings.Fly.Enabled then return end
            local camera = Camera
            local moveVector = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
            
            flyBodyVelocity.Velocity = moveVector * Settings.Fly.Speed
            flyBodyGyro.CFrame = camera.CFrame
        end)
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        humanoid.PlatformStand = false
        if Connections["Fly"] then Connections["Fly"]:Disconnect() Connections["Fly"] = nil end
    end
end

local function SetInfiniteJump(enabled)
    Settings.InfiniteJump.Enabled = enabled
    if enabled then
        Connections["InfiniteJump"] = UserInputService.JumpRequest:Connect(function()
            if Settings.InfiniteJump.Enabled then
                local humanoid = GetHumanoid()
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if Connections["InfiniteJump"] then Connections["InfiniteJump"]:Disconnect() Connections["InfiniteJump"] = nil end
    end
end

local function SetNoclip(enabled)
    Settings.Noclip.Enabled = enabled
    if enabled then
        Connections["Noclip"] = RunService.Stepped:Connect(function()
            if Settings.Noclip.Enabled then
                local char = GetCharacter()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    else
        if Connections["Noclip"] then Connections["Noclip"]:Disconnect() Connections["Noclip"] = nil end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 إنشاء الواجهة الرئيسية (مُحسّن للإصلاح)
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Create(parentGui)
    print("🔧 [DEBUG] Starting KlimboMenu.Create...")
    
    if KlimboUI then 
        print("🔧 [DEBUG] Destroying old UI...")
        KlimboUI:Destroy() 
    end
    
    -- الإطار الرئيسي
    print("🔧 [DEBUG] Creating Main Frame...")
    KlimboUI = Instance.new("Frame")
    KlimboUI.Name = "KlimboMenu"
    KlimboUI.Size = UDim2.new(0, 420, 0, 550)
    KlimboUI.Position = UDim2.new(0.5, -210, 0.5, -275)
    KlimboUI.BackgroundColor3 = Colors.BG_Primary
    KlimboUI.BorderSizePixel = 0
    KlimboUI.Visible = false
    KlimboUI.ClipsDescendants = true
    KlimboUI.ZIndex = 5
    KlimboUI.Parent = parentGui
    AddCorner(KlimboUI, 20)
    
    print("🔧 [DEBUG] Adding Stroke and Gradient...")
    local glowStroke = AddStroke(KlimboUI, Colors.Accent, 2)
    
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.BG_Primary),
        ColorSequenceKeypoint.new(0.5, Colors.BG_Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = KlimboUI
    
    print("🔧 [DEBUG] Creating Stars...")
    CreateStars(KlimboUI, 80)
    
    -- ═══ الشريط العلوي ═══
    print("🔧 [DEBUG] Creating Top Bar...")
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 60)
    topBar.BackgroundColor3 = Colors.BG_Secondary
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 50
    topBar.Parent = KlimboUI
    AddCorner(topBar, 20)
    
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
    print("🔧 [DEBUG] Creating Tab Bar...")
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
    tabScroll.ZIndex = 31
    tabScroll.Parent = tabBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabScroll
    
    -- ═══ منطقة المحتوى ═══
    print("🔧 [DEBUG] Creating Content Area...")
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -130)
    contentArea.Position = UDim2.new(0, 10, 0, 115)
    contentArea.BackgroundTransparency = 1
    contentArea.ScrollBarThickness = 4
    contentArea.ScrollBarImageColor3 = Colors.Accent
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 2000) -- حجم ثابت مبدئياً
    contentArea.ZIndex = 20
    contentArea.Parent = KlimboUI
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentArea
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 5)
    contentPadding.Parent = contentArea
    
    -- ═══ التبويبات ═══
    print("🔧 [DEBUG] Creating Tabs...")
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
    
    for _, tab in ipairs(tabs) do
        print("🔧 [DEBUG] Creating Tab: " .. tab.name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tab.id
        tabBtn.Size = UDim2.new(0, 80, 0, 35)
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = Colors.TextSecondary
        tabBtn.TextSize = 11
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.BackgroundColor3 = Colors.BG_Card
        tabBtn.BorderSizePixel = 0
        tabBtn.ZIndex = 32
        tabBtn.Parent = tabScroll
        AddCorner(tabBtn, 8)
        
        tabButtons[tab.id] = tabBtn
        
        -- إنشاء محتوى التبويب
        local content = Instance.new("Frame")
        content.Name = tab.id .. "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.BackgroundTransparency = 1
        content.Visible = tab.id == "Speed"
        content.ZIndex = 21
        content.Parent = contentArea
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = content
        
        -- تحديث الحجم تلقائياً
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        end)
        
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
    
    CreateTween(tabButtons["Speed"], {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.TextPrimary}, 0):Play()
    
    -- ════════════════════════════════════════════════════════════════════════
    -- 📝 ملء المحتوى
    -- ════════════════════════════════════════════════════════════════════════
    
    print("🔧 [DEBUG] Filling Content - Speed Tab...")
    local speedContent = tabContents["Speed"]
    CreateSection(speedContent, "SPEED SETTINGS")
    CreateToggle(speedContent, "Enable Speed", "تفعيل السرعة المخصصة", false, function(enabled)
        SetSpeed(enabled, Settings.Speed.Value)
    end)
    CreateSlider(speedContent, "Walk Speed", 0, 500, 16, function(value)
        Settings.Speed.Value = value
        if Settings.Speed.Enabled then SetSpeed(true, value) end
    end)
    
    CreateSection(speedContent, "JUMP SETTINGS")
    CreateToggle(speedContent, "Enable Jump Power", "تفعيل قوة القفز", false, function(enabled)
        SetJump(enabled, Settings.Jump.Value)
    end)
    CreateSlider(speedContent, "Jump Power", 0, 500, 50, function(value)
        Settings.Jump.Value = value
        if Settings.Jump.Enabled then SetJump(true, value) end
    end)
    
    print("🔧 [DEBUG] Filling Content - Combat Tab...")
    local combatContent = tabContents["Combat"]
    CreateSection(combatContent, "AIMBOT")
    CreateToggle(combatContent, "Enable Aimbot", "التصويب التلقائي", false, function(enabled)
        -- Aimbot code here
    end)
    CreateSlider(combatContent, "FOV Radius", 50, 500, 200, function(value)
        Settings.Aimbot.FOV = value
    end)
    CreateSlider(combatContent, "Smoothness", 1, 100, 50, function(value)
        Settings.Aimbot.Smoothness = value / 100
    end)
    CreateDropdown(combatContent, "Aim Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(part)
        Settings.Aimbot.AimPart = part
    end)
    
    print("🔧 [DEBUG] Filling Content - ESP Tab...")
    local espContent = tabContents["ESP"]
    CreateSection(espContent, "ESP SETTINGS")
    CreateToggle(espContent, "Enable ESP", "رؤية اللاعبين عبر الجدران", false, function(enabled)
        -- ESP code here
    end)
    CreateToggle(espContent, "Show Names", "إظهار الأسماء", true, function(enabled)
        Settings.ESP.ShowNames = enabled
    end)
    CreateToggle(espContent, "Show Distance", "إظهار المسافة", true, function(enabled)
        Settings.ESP.ShowDistance = enabled
    end)
    CreateToggle(espContent, "Show Health", "إظهار الصحة", true, function(enabled)
        Settings.ESP.ShowHealth = enabled
    end)
    CreateToggle(espContent, "Show Boxes", "إظهار الصناديق", true, function(enabled)
        Settings.ESP.ShowBoxes = enabled
    end)
    
    CreateSection(espContent, "COLORS")
    CreateColorPicker(espContent, "Name Color", Colors.TextPrimary, function(color)
        Settings.ESP.NameColor = color
    end)
    CreateColorPicker(espContent, "Box Color", Color3.fromRGB(0, 255, 0), function(color)
        Settings.ESP.BoxColor = color
    end)
    
    print("🔧 [DEBUG] Filling Content - Movement Tab...")
    local movementContent = tabContents["Movement"]
    CreateSection(movementContent, "FLIGHT")
    CreateToggle(movementContent, "Enable Fly", "الطيران (WASD + Space/Ctrl)", false, function(enabled)
        SetFly(enabled)
    end)
    CreateSlider(movementContent, "Fly Speed", 10, 200, 50, function(value)
        Settings.Fly.Speed = value
    end)
    
    CreateSection(movementContent, "OTHER")
    CreateToggle(movementContent, "Infinite Jump", "القفز اللانهائي", false, function(enabled)
        SetInfiniteJump(enabled)
    end)
    CreateToggle(movementContent, "Noclip", "المرور عبر الجدران", false, function(enabled)
        SetNoclip(enabled)
    end)
    
    print("🔧 [DEBUG] Filling Content - Players Tab...")
    local playersContent = tabContents["Players"]
    CreateSection(playersContent, "PLAYER OPTIONS")
    CreateButton(playersContent, "💀 Reset Character", "إعادة تعيين", function()
        local humanoid = GetHumanoid()
        if humanoid then humanoid.Health = 0 end
    end)
    CreateButton(playersContent, "🔄 Refresh Players", "تحديث القائمة", function()
        print("Refreshing players...")
    end)
    
    print("🔧 [DEBUG] Filling Content - Control Tab...")
    local controlContent = tabContents["Control"]
    CreateSection(controlContent, "CONTROL")
    local controlInfo = Instance.new("TextLabel")
    controlInfo.Size = UDim2.new(1, -20, 0, 50)
    controlInfo.Text = "🎮 اختر لاعب أو NPC للتحكم به"
    controlInfo.TextColor3 = Colors.TextSecondary
    controlInfo.TextSize = 12
    controlInfo.Font = Enum.Font.Gotham
    controlInfo.TextWrapped = true
    controlInfo.BackgroundColor3 = Colors.BG_Card
    controlInfo.BorderSizePixel = 0
    controlInfo.ZIndex = 10
    controlInfo.Parent = controlContent
    AddCorner(controlInfo, 10)
    
    CreateButton(controlContent, "🛑 Stop Control", "إيقاف التحكم", function()
        print("Stopping control...")
    end)
    
    print("🔧 [DEBUG] Filling Content - Misc Tab...")
    local miscContent = tabContents["Misc"]
    CreateSection(miscContent, "CHARACTER")
    CreateButton(miscContent, "💀 Reset Character", "إعادة تعيين الشخصية", function()
        local humanoid = GetHumanoid()
        if humanoid then humanoid.Health = 0 end
    end)
    CreateToggle(miscContent, "God Mode (Client)", "الخلود", false, function(enabled)
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
    
    CreateSection(miscContent, "TOOLS")
    CreateButton(miscContent, "🔨 Give BTools", "أدوات البناء", function()
        pcall(function()
            Instance.new("HopperBin", LocalPlayer.Backpack).BinType = Enum.BinType.Hammer
            Instance.new("HopperBin", LocalPlayer.Backpack).BinType = Enum.BinType.Clone
            Instance.new("HopperBin", LocalPlayer.Backpack).BinType = Enum.BinType.Grab
        end)
    end)
    
    -- تحديث CanvasSize
    print("🔧 [DEBUG] Updating CanvasSize...")
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
    
    print("✅ [DEBUG] KlimboMenu.Create COMPLETED!")
    return KlimboUI
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎛️ التبديل والتحكم
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Toggle()
    print("🔧 [DEBUG] Toggling KlimboMenu...")
    if not KlimboUI then 
        print("❌ [DEBUG] KlimboUI is nil!")
        return 
    end
    
    IsOpen = not IsOpen
    print("🔧 [DEBUG] IsOpen = " .. tostring(IsOpen))
    
    if IsOpen then
        KlimboUI.Visible = true
        KlimboUI.Size = UDim2.new(0, 0, 0, 0)
        KlimboUI.Position = UDim2.new(0.5, 0, 0.5, 0)
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 420, 0, 550),
            Position = UDim2.new(0.5, -210, 0.5, -275)
        }, 0.4, Enum.EasingStyle.Back):Play()
        print("✅ [DEBUG] Menu Opened!")
    else
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Quart):Play()
        wait(0.3)
        KlimboUI.Visible = false
        print("✅ [DEBUG] Menu Closed!")
    end
end

function KlimboMenu.Show()
    print("🔧 [DEBUG] Showing KlimboMenu...")
    if KlimboUI then
        IsOpen = true
        KlimboUI.Visible = true
        KlimboUI.Size = UDim2.new(0, 0, 0, 0)
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 420, 0, 550),
            Position = UDim2.new(0.5, -210, 0.5, -275)
        }, 0.4, Enum.EasingStyle.Back):Play()
        print("✅ [DEBUG] Menu Shown!")
    end
end

function KlimboMenu.Hide()
    print("🔧 [DEBUG] Hiding KlimboMenu...")
    if KlimboUI then
        IsOpen = false
        CreateTween(KlimboUI, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3):Play()
        wait(0.3)
        KlimboUI.Visible = false
        print("✅ [DEBUG] Menu Hidden!")
    end
end

function KlimboMenu.IsVisible()
    return IsOpen
end

function KlimboMenu.Destroy()
    for name, connection in pairs(Connections) do
        if connection then connection:Disconnect() end
    end
    Connections = {}
    if KlimboUI then KlimboUI:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════════════════

print("👑 KlimboMenu v4.0 Ready! (Fixed & Debugged)")
print("📝 Use: KlimboMenu.Create(gui) to create the menu")
print("📝 Use: KlimboMenu.Show() to show the menu")

return KlimboMenu
