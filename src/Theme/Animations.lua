--[[
    ═══════════════════════════════════════════════════════════════════════════
    🎬 WiliExplorer - Animation System v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تأثير Fade In/Out
    ✅ تأثير Slide (من كل الاتجاهات)
    ✅ تأثير Bounce
    ✅ تأثير Pulse/Glow
    ✅ تأثير Shake (لاهتزاز)
    ✅ تأثير Particle
    ✅ تأثير Typewriter (كتابة تدريجية)
    ✅ تأثير Scale
    ✅ تأثير Rotate
    ✅ تأثيرات مركبة
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Animations = {}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration, style, direction, repeatCount, reverses)
    if not obj or not obj.Parent then return nil end
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out,
        repeatCount or 0,
        reverses or false
    )
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

local function SafeTween(obj, props, duration, style, direction)
    pcall(function()
        Tween(obj, props, duration, style, direction)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎭 تأثيرات الدخول والخروج
-- ═══════════════════════════════════════════════════════════════════════

-- Fade In
function Animations.FadeIn(obj, duration)
    if not obj then return end
    local originalTransparency = obj.BackgroundTransparency or 0
    obj.BackgroundTransparency = 1
    Tween(obj, {BackgroundTransparency = originalTransparency}, duration or 0.3)
    
    -- للأطفال أيضاً
    for _, child in ipairs(obj:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                local orig = child.TextTransparency
                child.TextTransparency = 1
                Tween(child, {TextTransparency = orig}, duration or 0.3)
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                local orig = child.ImageTransparency
                child.ImageTransparency = 1
                Tween(child, {ImageTransparency = orig}, duration or 0.3)
            end
        end)
    end
end

-- Fade Out
function Animations.FadeOut(obj, duration, destroyAfter)
    if not obj then return end
    Tween(obj, {BackgroundTransparency = 1}, duration or 0.3)
    
    for _, child in ipairs(obj:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                Tween(child, {TextTransparency = 1}, duration or 0.3)
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                Tween(child, {ImageTransparency = 1}, duration or 0.3)
            end
        end)
    end
    
    if destroyAfter then
        task.delay(duration or 0.3, function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📐 تأثيرات Slide
-- ═══════════════════════════════════════════════════════════════════════

-- Slide In من اليسار
function Animations.SlideInLeft(obj, duration)
    if not obj then return end
    local originalPos = obj.Position
    obj.Position = UDim2.new(-1, 0, originalPos.Y.Scale, originalPos.Y.Offset)
    Tween(obj, {Position = originalPos}, duration or 0.4, Enum.EasingStyle.Back)
end

-- Slide In من اليمين
function Animations.SlideInRight(obj, duration)
    if not obj then return end
    local originalPos = obj.Position
    obj.Position = UDim2.new(1, 0, originalPos.Y.Scale, originalPos.Y.Offset)
    Tween(obj, {Position = originalPos}, duration or 0.4, Enum.EasingStyle.Back)
end

-- Slide In من الأعلى
function Animations.SlideInTop(obj, duration)
    if not obj then return end
    local originalPos = obj.Position
    obj.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, -1, 0)
    Tween(obj, {Position = originalPos}, duration or 0.4, Enum.EasingStyle.Back)
end

-- Slide In من الأسفل
function Animations.SlideInBottom(obj, duration)
    if not obj then return end
    local originalPos = obj.Position
    obj.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, 1, 0)
    Tween(obj, {Position = originalPos}, duration or 0.4, Enum.EasingStyle.Back)
end

-- Slide Out
function Animations.SlideOut(obj, direction, duration, destroyAfter)
    if not obj then return end
    local targetPos
    
    if direction == "left" then
        targetPos = UDim2.new(-1, 0, obj.Position.Y.Scale, obj.Position.Y.Offset)
    elseif direction == "right" then
        targetPos = UDim2.new(1, 0, obj.Position.Y.Scale, obj.Position.Y.Offset)
    elseif direction == "top" then
        targetPos = UDim2.new(obj.Position.X.Scale, obj.Position.X.Offset, -1, 0)
    elseif direction == "bottom" then
        targetPos = UDim2.new(obj.Position.X.Scale, obj.Position.X.Offset, 1, 0)
    end
    
    Tween(obj, {Position = targetPos}, duration or 0.3, Enum.EasingStyle.Back)
    
    if destroyAfter then
        task.delay(duration or 0.3, function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎾 تأثير Bounce
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Bounce(obj, intensity, duration)
    if not obj then return end
    intensity = intensity or 1.2
    
    local originalSize = obj.Size
    local bigSize = UDim2.new(
        originalSize.X.Scale * intensity,
        originalSize.X.Offset * intensity,
        originalSize.Y.Scale * intensity,
        originalSize.Y.Offset * intensity
    )
    
    Tween(obj, {Size = bigSize}, (duration or 0.3) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    task.delay((duration or 0.3) / 2, function()
        if obj and obj.Parent then
            Tween(obj, {Size = originalSize}, (duration or 0.3) / 2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 💫 تأثير Pulse/Glow
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Pulse(obj, color, duration, count)
    if not obj then return end
    
    local originalColor = obj.BackgroundColor3
    local pulseColor = color or Color3.fromRGB(255, 255, 255)
    local pulseCount = count or 3
    
    task.spawn(function()
        for i = 1, pulseCount do
            if not obj or not obj.Parent then break end
            Tween(obj, {BackgroundColor3 = pulseColor}, (duration or 0.5) / 2)
            task.wait((duration or 0.5) / 2)
            if not obj or not obj.Parent then break end
            Tween(obj, {BackgroundColor3 = originalColor}, (duration or 0.5) / 2)
            task.wait((duration or 0.5) / 2)
        end
    end)
end

-- Glow مستمر
function Animations.StartGlow(obj, color, minTransparency, maxTransparency, duration)
    if not obj then return nil end
    
    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "GlowEffect"
    glowFrame.Size = UDim2.new(1, 20, 1, 20)
    glowFrame.Position = UDim2.new(0, -10, 0, -10)
    glowFrame.BackgroundColor3 = color or Color3.fromRGB(0, 212, 255)
    glowFrame.BackgroundTransparency = maxTransparency or 0.7
    glowFrame.ZIndex = obj.ZIndex - 1
    glowFrame.Parent = obj
    
    Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 15)
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then
            connection:Disconnect()
            if glowFrame and glowFrame.Parent then glowFrame:Destroy() end
            return
        end
        
        local t = tick() % (duration or 2) / (duration or 2)
        local transparency = minTransparency + (maxTransparency - minTransparency) * (math.sin(t * math.pi * 2) + 1) / 2
        glowFrame.BackgroundTransparency = transparency
    end)
    
    return {
        frame = glowFrame,
        stop = function()
            connection:Disconnect()
            if glowFrame and glowFrame.Parent then
                Tween(glowFrame, {BackgroundTransparency = 1}, 0.3)
                task.delay(0.3, function()
                    if glowFrame and glowFrame.Parent then glowFrame:Destroy() end
                end)
            end
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📳 تأثير Shake
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Shake(obj, intensity, duration)
    if not obj then return end
    intensity = intensity or 5
    duration = duration or 0.3
    
    local originalPos = obj.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then
            connection:Disconnect()
            return
        end
        
        local elapsed = tick() - startTime
        if elapsed > duration then
            connection:Disconnect()
            obj.Position = originalPos
            return
        end
        
        local progress = elapsed / duration
        local currentIntensity = intensity * (1 - progress)
        
        local offsetX = math.random(-currentIntensity, currentIntensity)
        local offsetY = math.random(-currentIntensity, currentIntensity)
        
        obj.Position = UDim2.new(
            originalPos.X.Scale,
            originalPos.X.Offset + offsetX,
            originalPos.Y.Scale,
            originalPos.Y.Offset + offsetY
        )
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ⏫ تأثير Scale
-- ═══════════════════════════════════════════════════════════════════════

-- Scale In (من صغير لكبير)
function Animations.ScaleIn(obj, duration)
    if not obj then return end
    local originalSize = obj.Size
    obj.Size = UDim2.new(0, 0, 0, 0)
    Tween(obj, {Size = originalSize}, duration or 0.3, Enum.EasingStyle.Back)
end

-- Scale Out (من كبير لصغير)
function Animations.ScaleOut(obj, duration, destroyAfter)
    if not obj then return end
    Tween(obj, {Size = UDim2.new(0, 0, 0, 0)}, duration or 0.3, Enum.EasingStyle.Back)
    
    if destroyAfter then
        task.delay(duration or 0.3, function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 تأثير Rotate
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Rotate(obj, degrees, duration)
    if not obj then return end
    Tween(obj, {Rotation = degrees}, duration or 0.5, Enum.EasingStyle.Quad)
end

-- دوران مستمر
function Animations.StartSpin(obj, speed, direction)
    if not obj then return nil end
    
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        if not obj or not obj.Parent then
            connection:Disconnect()
            return
        end
        
        obj.Rotation = obj.Rotation + (speed or 360) * dt * (direction or 1)
    end)
    
    return {
        stop = function()
            connection:Disconnect()
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- ⌨️ تأثير Typewriter (كتابة تدريجية)
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Typewriter(label, text, speed, callback)
    if not label then return end
    speed = speed or 0.05
    
    label.Text = ""
    
    task.spawn(function()
        for i = 1, #text do
            if not label or not label.Parent then break end
            label.Text = string.sub(text, 1, i)
            task.wait(speed)
        end
        
        if callback then callback() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ✨ تأثير Particle (جزيئات)
-- ═══════════════════════════════════════════════════════════════════════
function Animations.CreateParticles(parent, count, color, duration)
    if not parent then return end
    count = count or 20
    duration = duration or 1
    
    for i = 1, count do
        task.spawn(function()
            local particle = Instance.new("Frame")
            particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
            particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
            particle.BackgroundColor3 = color or Color3.fromRGB(255, 215, 0)
            particle.BackgroundTransparency = 0
            particle.BorderSizePixel = 0
            particle.ZIndex = parent.ZIndex + 10
            particle.Parent = parent
            
            Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
            
            local targetX = particle.Position.X.Scale + (math.random() - 0.5) * 0.5
            local targetY = particle.Position.Y.Scale - math.random() * 0.5
            
            Tween(particle, {
                Position = UDim2.new(targetX, 0, targetY, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 1, 0, 1)
            }, duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            task.delay(duration, function()
                if particle and particle.Parent then particle:Destroy() end
            end)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🌊 تأثير Wave
-- ═══════════════════════════════════════════════════════════════════════
function Animations.Wave(obj, amplitude, frequency, duration)
    if not obj then return end
    amplitude = amplitude or 10
    frequency = frequency or 2
    duration = duration or 2
    
    local originalPos = obj.Position
    local startTime = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then
            connection:Disconnect()
            return
        end
        
        local elapsed = tick() - startTime
        if elapsed > duration then
            connection:Disconnect()
            obj.Position = originalPos
            return
        end
        
        local offset = math.sin(elapsed * frequency * math.pi * 2) * amplitude
        obj.Position = UDim2.new(
            originalPos.X.Scale,
            originalPos.X.Offset,
            originalPos.Y.Scale,
            originalPos.Y.Offset + offset
        )
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎭 تأثيرات مركبة
-- ═══════════════════════════════════════════════════════════════════════

-- دخول مع Bounce
function Animations.EntranceBounce(obj, duration)
    if not obj then return end
    local originalSize = obj.Size
    obj.Size = UDim2.new(0, 0, 0, 0)
    obj.BackgroundTransparency = 1
    
    Tween(obj, {
        Size = originalSize,
        BackgroundTransparency = 0
    }, duration or 0.5, Enum.EasingStyle.Back)
end

-- خروج مع Fade و Scale
function Animations.ExitFadeScale(obj, duration, destroyAfter)
    if not obj then return end
    
    Tween(obj, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }, duration or 0.3, Enum.EasingStyle.Back)
    
    if destroyAfter then
        task.delay(duration or 0.3, function()
            if obj and obj.Parent then obj:Destroy() end
        end)
    end
end

-- تأثير Hover للزر
function Animations.ButtonHover(obj, hoverColor, normalColor)
    if not obj then return end
    
    obj.MouseEnter:Connect(function()
        Tween(obj, {BackgroundColor3 = hoverColor or Color3.fromRGB(30, 35, 60)}, 0.15)
    end)
    
    obj.MouseLeave:Connect(function()
        Tween(obj, {BackgroundColor3 = normalColor or Color3.fromRGB(20, 25, 50)}, 0.15)
    end)
end

-- تأثير Click للزر
function Animations.ButtonClick(obj, callback)
    if not obj then return end
    
    obj.MouseButton1Click:Connect(function()
        Animations.Bounce(obj, 0.9, 0.2)
        if callback then callback() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 تأثير Progress Bar
-- ═══════════════════════════════════════════════════════════════════════
function Animations.ProgressBar(fillFrame, targetPercent, duration)
    if not fillFrame then return end
    Tween(fillFrame, {Size = UDim2.new(targetPercent, 0, 1, 0)}, duration or 1, Enum.EasingStyle.Quad)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🌟 تأثير Star Burst
-- ═══════════════════════════════════════════════════════════════════════
function Animations.StarBurst(parent, position, color, count)
    if not parent then return end
    count = count or 8
    
    for i = 1, count do
        task.spawn(function()
            local angle = (i / count) * math.pi * 2
            local distance = math.random(50, 100)
            
            local star = Instance.new("Frame")
            star.Size = UDim2.new(0, 6, 0, 6)
            star.Position = position or UDim2.new(0.5, 0, 0.5, 0)
            star.BackgroundColor3 = color or Color3.fromRGB(255, 215, 0)
            star.BorderSizePixel = 0
            star.ZIndex = parent.ZIndex + 10
            star.Parent = parent
            Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)
            
            local targetX = star.Position.X.Scale + math.cos(angle) * (distance / parent.AbsoluteSize.X)
            local targetY = star.Position.Y.Scale + math.sin(angle) * (distance / parent.AbsoluteSize.Y)
            
            Tween(star, {
                Position = UDim2.new(targetX, 0, targetY, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 2)
            }, 0.6, Enum.EasingStyle.Quad)
            
            task.delay(0.6, function()
                if star and star.Parent then star:Destroy() end
            end)
        end)
    end
end

print("🎬 Animation System v1.0 Loaded!")

return Animations
