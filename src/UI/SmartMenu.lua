local SmartMenu = {}

local GameAnalyzer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/GameAnalyzer.lua", true))()

local TweenService = game:GetService("TweenService")

local function ShowNotif(parent, msg, color)
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 300, 0, 50)
    N.Position = UDim2.new(0.5, -150, 0, -60)
    N.BackgroundColor3 = color
    N.ZIndex = 999
    N.Parent = parent
    Instance.new("UICorner", N).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 1, 0)
    L.Text = msg
    L.TextColor3 = Color3.fromRGB(255, 255, 255)
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.BackgroundTransparency = 1
    L.TextWrapped = true
    L.ZIndex = 1000
    L.Parent = N
    TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, 10)}):Play()
    spawn(function()
        wait(2.5)
        TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
        wait(0.3)
        N:Destroy()
    end)
end

function SmartMenu.Open(mainParent)
    local FullScreen = Instance.new("Frame")
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent
    
    -- الشريط العلوي
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 400, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.Text = "🧠 Smart Game Analyzer"
    Title.TextColor3 = Color3.fromRGB(255, 200, 50)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 502
    Title.Parent = TopBar
    
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(0, 400, 0, 20)
    StatusLbl.Position = UDim2.new(0, 15, 0, 33)
    StatusLbl.Text = "🔎 Scanning game..."
    StatusLbl.TextColor3 = Color3.fromRGB(0, 212, 255)
    StatusLbl.TextSize = 13
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.ZIndex = 502
    StatusLbl.Parent = TopBar
    
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 70, 0, 40)
    ExitBtn.Position = UDim2.new(1, -80, 0.5, -20)
    ExitBtn.Text = "✕"
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.TextSize = 20
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    ExitBtn.MouseButton1Click:Connect(function()
        FullScreen:Destroy()
    end)
    
    -- منطقة المحتوى
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -75)
    Scroll.Position = UDim2.new(0, 10, 0, 70)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 8
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 2000)
    Scroll.ZIndex = 501
    Scroll.Parent = FullScreen
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Scroll
    
    local SPad = Instance.new("UIPadding")
    SPad.PaddingTop = UDim.new(0, 5)
    SPad.PaddingLeft = UDim.new(0, 5)
    SPad.PaddingRight = UDim.new(0, 5)
    SPad.Parent = Scroll
    
    -- بدء الفحص
    spawn(function()
        wait(0.5)
        local results = GameAnalyzer.Scan()
        
        StatusLbl.Text = "✅ Scanned " .. results.summary.totalScanned .. " items | " .. results.summary.totalEditable .. " editable | " .. results.summary.totalRemotes .. " remotes"
        
        local orderCounter = 0
        
        -- ═══ دالة إنشاء بطاقة ═══
        local function CreateCard(icon, title, subtitle, color, items, order)
            if #items == 0 then return end
            
            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -10, 0, 50 + (#items * 60))
            Card.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
            Card.LayoutOrder = order
            Card.ZIndex = 502
            Card.Parent = Scroll
            Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
            
            local CStroke = Instance.new("UIStroke")
            CStroke.Color = color
            CStroke.Thickness = 1
            CStroke.Transparency = 0.4
            CStroke.Parent = Card
            
            local CTitle = Instance.new("TextLabel")
            CTitle.Size = UDim2.new(1, -20, 0, 25)
            CTitle.Position = UDim2.new(0, 10, 0, 8)
            CTitle.Text = icon .. " " .. title .. " (" .. #items .. ")"
            CTitle.TextColor3 = color
            CTitle.TextSize = 16
            CTitle.Font = Enum.Font.GothamBold
            CTitle.TextXAlignment = Enum.TextXAlignment.Left
            CTitle.BackgroundTransparency = 1
            CTitle.ZIndex = 503
            CTitle.Parent = Card
            
            local CSub = Instance.new("TextLabel")
            CSub.Size = UDim2.new(1, -20, 0, 18)
            CSub.Position = UDim2.new(0, 10, 0, 30)
            CSub.Text = subtitle
            CSub.TextColor3 = Color3.fromRGB(150, 170, 200)
            CSub.TextSize = 11
            CSub.Font = Enum.Font.Gotham
            CSub.TextXAlignment = Enum.TextXAlignment.Left
            CSub.BackgroundTransparency = 1
            CSub.ZIndex = 503
            CSub.Parent = Card
            
            -- عناصر البطاقة
            for i, item in ipairs(items) do
                if i > 15 then break end -- حد أقصى
                
                local ItemFrame = Instance.new("Frame")
                ItemFrame.Size = UDim2.new(1, -20, 0, 55)
                ItemFrame.Position = UDim2.new(0, 10, 0, 50 + ((i-1) * 60))
                ItemFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 70)
                ItemFrame.ZIndex = 503
                ItemFrame.Parent = Card
                Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 8)
                
                local ItemName = Instance.new("TextLabel")
                ItemName.Size = UDim2.new(0.55, 0, 0, 20)
                ItemName.Position = UDim2.new(0, 10, 0, 5)
                ItemName.Text = item.name or "Unknown"
                ItemName.TextColor3 = Color3.fromRGB(255, 255, 255)
                ItemName.TextSize = 13
                ItemName.Font = Enum.Font.GothamBold
                ItemName.TextXAlignment = Enum.TextXAlignment.Left
                ItemName.TextTruncate = Enum.TextTruncate.AtEnd
                ItemName.BackgroundTransparency = 1
                ItemName.ZIndex = 504
                ItemName.Parent = ItemFrame
                
                local ItemValue = Instance.new("TextLabel")
                ItemValue.Size = UDim2.new(0.55, 0, 0, 15)
                ItemValue.Position = UDim2.new(0, 10, 0, 25)
                ItemValue.TextColor3 = Color3.fromRGB(0, 212, 255)
                ItemValue.TextSize = 11
                ItemValue.Font = Enum.Font.Gotham
                ItemValue.TextXAlignment = Enum.TextXAlignment.Left
                ItemValue.TextTruncate = Enum.TextTruncate.AtEnd
                ItemValue.BackgroundTransparency = 1
                ItemValue.ZIndex = 504
                ItemValue.Parent = ItemFrame
                
                -- عرض القيمة حسب النوع
                if item.value then
                    ItemValue.Text = item.className .. " = " .. tostring(item.value)
                elseif item.walkSpeed then
                    ItemValue.Text = "Speed: " .. item.walkSpeed .. " | Jump: " .. item.jumpPower
                elseif item.isEvent then
                    ItemValue.Text = "RemoteEvent"
                elseif item.isFunction then
                    ItemValue.Text = "RemoteFunction"
                elseif item.sourceLength then
                    ItemValue.Text = item.className .. " | " .. item.sourceLength .. " chars"
                else
                    ItemValue.Text = item.className or ""
                end
                
                -- شارة حالة
                local StatusBadge = Instance.new("TextLabel")
                StatusBadge.Size = UDim2.new(0, 60, 0, 20)
                StatusBadge.Position = UDim2.new(0.55, 5, 0, 5)
                StatusBadge.TextSize = 10
                StatusBadge.Font = Enum.Font.GothamBold
                StatusBadge.TextColor3 = Color3.fromRGB(11, 13, 26)
                StatusBadge.ZIndex = 505
                StatusBadge.Parent = ItemFrame
                Instance.new("UICorner", StatusBadge).CornerRadius = UDim.new(0, 5)
                
                if item.editable == true then
                    StatusBadge.Text = "EDIT"
                    StatusBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
                elseif item.editable == false then
                    StatusBadge.Text = "LOCKED"
                    StatusBadge.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
                elseif item.readable == true then
                    StatusBadge.Text = "READ"
                    StatusBadge.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                elseif item.readable == false then
                    StatusBadge.Text = "HIDDEN"
                    StatusBadge.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                else
                    StatusBadge.Text = "FOUND"
                    StatusBadge.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                end
                
                -- أزرار الأكشن
                if item.instance and (item.editable or item.walkSpeed) then
                    -- زر تعديل
                    local EditBtn = Instance.new("TextButton")
                    EditBtn.Size = UDim2.new(0, 50, 0, 22)
                    EditBtn.Position = UDim2.new(0.55, 5, 0, 28)
                    EditBtn.Text = "✏️ Edit"
                    EditBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    EditBtn.TextSize = 10
                    EditBtn.Font = Enum.Font.GothamBold
                    EditBtn.BackgroundColor3 = Color3.fromRGB(0, 152, 219)
                    EditBtn.ZIndex = 505
                    EditBtn.Parent = ItemFrame
                    Instance.new("UICorner", EditBtn).CornerRadius = UDim.new(0, 5)
                    
                    EditBtn.MouseButton1Click:Connect(function()
                        if item.walkSpeed then
                            -- Humanoid Editor
                            pcall(function()
                                item.instance.WalkSpeed = 100
                                ShowNotif(FullScreen, "✅ WalkSpeed set to 100!", Color3.fromRGB(0, 200, 100))
                            end)
                        elseif item.instance:IsA("ValueBase") then
                            -- فتح Value Editor
                            FullScreen.Visible = false
                            local FileViewer = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/FileViewer.lua", true))()
                            FileViewer.OpenValueEditor(mainParent, item.instance, function()
                                FullScreen.Visible = true
                            end)
                        end
                    end)
                    
                    -- زر Freeze
                    local FrzBtn = Instance.new("TextButton")
                    FrzBtn.Size = UDim2.new(0, 55, 0, 22)
                    FrzBtn.Position = UDim2.new(0.55, 60, 0, 28)
                    FrzBtn.Text = "🧊 Freeze"
                    FrzBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    FrzBtn.TextSize = 9
                    FrzBtn.Font = Enum.Font.GothamBold
                    FrzBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    FrzBtn.ZIndex = 505
                    FrzBtn.Parent = ItemFrame
                    Instance.new("UICorner", FrzBtn).CornerRadius = UDim.new(0, 5)
                    
                    FrzBtn.MouseButton1Click:Connect(function()
                        if not _G.WiliFrozenValues then
                            _G.WiliFrozenValues = {}
                        end
                        
                        if item.walkSpeed then
                            pcall(function()
                                local frozenSpeed = item.instance.WalkSpeed
                                local frozenJump = item.instance.JumpPower
                                
                                game:GetService("RunService").Heartbeat:Connect(function()
                                    pcall(function()
                                        item.instance.WalkSpeed = frozenSpeed
                                        item.instance.JumpPower = frozenJump
                                    end)
                                end)
                                
                                ShowNotif(FullScreen, "🧊 Speed FROZEN at " .. frozenSpeed, Color3.fromRGB(100, 200, 255))
                                FrzBtn.Text = "🧊 ON"
                                FrzBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
                            end)
                        elseif item.instance:IsA("ValueBase") then
                            pcall(function()
                                local frozenVal = item.instance.Value
                                _G.WiliFrozenValues[item.instance] = frozenVal
                                
                                item.instance:GetPropertyChangedSignal("Value"):Connect(function()
                                    pcall(function()
                                        item.instance.Value = frozenVal
                                    end)
                                end)
                                
                                ShowNotif(FullScreen, "🧊 Value FROZEN at " .. tostring(frozenVal), Color3.fromRGB(100, 200, 255))
                                FrzBtn.Text = "🧊 ON"
                                FrzBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
                            end)
                        end
                    end)
                    
                    -- زر Bypass
                    local BypBtn = Instance.new("TextButton")
                    BypBtn.Size = UDim2.new(0, 55, 0, 22)
                    BypBtn.Position = UDim2.new(0.55, 120, 0, 28)
                    BypBtn.Text = "⚡ Max"
                    BypBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    BypBtn.TextSize = 9
                    BypBtn.Font = Enum.Font.GothamBold
                    BypBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 100)
                    BypBtn.ZIndex = 505
                    BypBtn.Parent = ItemFrame
                    Instance.new("UICorner", BypBtn).CornerRadius = UDim.new(0, 5)
                    
                    BypBtn.MouseButton1Click:Connect(function()
                        if item.walkSpeed then
                            pcall(function()
                                item.instance.WalkSpeed = 500
                                item.instance.JumpPower = 200
                                
                                game:GetService("RunService").Heartbeat:Connect(function()
                                    pcall(function()
                                        item.instance.WalkSpeed = 500
                                        item.instance.JumpPower = 200
                                    end)
                                end)
                                
                                ShowNotif(FullScreen, "⚡ MAX SPEED ACTIVATED!", Color3.fromRGB(255, 100, 150))
                                BypBtn.Text = "⚡ ON"
                                BypBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
                            end)
                        elseif item.instance:IsA("NumberValue") or item.instance:IsA("IntValue") then
                            pcall(function()
                                item.instance.Value = 999999
                                
                                game:GetService("RunService").Heartbeat:Connect(function()
                                    pcall(function()
                                        item.instance.Value = 999999
                                    end)
                                end)
                                
                                ShowNotif(FullScreen, "⚡ VALUE MAXED!", Color3.fromRGB(255, 100, 150))
                                BypBtn.Text = "⚡ ON"
                                BypBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
                            end)
                        elseif item.instance:IsA("BoolValue") then
                            pcall(function()
                                item.instance.Value = true
                                game:GetService("RunService").Heartbeat:Connect(function()
                                    pcall(function()
                                        item.instance.Value = true
                                    end)
                                end)
                                ShowNotif(FullScreen, "⚡ FORCED TRUE!", Color3.fromRGB(255, 100, 150))
                            end)
                        end
                    end)
                end
                
                -- زر FireServer للـ Remotes
                if item.instance and (item.isEvent or item.isFunction) then
                    local FireBtn = Instance.new("TextButton")
                    FireBtn.Size = UDim2.new(0, 80, 0, 22)
                    FireBtn.Position = UDim2.new(0.55, 5, 0, 28)
                    FireBtn.Text = "🔥 Fire"
                    FireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    FireBtn.TextSize = 10
                    FireBtn.Font = Enum.Font.GothamBold
                    FireBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
                    FireBtn.ZIndex = 505
                    FireBtn.Parent = ItemFrame
                    Instance.new("UICorner", FireBtn).CornerRadius = UDim.new(0, 5)
                    
                    FireBtn.MouseButton1Click:Connect(function()
                        pcall(function()
                            if item.isEvent then
                                item.instance:FireServer()
                                ShowNotif(FullScreen, "🔥 FireServer() called!", Color3.fromRGB(255, 150, 50))
                            elseif item.isFunction then
                                local result = item.instance:InvokeServer()
                                ShowNotif(FullScreen, "🔥 Result: " .. tostring(result):sub(1, 50), Color3.fromRGB(255, 150, 50))
                            end
                        end)
                    end)
                end
            end
        end
        
        -- ═══ عرض النتائج ═══
        orderCounter = orderCounter + 1
        CreateCard("⏱️", "Cooldowns", "Timers and delays found", Color3.fromRGB(255, 100, 100), results.cooldowns, orderCounter)
        
        orderCounter = orderCounter + 1
        CreateCard("🏃", "Speed Values", "Movement and speed related", Color3.fromRGB(0, 255, 200), results.speeds, orderCounter)
        
        orderCounter = orderCounter + 1
        CreateCard("💰", "Currencies & Stats", "Coins, gems, levels, etc", Color3.fromRGB(255, 200, 50), results.currencies, orderCounter)
        
        orderCounter = orderCounter + 1
        CreateCard("⭐", "Important", "Admin, VIP, bypass related", Color3.fromRGB(255, 100, 255), results.important, orderCounter)
        
        -- فلترة Remotes المهمة فقط
        local importantRemotes = {}
        for _, r in ipairs(results.remotes) do
            if r.interesting then
                table.insert(importantRemotes, r)
            end
        end
        
        orderCounter = orderCounter + 1
        CreateCard("📡", "Key Remotes", "Important remote events", Color3.fromRGB(255, 150, 50), importantRemotes, orderCounter)
        
        -- فلترة Scripts المهمة
        local importantScripts = {}
        for _, s in ipairs(results.scripts) do
            if s.containsCooldown or s.containsSpeed or s.containsCurrency or s.containsRemote then
                table.insert(importantScripts, s)
            end
        end
        
        orderCounter = orderCounter + 1
        CreateCard("📜", "Key Scripts", "Scripts with important code", Color3.fromRGB(0, 255, 136), importantScripts, orderCounter)
        
        -- تحديث حجم الـ Canvas
        wait(0.5)
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
    end)
end

return SmartMenu
