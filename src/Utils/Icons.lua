-- Central semantic icon registry. Emoji remain crisp at every Roblox UI scale.
local Icons = {
    Logo = "◈",
    Explorer = "⌘",
    Search = "⌕",
    Filter = "≡",
    Sort = "⇅",
    Clear = "×",
    Back = "‹",
    Forward = "›",
    Close = "×",
    Minimize = "−",
    Expand = "+",
    More = "•••",

    Script = "⌘",
    LocalScript = "⌁",
    ModuleScript = "◇",
    Model = "⬡",
    Part = "◫",
    MeshPart = "◆",
    Folder = "▰",
    Sound = "♫",
    Image = "▧",
    GUI = "▣",
    Value = "#",
    Remote = "↯",
    Light = "☼",
    Player = "●",
    Unknown = "?",

    Copy = "⧉",
    Paste = "▤",
    Delete = "⌫",
    Edit = "✎",
    Save = "↓",
    Download = "⇩",
    Refresh = "↻",
    Play = "▶",
    Pause = "Ⅱ",
    Stop = "■",
    Restart = "↺",
    Settings = "⚙",
    Properties = "☷",
    Analyze = "⌁",
    Preview = "◉",
    Link = "↗",
    Key = "◆",
    VIP = "✦",
    Success = "✓",
    Warning = "!",
    Error = "×",
    Info = "i"
}

local aliases = {
    Decal = "Image", Texture = "Image", ImageLabel = "Image", ImageButton = "Image",
    BasePart = "Part", UnionOperation = "MeshPart", Folder = "Folder",
    NumberValue = "Value", StringValue = "Value", BoolValue = "Value", IntValue = "Value",
    RemoteEvent = "Remote", RemoteFunction = "Remote", PointLight = "Light", SpotLight = "Light"
}

function Icons.Get(name, fallback)
    local key = aliases[name] or name
    return Icons[key] or fallback or Icons.Unknown
end

function Icons.ForInstance(instance)
    if not instance then return Icons.Unknown end
    return Icons.Get(instance.ClassName)
end

return Icons
