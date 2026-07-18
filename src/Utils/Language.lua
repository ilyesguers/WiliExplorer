اكتب في الملف:

-- WiliExplorer Language System
-- Arabic + English

local Language = {}

Language.Texts = {
    en = {
        -- General
        AppName = "WiliExplorer",
        Loading = "Loading...",
        Welcome = "Welcome to WiliExplorer",
        
        -- Key System
        EnterKey = "Enter your VIP Key",
        KeyPlaceholder = "XXXX-XXXX-XXXX-XXXX",
        Verify = "Verify",
        InvalidKey = "Invalid Key!",
        KeyExpired = "Key Expired!",
        KeySuccess = "Key Verified!",
        
        -- File Explorer
        Files = "Files",
        Search = "Search...",
        NoResults = "No results found",
        TotalFiles = "Total Files",
        TotalFolders = "Total Folders",
        
        -- Actions
        Copy = "Copy",
        CopyPath = "Copy Path",
        CopyContent = "Copy Content",
        Paste = "Paste",
        Delete = "Delete",
        Rename = "Rename",
        Clone = "Clone",
        Move = "Move",
        Save = "Save",
        Undo = "Undo",
        Download = "Download",
        DownloadAll = "Download All",
        Edit = "Edit",
        
        -- Editor
        ScriptEditor = "Script Editor",
        ImageEditor = "Image Editor",
        SoundEditor = "Sound Editor",
        Properties = "Properties",
        
        -- Sound
        Play = "Play",
        Stop = "Stop",
        Volume = "Volume",
        Pitch = "Pitch",
        Loop = "Loop",
        
        -- Errors
        Error = "Error",
        ErrorType = "Type",
        ErrorFile = "File",
        ErrorLine = "Line",
        ErrorDetails = "Details",
        ErrorSolution = "Suggested Fix",
        ErrorUndo = "Undo",
        ErrorIgnore = "Ignore",
        ErrorCopy = "Copy Error",
        
        -- Filters
        All = "All",
        Scripts = "Scripts",
        Models = "Models",
        Sounds = "Sounds",
        Images = "Images",
        GUI = "GUI",
        
        -- Confirm
        ConfirmDelete = "Are you sure you want to delete?",
        Yes = "Yes",
        No = "No",
        
        -- Notifications
        Copied = "Copied!",
        Saved = "Saved!",
        Deleted = "Deleted!",
        Modified = "Modified!",
        Protected = "Protected Script",
        
        -- Settings
        Language = "Language",
        Arabic = "العربية",
        English = "English",
    },
    
    ar = {
        -- عام
        AppName = "ويلي إكسبلورر",
        Loading = "جاري التحميل...",
        Welcome = "مرحباً بك في WiliExplorer",
        
        -- نظام المفاتيح
        EnterKey = "أدخل مفتاح VIP",
        KeyPlaceholder = "XXXX-XXXX-XXXX-XXXX",
        Verify = "تحقق",
        InvalidKey = "مفتاح غير صالح!",
        KeyExpired = "المفتاح منتهي!",
        KeySuccess = "تم التحقق بنجاح!",
        
        -- متصفح الملفات
        Files = "الملفات",
        Search = "بحث...",
        NoResults = "لا توجد نتائج",
        TotalFiles = "إجمالي الملفات",
        TotalFolders = "إجمالي المجلدات",
        
        -- الأوامر
        Copy = "نسخ",
        CopyPath = "نسخ المسار",
        CopyContent = "نسخ المحتوى",
        Paste = "لصق",
        Delete = "حذف",
        Rename = "إعادة تسمية",
        Clone = "نسخ مكرر",
        Move = "نقل",
        Save = "حفظ",
        Undo = "تراجع",
        Download = "تحميل",
        DownloadAll = "تحميل الكل",
        Edit = "تعديل",
        
        -- المحرر
        ScriptEditor = "محرر السكريبت",
        ImageEditor = "محرر الصور",
        SoundEditor = "محرر الأصوات",
        Properties = "الخصائص",
        
        -- الصوت
        Play = "تشغيل",
        Stop = "إيقاف",
        Volume = "مستوى الصوت",
        Pitch = "السرعة",
        Loop = "تكرار",
        
        -- الأخطاء
        Error = "خطأ",
        ErrorType = "النوع",
        ErrorFile = "الملف",
        ErrorLine = "السطر",
        ErrorDetails = "التفاصيل",
        ErrorSolution = "الحل المقترح",
        ErrorUndo = "تراجع",
        ErrorIgnore = "تجاهل",
        ErrorCopy = "نسخ الخطأ",
        
        -- الفلاتر
        All = "الكل",
        Scripts = "السكريبتات",
        Models = "الموديلات",
        Sounds = "الأصوات",
        Images = "الصور",
        GUI = "الواجهات",
        
        -- تأكيد
        ConfirmDelete = "هل أنت متأكد من الحذف؟",
        Yes = "نعم",
        No = "لا",
        
        -- تنبيهات
        Copied = "تم النسخ!",
        Saved = "تم الحفظ!",
        Deleted = "تم الحذف!",
        Modified = "تم التعديل!",
        Protected = "سكريبت محمي",
        
        -- الإعدادات
        Language = "اللغة",
        Arabic = "العربية",
        English = "English",
    }
}

return Language
