local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        minimapZoom = true,
    },
    settings = {
        { key = "minimapZoom", name = "MINIMAP_ZOOM", desc = "MINIMAP_ZOOM_DESC" },
    },
}

local hooked = false
local oldWheel

local function OnMouseWheel(_, delta)
    if not addon:Get("minimapZoom") then
        return
    end
    if delta > 0 then
        if MinimapZoomIn and MinimapZoomIn.Click then
            MinimapZoomIn:Click()
        elseif Minimap_ZoomIn then
            Minimap_ZoomIn()
        elseif Minimap.ZoomIn then
            Minimap:ZoomIn()
        end
    else
        if MinimapZoomOut and MinimapZoomOut.Click then
            MinimapZoomOut:Click()
        elseif Minimap_ZoomOut then
            Minimap_ZoomOut()
        elseif Minimap.ZoomOut then
            Minimap:ZoomOut()
        end
    end
end

function module:IsEnabled()
    return addon:Get("minimapZoom")
end

function module:Enable()
    if not Minimap then
        return
    end
    Minimap:EnableMouseWheel(true)
    if not hooked then
        oldWheel = Minimap:GetScript("OnMouseWheel")
        if not oldWheel then
            Minimap:SetScript("OnMouseWheel", OnMouseWheel)
        end
        hooked = true
    end
end

function module:Disable()
    -- Keep the hook; it no-ops when disabled so we don't fight other addons.
end

addon:RegisterModule("Minimap", module)
