local ImageEditor = {}

local TweenService = game:GetService("TweenService")

local function CopyToClipboard(text)
    pcall(function()
        if setclipboard then setclipboard(text)
        elseif toclipboard then toclipboard(text) end
    end)
end

local function ShowNotif(parent, msg, color)
    local N = Instance.new("Frame")
    N.Size = UDim2.new(0, 250, 0, 45)
    N.Position = UDim2.new(0.5, -125, 0, -50)
    N.BackgroundColor3 = color
    N.ZIndex = 310
    N.Parent = parent
    Instance.new("UICorner", N).CornerRadius = UDim.new(0, 10)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,0,1,0)
    L.Text = msg
    L.TextColor3 = Color3.fromRGB(255,255,255)
    L.TextSize = 13
    L.Font = Enum.Font.GothamBold
    L.BackgroundTransparency = 1
    L.ZIndex = 311
    L.Parent = N
    TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 10)}):Play()
    spawn(function()
        wait(2)
        TweenService:Create(N, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
        wait(0.3)
        N:Destroy()
    end)
end

function ImageEditor.Open(mainParent, imageInstance, onExit)
    local FullScreen = Instance.new("Frame")
    FullScreen.Size = UDim2.new(1, 0, 1, 0)
    FullScreen.BackgroundColor3 = Color3.fromRGB(8, 10, 20)
    FullScreen.ZIndex = 500
    FullScreen.Parent = mainParent

    -- الشريط العلوي
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 55)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
    TopBar.ZIndex = 501
    TopBar.Parent = FullScreen

    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, 0)
    TopLine.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    TopLine.ZIndex = 502
    TopLine.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = "🖼️ " .. imageInstance.Name
    Title.TextColor3 = Color3.fromRGB(255, 100, 150)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.ZIndex = 502
    Title.Parent = TopBar

    local ExitBtn = Instance.new("TextButton")
    ExitBtn.Size = UDim2.new(0, 90, 0, 38)
    ExitBtn.Position = UDim2.new(1, -100, 0.5, -19)
    ExitBtn.Text = "✕ Exit"
    ExitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ExitBtn.TextSize = 14
    ExitBtn.Font = Enum.Font.GothamBold
    ExitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    ExitBtn.ZIndex = 502
    ExitBtn.Parent = TopBar
    Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)

    ExitBtn.MouseButton1Click:Connect(function()
        FullScreen:Destroy()
        if onExit then onExit() end
    end)

    -- المحتوى
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -70)
    Content.Position = UDim2.new(0, 10, 0, 65)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    Content.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 150)
    Content.ZIndex = 501
    Content.Parent = FullScreen

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 12)
    CLayout.Parent = Content

    local CPad = Instance.new("UIPadding")
    CPad.PaddingTop = UDim.new(0, 10)
    CPad.PaddingLeft = UDim.new(0, 5)
    CPad.PaddingRight = UDim.new(0, 5)
    CPad.Parent = Content

    -- ═══ معاينة الصورة ═══
    local PreviewFrame = Instance.new("Frame")
    PreviewFrame.Size = UDim2.new(1, 0, 0, 200)
    PreviewFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    PreviewFrame.ZIndex = 502
    PreviewFrame.Parent = Content
    Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 12)

    local PreviewLabel = Instance.new("TextLabel")
    PreviewLabel.Size = UDim2.new(1, 0, 0, 25)
    PreviewLabel.Position = UDim2.new(0, 0, 0, 5)
    PreviewLabel.Text = "🖼️ Preview"
    PreviewLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
    PreviewLabel.TextSize = 14
    PreviewLabel.Font = Enum.Font.GothamBold
    PreviewLabel.BackgroundTransparency = 1
    PreviewLabel.ZIndex = 503
    PreviewLabel.Parent = PreviewFrame

    local currentImage = ""
    pcall(function()
        if imageInstance:IsA("Decal") or imageInstance:IsA("Texture") then
            currentImage = imageInstance.Texture
        elseif imageInstance:IsA("ImageLabel") or imageInstance:IsA("ImageButton") then
            currentImage = imageInstance.Image
        end
    end)

    local Preview = Instance.new("ImageLabel")
    Preview.Size = UDim2.new(0, 150, 0, 150)
    Preview.Position = UDim2.new(0.5, -75, 0, 35)
    Preview.Image = currentImage
    Preview.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Preview.ScaleType = Enum.ScaleType.Fit
    Preview.ZIndex = 503
    Preview.Parent = PreviewFrame
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 10)

    -- ═══ تغيير Image ID ═══
    local IdFrame = Instance.new("Frame")
    IdFrame.Size = UDim2.new(1, 0, 0, 80)
    IdFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    IdFrame.ZIndex = 502
    IdFrame.Parent = Content
    Instance.new("UICorner", IdFrame).CornerRadius = UDim.new(0, 12)

    local IdLabel = Instance.new("TextLabel")
    IdLabel.Size = UDim2.new(1, -20, 0, 20)
    IdLabel.Position = UDim2.new(0, 10, 0, 8)
    IdLabel.Text = "🎨 Image / Texture ID"
    IdLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
    IdLabel.TextSize = 13
    IdLabel.Font = Enum.Font.GothamBold
    IdLabel.TextXAlignment = Enum.TextXAlignment.Left
    IdLabel.BackgroundTransparency = 1
    IdLabel.ZIndex = 503
    IdLabel.Parent = IdFrame

    local IdInput = Instance.new("TextBox")
    IdInput.Size = UDim2.new(1, -20, 0, 35)
    IdInput.Position = UDim2.new(0, 10, 0, 35)
    IdInput.Text = currentImage
    IdInput.PlaceholderText = "rbxassetid://12345678"
    IdInput.BackgroundColor3 = Color3.fromRGB(12, 15, 30)
    IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    IdInput.Font = Enum.Font.Code
    IdInput.TextSize = 13
    IdInput.ClearTextOnFocus = false
    IdInput.ZIndex = 503
    IdInput.Parent = IdFrame
    Instance.new("UICorner", IdInput).CornerRadius = UDim.new(0, 8)

    IdInput.FocusLost:Connect(function()
        pcall(function()
            if imageInstance:IsA("Decal") or imageInstance:IsA("Texture") then
                imageInstance.Texture = IdInput.Text
            elseif imageInstance:IsA("ImageLabel") or imageInstance:IsA("ImageButton") then
                imageInstance.Image = IdInput.Text
            end
            Preview.Image = IdInput.Text
        end)
        ShowNotif(FullScreen, "🖼️ Image updated!", Color3.fromRGB(0, 200, 100))
    end)

    -- ═══ Transparency Slider ═══
    local TransFrame = Instance.new("Frame")
    TransFrame.Size = UDim2.new(1, 0, 0, 80)
    TransFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    TransFrame.ZIndex = 502
    TransFrame.Parent = Content
    Instance.new("UICorner", TransFrame).CornerRadius = UDim.new(0, 12)

    local TransLabel = Instance.new("TextLabel")
    TransLabel.Size = UDim2.new(0.5, 0, 0, 25)
    TransLabel.Position = UDim2.new(0, 15, 0, 8)
    TransLabel.Text = "🔍 Transparency"
    TransLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
    TransLabel.TextSize = 14
    TransLabel.Font = Enum.Font.GothamBold
    TransLabel.TextXAlignment = Enum.TextXAlignment.Left
    TransLabel.BackgroundTransparency = 1
    TransLabel.ZIndex = 503
    TransLabel.Parent = TransFrame

    local currentTrans = 0
    pcall(function() currentTrans = imageInstance.Transparency end)

    local TransVal = Instance.new("TextLabel")
    TransVal.Size = UDim2.new(0.4, 0, 0, 25)
    TransVal.Position = UDim2.new(0.55, 0, 0, 8)
    TransVal.Text = tostring(math.floor(currentTrans * 100) / 100)
    TransVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    TransVal.TextSize = 16
    TransVal.Font = Enum.Font.GothamBold
    TransVal.TextXAlignment = Enum.TextXAlignment.Right
    TransVal.BackgroundTransparency = 1
    TransVal.ZIndex = 503
    TransVal.Parent = TransFrame

    local TransTrack = Instance.new("Frame")
    TransTrack.Size = UDim2.new(1, -30, 0, 8)
    TransTrack.Position = UDim2.new(0, 15, 0, 50)
    TransTrack.BackgroundColor3 = Color3.fromRGB(40, 45, 80)
    TransTrack.ZIndex = 503
    TransTrack.Parent = TransFrame
    Instance.new("UICorner", TransTrack).CornerRadius = UDim.new(1, 0)

    local TransFill = Instance.new("Frame")
    TransFill.Size = UDim2.new(currentTrans, 0, 1, 0)
    TransFill.BackgroundColor3 = Color3.fromRGB(255, 100, 150)
    TransFill.ZIndex = 504
    TransFill.Parent = TransTrack
    Instance.new("UICorner", TransFill).CornerRadius = UDim.new(1, 0)

    local TransKnob = Instance.new("TextButton")
    TransKnob.Size = UDim2.new(0, 22, 0, 22)
    TransKnob.Position = UDim2.new(currentTrans, -11, 0.5, -11)
    TransKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TransKnob.Text = ""
    TransKnob.ZIndex = 505
    TransKnob.Parent = TransTrack
    Instance.new("UICorner", TransKnob).CornerRadius = UDim.new(1, 0)

    local transDragging = false
    TransKnob.MouseButton1Down:Connect(function() transDragging = true end)
    TransTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            transDragging = true
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            transDragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if transDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local trackPos = TransTrack.AbsolutePosition.X
            local trackSize = TransTrack.AbsoluteSize.X
            local percent = math.clamp((input.Position.X - trackPos) / trackSize, 0, 1)
            TransFill.Size = UDim2.new(percent, 0, 1, 0)
            TransKnob.Position = UDim2.new(percent, -11, 0.5, -11)
            TransVal.Text = tostring(math.floor(percent * 100) / 100)
            pcall(function() imageInstance.Transparency = percent end)
        end
    end)

    -- ═══ Color ═══
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 70)
    ColorFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    ColorFrame.ZIndex = 502
    ColorFrame.Parent = Content
    Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 12)

    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, -20, 0, 25)
    ColorLabel.Position = UDim2.new(0, 10, 0, 8)
    ColorLabel.Text = "🎨 Quick Colors"
    ColorLabel.TextColor3 = Color3.fromRGB(255, 100, 150)
    ColorLabel.TextSize = 14
    ColorLabel.Font = Enum.Font.GothamBold
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.ZIndex = 503
    ColorLabel.Parent = ColorFrame

    local ColorBar = Instance.new("Frame")
    ColorBar.Size = UDim2.new(1, -20, 0, 28)
    ColorBar.Position = UDim2.new(0, 10, 0, 35)
    ColorBar.BackgroundTransparency = 1
    ColorBar.ZIndex = 503
    ColorBar.Parent = ColorFrame

    local CBLayout = Instance.new("UIListLayout")
    CBLayout.FillDirection = Enum.FillDirection.Horizontal
    CBLayout.Padding = UDim.new(0, 6)
    CBLayout.Parent = ColorBar

    local colors = {
        Color3.fromRGB(255,255,255),
        Color3.fromRGB(255,0,0),
        Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,0,255),
        Color3.fromRGB(255,255,0),
        Color3.fromRGB(255,0,255),
        Color3.fromRGB(0,255,255),
        Color3.fromRGB(255,150,0),
        Color3.fromRGB(0,0,0)
    }

    for _, col in ipairs(colors) do
        local CB = Instance.new("TextButton")
        CB.Size = UDim2.new(0, 28, 0, 28)
        CB.BackgroundColor3 = col
        CB.Text = ""
        CB.ZIndex = 504
        CB.Parent = ColorBar
        Instance.new("UICorner", CB).CornerRadius = UDim.new(0, 6)

        CB.MouseButton1Click:Connect(function()
            pcall(function()
                if imageInstance:IsA("ImageLabel") or imageInstance:IsA("ImageButton") then
                    imageInstance.ImageColor3 = col
                elseif imageInstance:IsA("Decal") then
                    imageInstance.Color3 = col
                end
            end)
            ShowNotif(FullScreen, "🎨 Color changed!", Color3.fromRGB(0, 200, 100))
        end)
    end

    -- ═══ أزرار إضافية ═══
    local ActionBar = Instance.new("Frame")
    ActionBar.Size = UDim2.new(1, 0, 0, 55)
    ActionBar.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
    ActionBar.ZIndex = 502
    ActionBar.Parent = Content
    Instance.new("UICorner", ActionBar).CornerRadius = UDim.new(0, 12)

    local ABLayout = Instance.new("UIListLayout")
    ABLayout.FillDirection = Enum.FillDirection.Horizontal
    ABLayout.Padding = UDim.new(0, 8)
    ABLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ABLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ABLayout.Parent = ActionBar

    local function ActBtn(text, icon, color, callback)
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(0, 120, 0, 38)
        B.Text = icon .. " " .. text
        B.TextColor3 = Color3.fromRGB(255,255,255)
        B.TextSize = 12
        B.Font = Enum.Font.GothamBold
        B.BackgroundColor3 = color
        B.ZIndex = 503
        B.Parent = ActionBar
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
        B.MouseButton1Click:Connect(callback)
    end

    ActBtn("Copy ID", "📋", Color3.fromRGB(0, 152, 219), function()
        CopyToClipboard(currentImage)
        ShowNotif(FullScreen, "✅ Image ID copied!", Color3.fromRGB(0, 200, 100))
    end)

    ActBtn("Save Info", "💾", Color3.fromRGB(0, 200, 100), function()
        pcall(function()
            if writefile then
                writefile("WiliExplorer_Image_" .. imageInstance.Name .. ".txt", "Name: " .. imageInstance.Name .. "\nImage: " .. currentImage .. "\nClass: " .. imageInstance.ClassName)
                ShowNotif(FullScreen, "✅ Saved!", Color3.fromRGB(0, 200, 100))
            end
        end)
    end)

    Content.CanvasSize = UDim2.new(0, 0, 0, CLayout.AbsoluteContentSize.Y + 20)
    print("ImageEditor opened: " .. imageInstance.Name)
end

return ImageEditor
