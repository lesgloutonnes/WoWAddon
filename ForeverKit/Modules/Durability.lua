local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        durability = true,
    },
    settings = {
        { type = "header", name = "SECTION_CHAR" },
        { key = "durability", name = "DURABILITY", desc = "DURABILITY_DESC" },
    },
}

local SLOTS = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 15, 16, 17, 18 }
local text
local frame
local lastWarn

local function GetDurability()
    local current, max = 0, 0
    for _, slot in ipairs(SLOTS) do
        local cur, mx = GetInventoryItemDurability(slot)
        if cur and mx and mx > 0 and not ns.IsSecret(cur) then
            current = current + cur
            max = max + mx
        end
    end
    if max <= 0 then
        return nil
    end
    return math.floor((current / max) * 100 + 0.5)
end

local function Update()
    if not addon:Get("durability") or not text then
        return
    end
    local pct = GetDurability()
    if not pct then
        text:SetText("")
        return
    end
    local r, g, b = 0.2, 0.9, 0.2
    if pct < 25 then
        r, g, b = 1, 0.2, 0.2
    elseif pct < 50 then
        r, g, b = 1, 0.82, 0
    end
    text:SetFormattedText(L.DURABILITY_LABEL, pct)
    text:SetTextColor(r, g, b)
    if pct < 25 and lastWarn ~= pct then
        lastWarn = pct
        ns.Printf(L.DURABILITY_LOW, pct)
    elseif pct >= 25 then
        lastWarn = nil
    end
end

function module:IsEnabled()
    return addon:Get("durability")
end

function module:Enable()
    if not text then
        local parent = Minimap or UIParent
        text = parent:CreateFontString("ForeverKitDurability", "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("TOP", parent, "BOTTOM", 0, -18)
    end
    text:Show()
    if not frame then
        frame = CreateFrame("Frame")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        frame:RegisterEvent("MERCHANT_CLOSED")
        frame:SetScript("OnEvent", Update)
    else
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        frame:RegisterEvent("MERCHANT_CLOSED")
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

addon:RegisterModule("Durability", module)
