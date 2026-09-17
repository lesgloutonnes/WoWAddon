local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "minimap" }

function skin:Apply()
    local map = Minimap
    if not map then
        return
    end

    ns.TintNamed(map, "MinimapCompassTexture", ns.Color("chrome"))
    if MinimapCompassTexture then
        ns.Tint(MinimapCompassTexture, ns.Color("chrome"))
    end
    if MinimapBorder then
        ns.Tint(MinimapBorder, ns.Color("chrome"))
    end
    if MinimapBorderTop then
        ns.Tint(MinimapBorderTop, ns.Color("chrome"))
    end
    if MiniMapTrackingBorder then
        ns.Tint(MiniMapTrackingBorder, ns.Color("chrome"))
    end
    if MiniMapMailBorder then
        ns.Tint(MiniMapMailBorder, ns.Color("chrome"))
    end
    if MiniMapBattlefieldBorder then
        ns.Tint(MiniMapBattlefieldBorder, ns.Color("chrome"))
    end
    if MinimapZoneTextButton then
        ns.TintFrameArt(MinimapZoneTextButton, ns.Color("chrome"), 1)
    end
    if MinimapCluster then
        ns.TintNamed(MinimapCluster, "BorderTop", ns.Color("chrome"))
        ns.TintFrameArt(MinimapCluster, ns.Color("chrome"), 1)
        if MinimapCluster.Tracking then
            ns.TintNamed(MinimapCluster.Tracking, "Background", ns.Color("bg"))
        end
    end

    if addon:Get("crest") ~= false then
        local ring = ns.EnsureOverlay(map, "LumiereRing", "OVERLAY")
        ring:SetTexture(ns.Media("Ring"))
        local w, h = map:GetWidth(), map:GetHeight()
        if not w or w == 0 then
            w, h = 180, 180
        end
        ring:ClearAllPoints()
        ring:SetPoint("CENTER", map, "CENTER", 0, 0)
        ring:SetSize(w + 18, h + 18)
        ring:SetVertexColor(ns.Unpack("chrome"))
        if ring.SetDrawLayer then
            ring:SetDrawLayer("OVERLAY", 7)
        end
        ring:Show()

        local parent = MinimapCluster or map
        local crest = ns.EnsureOverlay(parent, "LumiereCrest", "OVERLAY")
        crest:SetTexture(ns.Media("Crest"))
        crest:ClearAllPoints()
        crest:SetSize(40, 40)
        crest:SetPoint("BOTTOM", map, "TOP", 0, 4)
        crest:Show()
    else
        if map.LumiereRing then
            map.LumiereRing:Hide()
        end
        if (MinimapCluster or map).LumiereCrest then
            (MinimapCluster or map).LumiereCrest:Hide()
        end
    end
end

addon:RegisterSkin("Minimap", skin)
