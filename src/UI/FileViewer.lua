--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - Universal File Viewer v7.0
    ═══════════════════════════════════════════════════════════════════════════
    عارض واحد لكل أنواع العناصر — لا مجرد "معلومات قليلة":

    • سكربتات      → كود ملوّن بالكامل (Highlighter) + تعديل/حفظ/تشغيل
    • أصوات        → مشغّل مدمج (تشغيل/إيقاف/مستوى/سرعة/تكرار) + محرر كامل
    • صور          → معاينة كبيرة + محرر الصور
    • فيديو        → معاينة تشغيل حقيقية
    • مجسمات/أجزاء → معاينة ثلاثية الأبعاد (ViewportFrame) مع تدوير تلقائي
    • حركات        → بيانات الحركة + تشغيلها على شخصيتك
    • واجهات GUI   → معاينة مصغّرة مع تحكم بالمقياس
    • تأثيرات      → معاينة حية داخل Viewport مع مفتاح تشغيل
    • إضاءة        → تحكم باللون/السطوع/المدى/الزاوية/الظلال
    • قيم          → محرر مدمج لكل الأنواع (نص/رقم/منطقي/لون)
    • اتصالات      → معلومات + إطلاق/استدعاء تجريبي
    • أي نوع آخر   → معلومات غنية + خصائص قابلة للتعديل + وسوم + Attributes

    المبادئ:
    • الأيقونة دائماً في Label مستقل عن النص (لا تشابك مع RTL)
    • كل النصوص من Language (عربي/إنجليزي)
    • حركات دخول وحالات Hover/Press على كل الأزرار
    ═══════════════════════════════════════════════════════════════════════════
]]

local FileViewer = {}

local function GetModule(name)
    return assert(_G.WiliModules and _G.WiliModules[name], "FileViewer dependency missing: " .. name)
end

local FileScanner = GetModule("FileScanner")
local Language = GetModule("Language")
local Icons = GetModule("Icons")
local Highlighter = GetModule("Highlighter")
local PropertyEditor = GetModule("PropertyEditor")
local Colors = GetModule("Colors")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════
-- لوحة الألوان والنصوص
-- ═══════════════════════════════════════════════════════════════════════════
local C = Colors.Current or Colors.Space

local P = {
    BG = Color3.fromRGB(8, 10, 22),
    BG_ALT = Color3.fromRGB(11, 14, 30),
    Surface = Color3.fromRGB(15, 20, 40),
    Raised = Color3.fromRGB(22, 28, 52),
    Hover = Color3.fromRGB(30, 38, 68),
    Header = Color3.fromRGB(13, 17, 36),
    Border = Color3.fromRGB(40, 50, 85),
    Text = Color3.fromRGB(242, 247, 255),
    Muted = Color3.fromRGB(150, 168, 197),
    Dim = Color3.fromRGB(110, 125, 155),
    Accent = C.Accent or Color3.fromRGB(0, 212, 255),
    AccentStrong = C.AccentDark or Color3.fromRGB(0, 152, 219),
    Success = C.Success or Color3.fromRGB(0, 255, 136),
    Warning = C.Warning or Color3.fromRGB(255, 200, 50),
    Danger = C.Error or Color3.fromRGB(255, 70, 90),
    Gold = C.Gold or Color3.fromRGB(255, 215, 0),
    Purple = C.Purple or Color3.fromRGB(153, 107, 255),
    Pink = C.Pink or Color3.fromRGB(255, 100, 150),
    DarkText = Color3.fromRGB(8, 22, 16)
}

local function T(key, fallback)
    return Language.Get(key, fallback)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- أدوات مساعدة
-- ═══════════════════════════════════════════════════════════════════════════
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or P.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function Tween(obj, props, duration, style)
    if obj and obj.Parent then
        TweenService:Create(obj, TweenInfo.new(duration or 0.18, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end
end

local function TextLabel(parent, text, size, color, font, align)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = tostring(text or "")
    l.TextColor3 = color or P.Text
    l.TextSize = size or 13
    l.Font = font or Enum.Font.Gotham
    l.TextXAlignment = align or Language.Alignment()
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.ZIndex = 3
    l.Parent = parent
    return l
end

-- أيقونة مستقلة دائماً — لا تدمجها مع نص
local function IconLabel(parent, icon, size, color, zIndex)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = icon or Icons.UI.Unknown
    l.TextColor3 = color or P.Accent
    l.TextSize = size or 18
    l.Font = Enum.Font.GothamMedium
    l.ZIndex = (zIndex or 3) + 1
    l.Parent = parent
    return l
end

local function StripScripts(clone)
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("BaseScript") then
            d:Destroy()
        elseif d:IsA("Sound") then
            pcall(function() d.Playing = false end)
        end
    end
    return clone
end

local function CopyToClipboard(text)
    local ok = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            ok = true
        elseif toclipboard then
            toclipboard(text)
            ok = true
        end
    end)
    return ok
end

-- إشعار صغير داخل العارض
local function Notify(parent, message, kind)
    local color = kind == "error" and P.Danger or kind == "warning" and P.Warning or P.Success
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 280, 0, 42)
    n.Position = UDim2.new(0.5, -140, 0, 6)
    n.BackgroundColor3 = color
    n.ZIndex = 60
    n.Parent = parent
    Corner(n, 10)
    local label = TextLabel(n, message, 13, P.DarkText, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    Tween(n, {BackgroundTransparency = 0.15}, 0.2)
    task.delay(2.2, function()
        if n and n.Parent then
            Tween(n, {BackgroundTransparency = 1}, 0.3)
            task.delay(0.35, function()
                if n and n.Parent then n:Destroy() end
            end)
        end
    end)
end

-- زر موحّد: أيقونة مستقلة + نص مستقل + حالات Hover/Press
-- يرجع (الزر، الأيقونة، النص) ويربطهما أيضاً كـ btn.IconLabel / btn.TextLabel
local function ActionButton(parent, icon, text, color, options)
    options = options or {}
    local btn = Instance.new("TextButton")
    btn.Size = options.size or UDim2.new(0, 128, 0, 40)
    btn.BackgroundColor3 = color or P.Surface
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    btn.Parent = parent
    Corner(btn, options.radius or 9)

    local iconSize = options.iconSize or 17
    local ic = IconLabel(btn, icon, iconSize, options.iconColor or P.Text, 4)
    ic.Size = UDim2.new(0, iconSize + 4, 1, 0)
    ic.Position = UDim2.new(0, options.compact and 6 or 9, 0, 0)

    local txt = TextLabel(btn, text or "", options.textSize or 12, options.textColor or P.Text, Enum.Font.GothamBold, Language.Alignment())
    txt.Size = UDim2.new(1, -(iconSize + 14), 1, 0)
    txt.Position = UDim2.new(0, iconSize + (options.compact and 8 or 11), 0, 0)
    txt.TextYAlignment = Enum.TextYAlignment.Center

    btn.IconLabel = ic
    btn.TextLabel = txt

    local hoverColor = options.hoverColor or P.Hover
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = hoverColor}, 0.12)
        Tween(ic, {TextColor3 = options.hoverIcon or P.Accent}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = color or P.Surface}, 0.12)
        Tween(ic, {TextColor3 = options.iconColor or P.Text}, 0.12)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, {BackgroundColor3 = options.pressColor or P.AccentStrong}, 0.06)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, {BackgroundColor3 = hoverColor}, 0.1)
    end)
    if options.callback then
        btn.MouseButton1Click:Connect(options.callback)
    end
    return btn, ic, txt
end

-- منطقة تمرير مع ترتيب
local function Scroller(parent, size, position)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = size or UDim2.new(1, 0, 1, 0)
    scroll.Position = position or UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = P.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 3
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
    end)
    task.defer(function()
        if scroll.Parent then
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
        end
    end)
    return scroll, layout
end

-- صف معلومات (مفتاح / قيمة)
local function InfoRow(parent, key, value, order, keyColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -2, 0, 52)
    row.BackgroundColor3 = P.Surface
    row.LayoutOrder = order or 0
    row.ZIndex = 3
    row.Parent = parent
    Corner(row, 8)
    Stroke(row, P.Border, 1, 0.6)

    local keyLabel = TextLabel(row, key, 11, keyColor or P.Accent, Enum.Font.GothamBold, Language.Alignment())
    keyLabel.Size = UDim2.new(1, -16, 0, 18)
    keyLabel.Position = UDim2.new(0, 8, 0, 5)

    local valueLabel = TextLabel(row, tostring(value), 13, P.Text, Enum.Font.Gotham, Language.Alignment())
    valueLabel.Size = UDim2.new(1, -16, 0, 22)
    valueLabel.Position = UDim2.new(0, 8, 0, 26)
    return row, valueLabel
end

-- حالة فارغة
local function EmptyState(parent, icon, title, subtitle)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 110)
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    local ic = IconLabel(holder, icon or Icons.UI.Empty, 42, P.Dim, 3)
    ic.Size = UDim2.new(0, 50, 0, 50)
    ic.Position = UDim2.new(0.5, -25, 0, 8)
    local t = TextLabel(holder, title or "", 15, P.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    t.Size = UDim2.new(1, 0, 0, 22)
    t.Position = UDim2.new(0, 0, 0, 62)
    local s = TextLabel(holder, subtitle or "", 11, P.Dim, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    s.Size = UDim2.new(1, 0, 0, 20)
    s.Position = UDim2.new(0, 0, 0, 86)
    return holder
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: سكربتات (كود ملوّن بالكامل)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildScriptPreview(content, instance, info, window)
    local sourceData = FileScanner.GetSource(instance)
    local source = sourceData.source or ""
    local canEdit = info.CanEdit and sourceData.success

    local Toolbar = Instance.new("Frame")
    Toolbar.Size = UDim2.new(1, -4, 0, 44)
    Toolbar.BackgroundColor3 = P.Header
    Toolbar.Parent = content
    Corner(Toolbar, 8)
    local toolbarLayout = Instance.new("UIListLayout")
    toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
    toolbarLayout.Padding = UDim.new(0, 6)
    toolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    toolbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    toolbarLayout.Parent = Toolbar
    local toolbarPad = Instance.new("UIPadding")
    toolbarPad.PaddingRight = UDim.new(0, 8)
    toolbarPad.PaddingLeft = UDim.new(0, 8)
    toolbarPad.Parent = Toolbar

    local stats = Highlighter.GetStats(source)
    local statsLabel = TextLabel(Toolbar, string.format(
        "%s: %d • %s: %d • %s: %d",
        T("Lines"), stats.lines, T("Chars"), stats.characters, T("Functions"), stats.functions
    ), 11, P.Muted, Enum.Font.Gotham, Language.Alignment())
    statsLabel.Size = UDim2.new(0.5, -10, 1, 0)
    statsLabel.Position = UDim2.new(0, 8, 0, 0)
    statsLabel.LayoutOrder = -1

    local codeArea = Instance.new("Frame")
    codeArea.Size = UDim2.new(1, -4, 1, -52)
    codeArea.Position = UDim2.new(0, 2, 0, 50)
    codeArea.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
    codeArea.ClipsDescendants = true
    codeArea.Parent = content
    Corner(codeArea, 10)
    Stroke(codeArea, P.Border, 1, 0.5)

    -- وضع القراءة: نص ملوّن
    local viewScroll = Instance.new("ScrollingFrame")
    viewScroll.Size = UDim2.new(1, -8, 1, -8)
    viewScroll.Position = UDim2.new(0, 4, 0, 4)
    viewScroll.BackgroundTransparency = 1
    viewScroll.BorderSizePixel = 0
    viewScroll.ScrollBarThickness = 5
    viewScroll.ScrollBarImageColor3 = P.Accent
    viewScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    viewScroll.Parent = codeArea

    local lineGutter = Instance.new("TextLabel")
    lineGutter.Name = "LineGutter"
    lineGutter.BackgroundTransparency = 1
    lineGutter.BorderSizePixel = 0
    lineGutter.Font = Enum.Font.Code
    lineGutter.TextSize = 13
    lineGutter.TextXAlignment = Enum.TextXAlignment.Right
    lineGutter.TextYAlignment = Enum.TextYAlignment.Top
    lineGutter.TextColor3 = P.Dim
    lineGutter.Size = UDim2.new(0, 42, 0, 0)
    lineGutter.Parent = viewScroll

    local codeLabel = Instance.new("TextLabel")
    codeLabel.BackgroundTransparency = 1
    codeLabel.BorderSizePixel = 0
    codeLabel.Font = Enum.Font.Code
    codeLabel.TextSize = 13
    codeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeLabel.TextYAlignment = Enum.TextYAlignment.Top
    codeLabel.RichText = true
    codeLabel.TextWrapped = false
    codeLabel.Size = UDim2.new(1, -52, 0, 0)
    codeLabel.Position = UDim2.new(0, 52, 0, 0)
    codeLabel.Parent = viewScroll

    local function renderHighlighted(text)
        local codeText = text or source
        codeLabel.Text = Highlighter.ToRichText(codeText ~= "" and codeText or "-- " .. T("SourceUnavailable"))
        lineGutter.Text = Highlighter.GetLineNumbers(codeText)
        local lines = 1
        for _ in codeText:gmatch("\n") do lines = lines + 1 end
        local height = math.max(60, lines * 17 + 24)
        codeLabel.Size = UDim2.new(1, -52, 0, height)
        lineGutter.Size = UDim2.new(0, 42, 0, height)
        viewScroll.CanvasSize = UDim2.new(0, 0, 0, height + 6)
    end
    renderHighlighted(source)

    -- وضع التحرير: TextBox عادي
    local editBox = Instance.new("TextBox")
    editBox.Size = UDim2.new(1, -8, 1, -8)
    editBox.Position = UDim2.new(0, 4, 0, 4)
    editBox.BackgroundTransparency = 1
    editBox.BorderSizePixel = 0
    editBox.ClearTextOnFocus = false
    editBox.MultiLine = true
    editBox.Font = Enum.Font.Code
    editBox.TextSize = 13
    editBox.TextXAlignment = Enum.TextXAlignment.Left
    editBox.TextYAlignment = Enum.TextYAlignment.Top
    editBox.TextColor3 = P.Text
    editBox.PlaceholderColor3 = P.Dim
    editBox.PlaceholderText = "-- " .. T("SourceUnavailable")
    editBox.Text = source
    editBox.Visible = false
    editBox.Parent = codeArea

    local editing = false

    local runBtn = ActionButton(Toolbar, Icons.UI.Run, T("RunCode"), P.AccentStrong, {
        size = UDim2.new(0, 96, 0, 32), textSize = 11,
        iconColor = P.Text, textColor = P.Text, callback = function()
            local fn, loadErr = loadstring(editBox.Text)
            if fn then
                local ok, err = pcall(fn)
                if ok then
                    Notify(window, T("RunDone"), "success")
                else
                    Notify(window, tostring(err):sub(1, 80), "error")
                end
            else
                Notify(window, tostring(loadErr):sub(1, 80), "error")
            end
        end
    })

    local editBtn = ActionButton(Toolbar, Icons.UI.Edit, T("EditScript"), P.Surface, {
        size = UDim2.new(0, 116, 0, 32), textSize = 11, callback = function()
            editing = not editing
            viewScroll.Visible = not editing
            editBox.Visible = editing
            editBtn.TextLabel.Text = editing and T("BackToViewer") or T("EditScript")
            if editing then
                editBox:CaptureFocus()
            else
                renderHighlighted(editBox.Text)
            end
        end
    })

    local saveBtn = ActionButton(Toolbar, Icons.UI.Save, T("SaveCode"), P.Success, {
        size = UDim2.new(0, 96, 0, 32), textSize = 11,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            if not canEdit then
                Notify(window, T("ReadOnly"), "warning")
                return
            end
            if FileScanner.SetSource(instance, editBox.Text) then
                Notify(window, T("CodeSaved"), "success")
            else
                Notify(window, T("SaveFailed"), "error")
            end
        end
    })

    local copyBtn = ActionButton(Toolbar, Icons.UI.Copy, T("CopyCode"), P.Surface, {
        size = UDim2.new(0, 96, 0, 32), textSize = 11, callback = function()
            if CopyToClipboard(editBox.Text) then
                Notify(window, T("Copied"), "success")
            end
        end
    })

    if not canEdit then
        saveBtn.Visible = false
        editBtn.Visible = false
    end

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: صوت (مشغّل مدمج)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildSoundPreview(content, instance, info, window)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, -4, 0, 214)
    panel.Position = UDim2.new(0, 2, 0, 0)
    panel.BackgroundColor3 = P.Surface
    panel.Parent = content
    Corner(panel, 10)
    Stroke(panel, P.Accent, 1, 0.4)

    local bigIcon = IconLabel(panel, Icons.UI.Sound, 40, P.Accent, 3)
    bigIcon.Size = UDim2.new(0, 56, 0, 56)
    bigIcon.Position = UDim2.new(0.5, -28, 0, 14)

    local idLabel = TextLabel(panel, instance.SoundId or "", 11, P.Muted, Enum.Font.Code, Enum.TextXAlignment.Center)
    idLabel.Size = UDim2.new(1, -40, 0, 18)
    idLabel.Position = UDim2.new(0, 20, 0, 78)

    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -30, 0, 44)
    controls.Position = UDim2.new(0, 15, 0, 102)
    controls.BackgroundTransparency = 1
    controls.Parent = panel
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 8)
    controlsLayout.Parent = controls

    local playing = false
    local playBtn = ActionButton(controls, Icons.UI.Play, T("PlayPreview"), P.Success, {
        size = UDim2.new(0, 100, 0, 38), textSize = 11,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            if not playing then
                pcall(function() instance:Play() end)
                playing = true
                playBtn.TextLabel.Text = T("PausePreview")
            else
                pcall(function() instance:Pause() end)
                playing = false
                playBtn.TextLabel.Text = T("PlayPreview")
            end
        end
    })

    local stopBtn = ActionButton(controls, Icons.UI.Stop, T("StopPreview"), P.Surface, {
        size = UDim2.new(0, 100, 0, 38), textSize = 11, callback = function()
            pcall(function() instance:Stop() end)
            playing = false
            playBtn.TextLabel.Text = T("PlayPreview")
        end
    })

    local loopBtn = ActionButton(controls, Icons.UI.Loop, T("LoopOff"), P.Surface, {
        size = UDim2.new(0, 100, 0, 38), textSize = 11, callback = function()
            pcall(function() instance.Looped = not instance.Looped end)
            loopBtn.TextLabel.Text = instance.Looped and T("LoopOn") or T("LoopOff")
        end
    })
    pcall(function() loopBtn.TextLabel.Text = instance.Looped and T("LoopOn") or T("LoopOff") end)

    local sliders = Instance.new("Frame")
    sliders.Size = UDim2.new(1, -30, 0, 48)
    sliders.Position = UDim2.new(0, 15, 0, 154)
    sliders.BackgroundTransparency = 1
    sliders.Parent = panel

    local function slider(name, prop, min, max, x)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0.32, -6, 1, 0)
        holder.Position = UDim2.new(x, 0, 0, 0)
        holder.BackgroundTransparency = 1
        holder.Parent = sliders
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -8, 0, 30)
        box.Position = UDim2.new(0, 0, 0, 0)
        box.BackgroundColor3 = P.Raised
        box.TextColor3 = P.Text
        box.TextSize = 11
        box.Font = Enum.Font.Code
        box.ClearTextOnFocus = false
        box.Parent = holder
        Corner(box, 6)
        pcall(function() box.Text = tostring(instance[prop]) end)
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local v = tonumber(box.Text)
                if v then
                    v = math.clamp(v, min, max)
                    pcall(function() instance[prop] = v end)
                    box.Text = tostring(v)
                end
            end
        end)
        local label = TextLabel(holder, name, 9, P.Dim, Enum.Font.GothamBold, Language.Alignment())
        label.Size = UDim2.new(1, -8, 0, 12)
        label.Position = UDim2.new(0, 4, 0, 31)
        return holder
    end

    slider(T("VolumeLabel"), "Volume", 0, 10, 0)
    slider(T("SpeedLabel"), "PlaybackSpeed", 0.1, 5, 0.34)
    slider(T("PitchLabel"), "Pitch", 0.1, 5, 0.68)

    local fullBtn = ActionButton(content, Icons.UI.Settings, T("OpenFullEditor"), P.Surface, {
        size = UDim2.new(0.6, -4, 0, 40), textSize = 12,
        callback = function()
            local SoundEditor = GetModule("SoundEditor")
            SoundEditor.Open(window, instance, function() end)
        end
    })
    fullBtn.Position = UDim2.new(0.2, 0, 0, 222)

    local infoScroll = Scroller(content, UDim2.new(1, -4, 0, 150), UDim2.new(0, 2, 0, 272))
    InfoRow(infoScroll, T("SoundId"), info.SoundId or "", 1)
    InfoRow(infoScroll, T("TimePosition"), string.format("%.1fs / %.1fs", instance.TimePosition or 0, info.SoundLength or 0), 2)
    InfoRow(infoScroll, T("VolumeLabel"), tostring(info.Volume), 3)
    InfoRow(infoScroll, T("PlayPreview"), instance.IsPlaying and "Yes" or "No", 4)

    return function()
        pcall(function() instance:Stop() end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: صورة
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildImagePreview(content, instance, info, window)
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(1, -4, 1, -60)
    preview.Position = UDim2.new(0, 2, 0, 0)
    preview.BackgroundColor3 = Color3.fromRGB(10, 12, 24)
    preview.ClipsDescendants = true
    preview.Parent = content
    Corner(preview, 10)
    Stroke(preview, P.Border, 1, 0.5)

    local checker = Instance.new("ImageLabel")
    checker.Size = UDim2.new(1, 0, 1, 0)
    checker.BackgroundTransparency = 0.85
    checker.Image = "rbxassetid://5733715132"
    checker.ScaleType = Enum.ScaleType.Tile
    checker.TileSize = UDim2.new(0, 40, 0, 40)
    checker.Parent = preview

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -24, 1, -24)
    img.Position = UDim2.new(0, 12, 0, 12)
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = preview
    pcall(function()
        if instance:IsA("Decal") or instance:IsA("Texture") then
            img.Image = instance.Texture
            img.ImageTransparency = instance.Transparency
        else
            img.Image = instance.Image
            img.ImageTransparency = instance.ImageTransparency
        end
    end)
    if not img.Image or img.Image == "" then
        EmptyState(preview, Icons.UI.Image, T("ImageNotAvailable"), info.ImageId or "")
    end

    local idRow = Instance.new("Frame")
    idRow.Size = UDim2.new(1, -4, 0, 46)
    idRow.Position = UDim2.new(0, 2, 1, -50)
    idRow.BackgroundColor3 = P.Header
    idRow.Parent = content
    Corner(idRow, 8)
    local idText = TextLabel(idRow, info.ImageId or "", 11, P.Muted, Enum.Font.Code, Language.Alignment())
    idText.Size = UDim2.new(1, -200, 1, 0)
    idText.Position = UDim2.new(0, 10, 0, 0)
    local copyId = ActionButton(idRow, Icons.UI.Copy, T("CopyId"), P.Surface, {
        size = UDim2.new(0, 84, 0, 30), textSize = 10,
        callback = function()
            if CopyToClipboard(info.ImageId or "") then Notify(window, T("Copied"), "success") end
        end
    })
    copyId.Position = UDim2.new(1, -96, 0.5, -15)
    local openEditor = ActionButton(idRow, Icons.UI.Settings, T("OpenFullEditor"), P.Surface, {
        size = UDim2.new(0, 92, 0, 30), textSize = 10,
        callback = function()
            local ImageEditor = GetModule("ImageEditor")
            ImageEditor.Open(window, instance, function() end)
        end
    })
    openEditor.Position = UDim2.new(1, -200, 0.5, -15)

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: فيديو
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildVideoPreview(content, instance, info, window)
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(1, -4, 1, -60)
    preview.Position = UDim2.new(0, 2, 0, 0)
    preview.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    preview.ClipsDescendants = true
    preview.Parent = content
    Corner(preview, 10)
    Stroke(preview, P.Border, 1, 0.5)

    local video
    pcall(function()
        video = StripScripts(instance:Clone())
        video.Size = UDim2.new(1, -20, 1, -20)
        video.Position = UDim2.new(0, 10, 0, 10)
        video.Parent = preview
    end)
    if not video then
        EmptyState(preview, Icons.UI.Video, T("PreviewUnavailable"), "")
    end

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -4, 0, 46)
    bar.Position = UDim2.new(0, 2, 1, -50)
    bar.BackgroundColor3 = P.Header
    bar.Parent = content
    Corner(bar, 8)

    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 330, 1, 0)
    controls.Position = UDim2.new(1, -336, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = bar
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.Parent = controls

    local function reloadVideo()
        if video then video:Destroy() end
        video = nil
        pcall(function()
            video = StripScripts(instance:Clone())
            video.Size = UDim2.new(1, -20, 1, -20)
            video.Position = UDim2.new(0, 10, 0, 10)
            video.Parent = preview
        end)
    end

    ActionButton(controls, Icons.UI.Restart, T("PlayPreview"), P.AccentStrong, {
        size = UDim2.new(0, 96, 0, 32), textSize = 10,
        iconColor = P.Text, textColor = P.Text, callback = reloadVideo
    })
    local loopBtn = ActionButton(controls, Icons.UI.Loop, T("LoopOff"), P.Surface, {
        size = UDim2.new(0, 96, 0, 32), textSize = 10, callback = function()
            if video then
                pcall(function() video.Looped = not video.Looped end)
                pcall(function() loopBtn.TextLabel.Text = video.Looped and T("LoopOn") or T("LoopOff") end)
            end
        end
    })
    pcall(function()
        if video then loopBtn.TextLabel.Text = video.Looped and T("LoopOn") or T("LoopOff") end
    end)

    local idText = TextLabel(bar, (pcall(function() return instance.Video end) and instance.Video) or "", 10, P.Muted, Enum.Font.Code, Language.Alignment())
    idText.Size = UDim2.new(1, -350, 1, 0)
    idText.Position = UDim2.new(0, 10, 0, 0)

    return function()
        if video then video:Destroy() end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: مجسمات وأجزاء (ViewportFrame ثلاثي الأبعاد)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildModelPreview(content, instance, info, window)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 1, -60)
    holder.Position = UDim2.new(0, 2, 0, 0)
    holder.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
    holder.ClipsDescendants = true
    holder.Parent = content
    Corner(holder, 10)
    Stroke(holder, P.Border, 1, 0.5)

    -- لا نستنسخ الخدمات أو اللعبة نفسها أبداً
    local isRoot = pcall(function() return instance:IsA("DataModel") end) and instance:IsA("DataModel")
    if isRoot or instance == game or instance == workspace then
        EmptyState(holder, Icons.UI.Model, T("PreviewUnavailable"), T("ProtectedLabel"))
        return function() end
    end

    local descendantCount = 0
    pcall(function() descendantCount = #instance:GetDescendants() end)
    if descendantCount > 800 then
        EmptyState(holder, Icons.UI.Model, T("PreviewUnavailable"), string.format(T("PreviewTooLarge"), descendantCount))
        return function() end
    end

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, 0, 1, 0)
    viewport.BackgroundColor3 = Color3.fromRGB(9, 11, 24)
    viewport.Ambient = Color3.fromRGB(120, 130, 160)
    viewport.LightColor = Color3.fromRGB(255, 250, 235)
    viewport.LightDirection = Vector3.new(-0.6, -0.9, -0.5)
    viewport.Parent = holder

    local worldModel = Instance.new("Model")
    worldModel.Name = "WiliPreviewWorld"

    local cloneOk = pcall(function()
        StripScripts(instance:Clone()).Parent = worldModel
        worldModel.Parent = viewport
    end)

    local camera = Instance.new("Camera")
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    camera.FieldOfView = 40

    local center = Vector3.new(0, 0, 0)
    local baseOffset = Vector3.new(8, 5, 12)

    if cloneOk then
        local bboxOk, res = pcall(function()
            local cf, size = worldModel:GetBoundingBox()
            return {cf = cf, size = size}
        end)
        if bboxOk and res and res.cf then
            center = res.cf.Position
            local extent = math.max(0.5, math.max(res.size.X, math.max(res.size.Y, res.size.Z)))
            baseOffset = Vector3.new(extent * 1.2, extent * 0.75, extent * 1.4)
            camera.CFrame = CFrame.lookAt(center + baseOffset, center)
        else
            camera.CFrame = CFrame.lookAt(Vector3.new(8, 5, 12), Vector3.new(0, 0, 0))
        end
    else
        EmptyState(holder, Icons.UI.Model, T("PreviewUnavailable"), "")
    end

    -- أدوات التحكم
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(0, 330, 1, 0)
    controls.Position = UDim2.new(1, -330, 0, 0)
    controls.BackgroundTransparency = 1
    controls.Parent = holder
    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0, 6)
    cLayout.Parent = controls
    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 10)
    cPad.PaddingLeft = UDim.new(0, 4)
    cPad.Parent = controls

    local spinning = true
    local angle = 0

    local spinBtn = ActionButton(controls, Icons.UI.Restart, T("SpinView"), P.Success, {
        size = UDim2.new(0, 160, 0, 34), textSize = 10,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            spinning = not spinning
            spinBtn.TextLabel.Text = spinning and T("SpinView") or T("PausePreview")
        end
    })

    local resetBtn = ActionButton(controls, Icons.UI.Refresh, T("ResetView"), P.Surface, {
        size = UDim2.new(0, 160, 0, 34), textSize = 10, callback = function()
            angle = 0
            camera.CFrame = CFrame.lookAt(center + baseOffset, center)
        end
    })

    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function(dt)
        if not viewport.Parent then
            heartbeat:Disconnect()
            return
        end
        if spinning and cloneOk then
            angle = angle + dt * 0.5
            local offset = CFrame.Angles(0, angle, 0) * baseOffset
            camera.CFrame = CFrame.lookAt(center + offset, center)
        end
    end)

    -- معلومات المجسم
    local infoBar = Instance.new("Frame")
    infoBar.Size = UDim2.new(1, -4, 0, 46)
    infoBar.Position = UDim2.new(0, 2, 1, -50)
    infoBar.BackgroundColor3 = P.Header
    infoBar.Parent = content
    Corner(infoBar, 8)
    local metaText = TextLabel(infoBar, string.format(
        "%s: %s • %s: %d • %s: %s",
        T("ClassLabel"), info.ClassName, T("DescendantsLabel"), info.Descendants,
        T("CategoryLabel"), info.Category
    ), 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
    metaText.Size = UDim2.new(1, -20, 1, 0)
    metaText.Position = UDim2.new(0, 10, 0, 0)

    return function()
        if heartbeat then heartbeat:Disconnect() end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: حركات (KeyframeSequence / Animator / AnimationController)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildAnimationPreview(content, instance, info, window)
    local iconHolder = Instance.new("Frame")
    iconHolder.Size = UDim2.new(1, -4, 0, 92)
    iconHolder.Position = UDim2.new(0, 2, 0, 0)
    iconHolder.BackgroundColor3 = P.Surface
    iconHolder.Parent = content
    Corner(iconHolder, 10)
    Stroke(iconHolder, P.Pink, 1, 0.4)
    local bigIcon = IconLabel(iconHolder, Icons.UI.Animation, 36, P.Pink, 3)
    bigIcon.Size = UDim2.new(0, 50, 0, 50)
    bigIcon.Position = UDim2.new(0.5, -25, 0, 10)
    local typeText = TextLabel(iconHolder, info.ClassName, 12, P.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    typeText.Size = UDim2.new(1, 0, 0, 20)
    typeText.Position = UDim2.new(0, 0, 0, 64)

    local length = 0
    if instance:IsA("KeyframeSequence") then
        pcall(function()
            local tempHumanoid = Instance.new("Humanoid")
            local tempAnimator = Instance.new("Animator")
            tempAnimator.Parent = tempHumanoid
            local track = tempAnimator:LoadAnimation(instance)
            length = track.Length
            track:Destroy()
            tempAnimator:Destroy()
            tempHumanoid:Destroy()
        end)
        if length <= 0 then
            for _, keyframe in ipairs(instance:GetChildren()) do
                if keyframe:IsA("Keyframe") then
                    length = math.max(length, keyframe.Time or 0)
                    for _, pose in ipairs(keyframe:GetChildren()) do
                        for _, curve in ipairs(pose:GetChildren()) do
                            for _, k in ipairs(curve:GetChildren()) do
                                if k:IsA("Keyframe") then
                                    length = math.max(length, (keyframe.Time or 0) + (k.Time or 0))
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local infoScroll = Scroller(content, UDim2.new(1, -4, 0, 170), UDim2.new(0, 2, 0, 100))
    InfoRow(infoScroll, T("AnimationLength"), string.format("%.2fs", length), 1)
    InfoRow(infoScroll, T("Keyframes"), #instance:GetChildren(), 2)
    if instance:IsA("AnimationTrack") then
        InfoRow(infoScroll, T("AnimationLooped"), tostring(instance.Looped), 3)
        InfoRow(infoScroll, T("AnimationPriority"), tostring(instance.Priority), 4)
        InfoRow(infoScroll, T("PlayPreview"), tostring(instance.IsPlaying), 5)
    end

    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -4, 0, 52)
    controls.Position = UDim2.new(0, 2, 0, 278)
    controls.BackgroundTransparency = 1
    controls.Parent = content
    local cLayout = Instance.new("UIListLayout")
    cLayout.FillDirection = Enum.FillDirection.Horizontal
    cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cLayout.Padding = UDim.new(0, 8)
    cLayout.Parent = controls

    local activeTrack = nil
    local playOnChar = ActionButton(controls, Icons.UI.Play, T("RigPlay"), P.Success, {
        size = UDim2.new(0, 210, 0, 40), textSize = 11,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            if activeTrack then
                pcall(function() activeTrack:Stop() activeTrack:Destroy() end)
                activeTrack = nil
                playOnChar.TextLabel.Text = T("RigPlay")
                return
            end
            local character = LocalPlayer and LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
            if not animator or not instance:IsA("KeyframeSequence") then
                Notify(window, T("RigNoCharacter"), "warning")
                return
            end
            local ok, track = pcall(function() return animator:LoadAnimation(instance) end)
            if ok and track then
                activeTrack = track
                pcall(function() track:Play() end)
                playOnChar.TextLabel.Text = T("RigStop")
            else
                Notify(window, T("ActionFailed"), "error")
            end
        end
    })
    if not instance:IsA("KeyframeSequence") then
        playOnChar.Visible = false
    end

    return function()
        if activeTrack then
            pcall(function() activeTrack:Stop() activeTrack:Destroy() end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: واجهات GUI (نسخة مصغّرة)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildGuiPreview(content, instance, info, window)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 1, -60)
    holder.Position = UDim2.new(0, 2, 0, 0)
    holder.BackgroundColor3 = Color3.fromRGB(20, 22, 40)
    holder.ClipsDescendants = true
    holder.Parent = content
    Corner(holder, 10)
    Stroke(holder, P.Border, 1, 0.5)

    local stage = Instance.new("Frame")
    stage.Size = UDim2.new(1, -24, 1, -24)
    stage.Position = UDim2.new(0, 12, 0, 12)
    stage.BackgroundColor3 = Color3.fromRGB(13, 15, 30)
    stage.ClipsDescendants = true
    stage.Parent = holder
    Corner(stage, 8)

    local previewRoot
    local isLayer = instance:IsA("LayerCollector")

    local function rebuild()
        if previewRoot then previewRoot:Destroy() end
        previewRoot = nil
        if isLayer then
            local root = Instance.new("Frame")
            root.Size = UDim2.new(1, 0, 1, 0)
            root.BackgroundTransparency = 1
            root.Parent = stage
            pcall(function()
                for _, child in ipairs(instance:GetChildren()) do
                    if child:IsA("GuiObject") then
                        StripScripts(child:Clone()).Parent = root
                    end
                end
            end)
            previewRoot = root
        else
            pcall(function()
                local root = StripScripts(instance:Clone())
                root.AnchorPoint = Vector2.new(0.5, 0.5)
                root.Position = UDim2.new(0.5, 0, 0.5, 0)
                root.Parent = stage
                previewRoot = root
            end)
        end
        applyScale()
    end

    local function applyScale()
        if not previewRoot then return end
        task.defer(function()
            if not previewRoot or not previewRoot.Parent then return end
            local target = previewRoot.AbsoluteSize
            local avail = stage.AbsoluteSize
            if target.X > 0 and target.Y > 0 and avail.X > 0 and avail.Y > 0 then
                local scale = math.clamp(math.min(avail.X / target.X, avail.Y / target.Y), 0.05, 1.5)
                local s = previewRoot:FindFirstChildOfClass("UIScale")
                if s then
                    s.Scale = scale
                elseif previewRoot:IsA("GuiObject") then
                    s = Instance.new("UIScale")
                    s.Scale = scale
                    s.Parent = previewRoot
                end
            end
        end)
    end

    rebuild()

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -4, 0, 46)
    bar.Position = UDim2.new(0, 2, 1, -50)
    bar.BackgroundColor3 = P.Header
    bar.Parent = content
    Corner(bar, 8)

    local metaText = TextLabel(bar, string.format("%s: %s • %s: %s", T("ClassLabel"), info.ClassName, T("SizeLabel"), info.GuiSize), 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
    metaText.Size = UDim2.new(1, -230, 1, 0)
    metaText.Position = UDim2.new(0, 10, 0, 0)

    local scaleBox = Instance.new("TextBox")
    scaleBox.Size = UDim2.new(0, 62, 0, 30)
    scaleBox.Position = UDim2.new(1, -148, 0.5, -15)
    scaleBox.BackgroundColor3 = P.Raised
    scaleBox.TextColor3 = P.Text
    scaleBox.TextSize = 11
    scaleBox.Font = Enum.Font.Code
    scaleBox.ClearTextOnFocus = false
    scaleBox.Text = "100%"
    scaleBox.Parent = bar
    Corner(scaleBox, 6)
    scaleBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and previewRoot then
            local v = tonumber(scaleBox.Text:gsub("%%", ""))
            if v then
                v = math.clamp(v, 5, 200) / 100
                local s = previewRoot:FindFirstChildOfClass("UIScale")
                if s then s.Scale = v else
                    s = Instance.new("UIScale")
                    s.Scale = v
                    s.Parent = previewRoot
                end
                scaleBox.Text = string.format("%d%%", math.floor(v * 100 + 0.5))
            end
        end
    end)

    local reloadBtn = ActionButton(bar, Icons.UI.Refresh, "", P.Surface, {
        size = UDim2.new(0, 40, 0, 30), compact = true, callback = rebuild
    })
    reloadBtn.Position = UDim2.new(1, -74, 0.5, -15)

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: تأثيرات (داخل Viewport مع مفتاح تشغيل)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildEffectPreview(content, instance, info, window)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 1, -60)
    holder.Position = UDim2.new(0, 2, 0, 0)
    holder.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
    holder.ClipsDescendants = true
    holder.Parent = content
    Corner(holder, 10)
    Stroke(holder, P.Border, 1, 0.5)

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.new(1, 0, 1, 0)
    viewport.BackgroundColor3 = Color3.fromRGB(9, 11, 24)
    viewport.Ambient = Color3.fromRGB(130, 135, 150)
    viewport.LightColor = Color3.fromRGB(255, 250, 235)
    viewport.LightDirection = Vector3.new(-0.5, -0.8, -0.4)
    viewport.Parent = holder

    local worldModel = Instance.new("Model")
    worldModel.Name = "WiliEffectWorld"
    worldModel.Parent = viewport

    local demoPart = Instance.new("Part")
    demoPart.Name = "DemoPart"
    demoPart.Size = Vector3.new(2.4, 2.4, 2.4)
    demoPart.Anchored = true
    demoPart.Position = Vector3.new(0, 3, 0)
    demoPart.Material = Enum.Material.Neon
    demoPart.Color = Color3.fromRGB(80, 90, 130)
    demoPart.Parent = worldModel

    local secondPart
    local effectClone
    local ok = pcall(function()
        effectClone = instance:Clone()
        effectClone.Parent = demoPart
        if instance:IsA("Beam") or instance:IsA("Trail") then
            secondPart = Instance.new("Part")
            secondPart.Size = Vector3.new(1.2, 1.2, 1.2)
            secondPart.Anchored = true
            secondPart.Position = Vector3.new(4, 5, 2)
            secondPart.Material = Enum.Material.Neon
            secondPart.Parent = worldModel
            local a0 = Instance.new("Attachment")
            a0.Position = Vector3.new(0, 1, 0)
            a0.Parent = demoPart
            local a1 = Instance.new("Attachment")
            a1.Parent = secondPart
            if instance:IsA("Beam") then
                effectClone.Attachment0 = a0
                effectClone.Attachment1 = a1
            end
            if instance:IsA("Trail") then
                effectClone.Attachment0 = a0
            end
        end
        if effectClone.Enabled ~= nil then
            effectClone.Enabled = true
        end
    end)
    if not ok or not effectClone then
        EmptyState(holder, Icons.UI.Effect, T("PreviewUnavailable"), "")
    end

    local camera = Instance.new("Camera")
    camera.Parent = viewport
    camera.CFrame = CFrame.lookAt(Vector3.new(7, 6, 9), Vector3.new(0, 3, 0))
    camera.FieldOfView = 45
    viewport.CurrentCamera = camera

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -4, 0, 46)
    bar.Position = UDim2.new(0, 2, 1, -50)
    bar.BackgroundColor3 = P.Header
    bar.Parent = content
    Corner(bar, 8)

    local toggle = ActionButton(bar, Icons.UI.Play, T("EffectToggle"), P.Success, {
        size = UDim2.new(0, 150, 0, 32), textSize = 10,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            if effectClone and effectClone.Enabled ~= nil then
                pcall(function() effectClone.Enabled = not effectClone.Enabled end)
                toggle.TextLabel.Text = effectClone.Enabled and T("EffectEnabled") or T("EffectToggle")
            end
        end
    })
    pcall(function()
        if effectClone and effectClone.Enabled ~= nil then
            toggle.TextLabel.Text = effectClone.Enabled and T("EffectEnabled") or T("EffectToggle")
        end
    end)
    toggle.Position = UDim2.new(1, -162, 0.5, -16)

    local metaText = TextLabel(bar, string.format("%s: %s", T("ClassLabel"), info.ClassName), 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
    metaText.Size = UDim2.new(1, -180, 1, 0)
    metaText.Position = UDim2.new(0, 10, 0, 0)

    local spinLoop
    spinLoop = RunService.Heartbeat:Connect(function(dt)
        if not demoPart.Parent then
            spinLoop:Disconnect()
            return
        end
        demoPart.CFrame = demoPart.CFrame * CFrame.Angles(0, dt * 1.2, 0)
        if secondPart and secondPart.Parent then
            local t = tick() * 0.6
            secondPart.Position = Vector3.new(math.cos(t) * 5, 5 + math.sin(t * 1.4) * 1.5, math.sin(t) * 5)
        end
    end)

    return function()
        if spinLoop then spinLoop:Disconnect() end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: إضاءة (تحكم كامل)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildLightPreview(content, instance, info, window)
    local swatchHolder = Instance.new("Frame")
    swatchHolder.Size = UDim2.new(1, -4, 0, 110)
    swatchHolder.Position = UDim2.new(0, 2, 0, 0)
    swatchHolder.BackgroundColor3 = P.Surface
    swatchHolder.Parent = content
    Corner(swatchHolder, 10)
    Stroke(swatchHolder, P.Warning, 1, 0.4)

    local swatch = Instance.new("Frame")
    swatch.Size = UDim2.new(0, 84, 0, 84)
    swatch.Position = UDim2.new(0.5, -42, 0, 12)
    swatch.Parent = swatchHolder
    Corner(swatch, 14)
    Stroke(swatch, P.Text, 2, 0.3)
    pcall(function() swatch.BackgroundColor3 = instance.Color end)

    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(0, 150, 0, 150)
    glow.Position = UDim2.new(0.5, -75, 0, -21)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://1227698400"
    glow.Parent = swatchHolder
    pcall(function() glow.ImageColor3 = instance.Color end)
    task.spawn(function()
        while glow and glow.Parent do
            Tween(glow, {ImageTransparency = 0.75}, 0.9)
            task.wait(0.9)
            Tween(glow, {ImageTransparency = 0.3}, 0.9)
            task.wait(0.9)
        end
    end)

    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -4, 0, 96)
    controls.Position = UDim2.new(0, 2, 0, 116)
    controls.BackgroundTransparency = 1
    controls.Parent = content

    local function lightSlider(name, prop, min, max, x, y)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0.46, -6, 0, 44)
        holder.Position = UDim2.new(x, 0, y, 0)
        holder.BackgroundTransparency = 1
        holder.Parent = controls
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -8, 0, 30)
        box.Position = UDim2.new(0, 0, 0, 0)
        box.BackgroundColor3 = P.Raised
        box.TextColor3 = P.Text
        box.TextSize = 12
        box.Font = Enum.Font.Code
        box.ClearTextOnFocus = false
        box.Parent = holder
        Corner(box, 7)
        pcall(function() box.Text = tostring(instance[prop]) end)
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local v = tonumber(box.Text)
                if v then
                    v = math.clamp(v, min, max)
                    pcall(function() instance[prop] = v end)
                    box.Text = tostring(v)
                end
            end
        end)
        local label = TextLabel(holder, name, 9, P.Dim, Enum.Font.GothamBold, Language.Alignment())
        label.Size = UDim2.new(1, -8, 0, 12)
        label.Position = UDim2.new(0, 4, 0, 31)
        return holder, box
    end

    lightSlider(T("LightBrightness"), "Brightness", 0, 60, 0, 0)
    lightSlider(T("LightRange"), "Range", 1, 300, 0.54, 0)
    local angleHolder, angleBox = lightSlider(T("LightAngle"), "Angle", 1, 180, 0.54, 48)
    if not instance:IsA("SpotLight") and not instance:IsA("SurfaceLight") then
        angleHolder.Visible = false
    end

    local shadowsBtn = ActionButton(content, Icons.UI.Preview, T("LightShadows"), P.Surface, {
        size = UDim2.new(0.46, -6, 0, 40), textSize = 11, callback = function()
            local enabled = false
            pcall(function() enabled = instance.Shadows end)
            pcall(function() instance.Shadows = not enabled end)
            pcall(function() shadowsBtn.TextLabel.Text = T("LightShadows") .. ": " .. (instance.Shadows and "✓" or "×") end)
        end
    })
    shadowsBtn.Position = UDim2.new(0, 2, 0, 218)
    pcall(function() shadowsBtn.TextLabel.Text = T("LightShadows") .. ": " .. (instance.Shadows and "✓" or "×") end)

    local colorBtn = ActionButton(content, Icons.UI.Palette, T("LightColor"), P.Surface, {
        size = UDim2.new(0.46, -6, 0, 40), textSize = 11, callback = function()
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -4, 0, 58)
            holder.Position = UDim2.new(0, 2, 0, 264)
            holder.BackgroundColor3 = P.Surface
            holder.Parent = content
            Corner(holder, 8)
            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Horizontal
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            layout.Padding = UDim.new(0, 6)
            layout.Parent = holder
            local inputs = {}
            for _, ch in ipairs({T("ColorR"), T("ColorG"), T("ColorB")}) do
                local box = Instance.new("TextBox")
                box.Size = UDim2.new(0, 62, 0, 34)
                box.BackgroundColor3 = P.Raised
                box.TextColor3 = P.Text
                box.TextSize = 12
                box.Font = Enum.Font.Code
                box.ClearTextOnFocus = false
                box.PlaceholderText = ch
                box.Parent = holder
                Corner(box, 7)
                table.insert(inputs, box)
            end
            pcall(function()
                inputs[1].Text = tostring(math.floor(instance.Color.R * 255))
                inputs[2].Text = tostring(math.floor(instance.Color.G * 255))
                inputs[3].Text = tostring(math.floor(instance.Color.B * 255))
            end)
            ActionButton(holder, Icons.UI.Success, T("ApplyColor"), P.Success, {
                size = UDim2.new(0, 82, 0, 34), textSize = 11,
                iconColor = P.DarkText, textColor = P.DarkText, callback = function()
                    local r = tonumber(inputs[1].Text)
                    local g = tonumber(inputs[2].Text)
                    local b = tonumber(inputs[3].Text)
                    if r and g and b then
                        local color = Color3.fromRGB(math.clamp(math.floor(r), 0, 255), math.clamp(math.floor(g), 0, 255), math.clamp(math.floor(b), 0, 255))
                        pcall(function() instance.Color = color end)
                        swatch.BackgroundColor3 = color
                        glow.ImageColor3 = color
                        Notify(window, T("ValueSaved"), "success")
                    end
                end
            })
        end
    })
    colorBtn.Position = UDim2.new(0.54, -2, 0, 218)

    local infoScroll = Scroller(content, UDim2.new(1, -4, 0, 110), UDim2.new(0, 2, 0, 330))
    InfoRow(infoScroll, T("LightShadows"), tostring(instance.Shadows), 1)
    InfoRow(infoScroll, T("LightBrightness"), tostring(instance.Brightness), 2)
    InfoRow(infoScroll, T("LightRange"), tostring(instance.Range), 3)

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: قيم (محرر مدمج لكل الأنواع)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildValuePreview(content, instance, info, window)
    if instance:IsA("BoolValue") then
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -4, 0, 130)
        holder.Position = UDim2.new(0, 2, 0, 0)
        holder.BackgroundColor3 = P.Surface
        holder.Parent = content
        Corner(holder, 10)
        Stroke(holder, P.Accent, 1, 0.4)
        local state = TextLabel(holder, tostring(instance.Value), 24, instance.Value and P.Success or P.Danger, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
        state.Size = UDim2.new(1, 0, 0, 60)
        state.Position = UDim2.new(0, 0, 0, 10)
        local toggle = ActionButton(holder, Icons.UI.Refresh, tostring(instance.Value), instance.Value and P.Success or P.Danger, {
            size = UDim2.new(0.6, 0, 0, 38), textSize = 13,
            iconColor = P.DarkText, textColor = P.DarkText, callback = function()
                pcall(function() instance.Value = not instance.Value end)
                local v = false
                pcall(function() v = instance.Value end)
                state.Text = tostring(v)
                state.TextColor3 = v and P.Success or P.Danger
                toggle.TextLabel.Text = tostring(v)
                Notify(window, T("ValueSaved"), "success")
            end
        })
        toggle.Position = UDim2.new(0.2, 0, 1, -50)
        return function() end
    end

    if instance:IsA("Color3Value") or instance:IsA("BrickColorValue") then
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -4, 0, 180)
        holder.Position = UDim2.new(0, 2, 0, 0)
        holder.BackgroundColor3 = P.Surface
        holder.Parent = content
        Corner(holder, 10)
        Stroke(holder, P.Accent, 1, 0.4)
        local swatch = Instance.new("Frame")
        swatch.Size = UDim2.new(0, 70, 0, 70)
        swatch.Position = UDim2.new(0.5, -35, 0, 12)
        swatch.Parent = holder
        Corner(swatch, 12)
        Stroke(swatch, P.Text, 2, 0.2)
        pcall(function() swatch.BackgroundColor3 = instance.Value end)
        local inputs = {}
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -40, 0, 40)
        row.Position = UDim2.new(0, 20, 0, 92)
        row.BackgroundTransparency = 1
        row.Parent = holder
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 8)
        layout.Parent = row
        for _, ch in ipairs({T("ColorR"), T("ColorG"), T("ColorB")}) do
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 72, 0, 34)
            box.BackgroundColor3 = P.Raised
            box.TextColor3 = P.Text
            box.TextSize = 12
            box.Font = Enum.Font.Code
            box.ClearTextOnFocus = false
            box.PlaceholderText = ch
            box.Parent = row
            Corner(box, 7)
            table.insert(inputs, box)
        end
        pcall(function()
            local c = instance.Value
            if c then
                inputs[1].Text = tostring(math.floor(c.R * 255))
                inputs[2].Text = tostring(math.floor(c.G * 255))
                inputs[3].Text = tostring(math.floor(c.B * 255))
            end
        end)
        local apply = ActionButton(holder, Icons.UI.Success, T("ApplyColor"), P.Success, {
            size = UDim2.new(0, 140, 0, 36), textSize = 11,
            iconColor = P.DarkText, textColor = P.DarkText, callback = function()
                local r = tonumber(inputs[1].Text)
                local g = tonumber(inputs[2].Text)
                local b = tonumber(inputs[3].Text)
                if r and g and b then
                    local color = Color3.fromRGB(math.clamp(math.floor(r), 0, 255), math.clamp(math.floor(g), 0, 255), math.clamp(math.floor(b), 0, 255))
                    pcall(function() instance.Value = color end)
                    swatch.BackgroundColor3 = color
                    Notify(window, T("ValueSaved"), "success")
                else
                    Notify(window, T("InvalidValue"), "error")
                end
            end
        })
        apply.Position = UDim2.new(0.5, -70, 1, -44)
        return function() end
    end

    if instance:IsA("ObjectValue") then
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -4, 0, 100)
        holder.Position = UDim2.new(0, 2, 0, 0)
        holder.BackgroundColor3 = P.Surface
        holder.Parent = content
        Corner(holder, 10)
        Stroke(holder, P.Accent, 1, 0.4)
        local target = TextLabel(holder, "", 14, P.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        target.Size = UDim2.new(1, -20, 0, 40)
        target.Position = UDim2.new(0, 10, 0, 10)
        pcall(function()
            target.Text = instance.Value and instance.Value:GetFullName() or "nil"
        end)
        local openBtn = ActionButton(holder, Icons.UI.Forward, T("OpenInViewer"), P.Surface, {
            size = UDim2.new(0.5, 0, 0, 38), textSize = 11, callback = function()
                if instance.Value then
                    FileViewer.Open(window.Parent.Parent, instance.Value, nil)
                end
            end
        })
        openBtn.Position = UDim2.new(0.25, 0, 1, -46)
        return function() end
    end

    -- نصوص وأرقام وأي قيمة أخرى
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 170)
    holder.Position = UDim2.new(0, 2, 0, 0)
    holder.BackgroundColor3 = P.Surface
    holder.Parent = content
    Corner(holder, 10)
    Stroke(holder, P.Accent, 1, 0.4)

    local typeLabel = TextLabel(holder, info.ClassName, 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    typeLabel.Size = UDim2.new(1, -24, 0, 18)
    typeLabel.Position = UDim2.new(0, 12, 0, 10)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -40, 0, 44)
    box.Position = UDim2.new(0, 20, 0, 36)
    box.BackgroundColor3 = P.Raised
    box.TextColor3 = P.Text
    box.TextSize = 13
    box.Font = Enum.Font.Code
    box.ClearTextOnFocus = false
    box.Parent = holder
    Corner(box, 8)
    pcall(function() box.Text = tostring(instance.Value) end)

    local saveBtn = ActionButton(holder, Icons.UI.Save, T("Save"), P.Success, {
        size = UDim2.new(0, 140, 0, 38), textSize = 12,
        iconColor = P.DarkText, textColor = P.DarkText, callback = function()
            local ok = false
            if instance:IsA("NumberValue") or instance:IsA("IntValue") then
                local n = tonumber(box.Text)
                if n then
                    pcall(function() instance.Value = n end)
                    ok = true
                end
            elseif instance:IsA("StringValue") then
                pcall(function() instance.Value = box.Text end)
                ok = true
            else
                pcall(function() instance.Value = box.Text end)
                ok = true
            end
            if ok then
                Notify(window, T("ValueSaved"), "success")
            else
                Notify(window, T("InvalidValue"), "error")
            end
        end
    })
    saveBtn.Position = UDim2.new(0.5, -70, 1, -48)

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة: اتصالات (Remotes)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildRemotePreview(content, instance, info, window)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 130)
    holder.Position = UDim2.new(0, 2, 0, 0)
    holder.BackgroundColor3 = P.Surface
    holder.Parent = content
    Corner(holder, 10)
    Stroke(holder, P.Purple, 1, 0.4)

    local kind = instance:IsA("RemoteFunction") and "RemoteFunction"
        or instance:IsA("BindableFunction") and "BindableFunction"
        or instance:IsA("BindableEvent") and "BindableEvent" or "RemoteEvent"
    local isFunction = kind == "RemoteFunction" or kind == "BindableFunction"

    local typeText = TextLabel(holder, kind, 13, P.Purple, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    typeText.Size = UDim2.new(1, 0, 0, 22)
    typeText.Position = UDim2.new(0, 0, 0, 10)

    local fireBtn = ActionButton(holder, Icons.UI.Fire, isFunction and T("InvokeFunction") or T("FireEvent"), P.Danger, {
        size = UDim2.new(0.5, -20, 0, 42), textSize = 12,
        iconColor = P.Text, textColor = P.Text, callback = function()
            local ok, result = pcall(function()
                if instance:IsA("RemoteEvent") or instance:IsA("UnreliableRemoteEvent") then
                    instance:FireServer()
                elseif instance:IsA("BindableEvent") then
                    instance:Fire()
                elseif instance:IsA("RemoteFunction") then
                    return instance:InvokeServer()
                elseif instance:IsA("BindableFunction") then
                    return instance:Invoke()
                end
            end)
            if ok then
                Notify(window, result ~= nil and tostring(result):sub(1, 40) or T("RunDone"), "success")
            else
                Notify(window, tostring(result):sub(1, 80), "error")
            end
        end
    })
    fireBtn.Position = UDim2.new(0.25, 0, 1, -54)

    local infoScroll = Scroller(content, UDim2.new(1, -4, 0, 120), UDim2.new(0, 2, 0, 138))
    InfoRow(infoScroll, T("ClassLabel"), info.ClassName, 1)
    InfoRow(infoScroll, T("RemoteType"), info.RemoteType, 2)
    local count = 0
    pcall(function()
        if getconnections and instance.OnClientEvent then
            count = #getconnections(instance.OnClientEvent)
        end
    end)
    InfoRow(infoScroll, T("Connections"), count > 0 and tostring(count) or T("NoListeners"), 3)

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- معاينة افتراضية: معلومات غنية + وسوم + Attributes + عناصر فرعية
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildDefaultPreview(content, instance, info, window, mainParent)
    local scroll = Scroller(content, UDim2.new(1, -4, 1, 0), UDim2.new(0, 2, 0, 0))

    local about = TextLabel(scroll, T("AboutLabel"), 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    about.Size = UDim2.new(1, 0, 0, 20)
    about.LayoutOrder = 1

    InfoRow(scroll, T("ClassLabel"), info.ClassName, 2)
    InfoRow(scroll, T("ParentLabel"), info.Parent ~= "" and info.Parent or "-", 3)
    InfoRow(scroll, T("Path"), info.FullName, 4)
    InfoRow(scroll, T("TabChildren"), tostring(info.Children), 5)
    InfoRow(scroll, T("DescendantsLabel"), tostring(info.Descendants), 6)
    InfoRow(scroll, T("CategoryLabel"), info.Category, 7)
    if info.Description and info.Description ~= "" then
        InfoRow(scroll, T("DescriptionLabel"), info.Description, 8)
    end
    InfoRow(scroll, T("Editable"), info.CanEdit and T("Editable") or T("ReadOnly"), 9, info.CanEdit and P.Success or P.Warning)

    -- Attributes
    local attrTitle = TextLabel(scroll, T("AttributesLabel"), 11, P.Gold, Enum.Font.GothamBold, Language.Alignment())
    attrTitle.Size = UDim2.new(1, 0, 0, 20)
    attrTitle.LayoutOrder = 10
    local hasAttrs = false
    if info.Attributes then
        for k, v in pairs(info.Attributes) do
            hasAttrs = true
            InfoRow(scroll, tostring(k), tostring(v), 11)
        end
    end
    if not hasAttrs then
        local empty = TextLabel(scroll, T("NoAttributes"), 11, P.Dim, Enum.Font.Gotham, Language.Alignment())
        empty.Size = UDim2.new(1, 0, 0, 18)
        empty.LayoutOrder = 12
    end

    -- Tags
    local tagTitle = TextLabel(scroll, T("TagsLabel"), 11, P.Gold, Enum.Font.GothamBold, Language.Alignment())
    tagTitle.Size = UDim2.new(1, 0, 0, 20)
    tagTitle.LayoutOrder = 20
    local hasTags = false
    if info.Tags then
        for _, tag in ipairs(info.Tags) do
            hasTags = true
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -2, 0, 34)
            row.BackgroundColor3 = P.Surface
            row.LayoutOrder = 21
            row.Parent = scroll
            Corner(row, 8)
            local t = TextLabel(row, tag, 11, P.Gold, Enum.Font.GothamBold, Language.Alignment())
            t.Size = UDim2.new(1, -12, 1, 0)
            t.Position = UDim2.new(0, 6, 0, 0)
        end
    end
    if not hasTags then
        local empty = TextLabel(scroll, T("NoTags"), 11, P.Dim, Enum.Font.Gotham, Language.Alignment())
        empty.Size = UDim2.new(1, 0, 0, 18)
        empty.LayoutOrder = 22
    end

    -- عناصر فرعية قابلة للفتح
    local children = FileScanner.GetChildren(instance)
    if #children > 0 then
        local kidsTitle = TextLabel(scroll, T("ChildrenOf") .. " (" .. #children .. ")", 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
        kidsTitle.Size = UDim2.new(1, 0, 0, 20)
        kidsTitle.LayoutOrder = 30
        for i, child in ipairs(children) do
            local cInfo = FileScanner.GetBasicInfo(child)
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -2, 0, 46)
            row.BackgroundColor3 = P.Surface
            row.Text = ""
            row.AutoButtonColor = false
            row.LayoutOrder = 31 + i
            row.Parent = scroll
            Corner(row, 8)
            local ic = IconLabel(row, cInfo.Icon, 18, cInfo.Color, 4)
            ic.Size = UDim2.new(0, 28, 0, 28)
            ic.Position = UDim2.new(0, 8, 0.5, -14)
            local nameLabel = TextLabel(row, cInfo.Name, 13, P.Text, Enum.Font.GothamBold, Language.Alignment())
            nameLabel.Size = UDim2.new(1, -170, 0, 24)
            nameLabel.Position = UDim2.new(0, 42, 0, 4)
            local classLabel = TextLabel(row, cInfo.ClassName .. " • " .. cInfo.Children .. " " .. T("ItemsCount"), 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
            classLabel.Size = UDim2.new(1, -170, 0, 16)
            classLabel.Position = UDim2.new(0, 42, 0, 26)
            local open = IconLabel(row, Icons.UI.Forward, 16, P.Accent, 4)
            open.Size = UDim2.new(0, 24, 0, 24)
            open.Position = UDim2.new(1, -34, 0.5, -12)
            row.MouseEnter:Connect(function()
                Tween(row, {BackgroundColor3 = P.Hover}, 0.12)
            end)
            row.MouseLeave:Connect(function()
                Tween(row, {BackgroundColor3 = P.Surface}, 0.12)
            end)
            row.MouseButton1Click:Connect(function()
                FileViewer.Open(mainParent, child, nil)
            end)
        end
    end

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- تبويب الخصائص (تعديل مباشر)
-- ═══════════════════════════════════════════════════════════════════════════
local function BuildPropertiesTab(content, instance, info, window)
    local scroll = Scroller(content, UDim2.new(1, -4, 1, 0), UDim2.new(0, 2, 0, 0))

    local props = PropertyEditor.GetAll(instance)
    local order = 0
    local simpleTypes = {["string"] = true, ["number"] = true, ["boolean"] = true}

    local editableTitle = TextLabel(scroll, T("Properties"), 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    editableTitle.Size = UDim2.new(1, 0, 0, 20)
    editableTitle.LayoutOrder = 1
    order = 2

    for name, value in pairs(props) do
        local valueType = typeof(value)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -2, 0, simpleTypes[valueType] and 58 or 50)
        row.BackgroundColor3 = P.Surface
        row.LayoutOrder = order
        row.Parent = scroll
        Corner(row, 8)
        order = order + 1

        local keyLabel = TextLabel(row, name, 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
        keyLabel.Size = UDim2.new(1, -16, 0, 18)
        keyLabel.Position = UDim2.new(0, 8, 0, 4)

        if valueType == "boolean" then
            local state = TextLabel(row, tostring(value), 12, value and P.Success or P.Dim, Enum.Font.GothamBold, Language.Alignment())
            state.Size = UDim2.new(0, 100, 0, 26)
            state.Position = UDim2.new(0, 8, 0, 24)
            local toggle = ActionButton(row, Icons.UI.Refresh, "", P.Surface, {
                size = UDim2.new(0, 74, 0, 26), compact = true, textSize = 10, callback = function()
                    if PropertyEditor.Set(instance, name, not value) then
                        value = not value
                        state.Text = tostring(value)
                        state.TextColor3 = value and P.Success or P.Dim
                        Notify(window, T("ValueSaved"), "success")
                    end
                end
            })
            toggle.Position = UDim2.new(1, -84, 0.5, -13)
        elseif simpleTypes[valueType] then
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -104, 0, 26)
            box.Position = UDim2.new(0, 8, 0, 24)
            box.BackgroundColor3 = P.Raised
            box.TextColor3 = P.Text
            box.TextSize = 11
            box.Font = Enum.Font.Code
            box.ClearTextOnFocus = false
            box.Text = tostring(value)
            box.Parent = row
            Corner(box, 6)
            local save = ActionButton(row, Icons.UI.Save, "", P.Surface, {
                size = UDim2.new(0, 40, 0, 26), compact = true, callback = function()
                    local newValue
                    if valueType == "number" then
                        newValue = tonumber(box.Text)
                    else
                        newValue = box.Text
                    end
                    if newValue ~= nil and PropertyEditor.Set(instance, name, newValue) then
                        Notify(window, T("ValueSaved"), "success")
                    else
                        Notify(window, T("InvalidValue"), "error")
                    end
                end
            })
            save.Position = UDim2.new(1, -46, 0, 24)
        else
            local val = TextLabel(row, tostring(value), 11, P.Muted, Enum.Font.Code, Language.Alignment())
            val.Size = UDim2.new(1, -16, 0, 22)
            val.Position = UDim2.new(0, 8, 0, 24)
        end
    end

    return function() end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- النافذة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════════
-- ⇄ تبويب الروابط (v7.1): الدور / الهدف / الموقع / المراجع / المرتبط / المشابه
-- ═══════════════════════════════════════════════════════════════════════
local function LinksRow(parent, icon, name, detail, color, order, onClick)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -2, 0, 46)
    row.BackgroundColor3 = P.Surface
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = order
    row.Parent = parent
    Corner(row, 8)

    local ic = IconLabel(row, icon, 16, color or P.Accent, 4)
    ic.Size = UDim2.new(0, 28, 0, 28)
    ic.Position = UDim2.new(0, 8, 0.5, -14)

    local nm = TextLabel(row, name, 12, P.Text, Enum.Font.GothamBold, Language.Alignment())
    nm.Size = UDim2.new(1, -140, 0, 22)
    nm.Position = UDim2.new(0, 42, 0, 5)
    nm.TextTruncate = Enum.TextTruncate.AtEnd

    local dt = TextLabel(row, detail, 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
    dt.Size = UDim2.new(1, -140, 0, 15)
    dt.Position = UDim2.new(0, 42, 0, 28)
    dt.TextTruncate = Enum.TextTruncate.AtEnd

    local arrow = IconLabel(row, Icons.UI.Forward, 14, P.Accent, 4)
    arrow.Size = UDim2.new(0, 22, 0, 22)
    arrow.Position = UDim2.new(1, -30, 0.5, -11)

    row.MouseEnter:Connect(function() Tween(row, {BackgroundColor3 = P.Hover}, 0.12) end)
    row.MouseLeave:Connect(function() Tween(row, {BackgroundColor3 = P.Surface}, 0.12) end)
    if onClick then row.MouseButton1Click:Connect(onClick) end
    return row
end

local function LinksHeader(scroll, icon, title, value, order)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -2, 0, 42)
    box.BackgroundColor3 = P.Raised
    box.BorderSizePixel = 0
    box.LayoutOrder = order
    box.Parent = scroll
    Corner(box, 8)

    local ic = IconLabel(box, icon, 15, P.Accent, 4)
    ic.Size = UDim2.new(0, 26, 0, 26)
    ic.Position = UDim2.new(0, 8, 0.5, -13)

    local tt = TextLabel(box, title, 10, P.Muted, Enum.Font.GothamBold, Language.Alignment())
    tt.Size = UDim2.new(0.3, -10, 1, 0)
    tt.Position = UDim2.new(0, 38, 0, 0)

    local vv = TextLabel(box, value, 11, P.Text, Enum.Font.GothamBold, Language.Alignment())
    vv.Size = UDim2.new(0.66, -8, 1, 0)
    vv.Position = UDim2.new(0.32, 0, 0, 0)
    vv.TextTruncate = Enum.TextTruncate.AtEnd
    return box
end

local function BuildLinksTab(content, instance, info, window, closeViewer, mainParent)
    local scroll = Scroller(content, UDim2.new(1, -4, 1, 0), UDim2.new(0, 2, 0, 0))
    local order = 0

    -- الرؤية الفورية (بدون مسح كامل للشجرة)
    local insights = FileScanner.GetInsights(instance)

    order = order + 1
    LinksHeader(scroll, Icons.UI.Purpose, T("RoleLabel"),
        insights.role or T("UnknownCategory") or "—", order)

    order = order + 1
    LinksHeader(scroll, Icons.UI.Tag, T("PurposeLabel"),
        insights.purpose or T("UnknownCategory") or "—", order)

    order = order + 1
    LinksHeader(scroll, Icons.UI.Location, T("LocationLabel"),
        info.FullName or instance.Name, order)

    -- عناصر مرتبطة مباشرة (خصائص تربطها بهذا العنصر)
    order = order + 1
    local relatedTitle = TextLabel(scroll, T("RelatedLabel"), 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    relatedTitle.Size = UDim2.new(1, 0, 0, 22)
    relatedTitle.LayoutOrder = order
    if #insights.links == 0 then
        order = order + 1
        local empty = TextLabel(scroll, T("NoRelated"), 10, P.Dim, Enum.Font.Gotham, Language.Alignment())
        empty.Size = UDim2.new(1, 0, 0, 22)
        empty.LayoutOrder = order
    else
        for _, linked in ipairs(insights.links) do
            order = order + 1
            local lInfo = FileScanner.GetBasicInfo(linked)
            LinksRow(scroll, lInfo.Icon, linked.Name, linked.ClassName .. " • " .. (lInfo.Children or 0) .. " " .. T("ItemsCount"),
                lInfo.Color, order, function()
                    closeViewer()
                    task.delay(0.22, function()
                        FileViewer.Open(mainParent, linked)
                    end)
                end)
        end
    end

    -- عناصر مشابهة (نفس الاسم/الصنف في نفس الأب)
    order = order + 1
    local sibTitle = TextLabel(scroll, T("SiblingsLabel"), 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    sibTitle.Size = UDim2.new(1, 0, 0, 22)
    sibTitle.LayoutOrder = order
    if #insights.sameName == 0 then
        order = order + 1
        local empty = TextLabel(scroll, T("NoSiblings"), 10, P.Dim, Enum.Font.Gotham, Language.Alignment())
        empty.Size = UDim2.new(1, 0, 0, 22)
        empty.LayoutOrder = order
    else
        for _, sib in ipairs(insights.sameName) do
            order = order + 1
            local sInfo = FileScanner.GetBasicInfo(sib)
            LinksRow(scroll, sInfo.Icon, sib.Name, sib.ClassName .. " • " .. (sInfo.Children or 0) .. " " .. T("ItemsCount"),
                sInfo.Color, order, function()
                    closeViewer()
                    task.delay(0.22, function()
                        FileViewer.Open(mainParent, sib)
                    end)
                end)
        end
    end

    -- المراجع في السكربتات (بحث عميق غير متزامن)
    order = order + 1
    local refTitle = TextLabel(scroll, T("ReferencesLabel"), 11, P.Accent, Enum.Font.GothamBold, Language.Alignment())
    refTitle.Size = UDim2.new(1, 0, 0, 22)
    refTitle.LayoutOrder = order

    order = order + 1
    local searchBtn = ActionButton(scroll, Icons.UI.Search, T("SearchReferences"), P.Surface, {
        size = UDim2.new(1, -2, 0, 42), textSize = 12, radius = 8
    })
    searchBtn.LayoutOrder = order
    searchBtn.MouseButton1Click:Connect(function()
        -- حالة البحث
        searchBtn.TextLabel.Text = T("SearchingReferences")
        searchBtn.AutoButtonColor = false

        -- تدمير صفوف النتائج القديمة
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child ~= searchBtn and child.Name ~= "LinksRow_Header" then
                if child:GetAttribute("SourceRef") then child:Destroy() end
            end
        end

        FileScanner.FindReferences(instance, function(results)
            searchBtn.TextLabel.Text = T("SearchReferences")
            if #results == 0 then
                local empty = TextLabel(scroll, T("NoReferences"), 10, P.Dim, Enum.Font.Gotham, Language.Alignment())
                empty.Size = UDim2.new(1, 0, 0, 22)
                empty.LayoutOrder = 100 + order
                empty:SetAttribute("SourceRef", true)
                return
            end
            for i, ref in ipairs(results) do
                local rInfo = FileScanner.GetBasicInfo(ref)
                local parentName = ""
                pcall(function() if ref.Parent then parentName = ref.Parent.Name end end)
                local row = LinksRow(scroll, Icons.UI.Script, ref.Name,
                    ref.ClassName .. " • " .. parentName, rInfo.Color, 100 + i,
                    function()
                        closeViewer()
                        task.delay(0.22, function()
                            FileViewer.Open(mainParent, ref)
                        end)
                    end)
                row:SetAttribute("SourceRef", true)
                row.Name = "SourceRef_" .. i
            end
        end, 25)
    end)
end

function FileViewer.Open(mainParent, instance, onClose)
    if not instance then return end
    local info = FileScanner.GetInfo(instance)
    local cleanupFns = {}

    local Overlay = Instance.new("Frame")
    Overlay.Name = "FileViewerOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.ZIndex = 90
    Overlay.Parent = mainParent

    local Window = Instance.new("Frame")
    Window.Name = "ViewerWindow"
    Window.Size = UDim2.new(0.96, 0, 0.3, 0)
    Window.Position = UDim2.new(0.02, 0, 0.04, 0)
    Window.BackgroundColor3 = P.BG
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.ZIndex = 91
    Window.Parent = Overlay
    Corner(Window, 15)
    Stroke(Window, P.Accent, 2, 0.2)

    local function cleanup()
        for _, fn in ipairs(cleanupFns) do
            pcall(fn)
        end
    end

    Overlay.Destroying:Connect(cleanup)

    local function closeViewer()
        cleanup()
        Tween(Overlay, {BackgroundTransparency = 1}, 0.18)
        Tween(Window, {Size = UDim2.new(0.96, 0, 0.3, 0)}, 0.18)
        task.delay(0.2, function()
            Overlay:Destroy()
            if onClose then onClose() end
        end)
    end

    -- ═══ الترويسة ═══
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 64)
    Header.BackgroundColor3 = P.Header
    Header.ZIndex = 92
    Header.Parent = Window
    Corner(Header, 15)

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 2)
    headerLine.Position = UDim2.new(0, 0, 1, -2)
    headerLine.BackgroundColor3 = info.Color or P.Accent
    headerLine.ZIndex = 93
    headerLine.Parent = Header

    local icon = IconLabel(Header, info.Icon, 26, info.Color or P.Accent, 93)
    icon.Size = UDim2.new(0, 44, 0, 44)
    icon.Position = UDim2.new(0, 12, 0.5, -22)

    local nameLabel = TextLabel(Header, info.Name, 17, P.Text, Enum.Font.GothamBold, Language.Alignment())
    nameLabel.Size = UDim2.new(1, -170, 0, 26)
    nameLabel.Position = UDim2.new(0, 64, 0, 10)

    local classLabel = TextLabel(Header, info.ClassName, 12, info.Color or P.Accent, Enum.Font.Gotham, Language.Alignment())
    classLabel.Size = UDim2.new(1, -170, 0, 18)
    classLabel.Position = UDim2.new(0, 64, 0, 38)

    local closeBtn = ActionButton(Header, Icons.UI.Close, "", P.Danger, {
        size = UDim2.new(0, 38, 0, 38), compact = true,
        pressColor = Color3.fromRGB(200, 40, 60), callback = closeViewer
    })
    closeBtn.Position = UDim2.new(1, -48, 0.5, -19)

    -- ═══ شريط التبويبات ═══
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.new(0, 10, 0, 72)
    TabBar.BackgroundColor3 = P.Surface
    TabBar.ZIndex = 92
    TabBar.Parent = Window
    Corner(TabBar, 10)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Parent = TabBar
    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingLeft = UDim.new(0, 8)
    tabPad.PaddingRight = UDim.new(0, 8)
    tabPad.Parent = TabBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -180)
    Content.Position = UDim2.new(0, 10, 0, 118)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.ZIndex = 92
    Content.Parent = Window

    -- ═══ الشريط السفلي ═══
    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, -20, 0, 48)
    BottomBar.Position = UDim2.new(0, 10, 1, -58)
    BottomBar.BackgroundColor3 = P.Surface
    BottomBar.ZIndex = 92
    BottomBar.Parent = Window
    Corner(BottomBar, 10)

    local bottomLayout = Instance.new("UIListLayout")
    bottomLayout.FillDirection = Enum.FillDirection.Horizontal
    bottomLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    bottomLayout.Padding = UDim.new(0, 6)
    bottomLayout.Parent = BottomBar
    local bottomPad = Instance.new("UIPadding")
    bottomPad.PaddingLeft = UDim.new(0, 8)
    bottomPad.PaddingRight = UDim.new(0, 8)
    bottomPad.Parent = BottomBar

    local pathLabel = TextLabel(BottomBar, info.FullName, 9, P.Dim, Enum.Font.Code, Language.Alignment())
    pathLabel.Size = UDim2.new(0.3, -10, 1, 0)
    pathLabel.LayoutOrder = -1

    ActionButton(BottomBar, Icons.UI.Copy, T("CopyPath"), P.Surface, {
        size = UDim2.new(0, 110, 0, 34), textSize = 10, callback = function()
            if CopyToClipboard(info.FullName) then
                Notify(Window, T("Copied"), "success")
            end
        end
    })

    ActionButton(BottomBar, Icons.UI.Copy, T("CopyProperties"), P.Surface, {
        size = UDim2.new(0, 132, 0, 34), textSize = 10, callback = function()
            local lines = {}
            table.insert(lines, info.FullName)
            table.insert(lines, "Class: " .. info.ClassName)
            table.insert(lines, "Parent: " .. tostring(info.Parent))
            table.insert(lines, "Children: " .. info.Children)
            table.insert(lines, "Descendants: " .. info.Descendants)
            if info.Attributes then
                for k, v in pairs(info.Attributes) do
                    table.insert(lines, "Attr." .. tostring(k) .. " = " .. tostring(v))
                end
            end
            if info.Tags and #info.Tags > 0 then
                table.insert(lines, "Tags: " .. table.concat(info.Tags, ", "))
            end
            if CopyToClipboard(table.concat(lines, "\n")) then
                Notify(Window, T("Copied"), "success")
            end
        end
    })

    ActionButton(BottomBar, Icons.UI.Duplicate, T("CloneItem"), P.Surface, {
        size = UDim2.new(0, 104, 0, 34), textSize = 10, callback = function()
            local ok = pcall(function()
                local clone = instance:Clone()
                clone.Parent = instance.Parent
                clone.Name = instance.Name .. "_Copy"
            end)
            if ok then
                Notify(Window, T("CloneSuccess"), "success")
            else
                Notify(Window, T("CloneFailed"), "error")
            end
        end
    })

    ActionButton(BottomBar, Icons.UI.Delete, T("DeleteItem"), P.Danger, {
        size = UDim2.new(0, 104, 0, 34), textSize = 10, callback = function()
            local ok = pcall(function() instance:Destroy() end)
            if ok then
                Notify(Window, T("Deleted"), "success")
                task.delay(1, closeViewer)
            else
                Notify(Window, T("ActionFailed"), "error")
            end
        end
    })

    -- ═══ نظام التبويبات ═══
    local tabs = {}
    local function CreateTab(name, iconName, previewKey)
        local btn, ic, txt = ActionButton(TabBar, iconName, name, P.Surface, {
            size = UDim2.new(0.235, -8, 0, 30), textSize = 10
        })
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = false
        contentFrame.ClipsDescendants = true
        contentFrame.ZIndex = 92
        contentFrame.Parent = Content
        tabs[previewKey] = {button = btn, icon = ic, label = txt, content = contentFrame}
        return btn, contentFrame
    end

    local previewTab, previewContent = CreateTab(T("TabPreview"), Icons.UI.Preview, "preview")
    local propsTab, propsContent = CreateTab(T("TabProperties"), Icons.UI.Properties, "props")
    local childrenTab, childrenContent = CreateTab(T("TabChildren"), Icons.UI.Tree, "children")
    local linksTab, linksContent = CreateTab(T("TabLinks"), Icons.UI.Links, "links")

    local function SwitchTab(key)
        for k, data in pairs(tabs) do
            local active = k == key
            Tween(data.button, {BackgroundColor3 = active and P.Accent or P.Surface}, 0.14)
            Tween(data.icon, {TextColor3 = active and P.BG or P.Text}, 0.14)
            Tween(data.label, {TextColor3 = active and P.BG or P.Muted}, 0.14)
            data.content.Visible = active
            if active then
                data.content.Position = UDim2.new(0.02, 0, 0, 0)
                Tween(data.content, {Position = UDim2.new(0, 0, 0, 0)}, 0.18)
            end
        end
    end

    for k, data in pairs(tabs) do
        data.button.MouseButton1Click:Connect(function()
            SwitchTab(k)
        end)
    end

    -- ═══ بناء المحتوى حسب النوع ═══
    local function BuildPreview()
        previewContent:ClearAllChildren()
        local cleanupFn = function() end
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            cleanupFn = BuildScriptPreview(previewContent, instance, info, Window)
        elseif instance:IsA("Sound") then
            cleanupFn = BuildSoundPreview(previewContent, instance, info, Window)
        elseif instance:IsA("Decal") or instance:IsA("Texture")
            or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            cleanupFn = BuildImagePreview(previewContent, instance, info, Window)
        elseif instance:IsA("VideoFrame") then
            cleanupFn = BuildVideoPreview(previewContent, instance, info, Window)
        elseif instance:IsA("KeyframeSequence") or instance:IsA("Animator") or instance:IsA("AnimationController") then
            cleanupFn = BuildAnimationPreview(previewContent, instance, info, Window)
        elseif instance:IsA("BasePart") or instance:IsA("Model") then
            cleanupFn = BuildModelPreview(previewContent, instance, info, Window)
        elseif instance:IsA("ParticleEmitter") or instance:IsA("Fire") or instance:IsA("Smoke")
            or instance:IsA("Sparkles") or instance:IsA("Beam") or instance:IsA("Trail")
            or instance:IsA("Highlight") or instance:IsA("Explosion") then
            cleanupFn = BuildEffectPreview(previewContent, instance, info, Window)
        elseif instance:IsA("Light") then
            cleanupFn = BuildLightPreview(previewContent, instance, info, Window)
        elseif instance:IsA("ValueBase") then
            cleanupFn = BuildValuePreview(previewContent, instance, info, Window)
        elseif instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")
            or instance:IsA("BindableEvent") or instance:IsA("BindableFunction") then
            cleanupFn = BuildRemotePreview(previewContent, instance, info, Window)
        elseif instance:IsA("GuiObject") or instance:IsA("LayerCollector") then
            cleanupFn = BuildGuiPreview(previewContent, instance, info, Window)
        else
            cleanupFn = BuildDefaultPreview(previewContent, instance, info, Window, mainParent)
        end
        table.insert(cleanupFns, cleanupFn)
    end

    BuildPreview()
    BuildPropertiesTab(propsContent, instance, info, Window)

    -- ═══ تبويب العناصر الفرعية ═══
    local children = FileScanner.GetChildren(instance)
    if #children > 0 then
        local scroll = Scroller(childrenContent, UDim2.new(1, -4, 1, 0), UDim2.new(0, 2, 0, 0))
        for i, child in ipairs(children) do
            local cInfo = FileScanner.GetBasicInfo(child)
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -2, 0, 50)
            row.BackgroundColor3 = P.Surface
            row.Text = ""
            row.AutoButtonColor = false
            row.LayoutOrder = i
            row.Parent = scroll
            Corner(row, 8)
            local ic = IconLabel(row, cInfo.Icon, 18, cInfo.Color, 4)
            ic.Size = UDim2.new(0, 30, 0, 30)
            ic.Position = UDim2.new(0, 8, 0.5, -15)
            local name = TextLabel(row, cInfo.Name, 13, P.Text, Enum.Font.GothamBold, Language.Alignment())
            name.Size = UDim2.new(1, -150, 0, 24)
            name.Position = UDim2.new(0, 44, 0, 4)
            local class = TextLabel(row, cInfo.ClassName .. " • " .. cInfo.Children .. " " .. T("ItemsCount"), 10, P.Muted, Enum.Font.Gotham, Language.Alignment())
            class.Size = UDim2.new(1, -150, 0, 16)
            class.Position = UDim2.new(0, 44, 0, 27)
            local open = IconLabel(row, Icons.UI.Forward, 15, P.Accent, 4)
            open.Size = UDim2.new(0, 24, 0, 24)
            open.Position = UDim2.new(1, -32, 0.5, -12)
            row.MouseEnter:Connect(function()
                Tween(row, {BackgroundColor3 = P.Hover}, 0.12)
            end)
            row.MouseLeave:Connect(function()
                Tween(row, {BackgroundColor3 = P.Surface}, 0.12)
            end)
            row.MouseButton1Click:Connect(function()
                closeViewer()
                task.delay(0.22, function()
                    FileViewer.Open(mainParent, child, onClose)
                end)
            end)
        end
    else
        EmptyState(childrenContent, Icons.UI.Empty, T("NoChildren"), info.Name)
    end

    BuildLinksTab(linksContent, instance, info, Window, closeViewer, mainParent)

    SwitchTab("preview")

    -- اتجاه اللغة
    if Language.Apply then Language.Apply(Window) end
    -- الكود دائماً LTR مهما كانت لغة الواجهة
    for _, obj in ipairs(Window:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton")) and obj.Font == Enum.Font.Code then
            obj.TextDirection = Enum.TextDirection.LeftToRight
            if obj.Name == "LineGutter" then
                obj.TextXAlignment = Enum.TextXAlignment.Right
            else
                obj.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
    end

    -- حركة دخول النافذة
    Tween(Overlay, {BackgroundTransparency = 0.45}, 0.2)
    Tween(Window, {Size = UDim2.new(0.96, 0, 0.92, 0)}, 0.26, Enum.EasingStyle.Quart)

    return {window = Window, overlay = Overlay, close = closeViewer}
end

return FileViewer
