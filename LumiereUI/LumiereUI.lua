local ADDON_NAME, ns = ...
local L = ns.L

local addon = {
    name = ADDON_NAME,
    version = "0.2.0",
    skins = {},
    order = {},
}
ns.addon = addon
_G.LumiereUI = addon

LumiereUIDB = LumiereUIDB or {}

local defaults = {
    enabled = true,
    variant = "auto",
    unitFrames = true,
    actionBars = true,
    minimap = true,
    chat = true,
    tooltips = true,
    castBars = true,
    windows = true,
    gryphons = true,
    crest = true,
    onlyPaladin = false,
    splash = true,
}

function addon:RegisterSkin(key, skin)
    skin.key = key
    self.skins[key] = skin
    self.order[#self.order + 1] = key
end

function addon:DB()
    return LumiereUIDB
end

function addon:Get(key)
    return LumiereUIDB[key]
end

function addon:Set(key, value)
    LumiereUIDB[key] = value
end

function addon:InitDB()
    for k, v in pairs(defaults) do
        if LumiereUIDB[k] == nil then
            LumiereUIDB[k] = v
        end
    end
end

function addon:Apply()
    ns.serial = (ns.serial or 0) + 1
    if not ns.SkinEnabled() then
        return
    end
    for _, key in ipairs(self.order) do
        local skin = self.skins[key]
        if skin and skin.Apply then
            local enabled = true
            if skin.setting then
                enabled = LumiereUIDB[skin.setting] ~= false
            end
            if enabled then
                local ok, err = pcall(skin.Apply, skin)
                if not ok then
                    print("|cfff58cbaLumièreUI|r |cffff5555" .. key .. "|r: " .. tostring(err))
                end
            end
        end
    end
end

function addon:ScheduleApply(delay)
    if C_Timer and C_Timer.After then
        C_Timer.After(delay or 0.15, function()
            addon:Apply()
        end)
    else
        self:Apply()
    end
end

function addon:OpenSettings()
    if Settings and Settings.OpenToCategory then
        if self.settingsCategory and self.settingsCategory.GetID then
            Settings.OpenToCategory(self.settingsCategory:GetID())
            return
        end
        Settings.OpenToCategory(L.SETTINGS)
    end
end

function addon:SetVariant(variant)
    LumiereUIDB.variant = variant
    self:Apply()
    print("|cfff58cbaLumièreUI|r " .. L.VARIANT .. ": " .. variant)
end

function addon:ShowSplash()
    if not LumiereUIDB.splash or not ns.SkinEnabled() then
        return
    end
    pcall(function()
        local frame = addon.splashFrame
        if not frame then
            frame = CreateFrame("Frame", "LumiereUISplash", UIParent)
            frame:SetSize(220, 220)
            frame:SetPoint("CENTER", 0, 80)
            frame:SetFrameStrata("TOOLTIP")
            local glow = frame:CreateTexture(nil, "BACKGROUND")
            glow:SetTexture(ns.Media("Glow"))
            glow:SetAllPoints()
            local crest = frame:CreateTexture(nil, "ARTWORK")
            crest:SetTexture(ns.Media("Crest"))
            crest:SetSize(160, 160)
            crest:SetPoint("CENTER", 0, 12)
            local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
            title:SetPoint("TOP", crest, "BOTTOM", 0, 4)
            title:SetText(L.SPLASH)
            local sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            sub:SetPoint("TOP", title, "BOTTOM", 0, -2)
            sub:SetText(L.SPLASH_SUB)
            frame.title = title
            frame.sub = sub
            addon.splashFrame = frame
        end
        frame.title:SetTextColor(ns.Unpack("text"))
        frame:SetAlpha(1)
        frame:Show()
        if C_Timer and C_Timer.After then
            C_Timer.After(2.8, function()
                if UIFrameFadeOut then
                    UIFrameFadeOut(frame, 1.2, 1, 0)
                else
                    frame:Hide()
                end
            end)
            C_Timer.After(4.2, function()
                frame:Hide()
            end)
        end
    end)
end

SLASH_LUMIEREUI1 = "/lumiere"
SLASH_LUMIEREUI2 = "/lumiereui"
SLASH_LUMIEREUI3 = "/lu"
SlashCmdList.LUMIEREUI = function(msg)
    msg = strtrim(strlower(msg or ""))
    if msg == "holy" or msg == "sacre" or msg == "sacré" then
        addon:SetVariant("holy")
    elseif msg == "prot" or msg == "protection" then
        addon:SetVariant("protection")
    elseif msg == "ret" or msg == "retribution" or msg == "vindicte" then
        addon:SetVariant("retribution")
    elseif msg == "auto" then
        addon:SetVariant("auto")
    elseif msg == "apply" or msg == "reloadskin" then
        addon:Apply()
    else
        addon:OpenSettings()
        print("|cfff58cbaLumièreUI|r " .. L.HELP)
    end
end

function LumiereUI_OnAddonCompartmentClick()
    addon:OpenSettings()
end

function LumiereUI_OnAddonCompartmentEnter(_, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(L.SETTINGS, ns.Unpack("chrome"))
    GameTooltip:AddLine(L.COMPARTMENT, 1, 1, 1, true)
    GameTooltip:Show()
end

function LumiereUI_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
pcall(events.RegisterEvent, events, "PLAYER_SPECIALIZATION_CHANGED")
pcall(events.RegisterEvent, events, "ACTIVE_TALENT_GROUP_CHANGED")
pcall(events.RegisterEvent, events, "PLAYER_TALENT_UPDATE")
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ADDON_NAME then
            addon:InitDB()
            if ns.InitSettings then
                ns.InitSettings(addon)
            end
        elseif arg1 and arg1:find("Blizzard_") then
            addon:ScheduleApply(0.2)
        end
    elseif event == "PLAYER_LOGIN" then
        addon:ScheduleApply(0.3)
        addon:ShowSplash()
        print("|cfff58cbaLumièreUI|r " .. L.LOADED)
    elseif event == "PLAYER_ENTERING_WORLD" then
        addon:ScheduleApply(0.5)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        if not arg1 or arg1 == "player" then
            addon:ScheduleApply(0.2)
        end
    end
end)

if EventRegistry and EventRegistry.RegisterCallback then
    pcall(function()
        EventRegistry:RegisterCallback("EditMode.Exit", function()
            addon:ScheduleApply(0.2)
        end)
    end)
end
