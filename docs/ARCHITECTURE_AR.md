# ◈ WiliExplorer — المعمارية والترابط والعيوب (وثيقة المطوّر)

> الإصدار 7.0.0 — مراجعة شاملة لبنية المشروع: خريطة الملفات، تدفق التحميل، الترابط بين الوحدات، والعيوب التي تم رصدها وإصلاحها.

---

## 1. نظرة عامة

**WiliExplorer** هو مستكشف بصري لتجارب Roblox مكتوب بلغة Luau، يُشغَّل عبر `loadstring(game:HttpGet(...))` داخل Executor. الواجهة تعمل بالكامل من جانب العميل (LocalScript بيئة) وتُبنى برمجياً من `Instance.new` دون أي ملفات UI خارجية.

- **الإصدار:** 7.0.0 (التطوير الشامل)
- **اللغة الافتراضية:** العربية (مع دعم إنجليزي كامل + RTL)
- **النمط:** ثيمات متعددة (Space افتراضي) من `Theme/Colors.lua`
- **التحميل:** `src/Loader.lua` يجلب الوحدات بالترتيب من `Config.Modules` مع cache محلي وتقرير أخطاء

---

## 2. خريطة الملفات والترابط

### 2.1 نقطة الدخول والتحميل

| الملف | الدور | الترابط |
|---|---|---|
| `src/Loader.lua` | Bootstrap: يجلب `Config.lua` أولاً ثم كل الوحدات المدرجة في `Config.Modules` بالترتيب (Theme → Utils → Security → Core → UI)، ويخزّنها في `_G.WiliModules`، ويطبّق إعدادات SaveSystem المحفوظة، ثم يستدعي `MainFrame.Create()` | يعتمد على `Config` فقط بشكل صريح؛ كل الوحدات تُحمَّل بالاسم عبر المجلدات المحددة |
| `src/Config.lua` | مصدر الحقيقة: الإصدار، الإعدادات الافتراضية، الأمان، وقائمة `Modules` (ما الذي يُحمَّل وما لا يُحمَّل) | تقرأه `Loader` و`MainFrame` (للأمان) |

**قاعدة ذهبية:** أي وحدة ليست في `Config.Modules` لن تُحمَّل ولن تكون في `_G.WiliModules`. الوحدات تحصل على بعضها عبر `_G.WiliModules` حصراً (ممنوع `game:HttpGet` داخل وحدات UI — يفرضها `tools/check-lua.js`).

### 2.2 الطبقات

```
Loader ──► Config ──► Theme   (Colors, Assets, Animations, Stars)
                     ├─ Utils  (Language, Icons, Highlighter, DesignSystem,
                     │          UIHelpers, HTTP, JSON*, SaveSystem, Logger, Lifecycle)
                     ├─ Security (KeySystem, HWID)
                     ├─ Core   (FileScanner, GameAnalyzer, PropertyEditor)
                     └─ UI     (MainFrame → Sidebar → TreeView → FileViewer,
                                KlimboMenu, AnalyzerUI, ContextMenu, ImageEditor,
                                SoundEditor, PropertiesPanel, Notifications,
                                SearchBar, ErrorPopup)
```

### 2.3 المسار الرئيسي للمستخدم

1. `MainFrame.Create()` يبني الإطار، شريط الأدوات (TopControls)، شاشة المفتاح، وشاشة المستكشف.
2. `Sidebar.Create()` يرسم بطاقات الخدمات (Workspace, Players, ...).
3. النقر على خدمة → `TreeView.Create(parent, service, onBack)` — شجرة تفاعلية.
4. النقر على عنصر → `FileViewer.Open(parent, instance, onClose)` — العارض الشامل v7.
5. `KlimboMenu.Create()` — وحدة المطوّر (فحص، أداء، إعدادات).

### 2.4 أهم الوحدات

| الملف | الوظيفة |
|---|---|
| `Core/FileScanner.lua` (2489 سطر) | قلب المشروع: `TypeData` لأكثر من 120 نوع (أيقونة/لون/فئة/صلاحيات)، `GetInfo`/`GetBasicInfo` (بيانات غنية لكل نوع)، `GetSource` (5 طرق قراءة)، `SetSource`، `Search` (DFS مجزّأ قابل للإلغاء)، `Clone`/`Delete`/`GetStats` |
| `UI/FileViewer.lua` (v7) | **العارض الشامل**: معاينة حقيقية لكل نوع — كود ملوّن، مشغّل صوت، معاينة صورة/فيديو، ViewportFrame ثلاثي الأبعاد للمجسمات، حركات، واجهات GUI، تأثيرات، إضاءة، قيم، اتصالات + تبويب خصائص قابل للتعديل + تبويب عناصر فرعية |
| `UI/MainFrame.lua` | الإطار الرئيسي + شريط أدوات مرتب بـ `UIListLayout` (بلا مواضع عشوائية) + تلميحات + نظام استجابة تلقائي |
| `UI/TreeView.lua` (v3) | شجرة بأيقونات منفصلة، 13 فلتر فئة، فرز (اسم/نوع)، قائمة سياق بالضغط المطوّل، زر فتح لكل صف |
| `Utils/Language.lua` | قاموس ar/en مركزي + `Get`/`Toggle`/`Set`/`IsRTL`/`Apply` (تطبيق اتجاه RTL على كل النصوص) |
| `Utils/Icons.lua` (v2) | سجل الأيقونات المركزي: أيقونة لكل `ClassName` + أيقونات أفعال + `Place`/`DecorateButton` لفصل الأيقونة عن النص |
| `Utils/Highlighter.lua` | تلوين Lua كامل → RichText + أرقام أسطر + إحصائيات |
| `Utils/DesignSystem.lua` | Tokens التصميم + الاستجابة (Breakpoints) + أوليات UI |
| `Theme/Animations.lua` | مكتبة تأثيرات (Fade/Slide/Bounce/Pulse/Shake/Typewriter...) — **كانت غير محمّلة قبل v7!** |
| `Security/KeySystem.lua` | تحقق خادمي اختياري (Endpoint) — بدون مفاتيح في المستودع |

### 2.5 ملفات أدوات المطوّر (خارج Lua)

| الملف | الدور |
|---|---|
| `tools/check-lua.js` | فحص luaparse + قواعد سياسة (لا HttpGet في UI، لا spawn/wait، لا ملفات قديمة، لا Fire على RBXScriptSignal...) |
| `tools/check-lua-strict.js` | **جديد v7:** فحص صارم بترجمة Lua 5.3 حقيقية (fengari) يلتقط ما يتساهل فيه luaparse |
| `tools/build_manifest.py` | Manifest بتوقيعات SHA-256 لكل ملفات src |
| `tools/github-actions-validate.yml` | CI: npm install → check → build |
| `package.json` | `npm run check` = الفحصان معاً |

---

## 3. العيوب التي تم رصدها وإصلاحها في v7.0.0

### 3.1 العارض يقرأ أنواعاً قليلة فقط ("سيء جداً... صورة وأصوات فقط")
**قبل:** `FileViewer` كان يعرض شاشة معلومات ثابتة لكل الأنواع، ويفتح محررات منفصلة فقط للسكربتات والأصوات والصور والقيم. المجسمات والحركات والفيديو والواجهات والتأثيرات والإضاءة كلها كانت "معلومات قليلة".
**بعد:** عارض شامل بمعاينة مخصصة لكل فئة (انظر §2.4)، وكل نافذة معاينة تعيد `cleanup` function تُستدعى عند الإغلاق (Heartbeat، أصوات، Tracks، نسخ GUI).

### 3.2 تشابك الكلمات والحروف والأيقونات مع النص (RTL)
**قبل:** أنماط مثل `"🔓 " .. Verify` و`"🌐 عربي"` و`icon .. "  " .. text` داخل نفس `TextLabel` — مع اتجاه RTL تختلط الأيقونة بالكلمة وتنعكس.
**بعد:**
- أيقونة دائماً في `TextLabel` مستقل (قاعدة مفروضة في كل الواجهات الجديدة).
- `KlimboMenu.translate` يفصل الأيقونة تلقائياً في `WiliIcon` مستقل.
- أزرار تسجيل الدخول واللغة والـ DEV والمحررات كلها أيقونة + نص منفصلان.
- الكود يبقى LTR دائماً حتى في الواجهة العربية (تمرير إجباري بعد `Language.Apply`).

### 3.3 الأزرار عشوائية المواضع ("الأزرار عشوائية وليس في مكانها")
**قبل:** مواضع ثابتة بالبكسل من اليمين (`1, -350`، `1, -250`، `1, -165`...) تتداخل فعلياً عند عرض UserInfo (تداخل ~20px بين DEV واللغة) وعلى الشاشات الصغيرة.
**بعد:** حاوية `TopControls` مع `UIListLayout` (ترتيب تلقائي بلا تداخل أبداً) + أحجام موحدة + تلميحات (Tooltips) + حالات Hover/Press. الوضع compact يقلّص الأزرار بدل إزاحتها.

### 3.4 لا يوجد أيقونات أو صور للأزرار
**بعد:** كل زر في المشروع أصبح بأيقونة مستقلة: زر رجوع، فرز، فلاتر، إغلاق، تصغير، نسخ، حذف... من سجل `Icons` المركزي.

### 3.5 "ينقصه الحياة" — الواجهة جامدة
**قبل:** وحدة `Animations` موجودة لكنها **ليست في `Config.Modules`** — لم تكن تُحمَّل أصلاً! كثير من الوحدات الميتة كذلك.
**بعد:**
- `Animations` محمّلة ومستخدمة: دخول متتابع لبطاقات Sidebar، حركة دخول نافذة العارض، نبض Stroke زر DEV.
- Hover/Press animated على كل الأزرار والصفوف (شجرة، عارض، قوائم).
- انتقال متحرك بين التبويبات.

### 3.6 وحدات ميتة / غير محمّلة (اكتشاف معماري)
| الوحدة | الحالة قبل v7 | الإجراء |
|---|---|---|
| `Theme/Animations.lua` | غير محمّلة | أُضيفت لـ Config وأصبحت مستخدمة |
| `Core/PropertyEditor.lua` | غير محمّلة | أُضيفت وأصبحت قلب تبويب الخصائص في العارض |
| `UI/ContextMenu.lua` | محمّلة لكن لا أحد يستخدمها | موصولة الآن بضغط مطوّل في TreeView |
| `UI/PropertiesPanel.lua` | محمّلة لكن ميتة | استُبدلت بتبويب خصائص مدمج (أفضل UX) |
| `UI/SearchBar.lua`، `UI/ErrorPopup.lua`، `Utils/HTTP.lua`، `Utils/Logger.lua`، `Utils/Lifecycle.lua` | محمّلة وغير مستخدمة مباشرة | تركت محمّلة للتوافق/أدوات مستقبلية — موثقة |
| `UI/ContentPanel.lua`، `UI/TopBar.lua`، `UI/KeyScreen.lua`، `Core/FileActions.lua`، `Core/FileEditor.lua`، `Core/TreeBuilder.lua`، `Utils/JSON.lua`، `Theme/Fonts.lua` | غير محمّلة أصلاً (خارج Config) | تركت كما هي كخيارات توسعة — موثقة |

### 3.7 أخطاء ملموسة أُصلحت
- **`Theme/Assets.lua`:** `Assets.Apply` كان سطراً واحداً ملغزاً (`imageObject.Image = asset imageObject.Visible = true return true end`) — يعمل لكن غير قابل للصيانة؛ أُعيد تنسيقه.
- **استنساخ عناصر خطرة:** العارض القديم لا يمنع استنساخ Workspace/الخدمات في المعاينة؛ v7 يمنع `DataModel`/`game`/`workspace` ويفرض سقف 800 عنصر.
- **سكربتات النسخ المعاينة:** أي نسخة للعرض تمر عبر `StripScripts` (إزالة سكربتات + إيقاف الأصوات) حتى لا تُنفَّذ أو تشغَّل أثناء المعاينة.
- **أزرار محرر الكود القديمة:** كانت مواضعها مطلقة (`1,-390` حتى `1,-75`) — استُبدلت بشريط أدوات مرتب.
- **تصلّب فلاتر TreeView:** 6 فلاتر فقط (all/script/model/image/sound/value) — الآن 13 فلتراً تغطي كل فئات `FileScanner`.

### 3.8 ملاحظات للمطوّر (عيوب متبقية مقصودة/معروفة)
- `TreeView.UpdateCanvasSize` يستخدم `task.wait()` لإعادة قياس الـ Canvas بعد الإدراج — يعمل لكن يُفضَّل لاحقاً ربط `AbsoluteContentSize`.
- `FileScanner.GetInfo` يقرأ الخصائص عند كل فتح — ثقيل على عناصر ضخمة؛ يمكن إضافة cache بمفتاح `Instance + tick`.
- فلاتر البحث في TreeView تعيد المسح عند كل حرف — يوجد إلغاء عبر `searchGeneration` لكن لا debounce.
- `ContextMenu` تبني `ScreenGui` مستقلة في CoreGui — لا تشارك ثيم العارض الرئيسي بعد.

---

## 4. اصطلاحات التطوير

1. **الاعتماديات:** `_G.WiliModules` فقط داخل UI/Core؛ `game:HttpGet` ممنوع (يفحصه CI).
2. **الأيقونات:** من `Icons` وفي Label مستقل دائماً.
3. **النصوص:** كلها عبر `Language.Get` (ar + en) — لا نصوص إنجليزية مكتوبة مباشرة في الواجهات الجديدة.
4. **الأمان:** لا `spawn`/`wait` (استخدم `task.*`)، لا `Signal:Fire()`، لا ملفات أمنية قديمة (يفحصها CI).
5. **الفحص قبل الدفع:** `npm run check` يشغّل luaparse + الفحص الصارم.
6. **التنظيف:** كل معاينة تعيد `cleanup` تُفصل الاتصالات والأصوات والـ Tracks عند الإغلاق.
7. **الاستجابة:** أهداف لمس ≥44px حيث أمكن، الأوضاع عبر `Design.GetMode()`.

## 5. كيف تشغّل وتختبر

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/WiliExplorer/main/src/Loader.lua"))()
```

محلياً (أدوات):
```bash
npm install
npm run check   # فحص الصياغة + السياسات + الفحص الصارم
npm run build   # manifest مع SHA-256
```

> © 2026 WiliExplorer — v7.0.0
