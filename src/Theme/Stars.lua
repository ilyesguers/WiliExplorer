local Stars = {}

local TweenService = game:GetService("TweenService")

function Stars.Create(parent, count)
    count = count or 150
    
    local StarContainer = Instance.new("Frame")
    StarContainer.Name = "SpaceContainer"
    StarContainer.Size = UDim2.new(1, 0, 1, 0)
    StarContainer.BackgroundTransparency = 1
    StarContainer.BorderSizePixel = 0
    StarContainer.ZIndex = 0
    StarContainer.ClipsDescendants = true
    StarContainer.Parent = parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = StarContainer
    
    -- ═══════════════════════════════
    -- 💫 السدم الملونة (Nebulas)
    -- ═══════════════════════════════
    for i = 1, 4 do
        local nebula = Instance.new("Frame")
        nebula.Name = "Nebula" .. i
        local size = math.random(80, 180)
        nebula.Size = UDim2.new(0, size, 0, size)
        nebula.Position = UDim2.new(
            math.random(0, 100) / 100, 0,
            math.random(0, 100) / 100, 0
        )
        
        local colors = {
            Color3.fromRGB(100, 50, 200),
            Color3.fromRGB(200, 50, 150),
            Color3.fromRGB(50, 100, 255),
            Color3.fromRGB(0, 150, 200)
        }
        nebula.BackgroundColor3 = colors[math.random(1, #colors)]
        nebula.BackgroundTransparency = 0.85
        nebula.BorderSizePixel = 0
        nebula.ZIndex = 1
        nebula.Parent = StarContainer
        
        local nebCorner = Instance.new("UICorner")
        nebCorner.CornerRadius = UDim.new(1, 0)
        nebCorner.Parent = nebula
        
        -- حركة بطيئة
        spawn(function()
            while nebula.Parent do
                local newPos = UDim2.new(
                    math.random(0, 100) / 100, 0,
                    math.random(0, 100) / 100, 0
                )
                local tween = TweenService:Create(
                    nebula,
                    TweenInfo.new(math.random(20, 40), Enum.EasingStyle.Sine),
                    {Position = newPos}
                )
                tween:Play()
                tween.Completed:Wait()
            end
        end)
    end
    
    -- ═══════════════════════════════
    -- ⭐ النجوم الثابتة (150 نجمة)
    -- ═══════════════════════════════
    for i = 1, count do
        local star = Instance.new("Frame")
        star.Name = "Star" .. i
        
        local size = math.random(1, 4)
        star.Size = UDim2.new(0, size, 0, size)
        
        star.Position = UDim2.new(
            math.random(0, 100) / 100, 0,
            math.random(0, 100) / 100, 0
        )
        
        -- ألوان متنوعة للنجوم
        local starColors = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 212, 255),
            Color3.fromRGB(200, 200, 255),
            Color3.fromRGB(255, 220, 180),
            Color3.fromRGB(180, 220, 255)
        }
        star.BackgroundColor3 = starColors[math.random(1, #starColors)]
        
        star.BorderSizePixel = 0
        star.ZIndex = 2
        star.Parent = StarContainer
        
        local starCorner = Instance.new("UICorner")
        starCorner.CornerRadius = UDim.new(1, 0)
        starCorner.Parent = star
        
        local glow = Instance.new("UIStroke")
        glow.Color = star.BackgroundColor3
        glow.Thickness = 1
        glow.Transparency = 0.3
        glow.Parent = star
        
        -- تلألؤ
        spawn(function()
            wait(math.random() * 3)
            while star.Parent do
                local duration = math.random(10, 30) / 10
                local fade = TweenService:Create(
                    star,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine),
                    {BackgroundTransparency = math.random(20, 80) / 100}
                )
                fade:Play()
                fade.Completed:Wait()
                
                local back = TweenService:Create(
                    star,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine),
                    {BackgroundTransparency = 0}
                )
                back:Play()
                back.Completed:Wait()
            end
        end)
    end
    
    -- ═══════════════════════════════
    -- 🪐 الكواكب الصغيرة
    -- ═══════════════════════════════
    for i = 1, 3 do
        spawn(function()
            while StarContainer.Parent do
                local planet = Instance.new("Frame")
                local size = math.random(8, 16)
                planet.Size = UDim2.new(0, size, 0, size)
                planet.Position = UDim2.new(-0.1, 0, math.random(10, 90) / 100, 0)
                
                local planetColors = {
                    Color3.fromRGB(255, 150, 100),
                    Color3.fromRGB(150, 200, 255),
                    Color3.fromRGB(200, 100, 200),
                    Color3.fromRGB(100, 200, 150),
                    Color3.fromRGB(255, 200, 100)
                }
                planet.BackgroundColor3 = planetColors[math.random(1, #planetColors)]
                planet.BorderSizePixel = 0
                planet.ZIndex = 3
                planet.Parent = StarContainer
                
                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(1, 0)
                pCorner.Parent = planet
                
                local pGlow = Instance.new("UIStroke")
                pGlow.Color = planet.BackgroundColor3
                pGlow.Thickness = 2
                pGlow.Transparency = 0.4
                pGlow.Parent = planet
                
                -- حلقة للكوكب (أحياناً)
                if math.random(1, 3) == 1 then
                    local ring = Instance.new("Frame")
                    ring.Size = UDim2.new(2, 0, 0.3, 0)
                    ring.Position = UDim2.new(-0.5, 0, 0.35, 0)
                    ring.BackgroundColor3 = planet.BackgroundColor3
                    ring.BackgroundTransparency = 0.5
                    ring.BorderSizePixel = 0
                    ring.ZIndex = 3
                    ring.Parent = planet
                    
                    local rCorner = Instance.new("UICorner")
                    rCorner.CornerRadius = UDim.new(1, 0)
                    rCorner.Parent = ring
                end
                
                local moveTween = TweenService:Create(
                    planet,
                    TweenInfo.new(math.random(25, 45), Enum.EasingStyle.Linear),
                    {Position = UDim2.new(1.1, 0, math.random(10, 90) / 100, 0)}
                )
                moveTween:Play()
                moveTween.Completed:Wait()
                planet:Destroy()
                
                wait(math.random(5, 15))
            end
        end)
    end
    
    -- ═══════════════════════════════
    -- 👽 الأجسام الفضائية (UFO)
    -- ═══════════════════════════════
    spawn(function()
        while StarContainer.Parent do
            wait(math.random(15, 30))
            
            local ufo = Instance.new("Frame")
            ufo.Size = UDim2.new(0, 20, 0, 8)
            ufo.Position = UDim2.new(-0.1, 0, math.random(15, 85) / 100, 0)
            ufo.BackgroundColor3 = Color3.fromRGB(150, 150, 180)
            ufo.BorderSizePixel = 0
            ufo.ZIndex = 4
            ufo.Parent = StarContainer
            
            local ufoCorner = Instance.new("UICorner")
            ufoCorner.CornerRadius = UDim.new(1, 0)
            ufoCorner.Parent = ufo
            
            -- قبة UFO
            local dome = Instance.new("Frame")
            dome.Size = UDim2.new(0.5, 0, 1, 0)
            dome.Position = UDim2.new(0.25, 0, -0.5, 0)
            dome.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
            dome.BackgroundTransparency = 0.3
            dome.BorderSizePixel = 0
            dome.ZIndex = 5
            dome.Parent = ufo
            
            local dCorner = Instance.new("UICorner")
            dCorner.CornerRadius = UDim.new(1, 0)
            dCorner.Parent = dome
            
            local dGlow = Instance.new("UIStroke")
            dGlow.Color = Color3.fromRGB(0, 255, 200)
            dGlow.Thickness = 2
            dGlow.Transparency = 0.3
            dGlow.Parent = dome
            
            -- حركة UFO متعرجة
            spawn(function()
                for i = 1, 20 do
                    if not ufo.Parent then break end
                    local newY = math.random(15, 85) / 100
                    local tween = TweenService:Create(
                        ufo,
                        TweenInfo.new(0.5, Enum.EasingStyle.Sine),
                        {Position = UDim2.new(ufo.Position.X.Scale, 0, newY, 0)}
                    )
                    tween:Play()
                    wait(0.5)
                end
            end)
            
            local moveTween = TweenService:Create(
                ufo,
                TweenInfo.new(10, Enum.EasingStyle.Linear),
                {Position = UDim2.new(1.1, 0, ufo.Position.Y.Scale, 0)}
            )
            moveTween:Play()
            moveTween.Completed:Connect(function()
                ufo:Destroy()
            end)
        end
    end)
    
    -- ═══════════════════════════════
    -- ☄️ المذنبات (بذيول طويلة)
    -- ═══════════════════════════════
    spawn(function()
        while StarContainer.Parent do
            wait(math.random(3, 8))
            
            local comet = Instance.new("Frame")
            comet.Size = UDim2.new(0, 4, 0, 4)
            
            local startX = math.random(0, 100) / 100
            comet.Position = UDim2.new(startX, 0, -0.1, 0)
            comet.BackgroundColor3 = Color3.fromRGB(0, 245, 255)
            comet.BorderSizePixel = 0
            comet.ZIndex = 5
            comet.Parent = StarContainer
            
            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(1, 0)
            cCorner.Parent = comet
            
            local cGlow = Instance.new("UIStroke")
            cGlow.Color = Color3.fromRGB(0, 245, 255)
            cGlow.Thickness = 3
            cGlow.Transparency = 0.2
            cGlow.Parent = comet
            
            -- ذيل المذنب
            for j = 1, 8 do
                spawn(function()
                    wait(j * 0.05)
                    if not comet.Parent then return end
                    
                    local tail = Instance.new("Frame")
                    tail.Size = UDim2.new(0, 3 - (j * 0.3), 0, 3 - (j * 0.3))
                    tail.Position = comet.Position
                    tail.BackgroundColor3 = Color3.fromRGB(0, 200 - j*15, 255)
                    tail.BackgroundTransparency = j * 0.12
                    tail.BorderSizePixel = 0
                    tail.ZIndex = 4
                    tail.Parent = StarContainer
                    
                    local tCorner = Instance.new("UICorner")
                    tCorner.CornerRadius = UDim.new(1, 0)
                    tCorner.Parent = tail
                    
                    TweenService:Create(
                        tail,
                        TweenInfo.new(1.5, Enum.EasingStyle.Quad),
                        {BackgroundTransparency = 1}
                    ):Play()
                    
                    game:GetService("Debris"):AddItem(tail, 2)
                end)
            end
            
            local endX = math.random(0, 100) / 100
            local moveTween = TweenService:Create(
                comet,
                TweenInfo.new(math.random(15, 25) / 10, Enum.EasingStyle.Quad),
                {
                    Position = UDim2.new(endX, 0, 1.1, 0),
                    BackgroundTransparency = 1
                }
            )
            moveTween:Play()
            moveTween.Completed:Connect(function()
                comet:Destroy()
            end)
        end
    end)
    
    -- ═══════════════════════════════
    -- 🌠 النجوم المتساقطة السريعة
    -- ═══════════════════════════════
    spawn(function()
        while StarContainer.Parent do
            wait(math.random(10, 25) / 10)
            
            local shootingStar = Instance.new("Frame")
            shootingStar.Size = UDim2.new(0, 2, 0, 2)
            shootingStar.Position = UDim2.new(
                math.random(0, 80) / 100, 0,
                math.random(-10, 30) / 100, 0
            )
            shootingStar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            shootingStar.BorderSizePixel = 0
            shootingStar.ZIndex = 4
            shootingStar.Parent = StarContainer
            
            local sCorner = Instance.new("UICorner")
            sCorner.CornerRadius = UDim.new(1, 0)
            sCorner.Parent = shootingStar
            
            local sGlow = Instance.new("UIStroke")
            sGlow.Color = Color3.fromRGB(255, 255, 255)
            sGlow.Thickness = 4
            sGlow.Transparency = 0.2
            sGlow.Parent = shootingStar
            
            local moveTween = TweenService:Create(
                shootingStar,
                TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(
                        (shootingStar.Position.X.Scale + 0.4), 0,
                        1.1, 0
                    ),
                    BackgroundTransparency = 1
                }
            )
            moveTween:Play()
            
            moveTween.Completed:Connect(function()
                shootingStar:Destroy()
            end)
        end
    end)
    
    print("Space environment created!")
    return StarContainer
end

return Stars
