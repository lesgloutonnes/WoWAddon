local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        mapCoords = true,
        minimapCoords = true,
    },
    settings = {
        { type = "header", name = "SECTION_MAP" },
        { key = "mapCoords", name = "MAP_COORDS", desc = "MAP_COORDS_DESC" },
        { key = "minimapCoords", name = "MINIMAP_COORDS", desc = "MINIMAP_COORDS_DESC" },
    },
}

local minimapText
local worldMapText
local ticker
local lastMapWarning

local function GetPlayerXY()
    if not C_Map or not C_Map.GetBestMapForUnit then
        return nil
    end
    local mapID = ns.SafeCall(C_Map.GetBestMapForUnit, "player")
    if not mapID then
        return nil
    end
    local pos = ns.SafeCall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not pos or not pos.GetXY then
        return nil, nil, mapID
    end
    local x, y = pos:GetXY()
    x, y = ns.Reveal(x), ns.Reveal(y)
    if not x or not y or (x == 0 and y == 0) then
        return nil, nil, mapID
    end
    return x * 100, y * 100, mapID
end

local function GetCursorXY()
    local map = WorldMapFrame
    if not map or not map.IsShown or not map:IsShown() then
        return nil
    end
    local container = map.ScrollContainer
    if container and container.GetNormalizedCursorPosition then
        local x, y = container:GetNormalizedCursorPosition()
        x, y = ns.Reveal(x), ns.Reveal(y)
        if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
            return x * 100, y * 100
        end
    end
    return nil
end

local function FormatPair(label, x, y)
    if not x or not y then
        return nil
    end
    return format(L.COORDS_FORMAT, label, x, y)
end

local function Update()
    local px, py = GetPlayerXY()

    if minimapText then
        if addon:Get("minimapCoords") then
            if px and py then
                minimapText:SetFormattedText("%.1f, %.1f", px, py)
            else
                minimapText:SetText("--")
            end
            minimapText:Show()
        else
            minimapText:Hide()
        end
    end

    if worldMapText then
        if addon:Get("mapCoords") and WorldMapFrame and WorldMapFrame:IsShown() then
            local parts = {}
            local playerLine = FormatPair(L.COORDS_PLAYER, px, py)
            if playerLine then
                parts[#parts + 1] = playerLine
            end
            local cx, cy = GetCursorXY()
            local cursorLine = FormatPair(L.COORDS_CURSOR, cx, cy)
            if cursorLine then
                parts[#parts + 1] = cursorLine
            end
            worldMapText:SetText(#parts > 0 and table.concat(parts, "    ") or L.COORDS_UNAVAILABLE)
            worldMapText:Show()
        else
            worldMapText:Hide()
        end
    end
end

function module:PrintCoords()
    local x, y, mapID = GetPlayerXY()
    if not x then
        ns.Print(L.COORDS_UNAVAILABLE)
        return
    end
    local info = mapID and ns.SafeCall(C_Map.GetMapInfo, mapID)
    local name = type(info) == "table" and info.name or tostring(mapID)
    ns.Printf("%s  %.1f, %.1f", name, x, y)
end

function module:IsEnabled()
    return addon:Get("mapCoords") or addon:Get("minimapCoords")
end

function module:Enable()
    if not minimapText then
        local parent = Minimap or UIParent
        minimapText = parent:CreateFontString("ForeverKitMinimapCoords", "OVERLAY", "GameFontNormalSmall")
        minimapText:SetPoint("TOP", parent, "BOTTOM", addon:Get("minimapCoordsX") or 0, addon:Get("minimapCoordsY") or -4)
        minimapText:SetTextColor(1, 0.82, 0)
    end

    if WorldMapFrame and not worldMapText then
        worldMapText = WorldMapFrame:CreateFontString("ForeverKitWorldMapCoords", "OVERLAY", "GameFontHighlight")
        local anchor = WorldMapFrame.BorderFrame or WorldMapFrame
        worldMapText:SetPoint("BOTTOM", anchor, "BOTTOM", 0, 8)
        worldMapText:SetTextColor(1, 0.82, 0)
    end

    if not ticker and C_Timer and C_Timer.NewTicker then
        ticker = C_Timer.NewTicker(0.2, Update)
    end
    Update()
end

function module:Disable()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
    if minimapText then
        minimapText:Hide()
    end
    if worldMapText then
        worldMapText:Hide()
    end
end

addon:RegisterModule("Map", module)
