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
    -- قائمة الخدمات (Scroll)
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

    -- ═══════════════════════════════
    -- زر Smart Analyzer الكبير (فوق كل شيء)
    -- ═══════════════════════════════
    local AnalyzerCard = Instance.new("TextButton")
    AnalyzerCard.Name = "SmartAnalyzer"
    AnalyzerCard.Size = UDim2.new(1, -10, 0, 100)
    AnalyzerCard.Position = UDim2.new(0, 5, 0, 5)
    AnalyzerCard.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    AnalyzerCard.Text = ""
    AnalyzerCard.AutoButtonColor = false
    AnalyzerCard.ZIndex = 22
    AnalyzerCard.Parent = Scroll
    Instance.new("UICorner", AnalyzerCard).CornerRadius = UDim.new(0, 15)
    
    -- تدرج ذهبي
    local AGrad = Instance.new("UIGradient")
    AGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 50))
    })
    AGrad.Rotation = 135
    AGrad.Parent = AnalyzerCard
    
    -- Stroke متوهج
    local AStroke = Instance.new("UIStroke")
    AStroke.Color = Color3.fromRGB(255, 255, 255)
    AStroke.Thickness = 2
    AStroke.Transparency = 0.5
    AStroke.Parent = AnalyzerCard
    
    -- توهج نبضي
    spawn(function()
        while AnalyzerCard.Parent do
            TweenService:Create(AStroke, TweenInfo.new(1.5), {Thickness = 4, Transparency = 0.2}):Play()
            wait(1.5)
            TweenService:Create(AStroke, TweenInfo.new(1.5), {Thickness = 2, Transparency = 0.5}):Play()
            wait(1.5)
        end
    end)
    
    local AIcon = Instance.new("TextLabel")
    AIcon.Size = UDim2.new(0, 60, 0, 60)
    AIcon.Position = UDim2.new(0, 15, 0.5, -30)
    AIcon.Text = "🧠"
    AIcon.TextSize = 42
    AIcon.BackgroundTransparency = 1
    AIcon.ZIndex = 23
    AIcon.Parent = AnalyzerCard
    
    local AName = Instance.new("TextLabel")
    AName.Size = UDim2.new(1, -90, 0, 28)
    AName.Position = UDim2.new(0, 80, 0, 15)
    AName.Text = "SMART ANALYZER"
    AName.TextColor3 = Color3.fromRGB(11, 13, 26)
    AName.TextSize = 20
    AName.Font = Enum.Font.GothamBold
    AName.TextXAlignment = Enum.TextXAlignment.Left
    AName.BackgroundTransparency = 1
    AName.ZIndex = 23
    AName.Parent = AnalyzerCard
    
    local ADesc = Instance.new("TextLabel")
    ADesc.Size = UDim2.new(1, -90, 0, 20)
    ADesc.Position = UDim2.new(0, 80, 0, 42)
    ADesc.Text = "🔍 Scan game automatically"
    ADesc.TextColor3 = Color3.fromRGB(50, 40, 20)
    ADesc.TextSize = 12
    ADesc.Font = Enum.Font.GothamBold
    ADesc.TextXAlignment = Enum.TextXAlignment.Left
    ADesc.BackgroundTransparency = 1
    ADesc.ZIndex = 23
    ADesc.Parent = AnalyzerCard
    
    local ABadge = Instance.new("TextLabel")
    ABadge.Size = UDim2.new(0, 50, 0, 18)
    ABadge.Position = UDim2.new(1, -60, 0, 65)
    ABadge.Text = "AI"
    ABadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    ABadge.TextSize = 12
    ABadge.Font = Enum.Font.GothamBold
    ABadge.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
    ABadge.ZIndex = 24
    ABadge.Parent = AnalyzerCard
    Instance.new("UICorner", ABadge).CornerRadius = UDim.new(0, 6)
    
    AnalyzerCard.MouseEnter:Connect(function()
        TweenService:Create(AnalyzerCard, TweenInfo.new(0.2), {Size = UDim2.new(1, -5, 0, 105)}):Play()
    end)
    AnalyzerCard.MouseLeave:Connect(function()
        TweenService:Create(AnalyzerCard, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 100)}):Play()
    end)
    
    AnalyzerCard.MouseButton1Click:Connect(function()
        TweenService:Create(AnalyzerCard, TweenInfo.new(0.1), {Size = UDim2.new(1, -15, 0, 95)}):Play()
        wait(0.1)
        TweenService:Create(AnalyzerCard, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 100)}):Play()
        
        local success, SmartMenu = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/SmartMenu.lua", true))()
        end)
        
        if success and SmartMenu then
            SmartMenu.Open(parent.Parent)
        else
            warn("Failed to load SmartMenu")
        end
    end)

    -- ═══════════════════════════════
    -- فاصل + عنوان "Services"
    -- ═══════════════════════════════
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -10, 0, 35)
    Divider.Position = UDim2.new(0, 5, 0, 115)
    Divider.BackgroundTransparency = 1
    Divider.ZIndex = 22
    Divider.Parent = Scroll
    
    local DLine = Instance.new("Frame")
    DLine.Size = UDim2.new(0.3, 0, 0, 1)
    DLine.Position = UDim2.new(0, 0, 0.5, 0)
    DLine.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    DLine.BackgroundTransparency = 0.5
    DLine.BorderSizePixel = 0
    DLine.ZIndex = 23
    DLine.Parent = Divider
    
    local DText = Instance.new("TextLabel")
    DText.Size = UDim2.new(0.4, 0, 1, 0)
    DText.Position = UDim2.new(0.3, 0, 0, 0)
    DText.Text = "📁 GAME SERVICES"
    DText.TextColor3 = Color3.fromRGB(0, 212, 255)
    DText.TextSize = 12
    DText.Font = Enum.Font.GothamBold
    DText.BackgroundTransparency = 1
    DText.ZIndex = 23
    DText.Parent = Divider
    
    local DLine2 = Instance.new("Frame")
    DLine2.Size = UDim2.new(0.3, 0, 0, 1)
    DLine2.Position = UDim2.new(0.7, 0, 0.5, 0)
    DLine2.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
    DLine2.BackgroundTransparency = 0.5
    DLine2.BorderSizePixel = 0
    DLine2.ZIndex = 23
    DLine2.Parent = Divider

    -- ═══════════════════════════════
    -- Grid للخدمات
    -- ═══════════════════════════════
    local ServicesFrame = Instance.new("Frame")
    ServicesFrame.Size = UDim2.new(1, -10, 0, 700)
    ServicesFrame.Position = UDim2.new(0, 5, 0, 155)
    ServicesFrame.BackgroundTransparency = 1
    ServicesFrame.ZIndex = 20
    ServicesFrame.Parent = Scroll

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -8, 0, 90)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = ServicesFrame

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
        Card.Parent = ServicesFrame
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 15)

        local CStroke = Instance.new("UIStroke")
        CStroke.Color = color
        CStroke.Thickness = 1.5
        CStroke.Transparency = 0.5
        CStroke.Parent = Card

        local CGrad = Instance.new("UIGradient")
        CGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 45))
        })
        CGrad.Rotation = 135
        CGrad.Parent = Card

        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(1, 0, 0, 40)
        Icon.Position = UDim2.new(0, 0, 0, 10)
        Icon.Text = icon
        Icon.TextSize = 32
        Icon.Font = Enum.Font.GothamBold
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 22
        Icon.Parent = Card

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
            
            local service = nil
            pcall(function() service = game:GetService(serviceName) end)
            
            if service then
                parent:ClearAllChildren()
                local TreeView = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/TreeView.lua", true))()
                TreeView.Create(parent, service, function()
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
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 155 + math.ceil(#services / 2) * 100 + 40)
end

return Sidebar
