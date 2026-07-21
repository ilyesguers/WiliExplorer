--[[
    ═══════════════════════════════════════════════════════════════════════════
    🌳 WiliExplorer - Tree Builder v1.0
    ═══════════════════════════════════════════════════════════════════════════
    
    ✅ بناء شجرة العناصر
    ✅ ترتيب العناصر
    ✅ فلترة العناصر
    
    ═══════════════════════════════════════════════════════════════════════════
]]

local TreeBuilder = {}

-- ═══════════════════════════════════════════════════════════════════════
-- 🌳 بناء الشجرة
-- ═══════════════════════════════════════════════════════════════════════
function TreeBuilder.Build(instance, maxDepth)
    if not instance then return {} end
    maxDepth = maxDepth or 10
    
    local tree = {
        instance = instance,
        name = instance.Name,
        className = instance.ClassName,
        children = {}
    }
    
    if maxDepth > 0 then
        pcall(function()
            for _, child in ipairs(instance:GetChildren()) do
                table.insert(tree.children, TreeBuilder.Build(child, maxDepth - 1))
            end
        end)
    end
    
    return tree
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🔍 بحث في الشجرة
-- ═══════════════════════════════════════════════════════════════════════
function TreeBuilder.Search(tree, query)
    local results = {}
    
    local function SearchNode(node, depth)
        if node.name:lower():find(query:lower()) then
            table.insert(results, {
                node = node,
                depth = depth
            })
        end
        
        for _, child in ipairs(node.children) do
            SearchNode(child, depth + 1)
        end
    end
    
    SearchNode(tree, 0)
    return results
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📊 إحصائيات
-- ═══════════════════════════════════════════════════════════════════════
function TreeBuilder.GetStats(tree)
    local stats = {
        total = 0,
        byClass = {}
    }
    
    local function CountNode(node)
        stats.total = stats.total + 1
        stats.byClass[node.className] = (stats.byClass[node.className] or 0) + 1
        
        for _, child in ipairs(node.children) do
            CountNode(child)
        end
    end
    
    CountNode(tree)
    return stats
end

print("🌳 Tree Builder v1.0 Loaded!")

return TreeBuilder
