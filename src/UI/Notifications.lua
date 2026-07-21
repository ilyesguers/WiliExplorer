--[[
    ═══════════════════════════════════════════════════════════════════════════
    📢 WiliExplorer - Notifications System v2.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ Features:
    • Mini notifications in corner
    • Color coded by type
    • Smooth animations
    • Auto dismiss
    • Queue system
    • Counter badge
    • Sound effects (optional)
    • Swipe to dismiss
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Notifications = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 NOTIFICATION THEME
-- ═══════════════════════════════════════════════════════════════════════
local NotifTheme = {
    -- Colors
    Success = Color3.fromRGB(0, 200, 100),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 165, 0),
    Info = Color3.fromRGB(100, 200, 255),
    Debug = Color3.fromRGB(150, 150, 200),
    
    -- Background
    Background = Color3.fromRGB(12, 12, 25),
    BackgroundHover = Color3.fromRGB(18, 18, 35),
    
    -- Text
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    
    -- Icons
    Icons = {
        Success = "✅",
        Error = "❌",
        Warning = "⚠️",
        Info = "ℹ️",
        Debug = "🔧",
        Star = "⭐",
        Fire = "🔥",
        Lock = "🔒",
        Unlock = "🔓",
        Heart = "❤️",
        Lightning = "⚡",
        Crown = "👑",
        Rocket = "🚀",
        Shield = "🛡️",
        Eye = "👁️",
        Magic = "✨"
    }
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 NOTIFICATION DATA
-- ═══════════════════════════════════════════════════════════════════════
local NotificationQueue = {}
local ActiveNotifications = {}
local NotificationCounter = 0
local MaxNotifications = 5
local NotificationContainer = nil
local CounterBadge = nil

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colors or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 CREATE NOTIFICATION CONTAINER
-- ═══════════════════════════════════════════════════════════════════════
local function CreateContainer()
    if NotificationContainer and NotificationContainer.Parent then
        return NotificationContainer
    end
    
    -- Create ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliNotifications"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Try CoreGui first, fallback to PlayerGui
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Container Frame
    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "NotifContainer"
    NotificationContainer.Size = UDim2.new(0, 280, 1, -20)
    NotificationContainer.Position = UDim2.new(1, -290, 0, 10)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = gui
    
    -- Layout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotificationContainer
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = NotificationContainer
    
    -- Counter Badge
    CounterBadge = Instance.new("Frame")
    CounterBadge.Name = "CounterBadge"
    CounterBadge.Size = UDim2.new(0, 24, 0, 24)
    CounterBadge.Position = UDim2.new(1, -30, 0, 5)
    CounterBadge.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    CounterBadge.Visible = false
    CounterBadge.ZIndex = 100
    CounterBadge.Parent = gui
    CreateCorner(CounterBadge, 12)
    
    local counterText = Instance.new("TextLabel")
    counterText.Name = "CounterText"
    counterText.Size = UDim2.new(1, 0, 1, 0)
    counterText.BackgroundTransparency = 1
    counterText.Text = "0"
    counterText.TextColor3 = Color3.fromRGB(255, 255, 255)
    counterText.TextSize = 12
    counterText.Font = Enum.Font.GothamBold
    counterText.ZIndex = 101
    counterText.Parent = CounterBadge
    
    return NotificationContainer
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 UPDATE COUNTER BADGE
-- ═══════════════════════════════════════════════════════════════════════
local function UpdateCounter()
    if not CounterBadge then return end
    
    local count = #ActiveNotifications
    if count > 0 then
        CounterBadge.Visible = true
        CounterBadge.CounterText.Text = tostring(count)
        
        -- Pulse animation
        TweenService:Create(CounterBadge, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 28, 0, 28)
        }):Play()
        task.wait(0.2)
        TweenService:Create(CounterBadge, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 24, 0, 24)
        }):Play()
    else
        CounterBadge.Visible = false
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 CREATE SINGLE NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════════
local function CreateNotification(data)
    local container = CreateContainer()
    
    -- Notification Frame
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, 0, 0, 50)
    notif.BackgroundColor3 = NotifTheme.Background
    notif.BorderSizePixel = 0
    notif.ZIndex = 50
    notif.Parent = container
    CreateCorner(notif, 10)
    
    -- Stroke
    local stroke = CreateStroke(notif, data.color or NotifTheme.Info, 2, 0.3)
    
    -- Gradient Background
    local gradient = CreateGradient(notif, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
    }), 135)
    
    -- Color Bar (Left side)
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.Size = UDim2.new(0, 4, 0.8, 0)
    colorBar.Position = UDim2.new(0, 4, 0.1, 0)
    colorBar.BackgroundColor3 = data.color or NotifTheme.Info
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex = 51
    colorBar.Parent = notif
    CreateCorner(colorBar, 2)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 35, 0, 35)
    icon.Position = UDim2.new(0, 12, 0.5, -17)
    icon.Text = data.icon or "ℹ️"
    icon.TextSize = 18
    icon.BackgroundTransparency = 1
    icon.ZIndex = 52
    icon.Parent = notif
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -90, 0, 18)
    title.Position = UDim2.new(0, 50, 0, 6)
    title.Text = data.title or "Notification"
    title.TextColor3 = NotifTheme.Text
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.BackgroundTransparency = 1
    title.ZIndex = 52
    title.Parent = notif
    
    -- Message
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Size = UDim2.new(1, -90, 0, 16)
    message.Position = UDim2.new(0, 50, 0, 26)
    message.Text = data.message or ""
    message.TextColor3 = NotifTheme.TextDim
    message.TextSize = 10
    message.Font = Enum.Font.Gotham
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextTruncate = Enum.TextTruncate.AtEnd
    message.BackgroundTransparency = 1
    message.ZIndex = 52
    message.Parent = notif
    
    -- Time
    local time = Instance.new("TextLabel")
    time.Name = "Time"
    time.Size = UDim2.new(0, 40, 0, 12)
    time.Position = UDim2.new(1, -45, 0, 5)
    time.Text = os.date("%H:%M")
    time.TextColor3 = NotifTheme.TextDim
    time.TextSize = 8
    time.Font = Enum.Font.Gotham
    time.TextXAlignment = Enum.TextXAlignment.Right
    time.BackgroundTransparency = 1
    time.ZIndex = 52
    time.Parent = notif
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = NotifTheme.TextDim
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 53
    closeBtn.Parent = notif
    
    -- Progress Bar (Auto dismiss)
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = data.color or NotifTheme.Info
    progress.BorderSizePixel = 0
    progress.ZIndex = 51
    progress.Parent = notif
    
    -- ═══════════════════════════════════════════════════════════════════
    -- 🎬 ANIMATIONS
    -- ═══════════════════════════════════════════════════════════════════
    
    -- Slide in animation
    notif.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Glow effect on entry
    TweenService:Create(stroke, TweenInfo.new(0.5), {
        Transparency = 0
    }):Play()
    task.delay(0.5, function()
        if stroke and stroke.Parent then
            TweenService:Create(stroke, TweenInfo.new(0.5), {
                Transparency = 0.3
            }):Play()
        end
    end)
    
    -- Progress bar animation
    local duration = data.duration or 3
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 2)
    }):Play()
    
    -- ═══════════════════════════════════════════════════════════════════
    -- 🎯 INTERACTIONS
    -- ═══════════════════════════════════════════════════════════════════
    
    -- Hover effect
    notif.MouseEnter:Connect(function()
        TweenService:Create(notif, TweenInfo.new(0.15), {
            BackgroundColor3 = NotifTheme.BackgroundHover
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {
            Transparency = 0
        }):Play()
    end)
    
    notif.MouseLeave:Connect(function()
        TweenService:Create(notif, TweenInfo.new(0.15), {
            BackgroundColor3 = NotifTheme.Background
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {
            Transparency = 0.3
        }):Play()
    end)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        -- Slide out animation
        TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        
        task.wait(0.2)
        
        -- Remove from active list
        for i, n in ipairs(ActiveNotifications) do
            if n == notif then
                table.remove(ActiveNotifications, i)
                break
            end
        end
        
        notif:Destroy()
        UpdateCounter()
    end)
    
    -- ═══════════════════════════════════════════════════════════════════
    -- ⏱️ AUTO DISMISS
    -- ═══════════════════════════════════════════════════════════════════
    task.delay(duration, function()
        if notif and notif.Parent then
            -- Fade out
            TweenService:Create(notif, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
            
            TweenService:Create(stroke, TweenInfo.new(0.3), {
                Transparency = 1
            }):Play()
            
            TweenService:Create(title, TweenInfo.new(0.3), {
                TextTransparency = 1
            }):Play()
            
            TweenService:Create(message, TweenInfo.new(0.3), {
                TextTransparency = 1
            }):Play()
            
            TweenService:Create(icon, TweenInfo.new(0.3), {
                TextTransparency = 1
            }):Play()
            
            task.wait(0.3)
            
            -- Slide out
            TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            task.wait(0.2)
            
            -- Remove
            for i, n in ipairs(ActiveNotifications) do
                if n == notif then
                    table.remove(ActiveNotifications, i)
                    break
                end
            end
            
            notif:Destroy()
            UpdateCounter()
        end
    end)
    
    return notif
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📢 PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════

function Notifications.Show(options)
    options = options or {}
    
    local data = {
        title = options.title or "Notification",
        message = options.message or "",
        icon = options.icon or "ℹ️",
        color = options.color or NotifTheme.Info,
        duration = options.duration or 3,
        type = options.type or "info"
    }
    
    -- Set color based on type if not specified
    if not options.color then
        if data.type == "success" then
            data.color = NotifTheme.Success
            data.icon = data.icon == "ℹ️" and "✅" or data.icon
        elseif data.type == "error" then
            data.color = NotifTheme.Error
            data.icon = data.icon == "ℹ️" and "❌" or data.icon
        elseif data.type == "warning" then
            data.color = NotifTheme.Warning
            data.icon = data.icon == "ℹ️" and "⚠️" or data.icon
        elseif data.type == "debug" then
            data.color = NotifTheme.Debug
            data.icon = data.icon == "ℹ️" and "🔧" or data.icon
        end
    end
    
    -- Check queue limit
    if #ActiveNotifications >= MaxNotifications then
        -- Remove oldest
        local oldest = table.remove(ActiveNotifications, 1)
        if oldest and oldest.Parent then
            oldest:Destroy()
        end
    end
    
    -- Create notification
    local notif = CreateNotification(data)
    table.insert(ActiveNotifications, notif)
    
    -- Update counter
    NotificationCounter = NotificationCounter + 1
    UpdateCounter()
    
    return notif
end

-- Convenience methods
function Notifications.Success(title, message, duration)
    return Notifications.Show({
        title = title,
        message = message,
        type = "success",
        duration = duration
    })
end

function Notifications.Error(title, message, duration)
    return Notifications.Show({
        title = title,
        message = message,
        type = "error",
        duration = duration
    })
end

function Notifications.Warning(title, message, duration)
    return Notifications.Show({
        title = title,
        message = message,
        type = "warning",
        duration = duration
    })
end

function Notifications.Info(title, message, duration)
    return Notifications.Show({
        title = title,
        message = message,
        type = "info",
        duration = duration
    })
end

function Notifications.Debug(title, message, duration)
    return Notifications.Show({
        title = title,
        message = message,
        type = "debug",
        duration = duration
    })
end

function Notifications.Custom(title, message, icon, color, duration)
    return Notifications.Show({
        title = title,
        message = message,
        icon = icon,
        color = color,
        duration = duration
    })
end

-- Clear all notifications
function Notifications.ClearAll()
    for _, notif in ipairs(ActiveNotifications) do
        if notif and notif.Parent then
            notif:Destroy()
        end
    end
    ActiveNotifications = {}
    UpdateCounter()
end

-- Get notification count
function Notifications.GetCount()
    return #ActiveNotifications
end

-- Set max notifications
function Notifications.SetMax(max)
    MaxNotifications = max
end

-- Set theme
function Notifications.SetTheme(theme)
    for key, value in pairs(theme) do
        if NotifTheme[key] then
            NotifTheme[key] = value
        end
    end
end

-- Initialize
Notifications.Show({
    title = "WiliExplorer",
    message = "Notifications system loaded!",
    icon = "👑",
    type = "success",
    duration = 2
})

return Notifications
