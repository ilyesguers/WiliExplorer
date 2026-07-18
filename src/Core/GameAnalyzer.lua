local GameAnalyzer = {}

function GameAnalyzer.Scan()
    local results = {
        cooldowns = {},
        speeds = {},
        currencies = {},
        remotes = {},
        values = {},
        guis = {},
        tools = {},
        sounds = {},
        scripts = {},
        important = {},
        summary = {
            totalScanned = 0,
            totalEditable = 0,
            totalProtected = 0,
            totalRemotes = 0
        }
    }
    
    local scannedCount = 0
    
    -- الكلمات المفتاحية للكشف
    local cooldownKeywords = {"cooldown", "cool", "cd", "delay", "wait", "timer", "timeout", "debounce", "interval"}
    local speedKeywords = {"speed", "walkspeed", "runspeed", "spd", "velocity", "fast", "slow", "sprint"}
    local currencyKeywords = {"coin", "cash", "money", "gold", "gem", "diamond", "credit", "point", "score", "currency", "buck", "robux", "token", "crystal", "star", "win", "kill", "death", "level", "xp", "exp", "power", "strength", "rebirth", "prestige", "rank", "multiplier", "mult", "boost", "damage", "dmg", "health", "hp", "mana", "energy", "stamina", "armor", "defence", "attack", "atk"}
    local importantKeywords = {"admin", "vip", "premium", "gamepass", "pass", "owner", "ban", "kick", "fly", "noclip", "god", "infinite", "unlimited", "max", "bypass", "anti", "cheat", "exploit", "hack", "teleport", "tp", "invisible", "invis"}
    
    local function MatchesKeywords(name, keywords)
        local lowerName = name:lower()
        for _, keyword in ipairs(keywords) do
            if lowerName:find(keyword) then
                return true, keyword
            end
        end
        return false, nil
    end
    
    local function CanEditValue(instance)
        local success = pcall(function()
            local old = instance.Value
            instance.Value = old
        end)
        return success
    end
    
    local function GetSourceSafe(instance)
        local source = ""
        local readable = false
        pcall(function()
            source = instance.Source
            if source and #source > 0 then
                readable = true
            end
        end)
        if not readable and decompile then
            pcall(function()
                source = decompile(instance)
                if source and #source > 0 then
                    readable = true
                end
            end)
        end
        return source, readable
    end
    
    -- ═══════════════════════════════
    -- فحص كل الخدمات
    -- ═══════════════════════════════
    local servicesToScan = {
        game:GetService("Workspace"),
        game:GetService("Players").LocalPlayer,
        game:GetService("ReplicatedStorage"),
        game:GetService("Lighting"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer")
    }
    
    -- إضافة PlayerGui
    pcall(function()
        local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 2)
        if pg then
            table.insert(servicesToScan, pg)
        end
    end)
    
    -- إضافة Backpack
    pcall(function()
        local bp = game:GetService("Players").LocalPlayer:WaitForChild("Backpack", 2)
        if bp then
            table.insert(servicesToScan, bp)
        end
    end)
    
    -- إضافة Character
    pcall(function()
        local char = game:GetService("Players").LocalPlayer.Character
        if char then
            table.insert(servicesToScan, char)
        end
    end)
    
    for _, service in ipairs(servicesToScan) do
        pcall(function()
            for _, instance in ipairs(service:GetDescendants()) do
                scannedCount = scannedCount + 1
                local name = instance.Name
                
                -- ═══ فحص Values ═══
                if instance:IsA("ValueBase") then
                    local canEdit = CanEditValue(instance)
                    local valStr = ""
                    pcall(function() valStr = tostring(instance.Value) end)
                    
                    local entry = {
                        instance = instance,
                        name = name,
                        className = instance.ClassName,
                        path = instance:GetFullName(),
                        value = valStr,
                        editable = canEdit
                    }
                    
                    table.insert(results.values, entry)
                    
                    if canEdit then
                        results.summary.totalEditable = results.summary.totalEditable + 1
                    end
                    
                    -- تصنيف حسب النوع
                    local isCooldown, cdKey = MatchesKeywords(name, cooldownKeywords)
                    if isCooldown then
                        entry.keyword = cdKey
                        entry.category = "Cooldown"
                        table.insert(results.cooldowns, entry)
                    end
                    
                    local isSpeed, spKey = MatchesKeywords(name, speedKeywords)
                    if isSpeed then
                        entry.keyword = spKey
                        entry.category = "Speed"
                        table.insert(results.speeds, entry)
                    end
                    
                    local isCurrency, curKey = MatchesKeywords(name, currencyKeywords)
                    if isCurrency then
                        entry.keyword = curKey
                        entry.category = "Currency"
                        table.insert(results.currencies, entry)
                    end
                    
                    local isImportant, impKey = MatchesKeywords(name, importantKeywords)
                    if isImportant then
                        entry.keyword = impKey
                        entry.category = "Important"
                        table.insert(results.important, entry)
                    end
                end
                
                -- ═══ فحص RemoteEvents ═══
                if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                    results.summary.totalRemotes = results.summary.totalRemotes + 1
                    
                    local remoteEntry = {
                        instance = instance,
                        name = name,
                        className = instance.ClassName,
                        path = instance:GetFullName(),
                        isEvent = instance:IsA("RemoteEvent"),
                        isFunction = instance:IsA("RemoteFunction")
                    }
                    
                    local isCD, _ = MatchesKeywords(name, cooldownKeywords)
                    local isSP, _ = MatchesKeywords(name, speedKeywords)
                    local isCUR, _ = MatchesKeywords(name, currencyKeywords)
                    local isIMP, _ = MatchesKeywords(name, importantKeywords)
                    
                    remoteEntry.interesting = isCD or isSP or isCUR or isIMP
                    
                    table.insert(results.remotes, remoteEntry)
                end
                
                -- ═══ فحص Scripts ═══
                if instance:IsA("LocalScript") or instance:IsA("ModuleScript") then
                    local source, readable = GetSourceSafe(instance)
                    
                    local scriptEntry = {
                        instance = instance,
                        name = name,
                        className = instance.ClassName,
                        path = instance:GetFullName(),
                        readable = readable,
                        sourceLength = #source,
                        containsCooldown = false,
                        containsSpeed = false,
                        containsCurrency = false,
                        containsRemote = false
                    }
                    
                    if readable then
                        results.summary.totalEditable = results.summary.totalEditable + 1
                        local lowerSrc = source:lower()
                        
                        for _, kw in ipairs(cooldownKeywords) do
                            if lowerSrc:find(kw) then
                                scriptEntry.containsCooldown = true
                                break
                            end
                        end
                        
                        for _, kw in ipairs(speedKeywords) do
                            if lowerSrc:find(kw) then
                                scriptEntry.containsSpeed = true
                                break
                            end
                        end
                        
                        for _, kw in ipairs(currencyKeywords) do
                            if lowerSrc:find(kw) then
                                scriptEntry.containsCurrency = true
                                break
                            end
                        end
                        
                        if lowerSrc:find("remoteevent") or lowerSrc:find("remotefunction") or lowerSrc:find("fireserver") then
                            scriptEntry.containsRemote = true
                        end
                    else
                        results.summary.totalProtected = results.summary.totalProtected + 1
                    end
                    
                    table.insert(results.scripts, scriptEntry)
                end
                
                -- ═══ فحص Tools ═══
                if instance:IsA("Tool") then
                    local toolEntry = {
                        instance = instance,
                        name = name,
                        path = instance:GetFullName()
                    }
                    
                    pcall(function()
                        toolEntry.requiresHandle = instance.RequiresHandle
                        toolEntry.canBeDropped = instance.CanBeDropped
                    end)
                    
                    table.insert(results.tools, toolEntry)
                end
                
                -- ═══ فحص Humanoid (WalkSpeed, JumpPower) ═══
                if instance:IsA("Humanoid") then
                    local humEntry = {
                        instance = instance,
                        name = "Humanoid",
                        path = instance:GetFullName(),
                        editable = true,
                        category = "Speed"
                    }
                    
                    pcall(function()
                        humEntry.walkSpeed = instance.WalkSpeed
                        humEntry.jumpPower = instance.JumpPower
                        humEntry.maxHealth = instance.MaxHealth
                        humEntry.health = instance.Health
                    end)
                    
                    table.insert(results.speeds, humEntry)
                end
            end
        end)
    end
    
    results.summary.totalScanned = scannedCount
    
    return results
end

return GameAnalyzer
