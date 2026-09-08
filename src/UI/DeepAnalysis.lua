--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - Deep Analysis v1.0 (v7.1)
    ═══════════════════════════════════════════════════════════════════════════
    فحص عميق للشجرة الحالية:
    • إجمالي العناصر + توزيع حسب الفئة (أشرطة ملونة)
    • أكبر الفروع (حسب عدد العناصر داخل كل فرع)
    • تكرارات الأسماء (Duplicates)
    • نسخ الشجرة كنص / نسخ الإحصائيات
    • فحص مجزّأ قابل للإلغاء (لا يجمّد اللعبة)
    ═══════════════════════════════════════════════════════════════════════════
]]

local DeepAnalysis = {}

local function GetModule(name)
    return assert(_G.WiliModules and _G.WiliModules[name], "DeepAnalysis dependency missing: " .. name)
end

local FileScanner = GetModule("FileScanner")
local Language = GetModule("Language")

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
    Warning = Color3.fromRGB(255, 190, 76)
}

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function CopyText(text)
    local ok = false
    pcall(function()
        if setclipboard then setclipboard(text) ok = true
        elseif toclipboard then toclipboard(text) ok = true end
    end)
    return ok
end

-- توليد شجرة نصية (حتى عمق 4)
local function BuildTextTree(root)
    local lines = {}
    local function walk(instance, depth)
        if depth > 4 then return end
        local icon = FileScanner.GetCategoryInfo(FileScanner.GetCategory(instance)).icon or "?"
        table.insert(lines, string.rep("  ", depth) .. icon .. " " .. instance.Name .. " [" .. instance.ClassName .. "]")
        local children = FileScanner.GetChildren(instance)
        for _, child in ipairs(children) do
            walk(child, depth + 1)
        end
    end
    walk(root, 0)
    return table.concat(lines, "\n")
end

function DeepAnalysis.Create(content, rootInstance, options)
    options = options or {}
    local notify = options.notify
    local token = {cancelled = false}

    -- ═══ شريط الإجراءات ═══
    local actions = Instance.new("Frame")
    actions.Size = UDim2.new(1, -4, 0, 44)
    actions.Position = UDim2.new(0, 2, 0, 0)
    actions.BackgroundTransparency = 1
    actions.Parent = content
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 8)
    actionsLayout.Parent = actions

    local function ActionButton(icon, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 0, 38)
        btn.BackgroundColor3 = color or P.Surface
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = actions
        Corner(btn, 9)

        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(0, 26, 1, 0)
        ic.Position = UDim2.new(0, 8, 0, 0)
        ic.BackgroundTransparency = 1
        ic.Text = icon
        ic.TextColor3 = P.Text
        ic.TextSize = 15
        ic.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -36, 1, 0)
        lbl.Position = UDim2.new(0, 32, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = P.Text
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Language.Alignment()
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = P.Hover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = color or P.Surface}):Play()
        end)
        if callback then btn.MouseButton1Click:Connect(callback) end
        return btn
    end

    local scanBtn = ActionButton("⌁", T("DeepScan"), P.Accent, function()
        token.cancelled = false
        RunScan()
    end)
    ActionButton("⧉", T("CopyTreeLabel"), P.Surface, function()
        local tree = BuildTextTree(rootInstance)
        if CopyText(tree) then
            if notify then notify(T("Copied"), "Success") end
        end
    end)
    ActionButton("≡", T("CopyStats"), P.Surface, function()
        local lines = {
            T("TreeStatsTitle") .. ": " .. rootInstance.Name,
            T("TotalItems") .. ": " .. tostring(scanData.total or 0)
        }
        for _, entry in ipairs(scanData.categories or {}) do
            table.insert(lines, entry.name .. ": " .. entry.count)
        end
        if CopyText(table.concat(lines, "\n")) then
            if notify then notify(T("Copied"), "Success") end
        end
    end)

    -- ═══ منطقة النتائج ═══
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -4, 1, -52)
    results.Position = UDim2.new(0, 2, 0, 50)
    results.BackgroundTransparency = 1
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 4
    results.ScrollBarImageColor3 = P.Accent
    results.CanvasSize = UDim2.new(0, 0, 0, 0)
    results.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = results
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.Parent = results
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        results.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    local scanData = {total = 0, categories = {}, duplicates = {}, branches = {}}

    local function SectionTitle(text, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 26)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = P.Accent
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Language.Alignment()
        label.LayoutOrder = order or 0
        label.Parent = results
        return label
    end

    -- صف إحصائية
    local function StatRow(order, icon, name, count, color, isLast)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -2, 0, 42)
        row.BackgroundColor3 = P.Surface
        row.LayoutOrder = order
        row.Parent = results
        Corner(row, 8)

        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(0, 26, 0, 26)
        ic.Position = UDim2.new(0, 8, 0.5, -13)
        ic.BackgroundTransparency = 1
        ic.Text = icon or "?"
        ic.TextColor3 = color or P.Accent
        ic.TextSize = 15
        ic.Parent = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -130, 0, 24)
        nameLabel.Position = UDim2.new(0, 40, 0, 9)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = P.Text
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Language.Alignment()
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = row

        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0, 70, 1, 0)
        countLabel.Position = UDim2.new(1, -78, 0, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = tostring(count)
        countLabel.TextColor3 = color or P.Accent
        countLabel.TextSize = 14
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextXAlignment = Enum.TextXAlignment.Right
        countLabel.Parent = row
    end

    -- شريط نسبة
    local function BarRow(order, icon, name, count, total, color)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -2, 0, 44)
        row.BackgroundColor3 = P.Surface
        row.LayoutOrder = order
        row.Parent = results
        Corner(row, 8)

        local ic = Instance.new("TextLabel")
        ic.Size = UDim2.new(0, 24, 0, 24)
        ic.Position = UDim2.new(0, 8, 0, 6)
        ic.BackgroundTransparency = 1
        ic.Text = icon or "?"
        ic.TextColor3 = color or P.Accent
        ic.TextSize = 14
        ic.Parent = row

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 38, 0, 4)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = P.Muted
        nameLabel.TextSize = 10
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Language.Alignment()
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0.52, -8, 0, 12)
        track.Position = UDim2.new(0.42, 0, 0, 8)
        track.BackgroundColor3 = P.Raised
        track.BorderSizePixel = 0
        track.Parent = row
        Corner(track, 6)

        local ratio = total > 0 and math.clamp(count / total, 0.01, 1) or 0.01
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        fill.BackgroundColor3 = color or P.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        Corner(fill, 6)

        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0, 40, 0, 20)
        countLabel.Position = UDim2.new(1, -48, 0, 4)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = tostring(count)
        countLabel.TextColor3 = P.Text
        countLabel.TextSize = 11
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextXAlignment = Enum.TextXAlignment.Right
        countLabel.Parent = row

        local percentLabel = Instance.new("TextLabel")
        percentLabel.Size = UDim2.new(0, 40, 0, 16)
        percentLabel.Position = UDim2.new(1, -48, 0, 24)
        percentLabel.BackgroundTransparency = 1
        percentLabel.Text = string.format("%d%%", math.floor((count / (total > 0 and total or 1)) * 100))
        percentLabel.TextColor3 = P.Dim
        percentLabel.TextSize = 9
        percentLabel.Font = Enum.Font.Gotham
        percentLabel.TextXAlignment = Enum.TextXAlignment.Right
        percentLabel.Parent = row
    end

    -- رسالة حالة
    local function StatusRow(text, color, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color or P.Dim
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Language.Alignment()
        label.LayoutOrder = order or 0
        label.Parent = results
        return label
    end

    -- ═══ الفحص العميق ═══
    local function RunScan()
        -- مسح النتائج القديمة
        for _, child in ipairs(results:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        scanData = {total = 0, categories = {}, duplicates = {}, branches = {}}

        local progress = StatusRow(T("ScanningLabel"), P.Muted, 1)

        task.spawn(function()
            local categoryCounts = {}
            local nameMap = {}
            local visited = 0
            local limit = 100000
            local preOrder = {}
            local parentMap = setmetatable({}, {__mode = "k"})

            -- DFS تكرارية (بدون استدعاء متكرر — آمنة للأشجار العميقة)
            local stack = {}
            for _, child in ipairs(FileScanner.GetChildren(rootInstance)) do
                table.insert(stack, child)
            end

            while #stack > 0 and visited < limit and not token.cancelled do
                local instance = table.remove(stack)
                visited = visited + 1
                table.insert(preOrder, instance)

                local cat = FileScanner.GetCategory(instance)
                categoryCounts[cat] = (categoryCounts[cat] or 0) + 1
                local lowerName = instance.Name:lower()
                nameMap[lowerName] = (nameMap[lowerName] or 0) + 1

                local children = FileScanner.GetChildren(instance)
                for _, child in ipairs(children) do
                    parentMap[child] = instance
                    table.insert(stack, child)
                end
                if visited % 500 == 0 then task.wait() end
            end

            -- أحجام الفروع الفرعية (post-order عبر القائمة المعكوسة)
            local subtree = setmetatable({}, {__mode = "k"})
            for i = #preOrder, 1, -1 do
                local instance = preOrder[i]
                subtree[instance] = (subtree[instance] or 0) + 1
                local parent = parentMap[instance]
                if parent then
                    subtree[parent] = (subtree[parent] or 0) + subtree[instance]
                end
            end

            scanData.total = visited
            for cat, count in pairs(categoryCounts) do
                table.insert(scanData.categories, {name = cat, count = count})
            end
            table.sort(scanData.categories, function(a, b) return a.count > b.count end)

            for name, count in pairs(nameMap) do
                if count > 1 then
                    table.insert(scanData.duplicates, {name = name, count = count})
                end
            end
            table.sort(scanData.duplicates, function(a, b) return a.count > b.count end)

            local branchList = {}
            for _, child in ipairs(FileScanner.GetChildren(rootInstance)) do
                table.insert(branchList, {instance = child, count = subtree[child] or 0})
            end
            table.sort(branchList, function(a, b) return a.count > b.count end)
            for i = 1, math.min(8, #branchList) do
                table.insert(scanData.branches, branchList[i])
            end

            -- عرض النتائج
            if token.cancelled then
                StatusRow(T("ScanCancelled"), P.Warning, 1)
                return
            end
            progress:Destroy()

            local order = 1
            local totalRow = Instance.new("Frame")
            totalRow.Size = UDim2.new(1, -2, 0, 56)
            totalRow.BackgroundColor3 = P.Surface
            totalRow.LayoutOrder = order
            totalRow.Parent = results
            Corner(totalRow, 10)
            local totalIcon = Instance.new("TextLabel")
            totalIcon.Size = UDim2.new(0, 30, 0, 30)
            totalIcon.Position = UDim2.new(0, 10, 0.5, -15)
            totalIcon.BackgroundTransparency = 1
            totalIcon.Text = "≡"
            totalIcon.TextColor3 = P.Accent
            totalIcon.TextSize = 18
            totalIcon.Parent = totalRow
            local totalTitle = Instance.new("TextLabel")
            totalTitle.Size = UDim2.new(1, -120, 0, 24)
            totalTitle.Position = UDim2.new(0, 48, 0, 6)
            totalTitle.BackgroundTransparency = 1
            totalTitle.Text = T("TotalItems")
            totalTitle.TextColor3 = P.Muted
            totalTitle.TextSize = 11
            totalTitle.Font = Enum.Font.GothamBold
            totalTitle.TextXAlignment = Language.Alignment()
            totalTitle.Parent = totalRow
            local totalCount = Instance.new("TextLabel")
            totalCount.Size = UDim2.new(0, 80, 1, 0)
            totalCount.Position = UDim2.new(1, -88, 0, 0)
            totalCount.BackgroundTransparency = 1
            totalCount.Text = tostring(scanData.total)
            totalCount.TextColor3 = P.Accent
            totalCount.TextSize = 18
            totalCount.Font = Enum.Font.GothamBlack
            totalCount.TextXAlignment = Enum.TextXAlignment.Right
            totalCount.Parent = totalRow
            order = order + 1

            SectionTitle(T("ByCategory"), order)
            order = order + 1
            for _, entry in ipairs(scanData.categories) do
                local info = FileScanner.GetCategoryInfo(entry.name)
                BarRow(order, info.icon or "?", entry.name, entry.count, scanData.total, info.color or P.Accent)
                order = order + 1
            end

            SectionTitle(T("LargestTrees"), order)
            order = order + 1
            for _, branch in ipairs(scanData.branches) do
                StatRow(order, "▰", branch.instance.Name, branch.count, P.Success)
                order = order + 1
            end

            SectionTitle(T("DuplicatesFound"), order)
            order = order + 1
            if #scanData.duplicates == 0 then
                StatusRow(T("NoSiblings"), P.Dim, order)
                order = order + 1
            else
                for _, dup in ipairs(scanData.duplicates) do
                    StatRow(order, "⧉", dup.name, dup.count, P.Warning)
                    order = order + 1
                end
            end

            StatusRow(T("ScanDone") .. " • " .. tostring(scanData.total) .. " " .. T("ItemsCount"), P.Success, order)
        end)
    end

    RunScan()

    -- إلغاء عند إغلاق الصفحة
    return function()
        token.cancelled = true
    end
end

return DeepAnalysis
