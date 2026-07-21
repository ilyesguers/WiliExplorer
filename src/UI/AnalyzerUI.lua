--[[
    ═══════════════════════════════════════════════════════════════════════════
    🔬 WiliExplorer - Analyzer UI v3.0 (Complete Rewrite)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ يعمل مع GameAnalyzer v3.0 الجديد
    ✅ يعرض كل النتائج بشكل جميل
    ✅ أزرار أكشن لكل عنصر
    ✅ تabs للتصنيفات
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local AnalyzerUI = {}

-- Services
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local C = {
    BG = Color3.fromRGB(8, 8, 18),
    BG2 = Color3.fromRGB(12, 12, 28),
    BG3 = Color3.fromRGB(18, 18, 38),
    Card = Color3.fromRGB(15, 15, 32),
    CardHover = Color3.fromRGB(22, 22, 45),
    Accent = Color3.fromRGB(0, 212, 255),
    Gold = Color3.fromRGB(255, 215, 0),
    Green = Color3.fromRGB(0, 255, 100),
    Red = Color3.fromRGB(255, 50, 50),
    Orange = Color3.fromRGB(255, 165, 0),
    Purple = Color3.fromRGB(138, 43, 226),
    Pink = Color3.fromRGB(255, 0, 128),
    Cyan = Color3.fromRGB(0, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 170, 200),
    Border = Color3.fromRGB(40, 40, 70)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), props):Play()
end

local function Notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🔬 Analyzer",
            Text = message,
            Duration = 2
        })
    end)
end

local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text) end
        if toclipboard then toclipboard(text) end
    end)
end

local function FormatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then return string.format("%.1fK", n/1000)
    else return tostring(n) end
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function AddStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.Parent = parent
    return s
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔬 الواجهة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════
function AnalyzerUI.Create(parent, onBack)
    -- تحميل GameAnalyzer
    local GameAnalyzer = nil
    local ok = pcall(function()
        GameAnalyzer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/GameAnalyzer.lua", true))()
    end)
    
    if not ok or not GameAnalyzer then
        -- محاولة تحميل من الذاكرة
        if _G.WiliModules and _G.WiliModules.GameAnalyzer then
            GameAnalyzer = _G.WiliModules.GameAnalyzer
        else
            warn("❌ Failed to load GameAnalyzer!")
            return
        end
    end
    
    -- ═══ النافذة الرئيسية ═══
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "AnalyzerUI"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = C.BG
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 10
    MainFrame.Parent = parent
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.BG),
        ColorSequenceKeypoint.new(0.5, C.BG2),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 10, 35))
    })
    Gradient.Rotation = 135
    Gradient.Parent = MainFrame

    -- ═══ الشريط العلوي ═══
    local ToolBar = Instance.new("Frame")
    ToolBar.Size = UDim2.new(1, 0, 0, 50)
    ToolBar.BackgroundColor3 = C.BG2
    ToolBar.BackgroundTransparency = 0.2
    ToolBar.BorderSizePixel = 0
    ToolBar.ZIndex = 20
    ToolBar.Parent = MainFrame
    
    local ToolBarLine = Instance.new("Frame")
    ToolBarLine.Size = UDim2.new(1, 0, 0, 2)
    ToolBarLine.Position = UDim2.new(0, 0, 1, -2)
    ToolBarLine.BackgroundColor3 = C.Accent
    ToolBarLine.BorderSizePixel = 0
    ToolBarLine.ZIndex = 21
    ToolBarLine.Parent = ToolBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.Text = "🔬 GAME ANALYZER"
    Title.TextColor3 = C.Accent
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 21
    Title.Parent = ToolBar

    -- زر الرجوع
    local BackBtn = Instance.new("TextButton")
    BackBtn.Size = UDim2.new(0, 75, 0, 32)
    BackBtn.Position = UDim2.new(1, -165, 0.5, -16)
    BackBtn.Text = "◀ Back"
    BackBtn.TextColor3 = C.Text
    BackBtn.TextSize = 12
    BackBtn.Font = Enum.Font.GothamBold
    BackBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 100)
    BackBtn.ZIndex = 21
    BackBtn.Parent = ToolBar
    AddCorner(BackBtn, 8)
    
    BackBtn.MouseButton1Click:Connect(function()
        parent:ClearAllChildren()
        if onBack then onBack() end
    end)
    
    -- زر Scan
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0, 75, 0, 32)
    ScanBtn.Position = UDim2.new(1, -82, 0.5, -16)
    ScanBtn.Text = "🔍 Scan"
    ScanBtn.TextColor3 = C.BG
    ScanBtn.TextSize = 12
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.BackgroundColor3 = C.Accent
    ScanBtn.ZIndex = 21
    ScanBtn.Parent = ToolBar
    AddCorner(ScanBtn, 8)

    -- ═══ التabs ═══
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -16, 0, 28)
    TabBar.Position = UDim2.new(0, 8, 0, 54)
    TabBar.BackgroundTransparency = 1
    TabBar.ZIndex = 20
    TabBar.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.Parent = TabBar

    -- ═══ منطقة المحتوى ═══
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -16, 1, -90)
    Content.Position = UDim2.new(0, 8, 0, 85)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 15
    Content.Parent = MainFrame

    -- ═══ المتغيرات ═══
    local pages = {}
    local tabButtons = {}
    local scanResults = nil
    local isScanning = false

    -- ═══ دوال إنشاء العناصر ═══
    local function CreateTab(name, icon, color, count)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 1, 0)
        btn.Text = icon .. " " .. tostring(count or 0)
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = C.Card
        btn.ZIndex = 21
        btn.Parent = TabBar
        AddCorner(btn, 6)
        
        local stroke = AddStroke(btn, color, 1, 0.6)
        
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = color
        page.Visible = false
        page.ZIndex = 16
        page.Parent = Content
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 4)
        pageLayout.Parent = page
        
        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingLeft = UDim.new(0, 2)
        pagePad.PaddingRight = UDim.new(0, 2)
        pagePad.PaddingTop = UDim.new(0, 2)
        pagePad.PaddingBottom = UDim.new(0, 8)
        pagePad.Parent = page
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        pages[name] = page
        tabButtons[name] = {btn = btn, stroke = stroke, color = color}
        
        btn.MouseButton1Click:Connect(function()
            for n, p in pairs(pages) do p.Visible = (n == name) end
            for n, d in pairs(tabButtons) do
                d.btn.BackgroundColor3 = (n == name) and d.color or C.Card
                d.btn.TextColor3 = (n == name) and C.BG or C.Text
                d.stroke.Transparency = (n == name) and 0 or 0.6
            end
        end)
        
        return page
    end
    
    local function CreateItemCard(page, item, itemType)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -4, 0, 48)
        card.BackgroundColor3 = C.Card
        card.ZIndex = 17
        card.Parent = page
        AddCorner(card, 8)
        
        local cardStroke = AddStroke(card, C.Border, 1, 0.5)
        
        -- الأيقونة
        local typeIcon = Instance.new("TextLabel")
        typeIcon.Size = UDim2.new(0, 28, 0, 28)
        typeIcon.Position = UDim2.new(0, 5, 0.5, -14)
        typeIcon.TextSize = 14
        typeIcon.BackgroundTransparency = 1
        typeIcon.ZIndex = 18
        typeIcon.Parent = card
        
        -- الاسم
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(0.4, 0, 0, 16)
        nameLbl.Position = UDim2.new(0, 36, 0, 4)
        nameLbl.TextColor3 = C.Text
        nameLbl.TextSize = 10
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.BackgroundTransparency = 1
        nameLbl.ZIndex = 18
        nameLbl.Parent = card
        
        -- المسار/المعلومات
        local infoLbl = Instance.new("TextLabel")
        infoLbl.Size = UDim2.new(0.4, 0, 0, 12)
        infoLbl.Position = UDim2.new(0, 36, 0, 22)
        infoLbl.TextColor3 = C.TextDim
        infoLbl.TextSize = 8
        infoLbl.Font = Enum.Font.Gotham
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        infoLbl.TextTruncate = Enum.TextTruncate.AtEnd
        infoLbl.BackgroundTransparency = 1
        infoLbl.ZIndex = 18
        infoLbl.Parent = card
        
        -- شارة الحالة
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 50, 0, 16)
        badge.Position = UDim2.new(0.45, 5, 0.5, -8)
        badge.TextSize = 7
        badge.Font = Enum.Font.GothamBold
        badge.TextColor3 = C.BG
        badge.ZIndex = 18
        badge.Parent = card
        AddCorner(badge, 4)
        
        -- دالة إنشاء زر أكشن
        local function ActionBtn(text, posX, color, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 40, 0, 18)
            btn.Position = UDim2.new(0.65, posX, 0.5, -9)
            btn.Text = text
            btn.TextColor3 = C.Text
            btn.TextSize = 7
            btn.Font = Enum.Font.GothamBold
            btn.BackgroundColor3 = color
            btn.ZIndex = 18
            btn.Parent = card
            AddCorner(btn, 4)
            
            btn.MouseButton1Click:Connect(callback)
            return btn
        end
        
        -- ═══ تعبئة حسب النوع ═══
        if itemType == "script" then
            typeIcon.Text = item.className == "LocalScript" and "📱" or item.className == "ModuleScript" and "📦" or "📜"
            nameLbl.Text = item.name
            infoLbl.Text = item.path
            
            if item.isSensitive then
                badge.Text = item.severity:upper()
                badge.BackgroundColor3 = item.severity == "critical" and C.Red or item.severity == "high" and C.Orange or C.Gold
                cardStroke.Color = badge.BackgroundColor3
            elseif item.readable then
                badge.Text = item.editable and "EDIT" or "READ"
                badge.BackgroundColor3 = item.editable and C.Green or C.Accent
            else
                badge.Text = "LOCKED"
                badge.BackgroundColor3 = Color3.fromRGB(100, 100, 130)
            end
            
            if item.readable then
                ActionBtn("👁️", 0, C.Accent, function()
                    local source = ""
                    pcall(function() source = item.instance.Source or "" end)
                    CopyToClipboard(source)
                    Notify("تم نسخ الكود! (" .. #source .. " chars)")
                end)
            end
            
            ActionBtn("📋", 45, Color3.fromRGB(60, 70, 110), function()
                CopyToClipboard(item.path)
                Notify("تم نسخ المسار!")
            end)
            
        elseif itemType == "sound" then
            typeIcon.Text = "🔊"
            nameLbl.Text = item.name
            infoLbl.Text = item.soundId ~= "" and item.soundId or item.path
            
            badge.Text = item.isPlaying and "▶ PLAY" or "STOP"
            badge.BackgroundColor3 = item.isPlaying and C.Green or Color3.fromRGB(100, 100, 130)
            
            ActionBtn("▶", 0, C.Green, function()
                pcall(function()
                    if item.instance.IsPlaying then
                        item.instance:Stop()
                        badge.Text = "STOP"
                        badge.BackgroundColor3 = Color3.fromRGB(100, 100, 130)
                    else
                        item.instance:Play()
                        badge.Text = "▶ PLAY"
                        badge.BackgroundColor3 = C.Green
                    end
                end)
            end)
            
            ActionBtn("📋", 45, Color3.fromRGB(60, 70, 110), function()
                CopyToClipboard(item.soundId)
                Notify("تم نسخ Sound ID!")
            end)
            
        elseif itemType == "image" then
            typeIcon.Text = "🖼️"
            nameLbl.Text = item.name
            infoLbl.Text = item.imageId ~= "" and item.imageId or item.path
            
            badge.Text = item.className
            badge.BackgroundColor3 = C.Pink
            
            ActionBtn("📋", 0, Color3.fromRGB(60, 70, 110), function()
                CopyToClipboard(item.imageId)
                Notify("تم نسخ Image ID!")
            end)
            
        elseif itemType == "remote" then
            typeIcon.Text = item.isEvent and "📡" or "📞"
            nameLbl.Text = item.name
            infoLbl.Text = item.path
            
            badge.Text = item.isEvent and "EVENT" or "FUNC"
            badge.BackgroundColor3 = item.isEvent and C.Orange or C.Purple
            
            ActionBtn("🔥", 0, C.Red, function()
                pcall(function()
                    if item.isEvent then
                        item.instance:FireServer()
                        Notify("تم إطلاق الـ Remote!")
                    else
                        local result = item.instance:InvokeServer()
                        Notify("النتيجة: " .. tostring(result):sub(1, 30))
                    end
                end)
            end)
            
            ActionBtn("📋", 45, Color3.fromRGB(60, 70, 110), function()
                CopyToClipboard(item.path)
                Notify("تم نسخ المسار!")
            end)
            
        elseif itemType == "value" then
            typeIcon.Text = "📊"
            nameLbl.Text = item.name
            infoLbl.Text = item.className .. " = " .. item.valueStr
            
            badge.Text = item.className:gsub("Value", "")
            badge.BackgroundColor3 = C.Cyan
            
            ActionBtn("📋", 0, Color3.fromRGB(60, 70, 110), function()
                CopyToClipboard(item.valueStr)
                Notify("تم نسخ القيمة!")
            end)
        end
        
        -- Hover
        card.MouseEnter:Connect(function()
            Tween(card, {BackgroundColor3 = C.CardHover}, 0.15)
        end)
        card.MouseLeave:Connect(function()
            Tween(card, {BackgroundColor3 = C.Card}, 0.15)
        end)
        
        return card
    end
    
    -- ═══ دالة بناء الواجهة من النتائج ═══
    local function BuildUI(results)
        -- مسح التabs القديمة
        for _, page in pairs(pages) do page:Destroy() end
        for _, data in pairs(tabButtons) do data.btn:Destroy() end
        pages = {}
        tabButtons = {}
        
        -- إنشاء التabs الجديدة
        CreateTab("Sensitive", "🔒", C.Red, #results.sensitive)
        CreateTab("Editable", "✏️", C.Green, #results.editable)
        CreateTab("Scripts", "📜", C.Accent, #results.scripts)
        CreateTab("Sounds", "🔊", C.Green, #results.sounds)
        CreateTab("Images", "🖼️", C.Pink, #results.images)
        CreateTab("Remotes", "📡", C.Orange, #results.remotes)
        CreateTab("Values", "📊", C.Cyan, #results.values)
        CreateTab("Game", "🎮", C.Gold, 1)
        CreateTab("Players", "👥", C.Accent, #results.players)
        
        -- ملء المحتوى
        for _, script in ipairs(results.sensitive) do
            CreateItemCard(pages["Sensitive"], script, "script")
        end
        
        for _, script in ipairs(results.editable) do
            CreateItemCard(pages["Editable"], script, "script")
        end
        
        for _, script in ipairs(results.scripts) do
            CreateItemCard(pages["Scripts"], script, "script")
        end
        
        for _, sound in ipairs(results.sounds) do
            CreateItemCard(pages["Sounds"], sound, "sound")
        end
        
        for _, image in ipairs(results.images) do
            CreateItemCard(pages["Images"], image, "image")
        end
        
        for _, remote in ipairs(results.remotes) do
            CreateItemCard(pages["Remotes"], remote, "remote")
        end
        
        for _, value in ipairs(results.values) do
            CreateItemCard(pages["Values"], value, "value")
        end
        
        -- معلومات اللعبة
        local gameCard = Instance.new("Frame")
        gameCard.Size = UDim2.new(1, -4, 0, 180)
        gameCard.BackgroundColor3 = C.Card
        gameCard.ZIndex = 17
        gameCard.Parent = pages["Game"]
        AddCorner(gameCard, 10)
        
        local gameInfo = Instance.new("TextLabel")
        gameInfo.Size = UDim2.new(1, -12, 1, -8)
        gameInfo.Position = UDim2.new(0, 6, 0, 4)
        gameInfo.Text = string.format(
            "🎮 Game: %s\n📍 Place ID: %s\n👥 Players: %d/%d\n⏱️ Server Time: %ds\n🎯 FPS: %d\n\n📊 Scan Results:\n• Total: %s\n• Scripts: %d (Editable: %d)\n• Sounds: %d | Images: %d\n• Remotes: %d | Values: %d\n• Sensitive: %d",
            results.gameInfo.name,
            results.gameInfo.placeId,
            results.gameInfo.playerCount,
            results.gameInfo.maxPlayers,
            results.gameInfo.serverTime,
            results.gameInfo.fps,
            FormatNumber(results.summary.totalScanned),
            results.summary.totalScripts,
            results.summary.totalEditable,
            results.summary.totalSounds,
            results.summary.totalImages,
            results.summary.totalRemotes,
            results.summary.totalValues,
            results.summary.totalSensitive
        )
        gameInfo.TextColor3 = C.Text
        gameInfo.TextSize = 11
        gameInfo.Font = Enum.Font.Gotham
        gameInfo.TextXAlignment = Enum.TextXAlignment.Left
        gameInfo.TextYAlignment = Enum.TextYAlignment.Top
        gameInfo.BackgroundTransparency = 1
        gameInfo.ZIndex = 18
        gameInfo.Parent = gameCard
        
        -- اللاعبين
        for _, player in ipairs(results.players) do
            local pCard = Instance.new("Frame")
            pCard.Size = UDim2.new(1, -4, 0, 50)
            pCard.BackgroundColor3 = C.Card
            pCard.ZIndex = 17
            pCard.Parent = pages["Players"]
            AddCorner(pCard, 8)
            
            local pName = Instance.new("TextLabel")
            pName.Size = UDim2.new(0.5, 0, 0, 16)
            pName.Position = UDim2.new(0, 8, 0, 4)
            pName.Text = "👤 " .. player.name
            pName.TextColor3 = C.Text
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.BackgroundTransparency = 1
            pName.ZIndex = 18
            pName.Parent = pCard
            
            local pInfo = Instance.new("TextLabel")
            pInfo.Size = UDim2.new(1, -12, 0, 12)
            pInfo.Position = UDim2.new(0, 8, 0, 24)
            pInfo.Text = string.format("ID: %d | Team: %s | HP: %s/%s | Speed: %s",
                player.userId, player.team,
                player.health or "?", player.maxHealth or "?",
                player.walkSpeed or "?"
            )
            pInfo.TextColor3 = C.TextDim
            pInfo.TextSize = 8
            pInfo.Font = Enum.Font.Gotham
            pInfo.TextXAlignment = Enum.TextXAlignment.Left
            pInfo.BackgroundTransparency = 1
            pInfo.ZIndex = 18
            pInfo.Parent = pCard
        end
        
        -- تفعيل أول Tab
        if tabButtons["Sensitive"] then
            tabButtons["Sensitive"].btn.MouseButton1Click:Fire()
        end
    end
    
    -- ═══ زر Scan ═══
    ScanBtn.MouseButton1Click:Connect(function()
        if isScanning then return end
        isScanning = true
        ScanBtn.Text = "⏳..."
        
        task.spawn(function()
            local results = GameAnalyzer.Scan(function(progress)
                Title.Text = "🔬 Scanning... " .. progress.percent .. "%"
            end)
            
            scanResults = results
            BuildUI(results)
            
            isScanning = false
            ScanBtn.Text = "🔍 Scan"
            Title.Text = "🔬 GAME ANALYZER"
            
            Notify("تم الفحص! " .. results.summary.totalScanned .. " عنصر")
        end)
    end)
    
    -- فحص تلقائي عند البناء
    task.spawn(function()
        task.wait(0.5)
        ScanBtn.MouseButton1Click:Fire()
    end)
end

print("🔬 Analyzer UI v3.0 Loaded!")

return AnalyzerUI
