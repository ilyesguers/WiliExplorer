--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - Page Router v1.1 (v7.1)
    ═══════════════════════════════════════════════════════════════════════════
    نظام تنقّل بالصفحات داخل حاوية واحدة:
    • كل ميزة صفحة مستقلة تماماً (لا تراكب بينها)
    • مكدس رجوع (Back Stack): الخروج من صفحة يعيد الصفحة السابقة
    • حركات انتقال منزلقة بين الصفحات
    • ذاكرة صفحة: الصفحات السابقة لا تُبنى من جديد عند الرجوع
    • ترويسة متكيفة مع RTL (عربي/إنجليزي) + نصوص مترجمة
    ═══════════════════════════════════════════════════════════════════════════
]]

local Router = {}

local TweenService = game:GetService("TweenService")

local function GetModule(name)
    if _G.WiliModules and _G.WiliModules[name] then
        return _G.WiliModules[name]
    end
    return nil
end

local function T(key)
    local lang = GetModule("Language")
    if lang then return lang.Get(key, key) end
    return key
end

local function IsRTL()
    local lang = GetModule("Language")
    if lang and lang.IsRTL then return lang.IsRTL() end
    return false
end

function Router.Create(container, notify)
    local stack = {}
    local activePage = nil

    local function closePage(page)
        if not page then return end
        if not page.frame then return end
        if not page.frame.Parent then return end
        if page.onClose then pcall(page.onClose) end
        if page.cleanup then pcall(page.cleanup) end
        page.frame:Destroy()
        page.frame = nil
    end

    local function renderTop(page)
        -- يحدّث زر الرجوع وعنوان الصفحة الحالية
        if not page then return end
        local canGoBack = #stack > 1
        if page.top and page.top.BackBtn then
            page.top.BackBtn.Visible = canGoBack
        end
    end

    -- فتح صفحة جديدة (تدفع فوق الحالية)
    function Router.Push(options)
        if not container then return end
        local page = {
            name = options.name or "page",
            title = options.title or "",
            subtitle = options.subtitle or "",
            icon = options.icon or "◈",
            color = options.color or Color3.fromRGB(0, 212, 255),
            builder = options.builder,
            onClose = options.onClose,
            top = {},
            frame = nil
        }

        local rtl = IsRTL()

        local frame = Instance.new("Frame")
        frame.Name = "Page_" .. page.name
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 20
        frame.Parent = container
        page.frame = frame

        -- ═══ ترويسة الصفحة (زر رجوع + عنوان + أيقونة) ═══
        local topBar = Instance.new("Frame")
        topBar.Name = "PageTopBar"
        topBar.Size = UDim2.new(1, -16, 0, 54)
        topBar.Position = UDim2.new(0, 8, 0, 8)
        topBar.BackgroundColor3 = Color3.fromRGB(15, 20, 40)
        topBar.BorderSizePixel = 0
        topBar.ZIndex = 21
        topBar.Parent = frame
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(0, 3, 1, -12)
        accentLine.Position = rtl and UDim2.new(1, -7, 0, 6) or UDim2.new(0, 4, 0, 6)
        accentLine.BackgroundColor3 = page.color
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 22
        accentLine.Parent = topBar

        local backBtn = Instance.new("TextButton")
        backBtn.Name = "BackBtn"
        backBtn.Size = UDim2.new(0, 90, 0, 38)
        backBtn.Position = rtl and UDim2.new(1, -104, 0.5, -19) or UDim2.new(0, 14, 0.5, -19)
        backBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 70)
        backBtn.Text = ""
        backBtn.AutoButtonColor = false
        backBtn.ZIndex = 22
        backBtn.Parent = topBar
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 9)
        page.top.BackBtn = backBtn

        local backIcon = Instance.new("TextLabel")
        backIcon.Size = UDim2.new(0, 24, 1, 0)
        backIcon.Position = rtl and UDim2.new(1, -32, 0, 0) or UDim2.new(0, 8, 0, 0)
        backIcon.BackgroundTransparency = 1
        backIcon.Text = rtl and "›" or "‹"
        backIcon.TextColor3 = Color3.fromRGB(242, 247, 255)
        backIcon.TextSize = 22
        backIcon.Font = Enum.Font.GothamBold
        backIcon.ZIndex = 23
        backIcon.Parent = backBtn

        local backLabel = Instance.new("TextLabel")
        backLabel.Size = UDim2.new(1, -34, 1, 0)
        backLabel.Position = rtl and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 32, 0, 0)
        backLabel.BackgroundTransparency = 1
        backLabel.Text = T("PageBack")
        backLabel.TextColor3 = Color3.fromRGB(242, 247, 255)
        backLabel.TextSize = 13
        backLabel.Font = Enum.Font.GothamBold
        backLabel.TextXAlignment = rtl and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        backLabel.ZIndex = 23
        backLabel.Parent = backBtn

        backBtn.MouseEnter:Connect(function()
            TweenService:Create(backBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(44, 55, 100)}):Play()
        end)
        backBtn.MouseLeave:Connect(function()
            TweenService:Create(backBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30, 38, 70)}):Play()
        end)
        backBtn.MouseButton1Click:Connect(function()
            Router.Back()
        end)

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 34, 0, 34)
        iconLabel.Position = rtl and UDim2.new(1, -150, 0.5, -17) or UDim2.new(0, 116, 0.5, -17)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = page.icon
        iconLabel.TextColor3 = page.color
        iconLabel.TextSize = 20
        iconLabel.ZIndex = 22
        iconLabel.Parent = topBar

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -174, 0, 24)
        titleLabel.Position = rtl and UDim2.new(0, 16, 0, 7) or UDim2.new(0, 158, 0, 7)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = page.title
        titleLabel.TextColor3 = Color3.fromRGB(242, 247, 255)
        titleLabel.TextSize = 16
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = rtl and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        titleLabel.ZIndex = 22
        titleLabel.Parent = topBar

        local subtitleLabel = Instance.new("TextLabel")
        subtitleLabel.Size = UDim2.new(1, -174, 0, 16)
        subtitleLabel.Position = rtl and UDim2.new(0, 16, 0, 32) or UDim2.new(0, 158, 0, 32)
        subtitleLabel.BackgroundTransparency = 1
        subtitleLabel.Text = page.subtitle
        subtitleLabel.TextColor3 = Color3.fromRGB(150, 168, 197)
        subtitleLabel.TextSize = 10
        subtitleLabel.Font = Enum.Font.Gotham
        subtitleLabel.TextXAlignment = rtl and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
        subtitleLabel.ZIndex = 22
        subtitleLabel.Parent = topBar

        -- ═══ جسم الصفحة ═══
        local body = Instance.new("Frame")
        body.Name = "PageBody"
        body.Size = UDim2.new(1, -16, 1, -72)
        body.Position = UDim2.new(0, 8, 0, 66)
        body.BackgroundTransparency = 1
        body.ZIndex = 21
        body.Parent = frame
        page.body = body

        -- حيّز المحتوى الفعلي (يبنيه الـ builder)
        local content = Instance.new("Frame")
        content.Name = "PageContent"
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.ZIndex = 21
        content.Parent = body
        page.content = content

        -- بناء المحتوى
        local ok, buildErr = pcall(function()
            if page.builder then
                page.builder(content, page)
            end
        end)
        if not ok then
            local errLabel = Instance.new("TextLabel")
            errLabel.Size = UDim2.new(1, 0, 0, 40)
            errLabel.Position = UDim2.new(0, 0, 0.5, -20)
            errLabel.BackgroundTransparency = 1
            errLabel.Text = T("PageError") .. ": " .. tostring(buildErr)
            errLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
            errLabel.TextSize = 12
            errLabel.Font = Enum.Font.Gotham
            errLabel.TextWrapped = true
            errLabel.Parent = content
        end

        -- إخفاء الصفحة الحالية قبل عرض الجديدة
        if activePage and activePage.frame then
            activePage.frame.Visible = false
        end

        -- حركة دخول
        frame.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        table.insert(stack, page)
        activePage = page
        renderTop(page)

        if notify then notify(page.title, "info") end
        return page
    end

    -- الرجوع للصفحة السابقة
    function Router.Back()
        if #stack <= 1 then
            return false
        end
        local current = stack[#stack]
        table.remove(stack)
        closePage(current)
        activePage = stack[#stack]
        if activePage and activePage.frame then
            activePage.frame.Visible = true
            activePage.frame.Position = UDim2.new(-0.04, 0, 0, 0)
            TweenService:Create(activePage.frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        end
        renderTop(activePage)
        return true
    end

    -- إغلاق الكل والعودة للجذر
    function Router.Reset(rootPage)
        for i = #stack, 1, -1 do
            closePage(stack[i])
        end
        table.clear(stack)
        activePage = nil
        if rootPage then
            Router.Push(rootPage)
        end
    end

    -- الصفحة الحالية
    function Router.Current()
        return activePage
    end

    -- عدد الصفحات في المكدس
    function Router.Depth()
        return #stack
    end

    -- إغلاق نهائي (تنظيف كل شيء)
    function Router.Destroy()
        for i = #stack, 1, -1 do
            closePage(stack[i])
        end
        table.clear(stack)
        activePage = nil
    end

    return Router
end

return Router
