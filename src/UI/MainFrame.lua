local MainFrame = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function MainFrame.Create(Modules)
    -- ═══════════════════════════════════════
    -- استقبال الـ Modules أو تحميلها إذا لم تُمرر
    -- ═══════════════════════════════════════
    Modules = Modules or {}
    
    local KeySystem = Modules.KeySystem or loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Security/KeySystem.lua", true))()
    local Stars = Modules.Stars or loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Theme/Stars.lua", true))()
    local Language = Modules.Language or loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()
    
    -- ⭐ الأدوات الجديدة
    local AdvancedTools = Modules.AdvancedTools
    local GameAnalyzer = Modules.GameAnalyzer

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- كشف حجم الشاشة
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < 800
    
    -- حجم مناسب للهاتف
    local frameWidth = isMobile and viewport.X * 0.95 or 700
    local frameHeight = isMobile and viewport.Y * 0.85 or 500

    -- ═══════════════════════════════
    -- الإطار الرئيسي
    -- ═══════════════════════════════
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
    Frame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
    Frame.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 212, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    -- تدرج فضائي
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 13, 26)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(17, 20, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 60))
    })
    Gradient.Rotation = 135
    Gradient.Parent = Frame

    -- النجوم في الخلفية (مقللة لمنع الكراش)
    if Stars and Stars.Create then
        Stars.Create(Frame, 30) -- 30 بدلاً من 100
    end

    -- ═══════════════════════════════
    -- الشريط العلوي (Top Bar)
    -- ═══════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.BackgroundTransparency = 0.3
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 50
    TopBar.Parent = Frame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 20)
    TopCorner.Parent = TopBar

    -- شعار التطبيق
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(0, 200, 1, 0)
    Logo.Position = UDim2.new(0, 15, 0, 0)
    Logo.Text = "🚀 WiliExplorer"
    Logo.TextColor3 = Color3.fromRGB(0, 212, 255)
    Logo.TextSize = 20
    Logo.Font = Enum.Font.GothamBold
    Logo.BackgroundTransparency = 1
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    Logo.ZIndex = 51
    Logo.Parent = TopBar

    -- زر اللغة
    local LangBtn = Instance.new("TextButton")
    LangBtn.Size = UDim2.new(0, 80, 0, 32)
    LangBtn.Position = UDim2.new(1, -180, 0.5, -16)
    LangBtn.Text = "🌐 عربي"
    LangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LangBtn.TextSize = 14
    LangBtn.Font = Enum.Font.GothamBold
    LangBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    LangBtn.ZIndex = 51
    LangBtn.Parent = TopBar
    Instance.new("UICorner", LangBtn).CornerRadius = UDim.new(0, 8)

    -- زر التصغير
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 32, 0, 32)
    MinBtn.Position = UDim2.new(1, -90, 0.5, -16)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    MinBtn.ZIndex = 51
    MinBtn.Parent = TopBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -50, 0.5, -16)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    CloseBtn.ZIndex = 51
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, frameWidth, 0, 50)}):Play()
        else
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, frameWidth, 0, frameHeight)}):Play()
        end
    end)

    -- ═══════════════════════════════
    -- منطقة المحتوى
    -- ═══════════════════════════════
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.Position = UDim2.new(0, 0, 0, 50)
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
    KeyScreen.ZIndex = 15
    KeyScreen.Parent = Content

    local Title = Instance.new("TextLabel")
    Title.Text = "🌌 WiliExplorer"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Position = UDim2.new(0, 0, 0.15, 0)
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
    Title.TextSize = 36
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.ZIndex = 16
    Title.Parent = KeyScreen

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = Language and Language.Get and Language.Get("Welcome") or "Welcome to the Cosmos"
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0.28, 0)
    Subtitle.TextColor3 = Color3.fromRGB(150, 170, 200)
    Subtitle.TextSize = 16
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 16
    Subtitle.Parent = KeyScreen

    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = Language and Language.Get and Language.Get("EnterKey") or "ENTER COSMIC KEY"
    KeyInput.Text = ""
    KeyInput.Size = UDim2.new(0.85, 0, 0, 55)
    KeyInput.Position = UDim2.new(0.075, 0, 0.45, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 130, 160)
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 18
    KeyInput.ClearTextOnFocus = false
    KeyInput.ZIndex = 16
    KeyInput.Parent = KeyScreen
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 12)
    
    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Color3.fromRGB(0, 212, 255)
    KeyStroke.Thickness = 2
    KeyStroke.Transparency = 0.5
    KeyStroke.Parent = KeyInput

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "🔓 " .. (Language and Language.Get and Language.Get("Verify") or "VERIFY KEY")
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 55)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.65, 0)
    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    LoginBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 20
    LoginBtn.ZIndex = 16
    LoginBtn.Parent = KeyScreen
    Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 12)

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = ""
    StatusLabel.Size = UDim2.new(0.8, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.ZIndex = 16
    StatusLabel.Parent = KeyScreen

    -- ═══════════════════════════════
    -- الشاشة الرئيسية (بعد المفتاح)
    -- ═══════════════════════════════
    local MainScreen = Instance.new("Frame")
    MainScreen.Name = "MainScreen"
    MainScreen.Size = UDim2.new(1, 0, 1, 0)
    MainScreen.BackgroundTransparency = 1
    MainScreen.Visible = false
    MainScreen.ZIndex = 15
    MainScreen.Parent = Content

    -- ═══════════════════════════════
    -- ⭐ أزرار الأدوات الجديدة
    -- ═══════════════════════════════
    local ToolsTitle = Instance.new("TextLabel")
    ToolsTitle.Text = "🛠️ Advanced Tools"
    ToolsTitle.Size = UDim2.new(1, 0, 0, 40)
    ToolsTitle.Position = UDim2.new(0, 0, 0, 10)
    ToolsTitle.TextColor3 = Color3.fromRGB(0, 212, 255)
    ToolsTitle.TextSize = 22
    ToolsTitle.Font = Enum.Font.GothamBold
    ToolsTitle.BackgroundTransparency = 1
    ToolsTitle.ZIndex = 16
    ToolsTitle.Parent = MainScreen

    local ButtonsContainer = Instance.new("Frame")
    ButtonsContainer.Size = UDim2.new(1, -20, 1, -60)
    ButtonsContainer.Position = UDim2.new(0, 10, 0, 55)
    ButtonsContainer.BackgroundTransparency = 1
    ButtonsContainer.ZIndex = 16
    ButtonsContainer.Parent = MainScreen

    local ButtonsLayout = Instance.new("UIGridLayout")
    ButtonsLayout.CellSize = UDim2.new(0.48, 0, 0, 60)
    ButtonsLayout.CellPadding = UDim2.new(0.02, 0, 0, 10)
    ButtonsLayout.Parent = ButtonsContainer

    -- دالة إنشاء زر
    local function CreateToolButton(name, icon, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = icon .. " " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = color
        btn.ZIndex = 17
        btn.Parent = ButtonsContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 2
        stroke.Transparency = 0.5
        stroke.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        
        return btn
    end

    -- ═══════════════════════════════
    -- 🎮 أزرار الأدوات
    -- ═══════════════════════════════
    
    -- 1. Game Analyzer
    CreateToolButton("Game Analyzer", "🔍", Color3.fromRGB(138, 43, 226), function()
        if GameAnalyzer then
            StatusLabel.Text = "🔍 Scanning..."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 193, 7)
            
            GameAnalyzer.Scan(nil, function(results)
                StatusLabel.Text = "✅ Found: " .. #results.values .. " values, " .. #results.remotes .. " remotes"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
            end)
        else
            StatusLabel.Text = "❌ GameAnalyzer not loaded"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
        end
    end)

    -- 2. Teleport to Part
    CreateToolButton("Teleport Tool", "📍", Color3.fromRGB(0, 200, 150), function()
        if AdvancedTools and AdvancedTools.Teleporter then
            AdvancedTools.Teleporter.SaveLocation("Saved_" .. tick())
            StatusLabel.Text = "✅ Location saved!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)

    -- 3. Highlight Objects
    CreateToolButton("Highlight Mode", "👁️", Color3.fromRGB(255, 193, 7), function()
        if AdvancedTools and AdvancedTools.Visualizer then
            -- Highlight كل الأجزاء القريبة
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Position - pos).Magnitude < 50 then
                        AdvancedTools.Visualizer.Highlight(part, Color3.fromRGB(255, 255, 0), 3)
                    end
                end
                StatusLabel.Text = "✅ Highlighted nearby parts!"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
            end
        end
    end)

    -- 4. Activator
    CreateToolButton("Auto Activate", "⚡", Color3.fromRGB(255, 100, 150), function()
        if AdvancedTools and AdvancedTools.Activator then
            local found = AdvancedTools.Activator.FindAll(workspace)
            StatusLabel.Text = "✅ Found " .. #found .. " activatable objects"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)

    -- 5. Model Editor
    CreateToolButton("Model Editor", "🧱", Color3.fromRGB(100, 150, 255), function()
        StatusLabel.Text = "🧱 Select a part to edit..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    end)

    -- 6. Clear Effects
    CreateToolButton("Clear Effects", "🧹", Color3.fromRGB(150, 150, 150), function()
        if AdvancedTools and AdvancedTools.Visualizer then
            AdvancedTools.Visualizer.ClearAll()
            StatusLabel.Text = "✅ All effects cleared!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)

    -- ═══════════════════════════════
    -- التحقق من المفتاح
    -- ═══════════════════════════════
    LoginBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if key == "" then
            StatusLabel.Text = "❌ Please enter a key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
            return
        end
        
        LoginBtn.Text = "⏳ Verifying..."
        
        local success, data = false, nil
        if KeySystem and KeySystem.Verify then
            success, data = KeySystem.Verify(key)
        end
        
        if success then
            StatusLabel.Text = "✅ Access Granted!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
            
            task.wait(1)
            
            -- إخفاء شاشة المفتاح وإظهار الشاشة الرئيسية
            KeyScreen.Visible = false
            MainScreen.Visible = true
        else
            StatusLabel.Text = "❌ Invalid Key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
            LoginBtn.Text = "🔓 " .. (Language and Language.Get and Language.Get("Verify") or "VERIFY KEY")
        end
    end)

    -- ═══════════════════════════════
    -- السحب (Drag)
    -- ═══════════════════════════════
    local dragging, dragInput, dragStart, startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
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

    return ScreenGui
end

return MainFrame
