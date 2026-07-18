local Sidebar = {}

local Language = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Utils/Language.lua", true))()

local TweenService = game:GetService("TweenService")

function Sidebar.Create(parent)
    -- ═══════════════════════════════
    -- الهيدر
    -- ═══════════════════════════════
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -20, 0, 70)
    Header.Position = UDim2.new(0, 10, 0, 10)
    Header.BackgroundColor3 = Color3.fromRGB(20, 25, 60)
    Header.BackgroundTransparency = 0.4
    Header.ZIndex = 20
    Header.Parent = parent
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)
    
    local HStroke = Instance.new("UIStroke")
    HStroke.Color = Color3.fromRGB(0, 212, 255)
    HStroke.Thickness = 1
    HStroke.Transparency = 0.6
    HStroke.Parent = Header

    local HTitle = Instance.new("TextLabel")
    HTitle.Size = UDim2.new(1, -20, 0, 30)
    HTitle.Position = UDim2.new(0, 15, 0, 8)
    HTitle.Text = "🌌 " .. Language.Get("Explorer")
    HTitle.TextColor3 = Color3.fromRGB(0, 212, 255)
    HTitle.TextSize = 20
    HTitle.Font = Enum.Font.GothamBold
    HTitle.TextXAlignment = Enum.TextXAlignment.Left
    HTitle.BackgroundTransparency = 1
    HTitle.ZIndex = 21
    HTitle.Parent = Header

    local HSub = Instance.new("TextLabel")
    HSub.Size = UDim2.new(1, -20, 0, 20)
    HSub.Position = UDim2.new(0, 15, 0, 38)
    HSub.Text = Language.Get("SelectService")
    HSub.TextColor3 = Color3.fromRGB(150, 170, 200)
    HSub.TextSize = 13
    HSub.Font = Enum.Font.Gotham
    HSub.TextXAlignment = Enum.TextXAlignment.Left
    HSub.BackgroundTransparency = 1
    HSub.ZIndex = 21
    HSub.Parent = Header

    -- ═══════════════════════════════
    -- قائمة الخدمات (Grid)
    -- ═══════════════════════════════
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -95)
    Scroll.Position = UDim2.new(0, 10, 0, 90)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 6
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Scroll.ZIndex = 20
    Scroll.Parent = parent

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -8, 0, 90)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = Scroll

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)
    Padding.Parent = Scroll

    -- ═══════════════════════════════
    -- دالة إنشاء بطاقة خدمة
    -- ═══════════════════════════════
    local function CreateCard(serviceName, icon, color, order)
        local Card = Instance.new("TextButton")
        Card.Name = serviceName
        Card.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Card.Text = ""
        Card.AutoButtonColor = false
        Card.LayoutOrder = order
        Card.ZIndex = 21
        Card.Parent = Scroll
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 15)

        local CStroke = Instance.new("UIStroke")
        CStroke.Color = color
        CStroke.Thickness = 1.5
        CStroke.Transparency = 0.5
        CStroke.Parent = Card

        -- تدرج
        local CGrad = Instance.new("UIGradient")
        CGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 45))
        })
        CGrad.Rotation = 135
        CGrad.Parent = Card

        -- الأيقونة
        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 0, 40)
        Icon.Position = UDim2.new(0, 0, 0, 10)
        Icon.Text = icon
        Icon.TextSize = 32
        Icon.Font = Enum.Font.GothamBold
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 22
        Icon.Parent = Card

        -- الاسم
        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -10, 0, 20)
        Name.Position = UDim2.new(0, 5, 0, 50)
        Name.Text = Language.Get(serviceName)
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.TextSize = 13
        Name.Font = Enum.Font.GothamBold
        Name.BackgroundTransparency = 1
        Name.TextWrapped = true
        Name.ZIndex = 22
        Name.Parent = Card

        -- عدد العناصر
        local Count = Instance.new("TextLabel")
        Count.Size = UDim2.new(1, -10, 0, 15)
        Count.Position = UDim2.new(0, 5, 1, -20)
        
        local itemCount = 0
        pcall(function()
            local svc = game:GetService(serviceName)
            itemCount = #svc:GetDescendants()
        end)
        
        Count.Text = itemCount .. " " .. Language.Get("Items")
        Count.TextColor3 = color
        Count.TextSize = 11
        Count.Font = Enum.Font.Gotham
        Count.BackgroundTransparency = 1
        Count.ZIndex = 22
        Count.Parent = Card

        -- تأثير Hover
        Card.MouseEnter:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 40, 80)
            }):Play()
            TweenService:Create(CStroke, TweenInfo.new(0.2), {
                Transparency = 0,
                Thickness = 2.5
            }):Play()
        end)
        Card.MouseLeave:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(20, 25, 55)
            }):Play()
            TweenService:Create(CStroke, TweenInfo.new(0.2), {
                Transparency = 0.5,
                Thickness = 1.5
            }):Play()
        end)

       Card.MouseButton1Click:Connect(function()
    TweenService:Create(Card, TweenInfo.new(0.1), {
        Size = UDim2.new(0.5, -12, 0, 86)
    }):Play()
    wait(0.1)
    TweenService:Create(Card, TweenInfo.new(0.1), {
        Size = UDim2.new(0.5, -8, 0, 90)
    }):Play()
    
    -- فتح TreeView
    local service = nil
    pcall(function() service = game:GetService(serviceName) end)
    
    if service then
        parent:ClearAllChildren()
        local TreeView = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/TreeView.lua", true))()
        TreeView.Create(parent, service, function()
            -- عند الضغط على Back
            parent:ClearAllChildren()
            Sidebar.Create(parent)
        end)
    else
        print("Failed to get service: " .. serviceName)
    end
end) 

        return Card
    end

    -- ═══════════════════════════════
    -- إضافة كل الخدمات
    -- ═══════════════════════════════
    local services = {
        {"Workspace", "📂", Color3.fromRGB(255, 200, 50)},
        {"Players", "👥", Color3.fromRGB(100, 200, 255)},
        {"Lighting", "💡", Color3.fromRGB(255, 220, 100)},
        {"ReplicatedStorage", "📦", Color3.fromRGB(150, 100, 255)},
        {"ServerStorage", "🗄️", Color3.fromRGB(200, 100, 200)},
        {"StarterGui", "🎮", Color3.fromRGB(0, 255, 150)},
        {"StarterPack", "🎒", Color3.fromRGB(255, 150, 100)},
        {"StarterPlayer", "🏃", Color3.fromRGB(100, 255, 200)},
        {"Teams", "🚩", Color3.fromRGB(255, 100, 100)},
        {"SoundService", "🔊", Color3.fromRGB(0, 200, 255)},
        {"MaterialService", "🎨", Color3.fromRGB(255, 150, 200)},
        {"Chat", "💬", Color3.fromRGB(150, 255, 150)}
    }

    for i, svc in ipairs(services) do
        CreateCard(svc[1], svc[2], svc[3], i)
    end

    -- تحديث حجم Canvas
    Scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#services / 2) * 100 + 20)
end

return Sidebar
