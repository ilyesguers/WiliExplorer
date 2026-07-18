local Sidebar = {}

local Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Icons.lua", true))()

function Sidebar.Create(parent)
    local Container = Instance.new("Frame")
    Container.Name = "Sidebar"
    Container.Size = UDim2.new(0.35, 0, 1, 0) -- يأخذ 35% من العرض
    Container.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    Container.BackgroundTransparency = 0.3
    Container.Parent = parent
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 2, 1, 0)
    Line.Position = UDim2.new(1, 0, 0, 0)
    Line.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    Line.BorderSizePixel = 0
    Line.Parent = Container

    local Title = Instance.new("TextLabel")
    Title.Text = " COSMIC EXPLORER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.TextColor3 = Color3.fromRGB(0, 212, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    Title.Parent = Container

    -- قائمة الملفات القابلة للتمرير (ScrollingFrame)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -10, 1, -50)
    Scroll.Position = UDim2.new(0, 5, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Scroll.Parent = Container

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 5)
    Layout.Parent = Scroll

    -- دالة لإضافة عنصر للقائمة
    local function AddItem(name, icon, isFolder)
        local Item = Instance.new("TextButton")
        Item.Size = UDim2.new(1, 0, 0, 30)
        Item.BackgroundColor3 = Color3.fromRGB(30, 35, 70)
        Item.BackgroundTransparency = 0.6
        Item.Text = "  " .. icon .. "  " .. name
        Item.TextColor3 = Color3.fromRGB(200, 200, 255)
        Item.TextSize = 14
        Item.Font = Enum.Font.Gotham
        Item.TextXAlignment = Enum.TextXAlignment.Left
        Item.Parent = Scroll
        
        Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 5)
        
        Item.MouseButton1Click:Connect(function()
            print("Selected: " .. name)
            -- سنضيف لاحقاً فتح المجلدات
        end)
    end

    -- عرض الخدمات الأساسية للماب كبداية
    local services = {
        {"Workspace", "📂"},
        {"Players", "👥"},
        {"Lighting", "💡"},
        {"ReplicatedStorage", "📦"},
        {"ServerStorage", "🗄️"},
        {"StarterGui", "🎮"},
        {"Teams", "🚩"}
    }

    for _, v in pairs(services) do
        AddItem(v[1], v[2], true)
    end
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

return Sidebar
