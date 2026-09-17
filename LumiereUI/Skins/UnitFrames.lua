local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "unitFrames" }

local function FindHealthBar(frame)
    if not frame then
        return nil
    end
    return frame.healthbar
        or frame.HealthBar
        or frame.healthBar
        or (frame.PlayerFrameContent
            and frame.PlayerFrameContent.PlayerFrameContentMain
            and frame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer
            and (frame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.healthBar
                or frame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar))
        or (frame.TargetFrameContent
            and frame.TargetFrameContent.TargetFrameContentMain
            and frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
            and (frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.healthBar
                or frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar))
end

local function FindPowerBar(frame)
    if not frame then
        return nil
    end
    return frame.manabar
        or frame.ManaBar
        or frame.powerBar
        or (frame.PlayerFrameContent
            and frame.PlayerFrameContent.PlayerFrameContentMain
            and frame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea
            and frame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar)
end

local function SkinUnit(frame, isPlayer)
    if not frame or (frame.IsForbidden and frame:IsForbidden()) then
        return
    end
    local container = frame.PlayerFrameContainer or frame.TargetFrameContainer or frame.PetFrameContainer or frame
    ns.TintNamed(container, "FrameTexture", ns.Color("chrome"))
    ns.TintNamed(container, "AlternatePowerFrameTexture", ns.Color("chrome"))
    ns.TintNamed(container, "FrameFlash", ns.Color("accent"))
    ns.TintNamed(frame, "threatIndicator", ns.Color("accent"))
    ns.TintNamed(frame, "nameBackground", ns.Color("bg"))
    ns.TintNineSlice(frame)
    if isPlayer then
        ns.ColorBar(FindHealthBar(frame), "health")
        ns.ColorBar(FindPowerBar(frame), "power")
        local name = frame.name or (frame.PlayerFrameContent and frame.PlayerFrameContent.PlayerFrameContentMain and frame.PlayerFrameContent.PlayerFrameContentMain.Name)
        if name and name.SetTextColor then
            name:SetTextColor(ns.Unpack("text"))
        end
    else
        -- Keep target health reaction coloring; only chrome is paladin.
        ns.TintFrameArt(container, ns.Color("chrome"), 0)
    end
end

function skin:Apply()
    SkinUnit(PlayerFrame, true)
    SkinUnit(PetFrame, true)
    SkinUnit(TargetFrame, false)
    SkinUnit(FocusFrame, false)
    SkinUnit(TargetFrameToT, false)
    SkinUnit(_G.TargetFrameToT, false)
    if BossTargetFrameContainer then
        ns.TintFrameArt(BossTargetFrameContainer, ns.Color("chrome"), 1)
    end
    for i = 1, 5 do
        SkinUnit(_G["Boss" .. i .. "TargetFrame"], false)
    end
    if CompactPartyFrame then
        ns.TintNineSlice(CompactPartyFrame)
        ns.TintFrameArt(CompactPartyFrame, ns.Color("chrome"), 1)
    end
end

if UnitFrameHealthBar_Update then
    hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
        if not ns.SkinEnabled() or not addon:Get("unitFrames") then
            return
        end
        if unit == "player" or unit == "vehicle" or unit == "pet" then
            ns.ColorBar(statusbar, "health")
        end
    end)
end

if UnitFrameManaBar_Update then
    hooksecurefunc("UnitFrameManaBar_Update", function(statusbar, unit)
        if not ns.SkinEnabled() or not addon:Get("unitFrames") then
            return
        end
        if unit == "player" or unit == "vehicle" or unit == "pet" then
            ns.ColorBar(statusbar, "power")
        end
    end)
end

addon:RegisterSkin("UnitFrames", skin)
