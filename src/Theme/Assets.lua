--[[
    Administrator-managed visual asset manifest.
    Only repository maintainers should change IDs or source paths through reviewed commits.
    Roblox ImageLabel requires uploaded Roblox assets; repository files are source artwork only.
]]
local Assets = {
    Version = 1,
    SourceFolder = "assets/branding/",
    Images = {
        Logo = {asset = "", source = "assets/branding/logo.png", fallback = "◈"},
        Developer = {asset = "", source = "assets/branding/developer.png", fallback = "⌁"},
        Explorer = {asset = "", source = "assets/branding/explorer.png", fallback = "⌘"},
        EmptyState = {asset = "", source = "assets/branding/empty-state.png", fallback = "◇"}
    }
}

function Assets.Get(name)
    local entry = Assets.Images[name]
    if not entry then return nil end
    return entry.asset ~= "" and entry.asset or nil, entry.fallback, entry.source
end

function Assets.Apply(imageObject, name)
    local asset = Assets.Get(name)
    if imageObject and asset then imageObject.Image = asset imageObject.Visible = true return true end
    if imageObject then imageObject.Visible = false end
    return false
end

return Assets
