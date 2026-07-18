local MainFrame = {}

local Colors = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Theme/Colors.lua"))()
local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Icons.lua"))()

function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.Parent = game:GetService("CoreGui") -- لضمان عدم حذفه بسهولة
    ScreenGui.ResetOnSpawn = false

    -- النافذة الرئيسية
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 450, 0, 300)
    Frame.Position = UDim2.new(0.5, -225, 0.5, -150)
    Frame.BackgroundColor3 = Colors.BG_Primary
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    -- جعل الزوايا دائرية (Rounded Corners)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Frame

    -- إضافة التوهج السماوي (Border Glow)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Accent
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = Frame

    -- العنوان
    local Title = Instance.new("TextLabel")
    Title.Text = Icons.Logo .. " WiliExplorer VIP"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Colors.Accent
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Parent = Frame

    -- رسالة الترحيب
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Enter your Cosmic Key to access WiliExplorer"
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0, 50)
    SubTitle.TextColor3 = Colors.TextSecondary
    SubTitle.TextSize = 14
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.BackgroundTransparency = 1
    SubTitle.Parent = Frame

    -- صندوق إدخال المفتاح (TextBox)
    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0.45, 0)
    KeyInput.BackgroundColor3 = Colors.BG_Secondary
    KeyInput.TextColor3 = Colors.TextPrimary
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 16
    KeyInput.Parent = Frame
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 8)
    KeyCorner.Parent = KeyInput

    -- زر الدخول
    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "VERIFY KEY"
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 45)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.7, 0)
    LoginBtn.BackgroundColor3 = Colors.Accent
    LoginBtn.TextColor3 = Colors.BG_Primary
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 18
    LoginBtn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = LoginBtn

    print("🌌 UI Created Successfully!")
    return ScreenGui
end

return MainFrame
