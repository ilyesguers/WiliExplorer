--[[
    ═══════════════════════════════════════════════════════════════════════════
    🎨 WiliExplorer - Syntax Highlighter v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ تلوين Syntax لغة Lua
    ✅ أرقام الأسطر
    ✅ تمييز الكلمات المفتاحية
    ✅ تمييز النصوص
    ✅ تمييز التعليقات
    ✅ تمييز الأرقام
    ✅ متوافق مع الهاتف
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local Highlighter = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 ألوان التلوين
-- ═══════════════════════════════════════════════════════════════════════
local Theme = {
    -- الكلمات المفتاحية
    keywords = Color3.fromRGB(255, 130, 200),      -- وردي
    -- الدوال المدمجة
    builtins = Color3.fromRGB(100, 200, 255),       -- أزرق فاتح
    -- النصوص
    strings = Color3.fromRGB(200, 255, 100),        -- أخضر فاتح
    -- التعليقات
    comments = Color3.fromRGB(100, 110, 140),       -- رمادي
    -- الأرقام
    numbers = Color3.fromRGB(255, 200, 100),        -- برتقالي
    -- العمليات
    operators = Color3.fromRGB(255, 255, 255),      -- أبيض
    -- القيم الخاصة
    booleans = Color3.fromRGB(255, 130, 200),       -- وردي
    -- nil
    nilValue = Color3.fromRGB(255, 130, 200),       -- وردي
    -- المتغيرات
    variables = Color3.fromRGB(220, 220, 255),      -- أبيض مائل للأزرق
    -- النص العادي
    default = Color3.fromRGB(220, 230, 255),        -- أبيض مائل للأزرق
    -- خلفية
    background = Color3.fromRGB(15, 15, 30),        -- أزرق غامق
    -- أرقام الأسطر
    lineNumbers = Color3.fromRGB(80, 90, 120),      -- رمادي
    -- الخط المحدد
    currentLine = Color3.fromRGB(25, 25, 50),       -- أزرق أغمق
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📝 الكلمات المفتاحية
-- ═══════════════════════════════════════════════════════════════════════
local Keywords = {
    ["and"] = true, ["break"] = true, ["do"] = true, ["else"] = true,
    ["elseif"] = true, ["end"] = true, ["false"] = true, ["for"] = true,
    ["function"] = true, ["if"] = true, ["in"] = true, ["local"] = true,
    ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true,
    ["return"] = true, ["then"] = true, ["true"] = true, ["until"] = true,
    ["while"] = true, ["continue"] = true, ["self"] = true
}

local Builtins = {
    -- Roblox Services
    ["game"] = true, ["workspace"] = true, ["Workspace"] = true,
    ["Instance"] = true, ["Vector3"] = true, ["Vector2"] = true,
    ["CFrame"] = true, ["Color3"] = true, ["BrickColor"] = true,
    ["UDim2"] = true, ["UDim"] = true, ["Enum"] = true,
    ["TweenInfo"] = true, ["Rect"] = true, ["NumberRange"] = true,
    ["NumberSequence"] = true, ["NumberSequenceKeypoint"] = true,
    ["ColorSequence"] = true, ["ColorSequenceKeypoint"] = true,
    
    -- Roblox Functions
    ["print"] = true, ["warn"] = true, ["error"] = true,
    ["type"] = true, ["typeof"] = true, ["tostring"] = true,
    ["tonumber"] = true, ["pcall"] = true, ["xpcall"] = true,
    ["require"] = true, ["spawn"] = true, ["delay"] = true,
    ["wait"] = true, ["task"] = true, ["coroutine"] = true,
    ["string"] = true, ["table"] = true, ["math"] = true,
    ["os"] = true, ["pairs"] = true, ["ipairs"] = true,
    ["next"] = true, ["select"] = true, ["unpack"] = true,
    ["rawget"] = true, ["rawset"] = true, ["setmetatable"] = true,
    ["getmetatable"] = true, ["loadstring"] = true,
    
    -- Executor Functions
    ["hookfunction"] = true, ["hookmetamethod"] = true,
    ["newcclosure"] = true, ["islclosure"] = true,
    ["getrawmetatable"] = true, ["setreadonly"] = true,
    ["getnamecallmethod"] = true, ["checkcaller"] = true,
    ["getscriptbytecode"] = true, ["decompile"] = true,
    ["getscripthash"] = true, ["getconnections"] = true,
    ["firesignal"] = true, ["setclipboard"] = true,
    ["getclipboard"] = true, ["messagebox"] = true,
    ["setfpscap"] = true, ["getfpscap"] = true,
    ["rconsoleprint"] = true, ["rconsoleclear"] = true,
    ["rconsolename"] = true, ["rconsoleinput"] = true,
    ["writefile"] = true, ["readfile"] = true,
    ["isfile"] = true, ["isfolder"] = true,
    ["makefolder"] = true, ["delfolder"] = true,
    ["delfile"] = true, ["loadfile"] = true,
    ["listfiles"] = true, ["HttpGet"] = true,
    ["HttpGetAsync"] = true, ["HttpPost"] = true,
    ["HttpPostAsync"] = true,
    
    -- Drawing
    ["Drawing"] = true, ["DrawingNew"] = true,
}

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 تلوين النص
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.Highlight(code)
    if not code or code == "" then return {} end
    
    local tokens = {}
    local i = 1
    local len = #code
    
    while i <= len do
        local char = code:sub(i, i)
        
        -- تعليق سطر واحد
        if code:sub(i, i + 1) == "--" then
            local endPos = code:find("\n", i) or (len + 1)
            local comment = code:sub(i, endPos - 1)
            table.insert(tokens, {text = comment, color = Theme.comments})
            i = endPos
            
        -- تعليق متعدد الأسطر
        elseif code:sub(i, i + 3) == "--[[" then
            local endPos = code:find("]]", i + 4)
            if endPos then
                local comment = code:sub(i, endPos + 1)
                table.insert(tokens, {text = comment, color = Theme.comments})
                i = endPos + 2
            else
                local comment = code:sub(i)
                table.insert(tokens, {text = comment, color = Theme.comments})
                i = len + 1
            end
            
        -- نص بعلامات اقتباس مزدوجة
        elseif char == '"' then
            local endPos = i + 1
            while endPos <= len do
                local c = code:sub(endPos, endPos)
                if c == '"' then break end
                if c == "\\" then endPos = endPos + 1 end -- تجاوز escape
                endPos = endPos + 1
            end
            local str = code:sub(i, endPos)
            table.insert(tokens, {text = str, color = Theme.strings})
            i = endPos + 1
            
        -- نص بعلامات اقتباس مفردة
        elseif char == "'" then
            local endPos = i + 1
            while endPos <= len do
                local c = code:sub(endPos, endPos)
                if c == "'" then break end
                if c == "\\" then endPos = endPos + 1 end
                endPos = endPos + 1
            end
            local str = code:sub(i, endPos)
            table.insert(tokens, {text = str, color = Theme.strings})
            i = endPos + 1
            
        -- أرقام
        elseif char:match("%d") then
            local num = code:match("^%d+%.?%d*[eE]?[+-]?%d*", i)
            if num then
                table.insert(tokens, {text = num, color = Theme.numbers})
                i = i + #num
            else
                table.insert(tokens, {text = char, color = Theme.default})
                i = i + 1
            end
            
        -- كلمات (متغيرات، كلمات مفتاحية)
        elseif char:match("[%a_]") then
            local word = code:match("^[%w_]+", i)
            if word then
                local color
                if Keywords[word] then
                    color = Theme.keywords
                elseif Builtins[word] then
                    color = Theme.builtins
                elseif word == "true" or word == "false" then
                    color = Theme.booleans
                elseif word == "nil" then
                    color = Theme.nilValue
                else
                    color = Theme.variables
                end
                table.insert(tokens, {text = word, color = color})
                i = i + #word
            else
                table.insert(tokens, {text = char, color = Theme.default})
                i = i + 1
            end
            
        -- العمليات
        elseif char:match("[%+%-%*%/%%%^%=%~%<%>%#%:%.]") then
            table.insert(tokens, {text = char, color = Theme.operators})
            i = i + 1
            
        -- مسافات وأسطر
        elseif char:match("%s") then
            table.insert(tokens, {text = char, color = Theme.default})
            i = i + 1
            
        -- أحرف خاصة
        else
            table.insert(tokens, {text = char, color = Theme.default})
            i = i + 1
        end
    end
    
    return tokens
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📄 إنشاء نص Rich Text
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.ToRichText(code)
    local tokens = Highlighter.Highlight(code)
    local result = ""
    
    for _, token in ipairs(tokens) do
        local r = math.floor(token.color.R * 255)
        local g = math.floor(token.color.G * 255)
        local b = math.floor(token.color.B * 255)
        
        -- تهريب أحرف HTML
        local text = token.text
            :gsub("&", "&amp;")
            :gsub("<", "&lt;")
            :gsub(">", "&gt;")
        
        result = result .. string.format(
            '<font color="rgb(%d, %d, %d)">%s</font>',
            r, g, b, text
        )
    end
    
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔢 إنشاء أرقام الأسطر
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.GetLineNumbers(code)
    if not code or code == "" then return "" end
    
    local lines = 1
    for _ in code:gmatch("\n") do
        lines = lines + 1
    end
    
    local result = ""
    for i = 1, lines do
        if i > 1 then result = result .. "\n" end
        result = result .. tostring(i)
    end
    
    return result
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 إحصائيات الكود
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.GetStats(code)
    if not code then return {} end
    
    local lines = 1
    for _ in code:gmatch("\n") do lines = lines + 1 end
    
    local chars = #code
    local words = 0
    for _ in code:gmatch("%S+") do words = words + 1 end
    
    local comments = 0
    for _ in code:gmatch("%-%-[^%[%]].*") do comments = comments + 1 end
    for _ in code:gmatch("%-%-%[%[.-%]%]") do comments = comments + 1 end
    
    local strings = 0
    for _ in code:gmatch('"[^"]*"') do strings = strings + 1 end
    for _ in code:gmatch("'[^']*'") do strings = strings + 1 end
    
    local functions = 0
    for _ in code:gmatch("function%s") do functions = functions + 1 end
    
    return {
        lines = lines,
        characters = chars,
        words = words,
        comments = comments,
        strings = strings,
        functions = functions
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 بحث في الكود
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.FindInCode(code, query, caseSensitive)
    if not code or not query then return {} end
    
    local results = {}
    local searchCode = caseSensitive and code or code:lower()
    local searchQuery = caseSensitive and query or query:lower()
    
    local startPos = 1
    while startPos <= #searchCode do
        local pos = searchCode:find(searchQuery, startPos, true)
        if not pos then break end
        
        -- حساب رقم السطر
        local line = 1
        for i = 1, pos - 1 do
            if code:sub(i, i) == "\n" then line = line + 1 end
        end
        
        table.insert(results, {
            position = pos,
            line = line,
            text = code:sub(pos, pos + #query - 1)
        })
        
        startPos = pos + 1
    end
    
    return results
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 استبدال في الكود
-- ═══════════════════════════════════════════════════════════════════════
function Highlighter.ReplaceInCode(code, find, replace, caseSensitive)
    if not code or not find then return code end
    
    if caseSensitive then
        return code:gsub(find, replace)
    else
        -- Lua doesn't have case-insensitive gsub by default
        local result = code
        local lowerCode = code:lower()
        local lowerFind = find:lower()
        local offset = 0
        
        local startPos = 1
        while startPos <= #lowerCode do
            local pos = lowerCode:find(lowerFind, startPos, true)
            if not pos then break end
            
            local before = result:sub(1, pos - 1 + offset)
            local after = result:sub(pos + #find + offset)
            result = before .. replace .. after
            offset = offset + #replace - #find
            
            startPos = pos + 1
        end
        
        return result
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 Themes إضافية
-- ═══════════════════════════════════════════════════════════════════════
Highlighter.Themes = {
    default = Theme,
    
    dark = {
        keywords = Color3.fromRGB(255, 85, 85),
        builtins = Color3.fromRGB(130, 170, 255),
        strings = Color3.fromRGB(152, 195, 121),
        comments = Color3.fromRGB(92, 99, 112),
        numbers = Color3.fromRGB(209, 154, 102),
        operators = Color3.fromRGB(198, 120, 221),
        booleans = Color3.fromRGB(209, 154, 102),
        default = Color3.fromRGB(171, 178, 191),
        background = Color3.fromRGB(30, 30, 30),
        lineNumbers = Color3.fromRGB(76, 80, 88)
    },
    
    light = {
        keywords = Color3.fromRGB(175, 42, 128),
        builtins = Color3.fromRGB(75, 110, 175),
        strings = Color3.fromRGB(82, 140, 50),
        comments = Color3.fromRGB(128, 128, 128),
        numbers = Color3.fromRGB(150, 100, 50),
        operators = Color3.fromRGB(120, 80, 150),
        booleans = Color3.fromRGB(175, 42, 128),
        default = Color3.fromRGB(50, 50, 50),
        background = Color3.fromRGB(245, 245, 245),
        lineNumbers = Color3.fromRGB(180, 180, 180)
    },
    
    ocean = {
        keywords = Color3.fromRGB(255, 120, 200),
        builtins = Color3.fromRGB(100, 200, 255),
        strings = Color3.fromRGB(150, 255, 150),
        comments = Color3.fromRGB(80, 100, 130),
        numbers = Color3.fromRGB(255, 200, 100),
        operators = Color3.fromRGB(200, 150, 255),
        booleans = Color3.fromRGB(255, 120, 200),
        default = Color3.fromRGB(200, 220, 255),
        background = Color3.fromRGB(10, 20, 40),
        lineNumbers = Color3.fromRGB(60, 80, 110)
    }
}

-- تغيير الثيم
function Highlighter.SetTheme(themeName)
    if Highlighter.Themes[themeName] then
        Theme = Highlighter.Themes[themeName]
    end
end

print("🎨 Syntax Highlighter v1.0 Loaded!")

return Highlighter
