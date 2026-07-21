--[[
    ═══════════════════════════════════════════════════════════════════════════
    ⚙️ WiliExplorer - Properties Panel v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ عرض كل خصائص العنصر
    ✅ تعديل أي خاصية
    ✅ فلترة حسب النوع
    ✅ بحث في الخصائص
    ✅ مقارنة القيم
    ✅ تاريخ التعديلات
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local PropertiesPanel = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    BG = Color3.fromRGB(15, 15, 30),
    Header = Color3.fromRGB(20, 25, 50),
    Body = Color3.fromRGB(18, 18, 38),
    Border = Color3.fromRGB(40, 40, 70),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180),
    Accent = Color3.fromRGB(0, 212, 255),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 165, 0),
    Danger = Color3.fromRGB(255, 50, 50),
    Button = Color3.fromRGB(30, 35, 65),
    ButtonHover = Color3.fromRGB(40, 45, 80),
    Section = Color3.fromRGB(25, 30, 60),
    Property = Color3.fromRGB(20, 22, 45),
    PropertyHover = Color3.fromRGB(28, 30, 55),
    Key = Color3.fromRGB(100, 200, 255),
    Value = Color3.fromRGB(200, 200, 255),
    Changed = Color3.fromRGB(255, 200, 100)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local EditHistory = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.15), props):Play()
end

local function Notify(message)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚙️ Properties",
            Text = message,
            Duration = 2
        })
    end)
end

local function ValueToString(value)
    if value == nil then return "nil" end
    if typeof then
        local t = typeof(value)
        if t == "Vector3" then
            return string.format("Vector3(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
        elseif t == "CFrame" then
            return string.format("CFrame(%.2f, %.2f, %.2f)", value.Position.X, value.Position.Y, value.Position.Z)
        elseif t == "Color3" then
            return string.format("Color3(%.2f, %.2f, %.2f)", value.R, value.G, value.B)
        elseif t == "UDim2" then
            return string.format("UDim2(%.2f, %d, %.2f, %d)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
        end
    end
    return tostring(value)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ⚙️ فتح لوحة الخصائص
-- ═══════════════════════════════════════════════════════════════════════
function PropertiesPanel.Open(parent, instance, onClose)
    if not instance then return end
    
    -- خصائص شائعة للعرض
    local CommonProperties = {
        -- عام
        {name = "Name", category = "General", editable = true},
        {name = "ClassName", category = "General", editable = false},
        {name = "Parent", category = "General", editable = false},
        {name = "Archivable", category = "General", editable = true},
        
        -- الأجزاء
        {name = "Position", category = "Transform", editable = false},
        {name = "Size", category = "Transform", editable = false},
        {name = "CFrame", category = "Transform", editable = false},
        {name = "Orientation", category = "Transform", editable = false},
        {name = "Rotation", category = "Transform", editable = false},
        
        -- المظهر
        {name = "Color", category = "Appearance", editable = true},
        {name = "Material", category = "Appearance", editable = true},
        {name = "Transparency", category = "Appearance", editable = true},
        {name = "Reflectance", category = "Appearance", editable = true},
        {name = "BrickColor", category = "Appearance", editable = true},
        
        -- الفيزياء
        {name = "Anchored", category = "Physics", editable = true},
        {name = "CanCollide", category = "Physics", editable = true},
        {name = "CanTouch", category = "Physics", editable = true},
        {name = "CanQuery", category = "Physics", editable = true},
        {name = "Massless", category = "Physics", editable = true},
        {name = "Locked", category = "Physics", editable = true},
        
        -- النصوص
        {name = "Text", category = "Text", editable = true},
        {name = "TextColor3", category = "Text", editable = true},
        {name = "TextSize", category = "Text", editable = true},
        {name = "Font", category = "Text", editable = true},
        {name = "TextScaled", category = "Text", editable = true},
        {name = "TextWrapped", category = "Text", editable = true},
        {name = "TextXAlignment", category = "Text", editable = true},
        {name = "TextYAlignment", category = "Text", editable = true},
        
        -- GUI
        {name = "Visible", category = "GUI", editable = true},
        {name = "BackgroundColor3", category = "GUI", editable = true},
        {name = "BackgroundTransparency", category = "GUI", editable = true},
        {name = "BorderColor3", category = "GUI", editable = true},
        {name = "BorderSizePixel", category = "GUI", editable = true},
        {name = "ZIndex", category = "GUI", editable = true},
        {name = "LayoutOrder", category = "GUI", editable = true},
        
        -- الصور
        {name = "Image", category = "Image", editable = true},
        {name = "ImageColor3", category = "Image", editable = true},
        {name = "ImageTransparency", category = "Image", editable = true},
        {name = "ScaleType", category = "Image", editable = true},
        
        -- الأصوات
        {name = "SoundId", category = "Sound", editable = true},
        {name = "Volume", category = "Sound", editable = true},
        {name = "Pitch", category = "Sound", editable = true},
        {name = "PlaybackSpeed", category = "Sound", editable = true},
        {name = "Looped", category = "Sound", editable = true},
        {name = "Playing", category = "Sound", editable = false},
        
        -- الشخصيات
        {name = "Health", category = "Character", editable = false},
        {name = "MaxHealth", category = "Character", editable = true},
        {name = "WalkSpeed", category = "Character", editable = true},
        {name = "JumpPower", category = "Character", editable = true},
        {name = "JumpHeight", category = "Character", editable = true},
        
        -- القيم
        {name = "Value", category = "Value", editable = true},
        {name = "Enabled", category = "Other", editable = true},
        {name = "Disabled", category = "Other", editable = true},
    }
    
    -- إنشاء الواجهة
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliProperties"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- خلفية
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.ZIndex = 998
    overlay.Parent = gui
    
    -- النافذة الرئيسية
    local window = Instance.new("Frame")
    window.Size = UDim2.new(0.9, 0, 0.9, 0)
    window.Position = UDim2.new(0.05, 0, 0.05, 0)
    window.BackgroundColor3 = Colors.BG
    window.BorderSizePixel = 0
    window.ZIndex = 999
    window.Parent = gui
    
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 15)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Accent
    stroke.Thickness = 2
    stroke.Parent = window
    
    -- الشريط العلوي
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Colors.Header
    header.BorderSizePixel = 0
    header.ZIndex = 1000
    header.Parent = window
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = Colors.Header
    headerBottom.BorderSizePixel = 0
    headerBottom.ZIndex = 1000
    headerBottom.Parent = header
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "⚙️ Properties - " .. instance.Name
    title.TextColor3 = Colors.Accent
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 1001
    title.Parent = header
    
    -- زر إغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BackgroundColor3 = Colors.Danger
    closeBtn.ZIndex = 1001
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    -- شريط البحث
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, -20, 0, 35)
    searchFrame.Position = UDim2.new(0, 10, 0, 55)
    searchFrame.BackgroundColor3 = Colors.Body
    searchFrame.ZIndex = 1000
    searchFrame.Parent = window
    Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)
    
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = Colors.Border
    searchStroke.Thickness = 1
    searchStroke.Parent = searchFrame
    
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 30, 1, 0)
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 14
    searchIcon.BackgroundTransparency = 1
    searchIcon.ZIndex = 1001
    searchIcon.Parent = searchFrame
    
    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -35, 1, -6)
    searchInput.Position = UDim2.new(0, 35, 0, 3)
    searchInput.PlaceholderText = "🔍 Search properties..."
    searchInput.Text = ""
    searchInput.TextColor3 = Colors.Text
    searchInput.PlaceholderColor3 = Colors.TextDim
    searchInput.Font = Enum.Font.Gotham
    searchInput.TextSize = 12
    searchInput.BackgroundTransparency = 1
    searchInput.ZIndex = 1001
    searchInput.Parent = searchFrame
    
    -- لوحة الخصائص
    local propsScroll = Instance.new("ScrollingFrame")
    propsScroll.Size = UDim2.new(1, -20, 1, -105)
    propsScroll.Position = UDim2.new(0, 10, 0, 95)
    propsScroll.BackgroundColor3 = Colors.Body
    propsScroll.BorderSizePixel = 0
    propsScroll.ScrollBarThickness = 4
    propsScroll.ScrollBarImageColor3 = Colors.Accent
    propsScroll.ZIndex = 1000
    propsScroll.Parent = window
    Instance.new("UICorner", propsScroll).CornerRadius = UDim.new(0, 10)
    
    local propsLayout = Instance.new("UIListLayout")
    propsLayout.Padding = UDim.new(0, 2)
    propsLayout.Parent = propsScroll
    
    local propsPad = Instance.new("UIPadding")
    propsPad.PaddingTop = UDim.new(0, 5)
    propsPad.PaddingBottom = UDim.new(0, 5)
    propsPad.PaddingLeft = UDim.new(0, 5)
    propsPad.PaddingRight = UDim.new(0, 5)
    propsPad.Parent = propsScroll
    
    -- ═══ دوال إنشاء العناصر ═══
    local allPropertyFrames = {}
    local currentCategory = nil
    
    local function CreateCategory(name)
        local cat = Instance.new("Frame")
        cat.Name = "Cat_" .. name
        cat.Size = UDim2.new(1, -4, 0, 25)
        cat.BackgroundColor3 = Colors.Section
        cat.ZIndex = 1001
        cat.Parent = propsScroll
        Instance.new("UICorner", cat).CornerRadius = UDim.new(0, 6)
        
        local catLabel = Instance.new("TextLabel")
        catLabel.Size = UDim2.new(1, -10, 1, 0)
        catLabel.Position = UDim2.new(0, 8, 0, 0)
        catLabel.Text = "📂 " .. name
        catLabel.TextColor3 = Colors.Accent
        catLabel.TextSize = 11
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextXAlignment = Enum.TextXAlignment.Left
        catLabel.BackgroundTransparency = 1
        catLabel.ZIndex = 1002
        catLabel.Parent = cat
        
        return cat
    end
    
    local function CreatePropertyRow(propName, propValue, isEditable)
        local row = Instance.new("Frame")
        row.Name = "Prop_" .. propName
        row.Size = UDim2.new(1, -4, 0, 30)
        row.BackgroundColor3 = Colors.Property
        row.ZIndex = 1001
        row.Parent = propsScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        
        -- اسم الخاصية
        local key = Instance.new("TextLabel")
        key.Size = UDim2.new(0.4, 0, 1, 0)
        key.Position = UDim2.new(0, 8, 0, 0)
        key.Text = propName
        key.TextColor3 = Colors.Key
        key.TextSize = 11
        key.Font = Enum.Font.GothamBold
        key.TextXAlignment = Enum.TextXAlignment.Left
        key.BackgroundTransparency = 1
        key.ZIndex = 1002
        key.Parent = row
        
        -- القيمة
        local valueStr = ValueToString(propValue)
        
        if isEditable then
            local valueInput = Instance.new("TextBox")
            valueInput.Size = UDim2.new(0.55, -5, 0, 22)
            valueInput.Position = UDim2.new(0.4, 5, 0.5, -11)
            valueInput.Text = valueStr
            valueInput.TextColor3 = Colors.Value
            valueInput.Font = Enum.Font.Code
            valueInput.TextSize = 10
            valueInput.TextXAlignment = Enum.TextXAlignment.Left
            valueInput.ClearTextOnFocus = false
            valueInput.BackgroundColor3 = Color3.fromRGB(12, 12, 25)
            valueInput.ZIndex = 1002
            valueInput.Parent = row
            Instance.new("UICorner", valueInput).CornerRadius = UDim.new(0, 4)
            
            valueInput.FocusLost:Connect(function()
                local newText = valueInput.Text
                local success = false
                
                pcall(function()
                    -- محاولة تحويل القيمة حسب النوع
                    local currentVal = instance[propName]
                    local newVal
                    
                    if type(currentVal) == "number" then
                        newVal = tonumber(newText)
                    elseif type(currentVal) == "boolean" then
                        if newText:lower() == "true" then newVal = true
                        elseif newText:lower() == "false" then newVal = false end
                    else
                        newVal = newText
                    end
                    
                    if newVal ~= nil then
                        instance[propName] = newVal
                        success = true
                        
                        -- حفظ في التاريخ
                        table.insert(EditHistory, {
                            property = propName,
                            oldValue = ValueToString(currentVal),
                            newValue = ValueToString(newVal),
                            time = os.date("%H:%M:%S")
                        })
                    end
                end)
                
                if success then
                    Tween(row, {BackgroundColor3 = Color3.fromRGB(20, 40, 20)}, 0.2)
                    task.delay(0.5, function()
                        Tween(row, {BackgroundColor3 = Colors.Property}, 0.2)
                    end)
                else
                    Tween(row, {BackgroundColor3 = Color3.fromRGB(40, 20, 20)}, 0.2)
                    task.delay(0.5, function()
                        Tween(row, {BackgroundColor3 = Colors.Property}, 0.2)
                    end)
                end
            end)
        else
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.55, -5, 1, 0)
            valueLabel.Position = UDim2.new(0.4, 5, 0, 0)
            valueLabel.Text = valueStr
            valueLabel.TextColor3 = Colors.TextDim
            valueLabel.TextSize = 10
            valueLabel.Font = Enum.Font.Code
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.BackgroundTransparency = 1
            valueLabel.ZIndex = 1002
            valueLabel.Parent = row
        end
        
        -- Hover
        row.MouseEnter:Connect(function()
            Tween(row, {BackgroundColor3 = Colors.PropertyHover}, 0.1)
        end)
        row.MouseLeave:Connect(function()
            Tween(row, {BackgroundColor3 = Colors.Property}, 0.1)
        end)
        
        table.insert(allPropertyFrames, {frame = row, name = propName:lower()})
        
        return row
    end
    
    -- ═══ تحميل الخصائص ═══
    local loadedCategories = {}
    
    for _, prop in ipairs(CommonProperties) do
        local success, value = pcall(function() return instance[prop.name] end)
        
        if success and value ~= nil then
            -- إنشاء الفئة إذا لم تكن موجودة
            if not loadedCategories[prop.category] then
                CreateCategory(prop.category)
                loadedCategories[prop.category] = true
            end
            
            CreatePropertyRow(prop.name, value, prop.editable)
        end
    end
    
    -- ═══ خصائص إضافية (Tags, Attributes) ═══
    pcall(function()
        local CollectionService = game:GetService("CollectionService")
        local tags = CollectionService:GetTags(instance)
        
        if #tags > 0 then
            CreateCategory("Tags")
            for _, tag in ipairs(tags) do
                CreatePropertyRow("Tag: " .. tag, "✅", false)
            end
        end
    end)
    
    pcall(function()
        local attributes = instance:GetAttributes()
        if attributes then
            local hasAttributes = false
            for _ in pairs(attributes) do hasAttributes = true; break end
            
            if hasAttributes then
                CreateCategory("Attributes")
                for name, value in pairs(attributes) do
                    CreatePropertyRow("Attr: " .. name, value, true)
                end
            end
        end
    end)
    
    -- ═══ البحث ═══
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchInput.Text:lower()
        
        for _, data in ipairs(allPropertyFrames) do
            if query == "" then
                data.frame.Visible = true
            else
                data.frame.Visible = data.name:find(query, 1, true) ~= nil
            end
        end
    end)
    
    -- ═══ تحديث حجم Canvas ═══
    propsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        propsScroll.CanvasSize = UDim2.new(0, 0, 0, propsLayout.AbsoluteContentSize.Y + 10)
    end)
    propsScroll.CanvasSize = UDim2.new(0, 0, 0, propsLayout.AbsoluteContentSize.Y + 10)
    
    -- ═══ إغلاق ═══
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if onClose then onClose() end
    end)
    
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            gui:Destroy()
            if onClose then onClose() end
        end
    end)
    
    return {
        close = function() gui:Destroy() end,
        getHistory = function() return EditHistory end
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 API
-- ═══════════════════════════════════════════════════════════════════════
function PropertiesPanel.GetEditHistory()
    return EditHistory
end

function PropertiesPanel.ClearHistory()
    EditHistory = {}
end

print("⚙️ Properties Panel v1.0 Loaded!")

return PropertiesPanel
