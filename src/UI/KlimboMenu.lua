--[[
    WiliExplorer Developer Console v6
    A responsive, self-contained diagnostics workspace. No third-party scripts,
    metatable hooks, remote firing, or client-only actions presented as server tools.
]]

local KlimboMenu = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local function Module(name)
    return _G.WiliModules and _G.WiliModules[name] or nil
end

local fallback = {
    Canvas = Color3.fromRGB(7, 10, 20), Surface = Color3.fromRGB(13, 18, 34),
    Raised = Color3.fromRGB(20, 27, 49), Hover = Color3.fromRGB(29, 39, 68),
    Border = Color3.fromRGB(47, 61, 91), Text = Color3.fromRGB(242, 247, 255),
    Muted = Color3.fromRGB(150, 168, 197), Accent = Color3.fromRGB(55, 211, 255),
    Purple = Color3.fromRGB(153, 107, 255), Green = Color3.fromRGB(55, 218, 142),
    Yellow = Color3.fromRGB(255, 190, 76), Red = Color3.fromRGB(255, 91, 115)
}

local copy = {
    ar = {
        title = "وحدة المطوّر", subtitle = "فحص، أداء، وإعدادات في مكان واحد",
        overview = "نظرة عامة", inspect = "الفحص", performance = "الأداء", settings = "الإعدادات",
        quick = "إجراءات سريعة", scan = "بدء فحص آمن", cancel = "إلغاء الفحص", clear = "مسح النتائج",
        scanning = "جارٍ الفحص", ready = "جاهز", complete = "اكتمل الفحص", selected = "العنصر المحدد",
        noSelection = "اختر نتيجة لعرض تفاصيلها", copyPath = "نسخ المسار", openExplorer = "فتح المستكشف",
        search = "ابحث بالاسم أو النوع أو المسار…", all = "الكل", scripts = "سكريبتات",
        models = "مجسمات", images = "صور", sounds = "أصوات", values = "قيم", remotes = "اتصالات",
        objects = "العناصر", players = "اللاعبون", memory = "الذاكرة", fps = "الإطارات",
        ping = "الاستجابة", uptime = "مدة الجلسة", device = "وضع الجهاز", mobile = "هاتف", desktop = "كمبيوتر",
        power = "توفير الطاقة", powerDesc = "يقلل معدل تحديث القياسات والمؤثرات",
        motion = "الحركة", motionDesc = "حركات انتقال خفيفة للواجهة", language = "اللغة",
        batch = "حجم دفعة الفحص", batchDesc = "القيمة الأصغر أكثر سلاسة على الهاتف",
        limit = "حد العناصر", limitDesc = "يمنع استهلاك ذاكرة غير محدود", activity = "النشاط",
        localNotice = "أدوات الفحص محلية وتعرض ما يستطيع العميل قراءته فقط.",
        scanStopped = "تم إيقاف الفحص", pathCopied = "تم نسخ المسار", unavailable = "غير متاح"
    },
    en = {
        title = "Developer Console", subtitle = "Inspection, performance, and settings in one place",
        overview = "Overview", inspect = "Inspect", performance = "Performance", settings = "Settings",
        quick = "Quick actions", scan = "Start safe scan", cancel = "Cancel scan", clear = "Clear results",
        scanning = "Scanning", ready = "Ready", complete = "Scan complete", selected = "Selected item",
        noSelection = "Select a result to view its details", copyPath = "Copy path", openExplorer = "Open Explorer",
        search = "Search by name, class, or path…", all = "All", scripts = "Scripts", models = "Models",
        images = "Images", sounds = "Sounds", values = "Values", remotes = "Connections",
        objects = "Objects", players = "Players", memory = "Memory", fps = "FPS", ping = "Latency",
        uptime = "Session", device = "Device mode", mobile = "Mobile", desktop = "Desktop",
        power = "Power saver", powerDesc = "Reduces metrics refresh rate and visual effects",
        motion = "Motion", motionDesc = "Use lightweight interface transitions", language = "Language",
        batch = "Scan batch size", batchDesc = "Smaller values stay smoother on mobile",
        limit = "Object limit", limitDesc = "Prevents unbounded memory use", activity = "Activity",
        localNotice = "Inspection is local and only reports data readable by the client.",
        scanStopped = "Scan stopped", pathCopied = "Path copied", unavailable = "Unavailable"
    }
}

function KlimboMenu.Create(parent)
    if not parent then return nil end
    local Language = Module("Language")
    local Design = Module("DesignSystem")
    local Notifications = Module("Notifications")
    local SaveSystem = Module("SaveSystem")
    local Colors = Module("Colors")
    local theme = Colors and Colors.Current or nil
    local C = {
        Canvas = theme and theme.BG_Primary or fallback.Canvas,
        Surface = theme and theme.BG_Secondary or fallback.Surface,
        Raised = theme and theme.BG_Card or fallback.Raised,
        Hover = theme and theme.BG_CardHover or fallback.Hover,
        Border = theme and theme.Border or fallback.Border,
        Text = theme and theme.Text_Primary or fallback.Text,
        Muted = theme and theme.Text_Secondary or fallback.Muted,
        Accent = theme and theme.Accent or fallback.Accent,
        Purple = theme and theme.Purple or fallback.Purple,
        Green = theme and theme.Success or fallback.Green,
        Yellow = theme and theme.Warning or fallback.Yellow,
        Red = theme and theme.Error or fallback.Red
    }

    local function languageCode()
        return Language and Language.Current or (_G.WiliLanguage or "ar")
    end
    local function T(key)
        return (copy[languageCode()] or copy.en)[key] or key
    end

    local connections, jobs, translated = {}, {}, {}
    local Main
    local destroyed, scanToken = false, 0
    local savedPowerMode = SaveSystem and SaveSystem.Get("powerSaver", "auto") or "auto"
    local settings = {
        powerSaver = savedPowerMode == "auto" and UserInputService.TouchEnabled or savedPowerMode == true,
        motion = SaveSystem and SaveSystem.Get("animationsEnabled", true) or true,
        batchSize = SaveSystem and SaveSystem.Get("scanBatchSize", UserInputService.TouchEnabled and 80 or 180) or 100,
        objectLimit = SaveSystem and SaveSystem.Get("scanObjectLimit", 15000) or 15000
    }
    local scan = {running = false, processed = 0, results = {}, counts = {}}
    local selected, activeType, activeTab = nil, "all", "overview"

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
    local function corner(object, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius or 10)
        value.Parent = object
        return value
    end
    local function stroke(object, color, transparency)
        local value = Instance.new("UIStroke")
        value.Color = color or C.Border
        value.Thickness = 1
        value.Transparency = transparency or 0
        value.Parent = object
        return value
    end
    local function tween(object, properties)
        if not object or not object.Parent then return end
        if settings.motion then
            TweenService:Create(object, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
        else
            for property, value in pairs(properties) do object[property] = value end
        end
    end
    local function translate(label, key, prefix)
        table.insert(translated, {label = label, key = key, prefix = prefix or ""})
        label.Text = (prefix or "") .. T(key)
    end
    local function refreshLanguage()
        for _, item in ipairs(translated) do
            if item.label and item.label.Parent then item.label.Text = item.prefix .. T(item.key) end
        end
        if Language and Language.Apply then Language.Apply(Main) end
    end
    local function notify(message, kind)
        if Notifications then
            local method = Notifications[kind or "Info"] or Notifications.Info
            if method then pcall(method, message, "WiliExplorer", 2) return end
        end
        print("[WiliExplorer] " .. tostring(message))
    end
    local function save(key, value)
        if SaveSystem and SaveSystem.Set then SaveSystem.Set(key, value) end
    end
    local function safePath(instance)
        local ok, result = pcall(function() return instance:GetFullName() end)
        return ok and result or instance.Name
    end
    local function copyText(text)
        local ok = pcall(function()
            if setclipboard then setclipboard(text)
            elseif toclipboard then toclipboard(text)
            else error("clipboard unavailable") end
        end)
        notify(ok and T("pathCopied") or T("unavailable"), ok and "Success" or "Warning")
    end

    Main = Instance.new("Frame")
    Main.Name = "DeveloperConsole"
    Main.Size = UDim2.fromScale(1, 1)
    Main.BackgroundColor3 = C.Canvas
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = parent

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 64)
    Header.BackgroundColor3 = C.Surface
    Header.BorderSizePixel = 0
    Header.Parent = Main
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = C.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = Header

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(1, -190, 0, 26)
    logo.Position = UDim2.new(0, 16, 0, 8)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = C.Text
    logo.TextSize = 18
    logo.Font = Enum.Font.GothamBold
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = Header
    translate(logo, "title", "◈  ")

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -190, 0, 17)
    subtitle.Position = UDim2.new(0, 17, 0, 36)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = C.Muted
    subtitle.TextSize = 11
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    subtitle.Parent = Header
    translate(subtitle, "subtitle")

    local headerActions = Instance.new("Frame")
    headerActions.Size = UDim2.new(0, 156, 0, 44)
    headerActions.Position = UDim2.new(1, -164, 0, 10)
    headerActions.BackgroundTransparency = 1
    headerActions.Parent = Header
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.Padding = UDim.new(0, 6)
    headerLayout.Parent = headerActions

    local function iconButton(text, color, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 44, 0, 44)
        button.BackgroundColor3 = color or C.Raised
        button.Text = text
        button.TextColor3 = C.Text
        button.TextSize = 15
        button.Font = Enum.Font.GothamBold
        button.AutoButtonColor = false
        button.Parent = headerActions
        corner(button, 11)
        connect(button.MouseEnter, function() tween(button, {BackgroundColor3 = C.Hover}) end)
        connect(button.MouseLeave, function() tween(button, {BackgroundColor3 = color or C.Raised}) end)
        connect(button.MouseButton1Click, callback)
        return button
    end

    local languageButton
    languageButton = iconButton(languageCode() == "ar" and "EN" or "AR", C.Raised, function()
        if Language and Language.Toggle then Language.Toggle() else
            _G.WiliLanguage = languageCode() == "ar" and "en" or "ar"
        end
        languageButton.Text = languageCode() == "ar" and "EN" or "AR"
        refreshLanguage()
    end)
    local powerButton
    powerButton = iconButton(settings.powerSaver and "◒" or "◉", C.Raised, function()
        settings.powerSaver = not settings.powerSaver
        powerButton.Text = settings.powerSaver and "◒" or "◉"
        save("powerSaver", settings.powerSaver)
        notify(T("power"), "Info")
    end)
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Size = UDim2.new(1, -24, 0, 48)
    TabBar.Position = UDim2.new(0, 12, 0, 72)
    TabBar.BackgroundTransparency = 1
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.Parent = Main
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = TabBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -24, 1, -132)
    Content.Position = UDim2.new(0, 12, 0, 124)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local pages, tabButtons = {}, {}
    local renderResults, updateOverview, updateSelected

    local function page(name)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = name
        frame.Size = UDim2.fromScale(1, 1)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 3
        frame.ScrollBarImageColor3 = C.Accent
        frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        frame.CanvasSize = UDim2.new()
        frame.Visible = false
        frame.Parent = Content
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = frame
        local padding = Instance.new("UIPadding")
        padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 2), UDim.new(0, 12)
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 2), UDim.new(0, 5)
        padding.Parent = frame
        pages[name] = frame
        return frame
    end

    local function selectTab(name)
        activeTab = name
        for id, frame in pairs(pages) do frame.Visible = id == name end
        for id, button in pairs(tabButtons) do
            tween(button, {BackgroundColor3 = id == name and C.Accent or C.Raised})
            button.TextColor3 = id == name and C.Canvas or C.Text
        end
        if name == "inspect" and renderResults then renderResults() end
    end

    local function tab(name, key, icon)
        local button = Instance.new("TextButton")
        button.AutomaticSize = Enum.AutomaticSize.X
        button.Size = UDim2.new(0, 0, 0, 42)
        button.BackgroundColor3 = C.Raised
        button.TextColor3 = C.Text
        button.TextSize = 12
        button.Font = Enum.Font.GothamBold
        button.Parent = TabBar
        corner(button, 10)
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 16), UDim.new(0, 16)
        padding.Parent = button
        translate(button, key, icon .. "  ")
        tabButtons[name] = button
        connect(button.MouseButton1Click, function() selectTab(name) end)
    end

    local function section(parentFrame, key)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.TextColor3 = C.Muted
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parentFrame
        translate(label, key)
        return label
    end

    local function button(parentFrame, key, icon, color, callback)
        local value = Instance.new("TextButton")
        value.Size = UDim2.new(1, -4, 0, 48)
        value.BackgroundColor3 = C.Raised
        value.TextColor3 = C.Text
        value.TextSize = 13
        value.Font = Enum.Font.GothamBold
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.AutoButtonColor = false
        value.Parent = parentFrame
        corner(value, 11)
        stroke(value, C.Border, 0.3)
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 15), UDim.new(0, 15)
        padding.Parent = value
        translate(value, key, icon .. "   ")
        connect(value.MouseEnter, function() tween(value, {BackgroundColor3 = C.Hover}) end)
        connect(value.MouseLeave, function() tween(value, {BackgroundColor3 = C.Raised}) end)
        connect(value.MouseButton1Click, callback)
        return value
    end

    local Overview = page("overview")
    local Inspect = page("inspect")
    local Performance = page("performance")
    local Settings = page("settings")
    tab("overview", "overview", "⌂")
    tab("inspect", "inspect", "⌕")
    tab("performance", "performance", "⌁")
    tab("settings", "settings", "⚙")

    local hero = Instance.new("Frame")
    hero.Size = UDim2.new(1, -4, 0, 94)
    hero.BackgroundColor3 = C.Surface
    hero.Parent = Overview
    corner(hero, 14)
    stroke(hero, C.Border, 0.25)
    local gameTitle = Instance.new("TextLabel")
    gameTitle.Size = UDim2.new(1, -28, 0, 28)
    gameTitle.Position = UDim2.new(0, 14, 0, 14)
    gameTitle.BackgroundTransparency = 1
    gameTitle.Text = "Experience"
    gameTitle.TextColor3 = C.Text
    gameTitle.TextSize = 17
    gameTitle.Font = Enum.Font.GothamBold
    gameTitle.TextXAlignment = Enum.TextXAlignment.Left
    gameTitle.TextTruncate = Enum.TextTruncate.AtEnd
    gameTitle.Parent = hero
    local gameMeta = Instance.new("TextLabel")
    gameMeta.Size = UDim2.new(1, -28, 0, 36)
    gameMeta.Position = UDim2.new(0, 14, 0, 47)
    gameMeta.BackgroundTransparency = 1
    gameMeta.TextColor3 = C.Muted
    gameMeta.TextSize = 11
    gameMeta.Font = Enum.Font.Gotham
    gameMeta.TextXAlignment = Enum.TextXAlignment.Left
    gameMeta.TextWrapped = true
    gameMeta.Parent = hero
    task.spawn(function()
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
        if destroyed then return end
        gameTitle.Text = ok and info and info.Name or "Experience " .. tostring(game.PlaceId)
        gameMeta.Text = "Place " .. tostring(game.PlaceId) .. "  •  " .. T(UserInputService.TouchEnabled and "mobile" or "desktop")
    end)

    local statsGrid = Instance.new("Frame")
    statsGrid.Size = UDim2.new(1, -4, 0, 86)
    statsGrid.BackgroundTransparency = 1
    statsGrid.Parent = Overview
    local grid = Instance.new("UIGridLayout")
    grid.CellPadding = UDim2.new(0, 8, 0, 8)
    grid.CellSize = UDim2.new(0.25, -7, 1, 0)
    grid.Parent = statsGrid
    local overviewValues = {}
    local function statCard(key, icon, color)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = C.Raised
        card.Parent = statsGrid
        corner(card, 11)
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -12, 0, 25)
        name.Position = UDim2.new(0, 8, 0, 7)
        name.BackgroundTransparency = 1
        name.TextColor3 = C.Muted
        name.TextSize = 10
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card
        translate(name, key, icon .. "  ")
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, -16, 0, 36)
        value.Position = UDim2.new(0, 8, 0, 36)
        value.BackgroundTransparency = 1
        value.Text = "0"
        value.TextColor3 = color
        value.TextSize = 20
        value.Font = Enum.Font.GothamBold
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.Parent = card
        overviewValues[key] = value
    end
    statCard("objects", "◇", C.Accent)
    statCard("scripts", "⌘", C.Green)
    statCard("images", "▧", C.Purple)
    statCard("sounds", "♫", C.Yellow)

    section(Overview, "quick")
    button(Overview, "scan", "⌕", C.Accent, function() selectTab("inspect") task.defer(function() if not scan.running then jobs.startScan() end end) end)
    local notice = Instance.new("TextLabel")
    notice.Size = UDim2.new(1, -4, 0, 48)
    notice.BackgroundColor3 = C.Surface
    notice.TextColor3 = C.Muted
    notice.TextSize = 11
    notice.Font = Enum.Font.Gotham
    notice.TextWrapped = true
    notice.Parent = Overview
    corner(notice, 10)
    translate(notice, "localNotice", "i  ")

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -4, 0, 46)
    searchBox.BackgroundColor3 = C.Surface
    searchBox.TextColor3 = C.Text
    searchBox.PlaceholderColor3 = C.Muted
    searchBox.TextSize = 13
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Text = ""
    searchBox.Parent = Inspect
    corner(searchBox, 11)
    stroke(searchBox, C.Border, 0.2)
    local searchPadding = Instance.new("UIPadding")
    searchPadding.PaddingLeft, searchPadding.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
    searchPadding.Parent = searchBox
    searchBox.PlaceholderText = T("search")

    local filterBar = Instance.new("ScrollingFrame")
    filterBar.Size = UDim2.new(1, -4, 0, 40)
    filterBar.BackgroundTransparency = 1
    filterBar.BorderSizePixel = 0
    filterBar.ScrollBarThickness = 0
    filterBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    filterBar.ScrollingDirection = Enum.ScrollingDirection.X
    filterBar.Parent = Inspect
    local filterLayout = Instance.new("UIListLayout")
    filterLayout.FillDirection = Enum.FillDirection.Horizontal
    filterLayout.Padding = UDim.new(0, 6)
    filterLayout.Parent = filterBar
    local filterButtons = {}
    local filterData = {{"all","●"},{"scripts","⌘"},{"models","◆"},{"images","▧"},{"sounds","♫"},{"values","#"},{"remotes","↯"}}

    local scanStatus = Instance.new("Frame")
    scanStatus.Size = UDim2.new(1, -4, 0, 54)
    scanStatus.BackgroundColor3 = C.Surface
    scanStatus.Parent = Inspect
    corner(scanStatus, 10)
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -118, 0, 23)
    statusText.Position = UDim2.new(0, 12, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.Text = T("ready")
    statusText.TextColor3 = C.Text
    statusText.TextSize = 11
    statusText.Font = Enum.Font.GothamBold
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = scanStatus
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(0, 100, 0, 23)
    progressText.Position = UDim2.new(1, -110, 0, 5)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0"
    progressText.TextColor3 = C.Accent
    progressText.TextSize = 11
    progressText.Font = Enum.Font.GothamBold
    progressText.TextXAlignment = Enum.TextXAlignment.Right
    progressText.Parent = scanStatus
    local progressBG = Instance.new("Frame")
    progressBG.Size = UDim2.new(1, -24, 0, 7)
    progressBG.Position = UDim2.new(0, 12, 0, 36)
    progressBG.BackgroundColor3 = C.Raised
    progressBG.BorderSizePixel = 0
    progressBG.Parent = scanStatus
    corner(progressBG, 4)
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = C.Accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBG
    corner(progressFill, 4)

    local actionRow = Instance.new("Frame")
    actionRow.Size = UDim2.new(1, -4, 0, 48)
    actionRow.BackgroundTransparency = 1
    actionRow.Parent = Inspect
    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 8)
    actionLayout.Parent = actionRow
    local function smallAction(key, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.333, -6, 0, 44)
        b.BackgroundColor3 = color
        b.TextColor3 = C.Text
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.Parent = actionRow
        corner(b, 10)
        translate(b, key)
        connect(b.MouseButton1Click, callback)
        return b
    end

    local resultsFrame = Instance.new("Frame")
    resultsFrame.Size = UDim2.new(1, -4, 0, 0)
    resultsFrame.AutomaticSize = Enum.AutomaticSize.Y
    resultsFrame.BackgroundTransparency = 1
    resultsFrame.Parent = Inspect
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.Padding = UDim.new(0, 6)
    resultsLayout.Parent = resultsFrame

    local selectedCard = Instance.new("Frame")
    selectedCard.Size = UDim2.new(1, -4, 0, 104)
    selectedCard.BackgroundColor3 = C.Surface
    selectedCard.Parent = Inspect
    corner(selectedCard, 11)
    stroke(selectedCard, C.Border, 0.25)
    local selectedTitle = Instance.new("TextLabel")
    selectedTitle.Size = UDim2.new(1, -24, 0, 24)
    selectedTitle.Position = UDim2.new(0, 12, 0, 9)
    selectedTitle.BackgroundTransparency = 1
    selectedTitle.Text = T("selected")
    selectedTitle.TextColor3 = C.Muted
    selectedTitle.TextSize = 10
    selectedTitle.Font = Enum.Font.GothamBold
    selectedTitle.TextXAlignment = Enum.TextXAlignment.Left
    selectedTitle.Parent = selectedCard
    local selectedInfo = Instance.new("TextLabel")
    selectedInfo.Size = UDim2.new(1, -24, 0, 56)
    selectedInfo.Position = UDim2.new(0, 12, 0, 36)
    selectedInfo.BackgroundTransparency = 1
    selectedInfo.Text = T("noSelection")
    selectedInfo.TextColor3 = C.Text
    selectedInfo.TextSize = 11
    selectedInfo.Font = Enum.Font.Gotham
    selectedInfo.TextXAlignment = Enum.TextXAlignment.Left
    selectedInfo.TextYAlignment = Enum.TextYAlignment.Top
    selectedInfo.TextWrapped = true
    selectedInfo.Parent = selectedCard

    local function classify(instance)
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then return "scripts", "⌘" end
        if instance:IsA("Model") or instance:IsA("BasePart") then return "models", "◆" end
        if instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then return "images", "▧" end
        if instance:IsA("Sound") then return "sounds", "♫" end
        if instance:IsA("ValueBase") then return "values", "#" end
        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") or instance:IsA("BindableEvent") or instance:IsA("BindableFunction") then return "remotes", "↯" end
        return "objects", "◇"
    end

    updateSelected = function()
        if not selected or not selected.instance or not selected.instance.Parent then
            selectedInfo.Text = T("noSelection")
            return
        end
        selectedInfo.Text = selected.name .. "  •  " .. selected.className .. "\n" .. selected.path
    end

    renderResults = function()
        for _, child in ipairs(resultsFrame:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
        local query = searchBox.Text:lower():match("^%s*(.-)%s*$")
        local shown = 0
        for _, item in ipairs(scan.results) do
            local matchesType = activeType == "all" or item.category == activeType
            local matchesQuery = query == "" or item.name:lower():find(query, 1, true) or item.className:lower():find(query, 1, true) or item.path:lower():find(query, 1, true)
            if matchesType and matchesQuery and shown < 120 then
                shown = shown + 1
                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, 0, 0, 50)
                row.BackgroundColor3 = C.Raised
                row.Text = item.icon .. "   " .. item.name .. "\n      " .. item.className
                row.TextColor3 = C.Text
                row.TextSize = 11
                row.Font = Enum.Font.Gotham
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.AutoButtonColor = false
                row.Parent = resultsFrame
                corner(row, 9)
                local rp = Instance.new("UIPadding")
                rp.PaddingLeft, rp.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
                rp.Parent = row
                connect(row.MouseButton1Click, function() selected = item updateSelected() end)
            end
        end
    end

    for _, data in ipairs(filterData) do
        local id, icon = data[1], data[2]
        local filter = Instance.new("TextButton")
        filter.AutomaticSize = Enum.AutomaticSize.X
        filter.Size = UDim2.new(0, 0, 0, 34)
        filter.BackgroundColor3 = id == "all" and C.Accent or C.Raised
        filter.TextColor3 = id == "all" and C.Canvas or C.Text
        filter.TextSize = 10
        filter.Font = Enum.Font.GothamBold
        filter.Parent = filterBar
        corner(filter, 9)
        local fp = Instance.new("UIPadding")
        fp.PaddingLeft, fp.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
        fp.Parent = filter
        translate(filter, id, icon .. "  ")
        filterButtons[id] = filter
        connect(filter.MouseButton1Click, function()
            activeType = id
            for filterId, other in pairs(filterButtons) do
                other.BackgroundColor3 = filterId == id and C.Accent or C.Raised
                other.TextColor3 = filterId == id and C.Canvas or C.Text
            end
            renderResults()
        end)
    end
    connect(searchBox:GetPropertyChangedSignal("Text"), renderResults)

    updateOverview = function()
        overviewValues.objects.Text = tostring(scan.processed)
        overviewValues.scripts.Text = tostring(scan.counts.scripts or 0)
        overviewValues.images.Text = tostring(scan.counts.images or 0)
        overviewValues.sounds.Text = tostring(scan.counts.sounds or 0)
    end

    local function finishScan(cancelled)
        scan.running = false
        statusText.Text = cancelled and T("scanStopped") or T("complete")
        progressFill.Size = UDim2.new(1, 0, 1, 0)
        updateOverview()
        renderResults()
        notify(statusText.Text, cancelled and "Warning" or "Success")
    end

    jobs.startScan = function()
        if scan.running then return end
        scanToken = scanToken + 1
        local token = scanToken
        scan = {running = true, processed = 0, results = {}, counts = {}}
        selected = nil
        updateSelected()
        statusText.Text = T("scanning")
        progressText.Text = "0"
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        task.spawn(function()
            local queue = game:GetChildren()
            -- DFS stack keeps only the active frontier instead of retaining every visited item.
            while #queue > 0 and scan.processed < settings.objectLimit and token == scanToken and not destroyed do
                for _ = 1, settings.batchSize do
                    local instance = table.remove(queue)
                    if not instance or scan.processed >= settings.objectLimit then break end
                    if instance.Parent then
                        scan.processed = scan.processed + 1
                        local category, icon = classify(instance)
                        scan.counts[category] = (scan.counts[category] or 0) + 1
                        if category ~= "objects" then
                            table.insert(scan.results, {instance = instance, name = instance.Name, className = instance.ClassName, path = safePath(instance), category = category, icon = icon})
                        end
                        local ok, children = pcall(function() return instance:GetChildren() end)
                        if ok then for _, child in ipairs(children) do table.insert(queue, child) end end
                    end
                end
                progressText.Text = tostring(scan.processed) .. " / " .. tostring(settings.objectLimit)
                progressFill.Size = UDim2.new(math.min(scan.processed / settings.objectLimit, 1), 0, 1, 0)
                task.wait(settings.powerSaver and 0.03 or 0)
            end
            table.clear(queue)
            if token ~= scanToken or destroyed then return end
            finishScan(false)
        end)
    end
    local function cancelScan()
        if scan.running then scanToken = scanToken + 1 finishScan(true) end
    end
    local function clearResults()
        cancelScan()
        scan = {running = false, processed = 0, results = {}, counts = {}}
        selected = nil
        progressText.Text = "0"
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        statusText.Text = T("ready")
        updateOverview(); updateSelected(); renderResults()
    end
    smallAction("scan", C.Accent, jobs.startScan)
    smallAction("cancel", C.Yellow, cancelScan)
    smallAction("clear", C.Red, clearResults)
    button(Inspect, "copyPath", "⧉", C.Raised, function() if selected then copyText(selected.path) end end)

    local metrics = {}
    section(Performance, "performance")
    local metricKeys = {{"fps","⌁",C.Green},{"memory","▤",C.Purple},{"ping","↔",C.Accent},{"uptime","◷",C.Yellow}}
    for _, data in ipairs(metricKeys) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 66)
        card.BackgroundColor3 = C.Raised
        card.Parent = Performance
        corner(card, 11)
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.6, -14, 1, 0)
        name.Position = UDim2.new(0, 14, 0, 0)
        name.BackgroundTransparency = 1
        name.TextColor3 = C.Text
        name.TextSize = 12
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card
        translate(name, data[1], data[2] .. "  ")
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(0.4, -14, 1, 0)
        value.Position = UDim2.new(0.6, 0, 0, 0)
        value.BackgroundTransparency = 1
        value.Text = "—"
        value.TextColor3 = data[3]
        value.TextSize = 18
        value.Font = Enum.Font.GothamBold
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Parent = card
        metrics[data[1]] = value
    end

    local heartbeatFrames, heartbeatElapsed, lastMetrics = 0, 0, 0
    connect(RunService.Heartbeat, function(delta)
        heartbeatFrames = heartbeatFrames + 1
        heartbeatElapsed = heartbeatElapsed + delta
        local interval = settings.powerSaver and 2 or 0.75
        if tick() - lastMetrics < interval then return end
        lastMetrics = tick()
        local fps = heartbeatElapsed > 0 and math.floor(heartbeatFrames / heartbeatElapsed + 0.5) or 0
        heartbeatFrames, heartbeatElapsed = 0, 0
        metrics.fps.Text = tostring(fps)
        local memory = 0
        pcall(function() memory = Stats:GetTotalMemoryUsageMb() end)
        metrics.memory.Text = string.format("%.0f MB", memory)
        local ping = "—"
        pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
        metrics.ping.Text = ping
        local seconds = math.floor(workspace.DistributedGameTime)
        metrics.uptime.Text = string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
    end)

    section(Settings, "settings")
    local function toggleSetting(key, descriptionKey, getter, setter)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(1, -4, 0, 70)
        card.BackgroundColor3 = C.Raised
        card.Text = ""
        card.Parent = Settings
        corner(card, 11)
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -86, 0, 25)
        name.Position = UDim2.new(0, 14, 0, 9)
        name.BackgroundTransparency = 1
        name.TextColor3 = C.Text
        name.TextSize = 12
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card
        translate(name, key)
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, -86, 0, 24)
        description.Position = UDim2.new(0, 14, 0, 36)
        description.BackgroundTransparency = 1
        description.TextColor3 = C.Muted
        description.TextSize = 10
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.Parent = card
        translate(description, descriptionKey)
        local state = Instance.new("TextLabel")
        state.Size = UDim2.new(0, 54, 0, 30)
        state.Position = UDim2.new(1, -68, 0.5, -15)
        state.BackgroundColor3 = getter() and C.Green or C.Border
        state.Text = getter() and "ON" or "OFF"
        state.TextColor3 = C.Canvas
        state.TextSize = 10
        state.Font = Enum.Font.GothamBold
        state.Parent = card
        corner(state, 15)
        connect(card.MouseButton1Click, function()
            local value = not getter()
            setter(value)
            state.Text = value and "ON" or "OFF"
            tween(state, {BackgroundColor3 = value and C.Green or C.Border})
        end)
    end
    toggleSetting("power", "powerDesc", function() return settings.powerSaver end, function(value) settings.powerSaver = value powerButton.Text = value and "◒" or "◉" save("powerSaver", value) end)
    toggleSetting("motion", "motionDesc", function() return settings.motion end, function(value) settings.motion = value save("animationsEnabled", value) end)
    button(Settings, "language", "文", C.Raised, function()
        if Language and Language.Toggle then Language.Toggle() else
            _G.WiliLanguage = languageCode() == "ar" and "en" or "ar"
        end
        languageButton.Text = languageCode() == "ar" and "EN" or "AR"
        refreshLanguage()
        searchBox.PlaceholderText = T("search")
        updateSelected()
    end)

    local function sliderSetting(key, descriptionKey, minimum, maximum, getter, setter)
        section(Settings, key)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -4, 0, 72)
        frame.BackgroundColor3 = C.Raised
        frame.Parent = Settings
        corner(frame, 11)
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(0.72, -14, 0, 28)
        description.Position = UDim2.new(0, 14, 0, 7)
        description.BackgroundTransparency = 1
        description.TextColor3 = C.Muted
        description.TextSize = 10
        description.Font = Enum.Font.Gotham
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.Parent = frame
        translate(description, descriptionKey)
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0.28, -14, 0, 28)
        valueText.Position = UDim2.new(0.72, 0, 0, 7)
        valueText.BackgroundTransparency = 1
        valueText.Text = tostring(getter())
        valueText.TextColor3 = C.Accent
        valueText.TextSize = 12
        valueText.Font = Enum.Font.GothamBold
        valueText.TextXAlignment = Enum.TextXAlignment.Right
        valueText.Parent = frame
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -28, 0, 10)
        bar.Position = UDim2.new(0, 14, 0, 50)
        bar.BackgroundColor3 = C.Border
        bar.Parent = frame
        corner(bar, 5)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - minimum) / (maximum - minimum), 0, 1, 0)
        fill.BackgroundColor3 = C.Accent
        fill.Parent = bar
        corner(fill, 5)
        local dragging = false
        local function update(input)
            local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local value = math.floor(minimum + (maximum - minimum) * ratio + 0.5)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valueText.Text = tostring(value)
            setter(value)
        end
        connect(bar.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true update(input) end
        end)
        connect(UserInputService.InputChanged, function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
        end)
        connect(UserInputService.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false save(key == "batch" and "scanBatchSize" or "scanObjectLimit", getter()) end
        end)
    end
    sliderSetting("batch", "batchDesc", 25, 400, function() return settings.batchSize end, function(v) settings.batchSize = v end)
    sliderSetting("limit", "limitDesc", 1000, 50000, function() return settings.objectLimit end, function(v) settings.objectLimit = v end)

    local function responsive()
        local width = Main.AbsoluteSize.X
        local compact = width < 580
        Header.Size = UDim2.new(1, 0, 0, compact and 60 or 64)
        logo.Size = UDim2.new(1, compact and -158 or -190, 0, 26)
        subtitle.Visible = not compact
        headerActions.Size = UDim2.new(0, compact and 144 or 156, 0, 44)
        headerActions.Position = UDim2.new(1, compact and -150 or -164, 0, 8)
        TabBar.Position = UDim2.new(0, 8, 0, compact and 64 or 72)
        TabBar.Size = UDim2.new(1, -16, 0, 48)
        Content.Position = UDim2.new(0, 8, 0, compact and 114 or 124)
        Content.Size = UDim2.new(1, -16, 1, compact and -120 or -132)
        grid.CellSize = compact and UDim2.new(0.5, -4, 0, 78) or UDim2.new(0.25, -7, 1, 0)
        statsGrid.Size = compact and UDim2.new(1, -4, 0, 166) or UDim2.new(1, -4, 0, 86)
    end
    connect(Main:GetPropertyChangedSignal("AbsoluteSize"), responsive)
    responsive()
    selectTab("overview")
    updateOverview()

    function KlimboMenu.Destroy()
        if destroyed then return end
        destroyed = true
        scanToken = scanToken + 1
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        table.clear(connections)
    end
    connect(Main.Destroying, KlimboMenu.Destroy)

    return Main
end

return KlimboMenu
