--[[
    ═══════════════════════════════════════════════════════════════════════════
    👑 KLIMBO MENU v4.0 - STANDALONE (100% Working)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ التحديث الجديد:
    • عند فتح KLIMBO، يختفي كل شيء آخر
    • القائمة تظهر لوحدها فقط
    • زر Back للعودة للقائمة الرئيسية
    • تصميم فضائي مع أنيميشن متقدم
    
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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════════
-- 📊 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════════

local KlimboUI = nil
local MainFrameRef = nil -- مرجع للقائمة الرئيسية
local IsOpen = false

local Settings = {
    Speed = { Enabled = false, Value = 16, Min = 0, Max = 500 },
    Jump = { Enabled = false, Value = 50, Min = 0, Max = 500 },
    Fly = { Enabled = false, Speed = 50 },
    InfiniteJump = { Enabled = false },
    Noclip = { Enabled = false }
}

local Connections = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════════

local Colors = {
    BG_Primary = Color3.fromRGB(8, 10, 25),
    BG_Secondary = Color3.fromRGB(15, 18, 45),
    BG_Card = Color3.fromRGB(20, 25, 55),
    Accent = Color3.fromRGB(255, 0, 128),
    AccentAlt = Color3.fromRGB(0, 255, 255),
    AccentGold = Color3.fromRGB(255, 215, 0),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 160, 200),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 71, 87)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateTween(object, props, duration)
    return TweenService:Create(object, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart), props)
end

local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Accent
    stroke.Thickness = thickness or 2
    stroke.Parent = parent
    return stroke
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ⭐ النجوم المتحركة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateStars(parent)
    local container = Instance.new("Frame")
    container.Name = "Stars"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ZIndex = 1
    container.Parent = parent
    
    for i = 1, 100 do
        local star = Instance.new("Frame")
        local size = math.random(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.ZIndex = 2
        star.Parent = container
        AddCorner(star, size)
        
        spawn(function()
            while star.Parent do
                local duration = math.random(10, 30) / 10
                CreateTween(star, {BackgroundTransparency = math.random(40, 90) / 100}, duration):Play()
                wait(duration)
                CreateTween(star, {BackgroundTransparency = 0}, duration):Play()
                wait(duration)
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎛️ عناصر الواجهة
-- ═══════════════════════════════════════════════════════════════════════════

local function CreateToggle(parent, name, description, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -30, 0, 65)
    toggle.BackgroundColor3 = Colors.BG_Card
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    AddCorner(toggle, 12)
    AddStroke(toggle, Colors.BG_Secondary, 1)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = toggle
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -80, 0, 20)
    desc.Position = UDim2.new(0, 15, 0, 35)
    desc.Text = description
    desc.TextColor3 = Colors.TextSecondary
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.BackgroundTransparency = 1
    desc.Parent = toggle
    
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(0, 55, 0, 28)
    btn.Position = UDim2.new(1, -65, 0.5, -14)
    btn.BackgroundColor3 = default and Colors.Success or Colors.BG_Secondary
    btn.BorderSizePixel = 0
    btn.Parent = toggle
    AddCorner(btn, 14)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    circle.BackgroundColor3 = Colors.TextPrimary
    circle.BorderSizePixel = 0
    circle.Parent = btn
    AddCorner(circle, 11)
    
    local enabled = default
    
    local function Update()
        CreateTween(btn, {BackgroundColor3 = enabled and Colors.Success or Colors.BG_Secondary}, 0.2):Play()
        CreateTween(circle, {Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)}, 0.2):Play()
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            Update()
            pcall(function() callback(enabled) end)
        end
    end)
    
    return toggle
end

local function CreateSlider(parent, name, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -30, 0, 75)
    slider.BackgroundColor3 = Colors.BG_Card
    slider.BorderSizePixel = 0
    slider.Parent = parent
    AddCorner(slider, 12)
    AddStroke(slider, Colors.BG_Secondary, 1)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.5, 0, 0, 25)
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Text = name
    title.TextColor3 = Colors.TextPrimary
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = slider
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.55, 0, 0, 8)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Colors.AccentAlt
    valueLabel.TextSize = 18
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 10)
    track.Position = UDim2.new(0, 15, 0, 48)
    track.BackgroundColor3 = Colors.BG_Secondary
    track.BorderSizePixel = 0
    track.Parent = slider
    AddCorner(track, 5)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    AddCorner(fill, 5)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    knob.BackgroundColor3 = Colors.TextPrimary
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    knob.Parent = track
    AddCorner(knob, 11)
    AddStroke(knob, Colors.Accent, 2)
    
    local dragging = false
    local value = default
    
    local function Update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        valueLabel.Text = tostring(value)
        CreateTween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1):Play()
        CreateTween(knob, {Position = UDim2.new(pos, -11, 0.5, -11)}, 0.1):Play()
        pcall(function() callback(value) end)
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

local function CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -30, 0, 40)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "━━━ " .. title .. " ━━━"
    label.TextColor3 = Colors.AccentGold
    label.TextSize = 14
    label.Font = Enum.Font.GothamBlack
    label.BackgroundTransparency = 1
    label.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎯 وظائف الميزات
-- ═══════════════════════════════════════════════════════════════════════════

local function SetSpeed(enabled, value)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = enabled and (value or 16) or 16
    end
end

local function SetJump(enabled, value)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = enabled and (value or 50) or 50
    end
end

local flyBV, flyBG = nil, nil

local function SetFly(enabled)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root or not humanoid then return end
    
    if enabled then
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = root
        
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.Parent = root
        
        humanoid.PlatformStand = true
        
        Connections["Fly"] = RunService.RenderStepped:Connect(function()
            if not Settings.Fly.Enabled then return end
            
            local move = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            
            flyBV.Velocity = move * Settings.Fly.Speed
            flyBG.CFrame = Camera.CFrame
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        humanoid.PlatformStand = false
        if Connections["Fly"] then Connections["Fly"]:Disconnect() Connections["Fly"] = nil end
    end
end

local function SetInfiniteJump(enabled)
    if enabled then
        Connections["InfiniteJump"] = UserInputService.JumpRequest:Connect(function()
            if Settings.InfiniteJump.Enabled then
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    else
        if Connections["InfiniteJump"] then Connections["InfiniteJump"]:Disconnect() Connections["InfiniteJump"] = nil end
    end
end

local function SetNoclip(enabled)
    if enabled then
        Connections["Noclip"] = RunService.Stepped:Connect(function()
            if Settings.Noclip.Enabled then
                local char = LocalPlayer.Character
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
-- 🎨 إنشاء الواجهة الرئيسية - STANDALONE
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Create(parentGui, mainFrame)
    print("🚀 [KLIMBO] Creating Standalone Menu...")
    
    if KlimboUI then KlimboUI:Destroy() end
    
    MainFrameRef = mainFrame -- حفظ مرجع القائمة الرئيسية
    
    -- ═══ الشاشة الكاملة ═══
    KlimboUI = Instance.new("ScreenGui")
    KlimboUI.Name = "KlimboMenuStandalone"
    KlimboUI.ResetOnSpawn = false
    KlimboUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KlimboUI.Enabled = false
    KlimboUI.Parent = parentGui or game.CoreGui
    
    -- ═══ الخلفية الكاملة ═══
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Colors.BG_Primary
    background.BorderSizePixel = 0
    background.ZIndex = 1
    background.Parent = KlimboUI
    
    -- تدرج الخلفية
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.BG_Primary),
        ColorSequenceKeypoint.new(0.5, Colors.BG_Secondary),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = background
    
    -- النجوم
    CreateStars(background)
    
    -- ═══ الإطار الرئيسي ═══
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(0, 450, 0, 600)
    mainContainer.Position = UDim2.new(0.5, -225, 0.5, -300)
    mainContainer.BackgroundColor3 = Colors.BG_Secondary
    mainContainer.BorderSizePixel = 0
    mainContainer.ZIndex = 10
    mainContainer.Parent = background
    AddCorner(mainContainer, 20)
    AddStroke(mainContainer, Colors.Accent, 3)
    
    -- ═══ الشريط العلوي ═══
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 70)
    topBar.BackgroundColor3 = Colors.BG_Primary
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 50
    topBar.Parent = mainContainer
    AddCorner(topBar, 20)
    
    -- الشعار
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0.7, 0, 1, 0)
    logo.Position = UDim2.new(0, 25, 0, 0)
    logo.Text = "👑 KLIMBO MENU"
    logo.TextSize = 26
    logo.Font = Enum.Font.GothamBlack
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.TextColor3 = Colors.AccentGold
    logo.BackgroundTransparency = 1
    logo.ZIndex = 51
    logo.Parent = topBar
    
    -- زر الرجوع
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 50, 0, 50)
    backBtn.Position = UDim2.new(1, -60, 0.5, -25)
    backBtn.Text = "◀"
    backBtn.TextColor3 = Colors.TextPrimary
    backBtn.TextSize = 24
    backBtn.Font = Enum.Font.GothamBold
    backBtn.BackgroundColor3 = Colors.Error
    backBtn.BorderSizePixel = 0
    backBtn.ZIndex = 51
    backBtn.Parent = topBar
    AddCorner(backBtn, 12)
    
    backBtn.MouseButton1Click:Connect(function()
        KlimboMenu.Hide()
    end)
    
    -- ═══ منطقة المحتوى ═══
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Content"
    scrollFrame.Size = UDim2.new(1, -30, 1, -90)
    scrollFrame.Position = UDim2.new(0, 15, 0, 75)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Colors.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    scrollFrame.ZIndex = 20
    scrollFrame.Parent = mainContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.Parent = scrollFrame
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- ════════════════════════════════════════════════════════════════════════
    -- 📝 ملء المحتوى
    -- ════════════════════════════════════════════════════════════════════════
    
    print("🔧 [KLIMBO] Adding Content...")
    
    -- ═══ السرعة ═══
    CreateSection(scrollFrame, "⚡ SPEED SETTINGS")
    
    CreateToggle(scrollFrame, "Enable Speed", "تفعيل السرعة المخصصة", false, function(enabled)
        Settings.Speed.Enabled = enabled
        SetSpeed(enabled, Settings.Speed.Value)
    end)
    
    CreateSlider(scrollFrame, "Walk Speed", 0, 500, 16, function(value)
        Settings.Speed.Value = value
        if Settings.Speed.Enabled then SetSpeed(true, value) end
    end)
    
    -- ═══ القفز ═══
    CreateSection(scrollFrame, "🎯 JUMP SETTINGS")
    
    CreateToggle(scrollFrame, "Enable Jump Power", "تفعيل قوة القفز", false, function(enabled)
        Settings.Jump.Enabled = enabled
        SetJump(enabled, Settings.Jump.Value)
    end)
    
    CreateSlider(scrollFrame, "Jump Power", 0, 500, 50, function(value)
        Settings.Jump.Value = value
        if Settings.Jump.Enabled then SetJump(true, value) end
    end)
    
    -- ═══ الطيران ═══
    CreateSection(scrollFrame, "✈️ FLIGHT SETTINGS")
    
    CreateToggle(scrollFrame, "Enable Fly", "الطيران (WASD + Space/Shift)", false, function(enabled)
        Settings.Fly.Enabled = enabled
        SetFly(enabled)
    end)
    
    CreateSlider(scrollFrame, "Fly Speed", 10, 200, 50, function(value)
        Settings.Fly.Speed = value
    end)
    
    -- ═══ ميزات أخرى ═══
    CreateSection(scrollFrame, "🌟 OTHER FEATURES")
    
    CreateToggle(scrollFrame, "Infinite Jump", "القفز اللانهائي", false, function(enabled)
        Settings.InfiniteJump.Enabled = enabled
        SetInfiniteJump(enabled)
    end)
    
    CreateToggle(scrollFrame, "Noclip", "المرور عبر الجدران", false, function(enabled)
        Settings.Noclip.Enabled = enabled
        SetNoclip(enabled)
    end)
    
    CreateToggle(scrollFrame, "God Mode", "الخلود (Client-Side)", false, function(enabled)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
    
    -- ═══ معلومات ═══
    CreateSection(scrollFrame, "ℹ️ INFORMATION")
    
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, -30, 0, 80)
    infoFrame.BackgroundColor3 = Colors.BG_Card
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = scrollFrame
    AddCorner(infoFrame, 12)
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 1, -20)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.Text = "👑 KLIMBO MENU v4.0\n🚀 All features working!\n💫 Press ◀ to go back"
    infoText.TextColor3 = Colors.TextSecondary
    infoText.TextSize = 13
    infoText.Font = Enum.Font.Gotham
    infoText.TextWrapped = true
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.BackgroundTransparency = 1
    infoText.Parent = infoFrame
    
    print("✅ [KLIMBO] Menu Created Successfully!")
    return KlimboUI
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎛️ التحكم في العرض
-- ═══════════════════════════════════════════════════════════════════════════

function KlimboMenu.Show()
    print("🔓 [KLIMBO] Opening Menu...")
    
    if not KlimboUI then
        warn("❌ [KLIMBO] Menu not created! Call KlimboMenu.Create() first!")
        return
    end
    
    -- إخفاء القائمة الرئيسية
    if MainFrameRef then
        MainFrameRef.Visible = false
        print("✅ [KLIMBO] Main menu hidden")
    end
    
    -- إظهار KLIMBO
    KlimboUI.Enabled = true
    IsOpen = true
    
    print("✅ [KLIMBO] Menu opened successfully!")
end

function KlimboMenu.Hide()
    print("🔒 [KLIMBO] Closing Menu...")
    
    if not KlimboUI then return end
    
    -- إخفاء KLIMBO
    KlimboUI.Enabled = false
    IsOpen = false
    
    -- إعادة إظهار القائمة الرئيسية
    if MainFrameRef then
        MainFrameRef.Visible = true
        print("✅ [KLIMBO] Main menu restored")
    end
    
    print("✅ [KLIMBO] Menu closed successfully!")
end

function KlimboMenu.Toggle()
    if IsOpen then
        KlimboMenu.Hide()
    else
        KlimboMenu.Show()
    end
end

function KlimboMenu.IsOpen()
    return IsOpen
end

function KlimboMenu.Destroy()
    -- تنظيف الاتصالات
    for name, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    Connections = {}
    
    -- حذف الواجهة
    if KlimboUI then KlimboUI:Destroy() end
    
    -- إعادة إظهار القائمة الرئيسية
    if MainFrameRef then MainFrameRef.Visible = true end
    
    print("🗑️ [KLIMBO] Menu destroyed")
end

-- ═══════════════════════════════════════════════════════════════════════════

print("👑 KLIMBO MENU v4.0 - STANDALONE READY!")
print("📝 Usage:")
print("   1. KlimboMenu.Create(gui, mainFrame)")
print("   2. KlimboMenu.Show()")
print("   3. Press ◀ to go back")

return KlimboMenu
