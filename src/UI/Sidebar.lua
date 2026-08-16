local Sidebar = {}

local function GetModule(name)
    local module = _G.WiliModules and _G.WiliModules[name]
    if not module then error("Sidebar dependency missing: " .. name) end
    return module
end

local function theme()
    local C = GetModule("Colors").Current
    return {
        Canvas = C.BG_Primary, Surface = C.BG_Card, Hover = C.BG_CardHover,
        Border = C.Border, Text = C.Text_Primary, Muted = C.Text_Secondary,
        Accent = C.Accent, Success = C.Success, Purple = C.Purple,
        Warning = C.Warning
    }
end

function Sidebar.Create(parent)
    local Language = GetModule("Language")
    local UI = GetModule("UIHelpers")
    local Assets = GetModule("Assets")
    local C = theme()

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -20, 0, 72)
    Header.Position = UDim2.new(0, 10, 0, 10)
    Header.BackgroundColor3 = C.Surface
    Header.BorderSizePixel = 0
    Header.Parent = parent
    UI.Corner(Header, 13)
    UI.Stroke(Header, C.Border, 0.2)

    local logoImage = Instance.new("ImageLabel")
    logoImage.Size = UDim2.new(0, 44, 0, 44)
    logoImage.Position = UDim2.new(0, 12, 0.5, -22)
    logoImage.BackgroundTransparency = 1
    logoImage.Parent = Header
    local hasLogo, logoFallback = Assets.Get("Explorer")
    if hasLogo then logoImage.Image = hasLogo else logoImage.Visible = false end

    local LogoFallback = Instance.new("TextLabel")
    LogoFallback.Size = logoImage.Size
    LogoFallback.Position = logoImage.Position
    LogoFallback.BackgroundTransparency = 1
    LogoFallback.Text = logoFallback or "⌘"
    LogoFallback.TextColor3 = C.Accent
    LogoFallback.TextSize = 25
    LogoFallback.Visible = not hasLogo
    LogoFallback.Parent = Header

    local titleOffset = 64
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -titleOffset - 10, 0, 28)
    Title.Position = UDim2.new(0, titleOffset, 0, 9)
    Title.BackgroundTransparency = 1
    Title.Text = Language.Get("Explorer")
    Title.TextColor3 = C.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Language.Alignment()
    Title.Parent = Header

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -titleOffset - 10, 0, 20)
    Subtitle.Position = UDim2.new(0, titleOffset, 0, 39)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = Language.Get("SelectService")
    Subtitle.TextColor3 = C.Muted
    Subtitle.TextSize = 11
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Language.Alignment()
    Subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    Subtitle.Parent = Header

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -98)
    Scroll.Position = UDim2.new(0, 10, 0, 90)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = C.Accent
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.CanvasSize = UDim2.new()
    Scroll.Parent = parent

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll
    local Padding = Instance.new("UIPadding")
    Padding.PaddingBottom = UDim.new(0, 14)
    Padding.PaddingLeft = UDim.new(0, 2)
    Padding.PaddingRight = UDim.new(0, 5)
    Padding.Parent = Scroll

    local function safeNavigate(moduleName, callback)
        local ok, err = pcall(function()
            local module = GetModule(moduleName)
            callback(module)
        end)
        if not ok then UI.Notify(Language.Get("NavigationFailed") .. ": " .. tostring(err), "Error") end
    end

    -- A single analysis entry point replaces the removed duplicate analyzer pages.
    local Analysis = Instance.new("TextButton")
    Analysis.Name = "UnifiedAnalysis"
    Analysis.Size = UDim2.new(1, -2, 0, 92)
    Analysis.LayoutOrder = 1
    Analysis.BackgroundColor3 = C.Surface
    Analysis.Text = ""
    Analysis.AutoButtonColor = false
    Analysis.Parent = Scroll
    UI.Corner(Analysis, 14)
    UI.Stroke(Analysis, C.Purple, 0.15, 2)

    local analysisImage = Instance.new("ImageLabel")
    analysisImage.Size = UDim2.new(0, 52, 0, 52)
    analysisImage.Position = UDim2.new(0, 14, 0.5, -26)
    analysisImage.BackgroundTransparency = 1
    analysisImage.Parent = Analysis
    local devAsset, devFallback = Assets.Get("Developer")
    if devAsset then analysisImage.Image = devAsset else analysisImage.Visible = false end

    local analysisIcon = Instance.new("TextLabel")
    analysisIcon.Size = analysisImage.Size
    analysisIcon.Position = analysisImage.Position
    analysisIcon.BackgroundTransparency = 1
    analysisIcon.Text = devFallback or "⌁"
    analysisIcon.TextColor3 = C.Purple
    analysisIcon.TextSize = 30
    analysisIcon.Visible = not devAsset
    analysisIcon.Parent = Analysis

    local AnalysisTitle = Instance.new("TextLabel")
    AnalysisTitle.Size = UDim2.new(1, -92, 0, 26)
    AnalysisTitle.Position = UDim2.new(0, 78, 0, 17)
    AnalysisTitle.BackgroundTransparency = 1
    AnalysisTitle.Text = Language.Get("AnalysisWorkspace")
    AnalysisTitle.TextColor3 = C.Text
    AnalysisTitle.TextSize = 16
    AnalysisTitle.Font = Enum.Font.GothamBold
    AnalysisTitle.TextXAlignment = Language.Alignment()
    AnalysisTitle.Parent = Analysis

    local AnalysisDescription = Instance.new("TextLabel")
    AnalysisDescription.Size = UDim2.new(1, -92, 0, 30)
    AnalysisDescription.Position = UDim2.new(0, 78, 0, 47)
    AnalysisDescription.BackgroundTransparency = 1
    AnalysisDescription.Text = Language.Get("AnalysisWorkspaceDescription")
    AnalysisDescription.TextColor3 = C.Muted
    AnalysisDescription.TextSize = 10
    AnalysisDescription.Font = Enum.Font.Gotham
    AnalysisDescription.TextXAlignment = Language.Alignment()
    AnalysisDescription.TextWrapped = true
    AnalysisDescription.Parent = Analysis

    Analysis.MouseEnter:Connect(function() UI.Tween(Analysis, {BackgroundColor3 = C.Hover}) end)
    Analysis.MouseLeave:Connect(function() UI.Tween(Analysis, {BackgroundColor3 = C.Surface}) end)
    Analysis.MouseButton1Click:Connect(function()
        safeNavigate("AnalyzerUI", function(AnalyzerUI)
            parent:ClearAllChildren()
            AnalyzerUI.Create(parent, function() parent:ClearAllChildren() Sidebar.Create(parent) end)
        end)
    end)

    local ServicesTitle = Instance.new("TextLabel")
    ServicesTitle.Size = UDim2.new(1, -2, 0, 34)
    ServicesTitle.LayoutOrder = 2
    ServicesTitle.BackgroundTransparency = 1
    ServicesTitle.Text = Language.Get("GameServices")
    ServicesTitle.TextColor3 = C.Accent
    ServicesTitle.TextSize = 12
    ServicesTitle.Font = Enum.Font.GothamBold
    ServicesTitle.TextXAlignment = Language.Alignment()
    ServicesTitle.Parent = Scroll

    local ServicesGrid = Instance.new("Frame")
    ServicesGrid.Name = "ServicesGrid"
    ServicesGrid.Size = UDim2.new(1, -2, 0, 0)
    ServicesGrid.AutomaticSize = Enum.AutomaticSize.Y
    ServicesGrid.LayoutOrder = 3
    ServicesGrid.BackgroundTransparency = 1
    ServicesGrid.Parent = Scroll

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.5, -5, 0, 92)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.SortOrder = Enum.SortOrder.LayoutOrder
    Grid.Parent = ServicesGrid

    local services = {
        {"Workspace", "▰", C.Warning}, {"Players", "●", C.Accent},
        {"Lighting", "☼", C.Warning}, {"ReplicatedStorage", "◇", C.Purple},
        {"ServerStorage", "▤", C.Muted}, {"StarterGui", "▣", C.Success},
        {"StarterPack", "▧", C.Warning}, {"StarterPlayer", "◉", C.Success},
        {"Teams", "⚑", C.Warning}, {"SoundService", "♫", C.Accent},
        {"MaterialService", "◆", C.Purple}, {"Chat", "◌", C.Success}
    }

    local function serviceCard(data, index)
        local serviceName, icon, accent = data[1], data[2], data[3]
        local Card = Instance.new("TextButton")
        Card.Name = serviceName
        Card.LayoutOrder = index
        Card.BackgroundColor3 = C.Surface
        Card.Text = ""
        Card.AutoButtonColor = false
        Card.Parent = ServicesGrid
        UI.Corner(Card, 12)
        local CardStroke = UI.Stroke(Card, accent, 0.5)

        local Icon = Instance.new("TextLabel")
        Icon.Size = UDim2.new(0, 42, 0, 42)
        Icon.Position = UDim2.new(0, 10, 0, 10)
        Icon.BackgroundTransparency = 1
        Icon.Text = icon
        Icon.TextColor3 = accent
        Icon.TextSize = 24
        Icon.Parent = Card

        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -64, 0, 35)
        Name.Position = UDim2.new(0, 58, 0, 12)
        Name.BackgroundTransparency = 1
        Name.Text = Language.Get(serviceName)
        Name.TextColor3 = C.Text
        Name.TextSize = 11
        Name.Font = Enum.Font.GothamBold
        Name.TextWrapped = true
        Name.TextXAlignment = Language.Alignment()
        Name.Parent = Card

        local Count = Instance.new("TextLabel")
        Count.Size = UDim2.new(1, -20, 0, 20)
        Count.Position = UDim2.new(0, 10, 1, -27)
        Count.BackgroundTransparency = 1
        Count.TextColor3 = C.Muted
        Count.TextSize = 10
        Count.Font = Enum.Font.Gotham
        Count.TextXAlignment = Language.Alignment()
        Count.Parent = Card
        local service
        pcall(function() service = game:GetService(serviceName) end)
        local childCount = service and #service:GetChildren() or 0
        Count.Text = tostring(childCount) .. " " .. Language.Get("DirectItems")

        Card.MouseEnter:Connect(function() UI.Tween(Card, {BackgroundColor3 = C.Hover}); UI.Tween(CardStroke, {Transparency = 0.1}) end)
        Card.MouseLeave:Connect(function() UI.Tween(Card, {BackgroundColor3 = C.Surface}); UI.Tween(CardStroke, {Transparency = 0.5}) end)
        Card.MouseButton1Click:Connect(function()
            if not service then UI.Notify(Language.Get("ServiceUnavailable"), "Warning") return end
            safeNavigate("TreeView", function(TreeView)
                parent:ClearAllChildren()
                TreeView.Create(parent, service, function() parent:ClearAllChildren() Sidebar.Create(parent) end)
            end)
        end)
    end

    for index, data in ipairs(services) do serviceCard(data, index) end
    if Language.Apply then Language.Apply(parent) end
end

return Sidebar
