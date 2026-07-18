local Stars = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function Stars.Create(parent, count)
    count = count or 40
    
    -- حاوية النجوم
    local StarContainer = Instance.new("Frame")
    StarContainer.Name = "Stars"
    StarContainer.Size = UDim2.new(1, 0, 1, 0)
    StarContainer.BackgroundTransparency = 1
    StarContainer.BorderSizePixel = 0
    StarContainer.ZIndex = 0
    StarContainer.ClipsDescendants = true
    StarContainer.Parent = parent
    
    -- زوايا مثل الأب
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = StarContainer
    
    -- إنشاء النجوم
    for i = 1, count do
        local star = Instance.new("Frame")
        star.Name = "Star" .. i
        
        -- حجم عشوائي
        local size = math.random(1, 3)
        star.Size = UDim2.new(0, size, 0, size)
        
        -- موقع عشوائي
        star.Position = UDim2.new(
            math.random(0, 100) / 100, 0,
            math.random(0, 100) / 100, 0
        )
        
        -- لون النجم (أبيض أو سماوي)
        if math.random(1, 3) == 1 then
            star.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
        else
            star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        star.BorderSizePixel = 0
        star.ZIndex = 1
        star.Parent = StarContainer
        
        -- دائري
        local starCorner = Instance.new("UICorner")
        starCorner.CornerRadius = UDim.new(1, 0)
        starCorner.Parent = star
        
        -- توهج (Glow)
        local glow = Instance.new("UIStroke")
        glow.Color = star.BackgroundColor3
        glow.Thickness = 1
        glow.Transparency = 0.5
        glow.Parent = star
        
        -- تأثير تلألؤ (Twinkle)
        spawn(function()
            wait(math.random() * 2)
            while star.Parent do
                local duration = math.random(15, 30) / 10
                
                local fadeOut = TweenService:Create(
                    star,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine),
                    {BackgroundTransparency = math.random(30, 80) / 100}
                )
                fadeOut:Play()
                fadeOut.Completed:Wait()
                
                local fadeIn = TweenService:Create(
                    star,
                    TweenInfo.new(duration, Enum.EasingStyle.Sine),
                    {BackgroundTransparency = 0}
                )
                fadeIn:Play()
                fadeIn.Completed:Wait()
            end
        end)
    end
    
    -- نجوم متساقطة (Shooting Stars)
    spawn(function()
        while StarContainer.Parent do
            wait(math.random(5, 12))
            
            local shootingStar = Instance.new("Frame")
            shootingStar.Size = UDim2.new(0, 2, 0, 2)
            shootingStar.Position = UDim2.new(
                math.random(0, 50) / 100, 0,
                -0.1, 0
            )
            shootingStar.BackgroundColor3 = Color3.fromRGB(0, 245, 255)
            shootingStar.BorderSizePixel = 0
            shootingStar.ZIndex = 2
            shootingStar.Parent = StarContainer
            
            local starCorner = Instance.new("UICorner")
            starCorner.CornerRadius = UDim.new(1, 0)
            starCorner.Parent = shootingStar
            
            local glow = Instance.new("UIStroke")
            glow.Color = Color3.fromRGB(0, 245, 255)
            glow.Thickness = 3
            glow.Transparency = 0.3
            glow.Parent = shootingStar
            
            local moveTween = TweenService:Create(
                shootingStar,
                TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {
                    Position = UDim2.new(
                        (math.random(50, 100)) / 100, 0,
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
    
    return StarContainer
end

return Stars
