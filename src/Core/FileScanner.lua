--[[
    ═══════════════════════════════════════════════════════════════════════════
    📁 WiliExplorer - FileScanner v3.0 (Ultimate Edition)
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ الميزات:
    • تصنيف ذكي لكل أنواع الملفات (+100 نوع)
    • معلومات شاملة عن كل عنصر
    • كشف إمكانية الفتح/التعديل/النسخ
    • قراءة السورس بـ 5 طرق مختلفة
    • تحليل الخصائص التفصيلية
    • نظام ألوان وأيقونات جميل
    • دعم كامل للـ Executors
    
    📱 متوافق مع: Delta, Synapse, Fluxus, Arceus X, Hydrogen
    ═══════════════════════════════════════════════════════════════════════════
]]

local FileScanner = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 نظام الأيقونات والألوان المتقدم
-- ═══════════════════════════════════════════════════════════════════════════

local TypeData = {
    -- 📜 السكريبتات
    Script = {
        icon = "📜",
        color = Color3.fromRGB(255, 100, 100),
        category = "Scripts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Server-side script"
    },
    LocalScript = {
        icon = "📱",
        color = Color3.fromRGB(100, 150, 255),
        category = "Scripts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Client-side script"
    },
    ModuleScript = {
        icon = "📦",
        color = Color3.fromRGB(180, 100, 255),
        category = "Scripts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Reusable module"
    },
    
    -- 📁 المجلدات والتنظيم
    Folder = {
        icon = "📁",
        color = Color3.fromRGB(255, 200, 80),
        category = "Organization",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Container folder"
    },
    Configuration = {
        icon = "⚙️",
        color = Color3.fromRGB(150, 150, 150),
        category = "Organization",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Configuration container"
    },
    
    -- 🧱 الأجزاء والنماذج
    Part = {
        icon = "🟦",
        color = Color3.fromRGB(100, 180, 255),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Basic part"
    },
    MeshPart = {
        icon = "🔷",
        color = Color3.fromRGB(80, 200, 255),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Mesh part"
    },
    UnionOperation = {
        icon = "🔶",
        color = Color3.fromRGB(255, 150, 50),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Union of parts"
    },
    WedgePart = {
        icon = "🔺",
        color = Color3.fromRGB(100, 200, 150),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Wedge shaped part"
    },
    CornerWedgePart = {
        icon = "◢",
        color = Color3.fromRGB(100, 200, 150),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Corner wedge part"
    },
    TrussPart = {
        icon = "🪜",
        color = Color3.fromRGB(139, 90, 43),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Climbable truss"
    },
    SpawnLocation = {
        icon = "🎯",
        color = Color3.fromRGB(0, 255, 128),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Player spawn point"
    },
    Seat = {
        icon = "🪑",
        color = Color3.fromRGB(139, 90, 43),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Sittable seat"
    },
    VehicleSeat = {
        icon = "🚗",
        color = Color3.fromRGB(50, 50, 200),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Vehicle controller seat"
    },
    SkateboardPlatform = {
        icon = "🛹",
        color = Color3.fromRGB(200, 150, 50),
        category = "Parts",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Skateboard platform"
    },
    Terrain = {
        icon = "🏔️",
        color = Color3.fromRGB(100, 200, 100),
        category = "Parts",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Terrain voxels"
    },
    
    -- 🧍 النماذج والشخصيات
    Model = {
        icon = "🧱",
        color = Color3.fromRGB(200, 150, 100),
        category = "Models",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Group of objects"
    },
    Humanoid = {
        icon = "🧍",
        color = Color3.fromRGB(255, 200, 150),
        category = "Characters",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Character controller"
    },
    HumanoidRootPart = {
        icon = "🎯",
        color = Color3.fromRGB(255, 100, 100),
        category = "Characters",
        canOpen = true,
        canEdit = true,
        canCopy = false,
        canDelete = false,
        description = "Character root"
    },
    HumanoidDescription = {
        icon = "👤",
        color = Color3.fromRGB(255, 200, 150),
        category = "Characters",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Avatar description"
    },
    Animator = {
        icon = "🎭",
        color = Color3.fromRGB(255, 150, 200),
        category = "Characters",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Animation controller"
    },
    
    -- 👕 الملابس والإكسسوارات
    Accessory = {
        icon = "🎩",
        color = Color3.fromRGB(255, 150, 200),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Wearable accessory"
    },
    Hat = {
        icon = "🎩",
        color = Color3.fromRGB(255, 150, 200),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Legacy hat"
    },
    Shirt = {
        icon = "👕",
        color = Color3.fromRGB(100, 200, 255),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Character shirt"
    },
    Pants = {
        icon = "👖",
        color = Color3.fromRGB(50, 100, 200),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Character pants"
    },
    ShirtGraphic = {
        icon = "🎨",
        color = Color3.fromRGB(255, 100, 150),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "T-shirt graphic"
    },
    BodyColors = {
        icon = "🎨",
        color = Color3.fromRGB(255, 200, 100),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Body part colors"
    },
    CharacterMesh = {
        icon = "🦴",
        color = Color3.fromRGB(200, 200, 200),
        category = "Clothing",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Body mesh override"
    },
    
    -- 🔊 الأصوات
    Sound = {
        icon = "🔊",
        color = Color3.fromRGB(100, 255, 150),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Audio file"
    },
    SoundGroup = {
        icon = "🎵",
        color = Color3.fromRGB(100, 255, 150),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Sound group"
    },
    SoundEffect = {
        icon = "🎚️",
        color = Color3.fromRGB(100, 255, 150),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Sound effect"
    },
    EqualizerSoundEffect = {
        icon = "🎛️",
        color = Color3.fromRGB(100, 255, 150),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Equalizer effect"
    },
    ReverbSoundEffect = {
        icon = "🔉",
        color = Color3.fromRGB(100, 255, 150),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Reverb effect"
    },
    DistortionSoundEffect = {
        icon = "📢",
        color = Color3.fromRGB(255, 100, 100),
        category = "Audio",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Distortion effect"
    },
    
    -- 🖼️ الصور والرسومات
    Decal = {
        icon = "🖼️",
        color = Color3.fromRGB(255, 150, 200),
        category = "Images",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Surface decal"
    },
    Texture = {
        icon = "🎨",
        color = Color3.fromRGB(255, 150, 200),
        category = "Images",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Tiled texture"
    },
    SurfaceAppearance = {
        icon = "✨",
        color = Color3.fromRGB(255, 200, 100),
        category = "Images",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "PBR material"
    },
    
    -- 🎮 واجهات المستخدم
    ScreenGui = {
        icon = "🎮",
        color = Color3.fromRGB(0, 200, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Screen interface"
    },
    SurfaceGui = {
        icon = "📺",
        color = Color3.fromRGB(0, 200, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "3D surface UI"
    },
    BillboardGui = {
        icon = "💬",
        color = Color3.fromRGB(0, 200, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Billboard UI"
    },
    Frame = {
        icon = "🖥️",
        color = Color3.fromRGB(80, 180, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "UI container"
    },
    ScrollingFrame = {
        icon = "📜",
        color = Color3.fromRGB(80, 180, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Scrollable container"
    },
    ViewportFrame = {
        icon = "🎥",
        color = Color3.fromRGB(80, 180, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "3D viewport"
    },
    CanvasGroup = {
        icon = "🎨",
        color = Color3.fromRGB(80, 180, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Canvas group"
    },
    TextLabel = {
        icon = "🔤",
        color = Color3.fromRGB(200, 200, 255),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Text display"
    },
    TextButton = {
        icon = "🔘",
        color = Color3.fromRGB(100, 255, 150),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Clickable text"
    },
    TextBox = {
        icon = "📝",
        color = Color3.fromRGB(255, 200, 100),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Text input"
    },
    ImageLabel = {
        icon = "🖼️",
        color = Color3.fromRGB(255, 150, 200),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Image display"
    },
    ImageButton = {
        icon = "🖼️",
        color = Color3.fromRGB(100, 255, 150),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Clickable image"
    },
    VideoFrame = {
        icon = "🎬",
        color = Color3.fromRGB(255, 100, 100),
        category = "GUI",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Video player"
    },
    
    -- 🎨 عناصر UI إضافية
    UIListLayout = {
        icon = "📋",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "List layout"
    },
    UIGridLayout = {
        icon = "⊞",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Grid layout"
    },
    UITableLayout = {
        icon = "▦",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Table layout"
    },
    UIPageLayout = {
        icon = "📑",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Page layout"
    },
    UIPadding = {
        icon = "⬜",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Padding"
    },
    UICorner = {
        icon = "◐",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Rounded corners"
    },
    UIStroke = {
        icon = "◯",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Border stroke"
    },
    UIGradient = {
        icon = "🌈",
        color = Color3.fromRGB(255, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Color gradient"
    },
    UIScale = {
        icon = "🔍",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Scale modifier"
    },
    UIAspectRatioConstraint = {
        icon = "📐",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Aspect ratio"
    },
    UISizeConstraint = {
        icon = "📏",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Size constraint"
    },
    UITextSizeConstraint = {
        icon = "🔠",
        color = Color3.fromRGB(150, 150, 255),
        category = "UILayout",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Text size constraint"
    },
    
    -- 💡 الإضاءة
    PointLight = {
        icon = "💡",
        color = Color3.fromRGB(255, 255, 150),
        category = "Lighting",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Point light source"
    },
    SpotLight = {
        icon = "🔦",
        color = Color3.fromRGB(255, 255, 150),
        category = "Lighting",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Spotlight"
    },
    SurfaceLight = {
        icon = "💡",
        color = Color3.fromRGB(255, 255, 150),
        category = "Lighting",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Surface light"
    },
    
    -- ✨ التأثيرات البصرية
    ParticleEmitter = {
        icon = "✨",
        color = Color3.fromRGB(255, 200, 255),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Particle system"
    },
    Fire = {
        icon = "🔥",
        color = Color3.fromRGB(255, 100, 50),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Fire effect"
    },
    Smoke = {
        icon = "💨",
        color = Color3.fromRGB(150, 150, 150),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Smoke effect"
    },
    Sparkles = {
        icon = "✨",
        color = Color3.fromRGB(255, 255, 100),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Sparkle effect"
    },
    Explosion = {
        icon = "💥",
        color = Color3.fromRGB(255, 150, 50),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Explosion"
    },
    Trail = {
        icon = "〰️",
        color = Color3.fromRGB(255, 200, 255),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Motion trail"
    },
    Beam = {
        icon = "⚡",
        color = Color3.fromRGB(100, 200, 255),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Light beam"
    },
    Highlight = {
        icon = "🔆",
        color = Color3.fromRGB(255, 255, 100),
        category = "Effects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Object highlight"
    },
    
    -- 📷 الكاميرا
    Camera = {
        icon = "📷",
        color = Color3.fromRGB(100, 200, 255),
        category = "Camera",
        canOpen = true,
        canEdit = true,
        canCopy = false,
        canDelete = false,
        description = "Camera view"
    },
    
    -- 🔧 الأدوات
    Tool = {
        icon = "🔧",
        color = Color3.fromRGB(255, 180, 100),
        category = "Tools",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Equippable tool"
    },
    HopperBin = {
        icon = "🗑️",
        color = Color3.fromRGB(255, 180, 100),
        category = "Tools",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Legacy tool"
    },
    BackpackItem = {
        icon = "🎒",
        color = Color3.fromRGB(255, 180, 100),
        category = "Tools",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Backpack item"
    },
    
    -- 🎬 الحركة والأنيميشن
    Animation = {
        icon = "🎬",
        color = Color3.fromRGB(255, 100, 200),
        category = "Animation",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Animation clip"
    },
    AnimationTrack = {
        icon = "🎞️",
        color = Color3.fromRGB(255, 100, 200),
        category = "Animation",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Playing animation"
    },
    AnimationController = {
        icon = "🎮",
        color = Color3.fromRGB(255, 100, 200),
        category = "Animation",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Animation controller"
    },
    KeyframeSequence = {
        icon = "🎞️",
        color = Color3.fromRGB(255, 100, 200),
        category = "Animation",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Keyframe data"
    },
    
    -- 📡 الاتصالات (Remotes)
    RemoteEvent = {
        icon = "📡",
        color = Color3.fromRGB(255, 100, 100),
        category = "Networking",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Server-Client event"
    },
    RemoteFunction = {
        icon = "📞",
        color = Color3.fromRGB(255, 150, 100),
        category = "Networking",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Server-Client function"
    },
    UnreliableRemoteEvent = {
        icon = "📡",
        color = Color3.fromRGB(255, 80, 80),
        category = "Networking",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Fast unreliable event"
    },
    BindableEvent = {
        icon = "🔗",
        color = Color3.fromRGB(100, 200, 255),
        category = "Networking",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Local event"
    },
    BindableFunction = {
        icon = "🔗",
        color = Color3.fromRGB(100, 200, 255),
        category = "Networking",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = "Local function"
    },
    
    -- 📌 القيود والوصلات
    Attachment = {
        icon = "📌",
        color = Color3.fromRGB(255, 200, 100),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Attachment point"
    },
    Motor6D = {
        icon = "⚙️",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Motor joint"
    },
    Weld = {
        icon = "🔧",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Weld joint"
    },
    WeldConstraint = {
        icon = "🔗",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Weld constraint"
    },
    HingeConstraint = {
        icon = "🔄",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Hinge joint"
    },
    BallSocketConstraint = {
        icon = "⚽",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Ball socket joint"
    },
    RodConstraint = {
        icon = "📏",
        color = Color3.fromRGB(200, 200, 200),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Rod constraint"
    },
    RopeConstraint = {
        icon = "〰️",
        color = Color3.fromRGB(200, 150, 100),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Rope constraint"
    },
    SpringConstraint = {
        icon = "🌀",
        color = Color3.fromRGB(100, 200, 100),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Spring constraint"
    },
    AlignPosition = {
        icon = "📍",
        color = Color3.fromRGB(100, 200, 255),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Position alignment"
    },
    AlignOrientation = {
        icon = "🔃",
        color = Color3.fromRGB(100, 200, 255),
        category = "Constraints",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Orientation alignment"
    },
    
    -- 🚀 القوى والحركة
    BodyVelocity = {
        icon = "💨",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Velocity force"
    },
    BodyPosition = {
        icon = "📍",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Position force"
    },
    BodyForce = {
        icon = "💪",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Constant force"
    },
    BodyGyro = {
        icon = "🔄",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Rotation stabilizer"
    },
    BodyAngularVelocity = {
        icon = "🌀",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Angular velocity"
    },
    BodyThrust = {
        icon = "🚀",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Thrust force"
    },
    VectorForce = {
        icon = "➡️",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Vector force"
    },
    LinearVelocity = {
        icon = "➡️",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Linear velocity"
    },
    AngularVelocity = {
        icon = "🔄",
        color = Color3.fromRGB(100, 255, 200),
        category = "Physics",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Angular velocity"
    },
    
    -- 🔢 القيم (Values)
    StringValue = {
        icon = "🔤",
        color = Color3.fromRGB(255, 200, 150),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Text value"
    },
    NumberValue = {
        icon = "🔢",
        color = Color3.fromRGB(100, 200, 255),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Number value"
    },
    IntValue = {
        icon = "🔢",
        color = Color3.fromRGB(100, 200, 255),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Integer value"
    },
    BoolValue = {
        icon = "☑️",
        color = Color3.fromRGB(100, 255, 150),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Boolean value"
    },
    ObjectValue = {
        icon = "🎯",
        color = Color3.fromRGB(255, 150, 200),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Object reference"
    },
    Vector3Value = {
        icon = "📐",
        color = Color3.fromRGB(200, 150, 255),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "3D vector value"
    },
    CFrameValue = {
        icon = "📐",
        color = Color3.fromRGB(200, 150, 255),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "CFrame value"
    },
    Color3Value = {
        icon = "🎨",
        color = Color3.fromRGB(255, 150, 200),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Color value"
    },
    BrickColorValue = {
        icon = "🎨",
        color = Color3.fromRGB(255, 150, 200),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "BrickColor value"
    },
    RayValue = {
        icon = "➡️",
        color = Color3.fromRGB(200, 150, 255),
        category = "Values",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Ray value"
    },
    
    -- 👥 اللاعبين والفرق
    Player = {
        icon = "👤",
        color = Color3.fromRGB(0, 200, 255),
        category = "Players",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Player instance"
    },
    Team = {
        icon = "🚩",
        color = Color3.fromRGB(255, 100, 100),
        category = "Teams",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Team"
    },
    
    -- 🌐 الخدمات
    Workspace = {
        icon = "🌍",
        color = Color3.fromRGB(100, 200, 100),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Game world"
    },
    Lighting = {
        icon = "☀️",
        color = Color3.fromRGB(255, 255, 150),
        category = "Services",
        canOpen = true,
        canEdit = true,
        canCopy = false,
        canDelete = false,
        description = "Lighting service"
    },
    ReplicatedStorage = {
        icon = "📦",
        color = Color3.fromRGB(100, 200, 255),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Replicated storage"
    },
    ServerStorage = {
        icon = "🔒",
        color = Color3.fromRGB(255, 100, 100),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Server storage"
    },
    StarterGui = {
        icon = "🎮",
        color = Color3.fromRGB(0, 200, 255),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Starter GUI"
    },
    StarterPack = {
        icon = "🎒",
        color = Color3.fromRGB(255, 200, 100),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Starter tools"
    },
    StarterPlayer = {
        icon = "🧍",
        color = Color3.fromRGB(255, 200, 150),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Player defaults"
    },
    Players = {
        icon = "👥",
        color = Color3.fromRGB(0, 200, 255),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Players service"
    },
    SoundService = {
        icon = "🔊",
        color = Color3.fromRGB(100, 255, 150),
        category = "Services",
        canOpen = true,
        canEdit = true,
        canCopy = false,
        canDelete = false,
        description = "Sound service"
    },
    Chat = {
        icon = "💬",
        color = Color3.fromRGB(200, 200, 255),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Chat service"
    },
    Teams = {
        icon = "🚩",
        color = Color3.fromRGB(255, 150, 150),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Teams service"
    },
    TweenService = {
        icon = "🔄",
        color = Color3.fromRGB(200, 150, 255),
        category = "Services",
        canOpen = false,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Tween service"
    },
    Debris = {
        icon = "🗑️",
        color = Color3.fromRGB(150, 150, 150),
        category = "Services",
        canOpen = false,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Debris cleanup"
    },
    MaterialService = {
        icon = "🧱",
        color = Color3.fromRGB(200, 150, 100),
        category = "Services",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Material service"
    },
    
    -- 🔮 أخرى
    ProximityPrompt = {
        icon = "❓",
        color = Color3.fromRGB(255, 200, 100),
        category = "Interaction",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Proximity prompt"
    },
    ClickDetector = {
        icon = "👆",
        color = Color3.fromRGB(255, 200, 100),
        category = "Interaction",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Click detector"
    },
    TouchTransmitter = {
        icon = "✋",
        color = Color3.fromRGB(255, 200, 100),
        category = "Interaction",
        canOpen = true,
        canEdit = false,
        canCopy = false,
        canDelete = false,
        description = "Touch transmitter"
    },
    Dialog = {
        icon = "💭",
        color = Color3.fromRGB(200, 200, 255),
        category = "Interaction",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "NPC dialog"
    },
    DialogChoice = {
        icon = "💬",
        color = Color3.fromRGB(200, 200, 255),
        category = "Interaction",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Dialog choice"
    },
    
    -- 🌈 تأثيرات الإضاءة
    BloomEffect = {
        icon = "🌟",
        color = Color3.fromRGB(255, 255, 200),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Bloom effect"
    },
    BlurEffect = {
        icon = "🔵",
        color = Color3.fromRGB(200, 200, 255),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Blur effect"
    },
    ColorCorrectionEffect = {
        icon = "🎨",
        color = Color3.fromRGB(255, 200, 200),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Color correction"
    },
    DepthOfFieldEffect = {
        icon = "📷",
        color = Color3.fromRGB(200, 200, 255),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Depth of field"
    },
    SunRaysEffect = {
        icon = "☀️",
        color = Color3.fromRGB(255, 255, 150),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Sun rays"
    },
    Atmosphere = {
        icon = "🌫️",
        color = Color3.fromRGB(200, 220, 255),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Atmosphere"
    },
    Sky = {
        icon = "🌌",
        color = Color3.fromRGB(100, 150, 255),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Skybox"
    },
    Clouds = {
        icon = "☁️",
        color = Color3.fromRGB(255, 255, 255),
        category = "PostEffects",
        canOpen = true,
        canEdit = true,
        canCopy = true,
        canDelete = true,
        description = "Volumetric clouds"
    },
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 📋 تصنيف الفئات مع ألوانها
-- ═══════════════════════════════════════════════════════════════════════════

local CategoryInfo = {
    Scripts = {icon = "📜", color = Color3.fromRGB(255, 100, 100), priority = 1},
    Organization = {icon = "📁", color = Color3.fromRGB(255, 200, 80), priority = 2},
    GUI = {icon = "🎮", color = Color3.fromRGB(0, 200, 255), priority = 3},
    UILayout = {icon = "📐", color = Color3.fromRGB(150, 150, 255), priority = 4},
    Parts = {icon = "🧱", color = Color3.fromRGB(100, 180, 255), priority = 5},
    Models = {icon = "📦", color = Color3.fromRGB(200, 150, 100), priority = 6},
    Characters = {icon = "🧍", color = Color3.fromRGB(255, 200, 150), priority = 7},
    Clothing = {icon = "👕", color = Color3.fromRGB(255, 150, 200), priority = 8},
    Audio = {icon = "🔊", color = Color3.fromRGB(100, 255, 150), priority = 9},
    Images = {icon = "🖼️", color = Color3.fromRGB(255, 150, 200), priority = 10},
    Lighting = {icon = "💡", color = Color3.fromRGB(255, 255, 150), priority = 11},
    Effects = {icon = "✨", color = Color3.fromRGB(255, 200, 255), priority = 12},
    Animation = {icon = "🎬", color = Color3.fromRGB(255, 100, 200), priority = 13},
    Networking = {icon = "📡", color = Color3.fromRGB(255, 100, 100), priority = 14},
    Constraints = {icon = "🔗", color = Color3.fromRGB(200, 200, 200), priority = 15},
    Physics = {icon = "🚀", color = Color3.fromRGB(100, 255, 200), priority = 16},
    Values = {icon = "🔢", color = Color3.fromRGB(100, 200, 255), priority = 17},
    Players = {icon = "👥", color = Color3.fromRGB(0, 200, 255), priority = 18},
    Teams = {icon = "🚩", color = Color3.fromRGB(255, 100, 100), priority = 19},
    Tools = {icon = "🔧", color = Color3.fromRGB(255, 180, 100), priority = 20},
    Camera = {icon = "📷", color = Color3.fromRGB(100, 200, 255), priority = 21},
    Services = {icon = "🌐", color = Color3.fromRGB(100, 200, 100), priority = 22},
    Interaction = {icon = "👆", color = Color3.fromRGB(255, 200, 100), priority = 23},
    PostEffects = {icon = "🌈", color = Color3.fromRGB(255, 200, 200), priority = 24},
    Unknown = {icon = "❓", color = Color3.fromRGB(150, 150, 150), priority = 99}
}

-- ═══════════════════════════════════════════════════════════════════════════
-- 🔧 الدوال الأساسية
-- ═══════════════════════════════════════════════════════════════════════════

-- الحصول على بيانات النوع
function FileScanner.GetTypeData(instance)
    if not instance then
        return {
            icon = "❓",
            color = Color3.fromRGB(150, 150, 150),
            category = "Unknown",
            canOpen = false,
            canEdit = false,
            canCopy = false,
            canDelete = false,
            description = "Unknown"
        }
    end
    
    local className = ""
    pcall(function() className = instance.ClassName end)
    
    if TypeData[className] then
        return TypeData[className]
    end
    
    -- محاولة تخمين النوع
    if className:find("Script") then
        return TypeData.ModuleScript
    elseif className:find("Part") then
        return TypeData.Part
    elseif className:find("Gui") then
        return TypeData.ScreenGui
    elseif className:find("Light") then
        return TypeData.PointLight
    elseif className:find("Value") then
        return TypeData.StringValue
    elseif className:find("Constraint") then
        return TypeData.WeldConstraint
    elseif className:find("Effect") then
        return TypeData.ParticleEmitter
    end
    
    return {
        icon = "❓",
        color = Color3.fromRGB(150, 150, 150),
        category = "Unknown",
        canOpen = true,
        canEdit = false,
        canCopy = true,
        canDelete = true,
        description = className
    }
end

-- الحصول على الأيقونة
function FileScanner.GetIcon(instance)
    local typeData = FileScanner.GetTypeData(instance)
    return typeData.icon
end

-- الحصول على اللون
function FileScanner.GetColor(instance)
    local typeData = FileScanner.GetTypeData(instance)
    return typeData.color
end

-- الحصول على الفئة
function FileScanner.GetCategory(instance)
    local typeData = FileScanner.GetTypeData(instance)
    return typeData.category
end

-- الحصول على معلومات الفئة
function FileScanner.GetCategoryInfo(categoryName)
    return CategoryInfo[categoryName] or CategoryInfo.Unknown
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📁 دوال الملفات والأطفال
-- ═══════════════════════════════════════════════════════════════════════════

-- الحصول على الأطفال بأمان
function FileScanner.GetChildren(instance)
    if not instance then return {} end
    
    local success, children = pcall(function()
        return instance:GetChildren()
    end)
    
    if success and children then
        return children
    end
    return {}
end

-- الحصول على الأحفاد بأمان
function FileScanner.GetDescendants(instance)
    if not instance then return {} end
    
    local success, descendants = pcall(function()
        return instance:GetDescendants()
    end)
    
    if success and descendants then
        return descendants
    end
    return {}
end

-- عد الأطفال
function FileScanner.CountChildren(instance)
    local children = FileScanner.GetChildren(instance)
    return #children
end

-- عد الأحفاد
function FileScanner.CountDescendants(instance)
    local descendants = FileScanner.GetDescendants(instance)
    return #descendants
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📜 قراءة السورس (5 طرق)
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.GetSource(instance)
    local result = {
        source = "",
        method = "none",
        success = false,
        isProtected = false,
        lineCount = 0,
        charCount = 0,
        hasErrors = false,
        errorMessage = ""
    }
    
    if not instance then
        result.errorMessage = "Instance is nil"
        return result
    end
    
    -- تحقق من النوع
    local isScript = false
    pcall(function()
        isScript = instance:IsA("BaseScript") or instance:IsA("ModuleScript")
    end)
    
    if not isScript then
        result.errorMessage = "Not a script"
        return result
    end
    
    -- ═══ الطريقة 1: قراءة مباشرة ═══
    local ok1, src1 = pcall(function() 
        return instance.Source 
    end)
    if ok1 and src1 and #src1 > 0 then
        result.source = src1
        result.method = "direct"
        result.success = true
        result.lineCount = select(2, src1:gsub("\n", "\n")) + 1
        result.charCount = #src1
        return result
    end
    
    -- ═══ الطريقة 2: decompile ═══
    if decompile then
        local ok2, src2 = pcall(function() 
            return decompile(instance) 
        end)
        if ok2 and src2 and #src2 > 0 then
            result.source = "-- 🔓 Decompiled Source\n\n" .. src2
            result.method = "decompile"
            result.success = true
            result.lineCount = select(2, src2:gsub("\n", "\n")) + 1
            result.charCount = #src2
            return result
        end
    end
    
    -- ═══ الطريقة 3: getscriptbytecode ═══
    if getscriptbytecode then
        local ok3, bytecode = pcall(function() 
            return getscriptbytecode(instance) 
        end)
        if ok3 and bytecode and #bytecode > 0 then
            result.source = "-- 📦 BYTECODE (Raw)\n-- Length: " .. #bytecode .. " bytes\n-- Use external decompiler to convert\n\n-- First 500 chars (hex):\n-- " .. bytecode:sub(1, 500):gsub(".", function(c) return string.format("%02X ", string.byte(c)) end)
            result.method = "bytecode"
            result.success = true
            result.charCount = #bytecode
            return result
        end
    end
    
    -- ═══ الطريقة 4: getscripthash ═══
    if getscripthash then
        local ok4, hash = pcall(function() 
            return getscripthash(instance) 
        end)
        if ok4 and hash then
            result.source = "-- 🔐 Script Hash\n-- Hash: " .. tostring(hash) .. "\n-- Source cannot be extracted directly"
            result.method = "hash"
            result.success = false
            result.isProtected = true
            return result
        end
    end
    
    -- ═══ الطريقة 5: getsenv (للسكريبتات الشغالة) ═══
    if getsenv then
        local ok5, env = pcall(function() 
            return getsenv(instance) 
        end)
        if ok5 and env then
            local envStr = "-- 🌍 Script Environment\n\n"
            for k, v in pairs(env) do
                local vStr = tostring(v)
                if #vStr > 100 then vStr = vStr:sub(1, 100) .. "..." end
                envStr = envStr .. "-- " .. tostring(k) .. " = " .. vStr .. "\n"
            end
            result.source = envStr
            result.method = "environment"
            result.success = true
            return result
        end
    end
    
    -- ═══ فشل كل الطرق ═══
    result.isProtected = true
    result.source = [[
-- ⚠️ هذا السكريبت محمي
-- Protected Script - Source Unavailable

-- ═══════════════════════════════════════
-- 🔒 الأسباب المحتملة:
-- ═══════════════════════════════════════
-- 1. السكريبت من السيرفر (ServerScript)
-- 2. الـ Executor لا يدعم decompile
-- 3. حماية من المطور
-- 4. Core Script

-- ═══════════════════════════════════════
-- 💡 الحلول:
-- ═══════════════════════════════════════
-- • استخدم Delta أو Synapse للـ decompile
-- • حاول مع ModuleScript بدلاً من Script
-- • ابحث عن نسخة في ReplicatedStorage

-- ═══════════════════════════════════════
-- 📊 معلومات السكريبت:
-- ═══════════════════════════════════════
-- Name: ]] .. (pcall(function() return instance.Name end) and instance.Name or "Unknown") .. [[

-- ClassName: ]] .. (pcall(function() return instance.ClassName end) and instance.ClassName or "Unknown") .. [[

-- Disabled: ]] .. tostring(pcall(function() return instance.Disabled end) and instance.Disabled or "N/A")
    
    return result
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ✏️ كتابة السورس
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.SetSource(instance, newSource)
    local result = {
        success = false,
        method = "none",
        error = ""
    }
    
    if not instance or not newSource then
        result.error = "Invalid parameters"
        return result
    end
    
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
        local ok2 = pcall(function()
            instance.Source = newSource
        end)
        if ok2 then
            result.success = true
            result.method = "setscriptable"
            return result
        end
    end
    
    -- الطريقة 3: sethiddenproperty
    if sethiddenproperty then
        local ok3 = pcall(function()
            sethiddenproperty(instance, "Source", newSource)
        end)
        if ok3 then
            result.success = true
            result.method = "sethiddenproperty"
            return result
        end
    end
    
    result.error = tostring(err1) or "Cannot write source"
    return result
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📊 معلومات شاملة عن العنصر
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.GetInfo(instance)
    local info = {
        -- معلومات أساسية
        Name = "",
        ClassName = "",
        FullName = "",
        
        -- التصنيف
        Icon = "❓",
        Color = Color3.fromRGB(150, 150, 150),
        Category = "Unknown",
        Description = "",
        
        -- الإمكانيات
        CanOpen = false,
        CanEdit = false,
        CanCopy = false,
        CanDelete = false,
        
        -- الهيكل
        Parent = "",
        ParentClass = "",
        Children = 0,
        Descendants = 0,
        
        -- للسكريبتات
        IsScript = false,
        HasSource = false,
        SourceLength = 0,
        SourceLines = 0,
        SourceMethod = "none",
        IsDisabled = false,
        
        -- للأصوات
        IsSound = false,
        SoundId = "",
        SoundLength = 0,
        IsPlaying = false,
        Volume = 0,
        
        -- للصور
        IsImage = false,
        ImageId = "",
        ImageTransparency = 0,
        
        -- للـ GUI
        IsGui = false,
        GuiSize = "",
        GuiPosition = "",
        Visible = true,
        
        -- للأجزاء
        IsPart = false,
        PartSize = "",
        PartPosition = "",
        PartColor = "",
        Material = "",
        Transparency = 0,
        Anchored = false,
        CanCollide = true,
        
        -- للقيم
        IsValue = false,
        ValueType = "",
        Value = nil,
        
        -- للـ Remotes
        IsRemote = false,
        RemoteType = "",
        
        -- معلومات إضافية
        Properties = {},
        Tags = {},
        Attributes = {}
    }
    
    if not instance then return info end
    
    -- المعلومات الأساسية
    pcall(function() info.Name = instance.Name end)
    pcall(function() info.ClassName = instance.ClassName end)
    pcall(function() info.FullName = instance:GetFullName() end)
    
    -- التصنيف
    local typeData = FileScanner.GetTypeData(instance)
    info.Icon = typeData.icon
    info.Color = typeData.color
    info.Category = typeData.category
    info.Description = typeData.description
    info.CanOpen = typeData.canOpen
    info.CanEdit = typeData.canEdit
    info.CanCopy = typeData.canCopy
    info.CanDelete = typeData.canDelete
    
    -- Parent
    pcall(function()
        if instance.Parent then
            info.Parent = instance.Parent.Name
            info.ParentClass = instance.Parent.ClassName
        end
    end)
    
    -- الأطفال
    info.Children = FileScanner.CountChildren(instance)
    info.Descendants = FileScanner.CountDescendants(instance)
    
    -- ═══ السكريبتات ═══
    pcall(function()
        if instance:IsA("BaseScript") or instance:IsA("ModuleScript") then
            info.IsScript = true
            local sourceData = FileScanner.GetSource(instance)
            info.HasSource = sourceData.success
            info.SourceLength = sourceData.charCount
            info.SourceLines = sourceData.lineCount
            info.SourceMethod = sourceData.method
        end
        if instance:IsA("BaseScript") then
            info.IsDisabled = instance.Disabled
        end
    end)
    
    -- ═══ الأصوات ═══
    pcall(function()
        if instance:IsA("Sound") then
            info.IsSound = true
            info.SoundId = instance.SoundId
            info.SoundLength = instance.TimeLength
            info.IsPlaying = instance.IsPlaying
            info.Volume = instance.Volume
        end
    end)
    
    -- ═══ الصور ═══
    pcall(function()
        if instance:IsA("Decal") then
            info.IsImage = true
            info.ImageId = instance.Texture
            info.ImageTransparency = instance.Transparency
        elseif instance:IsA("Texture") then
            info.IsImage = true
            info.ImageId = instance.Texture
            info.ImageTransparency = instance.Transparency
        elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            info.IsImage = true
            info.ImageId = instance.Image
            info.ImageTransparency = instance.ImageTransparency
        end
    end)
    
    -- ═══ GUI ═══
    pcall(function()
        if instance:IsA("GuiObject") then
            info.IsGui = true
            info.GuiSize = tostring(instance.Size)
            info.GuiPosition = tostring(instance.Position)
            info.Visible = instance.Visible
        end
    end)
    
    -- ═══ الأجزاء ═══
    pcall(function()
        if instance:IsA("BasePart") then
            info.IsPart = true
            info.PartSize = string.format("%.1f, %.1f, %.1f", instance.Size.X, instance.Size.Y, instance.Size.Z)
            info.PartPosition = string.format("%.1f, %.1f, %.1f", instance.Position.X, instance.Position.Y, instance.Position.Z)
            info.PartColor = string.format("RGB(%d, %d, %d)", 
                math.floor(instance.Color.R * 255), 
                math.floor(instance.Color.G * 255), 
                math.floor(instance.Color.B * 255))
            info.Material = tostring(instance.Material):gsub("Enum.Material.", "")
            info.Transparency = instance.Transparency
            info.Anchored = instance.Anchored
            info.CanCollide = instance.CanCollide
        end
    end)
    
    -- ═══ القيم ═══
    pcall(function()
        if instance:IsA("ValueBase") then
            info.IsValue = true
            info.ValueType = instance.ClassName:gsub("Value", "")
            info.Value = instance.Value
        end
    end)
    
    -- ═══ Remotes ═══
    pcall(function()
        if instance:IsA("RemoteEvent") then
            info.IsRemote = true
            info.RemoteType = "Event"
        elseif instance:IsA("RemoteFunction") then
            info.IsRemote = true
            info.RemoteType = "Function"
        elseif instance:IsA("BindableEvent") then
            info.IsRemote = true
            info.RemoteType = "BindableEvent"
        elseif instance:IsA("BindableFunction") then
            info.IsRemote = true
            info.RemoteType = "BindableFunction"
        end
    end)
    
    -- ═══ الـ Tags ═══
    pcall(function()
        if game:GetService("CollectionService") then
            info.Tags = game:GetService("CollectionService"):GetTags(instance)
        end
    end)
    
    -- ═══ الـ Attributes ═══
    pcall(function()
        if instance.GetAttributes then
            info.Attributes = instance:GetAttributes()
        end
    end)
    
    return info
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📊 تحليل الخصائص
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.GetProperties(instance)
    local properties = {}
    
    if not instance then return properties end
    
    -- خصائص شائعة
    local commonProps = {
        "Name", "ClassName", "Parent", "Archivable",
        -- للأجزاء
        "Position", "Size", "CFrame", "Orientation", "Color", "BrickColor",
        "Material", "Transparency", "Reflectance", "Anchored", "CanCollide",
        "CanTouch", "CanQuery", "Massless", "Locked",
        -- للـ GUI
        "Visible", "BackgroundColor3", "BackgroundTransparency", "BorderColor3",
        "BorderSizePixel", "ZIndex", "LayoutOrder", "Active",
        -- للنصوص
        "Text", "TextColor3", "TextSize", "Font", "TextScaled",
        "TextWrapped", "TextXAlignment", "TextYAlignment",
        -- للصور
        "Image", "ImageColor3", "ImageTransparency", "ScaleType",
        -- للأصوات
        "SoundId", "Volume", "Pitch", "PlaybackSpeed", "Looped", "Playing",
        -- للسكريبتات
        "Disabled", "RunContext",
        -- للشخصيات
        "Health", "MaxHealth", "WalkSpeed", "JumpPower", "JumpHeight",
        -- أخرى
        "Value", "Enabled", "MaxActivationDistance"
    }
    
    for _, propName in ipairs(commonProps) do
        local success, value = pcall(function()
            return instance[propName]
        end)
        if success and value ~= nil then
            local valueStr = tostring(value)
            if #valueStr > 100 then
                valueStr = valueStr:sub(1, 100) .. "..."
            end
            properties[propName] = {
                value = value,
                display = valueStr,
                editable = true
            }
        end
    end
    
    return properties
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🔍 البحث والفلترة
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.Search(parent, query, options)
    options = options or {}
    local results = {}
    local maxResults = options.maxResults or 100
    local searchIn = options.searchIn or "name" -- name, class, both
    local caseSensitive = options.caseSensitive or false
    
    if not caseSensitive then
        query = query:lower()
    end
    
    local descendants = FileScanner.GetDescendants(parent)
    
    for _, instance in ipairs(descendants) do
        if #results >= maxResults then break end
        
        local name = ""
        local class = ""
        pcall(function() 
            name = instance.Name
            class = instance.ClassName
        end)
        
        if not caseSensitive then
            name = name:lower()
            class = class:lower()
        end
        
        local match = false
        if searchIn == "name" then
            match = name:find(query, 1, true) ~= nil
        elseif searchIn == "class" then
            match = class:find(query, 1, true) ~= nil
        else
            match = name:find(query, 1, true) ~= nil or class:find(query, 1, true) ~= nil
        end
        
        if match then
            table.insert(results, instance)
        end
    end
    
    return results
end

-- البحث حسب الفئة
function FileScanner.FindByCategory(parent, category)
    local results = {}
    local descendants = FileScanner.GetDescendants(parent)
    
    for _, instance in ipairs(descendants) do
        local instanceCategory = FileScanner.GetCategory(instance)
        if instanceCategory == category then
            table.insert(results, instance)
        end
    end
    
    return results
end

-- البحث حسب النوع
function FileScanner.FindByClass(parent, className)
    local results = {}
    local descendants = FileScanner.GetDescendants(parent)
    
    for _, instance in ipairs(descendants) do
        local success, isA = pcall(function()
            return instance:IsA(className)
        end)
        if success and isA then
            table.insert(results, instance)
        end
    end
    
    return results
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📊 إحصائيات المجلد
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.GetStats(instance)
    local stats = {
        totalItems = 0,
        byCategory = {},
        byClass = {},
        scripts = 0,
        localScripts = 0,
        moduleScripts = 0,
        parts = 0,
        models = 0,
        guis = 0,
        sounds = 0,
        images = 0,
        remotes = 0,
        values = 0,
        folders = 0
    }
    
    local descendants = FileScanner.GetDescendants(instance)
    stats.totalItems = #descendants
    
    for _, desc in ipairs(descendants) do
        local class = ""
        pcall(function() class = desc.ClassName end)
        
        -- حسب الفئة
        local category = FileScanner.GetCategory(desc)
        stats.byCategory[category] = (stats.byCategory[category] or 0) + 1
        
        -- حسب الكلاس
        stats.byClass[class] = (stats.byClass[class] or 0) + 1
        
        -- إحصائيات خاصة
        pcall(function()
            if desc:IsA("Script") then stats.scripts = stats.scripts + 1 end
            if desc:IsA("LocalScript") then stats.localScripts = stats.localScripts + 1 end
            if desc:IsA("ModuleScript") then stats.moduleScripts = stats.moduleScripts + 1 end
            if desc:IsA("BasePart") then stats.parts = stats.parts + 1 end
            if desc:IsA("Model") then stats.models = stats.models + 1 end
            if desc:IsA("GuiBase") then stats.guis = stats.guis + 1 end
            if desc:IsA("Sound") then stats.sounds = stats.sounds + 1 end
            if desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("ImageLabel") then stats.images = stats.images + 1 end
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then stats.remotes = stats.remotes + 1 end
            if desc:IsA("ValueBase") then stats.values = stats.values + 1 end
            if desc:IsA("Folder") then stats.folders = stats.folders + 1 end
        end)
    end
    
    return stats
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🔧 أدوات الخدمات
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.GetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then return service end
    return nil
end

-- قائمة الخدمات القابلة للاستكشاف
function FileScanner.GetExplorerServices()
    return {
        {name = "Workspace", icon = "🌍", color = Color3.fromRGB(100, 200, 100)},
        {name = "Players", icon = "👥", color = Color3.fromRGB(0, 200, 255)},
        {name = "Lighting", icon = "☀️", color = Color3.fromRGB(255, 255, 150)},
        {name = "ReplicatedStorage", icon = "📦", color = Color3.fromRGB(100, 200, 255)},
        {name = "ReplicatedFirst", icon = "🥇", color = Color3.fromRGB(255, 200, 100)},
        {name = "StarterGui", icon = "🎮", color = Color3.fromRGB(0, 200, 255)},
        {name = "StarterPack", icon = "🎒", color = Color3.fromRGB(255, 200, 100)},
        {name = "StarterPlayer", icon = "🧍", color = Color3.fromRGB(255, 200, 150)},
        {name = "Teams", icon = "🚩", color = Color3.fromRGB(255, 100, 100)},
        {name = "SoundService", icon = "🔊", color = Color3.fromRGB(100, 255, 150)},
        {name = "Chat", icon = "💬", color = Color3.fromRGB(200, 200, 255)},
        {name = "LocalizationService", icon = "🌐", color = Color3.fromRGB(150, 200, 255)},
        {name = "TestService", icon = "🧪", color = Color3.fromRGB(255, 150, 150)},
        {name = "ServerStorage", icon = "🔒", color = Color3.fromRGB(255, 100, 100)},
        {name = "ServerScriptService", icon = "📜", color = Color3.fromRGB(255, 100, 100)}
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 📋 نسخ/حذف/استنساخ
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.Clone(instance)
    local result = {
        success = false,
        clone = nil,
        error = ""
    }
    
    local ok, clone = pcall(function()
        return instance:Clone()
    end)
    
    if ok and clone then
        result.success = true
        result.clone = clone
    else
        result.error = "Cannot clone this instance"
    end
    
    return result
end

function FileScanner.Delete(instance)
    local result = {
        success = false,
        error = ""
    }
    
    local ok, err = pcall(function()
        instance:Destroy()
    end)
    
    if ok then
        result.success = true
    else
        result.error = tostring(err) or "Cannot delete this instance"
    end
    
    return result
end

function FileScanner.CopyToClipboard(text)
    local result = {
        success = false,
        method = "none"
    }
    
    if setclipboard then
        pcall(function()
            setclipboard(text)
            result.success = true
            result.method = "setclipboard"
        end)
    elseif toclipboard then
        pcall(function()
            toclipboard(text)
            result.success = true
            result.method = "toclipboard"
        end)
    elseif Clipboard then
        pcall(function()
            Clipboard.set(text)
            result.success = true
            result.method = "Clipboard"
        end)
    end
    
    return result
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🎨 تنسيق العرض
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.FormatSize(bytes)
    if bytes < 1024 then
        return bytes .. " B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.1f KB", bytes / 1024)
    else
        return string.format("%.1f MB", bytes / (1024 * 1024))
    end
end

function FileScanner.FormatTime(seconds)
    if seconds < 60 then
        return string.format("%.1f sec", seconds)
    elseif seconds < 3600 then
        return string.format("%.1f min", seconds / 60)
    else
        return string.format("%.1f hr", seconds / 3600)
    end
end

function FileScanner.GetDisplayName(instance)
    local info = FileScanner.GetInfo(instance)
    local badge = ""
    
    if info.IsScript then
        badge = info.HasSource and " ✓" or " 🔒"
    elseif info.IsSound then
        badge = info.IsPlaying and " ▶" or ""
    elseif info.Children > 0 then
        badge = " [" .. info.Children .. "]"
    end
    
    return info.Icon .. " " .. info.Name .. badge
end

-- ═══════════════════════════════════════════════════════════════════════════
-- 🔄 ترتيب الملفات
-- ═══════════════════════════════════════════════════════════════════════════

function FileScanner.SortChildren(children, sortBy)
    sortBy = sortBy or "category" -- category, name, class
    
    table.sort(children, function(a, b)
        local infoA = FileScanner.GetInfo(a)
        local infoB = FileScanner.GetInfo(b)
        
        if sortBy == "category" then
            local catA = FileScanner.GetCategoryInfo(infoA.Category)
            local catB = FileScanner.GetCategoryInfo(infoB.Category)
            if catA.priority ~= catB.priority then
                return catA.priority < catB.priority
            end
            return infoA.Name < infoB.Name
        elseif sortBy == "name" then
            return infoA.Name < infoB.Name
        elseif sortBy == "class" then
            if infoA.ClassName ~= infoB.ClassName then
                return infoA.ClassName < infoB.ClassName
            end
            return infoA.Name < infoB.Name
        end
        
        return false
    end)
    
    return children
end

-- ═══════════════════════════════════════════════════════════════════════════

print("✅ FileScanner v3.0 Loaded!")

return FileScanner
