--[[
    ═══════════════════════════════════════════════════════════════════════════
    ◈ WiliExplorer - Central Icon Registry v2.0
    ═══════════════════════════════════════════════════════════════════════════
    مصدر واحد لكل الأيقونات في المشروع:
    • أيقونة مميزة لكل ClassName (تغطية +120 نوع)
    • أيقونات أفعال الواجهة (نسخ، حذف، تشغيل، ...)
    • فصل الأيقونة عن النص دائماً (Label مستقل) لمنع تشابك الحروف RTL

    القاعدة الذهبية: لا تدمج أيقونة مع نص في نفس TextLabel أبداً.
    استخدم Icons.Place(parent, name) للحصول على TextLabel أيقونة مستقل.
    ═══════════════════════════════════════════════════════════════════════════
]]

local Icons = {}

-- ─────────────────────────────────────────────────────────────
-- أيقونات الواجهة العامة
-- ─────────────────────────────────────────────────────────────
Icons.UI = {
    Logo = "◈", Explorer = "⌘", Search = "⌕", Filter = "≡", Sort = "⇅",
    SortAsc = "↑", SortDesc = "↓", Clear = "×", Back = "‹", Forward = "›",
    Close = "×", Minimize = "−", Maximize = "+", Expand = "+", Collapse = "−",
    More = "•••", Menu = "☰", Home = "⌂", Refresh = "↻",
    Copy = "⧉", Paste = "▤", Cut = "✂", Delete = "⌫", Edit = "✎",
    Save = "↓", Download = "⇩", Upload = "⇧", Run = "▶", Play = "▶",
    Pause = "Ⅱ", Stop = "■", Restart = "↺", Loop = "↻", Volume = "♫",
    VolumeOff = "♪", Speed = "⇢", Prev = "‹‹", Next = "››",
    Settings = "⚙", Properties = "☷", Analyze = "⌁", Preview = "◉",
    Eye = "◉", EyeOff = "◌", Link = "↗", Key = "◆", VIP = "✦",
    Success = "✓", Warning = "!", Error = "×", Info = "i",
    Duplicate = "⧉", Rename = "✎", Undo = "↶", Redo = "↷",
    Fire = "↯", Invoke = "⇄", ZoomIn = "+", ZoomOut = "−",
    Grid = "▦", List = "≡", Tree = "▨", Code = "⌘", Console = ">_",
    Camera = "◉", Light = "☼", Cube = "◫", Wireframe = "▥",
    Palette = "◐", Tag = "⚑", Attribute = "◆", Lock = "◇", Unlock = "◆",
    Language = "Aa", User = "●", Calendar = "▤", Clock = "◔",
    FolderOpen = "▰", FolderClosed = "▱", File = "▤", Image = "▧",
    Sound = "♫", Video = "▣", Animation = "♢", Model = "⬡",
    Script = "⌘", Module = "◇", Value = "#", Remote = "↯",
    Part = "◫", Terrain = "▲", Attachment = "◈", Constraint = "⛓",
    Force = "➤", Player = "●", Team = "◐", Service = "◌",
    Effect = "✦", Sparkle = "✧", Beam = "━", Trail = "⌇",
    Gui = "▣", Text = "T", Unknown = "?", Empty = "◇",
    -- v7.1 إضافات
    Up = "↑", Down = "↓", Links = "⇄", Recent = "◔",
    CopyTree = "▨", Duplicates = "⧉", Stats = "≡",
    Purpose = "◉", Location = "⌖", Breadcrumb = "›",
    Touch = "◉", Motion = "≋", Power = "⚡", Notifications = "◔",
    Scan = "⌁", Limit = "▭", About = "i", Repository = "↗",
    Scale = "⤢", Contrast = "◐", Compact = "▦", Auto = "◒"
}

-- ─────────────────────────────────────────────────────────────
-- أيقونات الأنواع (ClassName → glyph)
-- ─────────────────────────────────────────────────────────────
local ClassIcons = {
    -- السكريبتات
    Script = "⌘", LocalScript = "⌁", ModuleScript = "◇",
    -- التنظيم
    Folder = "▰", Configuration = "⚙",
    -- الأجزاء
    Part = "◫", MeshPart = "◆", UnionOperation = "◇", WedgePart = "▲",
    CornerWedgePart = "◣", TrussPart = "▦", SpawnLocation = "◉", Seat = "◈",
    VehicleSeat = "◈", SkateboardPlatform = "▬", Terrain = "▲",
    -- النماذج والشخصيات
    Model = "⬡", Humanoid = "●", HumanoidRootPart = "◎",
    HumanoidDescription = "◐", Animator = "♢",
    -- الملابس
    Accessory = "◒", Hat = "◒", Shirt = "▤", Pants = "▥",
    ShirtGraphic = "▦", BodyColors = "◐", CharacterMesh = "▧",
    -- الأصوات
    Sound = "♫", SoundGroup = "♪", SoundEffect = "♩",
    EqualizerSoundEffect = "≡", ReverbSoundEffect = "≈", DistortionSoundEffect = "∿",
    -- الصور
    Decal = "▧", Texture = "▦", SurfaceAppearance = "✦",
    -- الواجهات
    ScreenGui = "▣", SurfaceGui = "▢", BillboardGui = "▤", Frame = "▣",
    ScrollingFrame = "≡", ViewportFrame = "◉", CanvasGroup = "▨",
    TextLabel = "T", TextButton = "▣", TextBox = "▤", ImageLabel = "▧",
    ImageButton = "▧", VideoFrame = "▣", UIListLayout = "≡", UIGridLayout = "▦",
    UITableLayout = "▤", UIPageLayout = "▤", UIPadding = "▤", UICorner = "◜",
    UIStroke = "◻", UIGradient = "◐", UIScale = "⤢",
    UIAspectRatioConstraint = "▭", UISizeConstraint = "▭", UITextSizeConstraint = "T",
    -- الإضاءة
    PointLight = "☼", SpotLight = "☼", SurfaceLight = "☼",
    -- التأثيرات
    ParticleEmitter = "✦", Fire = "✦", Smoke = "✦", Sparkles = "✧",
    Explosion = "✦", Trail = "⌇", Beam = "━", Highlight = "◉",
    -- الكاميرا والأدوات
    Camera = "◉", Tool = "◆", HopperBin = "◆", BackpackItem = "◆",
    -- الحركة
    Animation = "♢", AnimationTrack = "♢", AnimationController = "♢", KeyframeSequence = "♢",
    -- الاتصالات
    RemoteEvent = "↯", RemoteFunction = "⇄", UnreliableRemoteEvent = "↯",
    BindableEvent = "↯", BindableFunction = "⇄",
    -- القيود والوصلات
    Attachment = "◈", Weld = "⛓", WeldConstraint = "⛓", HingeConstraint = "⛓",
    BallSocketConstraint = "⛓", RodConstraint = "⛓", RopeConstraint = "⛓",
    SpringConstraint = "⛓", AlignPosition = "➤", AlignOrientation = "↻",
    -- القوى والحركة
    BodyVelocity = "➤", BodyPosition = "➤", BodyForce = "➤", BodyGyro = "↻",
    BodyAngularVelocity = "↻", BodyThrust = "➤", VectorForce = "➤",
    LinearVelocity = "➤", AngularVelocity = "↻",
    -- القيم
    StringValue = "#", NumberValue = "#", IntValue = "#", BoolValue = "#",
    ObjectValue = "◉", CFrameValue = "◫", BrickColorValue = "◐", RayValue = "↗",
    -- اللاعبون والفرق
    Player = "●", Team = "◐",
    -- الخدمات
    Workspace = "◌", Lighting = "☼", ReplicatedStorage = "◇",
    ServerStorage = "▤", StarterGui = "▣", StarterPack = "▧",
    StarterPlayer = "◉", Players = "●", SoundService = "♫",
    Chat = "◌", Teams = "◐", TweenService = "◔", Debris = "✦",
    MaterialService = "◆", ServerScriptService = "⌘",
    -- تفاعلات
    ProximityPrompt = "◉", ClickDetector = "◉", TouchTransmitter = "◉",
    Dialog = "▣", DialogChoice = "▤",
    -- تأثيرات ما بعد المعالجة
    BloomEffect = "✦", BlurEffect = "≈", ColorCorrectionEffect = "◐",
    DepthOfFieldEffect = "◉", SunRaysEffect = "☼",
    Atmosphere = "◌", Sky = "◌", Clouds = "◌"
}

-- ─────────────────────────────────────────────────────────────
-- واجهة الاستخدام
-- ─────────────────────────────────────────────────────────────
function Icons.Get(name, fallback)
    if not name then return fallback or Icons.UI.Unknown end
    return ClassIcons[name] or Icons.UI[name] or fallback or Icons.UI.Unknown
end

function Icons.ForInstance(instance)
    if not instance then return Icons.UI.Unknown end
    return Icons.Get(instance.ClassName)
end

-- إنشاء TextLabel أيقونة مستقل (الفصل الإجباري عن النص)
function Icons.Place(parent, name, options)
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Name = options.name or "Icon"
    label.Size = options.size or UDim2.new(0, 28, 0, 28)
    label.Position = options.position or UDim2.new(0, 0, 0, 0)
    label.AnchorPoint = options.anchorPoint or Vector2.new(0, 0)
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Text = Icons.Get(name)
    label.TextColor3 = options.color or Color3.fromRGB(242, 247, 255)
    label.TextSize = options.textSize or 16
    label.Font = options.font or Enum.Font.GothamMedium
    label.ZIndex = options.zIndex or 2
    if parent then label.Parent = parent end
    return label
end

-- زر مركب: أيقونة مستقلة + نص مستقل داخل نفس الزر
-- يحل مشكلة تشابك الإيموجي/الأيقونات مع النص في اتجاه RTL
function Icons.DecorateButton(button, iconName, options)
    options = options or {}
    local iconSize = options.iconSize or 18
    local padding = options.padding or 10
    local icon = Icons.Place(button, iconName, {
        size = UDim2.new(0, iconSize, 0, iconSize),
        position = UDim2.new(0, padding, 0.5, -iconSize / 2),
        color = options.color or button.TextColor3,
        textSize = iconSize,
        zIndex = options.zIndex,
        font = Enum.Font.GothamMedium
    })
    button.TextXAlignment = Enum.TextXAlignment.Left
    if options.text then
        button.Text = options.text
    end
    if options.offsetText ~= nil then
        button.Position = UDim2.new(options.offsetText, 0, 0, 0)
    end
    -- حشوة داخلية ليبقى النص بعيداً عن الأيقونة
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, padding + iconSize + 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = button
    return icon
end

return Icons
