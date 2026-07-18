local Language = {
    en = {
        AppName = "WiliExplorer",
        Version = "VIP v1.0",
        EnterKey = "ENTER COSMIC KEY",
        Verify = "VERIFY KEY",
        Verifying = "VERIFYING...",
        Launching = "LAUNCHING...",
        Invalid = "INVALID KEY",
        Welcome = "Welcome to the Cosmos",
        Explorer = "COSMIC EXPLORER",
        Services = "Game Services",
        SelectService = "Select a service to explore",
        Items = "items",
        Loading = "Loading...",
        Close = "Close",
        Minimize = "Minimize",
        Language = "العربية",
        Back = "Back",
        Search = "Search files...",
        NoItems = "No items found",
        Files = "Files",
        Folders = "Folders",
        Total = "Total",
        
        -- Services
        Workspace = "Workspace",
        Players = "Players",
        Lighting = "Lighting",
        ReplicatedStorage = "Replicated Storage",
        ServerStorage = "Server Storage",
        StarterGui = "Starter GUI",
        StarterPack = "Starter Pack",
        StarterPlayer = "Starter Player",
        Teams = "Teams",
        SoundService = "Sounds",
        MaterialService = "Materials",
        Chat = "Chat"
    },
    ar = {
        AppName = "ويلي إكسبلورر",
        Version = "VIP v1.0",
        EnterKey = "أدخل المفتاح الكوني",
        Verify = "تحقق من المفتاح",
        Verifying = "جاري التحقق...",
        Launching = "جاري الإطلاق...",
        Invalid = "مفتاح خاطئ",
        Welcome = "مرحباً بك في الكون",
        Explorer = "المستكشف الكوني",
        Services = "خدمات اللعبة",
        SelectService = "اختر خدمة للاستكشاف",
        Items = "عنصر",
        Loading = "جاري التحميل...",
        Close = "إغلاق",
        Minimize = "تصغير",
        Language = "English",
        Back = "رجوع",
        Search = "ابحث في الملفات...",
        NoItems = "لا توجد عناصر",
        Files = "ملفات",
        Folders = "مجلدات",
        Total = "المجموع",
        
        -- Services
        Workspace = "مساحة العمل",
        Players = "اللاعبون",
        Lighting = "الإضاءة",
        ReplicatedStorage = "التخزين المشترك",
        ServerStorage = "تخزين السيرفر",
        StarterGui = "واجهة البداية",
        StarterPack = "حقيبة البداية",
        StarterPlayer = "لاعب البداية",
        Teams = "الفرق",
        SoundService = "الأصوات",
        MaterialService = "المواد",
        Chat = "الدردشة"
    }
}

-- اللغة الحالية (متغير عالمي)
Language.Current = "en"

function Language.Get(key)
    local lang = Language[Language.Current] or Language.en
    return lang[key] or key
end

function Language.Toggle()
    if Language.Current == "en" then
        Language.Current = "ar"
    else
        Language.Current = "en"
    end
    return Language.Current
end

return Language
