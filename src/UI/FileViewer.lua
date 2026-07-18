local FileViewer = {}

local FileScanner = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Core/FileScanner.lua", true))()

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function CopyToClipboard(text)
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        elseif toclipboard then
            toclipboard(text)
            success = true
        end
    end)
    return success
end

local function PasteFromClipboard()
    local text = ""
    pcall(function()
        if getclipboard then
            text = getclipboard()
        end
    end)
    return text
end

local function ShowNotification(parent, message, color)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 50)
    Notif.Position = UDim2.new(0.5, -150, 0, -60)
    Notif.BackgroundColor3 = color or Color3.fromRGB(0, 200, 100)
    Notif.ZIndex = 999
    Notif.Parent = parent
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.Text = message
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.BackgroundTransparency = 1
    Label.TextWrapped = true
    Label.ZIndex = 1000
    Label.Parent = Notif
    
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -150, 0, 10)
    }):Play()
    
    spawn(function()
        wait(2.5)
        TweenService:Create(Notif, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -150, 0, -60)
        }):Play()
        wait(0.3)
        Notif:Destroy()
    end)
end

function FileViewer.OpenCodeEditor(mainParent, instance, sourceData, onExit)
    local FullScreen = Instance.new("Frame")
    FullScreen.Name = "CodeEditorFullscreen"
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.Position = UDim2.new(0, 0, 0, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    FullScreen.BorderSizePixel = 0
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent
    
    -- الشريط العلوي
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 25, 50)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 45, 0, 45)
    Icon.Position = UDim2.new(0, 10, 0.5, -22)
    Icon.Text = "📜"
    Icon.TextSize = 28
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 502
    Icon.Parent = TopBar
    
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Size = UDim2.new(0, 200, 0, 22)
    ScriptName.Position = UDim2.new(0, 60, 0, 8)
    ScriptName.Text = instance.Name
    ScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptName.TextSize = 16
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.TextXAlignment = Enum.TextXAlignment.Left
    ScriptName.TextTruncate = Enum.TextTruncate.AtEnd
    ScriptName.BackgroundTransparency = 1
    ScriptName.ZIndex = 502
    ScriptName.Parent = TopBar
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(0, 300, 0, 18)
    InfoLabel.Position = UDim2.new(0, 60, 0, 30)
    InfoLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.ZIndex = 502
    InfoLabel.Parent = TopBar
    
    local function CountLines(text)
        local count = 1
        for _ in text:gmatch("\n") do count = count + 1 end
        return count
    end
    
    local totalLines = CountLines(sourceData.source)
    local methodText = sourceData.method or "unknown"
    
    -- تحديد نوع السكريبت
    local scriptType = "Unknown"
    local canModify = false
    
    pcall(function()
        if instance:IsA("LocalScript") then
            scriptType = "LocalScript ✅ (Editable)"
            canModify = true
        elseif instance:IsA("ModuleScript") then
            scriptType = "ModuleScript ⚠️ (Client-side only)"
            canModify = true
        elseif instance:IsA("Script") then
            scriptType = "Server Script ❌ (Read-only)"
            canModify = false
        end
    end)
    
    InfoLabel.Text = scriptType .. " • " .. totalLines .. " lines"
    
    -- أزرار العلوية
    local PasteBtn = Instance.new("TextButton")
    PasteBtn.Size = UDim2.new(0, 75, 0, 38)
    PasteBtn.Position = UDim2.new(1, -400, 0.5, -19)
    PasteBtn.Text = "📥 Paste"
    PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasteBtn.TextSize = 12
    PasteBtn.Font = Enum.Font.GothamBold
    PasteBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 200)
    PasteBtn.ZIndex = 502
    PasteBtn.Parent = TopBar
    Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0, 8)
    
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 75, 0, 38)
    CopyBtn.Position = UDim2.new(1, -320, 0.5, -19)
    CopyBtn.Text = "📋 Copy"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextSize = 12
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 152, 219)
    CopyBtn.ZIndex = 502
    CopyBtn.Parent = TopBar
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 8)
    
    local RunBtn = Instance.new("TextButton")
    RunBtn.Size = UDim2.new(0, 75, 0, 38)
    RunBtn.Position = UDim2.new(1, -240, 0.5, -19)
    RunBtn.Text = "▶️ Run"
    RunBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    RunBtn.TextSize = 13
    RunBtn.Font = Enum.Font.GothamBold
    RunBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    RunBtn.ZIndex = 502
    RunBtn.Parent = TopBar
    Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 8)
    
    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0, 85, 0, 38)
    SaveBtn.Position = UDim2.new(1, -155, 0.5, -19)
    SaveBtn.Text = "💾 Save"
    SaveBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
    SaveBtn.TextSize = 14
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
    SaveBtn.ZIndex = 502
    SaveBtn.Parent = TopBar
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
    
    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 65, 0, 38)
    ExitBtn.Position = UDim2.new(1, -75, 0.5, -19)
    ExitBtn.Text = "✕"
    ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExitBtn.TextSize = 18
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
    
    -- تحذير للسكريبتات السيرفر
    if not canModify then
        local WarnBar = Instance.new("Frame")
        WarnBar.Size = UDim2.new(1, 0, 0, 35)
        WarnBar.Position = UDim2.new(0, 0, 0, 55)
        WarnBar.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
        WarnBar.ZIndex = 501
        WarnBar.Parent = FullScreen
        
        local WarnLabel = Instance.new("TextLabel")
        WarnLabel.Size = UDim2.new(1, -20, 1, 0)
        WarnLabel.Position = UDim2.new(0, 10, 0, 0)
        WarnLabel.Text = "⚠️ Server Script - Cannot save to game. Use 'Run' to execute as LocalScript"
        WarnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        WarnLabel.TextSize = 13
        WarnLabel.Font = Enum.Font.GothamBold
        WarnLabel.TextXAlignment = Enum.TextXAlignment.Left
        WarnLabel.BackgroundTransparency = 1
        WarnLabel.ZIndex = 502
        WarnLabel.Parent = WarnBar
    end
    
    -- منطقة الكود
    local codeTopOffset = canModify and 55 or 90
    
    local CodeScroll = Instance.new("ScrollingFrame")
    CodeScroll.Size = UDim2.new(1, 0, 1, -codeTopOffset)
    CodeScroll.Position = UDim2.new(0, 0, 0, codeTopOffset)
    CodeScroll.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    CodeScroll.BorderSizePixel = 0
    CodeScroll.ScrollBarThickness = 10
    CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    CodeScroll.ScrollingDirection = Enum.ScrollingDirection.XY
    CodeScroll.CanvasSize = UDim2.new(0, 2000, 0, 3000)
    CodeScroll.ZIndex = 501
    CodeScroll.Parent = FullScreen
    
    local CodeBox = Instance.new("TextBox")
    CodeBox.Size = UDim2.new(0, 2000, 0, 3000)
    CodeBox.Position = UDim2.new(0, 15, 0, 15)
    CodeBox.BackgroundColor3 = Color3.fromRGB(15, 18, 35)
    CodeBox.TextColor3 = Color3.fromRGB(220, 230, 255)
    CodeBox.Font = Enum.Font.Code
    CodeBox.TextSize = 15
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.TextWrapped = false
    CodeBox.ClearTextOnFocus = false
    CodeBox.MultiLine = true
    CodeBox.Text = sourceData.source or ""
    CodeBox.TextEditable = true
    CodeBox.ZIndex = 502
    CodeBox.Parent = CodeScroll
    
    if not sourceData.success then
        CodeBox.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
    
    -- تحديث الحجم بشكل آمن
    local function UpdateSize()
        local text = CodeBox.Text
        local lines = CountLines(text)
        local longestLine = 0
        
        for line in text:gmatch("[^\n]+") do
            if #line > longestLine then
                longestLine = #line
            end
        end
        
        local width = math.max(2000, longestLine * 10)
        local height = math.max(3000, lines * 20 + 200)
        
        CodeBox.Size = UDim2.new(0, width, 0, height)
        CodeScroll.CanvasSize = UDim2.new(0, width + 30, 0, height + 30)
        
        InfoLabel.Text = scriptType .. " • " .. lines .. " lines"
    end
    
    -- تتبع التعديلات
    local isModified = false
    local originalText = sourceData.source or ""
    
    CodeBox:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSize()
        
        if CodeBox.Text ~= originalText then
            isModified = true
            SaveBtn.Text = "💾 Save*"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        else
            isModified = false
            SaveBtn.Text = "💾 Save"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
        end
    end)
    
    UpdateSize()
    
    -- زر النسخ
    CopyBtn.MouseButton1Click:Connect(function()
        if CopyToClipboard(CodeBox.Text) then
            ShowNotification(FullScreen, "✅ Code copied to clipboard!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "❌ Copy failed", Color3.fromRGB(200, 50, 70))
        end
    end)
    
    -- زر اللصق
    PasteBtn.MouseButton1Click:Connect(function()
        local pastedText = PasteFromClipboard()
        if pastedText and pastedText ~= "" then
            CodeBox.Text = CodeBox.Text .. "\n" .. pastedText
            ShowNotification(FullScreen, "✅ Pasted from clipboard!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "⚠️ Clipboard is empty", Color3.fromRGB(255, 200, 50))
        end
    end)
    
    -- زر تشغيل الكود (Execute)
    RunBtn.MouseButton1Click:Connect(function()
        local code = CodeBox.Text
        local success, err = pcall(function()
            local func = loadstring(code)
            if func then
                func()
            end
        end)
        
        if success then
            ShowNotification(FullScreen, "✅ Code executed successfully!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(FullScreen, "❌ Error: " .. tostring(err):sub(1, 100), Color3.fromRGB(200, 50, 70))
        end
    end)
    
    -- زر الحفظ
    SaveBtn.MouseButton1Click:Connect(function()
        if not canModify then
            ShowNotification(FullScreen, "⚠️ Cannot save Server Scripts. Use Run to execute", Color3.fromRGB(255, 200, 50))
            return
        end
        
        local saveResult = FileScanner.SetSource(instance, CodeBox.Text)
        if saveResult.success then
            ShowNotification(FullScreen, "✅ Saved! Method: " .. saveResult.method, Color3.fromRGB(0, 200, 100))
            originalText = CodeBox.Text
            isModified = false
            SaveBtn.Text = "💾 Saved"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            
            -- محاولة إعادة تشغيل السكريبت
            if instance:IsA("LocalScript") then
                pcall(function()
                    instance.Disabled = true
                    wait(0.1)
                    instance.Disabled = false
                end)
                ShowNotification(FullScreen, "🔄 Script reloaded!", Color3.fromRGB(100, 200, 255))
            end
            
            wait(2)
            SaveBtn.Text = "💾 Save"
        else
            ShowNotification(FullScreen, "❌ Save failed: " .. saveResult.error, Color3.fromRGB(200, 50, 70))
        end
    end)
    
    -- زر الخروج
    ExitBtn.MouseButton1Click:Connect(function()
        if isModified then
            local Confirm = Instance.new("Frame")
            Confirm.Size = UDim2.new(1, 0, 1, 0)
            Confirm.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Confirm.BackgroundTransparency = 0.5
            Confirm.ZIndex = 600
            Confirm.Parent = FullScreen
            
            local Dialog = Instance.new("Frame")
            Dialog.Size = UDim2.new(0, 380, 0, 180)
            Dialog.Position = UDim2.new(0.5, -190, 0.5, -90)
            Dialog.BackgroundColor3 = Color3.fromRGB(25, 30, 60)
            Dialog.ZIndex = 601
            Dialog.Parent = Confirm
            Instance.new("UICorner", Dialog).CornerRadius = UDim.new(0, 15)
            
            local DStroke = Instance.new("UIStroke")
            DStroke.Color = Color3.fromRGB(255, 200, 50)
            DStroke.Thickness = 2
            DStroke.Parent = Dialog
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 30)
            Title.Position = UDim2.new(0, 10, 0, 15)
            Title.Text = "⚠️ Unsaved Changes"
            Title.TextColor3 = Color3.fromRGB(255, 200, 50)
            Title.TextSize = 18
            Title.Font = Enum.Font.GothamBold
            Title.BackgroundTransparency = 1
            Title.ZIndex = 602
            Title.Parent = Dialog
            
            local Msg = Instance.new("TextLabel")
            Msg.Size = UDim2.new(1, -20, 0, 40)
            Msg.Position = UDim2.new(0, 10, 0, 50)
            Msg.Text = "You have unsaved changes. What do you want to do?"
            Msg.TextColor3 = Color3.fromRGB(255, 255, 255)
            Msg.TextSize = 13
            Msg.Font = Enum.Font.Gotham
            Msg.TextWrapped = true
            Msg.BackgroundTransparency = 1
            Msg.ZIndex = 602
            Msg.Parent = Dialog
            
            local SaveExit = Instance.new("TextButton")
            SaveExit.Size = UDim2.new(0, 110, 0, 40)
            SaveExit.Position = UDim2.new(0, 15, 1, -55)
            SaveExit.Text = "💾 Save & Exit"
            SaveExit.TextColor3 = Color3.fromRGB(11, 13, 26)
            SaveExit.TextSize = 12
            SaveExit.Font = Enum.Font.GothamBold
            SaveExit.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
            SaveExit.ZIndex = 602
            SaveExit.Parent = Dialog
            Instance.new("UICorner", SaveExit).CornerRadius = UDim.new(0, 8)
            
            local Discard = Instance.new("TextButton")
            Discard.Size = UDim2.new(0, 110, 0, 40)
            Discard.Position = UDim2.new(0, 135, 1, -55)
            Discard.Text = "🗑️ Discard"
            Discard.TextColor3 = Color3.fromRGB(255, 255, 255)
            Discard.TextSize = 12
            Discard.Font = Enum.Font.GothamBold
            Discard.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
            Discard.ZIndex = 602
            Discard.Parent = Dialog
            Instance.new("UICorner", Discard).CornerRadius = UDim.new(0, 8)
            
            local Cancel = Instance.new("TextButton")
            Cancel.Size = UDim2.new(0, 100, 0, 40)
            Cancel.Position = UDim2.new(1, -115, 1, -55)
            Cancel.Text = "Cancel"
            Cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
            Cancel.TextSize = 12
            Cancel.Font = Enum.Font.GothamBold
            Cancel.BackgroundColor3 = Color3.fromRGB(80, 90, 130)
            Cancel.ZIndex = 602
            Cancel.Parent = Dialog
            Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 8)
            
            SaveExit.MouseButton1Click:Connect(function()
                if canModify then
                    local r = FileScanner.SetSource(instance, CodeBox.Text)
                    if r.success then
                        FullScreen:Destroy()
                        if onExit then onExit() end
                    else
                        Confirm:Destroy()
                    end
                else
                    FullScreen:Destroy()
                    if onExit then onExit() end
                end
            end)
            
            Discard.MouseButton1Click:Connect(function()
                FullScreen:Destroy()
                if onExit then onExit() end
            end)
            
            Cancel.MouseButton1Click:Connect(function()
                Confirm:Destroy()
            end)
        else
            FullScreen:Destroy()
            if onExit then onExit() end
        end
    end)
end

function FileViewer.Open(mainParent, instance, onClose)
    local info = FileScanner.GetInfo(instance)
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "FileViewerOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.4
    Overlay.ZIndex = 90
    Overlay.Parent = mainParent

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0.96, 0, 0.92, 0)
    Window.Position = UDim2.new(0.02, 0, 0.04, 0)
    Window.BackgroundColor3 = Color3.fromRGB(11, 13, 26)
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.ZIndex = 91
    Window.Parent = Overlay
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 15)

    local WStroke = Instance.new("UIStroke")
    WStroke.Color = Color3.fromRGB(0, 212, 255)
    WStroke.Thickness = 2
    WStroke.Parent = Window

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 70)
    Header.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    Header.ZIndex = 92
    Header.Parent = Window

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 55, 0, 55)
    IconLabel.Position = UDim2.new(0, 10, 0.5, -27)
    IconLabel.Text = info.Icon
    IconLabel.TextSize = 36
    IconLabel.BackgroundTransparency = 1
    IconLabel.ZIndex = 93
    IconLabel.Parent = Header

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -140, 0, 25)
    NameLabel.Position = UDim2.new(0, 70, 0, 12)
    NameLabel.Text = info.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 20
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.BackgroundTransparency = 1
    NameLabel.ZIndex = 93
    NameLabel.Parent = Header

    local ClassLabel = Instance.new("TextLabel")
    ClassLabel.Size = UDim2.new(1, -140, 0, 18)
    ClassLabel.Position = UDim2.new(0, 70, 0, 40)
    ClassLabel.Text = info.ClassName .. " • " .. info.Descendants .. " items"
    ClassLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
    ClassLabel.TextSize = 13
    ClassLabel.Font = Enum.Font.Gotham
    ClassLabel.TextXAlignment = Enum.TextXAlignment.Left
    ClassLabel.BackgroundTransparency = 1
    ClassLabel.ZIndex = 93
    ClassLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 45, 0, 45)
    CloseBtn.Position = UDim2.new(1, -55, 0.5, -22)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    CloseBtn.ZIndex = 93
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

    CloseBtn.MouseButton1Click:Connect(function()
        Overlay:Destroy()
        if onClose then onClose() end
    end)

    local hasBigButton = false
    local buttonColor = Color3.fromRGB(0, 255, 136)
    local buttonText = ""
    local buttonAction = nil

    if info.IsScript then
        hasBigButton = true
        buttonColor = Color3.fromRGB(0, 255, 136)
        buttonText = "📜  VIEW & EDIT CODE"
        buttonAction = function(overlay)
            local sourceData = FileScanner.GetSource(instance)
            overlay.Visible = false
            FileViewer.OpenCodeEditor(mainParent, instance, sourceData, function()
                overlay.Visible = true
            end)
        end
    elseif instance:IsA("Sound") then
        hasBigButton = true
        buttonColor = Color3.fromRGB(255, 200, 50)
        buttonText = "🔊  SOUND EDITOR"
        buttonAction = function(overlay)
            overlay.Visible = false
            local SoundEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/SoundEditor.lua", true))()
            SoundEditor.Open(mainParent, instance, function()
                overlay.Visible = true
            end)
        end
    elseif instance:IsA("Decal") or instance:IsA("Texture") or instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        hasBigButton = true
        buttonColor = Color3.fromRGB(255, 100, 150)
        buttonText = "🖼️  IMAGE EDITOR"
        buttonAction = function(overlay)
            overlay.Visible = false
            local ImageEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/UI/ImageEditor.lua", true))()
            ImageEditor.Open(mainParent, instance, function()
                overlay.Visible = true
            end)
        end
    end

    if hasBigButton then
        local BigBtn = Instance.new("TextButton")
        BigBtn.Size = UDim2.new(1, -30, 0, 85)
        BigBtn.Position = UDim2.new(0, 15, 0, 85)
        BigBtn.Text = buttonText
        BigBtn.TextColor3 = Color3.fromRGB(11, 13, 26)
        BigBtn.TextSize = 24
        BigBtn.Font = Enum.Font.GothamBold
        BigBtn.BackgroundColor3 = buttonColor
        BigBtn.AutoButtonColor = false
        BigBtn.ZIndex = 200
        BigBtn.Parent = Window
        Instance.new("UICorner", BigBtn).CornerRadius = UDim.new(0, 15)

        local BStroke = Instance.new("UIStroke")
        BStroke.Color = buttonColor
        BStroke.Thickness = 3
        BStroke.Parent = BigBtn

        spawn(function()
            while BigBtn.Parent do
                TweenService:Create(BStroke, TweenInfo.new(1), {Thickness = 5, Transparency = 0.4}):Play()
                wait(1)
                TweenService:Create(BStroke, TweenInfo.new(1), {Thickness = 3, Transparency = 0}):Play()
                wait(1)
            end
        end)

        BigBtn.MouseButton1Click:Connect(function()
            if buttonAction then
                buttonAction(Overlay)
            end
        end)
    end

    local ContentArea = Instance.new("Frame")
    if hasBigButton then
        ContentArea.Size = UDim2.new(1, -20, 1, -260)
        ContentArea.Position = UDim2.new(0, 10, 0, 185)
    else
        ContentArea.Size = UDim2.new(1, -20, 1, -160)
        ContentArea.Position = UDim2.new(0, 10, 0, 80)
    end
    ContentArea.BackgroundColor3 = Color3.fromRGB(10, 12, 30)
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.ZIndex = 92
    ContentArea.Parent = Window
    Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 10)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    TabBar.ZIndex = 93
    TabBar.Parent = ContentArea
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingLeft = UDim.new(0, 5)
    TabPad.PaddingTop = UDim.new(0, 5)
    TabPad.PaddingBottom = UDim.new(0, 5)
    TabPad.Parent = TabBar

    local tabs = {}
    local function CreateTab(name, icon, order)
        local Tab = Instance.new("TextButton")
        Tab.Size = UDim2.new(0, 120, 1, 0)
        Tab.Text = icon .. " " .. name
        Tab.TextColor3 = Color3.fromRGB(150, 170, 200)
        Tab.TextSize = 13
        Tab.Font = Enum.Font.GothamBold
        Tab.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Tab.LayoutOrder = order
        Tab.ZIndex = 94
        Tab.Parent = TabBar
        Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 8)
        return Tab
    end

    local function SwitchTab(tabName)
        for name, data in pairs(tabs) do
            if name == tabName then
                data.button.BackgroundColor3 = Color3.fromRGB(0, 212, 255)
                data.button.TextColor3 = Color3.fromRGB(11, 13, 26)
                data.content.Visible = true
            else
                data.button.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
                data.button.TextColor3 = Color3.fromRGB(150, 170, 200)
                data.content.Visible = false
            end
        end
    end

    local InfoContent = Instance.new("ScrollingFrame")
    InfoContent.Size = UDim2.new(1, -10, 1, -50)
    InfoContent.Position = UDim2.new(0, 5, 0, 45)
    InfoContent.BackgroundTransparency = 1
    InfoContent.ScrollBarThickness = 4
    InfoContent.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    InfoContent.Visible = false
    InfoContent.ZIndex = 93
    InfoContent.Parent = ContentArea

    local InfoLayout = Instance.new("UIListLayout")
    InfoLayout.Padding = UDim.new(0, 8)
    InfoLayout.Parent = InfoContent

    local InfoPad = Instance.new("UIPadding")
    InfoPad.PaddingTop = UDim.new(0, 10)
    InfoPad.PaddingLeft = UDim.new(0, 10)
    InfoPad.PaddingRight = UDim.new(0, 10)
    InfoPad.Parent = InfoContent

    local function AddInfoRow(key, value, order)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -10, 0, 55)
        Row.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        Row.LayoutOrder = order
        Row.ZIndex = 94
        Row.Parent = InfoContent
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

        local Key = Instance.new("TextLabel")
        Key.Size = UDim2.new(1, -10, 0, 20)
        Key.Position = UDim2.new(0, 10, 0, 5)
        Key.Text = key
        Key.TextColor3 = Color3.fromRGB(0, 212, 255)
        Key.TextSize = 12
        Key.Font = Enum.Font.GothamBold
        Key.TextXAlignment = Enum.TextXAlignment.Left
        Key.BackgroundTransparency = 1
        Key.ZIndex = 95
        Key.Parent = Row

        local Value = Instance.new("TextLabel")
        Value.Size = UDim2.new(1, -10, 0, 25)
        Value.Position = UDim2.new(0, 10, 0, 25)
        Value.Text = tostring(value)
        Value.TextColor3 = Color3.fromRGB(255, 255, 255)
        Value.TextSize = 14
        Value.Font = Enum.Font.Gotham
        Value.TextXAlignment = Enum.TextXAlignment.Left
        Value.TextTruncate = Enum.TextTruncate.AtEnd
        Value.BackgroundTransparency = 1
        Value.ZIndex = 95
        Value.Parent = Row
    end

    AddInfoRow("📛 Name", info.Name, 1)
    AddInfoRow("🏷️ Class", info.ClassName, 2)
    AddInfoRow("📁 Full Path", info.FullName, 3)
    AddInfoRow("👨‍👦 Parent", info.Parent, 4)
    AddInfoRow("📂 Children", info.Children, 5)
    AddInfoRow("🌳 Descendants", info.Descendants, 6)
    
    if info.IsScript then
        AddInfoRow("📜 Script", "Yes (" .. info.SourceLength .. " chars)", 7)
    end

    local propOrder = 20
    local function TryProp(name)
        pcall(function()
            local v = instance[name]
            if v ~= nil then
                AddInfoRow("⚙️ " .. name, tostring(v), propOrder)
                propOrder = propOrder + 1
            end
        end)
    end
    
    for _, prop in ipairs({"Position", "Size", "Anchored", "Transparency", "Material", "Color", "Value", "Text", "SoundId", "Volume", "Image", "Enabled", "Visible"}) do
        TryProp(prop)
    end

    InfoContent.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 20)

    local ChildrenContent = Instance.new("ScrollingFrame")
    ChildrenContent.Size = UDim2.new(1, -10, 1, -50)
    ChildrenContent.Position = UDim2.new(0, 5, 0, 45)
    ChildrenContent.BackgroundTransparency = 1
    ChildrenContent.ScrollBarThickness = 4
    ChildrenContent.ScrollBarImageColor3 = Color3.fromRGB(0, 212, 255)
    ChildrenContent.Visible = false
    ChildrenContent.ZIndex = 93
    ChildrenContent.Parent = ContentArea

    local ChLayout = Instance.new("UIListLayout")
    ChLayout.Padding = UDim.new(0, 5)
    ChLayout.Parent = ChildrenContent

    local ChPad = Instance.new("UIPadding")
    ChPad.PaddingTop = UDim.new(0, 5)
    ChPad.PaddingLeft = UDim.new(0, 5)
    ChPad.PaddingRight = UDim.new(0, 5)
    ChPad.Parent = ChildrenContent

    local children = FileScanner.GetChildren(instance)
    for i, child in ipairs(children) do
        local cInfo = FileScanner.GetInfo(child)
        
        local ChItem = Instance.new("TextButton")
        ChItem.Size = UDim2.new(1, -10, 0, 50)
        ChItem.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
        ChItem.Text = ""
        ChItem.LayoutOrder = i
        ChItem.ZIndex = 94
        ChItem.Parent = ChildrenContent
        Instance.new("UICorner", ChItem).CornerRadius = UDim.new(0, 8)

        local CIcon = Instance.new("TextLabel")
        CIcon.Size = UDim2.new(0, 40, 1, 0)
        CIcon.Position = UDim2.new(0, 5, 0, 0)
        CIcon.Text = cInfo.Icon
        CIcon.TextSize = 22
        CIcon.BackgroundTransparency = 1
        CIcon.ZIndex = 95
        CIcon.Parent = ChItem

        local CName = Instance.new("TextLabel")
        CName.Size = UDim2.new(1, -110, 0, 20)
        CName.Position = UDim2.new(0, 50, 0, 5)
        CName.Text = cInfo.Name
        CName.TextColor3 = Color3.fromRGB(255, 255, 255)
        CName.TextSize = 14
        CName.Font = Enum.Font.GothamBold
        CName.TextXAlignment = Enum.TextXAlignment.Left
        CName.BackgroundTransparency = 1
        CName.ZIndex = 95
        CName.Parent = ChItem

        local CClass = Instance.new("TextLabel")
        CClass.Size = UDim2.new(1, -110, 0, 15)
        CClass.Position = UDim2.new(0, 50, 0, 27)
        CClass.Text = cInfo.ClassName .. " • " .. cInfo.Children .. " items"
        CClass.TextColor3 = Color3.fromRGB(150, 170, 200)
        CClass.TextSize = 11
        CClass.Font = Enum.Font.Gotham
        CClass.TextXAlignment = Enum.TextXAlignment.Left
        CClass.BackgroundTransparency = 1
        CClass.ZIndex = 95
        CClass.Parent = ChItem

        ChItem.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            FileViewer.Open(mainParent, child, onClose)
        end)
    end

    ChildrenContent.CanvasSize = UDim2.new(0, 0, 0, ChLayout.AbsoluteContentSize.Y + 20)

    tabs["Info"] = {button = CreateTab("Info", "ℹ️", 1), content = InfoContent}
    if info.Children > 0 then
        tabs["Children"] = {button = CreateTab("Children", "📂", 2), content = ChildrenContent}
    end

    for name, data in pairs(tabs) do
        data.button.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end

    SwitchTab("Info")

    local BottomBar = Instance.new("Frame")
    BottomBar.Size = UDim2.new(1, -20, 0, 50)
    BottomBar.Position = UDim2.new(0, 10, 1, -60)
    BottomBar.BackgroundColor3 = Color3.fromRGB(15, 20, 45)
    BottomBar.ZIndex = 92
    BottomBar.Parent = Window
    Instance.new("UICorner", BottomBar).CornerRadius = UDim.new(0, 10)

    local BLayout = Instance.new("UIListLayout")
    BLayout.FillDirection = Enum.FillDirection.Horizontal
    BLayout.Padding = UDim.new(0, 5)
    BLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    BLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BLayout.Parent = BottomBar

    local function ActionBtn(text, icon, color, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 100, 0, 38)
        Btn.Text = icon .. " " .. text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 13
        Btn.Font = Enum.Font.GothamBold
        Btn.BackgroundColor3 = color
        Btn.ZIndex = 93
        Btn.Parent = BottomBar
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    ActionBtn("Copy Path", "🔗", Color3.fromRGB(100, 100, 200), function()
        if CopyToClipboard(info.FullName) then
            ShowNotification(Window, "✅ Path copied!", Color3.fromRGB(0, 200, 100))
        end
    end)

    ActionBtn("Clone", "📑", Color3.fromRGB(200, 150, 50), function()
        local success = pcall(function()
            local clone = instance:Clone()
            clone.Parent = instance.Parent
            clone.Name = instance.Name .. "_Copy"
        end)
        if success then
            ShowNotification(Window, "✅ Cloned!", Color3.fromRGB(0, 200, 100))
        else
            ShowNotification(Window, "❌ Failed", Color3.fromRGB(200, 50, 70))
        end
    end)

    ActionBtn("Delete", "🗑️", Color3.fromRGB(200, 50, 70), function()
        local success = pcall(function() instance:Destroy() end)
        if success then
            ShowNotification(Window, "✅ Deleted!", Color3.fromRGB(0, 200, 100))
            wait(1)
            Overlay:Destroy()
            if onClose then onClose() end
        else
            ShowNotification(Window, "❌ Failed", Color3.fromRGB(200, 50, 70))
        end
    end)
end

return FileViewer
