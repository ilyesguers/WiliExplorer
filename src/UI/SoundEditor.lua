--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔊 WiliExplorer - Sound Editor v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تشغيل/إيقاف الصوت
    ✅ تغيير Volume
    ✅ تغيير Pitch/PlaybackSpeed
    ✅ تغيير Sound ID
    ✅ Loop toggle
    ✅ عرض معلومات الصوت
    ✅ شريط تقدم
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local SoundEditor = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
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
    Accent = Color3.fromRGB(100, 255, 150),
    Play = Color3.fromRGB(0, 200, 100),
    Stop = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Button = Color3.fromRGB(30, 35, 65),
    ButtonHover = Color3.fromRGB(40, 45, 80),
    Progress = Color3.fromRGB(100, 255, 150),
    ProgressBG = Color3.fromRGB(25, 25, 50)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), props):Play()
end

local function FormatTime(seconds)
    if not seconds or seconds ~= seconds then return "0:00" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", mins, secs)
end

local function Notify(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔊 Sound Editor",
            Text = message,
            Duration = 2
        })
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔊 فتح محرر الأصوات
-- ═══════════════════════════════════════════════════════════════════════
function SoundEditor.Open(parent, instance, onClose)
    if not instance or not instance:IsA("Sound") then return end
    
    -- إنشاء الواجهة
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliSoundEditor"
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
    window.Size = UDim2.new(0, 400, 0, 500)
    window.Position = UDim2.new(0.5, -200, 0.5, -250)
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
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "🔊 " .. instance.Name
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
    closeBtn.BackgroundColor3 = Colors.Stop
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
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = content
    
    -- ═══ معلومات الصوت ═══
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 0, 80)
    infoFrame.BackgroundColor3 = Colors.Body
    infoFrame.ZIndex = 1000
    infoFrame.Parent = content
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 10)
    
    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = Colors.Border
    infoStroke.Thickness = 1
    infoStroke.Parent = infoFrame
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -16, 1, -10)
    infoText.Position = UDim2.new(0, 8, 0, 5)
    infoText.Text = string.format(
        "Sound ID: %s\nTime: %s / %s\nPlaying: %s",
        instance.SoundId,
        FormatTime(instance.TimePosition),
        FormatTime(instance.TimeLength),
        instance.IsPlaying and "Yes ✅" or "No ❌"
    )
    infoText.TextColor3 = Colors.Text
    infoText.TextSize = 12
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.BackgroundTransparency = 1
    infoText.ZIndex = 1001
    infoText.Parent = infoFrame
    
    -- ═══ شريط التقدم ═══
    local progressFrame = Instance.new("Frame")
    progressFrame.Size = UDim2.new(1, 0, 0, 40)
    progressFrame.BackgroundColor3 = Colors.Body
    progressFrame.ZIndex = 1000
    progressFrame.Parent = content
    Instance.new("UICorner", progressFrame).CornerRadius = UDim.new(0, 10)
    
    local progressStroke = Instance.new("UIStroke")
    progressStroke.Color = Colors.Border
    progressStroke.Thickness = 1
    progressStroke.Parent = progressFrame
    
    local timeText = Instance.new("TextLabel")
    timeText.Size = UDim2.new(1, -10, 0, 15)
    timeText.Position = UDim2.new(0, 5, 0, 3)
    timeText.Text = FormatTime(instance.TimePosition) .. " / " .. FormatTime(instance.TimeLength)
    timeText.TextColor3 = Colors.TextDim
    timeText.TextSize = 10
    timeText.Font = Enum.Font.Gotham
    timeText.BackgroundTransparency = 1
    timeText.ZIndex = 1001
    timeText.Parent = progressFrame
    
    local progressBarBG = Instance.new("Frame")
    progressBarBG.Size = UDim2.new(1, -10, 0, 6)
    progressBarBG.Position = UDim2.new(0, 5, 0, 25)
    progressBarBG.BackgroundColor3 = Colors.ProgressBG
    progressBarBG.ZIndex = 1001
    progressBarBG.Parent = progressFrame
    Instance.new("UICorner", progressBarBG).CornerRadius = UDim.new(0, 3)
    
    local progressBarFill = Instance.new("Frame")
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
    progressBarFill.BackgroundColor3 = Colors.Progress
    progressBarFill.ZIndex = 1002
    progressBarFill.Parent = progressBarBG
    Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(0, 3)
    
    -- ═══ أزرار التحكم ═══
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(1, 0, 0, 50)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.ZIndex = 1000
    controlsFrame.Parent = content
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 10)
    controlsLayout.Parent = controlsFrame
    
    local function CreateControlBtn(text, icon, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 40)
        btn.BackgroundColor3 = color or Colors.Button
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 1001
        btn.Parent = controlsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        
        local iconLbl = Instance.new("TextLabel")
        iconLbl.Size = UDim2.new(0, 30, 1, 0)
        iconLbl.Position = UDim2.new(0, 5, 0, 0)
        iconLbl.Text = icon
        iconLbl.TextSize = 16
        iconLbl.BackgroundTransparency = 1
        iconLbl.ZIndex = 1002
        iconLbl.Parent = btn
        
        local textLbl = Instance.new("TextLabel")
        textLbl.Size = UDim2.new(1, -40, 1, 0)
        textLbl.Position = UDim2.new(0, 35, 0, 0)
        textLbl.Text = text
        textLbl.TextColor3 = Colors.Text
        textLbl.TextSize = 11
        textLbl.Font = Enum.Font.GothamBold
        textLbl.BackgroundTransparency = 1
        textLbl.ZIndex = 1002
        textLbl.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Colors.ButtonHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = color or Colors.Button}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    local playBtn = CreateControlBtn("Play", "▶️", Colors.Play, function()
        if instance.IsPlaying then
            instance:Pause()
        else
            instance:Resume()
        end
    end)
    
    local stopBtn = CreateControlBtn("Stop", "⏹️", Colors.Stop, function()
        instance:Stop()
    end)
    
    local restartBtn = CreateControlBtn("Restart", "🔄", Colors.Warning, function()
        instance:Stop()
        task.wait(0.1)
        instance:Play()
    end)
    
    -- ═══ خصائص الصوت ═══
    local propsFrame = Instance.new("Frame")
    propsFrame.Size = UDim2.new(1, 0, 0, 180)
    propsFrame.BackgroundColor3 = Colors.Body
    propsFrame.ZIndex = 1000
    propsFrame.Parent = content
    Instance.new("UICorner", propsFrame).CornerRadius = UDim.new(0, 10)
    
    local propsStroke = Instance.new("UIStroke")
    propsStroke.Color = Colors.Border
    propsStroke.Thickness = 1
    propsStroke.Parent = propsFrame
    
    local propsScroll = Instance.new("ScrollingFrame")
    propsScroll.Size = UDim2.new(1, -10, 1, -10)
    propsScroll.Position = UDim2.new(0, 5, 0, 5)
    propsScroll.BackgroundTransparency = 1
    propsScroll.ScrollBarThickness = 3
    propsScroll.ScrollBarImageColor3 = Colors.Accent
    propsScroll.ZIndex = 1001
    propsScroll.Parent = propsFrame
    
    local propsLayout = Instance.new("UIListLayout")
    propsLayout.Padding = UDim.new(0, 6)
    propsLayout.Parent = propsScroll
    
    -- دالة إنشاء Slider
    local function CreatePropSlider(name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Colors.Button
        frame.ZIndex = 1002
        frame.Parent = propsScroll
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 0, 15)
        lbl.Position = UDim2.new(0, 5, 0, 2)
        lbl.Text = name
        lbl.TextColor3 = Colors.TextDim
        lbl.TextSize = 10
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.ZIndex = 1003
        lbl.Parent = frame
        
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.5, -5, 0, 15)
        valLbl.Position = UDim2.new(0.5, 0, 0, 2)
        valLbl.Text = string.format("%.2f", default)
        valLbl.TextColor3 = Colors.Accent
        valLbl.TextSize = 10
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.BackgroundTransparency = 1
        valLbl.ZIndex = 1003
        valLbl.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -10, 0, 6)
        sliderBg.Position = UDim2.new(0, 5, 0, 25)
        sliderBg.BackgroundColor3 = Colors.ProgressBG
        sliderBg.ZIndex = 1003
        sliderBg.Parent = frame
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 3)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Colors.Accent
        fill.ZIndex = 1004
        fill.Parent = sliderBg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
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
                knob.Position = UDim2.new(pos, -6, 0.5, -6)
                if callback then callback(val) end
            end
        end)
    end
    
    -- ═══ Loop Toggle ═══
    local loopFrame = Instance.new("Frame")
    loopFrame.Size = UDim2.new(1, 0, 0, 35)
    loopFrame.BackgroundColor3 = Colors.Button
    loopFrame.ZIndex = 1002
    loopFrame.Parent = propsScroll
    Instance.new("UICorner", loopFrame).CornerRadius = UDim.new(0, 6)
    
    local loopLabel = Instance.new("TextLabel")
    loopLabel.Size = UDim2.new(0.7, 0, 1, 0)
    loopLabel.Position = UDim2.new(0, 10, 0, 0)
    loopLabel.Text = "🔄 Loop"
    loopLabel.TextColor3 = Colors.Text
    loopLabel.TextSize = 12
    loopLabel.Font = Enum.Font.GothamBold
    loopLabel.TextXAlignment = Enum.TextXAlignment.Left
    loopLabel.BackgroundTransparency = 1
    loopLabel.ZIndex = 1003
    loopLabel.Parent = loopFrame
    
    local loopToggle = Instance.new("TextButton")
    loopToggle.Size = UDim2.new(0, 50, 0, 25)
    loopToggle.Position = UDim2.new(1, -60, 0.5, -12)
    loopToggle.Text = instance.Looped and "ON ✅" or "OFF ❌"
    loopToggle.TextColor3 = instance.Looped and Colors.Accent or Colors.Stop
    loopToggle.TextSize = 10
    loopToggle.Font = Enum.Font.GothamBold
    loopToggle.BackgroundColor3 = instance.Looped and Color3.fromRGB(20, 50, 30) or Color3.fromRGB(50, 20, 20)
    loopToggle.ZIndex = 1003
    loopToggle.Parent = loopFrame
    Instance.new("UICorner", loopToggle).CornerRadius = UDim.new(0, 6)
    
    loopToggle.MouseButton1Click:Connect(function()
        instance.Looped = not instance.Looped
        loopToggle.Text = instance.Looped and "ON ✅" or "OFF ❌"
        loopToggle.TextColor3 = instance.Looped and Colors.Accent or Colors.Stop
        Tween(loopToggle, {
            BackgroundColor3 = instance.Looped and Color3.fromRGB(20, 50, 30) or Color3.fromRGB(50, 20, 20)
        }, 0.2)
    end)
    
    -- ═══ Sliders ═══
    CreatePropSlider("Volume", 0, 10, instance.Volume, function(val)
        instance.Volume = val
    end)
    
    CreatePropSlider("PlaybackSpeed", 0.1, 3, instance.PlaybackSpeed, function(val)
        instance.PlaybackSpeed = val
    end)
    
    CreatePropSlider("Pitch", 0.1, 3, instance.PlaybackSpeed, function(val)
        instance.PlaybackSpeed = val
    end)
    
    -- Sound ID Input
    local idFrame = Instance.new("Frame")
    idFrame.Size = UDim2.new(1, 0, 0, 55)
    idFrame.BackgroundColor3 = Colors.Button
    idFrame.ZIndex = 1002
    idFrame.Parent = propsScroll
    Instance.new("UICorner", idFrame).CornerRadius = UDim.new(0, 6)
    
    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -10, 0, 18)
    idLabel.Position = UDim2.new(0, 5, 0, 3)
    idLabel.Text = "🎵 Sound ID"
    idLabel.TextColor3 = Colors.TextDim
    idLabel.TextSize = 10
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.BackgroundTransparency = 1
    idLabel.ZIndex = 1003
    idLabel.Parent = idFrame
    
    local idInput = Instance.new("TextBox")
    idInput.Size = UDim2.new(1, -10, 0, 25)
    idInput.Position = UDim2.new(0, 5, 0, 25)
    idInput.Text = instance.SoundId
    idInput.TextColor3 = Colors.Text
    idInput.Font = Enum.Font.Code
    idInput.TextSize = 12
    idInput.TextXAlignment = Enum.TextXAlignment.Left
    idInput.ClearTextOnFocus = false
    idInput.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    idInput.ZIndex = 1003
    idInput.Parent = idFrame
    Instance.new("UICorner", idInput).CornerRadius = UDim.new(0, 6)
    
    idInput.FocusLost:Connect(function()
        instance.SoundId = idInput.Text
        Notify("تم تغيير Sound ID!")
    end)
    
    -- ═══ تحديث شريط التقدم ═══
    local progressConnection
    progressConnection = RunService.Heartbeat:Connect(function()
        if not instance or not instance.Parent then
            progressConnection:Disconnect()
            return
        end
        
        local progress = 0
        if instance.TimeLength > 0 then
            progress = instance.TimePosition / instance.TimeLength
        end
        
        progressBarFill.Size = UDim2.new(math.clamp(progress, 0, 1), 0, 1, 0)
        timeText.Text = FormatTime(instance.TimePosition) .. " / " .. FormatTime(instance.TimeLength)
        
        infoText.Text = string.format(
            "Sound ID: %s\nTime: %s / %s\nPlaying: %s",
            instance.SoundId,
            FormatTime(instance.TimePosition),
            FormatTime(instance.TimeLength),
            instance.IsPlaying and "Yes ✅" or "No ❌"
        )
    end)
    
    -- ═══ إغلاق ═══
    closeBtn.MouseButton1Click:Connect(function()
        progressConnection:Disconnect()
        gui:Destroy()
        if onClose then onClose() end
    end)
    
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            progressConnection:Disconnect()
            gui:Destroy()
            if onClose then onClose() end
        end
    end)
    
    return {
        close = function()
            progressConnection:Disconnect()
            gui:Destroy()
        end
    }
end

print("🔊 Sound Editor v1.0 Loaded!")

return SoundEditor
