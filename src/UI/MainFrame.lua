local MainFrame = {}

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Security/KeySystem.lua", true))()
local Stars = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Theme/Stars.lua", true))()
local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function MainFrame.Create()
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

    -- النجوم في الخلفية
    Stars.Create(Frame, 100)

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
    Subtitle.Text = Language.Get("Welcome")
    Subtitle.Size = UDim2.new(1, 0, 0, 25)
    Subtitle.Position = UDim2.new(0, 0, 0.28, 0)
    Subtitle.TextColor3 = Color3.fromRGB(150, 170, 200)
    Subtitle.TextSize = 16
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.BackgroundTransparency = 1
    Subtitle.ZIndex = 16
    Subtitle.Parent = KeyScreen

    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = Language.Get("EnterKey")
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
    LoginBtn.Text = "🔓 " .. Language.Get("Verify")
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 55)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.65, 0)
    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    LoginBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 20
    LoginBtn.ZIndex = 16
    LoginBtn.Parent = KeyScreen
    Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 12)

    local LoginGradient = Instance.new("UIGradient")
    LoginGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 245, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 152, 219))
    })
    LoginGradient.Rotation = 90
    LoginGradient.Parent = LoginBtn

    -- ═══════════════════════════════
    -- شاشة المتصفح
    -- ═══════════════════════════════
    local ExplorerScreen = Instance.new("Frame")
    ExplorerScreen.Name = "ExplorerScreen"
    ExplorerScreen.Size = UDim2.new(1, 0, 1, 0)
    ExplorerScreen.BackgroundTransparency = 1
    ExplorerScreen.Visible = false
    ExplorerScreen.ZIndex = 15
    ExplorerScreen.Parent = Content

    -- تحديث اللغة
    LangBtn.MouseButton1Click:Connect(function()
        Language.Toggle()
        LangBtn.Text = Language.Current == "en" and "🌐 عربي" or "🌐 English"
        
        Subtitle.Text = Language.Get("Welcome")
        KeyInput.PlaceholderText = Language.Get("EnterKey")
        LoginBtn.Text = "🔓 " .. Language.Get("Verify")
        
        -- إعادة تحميل المتصفح لو مفتوح
        if ExplorerScreen.Visible then
            ExplorerScreen:ClearAllChildren()
            local Sidebar = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/Sidebar.lua", true))()
            Sidebar.Create(ExplorerScreen)
        end
    end)

    -- التحقق من المفتاح
    LoginBtn.MouseButton1Click:Connect(function()
        LoginBtn.Text = "⏳ " .. Language.Get("Verifying")
        LoginBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
        wait(0.5)
        
        local success, data = KeySystem.Verify(KeyInput.Text)
        
        if success then
            LoginBtn.Text = "✅ " .. Language.Get("Launching")
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            KeyStroke.Color = Color3.fromRGB(0, 255, 136)
            wait(1)
            
            KeyScreen.Visible = false
            ExplorerScreen.Visible = true
            
            local Sidebar = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/Sidebar.lua", true))()
            Sidebar.Create(ExplorerScreen)
        else
            LoginBtn.Text = "❌ " .. Language.Get("Invalid")
            LoginBtn.BackgroundColor3 = Color3.fromRGB(255, 71, 87)
            KeyStroke.Color = Color3.fromRGB(255, 71, 87)
            wait(2)
            LoginBtn.Text = "🔓 " .. Language.Get("Verify")
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
            KeyStroke.Color = Color3.fromRGB(0, 212, 255)
        end
    end)

    -- جعل النافذة قابلة للسحب
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

    print("WiliExplorer Mobile UI Ready!")
    return ScreenGui
end

return MainFrame
