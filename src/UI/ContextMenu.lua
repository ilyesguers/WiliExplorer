--[[
    ═══════════════════════════════════════════════════════════════════════════
    📋 WiliExplorer - Context Menu v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ قائمة منبثقة عند النقر (Long Press للهاتف)
    ✅ خيارات ذكية حسب نوع العنصر
    ✅ نسخ/لصق/حذف/تعديل
    ✅ فتح في محرر الكود
    ✅ نسخ المسار
    ✅ معلومات العنصر
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local ContextMenu = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    BG = Color3.fromRGB(15, 15, 30),
    BGLight = Color3.fromRGB(22, 22, 45),
    Border = Color3.fromRGB(40, 40, 70),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 180),
    Accent = Color3.fromRGB(0, 212, 255),
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 165, 0),
    Separator = Color3.fromRGB(40, 40, 70)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local CurrentMenu = nil
local MenuGui = nil

-- ═══════════════════════════════════════════════════════════════════════
-- 🛠️ دوال مساعدة
-- ═══════════════════════════════════════════════════════════════════════
local function Tween(obj, props, duration, style)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart), props):Play()
end

local function CreateGui()
    if MenuGui and MenuGui.Parent then return MenuGui end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "WiliContextMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    MenuGui = gui
    return gui
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 إنشاء القائمة المنبثقة
-- ═══════════════════════════════════════════════════════════════════════
function ContextMenu.Open(options, position)
    -- إغلاق القائمة السابقة
    ContextMenu.Close()
    
    local gui = CreateGui()
    
    -- خلفية شفافة للإغلاق
    local overlay = Instance.new("TextButton")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.Text = ""
    overlay.ZIndex = 9998
    overlay.Parent = gui
    
    -- القائمة الرئيسية
    local menu = Instance.new("Frame")
    menu.Name = "Menu"
    menu.Size = UDim2.new(0, 200, 0, 0) -- يبدأ بحجم 0
    menu.Position = position or UDim2.new(0.5, -100, 0.5, 0)
    menu.BackgroundColor3 = Colors.BG
    menu.BorderSizePixel = 0
    menu.ClipsDescendants = true
    menu.ZIndex = 9999
    menu.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = menu
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1.5
    stroke.Parent = menu
    
    -- حاوية العناصر
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -10, 1, -10)
    container.Position = UDim2.new(0, 5, 0, 5)
    container.BackgroundTransparency = 1
    container.ZIndex = 10000
    container.Parent = menu
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = container
    
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = container
    
    -- إضافة العناصر
    local totalHeight = 8
    for i, option in ipairs(options) do
        if option.type == "separator" then
            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, -8, 0, 1)
            sep.BackgroundColor3 = Colors.Separator
            sep.BackgroundTransparency = 0.5
            sep.BorderSizePixel = 0
            sep.ZIndex = 10001
            sep.Parent = container
            totalHeight = totalHeight + 5
        else
            local btn = Instance.new("TextButton")
            btn.Name = "Option_" .. i
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = Colors.BGLight
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 10001
            btn.Parent = container
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            
            -- الأيقونة
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 28, 1, 0)
            icon.Position = UDim2.new(0, 4, 0, 0)
            icon.Text = option.icon or "📋"
            icon.TextSize = 14
            icon.BackgroundTransparency = 1
            icon.ZIndex = 10002
            icon.Parent = btn
            
            -- النص
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, -40, 1, 0)
            text.Position = UDim2.new(0, 35, 0, 0)
            text.Text = option.text or "Option"
            text.TextColor3 = option.color or Colors.Text
            text.TextSize = 12
            text.Font = Enum.Font.Gotham
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.BackgroundTransparency = 1
            text.ZIndex = 10002
            text.Parent = btn
            
            -- اللون عند التمرير
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundTransparency = 0}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundTransparency = 1}, 0.15)
            end)
            
            -- النقر
            btn.MouseButton1Click:Connect(function()
                if option.callback then
                    option.callback()
                end
                ContextMenu.Close()
            end)
            
            totalHeight = totalHeight + 34
        end
    end
    
    -- تحديد الحجم النهائي
    local finalHeight = math.min(totalHeight, 300)
    local finalWidth = 200
    
    -- ضبط الموضع ليكون داخل الشاشة
    local screenSize = workspace.CurrentCamera.ViewportSize
    local posX = position and position.X.Offset or (screenSize.X / 2 - finalWidth / 2)
    local posY = position and position.Y.Offset or (screenSize.Y / 2 - finalHeight / 2)
    
    posX = math.clamp(posX, 5, screenSize.X - finalWidth - 5)
    posY = math.clamp(posY, 5, screenSize.Y - finalHeight - 5)
    
    menu.Position = UDim2.new(0, posX, 0, posY)
    
    -- أنيميشن الظهور
    menu.Size = UDim2.new(0, finalWidth, 0, 0)
    menu.BackgroundTransparency = 1
    stroke.Transparency = 1
    
    Tween(menu, {
        Size = UDim2.new(0, finalWidth, 0, finalHeight),
        BackgroundTransparency = 0
    }, 0.3, Enum.EasingStyle.Back)
    Tween(stroke, {Transparency = 0}, 0.2)
    
    -- إغلاق عند النقر على الخلفية
    overlay.MouseButton1Click:Connect(function()
        ContextMenu.Close()
    end)
    
    -- إغلاق عند الضغط على Escape
    local escapeConn
    escapeConn = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape then
            ContextMenu.Close()
            escapeConn:Disconnect()
        end
    end)
    
    CurrentMenu = {
        overlay = overlay,
        menu = menu,
        connections = {escapeConn}
    }
    
    return menu
end

-- ═══════════════════════════════════════════════════════════════════════
-- ❌ إغلاق القائمة
-- ═══════════════════════════════════════════════════════════════════════
function ContextMenu.Close()
    if CurrentMenu then
        -- إغلاق الأنيميشن
        if CurrentMenu.menu and CurrentMenu.menu.Parent then
            Tween(CurrentMenu.menu, {
                Size = UDim2.new(0, CurrentMenu.menu.AbsoluteSize.X, 0, 0),
                BackgroundTransparency = 1
            }, 0.2)
            task.delay(0.25, function()
                if CurrentMenu and CurrentMenu.menu and CurrentMenu.menu.Parent then
                    CurrentMenu.menu.Parent:Destroy()
                end
            end)
        end
        
        -- قطع الاتصالات
        if CurrentMenu.connections then
            for _, conn in ipairs(CurrentMenu.connections) do
                pcall(function() conn:Disconnect() end)
            end
        end
        
        CurrentMenu = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 قوائم جاهزة حسب نوع العنصر
-- ═══════════════════════════════════════════════════════════════════════

-- قائمة السكريبتات
function ContextMenu.ScriptMenu(instance, callbacks)
    local options = {
        {
            icon = "📜",
            text = "View Source",
            color = Colors.Accent,
            callback = callbacks.viewSource
        },
        {
            icon = "📋",
            text = "Copy Source",
            color = Colors.Text,
            callback = callbacks.copySource
        },
        {
            icon = "✏️",
            text = "Edit Source",
            color = Colors.Warning,
            callback = callbacks.editSource
        },
        {type = "separator"},
        {
            icon = "▶️",
            text = "Run Script",
            color = Colors.Success,
            callback = callbacks.runScript
        },
        {
            icon = "⏸️",
            text = "Toggle Disable",
            color = Colors.Warning,
            callback = callbacks.toggleDisable
        },
        {type = "separator"},
        {
            icon = "📋",
            text = "Copy Path",
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = "📋",
            text = "Copy Name",
            color = Colors.Text,
            callback = callbacks.copyName
        },
        {type = "separator"},
        {
            icon = "🗑️",
            text = "Delete",
            color = Colors.Danger,
            callback = callbacks.delete
        }
    }
    return ContextMenu.Open(options)
end

-- قائمة الأجزاء (Parts)
function ContextMenu.PartMenu(instance, callbacks)
    local options = {
        {
            icon = "📋",
            text = "Copy Position",
            color = Colors.Accent,
            callback = callbacks.copyPosition
        },
        {
            icon = "📋",
            text = "Copy Size",
            color = Colors.Text,
            callback = callbacks.copySize
        },
        {
            icon = "📋",
            text = "Copy CFrame",
            color = Colors.Text,
            callback = callbacks.copyCFrame
        },
        {type = "separator"},
        {
            icon = "📍",
            text = "Teleport To",
            color = Colors.Success,
            callback = callbacks.teleportTo
        },
        {
            icon = "🎨",
            text = "Copy Color",
            color = Colors.Warning,
            callback = callbacks.copyColor
        },
        {
            icon = "🧱",
            text = "Copy Material",
            color = Colors.Text,
            callback = callbacks.copyMaterial
        },
        {type = "separator"},
        {
            icon = "📌",
            text = "Toggle Anchored",
            color = Colors.Warning,
            callback = callbacks.toggleAnchored
        },
        {
            icon = "👻",
            text = "Toggle CanCollide",
            color = Colors.Text,
            callback = callbacks.toggleCanCollide
        },
        {type = "separator"},
        {
            icon = "📋",
            text = "Copy Path",
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = "🗑️",
            text = "Delete",
            color = Colors.Danger,
            callback = callbacks.delete
        }
    }
    return ContextMenu.Open(options)
end

-- قائمة الـ Values
function ContextMenu.ValueMenu(instance, callbacks)
    local options = {
        {
            icon = "📊",
            text = "View Value",
            color = Colors.Accent,
            callback = callbacks.viewValue
        },
        {
            icon = "✏️",
            text = "Edit Value",
            color = Colors.Warning,
            callback = callbacks.editValue
        },
        {
            icon = "📋",
            text = "Copy Value",
            color = Colors.Text,
            callback = callbacks.copyValue
        },
        {type = "separator"},
        {
            icon = "❄️",
            text = "Freeze Value",
            color = Colors.Info,
            callback = callbacks.freezeValue
        },
        {
            icon = "🔄",
            text = "Reset Value",
            color = Colors.Warning,
            callback = callbacks.resetValue
        },
        {type = "separator"},
        {
            icon = "📋",
            text = "Copy Path",
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = "🗑️",
            text = "Delete",
            color = Colors.Danger,
            callback = callbacks.delete
        }
    }
    return ContextMenu.Open(options)
end

-- قائمة الـ Remotes
function ContextMenu.RemoteMenu(instance, callbacks)
    local options = {
        {
            icon = "📡",
            text = "View Info",
            color = Colors.Accent,
            callback = callbacks.viewInfo
        },
        {
            icon = "🔥",
            text = "Fire Remote",
            color = Colors.Danger,
            callback = callbacks.fireRemote
        },
        {
            icon = "📋",
            text = "Copy Path",
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {type = "separator"},
        {
            icon = "🕵️",
            text = "Spy This Remote",
            color = Colors.Warning,
            callback = callbacks.spyRemote
        },
        {
            icon = "📋",
            text = "Copy Fire Code",
            color = Colors.Text,
            callback = callbacks.copyFireCode
        }
    }
    return ContextMenu.Open(options)
end

-- قائمة عامة
function ContextMenu.GeneralMenu(instance, callbacks)
    local options = {
        {
            icon = "ℹ️",
            text = "View Info",
            color = Colors.Accent,
            callback = callbacks.viewInfo
        },
        {
            icon = "📋",
            text = "Copy Name",
            color = Colors.Text,
            callback = callbacks.copyName
        },
        {
            icon = "📋",
            text = "Copy Path",
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = "📋",
            text = "Copy ClassName",
            color = Colors.Text,
            callback = callbacks.copyClassName
        },
        {type = "separator"},
        {
            icon = "📑",
            text = "Clone",
            color = Colors.Warning,
            callback = callbacks.clone
        },
        {
            icon = "🗑️",
            text = "Delete",
            color = Colors.Danger,
            callback = callbacks.delete
        }
    }
    return ContextMenu.Open(options)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 إغلاق عند النقر خارج القائمة
-- ═══════════════════════════════════════════════════════════════════════
function ContextMenu.IsOpen()
    return CurrentMenu ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📱 دعم اللمس (Long Press)
-- ═══════════════════════════════════════════════════════════════════════
function ContextMenu.AddLongPress(frame, callback, duration)
    local pressTime = 0
    local pressing = false
    local longPressDuration = duration or 0.5
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressing = true
            pressTime = tick()
            
            task.delay(longPressDuration, function()
                if pressing and (tick() - pressTime) >= longPressDuration then
                    local pos = UDim2.new(0, input.Position.X, 0, input.Position.Y)
                    callback(pos)
                end
            end)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressing = false
        end
    end)
end

print("📋 Context Menu v1.0 Loaded!")

return ContextMenu
