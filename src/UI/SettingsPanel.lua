--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - Settings Panel v1.0 (v7.1)
    ═══════════════════════════════════════════════════════════════════════════
    صفحة إعدادات كاملة بمبدأ "كل ميزة صفحة لوحدها":
    • صفحة الإعدادات الرئيسية (واجهة/عرض/مستكشف/أداء/بيانات/حول)
    • صفحة فرعية "حول المشروع" مع معلومات الإصدار
    • كل عنصر تحكم ≥44px (لمس مريح) وبلا تداخل
    • حفظ فوري عبر SaveSystem وتطبيق مباشر (لغة/مظهر/حركات...)
    ═══════════════════════════════════════════════════════════════════════════
]]

local SettingsPanel = {}

local function GetModule(name)
    return assert(_G.WiliModules and _G.WiliModules[name], "SettingsPanel dependency missing: " .. name)
end

local Language = GetModule("Language")
local Colors = GetModule("Colors")
local Icons = GetModule("Icons")
local SaveSystem = GetModule("SaveSystem")

local TweenService = game:GetService("TweenService")

local function T(key) return Language.Get(key, key) end

local P = {
    BG = Color3.fromRGB(8, 10, 22),
    Surface = Color3.fromRGB(15, 20, 40),
    Raised = Color3.fromRGB(22, 28, 52),
    Hover = Color3.fromRGB(30, 38, 68),
    Text = Color3.fromRGB(242, 247, 255),
    Muted = Color3.fromRGB(150, 168, 197),
    Dim = Color3.fromRGB(110, 125, 155),
    Accent = Color3.fromRGB(0, 212, 255),
    Success = Color3.fromRGB(0, 255, 136),
    Danger = Color3.fromRGB(255, 70, 90),
    Warning = Color3.fromRGB(255, 190, 76),
    Purple = Color3.fromRGB(153, 107, 255),
    Gold = Color3.fromRGB(255, 215, 0)
}

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function Tween(obj, props, duration)
    if obj and obj.Parent then
        TweenService:Create(obj, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end
end

local function Settings()
    return SaveSystem and SaveSystem.Settings or {}
end

local function SaveSetting(key, value)
    if SaveSystem and SaveSystem.Set then
        pcall(function() SaveSystem.Set(key, value) end)
    end
end

-- إعادة تلوين الصفحة بعد تغيير الثيم
local function RefreshTheme(container)
    if not container then return end
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Name == "WiliCard" then
            pcall(function()
                obj.BackgroundColor3 = P.Surface
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- عناصر التحكم (كلها ≥44px)
-- ═══════════════════════════════════════════════════════════════════════════

-- ترويسة قسم
local function SectionHeader(parent, text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = P.Accent
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Language.Alignment()
    label.LayoutOrder = order or 0
    label.Parent = parent
    return label
end

-- صف إعداد: عنوان + وصف + محتوى تحكم على اليمين
local function SettingRow(parent, title, subtitle, order, controlBuilder)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -2, 0, 54)
    row.BackgroundColor3 = P.Surface
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    row.Parent = parent
    Corner(row, 10)
    Instance.new("UIStroke", row).Color = P.Surface

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -220, 0, 26)
    titleLabel.Position = UDim2.new(0, 12, 0, 6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = P.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Language.Alignment()
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = row

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -220, 0, 16)
    subtitleLabel.Position = UDim2.new(0, 12, 0, 32)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = subtitle or ""
    subtitleLabel.TextColor3 = P.Dim
    subtitleLabel.TextSize = 9
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Language.Alignment()
    subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subtitleLabel.Parent = row

    local controlArea = Instance.new("Frame")
    controlArea.Size = UDim2.new(0, 190, 0, 46)
    controlArea.Position = UDim2.new(1, -196, 0.5, -23)
    controlArea.BackgroundTransparency = 1
    controlArea.Parent = row

    if controlBuilder then
        controlBuilder(controlArea, row, titleLabel, subtitleLabel)
    end
    return row
end

-- مفتاح تبديل (44px)
local function Toggle(parent, initial, onChanged)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 32)
    btn.Position = UDim2.new(1, -60, 0.5, -16)
    btn.BackgroundColor3 = initial and P.Success or P.Dim
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = parent
    Corner(btn, 16)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 26, 0, 26)
    knob.Position = UDim2.new(0, 3, 0.5, -13)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = btn
    Corner(knob, 13)

    local state = initial

    local function render()
        Tween(btn, {BackgroundColor3 = state and P.Success or Color3.fromRGB(60, 70, 100)}, 0.15)
        Tween(knob, {Position = UDim2.new(0, state and 31 or 3, 0.5, -13)}, 0.15)
    end
    render()

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        if onChanged then onChanged(state) end
    end)
    return btn, function() return state end, function(v) state = v render() end
end

-- تحكم مقسّم (2-4 خيارات) — كل خيار ≥44px عرض
local function Segmented(parent, options, selectedIndex, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 186, 0, 40)
    holder.Position = UDim2.new(1, -186, 0.5, -20)
    holder.BackgroundColor3 = P.Raised
    holder.BorderSizePixel = 0
    holder.Parent = parent
    Corner(holder, 10)

    local count = #options
    local cellWidth = 186 / count
    local buttons = {}
    local current = selectedIndex or 1

    for i, option in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, cellWidth - 6, 0, 34)
        btn.Position = UDim2.new(0, (i - 1) * cellWidth + 3, 0, 3)
        btn.BackgroundColor3 = i == current and P.Accent or Color3.fromRGB(28, 36, 64)
        btn.Text = option.label or tostring(option)
        btn.TextColor3 = i == current and P.BG or P.Muted
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = holder
        Corner(btn, 7)
        buttons[i] = btn

        btn.MouseButton1Click:Connect(function()
            if current == i then return end
            current = i
            for j, b in ipairs(buttons) do
                Tween(b, {
                    BackgroundColor3 = j == current and P.Accent or Color3.fromRGB(28, 36, 64)
                }, 0.14)
                Tween(b, {
                    TextColor3 = j == current and P.BG or P.Muted
                }, 0.14)
            end
            if onChanged then onChanged(option, i) end
        end)
    end
    return holder, function() return current end
end

-- منزلق (44px) مع خانة قيمة
local function SliderControl(parent, min, max, step, initial, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 186, 0, 40)
    holder.Position = UDim2.new(1, -186, 0.5, -20)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local track = Instance.new("TextButton")
    track.Size = UDim2.new(0, 120, 0, 44)
    track.Position = UDim2.new(0, 0, 0.5, -22)
    track.BackgroundColor3 = P.Raised
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = holder
    Corner(track, 10)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 4)
    fill.Position = UDim2.new(0, 6, 0.5, -2)
    fill.BackgroundColor3 = P.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Corner(fill, 2)

    local valueBox = Instance.new("TextBox")
    valueBox.Size = UDim2.new(0, 56, 0, 36)
    valueBox.Position = UDim2.new(1, -56, 0.5, -18)
    valueBox.BackgroundColor3 = P.Raised
    valueBox.TextColor3 = P.Text
    valueBox.TextSize = 12
    valueBox.Font = Enum.Font.Code
    valueBox.ClearTextOnFocus = false
    valueBox.Parent = holder
    Corner(valueBox, 9)

    local value = math.clamp(initial or min, min, max)
    valueBox.Text = tostring(value)

    local function setValue(v, fire)
        v = math.clamp(v, min, max)
        value = v
        valueBox.Text = tostring(math.floor(v * 100 + 0.5) / 100)
        local ratio = (v - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 0, 4)
        if fire and onChanged then onChanged(v) end
    end
    setValue(value, false)

    local function setFromPosition(px)
        local ratio = math.clamp((px - 6) / (track.AbsoluteSize.X - 12), 0, 1)
        local v = min + ratio * (max - min)
        if step then v = math.floor(v / step + 0.5) * step end
        setValue(v, true)
    end

    track.MouseButton1Down:Connect(function(x, y)
        if x and y then setFromPosition(x) end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setFromPosition(input.Position.X - track.AbsolutePosition.X)
        end
    end)

    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local v = tonumber(valueBox.Text)
            if v then setValue(v, true) end
        end
    end)

    return holder, setValue, function() return value end
end

-- صف زر (لأفعال مثل مسح الذاكرة)
local function ActionRow(parent, title, subtitle, icon, order, callback, color)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -2, 0, 50)
    row.BackgroundColor3 = P.Surface
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = order or 0
    row.Parent = parent
    Corner(row, 10)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 10, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "›"
    iconLabel.TextColor3 = color or P.Accent
    iconLabel.TextSize = 16
    iconLabel.Parent = row

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 24)
    titleLabel.Position = UDim2.new(0, 48, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = P.Text
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Language.Alignment()
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = row

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -70, 0, 14)
    subtitleLabel.Position = UDim2.new(0, 48, 0, 31)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = subtitle or ""
    subtitleLabel.TextColor3 = P.Dim
    subtitleLabel.TextSize = 9
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Language.Alignment()
    subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    subtitleLabel.Parent = row

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "›"
    arrow.TextColor3 = P.Dim
    arrow.TextSize = 18
    arrow.Font = Enum.Font.GothamBold
    arrow.Parent = row

    row.MouseEnter:Connect(function()
        Tween(row, {BackgroundColor3 = P.Hover}, 0.12)
    end)
    row.MouseLeave:Connect(function()
        Tween(row, {BackgroundColor3 = P.Surface}, 0.12)
    end)
    row.MouseButton1Down:Connect(function()
        Tween(row, {BackgroundColor3 = Color3.fromRGB(20, 40, 70)}, 0.06)
    end)
    row.MouseButton1Up:Connect(function()
        Tween(row, {BackgroundColor3 = P.Hover}, 0.1)
    end)
    if callback then
        row.MouseButton1Click:Connect(callback)
    end
    return row
end

-- ═══════════════════════════════════════════════════════════════════════════
-- الصفحة الفرعية: حول المشروع
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildAboutPage(content, subRouter)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = P.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.Parent = scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    -- الشعار
    local logoCard = Instance.new("Frame")
    logoCard.Size = UDim2.new(1, -2, 0, 110)
    logoCard.BackgroundColor3 = P.Surface
    logoCard.LayoutOrder = 1
    logoCard.Parent = scroll
    Corner(logoCard, 12)

    local logoIcon = Instance.new("TextLabel")
    logoIcon.Size = UDim2.new(0, 60, 0, 60)
    logoIcon.Position = UDim2.new(0.5, -30, 0, 10)
    logoIcon.BackgroundTransparency = 1
    logoIcon.Text = "◈"
    logoIcon.TextColor3 = P.Accent
    logoIcon.TextSize = 40
    logoIcon.Parent = logoCard

    local logoName = Instance.new("TextLabel")
    logoName.Size = UDim2.new(1, 0, 0, 22)
    logoName.Position = UDim2.new(0, 0, 0, 76)
    logoName.BackgroundTransparency = 1
    logoName.Text = "WiliExplorer"
    logoName.TextColor3 = P.Text
    logoName.TextSize = 16
    logoName.Font = Enum.Font.GothamBlack
    logoName.TextXAlignment = Enum.TextXAlignment.Center
    logoName.Parent = logoCard

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Size = UDim2.new(1, -20, 0, 20)
    versionLabel.Position = UDim2.new(0, 10, 0, 90)
    versionLabel.BackgroundTransparency = 1
    versionLabel.Text = T("VersionLabel") .. ": " .. tostring(_G.WiliConfig and _G.WiliConfig.Version or "7.1.0")
    versionLabel.TextColor3 = P.Muted
    versionLabel.TextSize = 11
    versionLabel.Font = Enum.Font.Gotham
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.Parent = scroll
    versionLabel.LayoutOrder = 2

    local authorLabel = Instance.new("TextLabel")
    authorLabel.Size = UDim2.new(1, -20, 0, 20)
    authorLabel.Position = UDim2.new(0, 10, 0, 0)
    authorLabel.BackgroundTransparency = 1
    authorLabel.Text = T("AuthorLabel") .. ": " .. tostring(_G.WiliConfig and _G.WiliConfig.Author or "ilyesguers")
    authorLabel.TextColor3 = P.Muted
    authorLabel.TextSize = 11
    authorLabel.Font = Enum.Font.Gotham
    authorLabel.TextXAlignment = Enum.TextXAlignment.Left
    authorLabel.Parent = scroll
    authorLabel.LayoutOrder = 3

    local repoBtn = ActionRow(scroll, T("OpenRepository"), "github.com/ilyesguers/WiliExplorer", "↗", 4, function()
        pcall(function()
            if setclipboard then setclipboard("https://github.com/ilyesguers/WiliExplorer") end
        end)
    end, P.Accent)

    local backBtn = ActionRow(scroll, T("PageBack"), T("SettingsTitle"), "‹", 5, function()
        if subRouter then subRouter.Back() end
    end, P.Warning)
    backBtn.LayoutOrder = 5
end

-- ═══════════════════════════════════════════════════════════════════════════
-- الصفحة الرئيسية للإعدادات
-- ═══════════════════════════════════════════════════════════════════════════
function SettingsPanel.Create(parent, options)
    options = options or {}
    local notify = options.notify
    local settings = Settings()

    -- ═══ راوتر داخلي للصفحات الفرعية ═══
    local Router = GetModule("Router")
    local subRouter = Router.Create(parent, notify)

    local themeNames = {"Space", "Ocean", "Sunset", "Forest"}
    local themeLabels = {}
    for _, name in ipairs(themeNames) do
        local theme = Colors[name]
        themeLabels[name] = {
            label = name:sub(1, 3),
            swatch = theme and theme.Accent or Color3.fromRGB(0, 212, 255)
        }
    end

    local function buildMainPage(content, page)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = P.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.Parent = content
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 14)
        pad.Parent = scroll
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
        end)

        -- ═══ الواجهة ═══
        SectionHeader(scroll, T("InterfaceSection"), 1)

        local function languageLabel()
            return Language.Current == "ar" and "العربية" or "English"
        end

        SettingRow(scroll, T("LanguageLabel"), languageLabel(), 2, function(area)
            Segmented(area, {
                {label = "AR"},
                {label = "EN"}
            }, Language.Current == "ar" and 1 or 2, function(option, index)
                Language.Set(index == 1 and "ar" or "en")
                SaveSetting("language", Language.Current)
                if notify then notify(T("LanguageChanged"), "Info") end
                if options.onLanguageChanged then options.onLanguageChanged() end
            end)
        end)

        local currentThemeName = "Space"
        for _, name in ipairs(themeNames) do
            if Colors.Current == Colors[name] then
                currentThemeName = name
                break
            end
        end
        SettingRow(scroll, T("ThemeLabel"), currentThemeName, 3, function(area)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(0, 186, 0, 40)
            holder.Position = UDim2.new(1, -186, 0.5, -20)
            holder.BackgroundColor3 = P.Raised
            holder.BorderSizePixel = 0
            holder.Parent = area
            Corner(holder, 10)
            local buttons = {}
            for i, name in ipairs(themeNames) do
                local data = themeLabels[name]
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 42, 0, 34)
                btn.Position = UDim2.new(0, (i - 1) * 45 + 3, 0, 3)
                btn.BackgroundColor3 = name == currentThemeName and data.swatch or Color3.fromRGB(28, 36, 64)
                btn.Text = name:sub(1, 2)
                btn.TextColor3 = P.Text
                btn.TextSize = 10
                btn.Font = Enum.Font.GothamBold
                btn.AutoButtonColor = false
                btn.Parent = holder
                Corner(btn, 7)
                buttons[i] = {btn = btn, name = name, swatch = data.swatch}
                btn.MouseButton1Click:Connect(function()
                    Colors.SetTheme(name)
                    SaveSetting("theme", name:lower())
                    for j, b in ipairs(buttons) do
                        Tween(b.btn, {
                            BackgroundColor3 = b.name == name and b.swatch or Color3.fromRGB(28, 36, 64)
                        }, 0.14)
                    end
                    if notify then notify(T("ThemeChanged"), "Info") end
                    if options.onThemeChanged then options.onThemeChanged() end
                end)
            end
        end)

        SettingRow(scroll, T("ScaleLabel"), "100%", 4, function(area)
            SliderControl(area, 80, 140, 5, settings.uiScale and settings.uiScale * 100 or 100, function(v)
                SaveSetting("uiScale", v / 100)
            end)
        end)

        SettingRow(scroll, T("CompactLabel"), T("AutoValue"), 5, function(area)
            Segmented(area, {
                {label = T("AutoValue")},
                {label = T("OnValue")},
                {label = T("OffValue")}
            }, settings.compactMode == "auto" and 1 or settings.compactMode and 2 or 3, function(option, index)
                local value = index == 1 and "auto" or index == 2 and "on" or "off"
                SaveSetting("compactMode", value)
            end)
        end)

        SettingRow(scroll, T("MotionLabel"), settings.animationsEnabled ~= false and T("OnValue") or T("OffValue"), 6, function(area)
            Toggle(area, settings.animationsEnabled ~= false, function(state)
                SaveSetting("animationsEnabled", state)
            end)
        end)

        SettingRow(scroll, T("NotificationsLabel"), settings.showNotifications ~= false and T("OnValue") or T("OffValue"), 7, function(area)
            Toggle(area, settings.showNotifications ~= false, function(state)
                SaveSetting("showNotifications", state)
            end)
        end)

        -- ═══ العرض ═══
        SectionHeader(scroll, T("DisplaySection"), 10)
        SettingRow(scroll, T("SpaceEffectsLabel"), settings.spaceEffects ~= false and T("OnValue") or T("OffValue"), 11, function(area)
            Toggle(area, settings.spaceEffects ~= false, function(state)
                SaveSetting("spaceEffects", state)
            end)
        end)
        SettingRow(scroll, T("ContrastLabel"), settings.highContrast and T("OnValue") or T("OffValue"), 12, function(area)
            Toggle(area, settings.highContrast == true, function(state)
                SaveSetting("highContrast", state)
            end)
        end)

        -- ═══ المستكشف ═══
        SectionHeader(scroll, T("ExplorerSection"), 20)
        SettingRow(scroll, T("ScanLimitLabel"), tostring(settings.scanObjectLimit or 15000), 21, function(area)
            SliderControl(area, 1000, 100000, 1000, settings.scanObjectLimit or 15000, function(v)
                SaveSetting("scanObjectLimit", math.floor(v))
            end)
        end)
        SettingRow(scroll, T("ScanBatchLabel"), tostring(settings.scanBatchSize or 100), 22, function(area)
            SliderControl(area, 10, 500, 10, settings.scanBatchSize or 100, function(v)
                SaveSetting("scanBatchSize", math.floor(v))
            end)
        end)

        -- ═══ الأداء ═══
        SectionHeader(scroll, T("PerformanceSection"), 30)
        SettingRow(scroll, T("PowerSaverLabel"), settings.powerSaver == true and T("OnValue") or T("AutoValue"), 31, function(area)
            Segmented(area, {
                {label = T("AutoValue")},
                {label = T("OnValue")},
                {label = T("OffValue")}
            }, settings.powerSaver == true and 2 or settings.powerSaver == false and 3 or 1, function(option, index)
                local value = index == 2 and true or index == 3 and false or "auto"
                SaveSetting("powerSaver", value)
            end)
        end)

        -- ═══ البيانات ═══
        SectionHeader(scroll, T("DataSection"), 40)
        ActionRow(scroll, T("ClearCache"), "WiliExplorer/cache", "⌫", 41, function()
            pcall(function()
                if isfolder and isfolder("WiliExplorer/cache") and delfolder then
                    delfolder("WiliExplorer/cache")
                end
            end)
            if notify then notify(T("CacheCleared"), "Info") end
        end, P.Warning)
        ActionRow(scroll, T("ResetSettings"), T("ResetConfirm"), "↻", 42, function()
            pcall(function()
                if SaveSystem and SaveSystem.ClearAll then
                    SaveSystem.ClearAll()
                end
            end)
            if notify then notify(T("ResetConfirm"), "Info") end
        end, P.Danger)

        -- ═══ حول ═══
        SectionHeader(scroll, T("AboutSection"), 50)
        ActionRow(scroll, T("ProfileTitle"), T("ProfileSubtitle"), "i", 51, function()
            subRouter.Push({
                name = "about",
                title = T("ProfileTitle"),
                subtitle = "WiliExplorer",
                icon = "◈",
                color = P.Accent,
                builder = function(c, p) BuildAboutPage(c, subRouter) end
            })
        end, P.Accent)
    end

    subRouter.Push({
        name = "settings",
        title = T("SettingsTitle"),
        subtitle = T("SettingsSubtitle"),
        icon = "⚙",
        color = P.Accent,
        builder = buildMainPage
    })

    return subRouter
end

return SettingsPanel
