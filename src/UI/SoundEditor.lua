local SoundEditor = {}

local TweenService = game:GetService("TweenService")

local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text) end
    end)
end

local function ShowNotif(parent, msg, color)
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 250, 0, 45)
    N.Position = UDim2.new(0.5, -125, 0, -50)
    N.BackgroundColor3 = color
    N.ZIndex = 310
    N.Parent = parent
    Instance.new("UICorner", N).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,0,1,0)
    L.Text = msg
    L.TextColor3 = Color3.fromRGB(255,255,255)
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.BackgroundTransparency = 1
    L.ZIndex = 311
    L.Parent = N
    TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 10)}):Play()
    spawn(function()
        wait(2)
        TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
        wait(0.3)
        N:Destroy()
    end)
end

function SoundEditor.Open(mainParent, soundInstance, onExit)
    local FullScreen = Instance.new("Frame")
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent

    -- الشريط العلوي
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen

    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, 0)
    TopLine.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    TopLine.ZIndex = 502
    TopLine.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "🔊 " .. soundInstance.Name
    Title.TextColor3 = Color3.fromRGB(255, 200, 50)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 502
    Title.Parent = TopBar

    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 90, 0, 38)
    ExitBtn.Position = UDim2.new(1, -100, 0.5, -19)
    ExitBtn.Text = "✕ Exit"
    ExitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ExitBtn.TextSize = 14
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)

    ExitBtn.MouseButton1Click:Connect(function()
        pcall(function() soundInstance:Stop() end)
        FullScreen:Destroy()
        if onExit then onExit() end
    end)

    -- المحتوى
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -70)
    Content.Position = UDim2.new(0, 10, 0, 65)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 50)
    Content.ZIndex = 501
    Content.Parent = FullScreen

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 12)
    CLayout.Parent = Content

    local CPad = Instance.new("UIPadding")
    CPad.PaddingTop = UDim.new(0, 10)
    CPad.PaddingLeft = UDim.new(0, 5)
    CPad.PaddingRight = UDim.new(0, 5)
    CPad.Parent = Content

    -- ═══ أزرار التشغيل ═══
    local PlayBar = Instance.new("Frame")
    PlayBar.Size = UDim2.new(1, 0, 0, 70)
    PlayBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    PlayBar.ZIndex = 502
    PlayBar.Parent = Content
    Instance.new("UICorner", PlayBar).CornerRadius = UDim.new(0, 12)

    local PBLayout = Instance.new("UIListLayout")
    PBLayout.FillDirection = Enum.FillDirection.Horizontal
    PBLayout.Padding = UDim.new(0, 10)
    PBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PBLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    PBLayout.Parent = PlayBar

    local function PlayBtn(text, icon, color, callback)
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(0, 100, 0, 50)
        B.Text = icon .. " " .. text
        B.TextColor3 = Color3.fromRGB(255,255,255)
        B.TextSize = 15
        B.Font = Enum.Font.GothamBold
        B.BackgroundColor3 = color
        B.ZIndex = 503
        B.Parent = PlayBar
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
        B.MouseButton1Click:Connect(callback)
        return B
    end

    PlayBtn("Play", "▶️", Color3.fromRGB(0, 200, 100), function()
        pcall(function() soundInstance:Play() end)
        ShowNotif(FullScreen, "▶️ Playing...", Color3.fromRGB(0, 200, 100))
    end)

    PlayBtn("Pause", "⏸️", Color3.fromRGB(255, 200, 50), function()
        pcall(function() soundInstance:Pause() end)
        ShowNotif(FullScreen, "⏸️ Paused", Color3.fromRGB(255, 200, 50))
    end)

    PlayBtn("Stop", "⏹️", Color3.fromRGB(200, 50, 70), function()
        pcall(function() soundInstance:Stop() end)
        ShowNotif(FullScreen, "⏹️ Stopped", Color3.fromRGB(200, 50, 70))
    end)

    -- ═══ دالة لإنشاء Slider ═══
    local function CreateSlider(title, icon, currentVal, minVal, maxVal, onChanged)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 80)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        SliderFrame.ZIndex = 502
        SliderFrame.Parent = Content
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 12)

        local SLabel = Instance.new("TextLabel")
        SLabel.Size = UDim2.new(0.5, 0, 0, 25)
        SLabel.Position = UDim2.new(0, 15, 0, 8)
        SLabel.Text = icon .. " " .. title
        SLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
        SLabel.TextSize = 14
        SLabel.Font = Enum.Font.GothamBold
        SLabel.TextXAlignment = Enum.TextXAlignment.Left
        SLabel.BackgroundTransparency = 1
        SLabel.ZIndex = 503
        SLabel.Parent = SliderFrame

        local ValLabel = Instance.new("TextLabel")
        ValLabel.Size = UDim2.new(0.4, 0, 0, 25)
        ValLabel.Position = UDim2.new(0.55, 0, 0, 8)
        ValLabel.Text = tostring(math.floor(currentVal * 100) / 100)
        ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValLabel.TextSize = 16
        ValLabel.Font = Enum.Font.GothamBold
        ValLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValLabel.BackgroundTransparency = 1
        ValLabel.ZIndex = 503
        ValLabel.Parent = SliderFrame

        -- شريط التمرير
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -30, 0, 8)
        Track.Position = UDim2.new(0, 15, 0, 50)
        Track.BackgroundColor3 = Color3.fromRGB(40, 45, 80)
        Track.ZIndex = 503
        Track.Parent = SliderFrame
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        local fillPercent = (currentVal - minVal) / (maxVal - minVal)
        Fill.Size = UDim2.new(math.clamp(fillPercent, 0, 1), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
        Fill.ZIndex = 504
        Fill.Parent = Track
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local Knob = Instance.new("TextButton")
        Knob.Size = UDim2.new(0, 22, 0, 22)
        Knob.Position = UDim2.new(math.clamp(fillPercent, 0, 1), -11, 0.5, -11)
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.Text = ""
        Knob.ZIndex = 505
        Knob.Parent = Track
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local KStroke = Instance.new("UIStroke")
        KStroke.Color = Color3.fromRGB(0, 212, 255)
        KStroke.Thickness = 2
        KStroke.Parent = Knob

        local dragging = false
        Knob.MouseButton1Down:Connect(function() dragging = true end)
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local trackPos = Track.AbsolutePosition.X
                local trackSize = Track.AbsoluteSize.X
                local mouseX = input.Position.X

                local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                local value = minVal + (maxVal - minVal) * percent

                Fill.Size = UDim2.new(percent, 0, 1, 0)
                Knob.Position = UDim2.new(percent, -11, 0.5, -11)
                ValLabel.Text = tostring(math.floor(value * 100) / 100)

                onChanged(value)
            end
        end)
    end

    -- ═══ Volume Slider ═══
    local currentVolume = 1
    pcall(function() currentVolume = soundInstance.Volume end)
    CreateSlider("Volume", "🔊", currentVolume, 0, 3, function(val)
        pcall(function() soundInstance.Volume = val end)
    end)

    -- ═══ Pitch Slider ═══
    local currentPitch = 1
    pcall(function() currentPitch = soundInstance.PlaybackSpeed end)
    CreateSlider("Pitch / Speed", "⚡", currentPitch, 0.1, 5, function(val)
        pcall(function() soundInstance.PlaybackSpeed = val end)
    end)

    -- ═══ Loop Toggle ═══
    local LoopFrame = Instance.new("Frame")
    LoopFrame.Size = UDim2.new(1, 0, 0, 55)
    LoopFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    LoopFrame.ZIndex = 502
    LoopFrame.Parent = Content
    Instance.new("UICorner", LoopFrame).CornerRadius = UDim.new(0, 12)

    local LoopLabel = Instance.new("TextLabel")
    LoopLabel.Size = UDim2.new(0.6, 0, 1, 0)
    LoopLabel.Position = UDim2.new(0, 15, 0, 0)
    LoopLabel.Text = "🔁 Loop"
    LoopLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    LoopLabel.TextSize = 16
    LoopLabel.Font = Enum.Font.GothamBold
    LoopLabel.TextXAlignment = Enum.TextXAlignment.Left
    LoopLabel.BackgroundTransparency = 1
    LoopLabel.ZIndex = 503
    LoopLabel.Parent = LoopFrame

    local isLooped = false
    pcall(function() isLooped = soundInstance.Looped end)

    local LoopBtn = Instance.new("TextButton")
    LoopBtn.Size = UDim2.new(0, 80, 0, 35)
    LoopBtn.Position = UDim2.new(1, -95, 0.5, -17)
    LoopBtn.Text = isLooped and "ON" or "OFF"
    LoopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    LoopBtn.TextSize = 14
    LoopBtn.Font = Enum.Font.GothamBold
    LoopBtn.BackgroundColor3 = isLooped and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 50, 50)
    LoopBtn.ZIndex = 503
    LoopBtn.Parent = LoopFrame
    Instance.new("UICorner", LoopBtn).CornerRadius = UDim.new(0, 8)

    LoopBtn.MouseButton1Click:Connect(function()
        isLooped = not isLooped
        pcall(function() soundInstance.Looped = isLooped end)
        LoopBtn.Text = isLooped and "ON" or "OFF"
        LoopBtn.BackgroundColor3 = isLooped and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 50, 50)
    end)

    -- ═══ Sound ID ═══
    local IdFrame = Instance.new("Frame")
    IdFrame.Size = UDim2.new(1, 0, 0, 80)
    IdFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    IdFrame.ZIndex = 502
    IdFrame.Parent = Content
    Instance.new("UICorner", IdFrame).CornerRadius = UDim.new(0, 12)

    local IdLabel = Instance.new("TextLabel")
    IdLabel.Size = UDim2.new(1, -20, 0, 20)
    IdLabel.Position = UDim2.new(0, 10, 0, 8)
    IdLabel.Text = "🎵 Sound ID"
    IdLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    IdLabel.TextSize = 13
    IdLabel.Font = Enum.Font.GothamBold
    IdLabel.TextXAlignment = Enum.TextXAlignment.Left
    IdLabel.BackgroundTransparency = 1
    IdLabel.ZIndex = 503
    IdLabel.Parent = IdFrame

    local currentId = ""
    pcall(function() currentId = soundInstance.SoundId end)

    local IdInput = Instance.new("TextBox")
    IdInput.Size = UDim2.new(1, -20, 0, 35)
    IdInput.Position = UDim2.new(0, 10, 0, 35)
    IdInput.Text = currentId
    IdInput.PlaceholderText = "rbxassetid://12345678"
    IdInput.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    IdInput.Font = Enum.Font.Code
    IdInput.TextSize = 13
    IdInput.ClearTextOnFocus = false
    IdInput.ZIndex = 503
    IdInput.Parent = IdFrame
    Instance.new("UICorner", IdInput).CornerRadius = UDim.new(0, 8)

    IdInput.FocusLost:Connect(function()
        pcall(function()
            soundInstance.SoundId = IdInput.Text
        end)
        ShowNotif(FullScreen, "🎵 Sound ID updated!", Color3.fromRGB(0, 200, 100))
    end)

    -- ═══ أزرار إضافية ═══
    local ActionBar = Instance.new("Frame")
    ActionBar.Size = UDim2.new(1, 0, 0, 55)
    ActionBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    ActionBar.ZIndex = 502
    ActionBar.Parent = Content
    Instance.new("UICorner", ActionBar).CornerRadius = UDim.new(0, 12)

    local ABLayout = Instance.new("UIListLayout")
    ABLayout.FillDirection = Enum.FillDirection.Horizontal
    ABLayout.Padding = UDim.new(0, 8)
    ABLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ABLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ABLayout.Parent = ActionBar

    local function ActBtn(text, icon, color, callback)
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(0, 120, 0, 38)
        B.Text = icon .. " " .. text
        B.TextColor3 = Color3.fromRGB(255,255,255)
        B.TextSize = 12
        B.Font = Enum.Font.GothamBold
        B.BackgroundColor3 = color
        B.ZIndex = 503
        B.Parent = ActionBar
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
        B.MouseButton1Click:Connect(callback)
    end

    ActBtn("Copy ID", "📋", Color3.fromRGB(0, 152, 219), function()
        CopyToClipboard(currentId)
        ShowNotif(FullScreen, "✅ Sound ID copied!", Color3.fromRGB(0, 200, 100))
    end)

    ActBtn("Save File", "💾", Color3.fromRGB(0, 200, 100), function()
        pcall(function()
            if writefile then
                writefile("WiliExplorer_Sound_" .. soundInstance.Name .. ".txt", "SoundId: " .. soundInstance.SoundId .. "\nVolume: " .. soundInstance.Volume .. "\nPitch: " .. soundInstance.PlaybackSpeed .. "\nLooped: " .. tostring(soundInstance.Looped))
                ShowNotif(FullScreen, "✅ Info saved to file!", Color3.fromRGB(0, 200, 100))
            end
        end)
    end)

    Content.CanvasSize = UDim2.new(0, 0, 0, CLayout.AbsoluteContentSize.Y + 20)
    print("SoundEditor opened: " .. soundInstance.Name)
end

return SoundEditor
