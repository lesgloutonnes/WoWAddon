local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        xpRested = true,
    },
    settings = {
        { key = "xpRested", name = "XP_RESTED", desc = "XP_RESTED_DESC" },
    },
}

local text
local frame

local function Abbrev(n)
    n = tonumber(n) or 0
    if n >= 1000000 then
        return format("%.1fM", n / 1000000)
    end
    if n >= 10000 then
        return format("%.1fk", n / 1000)
    end
    return tostring(n)
end

local function Update()
    if not text or not addon:Get("xpRested") then
        return
    end
    local xp = ns.Reveal(UnitXP("player"))
    local max = ns.Reveal(UnitXPMax("player"))
    if not xp or not max or max <= 0 then
        text:SetText("")
        return
    end
    local pct = (xp / max) * 100
    local line = format(L.XP_TEXT, Abbrev(xp), Abbrev(max), pct)
    local rested = GetXPExhaustion and ns.Reveal(GetXPExhaustion()) or 0
    if rested and rested > 0 then
        line = line .. "   " .. format(L.XP_RESTED_TEXT, Abbrev(rested), (rested / max) * 100)
    else
        line = line .. "   " .. L.XP_RESTED_NONE
    end
    text:SetText(line)
end

function module:IsEnabled()
    return addon:Get("xpRested")
end

function module:Enable()
    if not text then
        text = UIParent:CreateFontString("ForeverKitXP", "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 28)
        text:SetTextColor(0.6, 0.85, 1)
    end
    text:Show()
    if not frame then
        frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("PLAYER_XP_UPDATE")
        frame:RegisterEvent("PLAYER_LEVEL_UP")
        frame:RegisterEvent("UPDATE_EXHAUSTION")
        frame:SetScript("OnEvent", Update)
    else
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("PLAYER_XP_UPDATE")
        frame:RegisterEvent("PLAYER_LEVEL_UP")
        frame:RegisterEvent("UPDATE_EXHAUSTION")
    end
    Update()
end

function module:Disable()
    if text then
        text:Hide()
    end
    if frame then
        frame:UnregisterAllEvents()
    end
end

addon:RegisterModule("XP", module)
