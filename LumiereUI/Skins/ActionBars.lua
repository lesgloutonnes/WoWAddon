local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "actionBars" }

local BAR_NAMES = {
    "MainActionBar",
    "MainMenuBar",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarRight",
    "MultiBarLeft",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "MultiBar8",
    "StanceBar",
    "PetActionBar",
    "PossessActionBar",
    "OverrideActionBar",
    "ExtraActionBar",
    "ZoneAbilityFrame",
}

local BUTTON_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
    "MultiBar8Button",
    "StanceButton",
    "PetActionButton",
    "PossessButton",
}

local function SkinButton(btn)
    if not btn or (btn.IsForbidden and btn:IsForbidden()) then
        return
    end
    local chrome = ns.Color("chrome")
    local nt = btn.NormalTexture or (btn.GetNormalTexture and btn:GetNormalTexture())
    if nt then
        ns.Tint(nt, chrome)
    end
    local pushed = btn.PushedTexture or (btn.GetPushedTexture and btn:GetPushedTexture())
    if pushed then
        ns.Tint(pushed, ns.Color("chromeHi"))
    end
    ns.TintNamed(btn, "SlotBackground", ns.Color("bg"))
    ns.TintNamed(btn, "SlotArt", chrome)
    ns.TintNamed(btn, "Border", ns.Color("accent"))
    ns.TintNamed(btn, "IconMask", chrome)
    ns.TintNamed(btn, "Flash", ns.Color("accent"))

    if addon:Get("crest") ~= false then
        local overlay = ns.EnsureOverlay(btn, "LumiereBorder", "OVERLAY")
        overlay:SetTexture(ns.Media("ButtonBorder"))
        overlay:SetAllPoints(btn)
        overlay:SetVertexColor(chrome[1], chrome[2], chrome[3], 1)
        if overlay.SetDrawLayer then
            overlay:SetDrawLayer("OVERLAY", 6)
        end
        overlay:Show()
    elseif btn.LumiereBorder then
        btn.LumiereBorder:Hide()
    end
end

local function SkinBar(bar)
    if not bar then
        return
    end
    ns.TintNamed(bar, "Background", ns.Color("bg"))
    ns.TintNamed(bar, "ActionBarBackground", ns.Color("bg"))
    local endCaps = bar.EndCaps
    if endCaps then
        if addon:Get("gryphons") then
            if endCaps.LeftEndCap then
                endCaps.LeftEndCap:SetAlpha(0)
            end
            if endCaps.RightEndCap then
                endCaps.RightEndCap:SetAlpha(0)
            end
        else
            ns.TintNamed(endCaps, "LeftEndCap", ns.Color("chrome"))
            ns.TintNamed(endCaps, "RightEndCap", ns.Color("chrome"))
        end
    end
    if bar.GetChildren then
        local children = { bar:GetChildren() }
        for i = 1, #children do
            local child = children[i]
            if child and (child.icon or child.Icon or child.NormalTexture) then
                SkinButton(child)
            end
        end
    end
end

local function PlaceCrest(parent, key, point, relPoint, x, y)
    if not parent or not addon:Get("crest") or not addon:Get("gryphons") then
        if parent and parent[key] then
            parent[key]:Hide()
        end
        return
    end
    local tex = parent[key]
    if not tex then
        tex = parent:CreateTexture(nil, "OVERLAY")
        tex:SetSize(72, 72)
        parent[key] = tex
    end
    tex:SetTexture(ns.Media("Crest"))
    tex:ClearAllPoints()
    tex:SetPoint(point, parent, relPoint, x, y)
    tex:Show()
end

function skin:Apply()
    for _, name in ipairs(BAR_NAMES) do
        SkinBar(_G[name])
    end
    for _, prefix in ipairs(BUTTON_PREFIXES) do
        ns.ForEachGlobal(prefix, 12, SkinButton)
    end
    SkinButton(_G.ExtraActionButton1)

    local main = MainActionBar or MainMenuBar
    if main then
        PlaceCrest(main, "LumiereCrestLeft", "RIGHT", "LEFT", 6, 12)
        PlaceCrest(main, "LumiereCrestRight", "LEFT", "RIGHT", -6, 12)
        if main.LumiereCrestRight then
            main.LumiereCrestRight:SetTexCoord(1, 0, 0, 1)
        end
    end

    if MicroMenuContainer then
        ns.TintFrameArt(MicroMenuContainer, ns.Color("chrome"), 2)
    end
    if BagsBar then
        ns.TintFrameArt(BagsBar, ns.Color("chrome"), 2)
        if BagsBar.GetChildren then
            for _, child in ipairs({ BagsBar:GetChildren() }) do
                if child and child.GetNormalTexture then
                    SkinButton(child)
                end
            end
        end
    end
    if StatusTrackingBarManager then
        ns.TintFrameArt(StatusTrackingBarManager, ns.Color("chrome"), 2)
    end
end

addon:RegisterSkin("ActionBars", skin)
