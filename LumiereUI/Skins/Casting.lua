local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "castBars" }

local function SkinCastBar(bar)
    if not bar then
        return
    end
    ns.ColorBar(bar, "chrome")
    ns.TintNamed(bar, "Border", ns.Color("chrome"))
    ns.TintNamed(bar, "BorderShield", ns.Color("accent"))
    ns.TintNamed(bar, "Background", ns.Color("bg"))
    ns.TintNamed(bar, "Spark", ns.Color("chromeHi"))
    ns.TintNamed(bar, "Flash", ns.Color("chromeHi"))
    ns.TintNineSlice(bar)
    local name = bar.GetName and bar:GetName()
    if name then
        ns.Tint(_G[name .. "Border"], ns.Color("chrome"))
        ns.Tint(_G[name .. "Flash"], ns.Color("chromeHi"))
        ns.Tint(_G[name .. "Spark"], ns.Color("chromeHi"))
        ns.Tint(_G[name .. "Text"], ns.Color("text"))
    end
    if bar.Text and bar.Text.SetTextColor then
        bar.Text:SetTextColor(ns.Unpack("text"))
    end
    if bar.TextBG and bar.TextBG.SetTextColor then
        bar.TextBG:SetTextColor(ns.Unpack("bg"))
    end
end

function skin:Apply()
    SkinCastBar(PlayerCastingBarFrame)
    SkinCastBar(CastingBarFrame)
    SkinCastBar(TargetFrameSpellBar)
    SkinCastBar(FocusFrameSpellBar)
    SkinCastBar(PetCastingBarFrame)
    SkinCastBar(_G.TargetFrameSpellBar)
    if PlayerCastingBarFrame and PlayerCastingBarFrame.ApplyAlpha then
        -- keep Blizzard behaviour; color only
    end
end

local function Hook(bar)
    if not bar or bar.LumiereCastHooked then
        return
    end
    bar.LumiereCastHooked = true
    bar:HookScript("OnShow", function(self)
        if ns.SkinEnabled() and addon:Get("castBars") then
            SkinCastBar(self)
        end
    end)
end

Hook(PlayerCastingBarFrame)
Hook(CastingBarFrame)
Hook(TargetFrameSpellBar)
Hook(FocusFrameSpellBar)

addon:RegisterSkin("Casting", skin)
