local MainFrame = {}

function MainFrame.Create()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WiliExplorerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- محاولة وضعه في CoreGui
    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local Frame = Instance.new("Frame")
    Frame.Name = "Main"
    Frame.Size = UDim2.new(0, 450, 0, 300)
    Frame.Position = UDim2.new(0.5, -225, 0.5, -150)
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

    local Title = Instance.new("TextLabel")
    Title.Text = "WiliExplorer VIP"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.Parent = Frame

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "Enter your Cosmic Key"
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0, 50)
    SubTitle.TextColor3 = Color3.fromRGB(123, 140, 168)
    SubTitle.TextSize = 14
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.BackgroundTransparency = 1
    SubTitle.Parent = Frame

    local KeyInput = Instance.new("TextBox")
    KeyInput.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    KeyInput.Text = ""
    KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0.45, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(17, 20, 50)
    KeyInput.TextColor3 = Color3.fromRGB(232, 232, 232)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(123, 140, 168)
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 16
    KeyInput.Parent = Frame
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 8)
    KeyCorner.Parent = KeyInput

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Text = "VERIFY KEY"
    LoginBtn.Size = UDim2.new(0.6, 0, 0, 45)
    LoginBtn.Position = UDim2.new(0.2, 0, 0.7, 0)
    LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    LoginBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    LoginBtn.Font = Enum.Font.GothamBold
    LoginBtn.TextSize = 18
    LoginBtn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = LoginBtn

    print("UI Created Successfully!")
    return ScreenGui
end

return MainFrame
