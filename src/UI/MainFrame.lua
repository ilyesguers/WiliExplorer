local MainFrame = {}

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Security/KeySystem.lua", true))()
local Stars = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Theme/Stars.lua", true))()

function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    
    local success = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not success then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- الإطار الرئيسي (الخزانة الفضائية)
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 600, 0, 400) -- كبرنا الحجم للمتصفح
    Frame.Position = UDim2.new(0.5, -300, 0.5, -200)
    Frame.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 212, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    -- إضافة النجوم
    Stars.Create(Frame, 80)

    -- [1] شاشة المفتاح (KeyScreen)
    local KeyScreen = Instance.new("Frame")
    KeyScreen.Name = "KeyScreen"
    KeyScreen.Size = UDim2.new(1, 0, 1, 0)
    KeyScreen.BackgroundTransparency = 1
    KeyScreen.ZIndex = 10
    KeyScreen.Parent = Frame

    -- [2] شاشة المتصفح (ExplorerScreen) - مخفية في البداية
    local ExplorerScreen = Instance.new("Frame")
    ExplorerScreen.Name = "ExplorerScreen"
    ExplorerScreen.Size = UDim2.new(1, 0, 1, 0)
    ExplorerScreen.BackgroundTransparency = 1
    ExplorerScreen.Visible = false
    ExplorerScreen.ZIndex = 20
    ExplorerScreen.Parent = Frame

    -- نضع كود الـ Key UI داخل KeyScreen (العناوين، الأزرار...)
    local Title = Instance.new("TextLabel")
    Title.Text = "WiliExplorer VIP"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
    Title.TextSize = 30
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Parent = KeyScreen

    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = "ENTER COSMIC KEY"
    KeyInput.Size = UDim2.new(0.7, 0, 0, 45)
    KeyInput.Position = UDim2.new(0.15, 0, 0.4, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 18
    KeyInput.Parent = KeyScreen
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "VERIFY KEY"
    LoginBtn.Size = UDim2.new(0.5, 0, 0, 50)
    LoginBtn.Position = UDim2.new(0.25, 0, 0.6, 0)
    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 20
    LoginBtn.Parent = KeyScreen
    Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 10)

    -- عند النجاح: الانتقال للمتصفح
    LoginBtn.MouseButton1Click:Connect(function()
        local success, data = KeySystem.Verify(KeyInput.Text)
        if success then
            LoginBtn.Text = "LAUNCHING..."
            wait(1)
            KeyScreen.Visible = false
            ExplorerScreen.Visible = true
            -- هنا سنقوم بتحميل متصفح الملفات
            local Sidebar = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/Sidebar.lua", true))()
            Sidebar.Create(ExplorerScreen)
        else
            LoginBtn.Text = "INVALID KEY"
            wait(1)
            LoginBtn.Text = "VERIFY KEY"
        end
    end)

    return ScreenGui
end

return MainFrame
