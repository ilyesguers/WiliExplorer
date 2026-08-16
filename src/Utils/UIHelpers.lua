-- Shared UI primitives. Keeps visual behavior and theme usage consistent.
local UIHelpers = {}

local TweenService = game:GetService("TweenService")

local function palette()
    local Colors = _G.WiliModules and _G.WiliModules.Colors
    local C = Colors and Colors.Current or {}
    return {
        Surface = C.BG_Card or Color3.fromRGB(15, 20, 38),
        Raised = C.BG_CardHover or Color3.fromRGB(23, 31, 55),
        Border = C.Border or Color3.fromRGB(45, 58, 86),
        Text = C.Text_Primary or Color3.fromRGB(242, 247, 255),
        Muted = C.Text_Secondary or Color3.fromRGB(150, 168, 197),
        Accent = C.Accent or Color3.fromRGB(55, 211, 255)
    }
end

function UIHelpers.GetModule(name, required)
    local value = _G.WiliModules and _G.WiliModules[name]
    if not value and required ~= false then error("Module not loaded: " .. tostring(name), 2) end
    return value
end

function UIHelpers.Corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 10)
    value.Parent = parent
    return value
end

function UIHelpers.Stroke(parent, color, transparency, thickness)
    local value = Instance.new("UIStroke")
    value.Color = color or palette().Border
    value.Transparency = transparency or 0
    value.Thickness = thickness or 1
    value.Parent = parent
    return value
end

function UIHelpers.Padding(parent, horizontal, vertical)
    local value = Instance.new("UIPadding")
    value.PaddingLeft = UDim.new(0, horizontal or 12)
    value.PaddingRight = UDim.new(0, horizontal or 12)
    value.PaddingTop = UDim.new(0, vertical or 8)
    value.PaddingBottom = UDim.new(0, vertical or 8)
    value.Parent = parent
    return value
end

function UIHelpers.Tween(object, properties, duration)
    if not object or not object.Parent then return nil end
    local value = TweenService:Create(object, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    value:Play()
    return value
end

function UIHelpers.Card(parent, height)
    local C = palette()
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, height or 72)
    card.BackgroundColor3 = C.Surface
    card.BorderSizePixel = 0
    card.Parent = parent
    UIHelpers.Corner(card, 12)
    UIHelpers.Stroke(card, C.Border, 0.25)
    return card
end

function UIHelpers.Button(parent, text, icon, callback)
    local C = palette()
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 48)
    button.BackgroundColor3 = C.Surface
    button.BorderSizePixel = 0
    button.Text = (icon and icon .. "  " or "") .. text
    button.TextColor3 = C.Text
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = parent
    UIHelpers.Corner(button, 11)
    UIHelpers.Stroke(button, C.Border, 0.25)
    button.MouseEnter:Connect(function() UIHelpers.Tween(button, {BackgroundColor3 = C.Raised}) end)
    button.MouseLeave:Connect(function() UIHelpers.Tween(button, {BackgroundColor3 = C.Surface}) end)
    if callback then button.MouseButton1Click:Connect(callback) end
    return button
end

function UIHelpers.BindCanvas(scroll, layout, extra)
    local function update()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + (extra or 16))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

function UIHelpers.Notify(message, kind)
    local Notifications = _G.WiliModules and _G.WiliModules.Notifications
    local method = Notifications and Notifications[kind or "Info"]
    if method then pcall(method, message, "WiliExplorer", 3) else warn("[WiliExplorer] " .. tostring(message)) end
end

return UIHelpers
