--[[
    ═══════════════════════════════════════════════════════════════════════════
    ▤ WiliExplorer - Context Menu v2.0 (v7.1)
    ═══════════════════════════════════════════════════════════════════════════

    ✓ قائمة منبثقة عند النقر (Long Press للهاتف)
    ✓ خيارات ذكية حسب نوع العنصر
    ✓ صفوف بارتفاع 44px مناسبة للمس
    ✓ أيقونات رموز بدل الإيموجي + نصوص مترجمة

    ═══════════════════════════════════════════════════════════════════════════
]]

local ContextMenu = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local function GetModule(name)
    if _G.WiliModules and _G.WiliModules[name] then
        return _G.WiliModules[name]
    end
    return nil
end

local function T(key)
    local lang = GetModule("Language")
    if lang then return lang.Get(key, key) end
    return key
end

local function Icon(key, fallback)
    local icons = GetModule("Icons")
    if icons and icons[key] then return icons[key] end
    return fallback or "?"
end

-- ═══════════════════════════════════════════════════════════════════════
-- ◈ الألوان
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
-- ▤ المتغيرات
-- ═══════════════════════════════════════════════════════════════════════
local CurrentMenu = nil
local MenuGui = nil

-- ═══════════════════════════════════════════════════════════════════════
-- ◆ دوال مساعدة
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
-- ▤ إنشاء القائمة المنبثقة
-- ═══════════════════════════════════════════════════════════════════════
local ROW_HEIGHT = 44

function ContextMenu.Open(options, position)
    -- إغلاق القائمة السابقة
    ContextMenu.Close()

    local gui = CreateGui()
    local align = Enum.TextXAlignment.Left
    local lang = GetModule("Language")
    if lang then align = lang.Alignment() end

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
    menu.Size = UDim2.new(0, 220, 0, 0) -- يبدأ بحجم 0
    menu.Position = position or UDim2.new(0.5, -110, 0.5, 0)
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
            btn.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
            btn.BackgroundColor3 = Colors.BGLight
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 10001
            btn.Parent = container
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            -- الأيقونة
            local icon = Instance.new("TextLabel")
            icon.Size = UDim2.new(0, 30, 1, 0)
            icon.Position = UDim2.new(0, 6, 0, 0)
            icon.Text = option.icon or Icon("Info", "?")
            icon.TextSize = 15
            icon.TextColor3 = option.color or Colors.Accent
            icon.BackgroundTransparency = 1
            icon.ZIndex = 10002
            icon.Parent = btn

            -- النص
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, -42, 1, 0)
            text.Position = UDim2.new(0, 38, 0, 0)
            text.Text = option.text or T("MenuOption")
            text.TextColor3 = option.color or Colors.Text
            text.TextSize = 13
            text.Font = Enum.Font.Gotham
            text.TextXAlignment = align
            text.TextTruncate = Enum.TextTruncate.AtEnd
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

            totalHeight = totalHeight + ROW_HEIGHT + 2
        end
    end

    -- تحديد الحجم النهائي
    local finalHeight = math.min(totalHeight, 400)
    local finalWidth = 220

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
-- × إغلاق القائمة
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
-- ▤ قوائم جاهزة حسب نوع العنصر
-- ═══════════════════════════════════════════════════════════════════════

-- قائمة السكريبتات
function ContextMenu.ScriptMenu(instance, callbacks)
    local options = {
        {
            icon = Icon("Edit", "⌘"),
            text = T("MenuViewSource"),
            color = Colors.Accent,
            callback = callbacks.viewSource
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopySource"),
            color = Colors.Text,
            callback = callbacks.copySource
        },
        {
            icon = Icon("Edit", "✎"),
            text = T("MenuEditSource"),
            color = Colors.Warning,
            callback = callbacks.editSource
        },
        {type = "separator"},
        {
            icon = Icon("Run", "▶"),
            text = T("MenuRunScript"),
            color = Colors.Success,
            callback = callbacks.runScript
        },
        {
            icon = Icon("Pause", "Ⅱ"),
            text = T("MenuToggleDisable"),
            color = Colors.Warning,
            callback = callbacks.toggleDisable
        },
        {type = "separator"},
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPath"),
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyName"),
            color = Colors.Text,
            callback = callbacks.copyName
        },
        {type = "separator"},
        {
            icon = Icon("Delete", "⌫"),
            text = T("MenuDelete"),
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
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPosition"),
            color = Colors.Accent,
            callback = callbacks.copyPosition
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopySize"),
            color = Colors.Text,
            callback = callbacks.copySize
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyCFrame"),
            color = Colors.Text,
            callback = callbacks.copyCFrame
        },
        {type = "separator"},
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuTeleportTo"),
            color = Colors.Success,
            callback = callbacks.teleportTo
        },
        {
            icon = Icon("Contrast", "◐"),
            text = T("MenuCopyColor"),
            color = Colors.Warning,
            callback = callbacks.copyColor
        },
        {
            icon = "◫",
            text = T("MenuCopyMaterial"),
            color = Colors.Text,
            callback = callbacks.copyMaterial
        },
        {type = "separator"},
        {
            icon = "⚓",
            text = T("MenuToggleAnchored"),
            color = Colors.Warning,
            callback = callbacks.toggleAnchored
        },
        {
            icon = "◌",
            text = T("MenuToggleCanCollide"),
            color = Colors.Text,
            callback = callbacks.toggleCanCollide
        },
        {type = "separator"},
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPath"),
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = Icon("Delete", "⌫"),
            text = T("MenuDelete"),
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
            icon = Icon("Stats", "≡"),
            text = T("MenuViewValue"),
            color = Colors.Accent,
            callback = callbacks.viewValue
        },
        {
            icon = Icon("Edit", "✎"),
            text = T("MenuEditValue"),
            color = Colors.Warning,
            callback = callbacks.editValue
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyValue"),
            color = Colors.Text,
            callback = callbacks.copyValue
        },
        {type = "separator"},
        {
            icon = "❄",
            text = T("MenuFreezeValue"),
            color = Colors.Accent,
            callback = callbacks.freezeValue
        },
        {
            icon = Icon("Restart", "↺"),
            text = T("MenuResetValue"),
            color = Colors.Warning,
            callback = callbacks.resetValue
        },
        {type = "separator"},
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPath"),
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = Icon("Delete", "⌫"),
            text = T("MenuDelete"),
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
            icon = "↯",
            text = T("MenuViewInfo"),
            color = Colors.Accent,
            callback = callbacks.viewInfo
        },
        {
            icon = "➤",
            text = T("MenuFireRemote"),
            color = Colors.Danger,
            callback = callbacks.fireRemote
        },
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPath"),
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {type = "separator"},
        {
            icon = "◔",
            text = T("MenuSpyRemote"),
            color = Colors.Warning,
            callback = callbacks.spyRemote
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyFireCode"),
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
            icon = Icon("Info", "i"),
            text = T("MenuViewInfo"),
            color = Colors.Accent,
            callback = callbacks.viewInfo
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyName"),
            color = Colors.Text,
            callback = callbacks.copyName
        },
        {
            icon = Icon("Location", "⌖"),
            text = T("MenuCopyPath"),
            color = Colors.Text,
            callback = callbacks.copyPath
        },
        {
            icon = Icon("Copy", "⧉"),
            text = T("MenuCopyClassName"),
            color = Colors.Text,
            callback = callbacks.copyClassName
        },
        {type = "separator"},
        {
            icon = "⧉",
            text = T("MenuClone"),
            color = Colors.Warning,
            callback = callbacks.clone
        },
        {
            icon = Icon("Delete", "⌫"),
            text = T("MenuDelete"),
            color = Colors.Danger,
            callback = callbacks.delete
        }
    }
    return ContextMenu.Open(options)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ◈ هل القائمة مفتوحة؟
-- ═══════════════════════════════════════════════════════════════════════
function ContextMenu.IsOpen()
    return CurrentMenu ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- ◉ دعم اللمس (Long Press)
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

print("▤ Context Menu v2.0 Loaded!")

return ContextMenu
