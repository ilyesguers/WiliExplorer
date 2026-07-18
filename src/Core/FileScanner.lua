local FileScanner = {}

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

-- ═══════════════════════════════
-- محاولة قراءة سورس السكريبت (مع تجاوز الحماية)
-- ═══════════════════════════════
function FileScanner.GetSource(instance)
    local result = {
        source = "",
        method = "none",
        success = false,
        isProtected = false
    }
    
    if not (instance:IsA("BaseScript") or instance:IsA("ModuleScript")) then
        return result
    end
    
    -- الطريقة 1: قراءة مباشرة
    local ok1, src1 = pcall(function() return instance.Source end)
    if ok1 and src1 and #src1 > 0 then
        result.source = src1
        result.method = "direct"
        result.success = true
        return result
    end
    
    -- الطريقة 2: decompile (متوفرة في بعض executors)
    if decompile then
        local ok2, src2 = pcall(function() return decompile(instance) end)
        if ok2 and src2 and #src2 > 0 then
            result.source = src2
            result.method = "decompile"
            result.success = true
            return result
        end
    end
    
    -- الطريقة 3: getscriptbytecode
    if getscriptbytecode then
        local ok3, bytecode = pcall(function() return getscriptbytecode(instance) end)
        if ok3 and bytecode then
            result.source = "-- BYTECODE FOUND (raw)\n-- Use decompiler to convert\n\n" .. tostring(bytecode)
            result.method = "bytecode"
            result.success = true
            return result
        end
    end
    
    -- الطريقة 4: getscripthash
    if getscripthash then
        local ok4, hash = pcall(function() return getscripthash(instance) end)
        if ok4 and hash then
            result.source = "-- Script Hash: " .. tostring(hash) .. "\n-- Source cannot be extracted"
            result.method = "hash"
            result.success = false
        end
    end
    
    result.isProtected = true
    if result.source == "" then
        result.source = "-- ⚠️ This script is protected\n-- Source code cannot be read\n-- \n-- Executor doesn't support:\n-- - decompile()\n-- - getscriptbytecode()\n-- \n-- Try Delta, Synapse, or Fluxus for full access"
    end
    
    return result
end

-- ═══════════════════════════════
-- محاولة كتابة سورس السكريبت
-- ═══════════════════════════════
function FileScanner.SetSource(instance, newSource)
    local result = {
        success = false,
        method = "none",
        error = ""
    }
    
    -- الطريقة 1: كتابة مباشرة
    local ok1, err1 = pcall(function()
        instance.Source = newSource
    end)
    if ok1 then
        result.success = true
        result.method = "direct"
        return result
    end
    
    -- الطريقة 2: setscriptable
    if setscriptable then
        pcall(function() setscriptable(instance, "Source", true) end)
        local ok2, err2 = pcall(function()
            instance.Source = newSource
        end)
        if ok2 then
            result.success = true
            result.method = "setscriptable"
            return result
        end
    end
    
    -- الطريقة 3: hookmetamethod (متقدم)
    if hookmetamethod then
        local ok3 = pcall(function()
            instance.Source = newSource
        end)
        if ok3 then
            result.success = true
            result.method = "metamethod"
            return result
        end
    end
    
    result.error = tostring(err1)
    return result
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
        HasSource = false,
        SourceLength = 0
    }
    
    pcall(function()
        info.Children = #instance:GetChildren()
        info.Descendants = #instance:GetDescendants()
        info.FullName = instance:GetFullName()
        if instance.Parent then
            info.Parent = instance.Parent.Name
        end
        
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            info.IsScript = true
            local sourceData = FileScanner.GetSource(instance)
            if sourceData.success then
                info.HasSource = true
                info.SourceLength = #sourceData.source
            end
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
