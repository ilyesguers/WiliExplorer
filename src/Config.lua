return {
    Name = "WiliExplorer",
    Version = "5.0.0",
    Build = "2026.07.21",
    DefaultLanguage = "ar",
    Theme = "space",
    LOADED = false,
    
    -- معلومات التطبيق
    Author = "ilyesguers",
    Description = "Ultimate Roblox Explorer & Exploit Suite",
    
    -- الإعدادات الافتراضية
    Settings = {
        -- الواجهة
        uiScale = 1,
        showNotifications = true,
        notificationDuration = 3,
        showFloatingButton = true,
        
        -- KlimboMenu
        klimboPosition = {x = 0.5, y = 0.5},
        klimboSize = {w = 700, h = 500},
        
        -- ESP
        espEnabled = false,
        espNames = true,
        espHealth = true,
        espDistance = true,
        espHighlight = true,
        
        -- Aimbot
        aimbotEnabled = false,
        aimbotFOV = 200,
        aimbotSmoothness = 0.5,
        aimbotTargetPart = "Head",
        
        -- Player
        walkSpeed = 16,
        jumpPower = 50,
        flySpeed = 50,
        
        -- الأمان
        antiKick = false,
        antiAFK = false,
        
        -- المظهر
        spaceEffects = true,
        particlesEnabled = true,
        animationsEnabled = true
    },
    
    -- الملفات المطلوبة
    Modules = {
        Core = {
            "FileScanner",
            "FileEditor",
            "FileActions",
            "TreeBuilder",
            "ErrorHandler",
            "GameAnalyzer",
            "AdvancedTools",
            "PropertyEditor"
        },
        Security = {
            "KeySystem",
            "Keys",
            "AntiTamper",
            "HWID"
        },
        Theme = {
            "Colors",
            "Fonts",
            "Animations",
            "Stars"
        },
        UI = {
            "MainFrame",
            "Sidebar",
            "TreeView",
            "FileViewer",
            "KlimboMenu",
            "AdvancedUI",
            "AnalyzerUI",
            "ContentPanel",
            "ContextMenu",
            "ErrorPopup",
            "ImageEditor",
            "KeyScreen",
            "Notifications",
            "PropertiesPanel",
            "SearchBar",
            "SmartMenu",
            "SoundEditor",
            "TopBar"
        },
        Utils = {
            "HTTP",
            "Highlighter",
            "Icons",
            "JSON",
            "Language",
            "SaveSystem"
        }
    }
}
