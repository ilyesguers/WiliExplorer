local Language = {
    en = {
        AppName = "WiliExplorer", Version = "Responsive v6", LanguageCode = "EN",
        EnterKey = "Enter your access key", Verify = "Continue", Verifying = "Checking…",
        Launching = "Opening workspace…", Invalid = "That key is not valid", Welcome = "Explore every layer of your experience",
        Explorer = "Explorer", Services = "Game services", SelectService = "Choose a service to start exploring",
        Items = "items", Loading = "Loading…", Close = "Close", Minimize = "Minimize", Language = "العربية",
        Back = "Back", Search = "Search by name, class or path…", NoItems = "No matching items",
        Files = "Files", Folders = "Folders", Total = "Total", All = "All", Filter = "Filter",
        Sort = "Sort", Name = "Name", Type = "Type", Path = "Path", Recent = "Recent",
        Images = "Images", Sounds = "Sounds", Models = "Models", Scripts = "Scripts", Properties = "Properties",
        Preview = "Preview", Copy = "Copy", Save = "Save", Reset = "Reset", Play = "Play", Pause = "Pause",
        AnalysisWorkspace = "Analysis workspace", AnalysisWorkspaceDescription = "One scanner for diagnostics, assets, values, and performance",
        GameServices = "Game services", DirectItems = "direct items", NavigationFailed = "Could not open page",
        ServiceUnavailable = "This service is unavailable", SearchAll = "Search the complete tree…",
        SearchResults = "Search results", NoSearchResults = "No matching items in this tree", GameAnalyzer = "Game analyzer",
        ScanGame = "Scan experience", ScanningGame = "Scanning experience…",
        ModelEditorDescription = "Model editor and customization", DeepAnalysisDescription = "Deep analysis of assets and values",
        Beta = "Beta", Pro = "Pro", AI = "AI",
        Workspace = "Workspace", Players = "Players", Lighting = "Lighting", ReplicatedStorage = "Replicated Storage",
        ServerStorage = "Server Storage", StarterGui = "Starter GUI", StarterPack = "Starter Pack",
        StarterPlayer = "Starter Player", Teams = "Teams", SoundService = "Sounds",
        MaterialService = "Materials", Chat = "Chat"
    },
    ar = {
        AppName = "ويلي إكسبلورر", Version = "الإصدار المتجاوب 6", LanguageCode = "AR",
        EnterKey = "أدخل مفتاح الوصول", Verify = "متابعة", Verifying = "جارٍ التحقق…",
        Launching = "جارٍ فتح مساحة العمل…", Invalid = "المفتاح غير صالح", Welcome = "استكشف كل طبقات تجربتك",
        Explorer = "المستكشف", Services = "خدمات اللعبة", SelectService = "اختر خدمة لبدء الاستكشاف",
        Items = "عنصر", Loading = "جارٍ التحميل…", Close = "إغلاق", Minimize = "تصغير", Language = "English",
        Back = "رجوع", Search = "ابحث بالاسم أو النوع أو المسار…", NoItems = "لا توجد نتائج مطابقة",
        Files = "ملفات", Folders = "مجلدات", Total = "الإجمالي", All = "الكل", Filter = "تصفية",
        Sort = "ترتيب", Name = "الاسم", Type = "النوع", Path = "المسار", Recent = "الأحدث",
        Images = "صور", Sounds = "أصوات", Models = "مجسمات", Scripts = "سكربتات", Properties = "خصائص",
        Preview = "معاينة", Copy = "نسخ", Save = "حفظ", Reset = "إعادة ضبط", Play = "تشغيل", Pause = "إيقاف مؤقت",
        AnalysisWorkspace = "مساحة التحليل", AnalysisWorkspaceDescription = "محلّل واحد للتشخيص والأصول والقيم والأداء",
        GameServices = "خدمات اللعبة", DirectItems = "عنصر مباشر", NavigationFailed = "تعذّر فتح الصفحة",
        ServiceUnavailable = "هذه الخدمة غير متاحة", SearchAll = "ابحث في الشجرة كاملة…",
        SearchResults = "نتائج البحث", NoSearchResults = "لا توجد نتائج مطابقة في هذه الشجرة", GameAnalyzer = "محلّل اللعبة",
        ScanGame = "فحص التجربة", ScanningGame = "جارٍ فحص التجربة…",
        ModelEditorDescription = "محرر المجسمات وتخصيصها", DeepAnalysisDescription = "تحليل عميق للأصول والقيم",
        Beta = "تجريبي", Pro = "احترافي", AI = "ذكي",
        Workspace = "مساحة العمل", Players = "اللاعبون", Lighting = "الإضاءة", ReplicatedStorage = "التخزين المشترك",
        ServerStorage = "تخزين الخادم", StarterGui = "واجهة البداية", StarterPack = "حقيبة البداية",
        StarterPlayer = "لاعب البداية", Teams = "الفرق", SoundService = "الأصوات",
        MaterialService = "المواد", Chat = "الدردشة"
    }
}

Language.Current = _G.WiliLanguage or "ar"
_G.WiliLanguage = Language.Current

function Language.Get(key, fallback)
    local dictionary = Language[Language.Current] or Language.en
    return dictionary[key] or Language.en[key] or fallback or key
end

function Language.Toggle()
    Language.Current = Language.Current == "ar" and "en" or "ar"
    _G.WiliLanguage = Language.Current
    return Language.Current
end

function Language.Set(code)
    if Language[code] then
        Language.Current = code
        _G.WiliLanguage = code
        return true
    end
    return false
end

function Language.IsRTL()
    return Language.Current == "ar"
end

function Language.Alignment()
    return Language.IsRTL() and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
end

function Language.Apply(root)
    if not root then return end
    local rtl = Language.IsRTL()
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            pcall(function() object.TextDirection = rtl and Enum.TextDirection.RightToLeft or Enum.TextDirection.LeftToRight end)
            -- Preserve intentionally centered icon-only controls.
            if object.TextXAlignment ~= Enum.TextXAlignment.Center or #object.Text > 3 then
                object.TextXAlignment = rtl and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
            end
        end
    end
end

return Language
