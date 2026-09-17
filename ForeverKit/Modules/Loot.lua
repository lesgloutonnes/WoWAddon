local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        fastLoot = true,
    },
    settings = {
        { type = "header", name = "SECTION_LOOT" },
        { key = "fastLoot", name = "FAST_LOOT", desc = "FAST_LOOT_DESC" },
    },
}

local frame

local function AutoLootEnabled()
    if GetCVarBool then
        return GetCVarBool("autoLootDefault")
    end
    local v = GetCVar and GetCVar("autoLootDefault")
    return v == "1" or v == 1
end

local function FastLoot()
    if not addon:Get("fastLoot") then
        return
    end
    if not AutoLootEnabled() then
        return
    end
    if IsModifiedClick and IsModifiedClick("AUTOLOOTTOGGLE") then
        return
    end
    local n = GetNumLootItems and GetNumLootItems() or 0
    for i = n, 1, -1 do
        if LootSlot then
            LootSlot(i)
        end
    end
end

function module:IsEnabled()
    return addon:Get("fastLoot")
end

function module:Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", FastLoot)
    end
    frame:RegisterEvent("LOOT_READY")
end

function module:Disable()
    if frame then
        frame:UnregisterAllEvents()
    end
end

addon:RegisterModule("Loot", module)
