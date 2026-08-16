return {
    Name = "WiliExplorer",
    Version = "6.1.0",
    Build = "2026.08.16",
    DefaultLanguage = "ar",
    Theme = "space",
    LOADED = false,
    
    -- معلومات التطبيق
    Author = "ilyesguers",
    Description = "Professional responsive Roblox experience explorer and asset toolkit",
    
    -- الإعدادات الافتراضية
    Settings = {
        -- الواجهة
        language = "ar",
        theme = "space",
        version = "6.1.0",
        uiScale = 1,
        responsiveLayout = true,
        compactMode = "auto",
        reducedMotion = false,
        highContrast = false,
        touchTargetSize = 44,
        showNotifications = true,
        notificationDuration = 3,
        showFloatingButton = true,
        
        -- وحدة المطوّر
        consoleLastTab = "overview",
        scanBatchSize = 100,
        scanObjectLimit = 15000,
        powerSaver = "auto",
        
        -- المظهر
        spaceEffects = true,
        particlesEnabled = true,
        animationsEnabled = true
    },

    -- لا يمكن حماية سر داخل عميل عام. ضع Endpoint لخدمة تحقق خادمية.
    Security = {
        RequireKey = false,
        Endpoint = "",
        RequestTimeout = 10,
        AllowStudioBypass = true,
        AllowOfflineKeys = false
    },

    Distribution = {
        Channel = "development",
        Ref = "main",
        Repository = "https://raw.githubusercontent.com/ilyesguers/WiliExplorer/"
    },
    
    -- الملفات المطلوبة
    Modules = {
        Core = {
            "FileScanner",
            "GameAnalyzer"
        },
        Security = {
            "KeySystem",
            "HWID"
        },
        Theme = {
            "Colors",
            "Assets",
            "Stars"
        },
        UI = {
            "MainFrame",
            "Sidebar",
            "FileViewer",
            "TreeView",
            "KlimboMenu",
            "AnalyzerUI",
            "ContextMenu",
            "ErrorPopup",
            "ImageEditor",
            "Notifications",
            "PropertiesPanel",
            "SearchBar",
            "SoundEditor"
        },
        Utils = {
            "HTTP",
            "Highlighter",
            "Icons",
            "DesignSystem",
            "UIHelpers",
            "Logger",
            "Lifecycle",
            "Language",
            "SaveSystem"
        }
    }
}
