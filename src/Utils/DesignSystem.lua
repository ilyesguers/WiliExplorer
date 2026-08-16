--[[
    WiliExplorer Design System v6
    Shared visual tokens, responsive layouts and accessible UI primitives.
]]

local Design = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

Design.Breakpoints = {
    Compact = 520,
    Mobile = 800,
    Desktop = 1180
}

Design.Space = {XS = 4, SM = 8, MD = 12, LG = 16, XL = 24, XXL = 32}
Design.Radius = {SM = 6, MD = 10, LG = 14, XL = 18, Pill = 999}
Design.TouchTarget = 44
Design.Font = {
    Regular = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
    Display = Enum.Font.GothamBlack,
    Mono = Enum.Font.Code
}

Design.Palette = {
    Canvas = Color3.fromRGB(7, 10, 20),
    Surface = Color3.fromRGB(13, 18, 34),
    SurfaceRaised = Color3.fromRGB(19, 26, 48),
    SurfaceHover = Color3.fromRGB(27, 36, 63),
    Border = Color3.fromRGB(48, 61, 91),
    BorderSoft = Color3.fromRGB(33, 43, 68),
    Text = Color3.fromRGB(242, 247, 255),
    TextMuted = Color3.fromRGB(153, 169, 196),
    TextDim = Color3.fromRGB(107, 124, 153),
    Accent = Color3.fromRGB(55, 211, 255),
    AccentStrong = Color3.fromRGB(36, 156, 255),
    Purple = Color3.fromRGB(153, 107, 255),
    Success = Color3.fromRGB(55, 218, 142),
    Warning = Color3.fromRGB(255, 190, 76),
    Danger = Color3.fromRGB(255, 91, 115)
}

function Design.GetViewport()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

function Design.GetMode(width)
    width = width or Design.GetViewport().X
    if width <= Design.Breakpoints.Compact then return "compact" end
    if width <= Design.Breakpoints.Mobile then return "mobile" end
    if width <= Design.Breakpoints.Desktop then return "tablet" end
    return "desktop"
end

function Design.IsTouch()
    return UserInputService.TouchEnabled
end

function Design.WindowSize(viewport)
    viewport = viewport or Design.GetViewport()
    local mode = Design.GetMode(viewport.X)
    if mode == "compact" then
        return Vector2.new(math.max(300, viewport.X - 12), math.max(300, viewport.Y - 18))
    elseif mode == "mobile" then
        return Vector2.new(math.max(300, viewport.X - 24), math.max(300, math.min(viewport.Y - 30, 720)))
    elseif mode == "tablet" then
        return Vector2.new(math.min(900, viewport.X - 48), math.min(660, viewport.Y - 60))
    end
    return Vector2.new(math.min(1040, viewport.X - 80), math.min(720, viewport.Y - 80))
end

function Design.Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Design.Radius.MD)
    corner.Parent = parent
    return corner
end

function Design.Stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Design.Palette.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Design.Padding(parent, horizontal, vertical)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, horizontal or Design.Space.MD)
    padding.PaddingRight = UDim.new(0, horizontal or Design.Space.MD)
    padding.PaddingTop = UDim.new(0, vertical or Design.Space.MD)
    padding.PaddingBottom = UDim.new(0, vertical or Design.Space.MD)
    padding.Parent = parent
    return padding
end

function Design.Gradient(parent, first, last, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(first or Design.Palette.Accent, last or Design.Palette.Purple)
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

function Design.Tween(object, properties, duration, style)
    if not object or not object.Parent then return nil end
    local tween = TweenService:Create(object, TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ), properties)
    tween:Play()
    return tween
end

function Design.MakeInteractive(button, options)
    options = options or {}
    button.AutoButtonColor = false
    local normal = options.normal or button.BackgroundColor3
    local hover = options.hover or Design.Palette.SurfaceHover
    local pressed = options.pressed or Design.Palette.AccentStrong

    button.MouseEnter:Connect(function()
        Design.Tween(button, {BackgroundColor3 = hover}, 0.12)
    end)
    button.MouseLeave:Connect(function()
        Design.Tween(button, {BackgroundColor3 = normal}, 0.12)
    end)
    button.MouseButton1Down:Connect(function()
        Design.Tween(button, {BackgroundColor3 = pressed}, 0.07)
    end)
    button.MouseButton1Up:Connect(function()
        Design.Tween(button, {BackgroundColor3 = hover}, 0.1)
    end)
    return button
end

function Design.Button(parent, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Name = options.name or "Button"
    button.Size = options.size or UDim2.new(0, 120, 0, Design.TouchTarget)
    button.BackgroundColor3 = options.color or Design.Palette.SurfaceRaised
    button.BorderSizePixel = 0
    button.Text = (options.icon and options.icon .. "  " or "") .. (options.text or "Button")
    button.TextColor3 = options.textColor or Design.Palette.Text
    button.TextSize = options.textSize or 13
    button.Font = options.font or Design.Font.Bold
    button.TextTruncate = Enum.TextTruncate.AtEnd
    button.Parent = parent
    Design.Corner(button, options.radius or Design.Radius.MD)
    if options.stroke ~= false then Design.Stroke(button, options.strokeColor or Design.Palette.Border, 1, 0.2) end
    Design.MakeInteractive(button, {normal = button.BackgroundColor3, hover = options.hover})
    return button
end

function Design.Card(parent, options)
    options = options or {}
    local card = Instance.new("Frame")
    card.Name = options.name or "Card"
    card.Size = options.size or UDim2.new(1, 0, 0, 80)
    card.BackgroundColor3 = options.color or Design.Palette.Surface
    card.BackgroundTransparency = options.transparency or 0
    card.BorderSizePixel = 0
    card.Parent = parent
    Design.Corner(card, options.radius or Design.Radius.LG)
    Design.Stroke(card, options.strokeColor or Design.Palette.BorderSoft, 1, options.strokeTransparency or 0.15)
    return card
end

function Design.BindResponsive(gui, callback)
    local camera = workspace.CurrentCamera
    local connection
    local lastMode

    local function update()
        local viewport = Design.GetViewport()
        local mode = Design.GetMode(viewport.X)
        if mode ~= lastMode then lastMode = mode end
        callback(mode, viewport)
    end

    if camera then
        connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    end
    update()

    if gui and gui.Destroying then
        gui.Destroying:Connect(function()
            if connection then connection:Disconnect() end
        end)
    end
    return connection
end

function Design.ApplyCanvas(scroll, layout, extra)
    local function update()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 16))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

return Design
