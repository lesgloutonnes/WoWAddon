local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "windows" }

local PANELS = {
    "CharacterFrame",
    "SpellBookFrame",
    "PlayerSpellsFrame",
    "QuestLogFrame",
    "QuestMapFrame",
    "WorldMapFrame",
    "FriendsFrame",
    "PVEFrame",
    "MailFrame",
    "MerchantFrame",
    "GossipFrame",
    "QuestFrame",
    "TaxiFrame",
    "ClassTrainerFrame",
    "TradeSkillFrame",
    "CraftFrame",
    "BankFrame",
    "GuildFrame",
    "SettingsPanel",
    "GameMenuFrame",
    "ContainerFrameCombinedBags",
    "InspectFrame",
    "LootFrame",
    "GroupLootFrame1",
}

local function AddCorners(frame)
    if not frame or not addon:Get("crest") then
        return
    end
    if not frame.LumiereCornerTextures then
        frame.LumiereCornerTextures = {}
        local size = 28
        local points = {
            { "TOPLEFT", 4, -4, false, false },
            { "TOPRIGHT", -4, -4, true, false },
            { "BOTTOMLEFT", 4, 4, false, true },
            { "BOTTOMRIGHT", -4, 4, true, true },
        }
        for _, spec in ipairs(points) do
            local tex = frame:CreateTexture(nil, "OVERLAY")
            tex:SetTexture(ns.Media("Corner"))
            tex:SetSize(size, size)
            tex:SetPoint(spec[1], frame, spec[1], spec[2], spec[3])
            tex:SetTexCoord(spec[4] and 1 or 0, spec[4] and 0 or 1, spec[5] and 1 or 0, spec[5] and 0 or 1)
            frame.LumiereCornerTextures[#frame.LumiereCornerTextures + 1] = tex
        end
    end
    for i = 1, #frame.LumiereCornerTextures do
        frame.LumiereCornerTextures[i]:SetVertexColor(ns.Unpack("chrome"))
        frame.LumiereCornerTextures[i]:Show()
    end
end

local function SkinPanel(frame)
    if not frame or ns.ShouldSkipFrame(frame) then
        return
    end
    ns.TintNineSlice(frame)
    ns.TintNamed(frame, "Bg", ns.Color("bg"))
    ns.TintNamed(frame, "Background", ns.Color("bg"))
    ns.TintFrameArt(frame, ns.Color("chrome"), 1)
    local title = frame.TitleText
        or (frame.TitleContainer and frame.TitleContainer.TitleText)
        or frame.Title
    if title and title.SetTextColor then
        title:SetTextColor(ns.Unpack("text"))
    end
    AddCorners(frame)
end

function skin:Apply()
    for i = 1, #PANELS do
        local frame = _G[PANELS[i]]
        if frame then
            SkinPanel(frame)
        end
    end
    ns.ForEachGlobal("ContainerFrame", 13, SkinPanel)
    if ObjectiveTrackerFrame then
        ns.TintFrameArt(ObjectiveTrackerFrame, ns.Color("chrome"), 2)
        if ObjectiveTrackerFrame.Header then
            ns.TintFrameArt(ObjectiveTrackerFrame.Header, ns.Color("chrome"), 1)
        end
    end
end

if ShowUIPanel then
    hooksecurefunc("ShowUIPanel", function(frame)
        if ns.SkinEnabled() and addon:Get("windows") and frame then
            SkinPanel(frame)
        end
    end)
end

addon:RegisterSkin("Windows", skin)
