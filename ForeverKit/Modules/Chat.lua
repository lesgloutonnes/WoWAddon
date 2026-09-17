local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        chatTimestamps = true,
        chatClassColors = true,
    },
    settings = {
        { type = "header", name = "SECTION_CHAT" },
        { key = "chatTimestamps", name = "CHAT_TIMESTAMPS", desc = "CHAT_TIMESTAMPS_DESC" },
        { key = "chatClassColors", name = "CHAT_CLASS_COLORS", desc = "CHAT_CLASS_COLORS_DESC" },
    },
}

local CHAT_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_LOOT",
    "CHAT_MSG_MONEY",
    "CHAT_MSG_SKILL",
    "CHAT_MSG_COMBAT_FACTION_CHANGE",
}

local copyFrame
local filtersAdded = false

local function TimestampFilter(_, _, message, ...)
    if not addon:Get("chatTimestamps") then
        return false
    end
    if type(message) ~= "string" then
        return false
    end
    if message:find("^%[%d%d:%d%d%]") then
        return false
    end
    local stamp = date("%H:%M")
    return false, format("[%s] %s", stamp, message), ...
end

local function ApplyClassColors()
    if not addon:Get("chatClassColors") then
        return
    end
    if C_CVar and C_CVar.SetCVar then
        pcall(C_CVar.SetCVar, "chatClassColorOverride", "0")
    elseif SetCVar then
        pcall(SetCVar, "chatClassColorOverride", "0")
    end
    if ChatTypeInfo then
        for _, info in pairs(ChatTypeInfo) do
            if type(info) == "table" then
                info.colorNameByClass = true
            end
        end
    end
end

local function EnsureCopyFrame()
    if copyFrame then
        return copyFrame
    end
    local ok, frame = pcall(CreateFrame, "Frame", "ForeverKitChatCopyFrame", UIParent, "BasicFrameTemplateWithInset")
    if not ok or not frame then
        frame = CreateFrame("Frame", "ForeverKitChatCopyFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        })
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
    end
    frame:SetSize(640, 420)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    if frame.TitleText then
        frame.TitleText:SetText(L.CHAT_COPY_TITLE)
    elseif frame.TitleContainer and frame.TitleContainer.TitleText then
        frame.TitleContainer.TitleText:SetText(L.CHAT_COPY_TITLE)
    end

    local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", -30, 12)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(590)
    edit:SetAutoFocus(false)
    edit:SetScript("OnEscapePressed", function()
        frame:Hide()
        edit:ClearFocus()
    end)
    scroll:SetScrollChild(edit)
    frame.edit = edit
    copyFrame = frame
    return frame
end

function module:Copy()
    local frame = EnsureCopyFrame()
    local lines = {}
    local chat = NUM_CHAT_WINDOWS and _G["ChatFrame1"] or ChatFrame1
    if chat and chat.GetNumMessages then
        local n = chat:GetNumMessages() or 0
        for i = 1, n do
            local text = chat:GetMessageInfo(i)
            if text then
                lines[#lines + 1] = text
            end
        end
    end
    frame.edit:SetText(table.concat(lines, "\n"))
    frame:Show()
    frame.edit:HighlightText()
    frame.edit:SetFocus()
end

function module:IsEnabled()
    return addon:Get("chatTimestamps") or addon:Get("chatClassColors")
end

function module:Enable()
    if ChatFrame_AddMessageEventFilter and not filtersAdded then
        for _, event in ipairs(CHAT_EVENTS) do
            ChatFrame_AddMessageEventFilter(event, TimestampFilter)
        end
        filtersAdded = true
    end
    ApplyClassColors()
end

function module:Disable()
    -- Filters stay registered but no-op when the setting is off.
end

addon:RegisterModule("Chat", module)
