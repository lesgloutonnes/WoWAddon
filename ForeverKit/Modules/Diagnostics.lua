local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {},
}

local function Dump(label, value)
    print(format("  |cffffd200%s|r %s", label, tostring(value)))
end

function module:Run()
    print("|cff00ccff" .. L.DEBUG_HEADER .. "|r")
    ns.Printf(L.DEBUG_VERSION, ns.VERSION)

    local version, build, buildDate, toc = "?", "?", "?", "?"
    if GetBuildInfo then
        version, build, buildDate, toc = GetBuildInfo()
    end
    ns.Printf(L.DEBUG_BUILD, tostring(version), tostring(build), tostring(buildDate))
    ns.Printf(L.DEBUG_TOC, tostring(toc))
    ns.Printf(L.DEBUG_LOCALE, tostring(GetLocale and GetLocale() or "?"))
    ns.Printf(L.DEBUG_PROJECT, tostring(_G.WOW_PROJECT_ID or "?"))

    Dump("LE_EXPANSION_LEVEL_CURRENT", _G.LE_EXPANSION_LEVEL_CURRENT)
    Dump("IsInInstance", IsInInstance and select(2, IsInInstance()) or "?")

    if C_CVar and C_CVar.GetCVar then
        Dump("portal", C_CVar.GetCVar("portal"))
    end

    local mapID = ns.SafeCall(C_Map.GetBestMapForUnit, "player")
    local mapName = mapID and ns.SafeCall(C_Map.GetMapInfo, mapID)
    if type(mapName) == "table" then
        mapName = mapName.name
    end
    ns.Printf(L.DEBUG_MAP, tostring(mapName or "?"), tostring(mapID or "?"))

    if mapID then
        local pos = ns.SafeCall(C_Map.GetPlayerMapPosition, mapID, "player")
        if pos and pos.GetXY then
            local x, y = pos:GetXY()
            x = ns.Reveal(x)
            y = ns.Reveal(y)
            if x and y then
                ns.Printf(L.DEBUG_POS, x * 100, y * 100)
            else
                print("  " .. L.COORDS_UNAVAILABLE)
            end
        else
            print("  " .. L.COORDS_UNAVAILABLE)
        end
    end

    ns.Printf(L.DEBUG_SECRETS, tostring(ns.AreAurasRestricted()))
    Dump("issecretvalue exists", issecretvalue ~= nil)
    Dump("canaccessvalue exists", canaccessvalue ~= nil)
    Dump("TooltipDataProcessor", TooltipDataProcessor ~= nil)
    Dump("C_Container", C_Container ~= nil)
    Dump("C_Item", C_Item ~= nil)
    Dump("C_Mail", C_Mail ~= nil)
    Dump("Settings API", Settings ~= nil)
    print("|cffaaaaaa" .. L.DEBUG_FLAVOR .. "|r")
end

function module:IsEnabled()
    return true
end

function module:Enable()
end

addon:RegisterModule("Diagnostics", module)
