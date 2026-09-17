local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "actionBars" }

local BAR_NAMES = {
    "MainActionBar",
    "MainMenuBar",
    "MainMenuBarArtFrame",
    "MainMenuBarArtFrameBackground",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarRight",
    "MultiBarLeft",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "MultiBar8",
    "StanceBar",
    "StanceBarFrame",
    "ShapeshiftBarFrame",
    "PetActionBar",
    "PetActionBarFrame",
    "PossessActionBar",
    "PossessBarFrame",
    "OverrideActionBar",
    "ExtraActionBar",
    "ZoneAbilityFrame",
    "BonusActionBarFrame",
}

local BUTTON_PREFIXES = {
    "ActionButton",
    "BonusActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
    "MultiBar8Button",
    "StanceButton",
    "ShapeshiftButton",
    "PetActionButton",
    "PossessButton",
}

local ART_TEXTURES = {
    "MainMenuBarTexture0",
    "MainMenuBarTexture1",
    "MainMenuBarTexture2",
    "MainMenuBarTexture3",
    "MainMenuMaxLevelBar0",
    "MainMenuMaxLevelBar1",
    "MainMenuMaxLevelBar2",
    "MainMenuMaxLevelBar3",
    "MainMenuXPBarTexture0",
    "MainMenuXPBarTexture1",
    "MainMenuXPBarTexture2",
    "MainMenuXPBarTexture3",
    "ReputationWatchBarTexture0",
    "ReputationWatchBarTexture1",
    "ReputationWatchBarTexture2",
    "ReputationWatchBarTexture3",
    "MainMenuBarLeftEndCap",
    "MainMenuBarRightEndCap",
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
    ns.TintNamed(btn, "NormalTexture", chrome)
    ns.TintNamed(btn, "PushedTexture", ns.Color("chromeHi"))
    ns.TintNamed(btn, "FloatingBG", ns.Color("bg"))

    if addon:Get("crest") ~= false then
        local overlay = ns.EnsureOverlay(btn, "LumiereBorder", "OVERLAY")
        overlay:SetTexture(ns.Media("ButtonBorder"))
        overlay:SetAllPoints(btn)
        overlay:SetVertexColor(chrome[1], chrome[2], chrome[3], 1)
        if overlay.SetDrawLayer then
            overlay:SetDrawLayer("OVERLAY", 6)
        end
        overlay:Show()
    end
end

local function SkinEndCap(tex, hide)
    if not tex then
        return
    end
    if hide then
        ns.SetAlpha(tex, 0)
    else
        if tex.LumiereOrigAlpha ~= nil then
            ns.SetAlpha(tex, tex.LumiereOrigAlpha)
        else
            ns.SetAlpha(tex, 1)
        end
        ns.Tint(tex, ns.Color("chrome"))
    end
end

local function SkinBar(bar)
    if not bar then
        return
    end
    ns.TintNamed(bar, "Background", ns.Color("bg"))
    ns.TintNamed(bar, "ActionBarBackground", ns.Color("bg"))
    ns.TintFrameArt(bar, ns.Color("chrome"), 1)
    local endCaps = bar.EndCaps
    if endCaps then
        SkinEndCap(endCaps.LeftEndCap, addon:Get("gryphons"))
        SkinEndCap(endCaps.RightEndCap, addon:Get("gryphons"))
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
        return
    end
    local tex = ns.EnsureOverlay(parent, key, "OVERLAY")
    tex:SetSize(72, 72)
    tex:SetTexture(ns.Media("Crest"))
    tex:ClearAllPoints()
    tex:SetPoint(point, parent, relPoint, x, y)
    tex:Show()
    return tex
end

function skin:Apply()
    for _, name in ipairs(BAR_NAMES) do
        SkinBar(_G[name])
    end
    for _, prefix in ipairs(BUTTON_PREFIXES) do
        ns.ForEachGlobal(prefix, 12, SkinButton)
    end
    SkinButton(_G.ExtraActionButton1)

    for i = 1, #ART_TEXTURES do
        local tex = _G[ART_TEXTURES[i]]
        if tex then
            if (ART_TEXTURES[i] == "MainMenuBarLeftEndCap" or ART_TEXTURES[i] == "MainMenuBarRightEndCap") then
                SkinEndCap(tex, addon:Get("gryphons"))
            else
                ns.Tint(tex, ns.Color("chrome"))
            end
        end
    end

    local main = MainActionBar or MainMenuBar or MainMenuBarArtFrame
    if main then
        local classicCaps = _G.MainMenuBarLeftEndCap or _G.MainMenuBarRightEndCap
        if classicCaps then
            local left = PlaceCrest(main, "LumiereCrestLeft", "LEFT", "LEFT", -28, 10)
            local right = PlaceCrest(main, "LumiereCrestRight", "RIGHT", "RIGHT", 28, 10)
            if right then
                right:SetTexCoord(1, 0, 0, 1)
            end
            if left then
                left:SetTexCoord(0, 1, 0, 1)
            end
        else
            local left = PlaceCrest(main, "LumiereCrestLeft", "RIGHT", "LEFT", 6, 12)
            local right = PlaceCrest(main, "LumiereCrestRight", "LEFT", "RIGHT", -6, 12)
            if right then
                right:SetTexCoord(1, 0, 0, 1)
            end
            if left then
                left:SetTexCoord(0, 1, 0, 1)
            end
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
    if MainMenuExpBar then
        ns.TintFrameArt(MainMenuExpBar, ns.Color("chrome"), 1)
        ns.ColorBar(MainMenuExpBar, "health")
    end
    if ReputationWatchBar then
        ns.TintFrameArt(ReputationWatchBar, ns.Color("chrome"), 1)
    end
end

addon:RegisterSkin("ActionBars", skin)
