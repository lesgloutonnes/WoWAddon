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
        or _G[(frame.GetName and frame:GetName() or "") .. "HealthBar"]
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
    local name = frame.GetName and frame:GetName() or ""
    return frame.manabar
        or frame.ManaBar
        or frame.powerBar
        or _G[name .. "ManaBar"]
        or (frame.PlayerFrameContent
            and frame.PlayerFrameContent.PlayerFrameContentMain
            and frame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea
            and frame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar)
end

local function SkinClassicArt(frame)
    if not frame then
        return
    end
    local name = frame.GetName and frame:GetName() or ""
    local chrome = ns.Color("chrome")
    ns.Tint(_G[name .. "Texture"], chrome)
    ns.Tint(_G[name .. "VehicleTexture"], chrome)
    ns.TintNamed(frame, "texture", chrome)
    ns.TintNamed(frame, "Texture", chrome)
    if frame.textureFrame then
        ns.TintNamed(frame.textureFrame, "texture", chrome)
        ns.TintNamed(frame.textureFrame, "Texture", chrome)
    end
    if frame.TextureFrame then
        ns.TintNamed(frame.TextureFrame, "texture", chrome)
        ns.TintNamed(frame.TextureFrame, "Texture", chrome)
        ns.Tint(_G[name .. "TextureFrameTexture"], chrome)
    end
    ns.Tint(_G[name .. "NameBackground"], ns.Color("bg"))
    ns.TintNamed(frame, "nameBackground", ns.Color("bg"))
    ns.TintNamed(frame, "NameBackground", ns.Color("bg"))
    ns.Tint(_G[name .. "Flash"], ns.Color("accent"))
    ns.Tint(_G[name .. "StatusTexture"], ns.Color("accent"))
    ns.Tint(_G.PlayerStatusTexture, ns.Color("accent"))
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
    SkinClassicArt(frame)
    ns.TintFrameArt(container, ns.Color("chrome"), 1)
    if isPlayer then
        ns.ColorBar(FindHealthBar(frame), "health")
        ns.ColorBar(FindPowerBar(frame), "power")
        local name = frame.name
            or frame.Name
            or _G.PlayerName
            or (frame.PlayerFrameContent and frame.PlayerFrameContent.PlayerFrameContentMain and frame.PlayerFrameContent.PlayerFrameContentMain.Name)
        if name and name.SetTextColor then
            name:SetTextColor(ns.Unpack("text"))
        end
    else
        -- Keep target health reaction coloring; only chrome is paladin.
        ns.TintFrameArt(container, ns.Color("chrome"), 0)
    end
    if addon:Get("crest") ~= false then
        local crest = ns.EnsureOverlay(frame, "LumiereCrest", "OVERLAY")
        crest:SetTexture(ns.Media("Crest"))
        crest:SetSize(28, 28)
        crest:ClearAllPoints()
        crest:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 4, 6)
        crest:Show()
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
        SkinUnit(_G["PartyMemberFrame" .. i], false)
    end
    if CompactPartyFrame then
        ns.TintNineSlice(CompactPartyFrame)
        ns.TintFrameArt(CompactPartyFrame, ns.Color("chrome"), 1)
    end
    ns.ColorBar(_G.PlayerFrameHealthBar, "health")
    ns.ColorBar(_G.PlayerFrameManaBar, "power")
    ns.Tint(_G.TargetFrameTextureFrameTexture, ns.Color("chrome"))
    ns.Tint(_G.PlayerFrameTexture, ns.Color("chrome"))
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
