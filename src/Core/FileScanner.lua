local FileScanner = {}

-- الأيقونات حسب نوع العنصر
local TypeIcons = {
    Folder = "📁",
    Model = "🧱",
    Part = "🟦",
    MeshPart = "🔷",
    UnionOperation = "🔶",
    Script = "📜",
    LocalScript = "📱",
    ModuleScript = "📦",
    Sound = "🔊",
    Decal = "🖼️",
    Texture = "🎨",
    ImageLabel = "🖼️",
    ImageButton = "🖼️",
    TextLabel = "🔤",
    TextButton = "🔘",
    TextBox = "📝",
    Frame = "🖥️",
    ScrollingFrame = "📜",
    ScreenGui = "🎮",
    SurfaceGui = "📺",
    BillboardGui = "💬",
    Tool = "🔧",
    Animation = "🎬",
    ParticleEmitter = "✨",
    Fire = "🔥",
    Smoke = "💨",
    Light = "💡",
    PointLight = "💡",
    SpotLight = "🔦",
    SurfaceLight = "💡",
    Camera = "📷",
    Humanoid = "🧍",
    HumanoidRootPart = "🎯",
    Accessory = "🎩",
    Shirt = "👕",
    Pants = "👖",
    Hat = "🎩",
    Player = "👤",
    Team = "🚩",
    RemoteEvent = "📡",
    RemoteFunction = "📞",
    BindableEvent = "🔗",
    BindableFunction = "🔗",
    Configuration = "⚙️",
    Folder = "📂",
    Attachment = "📌",
    Motor6D = "⚙️",
    Weld = "🔧",
    WeldConstraint = "🔗",
    BodyVelocity = "💨",
    BodyPosition = "📍",
    Vector3Value = "📐",
    NumberValue = "🔢",
    StringValue = "🔤",
    BoolValue = "☑️",
    ObjectValue = "🎯",
    CFrameValue = "📐",
    Color3Value = "🎨",
    IntValue = "🔢"
}

function FileScanner.GetIcon(instance)
    local className = instance.ClassName
    if TypeIcons[className] then
        return TypeIcons[className]
    end
    -- محاولة إيجاد أيقونة قريبة
    if className:find("Script") then return "📜" end
    if className:find("Part") then return "🧱" end
    if className:find("Gui") then return "🎮" end
    if className:find("Light") then return "💡" end
    if className:find("Value") then return "🔢" end
    return "❓"
end

function FileScanner.GetChildren(instance)
    local children = {}
    local success, result = pcall(function()
        return instance:GetChildren()
    end)
    if success then
        return result
    end
    return children
end

function FileScanner.CountDescendants(instance)
    local success, result = pcall(function()
        return #instance:GetDescendants()
    end)
    if success then return result end
    return 0
end

function FileScanner.GetInfo(instance)
    local info = {
        Name = instance.Name,
        ClassName = instance.ClassName,
        Icon = FileScanner.GetIcon(instance),
        Children = 0,
        Descendants = 0,
        FullName = "",
        Parent = "",
        IsScript = false,
        HasSource = false
    }
    
    pcall(function()
        info.Children = #instance:GetChildren()
        info.Descendants = #instance:GetDescendants()
        info.FullName = instance:GetFullName()
        if instance.Parent then
            info.Parent = instance.Parent.Name
        end
        
        -- تحقق إن كان سكريبت
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            info.IsScript = true
            pcall(function()
                local src = instance.Source
                if src and #src > 0 then
                    info.HasSource = true
                    info.SourceLength = #src
                end
            end)
        end
    end)
    
    return info
end

function FileScanner.GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then return service end
    return nil
end

return FileScanner
