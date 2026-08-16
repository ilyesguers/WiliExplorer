-- WiliExplorer key verification client v2
-- Security note: a public client cannot safely contain signing secrets or authoritative keys.
-- Production verification must be performed by the configured backend.

local KeySystem = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function config()
    local root = _G.WiliConfig or {}
    return root.Security or {}
end

local function hwidModule()
    return _G.WiliModules and _G.WiliModules.HWID or nil
end

local function parseExpiry(value)
    if value == nil or value == "" then return nil end
    if type(value) == "number" then return value end
    if type(value) ~= "string" then return nil end
    local year, month, day, hour, minute, second = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T?(%d?%d?):?(%d?%d?):?(%d?%d?)")
    if not year then return nil end
    return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour) or 0, min = tonumber(minute) or 0, sec = tonumber(second) or 0})
end

function KeySystem.ValidateResponse(data)
    if type(data) ~= "table" then return false, "Malformed verification response" end
    if data.valid ~= true or data.active == false then return false, data.message or "Key rejected" end
    local expiresAt = parseExpiry(data.expiresAt or data.expires)
    if expiresAt and os.time() >= expiresAt then return false, "Key expired" end
    data.expiresAtUnix = expiresAt
    if expiresAt then data.remainingSeconds = math.max(0, expiresAt - os.time()) end
    return true, data
end

function KeySystem.Verify(inputKey)
    inputKey = tostring(inputKey or ""):match("^%s*(.-)%s*$")
    if inputKey == "" then return false, "Empty key" end

    local security = config()
    if RunService:IsStudio() and security.AllowStudioBypass then
        return true, {valid = true, active = true, plan = "studio", owner = Players.LocalPlayer and Players.LocalPlayer.Name or "Developer", studio = true}
    end

    local endpoint = tostring(security.Endpoint or "")
    if endpoint == "" then
        return false, "Verification service is not configured"
    end

    local HWID = hwidModule()
    local device = HWID and HWID.GetInfo and HWID.GetInfo() or {hwid = "unavailable", strong = false}
    local payload = {
        key = inputKey,
        deviceId = device.hwid,
        deviceIdStrong = device.strong == true,
        userId = Players.LocalPlayer and Players.LocalPlayer.UserId or 0,
        placeId = game.PlaceId,
        clientVersion = (_G.WiliConfig and _G.WiliConfig.Version) or "unknown",
        nonce = HttpService:GenerateGUID(false),
        timestamp = os.time()
    }

    local ok, response = pcall(function()
        return game:HttpPost(endpoint, HttpService:JSONEncode(payload), "application/json")
    end)
    if not ok then return false, "Verification service unavailable" end

    local decodedOk, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not decodedOk then return false, "Invalid verification response" end
    return KeySystem.ValidateResponse(data)
end

-- Kept for compatibility; authoritative keys are intentionally never downloaded.
function KeySystem.LoadKeys()
    return {}
end

return KeySystem
