-- WiliExplorer smart search and filter controls v2
local SearchBar = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local P = {
    BG = Color3.fromRGB(13, 18, 34), Raised = Color3.fromRGB(22, 29, 52),
    Hover = Color3.fromRGB(31, 41, 70), Border = Color3.fromRGB(48, 61, 91),
    Text = Color3.fromRGB(242, 247, 255), Muted = Color3.fromRGB(145, 162, 191),
    Accent = Color3.fromRGB(55, 211, 255), AccentStrong = Color3.fromRGB(36, 156, 255)
}

local SearchHistory = {}
local MAX_HISTORY = 10

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 10)
    value.Parent = parent
    return value
end

local function tween(object, props, duration)
    if object and object.Parent then
        TweenService:Create(object, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end
end

local function addHistory(query)
    query = tostring(query or ""):match("^%s*(.-)%s*$")
    if query == "" then return end
    for index = #SearchHistory, 1, -1 do
        if SearchHistory[index]:lower() == query:lower() then table.remove(SearchHistory, index) end
    end
    table.insert(SearchHistory, 1, query)
    while #SearchHistory > MAX_HISTORY do table.remove(SearchHistory) end
end

local function contains(text, query)
    return tostring(text):lower():find(tostring(query):lower(), 1, true) ~= nil
end

function SearchBar.Create(parent, options)
    options = options or {}
    local container = Instance.new("Frame")
    container.Name = "SmartSearch"
    container.Size = options.size or UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = P.BG
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = parent
    corner(container, 11)

    local stroke = Instance.new("UIStroke")
    stroke.Color = P.Border
    stroke.Thickness = 1
    stroke.Parent = container

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 42, 1, 0)
    icon.Text = "⌕"
    icon.TextColor3 = P.Muted
    icon.TextSize = 21
    icon.Font = Enum.Font.GothamBold
    icon.BackgroundTransparency = 1
    icon.Parent = container

    local actions = Instance.new("Frame")
    actions.Size = UDim2.new(0, 70, 1, 0)
    actions.Position = UDim2.new(1, -74, 0, 0)
    actions.BackgroundTransparency = 1
    actions.Parent = container

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionLayout.Padding = UDim.new(0, 4)
    actionLayout.Parent = actions

    local clear = Instance.new("TextButton")
    clear.Size = UDim2.new(0, 30, 0, 30)
    clear.Text = "×"
    clear.TextSize = 19
    clear.TextColor3 = P.Muted
    clear.BackgroundColor3 = P.Raised
    clear.Visible = false
    clear.Parent = actions
    corner(clear, 8)

    local filter = Instance.new("TextButton")
    filter.Size = UDim2.new(0, 34, 0, 30)
    filter.Text = "≡"
    filter.TextSize = 18
    filter.TextColor3 = P.Muted
    filter.BackgroundColor3 = P.Raised
    filter.Parent = actions
    corner(filter, 8)

    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -122, 1, -4)
    input.Position = UDim2.new(0, 42, 0, 2)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = options.placeholder or "Search by name, class or path…"
    input.PlaceholderColor3 = P.Muted
    input.TextColor3 = P.Text
    input.TextSize = 14
    input.Font = Enum.Font.GothamMedium
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = container

    local dropdown = Instance.new("ScrollingFrame")
    dropdown.Name = "Suggestions"
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.Position = UDim2.new(0, 0, 1, 6)
    dropdown.BackgroundColor3 = P.BG
    dropdown.BorderSizePixel = 0
    dropdown.ScrollBarThickness = 3
    dropdown.ScrollBarImageColor3 = P.Accent
    dropdown.ClipsDescendants = true
    dropdown.Visible = false
    dropdown.ZIndex = 200
    dropdown.Parent = container
    corner(dropdown, 11)
    local dropStroke = Instance.new("UIStroke")
    dropStroke.Color = P.Border
    dropStroke.Parent = dropdown
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 3)
    list.Parent = dropdown
    local padding = Instance.new("UIPadding")
    padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 5), UDim.new(0, 5)
    padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 5), UDim.new(0, 5)
    padding.Parent = dropdown

    local focused = false
    local api = {}

    local function hideSuggestions()
        tween(dropdown, {Size = UDim2.new(1, 0, 0, 0)}, 0.12)
        task.delay(0.13, function() if not focused then dropdown.Visible = false end end)
    end

    local function choose(value)
        input.Text = value
        addHistory(value)
        focused = false
        input:ReleaseFocus()
        hideSuggestions()
        if options.onSubmit then options.onSubmit(value) end
        if options.onSearch then options.onSearch(value) end
    end

    local function showSuggestions(query)
        for _, child in ipairs(dropdown:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local source = {}
        for _, item in ipairs(options.suggestions or {}) do
            if query == "" or contains(item, query) then table.insert(source, {value = item, recent = false}) end
            if #source >= 8 then break end
        end
        for _, item in ipairs(SearchHistory) do
            if (query == "" or contains(item, query)) then
                local duplicate = false
                for _, existing in ipairs(source) do if existing.value == item then duplicate = true break end end
                if not duplicate then table.insert(source, 1, {value = item, recent = true}) end
            end
            if #source >= 8 then break end
        end
        if #source == 0 or not focused then hideSuggestions() return end

        for index, suggestion in ipairs(source) do
            if index > 8 then break end
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, -10, 0, 36)
            row.BackgroundColor3 = P.Raised
            row.BackgroundTransparency = 1
            row.Text = (suggestion.recent and "↻  " or "⌕  ") .. suggestion.value
            row.TextColor3 = P.Text
            row.TextSize = 12
            row.Font = Enum.Font.Gotham
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.TextTruncate = Enum.TextTruncate.AtEnd
            row.ZIndex = 201
            row.Parent = dropdown
            corner(row, 7)
            local rowPad = Instance.new("UIPadding")
            rowPad.PaddingLeft = UDim.new(0, 10)
            rowPad.PaddingRight = UDim.new(0, 10)
            rowPad.Parent = row
            row.MouseEnter:Connect(function() tween(row, {BackgroundTransparency = 0}, 0.1) end)
            row.MouseLeave:Connect(function() tween(row, {BackgroundTransparency = 1}, 0.1) end)
            row.MouseButton1Click:Connect(function() choose(suggestion.value) end)
        end
        local height = math.min(#source, 8) * 39 + 10
        dropdown.CanvasSize = UDim2.new(0, 0, 0, height)
        dropdown.Visible = true
        tween(dropdown, {Size = UDim2.new(1, 0, 0, math.min(height, 205))}, 0.16)
    end

    input.Focused:Connect(function()
        focused = true
        tween(stroke, {Color = P.Accent, Thickness = 2})
        tween(icon, {TextColor3 = P.Accent})
        showSuggestions(input.Text)
    end)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and input.Text ~= "" then addHistory(input.Text) end
        task.delay(0.12, function()
            focused = false
            tween(stroke, {Color = P.Border, Thickness = 1})
            tween(icon, {TextColor3 = P.Muted})
            hideSuggestions()
        end)
    end)
    input:GetPropertyChangedSignal("Text"):Connect(function()
        clear.Visible = input.Text ~= ""
        if focused then showSuggestions(input.Text) end
        if options.onSearch then options.onSearch(input.Text) end
    end)
    clear.MouseButton1Click:Connect(function() input.Text = "" input:CaptureFocus() end)
    filter.MouseButton1Click:Connect(function()
        filter.TextColor3 = P.Accent
        if options.onFilter then options.onFilter() end
    end)

    function api:GetText() return input.Text end
    function api:SetText(value) input.Text = tostring(value or "") end
    function api:Focus() input:CaptureFocus() end
    function api:Submit() choose(input.Text) end
    function api:ClearHistory() SearchHistory = {} end
    function api:GetHistory() return SearchHistory end
    function api:SetSuggestions(values) options.suggestions = values or {} end
    function api:SetFilterActive(active) filter.TextColor3 = active and P.Accent or P.Muted end
    function api:Destroy() container:Destroy() end

    if options.shortcut ~= false then
        UserInputService.InputBegan:Connect(function(key, processed)
            if not processed and key.KeyCode == Enum.KeyCode.F and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                input:CaptureFocus()
            end
        end)
    end
    return api, container
end

function SearchBar.CreateFilter(parent, filters, options)
    options = options or {}
    filters = filters or {}
    local container = Instance.new("ScrollingFrame")
    container.Name = "FilterChips"
    container.Size = options.size or UDim2.new(1, 0, 0, 42)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 0
    container.ScrollingDirection = Enum.ScrollingDirection.X
    container.AutomaticCanvasSize = Enum.AutomaticSize.X
    container.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 7)
    layout.Parent = container
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 2), UDim.new(0, 8)
    pad.Parent = container

    local state, buttons = {}, {}
    local api = {}
    local function emit()
        if options.onChange then options.onChange(state) end
    end

    for index, item in ipairs(filters) do
        local id = item.id or item.name or tostring(index)
        state[id] = item.active == true
        local button = Instance.new("TextButton")
        button.Name = "Filter_" .. id
        button.AutomaticSize = Enum.AutomaticSize.X
        button.Size = UDim2.new(0, 0, 0, 32)
        button.BackgroundColor3 = state[id] and (item.color or P.AccentStrong) or P.Raised
        button.Text = (item.icon and item.icon .. "  " or "") .. (item.label or item.name or id)
        button.TextColor3 = P.Text
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.Parent = container
        corner(button, 9)
        local bp = Instance.new("UIPadding")
        bp.PaddingLeft, bp.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
        bp.Parent = button
        buttons[id] = button
        button.MouseButton1Click:Connect(function()
            if options.single then
                for key in pairs(state) do
                    state[key] = false
                    buttons[key].BackgroundColor3 = P.Raised
                end
            end
            state[id] = not state[id]
            tween(button, {BackgroundColor3 = state[id] and (item.color or P.AccentStrong) or P.Raised})
            emit()
        end)
    end

    function api:GetActive()
        local active = {}
        for id, value in pairs(state) do if value then table.insert(active, id) end end
        return active
    end
    function api:IsActive(id) return state[id] == true end
    function api:SetActive(id, active)
        if state[id] == nil then return end
        state[id] = active == true
        buttons[id].BackgroundColor3 = state[id] and P.AccentStrong or P.Raised
        emit()
    end
    function api:Clear()
        for id in pairs(state) do state[id] = false buttons[id].BackgroundColor3 = P.Raised end
        emit()
    end

    -- Keep the legacy second return value (state table), add a richer third return.
    return container, state, api
end

function SearchBar.Match(item, query, activeFilters)
    query = tostring(query or ""):lower():match("^%s*(.-)%s*$")
    local name = tostring(item.Name or item.name or "")
    local className = tostring(item.ClassName or item.className or item.type or "")
    local path = tostring(item.Path or item.path or "")
    local queryMatch = query == "" or contains(name, query) or contains(className, query) or contains(path, query)
    if not queryMatch then return false end
    if not activeFilters then return true end
    local hasActive = false
    for _, active in pairs(activeFilters) do if active then hasActive = true break end end
    if not hasActive then return true end
    return activeFilters[className] == true or activeFilters[className:lower()] == true
end

return SearchBar
