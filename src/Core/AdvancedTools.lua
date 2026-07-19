--[[
    ═══════════════════════════════════════════════════════════════════════
    🌟 WiliExplorer - Advanced Tools v2.0
    ═══════════════════════════════════════════════════════════════════════
    
    📦 المحتويات:
    ├── 🧱 ModelEditor     - محرر المجسمات والأجزاء
    ├── ⚡ Activator       - تفعيل الأشياء (أبواب، أزرار، إلخ)
    ├── 🎨 Customizer      - تخصيص المظهر (ألوان، مواد، شفافية)
    ├── 📍 Teleporter      - النقل الفوري للأماكن
    ├── 👁️ Visualizer      - عرض الحدود والمعلومات
    ├── 🔧 PropertyPanel   - لوحة الخصائص الكاملة
    └── ✨ Animations      - أنيميشن جمالية
    
    ═══════════════════════════════════════════════════════════════════════
]]

local AdvancedTools = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان والتصميم
-- ═══════════════════════════════════════════════════════════════════════
local Theme = {
    Primary = Color3.fromRGB(0, 212, 255),
    Secondary = Color3.fromRGB(138, 43, 226),
    Success = Color3.fromRGB(0, 255, 136),
    Warning = Color3.fromRGB(255, 193, 7),
    Danger = Color3.fromRGB(255, 71, 87),
    Dark = Color3.fromRGB(15, 17, 35),
    Darker = Color3.fromRGB(10, 12, 25),
    Light = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(120, 130, 150),
    
    -- Gradients
    GradientPurple = {
        Color3.fromRGB(138, 43, 226),
        Color3.fromRGB(75, 0, 130)
    },
    GradientCyan = {
        Color3.fromRGB(0, 212, 255),
        Color3.fromRGB(0, 150, 200)
    }
}

-- ═══════════════════════════════════════════════════════════════════════
-- ✨ نظام الأنيميشن
-- ═══════════════════════════════════════════════════════════════════════
local Animations = {}

function Animations.FadeIn(element, duration)
    duration = duration or 0.3
    element.BackgroundTransparency = 1
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        element.TextTransparency = 1
    end
    
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    })
    
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        TweenService:Create(element, TweenInfo.new(duration), {TextTransparency = 0}):Play()
    end
    
    tween:Play()
    return tween
end

function Animations.FadeOut(element, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Quart), {
        BackgroundTransparency = 1
    })
    
    if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
        TweenService:Create(element, TweenInfo.new(duration), {TextTransparency = 1}):Play()
    end
    
    tween:Play()
    return tween
end

function Animations.SlideIn(element, direction, duration)
    duration = duration or 0.4
    direction = direction or "left"
    
    local originalPos = element.Position
    local startPos
    
    if direction == "left" then
        startPos = UDim2.new(originalPos.X.Scale - 0.5, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
    elseif direction == "right" then
        startPos = UDim2.new(originalPos.X.Scale + 0.5, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset)
    elseif direction == "top" then
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale - 0.5, originalPos.Y.Offset)
    else
        startPos = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale + 0.5, originalPos.Y.Offset)
    end
    
    element.Position = startPos
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = originalPos
    })
    tween:Play()
    return tween
end

function Animations.Pop(element, duration)
    duration = duration or 0.3
    local originalSize = element.Size
    element.Size = UDim2.new(originalSize.X.Scale * 0.8, originalSize.X.Offset * 0.8, originalSize.Y.Scale * 0.8, originalSize.Y.Offset * 0.8)
    
    local tween = TweenService:Create(element, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize
    })
    tween:Play()
    return tween
end

function Animations.Pulse(element, color, duration)
    duration = duration or 0.5
    color = color or Theme.Primary
    
    local originalColor = element.BackgroundColor3
    
    TweenService:Create(element, TweenInfo.new(duration/2), {BackgroundColor3 = color}):Play()
    task.delay(duration/2, function()
        TweenService:Create(element, TweenInfo.new(duration/2), {BackgroundColor3 = originalColor}):Play()
    end)
end

function Animations.Shake(element, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.3
    
    local originalPos = element.Position
    local startTime = tick()
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if tick() - startTime > duration then
            element.Position = originalPos
            connection:Disconnect()
            return
        end
        
        local offsetX = math.random(-intensity, intensity)
        local offsetY = math.random(-intensity, intensity)
        element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offsetX, originalPos.Y.Scale, originalPos.Y.Offset + offsetY)
    end)
end

function Animations.Glow(element, color, duration)
    duration = duration or 1
    color = color or Theme.Primary
    
    local stroke = element:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Parent = element
    end
    
    stroke.Color = color
    stroke.Transparency = 0
    
    task.spawn(function()
        while stroke.Parent do
            TweenService:Create(stroke, TweenInfo.new(duration/2), {Transparency = 0.7}):Play()
            task.wait(duration/2)
            TweenService:Create(stroke, TweenInfo.new(duration/2), {Transparency = 0}):Play()
            task.wait(duration/2)
        end
    end)
    
    return stroke
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔔 نظام الإشعارات الجميلة
-- ═══════════════════════════════════════════════════════════════════════
local Notifications = {}
Notifications.Container = nil

function Notifications.Init(parent)
    if Notifications.Container then return end
    
    Notifications.Container = Instance.new("Frame")
    Notifications.Container.Name = "NotificationContainer"
    Notifications.Container.Size = UDim2.new(0, 320, 1, 0)
    Notifications.Container.Position = UDim2.new(1, -330, 0, 0)
    Notifications.Container.BackgroundTransparency = 1
    Notifications.Container.ZIndex = 999
    Notifications.Container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = Notifications.Container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = Notifications.Container
end

function Notifications.Show(title, message, notifType, duration)
    if not Notifications.Container then return end
    
    duration = duration or 3
    notifType = notifType or "info"
    
    local colors = {
        info = Theme.Primary,
        success = Theme.Success,
        warning = Theme.Warning,
        error = Theme.Danger
    }
    
    local icons = {
        info = "ℹ️",
        success = "✅",
        warning = "⚠️",
        error = "❌"
    }
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 70)
    notif.BackgroundColor3 = Theme.Darker
    notif.BorderSizePixel = 0
    notif.ZIndex = 1000
    notif.Parent = Notifications.Container
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors[notifType]
    stroke.Thickness = 2
    stroke.Parent = notif
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -10)
    accent.Position = UDim2.new(0, 5, 0, 5)
    accent.BackgroundColor3 = colors[notifType]
    accent.BorderSizePixel = 0
    accent.ZIndex = 1001
    accent.Parent = notif
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 20, 0, 10)
    icon.Text = icons[notifType]
    icon.TextSize = 20
    icon.BackgroundTransparency = 1
    icon.ZIndex = 1001
    icon.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 22)
    titleLabel.Position = UDim2.new(0, 55, 0, 8)
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Light
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.ZIndex = 1001
    titleLabel.Parent = notif
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -70, 0, 30)
    messageLabel.Position = UDim2.new(0, 55, 0, 30)
    messageLabel.Text = message
    messageLabel.TextColor3 = Theme.Gray
    messageLabel.TextSize = 12
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.BackgroundTransparency = 1
    messageLabel.ZIndex = 1001
    messageLabel.Parent = notif
    
    -- Progress bar
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, -20, 0, 3)
    progress.Position = UDim2.new(0, 10, 1, -8)
    progress.BackgroundColor3 = colors[notifType]
    progress.BorderSizePixel = 0
    progress.ZIndex = 1001
    progress.Parent = notif
    Instance.new("UICorner", progress).CornerRadius = UDim.new(0, 2)
    
    -- Animate in
    Animations.SlideIn(notif, "right", 0.3)
    Animations.Pop(notif, 0.3)
    
    -- Progress animation
    TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Remove after duration
    task.delay(duration, function()
        Animations.FadeOut(notif, 0.3)
        task.wait(0.3)
        notif:Destroy()
    end)
    
    return notif
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🧱 محرر المجسمات (Model & Part Editor)
-- ═══════════════════════════════════════════════════════════════════════
local ModelEditor = {}

-- خصائص يمكن تعديلها
ModelEditor.EditableProperties = {
    BasePart = {
        "Position", "Size", "Orientation", "Color", "Material", 
        "Transparency", "Reflectance", "CanCollide", "Anchored",
        "CastShadow", "Massless"
    },
    Model = {
        "Name", "PrimaryPart"
    },
    Decal = {
        "Texture", "Transparency", "Color3", "Face"
    },
    Texture = {
        "Texture", "Transparency", "Color3", "Face",
        "OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV"
    },
    PointLight = {
        "Brightness", "Color", "Range", "Shadows", "Enabled"
    },
    SpotLight = {
        "Brightness", "Color", "Range", "Angle", "Face", "Shadows", "Enabled"
    },
    Fire = {
        "Color", "SecondaryColor", "Size", "Heat", "Enabled"
    },
    Smoke = {
        "Color", "Opacity", "Size", "RiseVelocity", "Enabled"
    },
    ParticleEmitter = {
        "Color", "Size", "Transparency", "Lifetime", "Rate", 
        "Speed", "SpreadAngle", "Enabled"
    }
}

-- المواد المتاحة
ModelEditor.Materials = {
    "Plastic", "Wood", "Slate", "Concrete", "CorrodedMetal",
    "DiamondPlate", "Foil", "Grass", "Ice", "Marble", "Granite",
    "Brick", "Pebble", "Sand", "Fabric", "SmoothPlastic", "Metal",
    "WoodPlanks", "Cobblestone", "Neon", "Glass", "ForceField"
}

function ModelEditor.GetInfo(instance)
    local info = {
        Name = "",
        ClassName = "",
        FullPath = "",
        Properties = {},
        CanEdit = false,
        Children = 0,
        IsModel = false,
        IsPart = false,
        Position = nil,
        Size = nil
    }
    
    pcall(function()
        info.Name = instance.Name
        info.ClassName = instance.ClassName
        info.FullPath = instance:GetFullName()
        info.Children = #instance:GetChildren()
        
        info.IsModel = instance:IsA("Model")
        info.IsPart = instance:IsA("BasePart")
        
        if info.IsPart then
            info.Position = instance.Position
            info.Size = instance.Size
            info.CanEdit = true
        end
        
        if info.IsModel then
            info.CanEdit = true
            if instance.PrimaryPart then
                info.Position = instance.PrimaryPart.Position
            end
        end
    end)
    
    return info
end

function ModelEditor.SetProperty(instance, property, value)
    local result = {success = false, error = "", oldValue = nil}
    
    pcall(function()
        result.oldValue = instance[property]
    end)
    
    local ok, err = pcall(function()
        instance[property] = value
    end)
    
    if ok then
        result.success = true
    else
        result.error = tostring(err)
    end
    
    return result
end

function ModelEditor.Move(instance, direction, distance)
    distance = distance or 1
    
    local offset = Vector3.new(0, 0, 0)
    if direction == "up" then offset = Vector3.new(0, distance, 0)
    elseif direction == "down" then offset = Vector3.new(0, -distance, 0)
    elseif direction == "left" then offset = Vector3.new(-distance, 0, 0)
    elseif direction == "right" then offset = Vector3.new(distance, 0, 0)
    elseif direction == "forward" then offset = Vector3.new(0, 0, -distance)
    elseif direction == "backward" then offset = Vector3.new(0, 0, distance)
    end
    
    local ok, err = pcall(function()
        if instance:IsA("Model") and instance.PrimaryPart then
            instance:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame + offset)
        elseif instance:IsA("BasePart") then
            instance.Position = instance.Position + offset
        end
    end)
    
    return ok, err
end

function ModelEditor.Rotate(instance, axis, degrees)
    degrees = degrees or 15
    
    local ok, err = pcall(function()
        if instance:IsA("Model") and instance.PrimaryPart then
            local cf = instance.PrimaryPart.CFrame
            if axis == "x" then
                instance:SetPrimaryPartCFrame(cf * CFrame.Angles(math.rad(degrees), 0, 0))
            elseif axis == "y" then
                instance:SetPrimaryPartCFrame(cf * CFrame.Angles(0, math.rad(degrees), 0))
            elseif axis == "z" then
                instance:SetPrimaryPartCFrame(cf * CFrame.Angles(0, 0, math.rad(degrees)))
            end
        elseif instance:IsA("BasePart") then
            local cf = instance.CFrame
            if axis == "x" then
                instance.CFrame = cf * CFrame.Angles(math.rad(degrees), 0, 0)
            elseif axis == "y" then
                instance.CFrame = cf * CFrame.Angles(0, math.rad(degrees), 0)
            elseif axis == "z" then
                instance.CFrame = cf * CFrame.Angles(0, 0, math.rad(degrees))
            end
        end
    end)
    
    return ok, err
end

function ModelEditor.Scale(instance, factor)
    factor = factor or 1.1
    
    local ok, err = pcall(function()
        if instance:IsA("BasePart") then
            instance.Size = instance.Size * factor
        elseif instance:IsA("Model") then
            for _, part in ipairs(instance:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * factor
                end
            end
        end
    end)
    
    return ok, err
end

function ModelEditor.Clone(instance)
    local clone = nil
    local ok, err = pcall(function()
        clone = instance:Clone()
        clone.Parent = instance.Parent
        clone.Name = instance.Name .. "_Copy"
        
        if clone:IsA("BasePart") then
            clone.Position = clone.Position + Vector3.new(2, 0, 0)
        elseif clone:IsA("Model") and clone.PrimaryPart then
            clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame + Vector3.new(5, 0, 0))
        end
    end)
    
    return ok, clone, err
end

function ModelEditor.Delete(instance)
    local ok, err = pcall(function()
        instance:Destroy()
    end)
    return ok, err
end

function ModelEditor.TeleportTo(instance)
    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPos
        if instance:IsA("BasePart") then
            targetPos = instance.Position + Vector3.new(0, 5, 0)
        elseif instance:IsA("Model") and instance.PrimaryPart then
            targetPos = instance.PrimaryPart.Position + Vector3.new(0, 5, 0)
        else
            return
        end
        
        hrp.CFrame = CFrame.new(targetPos)
    end)
    
    return ok, err
end

function ModelEditor.BringToMe(instance)
    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPos = hrp.Position + hrp.CFrame.LookVector * 5
        
        if instance:IsA("BasePart") then
            instance.Position = targetPos
        elseif instance:IsA("Model") and instance.PrimaryPart then
            instance:SetPrimaryPartCFrame(CFrame.new(targetPos))
        end
    end)
    
    return ok, err
end

-- ═══════════════════════════════════════════════════════════════════════
-- ⚡ نظام التفعيل (Activator)
-- ═══════════════════════════════════════════════════════════════════════
local Activator = {}

-- أنواع الأشياء القابلة للتفعيل
Activator.ActivatableTypes = {
    "ProximityPrompt",    -- E للتفاعل
    "ClickDetector",       -- نقر
    "TouchTransmitter",    -- لمس
    "Tool",               -- أداة
    "Dialog",             -- حوار
    "Seat",               -- كرسي
    "VehicleSeat",        -- مقعد مركبة
    "SkateboardPlatform"  -- سكيتبورد
}

function Activator.GetInfo(instance)
    local info = {
        Name = "",
        Type = "",
        CanActivate = false,
        ActivateMethod = "none",
        Details = {}
    }
    
    pcall(function()
        info.Name = instance.Name
        info.Type = instance.ClassName
        
        -- ProximityPrompt
        if instance:IsA("ProximityPrompt") then
            info.CanActivate = true
            info.ActivateMethod = "fireproximityprompt"
            info.Details = {
                ActionText = instance.ActionText,
                ObjectText = instance.ObjectText,
                HoldDuration = instance.HoldDuration,
                Enabled = instance.Enabled
            }
        
        -- ClickDetector
        elseif instance:IsA("ClickDetector") then
            info.CanActivate = true
            info.ActivateMethod = "fireclickdetector"
            info.Details = {
                MaxActivationDistance = instance.MaxActivationDistance,
                CursorIcon = instance.CursorIcon
            }
        
        -- Tool
        elseif instance:IsA("Tool") then
            info.CanActivate = true
            info.ActivateMethod = "equip"
            info.Details = {
                ToolTip = instance.ToolTip,
                RequiresHandle = instance.RequiresHandle,
                CanBeDropped = instance.CanBeDropped
            }
        
        -- Seat
        elseif instance:IsA("Seat") or instance:IsA("VehicleSeat") then
            info.CanActivate = true
            info.ActivateMethod = "sit"
            info.Details = {
                Disabled = instance.Disabled,
                Occupant = instance.Occupant and instance.Occupant.Name or "None"
            }
        end
    end)
    
    return info
end

function Activator.Activate(instance)
    local result = {success = false, method = "", error = ""}
    
    pcall(function()
        -- ProximityPrompt
        if instance:IsA("ProximityPrompt") then
            if fireproximityprompt then
                fireproximityprompt(instance)
                result.success = true
                result.method = "fireproximityprompt"
            else
                -- Fallback
                instance:InputHoldBegin()
                task.wait(instance.HoldDuration + 0.1)
                instance:InputHoldEnd()
                result.success = true
                result.method = "InputHold"
            end
        
        -- ClickDetector
        elseif instance:IsA("ClickDetector") then
            if fireclickdetector then
                fireclickdetector(instance)
                result.success = true
                result.method = "fireclickdetector"
            else
                -- Manual fire
                local clickEvent = instance:FindFirstChild("MouseClick") or instance.MouseClick
                if clickEvent then
                    clickEvent:Fire(LocalPlayer)
                    result.success = true
                    result.method = "MouseClick:Fire"
                end
            end
        
        -- Tool
        elseif instance:IsA("Tool") then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                instance.Parent = bp
                task.wait(0.1)
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:EquipTool(instance)
                        result.success = true
                        result.method = "EquipTool"
                    end
                end
            end
        
        -- Seat
        elseif instance:IsA("Seat") or instance:IsA("VehicleSeat") then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    instance:Sit(humanoid)
                    result.success = true
                    result.method = "Sit"
                end
            end
        
        -- Generic - try to find and call Activate
        else
            if instance.Activate then
                instance:Activate()
                result.success = true
                result.method = "Activate"
            end
        end
    end)
    
    return result
end

function Activator.Toggle(instance, enabled)
    local ok, err = pcall(function()
        if instance:IsA("ProximityPrompt") then
            instance.Enabled = enabled
        elseif instance:IsA("Seat") or instance:IsA("VehicleSeat") then
            instance.Disabled = not enabled
        elseif instance:FindFirstChild("Enabled") then
            instance.Enabled = enabled
        end
    end)
    return ok, err
end

function Activator.FindAll(parent)
    local found = {}
    
    pcall(function()
        for _, instance in ipairs(parent:GetDescendants()) do
            for _, typeName in ipairs(Activator.ActivatableTypes) do
                if instance.ClassName == typeName then
                    table.insert(found, {
                        instance = instance,
                        info = Activator.GetInfo(instance)
                    })
                    break
                end
            end
        end
    end)
    
    return found
end

-- ═══════════════════════════════════════════════════════════════════════
-- 👁️ نظام العرض (Visualizer)
-- ═══════════════════════════════════════════════════════════════════════
local Visualizer = {}
Visualizer.Highlights = {}
Visualizer.Labels = {}

function Visualizer.Highlight(instance, color, duration)
    color = color or Theme.Primary
    duration = duration or 5
    
    pcall(function()
        -- إزالة highlight سابق
        Visualizer.RemoveHighlight(instance)
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "WiliHighlight"
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.Adornee = instance
        highlight.Parent = instance
        
        Visualizer.Highlights[instance] = highlight
        
        -- تأثير نبض
        task.spawn(function()
            local elapsed = 0
            while highlight.Parent and elapsed < duration do
                for i = 0.5, 0.8, 0.05 do
                    if not highlight.Parent then break end
                    highlight.FillTransparency = i
                    task.wait(0.05)
                end
                for i = 0.8, 0.5, -0.05 do
                    if not highlight.Parent then break end
                    highlight.FillTransparency = i
                    task.wait(0.05)
                end
                elapsed = elapsed + 0.6
            end
            
            if highlight.Parent then
                highlight:Destroy()
                Visualizer.Highlights[instance] = nil
            end
        end)
    end)
end

function Visualizer.RemoveHighlight(instance)
    if Visualizer.Highlights[instance] then
        Visualizer.Highlights[instance]:Destroy()
        Visualizer.Highlights[instance] = nil
    end
    
    pcall(function()
        local existing = instance:FindFirstChild("WiliHighlight")
        if existing then existing:Destroy() end
    end)
end

function Visualizer.AddLabel(instance, text, color)
    color = color or Theme.Primary
    
    pcall(function()
        Visualizer.RemoveLabel(instance)
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "WiliLabel"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = instance
        billboard.Parent = instance
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundColor3 = Theme.Darker
        label.BackgroundTransparency = 0.3
        label.TextColor3 = color
        label.Text = text
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
        Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Parent = label
        
        Visualizer.Labels[instance] = billboard
    end)
end

function Visualizer.RemoveLabel(instance)
    if Visualizer.Labels[instance] then
        Visualizer.Labels[instance]:Destroy()
        Visualizer.Labels[instance] = nil
    end
    
    pcall(function()
        local existing = instance:FindFirstChild("WiliLabel")
        if existing then existing:Destroy() end
    end)
end

function Visualizer.ShowBoundingBox(instance, color)
    color = color or Theme.Warning
    
    pcall(function()
        if not instance:IsA("BasePart") then return end
        
        local box = Instance.new("SelectionBox")
        box.Name = "WiliBoundingBox"
        box.Color3 = color
        box.LineThickness = 0.05
        box.SurfaceColor3 = color
        box.SurfaceTransparency = 0.9
        box.Adornee = instance
        box.Parent = instance
        
        task.delay(10, function()
            if box.Parent then box:Destroy() end
        end)
    end)
end

function Visualizer.ClearAll()
    for instance, highlight in pairs(Visualizer.Highlights) do
        pcall(function() highlight:Destroy() end)
    end
    Visualizer.Highlights = {}
    
    for instance, label in pairs(Visualizer.Labels) do
        pcall(function() label:Destroy() end)
    end
    Visualizer.Labels = {}
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔧 لوحة الخصائص المتقدمة
-- ═══════════════════════════════════════════════════════════════════════
local PropertyPanel = {}

function PropertyPanel.GetAllProperties(instance)
    local properties = {}
    
    -- خصائص عامة
    local commonProps = {
        "Name", "ClassName", "Parent", "Archivable"
    }
    
    -- خصائص BasePart
    local partProps = {
        "Position", "Size", "Orientation", "CFrame",
        "Color", "BrickColor", "Material", "Reflectance",
        "Transparency", "CanCollide", "Anchored", "Massless",
        "CastShadow", "CanTouch", "CanQuery"
    }
    
    -- خصائص الإضاءة
    local lightProps = {
        "Brightness", "Color", "Range", "Shadows", "Enabled"
    }
    
    -- خصائص GUI
    local guiProps = {
        "Visible", "Size", "Position", "BackgroundColor3",
        "BackgroundTransparency", "BorderColor3", "ZIndex"
    }
    
    -- خصائص النص
    local textProps = {
        "Text", "TextColor3", "TextSize", "Font",
        "TextTransparency", "TextWrapped", "RichText"
    }
    
    -- جمع الخصائص
    for _, prop in ipairs(commonProps) do
        local ok, val = pcall(function() return instance[prop] end)
        if ok then
            table.insert(properties, {name = prop, value = val, category = "Common"})
        end
    end
    
    pcall(function()
        if instance:IsA("BasePart") then
            for _, prop in ipairs(partProps) do
                local ok, val = pcall(function() return instance[prop] end)
                if ok then
                    table.insert(properties, {name = prop, value = val, category = "Part"})
                end
            end
        end
        
        if instance:IsA("Light") then
            for _, prop in ipairs(lightProps) do
                local ok, val = pcall(function() return instance[prop] end)
                if ok then
                    table.insert(properties, {name = prop, value = val, category = "Light"})
                end
            end
        end
        
        if instance:IsA("GuiObject") then
            for _, prop in ipairs(guiProps) do
                local ok, val = pcall(function() return instance[prop] end)
                if ok then
                    table.insert(properties, {name = prop, value = val, category = "GUI"})
                end
            end
        end
        
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            for _, prop in ipairs(textProps) do
                local ok, val = pcall(function() return instance[prop] end)
                if ok then
                    table.insert(properties, {name = prop, value = val, category = "Text"})
                end
            end
        end
    end)
    
    return properties
end

function PropertyPanel.SetProperty(instance, property, value)
    local result = {success = false, error = ""}
    
    local ok, err = pcall(function()
        instance[property] = value
    end)
    
    if ok then
        result.success = true
    else
        result.error = tostring(err)
    end
    
    return result
end

function PropertyPanel.GetMethods(instance)
    local methods = {}
    
    -- طرق BasePart
    local partMethods = {
        {name = "Destroy", desc = "حذف العنصر", dangerous = true},
        {name = "Clone", desc = "نسخ العنصر", dangerous = false},
        {name = "ClearAllChildren", desc = "حذف كل الأطفال", dangerous = true},
        {name = "GetChildren", desc = "الحصول على الأطفال", dangerous = false},
        {name = "FindFirstChild", desc = "البحث عن طفل", dangerous = false}
    }
    
    pcall(function()
        if instance:IsA("BasePart") then
            table.insert(methods, {name = "BreakJoints", desc = "فك الوصلات", dangerous = false})
            table.insert(methods, {name = "MakeJoints", desc = "إنشاء وصلات", dangerous = false})
        end
        
        if instance:IsA("Humanoid") then
            table.insert(methods, {name = "TakeDamage", desc = "إحداث ضرر", dangerous = false})
            table.insert(methods, {name = "UnequipTools", desc = "إزالة الأدوات", dangerous = false})
        end
    end)
    
    for _, method in ipairs(partMethods) do
        if instance[method.name] then
            table.insert(methods, method)
        end
    end
    
    return methods
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📍 نظام النقل (Teleporter)
-- ═══════════════════════════════════════════════════════════════════════
local Teleporter = {}
Teleporter.SavedLocations = {}

function Teleporter.SaveLocation(name)
    local char = LocalPlayer.Character
    if not char then return false, "No character" end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HumanoidRootPart" end
    
    Teleporter.SavedLocations[name] = hrp.CFrame
    return true, "Saved: " .. name
end

function Teleporter.LoadLocation(name)
    local loc = Teleporter.SavedLocations[name]
    if not loc then return false, "Location not found" end
    
    local char = LocalPlayer.Character
    if not char then return false, "No character" end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "No HumanoidRootPart" end
    
    hrp.CFrame = loc
    return true, "Teleported to: " .. name
end

function Teleporter.ToPosition(x, y, z)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    hrp.CFrame = CFrame.new(x, y, z)
    return true
end

function Teleporter.ToPlayer(playerName)
    local target = Players:FindFirstChild(playerName)
    if not target then return false, "Player not found" end
    
    local targetChar = target.Character
    if not targetChar then return false, "Player has no character" end
    
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return false, "Target has no HRP" end
    
    local char = LocalPlayer.Character
    if not char then return false, "You have no character" end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, "You have no HRP" end
    
    hrp.CFrame = targetHRP.CFrame * CFrame.new(3, 0, 0)
    return true, "Teleported to: " .. playerName
end

function Teleporter.GetAllLocations()
    return Teleporter.SavedLocations
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 مخصص الألوان (Color Picker Helper)
-- ═══════════════════════════════════════════════════════════════════════
local ColorHelper = {}

ColorHelper.Presets = {
    {name = "أحمر", color = Color3.fromRGB(255, 0, 0)},
    {name = "أخضر", color = Color3.fromRGB(0, 255, 0)},
    {name = "أزرق", color = Color3.fromRGB(0, 0, 255)},
    {name = "أصفر", color = Color3.fromRGB(255, 255, 0)},
    {name = "سماوي", color = Color3.fromRGB(0, 255, 255)},
    {name = "وردي", color = Color3.fromRGB(255, 0, 255)},
    {name = "برتقالي", color = Color3.fromRGB(255, 165, 0)},
    {name = "بنفسجي", color = Color3.fromRGB(138, 43, 226)},
    {name = "أبيض", color = Color3.fromRGB(255, 255, 255)},
    {name = "أسود", color = Color3.fromRGB(0, 0, 0)},
    {name = "رمادي", color = Color3.fromRGB(128, 128, 128)},
    {name = "ذهبي", color = Color3.fromRGB(255, 215, 0)},
    {name = "فضي", color = Color3.fromRGB(192, 192, 192)},
    {name = "نيون أزرق", color = Color3.fromRGB(0, 212, 255)},
    {name = "نيون أخضر", color = Color3.fromRGB(0, 255, 136)}
}

function ColorHelper.FromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    return Color3.fromRGB(r, g, b)
end

function ColorHelper.ToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function ColorHelper.Rainbow(speed)
    speed = speed or 1
    local hue = (tick() * speed) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📤 التصدير النهائي
-- ═══════════════════════════════════════════════════════════════════════
AdvancedTools.Theme = Theme
AdvancedTools.Animations = Animations
AdvancedTools.Notifications = Notifications
AdvancedTools.ModelEditor = ModelEditor
AdvancedTools.Activator = Activator
AdvancedTools.Visualizer = Visualizer
AdvancedTools.PropertyPanel = PropertyPanel
AdvancedTools.Teleporter = Teleporter
AdvancedTools.ColorHelper = ColorHelper

-- دالة التهيئة
function AdvancedTools.Init(screenGui)
    Notifications.Init(screenGui)
    return AdvancedTools
end

return AdvancedTools
