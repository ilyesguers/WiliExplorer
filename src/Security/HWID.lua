-- Device identity capability wrapper.
-- A UserId fallback is explicitly marked weak; it is never presented as hardware binding.
local HWID = {}

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local cached

local function hashIfAvailable(value)
    local hashed = value
    local ok = pcall(function()
        if crypt and crypt.hash then hashed = crypt.hash(value, "sha256")
        elseif syn and syn.crypt and syn.crypt.hash then hashed = syn.crypt.hash(value) end
    end)
    return ok and hashed or value
end

function HWID.GetInfo()
    if cached then return cached end
    local raw, source, strong = "", "none", false

    pcall(function()
        if gethwid then
            raw = tostring(gethwid() or "")
            source = "gethwid"
            strong = raw ~= ""
        end
    end)

    if raw == "" then
        -- Stable account identity only. This is not hardware identity.
        raw = "ACCOUNT_" .. tostring(LocalPlayer and LocalPlayer.UserId or 0)
        source = "account"
        strong = false
    end

    cached = {
        hwid = hashIfAvailable(raw),
        source = source,
        strong = strong,
        userId = LocalPlayer and LocalPlayer.UserId or 0,
        username = LocalPlayer and LocalPlayer.Name or "Unknown"
    }
    return cached
end

function HWID.GetHWID()
    return HWID.GetInfo().hwid
end

function HWID.Verify(storedHWID, requireStrong)
    local info = HWID.GetInfo()
    if requireStrong and not info.strong then return false, "Strong device identity unavailable" end
    return info.hwid == storedHWID
end

return HWID
