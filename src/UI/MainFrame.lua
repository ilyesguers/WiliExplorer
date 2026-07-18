local MainFrame = {}

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Security/KeySystem.lua", true))()

function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- الإطار الرئيسي
    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 450, 0, 350)
    Frame.Position = UDim2.new(0.5, -225, 0.5, -175)
    Frame.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 212, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Frame

    -- العنوان
    local Title = Instance.new("TextLabel")
    Title.Text = "WiliExplorer VIP"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Parent = Frame

    -- النص الفرعي
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Enter your Cosmic Key"
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0, 50)
    SubTitle.TextColor3 = Color3.fromRGB(123, 140, 168)
    SubTitle.TextSize = 14
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.BackgroundTransparency = 1
    SubTitle.Parent = Frame

    -- صندوق المفتاح
    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = "WILI-XXXX-XXXX-XXXX"
    KeyInput.Text = ""
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0.35, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(17, 20, 50)
    KeyInput.TextColor3 = Color3.fromRGB(232, 232, 232)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(123, 140, 168)
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 16
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = Frame
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 8)
    KeyCorner.Parent = KeyInput

    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Color3.fromRGB(0, 212, 255)
    KeyStroke.Thickness = 1
    KeyStroke.Transparency = 0.5
    KeyStroke.Parent = KeyInput

    -- زر التحقق
    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "VERIFY KEY"
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 45)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.55, 0)
    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    LoginBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 18
    LoginBtn.AutoButtonColor = true
    LoginBtn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = LoginBtn

    -- رسالة الحالة (خطأ/نجاح)
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = ""
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    StatusLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Parent = Frame

    -- معلومات الخطة (تظهر عند النجاح)
    local PlanLabel = Instance.new("TextLabel")
    PlanLabel.Text = ""
    PlanLabel.Size = UDim2.new(1, 0, 0, 20)
    PlanLabel.Position = UDim2.new(0, 0, 0.85, 0)
    PlanLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
    PlanLabel.TextSize = 12
    PlanLabel.Font = Enum.Font.Gotham
    PlanLabel.BackgroundTransparency = 1
    PlanLabel.Parent = Frame

    -- منطق زر التحقق
    LoginBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        StatusLabel.Text = "Verifying..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
        PlanLabel.Text = ""
        
        wait(0.5)
        
        local success, data = KeySystem.Verify(key)
        
        if success then
            StatusLabel.Text = "Key Verified Successfully!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
            PlanLabel.Text = "Plan: " .. data.plan .. " | Owner: " .. data.owner
            
            KeyStroke.Color = Color3.fromRGB(0, 255, 136)
            LoginBtn.Text = "LAUNCHING..."
            LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            
            wait(2)
            
            -- سيتم فتح متصفح الملفات هنا لاحقاً
            StatusLabel.Text = "File Explorer coming next!"
        else
            StatusLabel.Text = "Error: " .. tostring(data)
            StatusLabel.TextColor3 = Color3.fromRGB(255, 71, 87)
            KeyStroke.Color = Color3.fromRGB(255, 71, 87)
            
            wait(2)
            KeyStroke.Color = Color3.fromRGB(0, 212, 255)
            StatusLabel.Text = ""
        end
    end)

    print("UI Created Successfully!")
    return ScreenGui
end

return MainFrame
