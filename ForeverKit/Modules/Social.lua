local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        autoAcceptFriends = false,
        autoAcceptGuild = false,
    },
    settings = {
        { type = "header", name = "SECTION_SOCIAL" },
        { key = "autoAcceptFriends", name = "AUTO_ACCEPT_FRIENDS", desc = "AUTO_ACCEPT_FRIENDS_DESC" },
        { key = "autoAcceptGuild", name = "AUTO_ACCEPT_GUILD", desc = "AUTO_ACCEPT_GUILD_DESC" },
    },
}

local frame

local function IsFriend(name)
    if not name or name == "" then
        return false
    end
    name = Ambiguate and Ambiguate(name, "none") or name
    if C_FriendList and C_FriendList.GetFriendInfo then
        local info = C_FriendList.GetFriendInfo(name)
        if info then
            return true
        end
    end
    if C_BattleNet and C_BattleNet.GetFriendNumGameAccounts then
        local n = BNGetNumFriends and BNGetNumFriends() or 0
        for i = 1, n do
            local account = C_BattleNet.GetFriendAccountInfo and C_BattleNet.GetFriendAccountInfo(i)
            local game = account and account.gameAccountInfo
            if game and game.characterName and (game.characterName == name or (Ambiguate and Ambiguate(game.characterName, "none") == name)) then
                return true
            end
        end
    end
    return false
end

local function IsGuildie(name)
    if not name or not IsInGuild or not IsInGuild() then
        return false
    end
    name = Ambiguate and Ambiguate(name, "none") or name
    if GetNumGuildMembers then
        local n = GetNumGuildMembers() or 0
        for i = 1, n do
            local gname = GetGuildRosterInfo(i)
            if gname and (Ambiguate and Ambiguate(gname, "none") or gname) == name then
                return true
            end
        end
    end
    return false
end

local function OnInvite(_, _, name)
    if ns.InCombat() then
        return
    end
    local accept = false
    if addon:Get("autoAcceptFriends") and IsFriend(name) then
        accept = true
    elseif addon:Get("autoAcceptGuild") and IsGuildie(name) then
        accept = true
    end
    if not accept then
        return
    end
    if AcceptGroup then
        AcceptGroup()
    end
    for i = 1, STATICPOPUP_NUMDIALOGS or 4 do
        local popup = _G["StaticPopup" .. i]
        if popup and popup:IsShown() and (popup.which == "PARTY_INVITE" or popup.which == "PARTY_INVITE_XREALM") then
            popup:Hide()
        end
    end
end

function module:IsEnabled()
    return addon:Get("autoAcceptFriends") or addon:Get("autoAcceptGuild")
end

function module:Enable()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", OnInvite)
    end
    frame:RegisterEvent("PARTY_INVITE_REQUEST")
end

function module:Disable()
    if frame then
        frame:UnregisterAllEvents()
    end
end

addon:RegisterModule("Social", module)
