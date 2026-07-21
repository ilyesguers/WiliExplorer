--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔑 WiliExplorer - Key Screen v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ شاشة إدخال المفتاح
    ✅ تحقق من المفتاح
    ✅ أنيميشن ظهور
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local KeyScreen = {}

-- Services
local TweenService = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════════════════
-- 🔑 إنشاء شاشة المفتاح
-- ═══════════════════════════════════════════════════════════════════════
function KeyScreen.Create(parent, onVerified)
    local screen = Instance.new("Frame")
    screen.Name = "KeyScreen"
    screen.Size = UDim2.new(1, 0, 1, 0)
    screen.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    screen.Parent = parent
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0.2, 0)
    title.Text = "🔑 Enter Key"
    title.TextColor3 = Color3.fromRGB(0, 212, 255)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBlack
    title.BackgroundTransparency = 1
    title.Parent = screen
    
    -- حقل الإدخال
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.8, 0, 0, 50)
    input.Position = UDim2.new(0.1, 0, 0.4, 0)
    input.PlaceholderText = "Enter your key..."
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Code
    input.TextSize = 18
    input.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    input.Parent = screen
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 12)
    
    -- زر التحقق
    local verifyBtn = Instance.new("TextButton")
    verifyBtn.Size = UDim2.new(0.6, 0, 0, 50)
    verifyBtn.Position = UDim2.new(0.2, 0, 0.55, 0)
    verifyBtn.Text = "🔓 Verify"
    verifyBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 18
    verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    verifyBtn.Parent = screen
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 12)
    
    verifyBtn.MouseButton1Click:Connect(function()
        if onVerified then
            onVerified(input.Text)
        end
    end)
    
    return screen
end

print("🔑 Key Screen v1.0 Loaded!")

return KeyScreen
