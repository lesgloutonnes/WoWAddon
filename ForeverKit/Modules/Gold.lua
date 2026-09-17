local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        goldTracker = true,
    },
    settings = {
        { type = "header", name = "SECTION_GOLD" },
        { key = "goldTracker", name = "GOLD_TRACKER", desc = "GOLD_TRACKER_DESC" },
    },
}

local frame
local sessionStart

local function CurrentMoney()
    return ns.Reveal(GetMoney and GetMoney() or 0, 0) or 0
end

function module:PrintSession()
    if not addon:Get("goldTracker") then
        return
    end
    local start = sessionStart or CurrentMoney()
    local now = CurrentMoney()
    local delta = now - start
    local sign = delta >= 0 and "|cff55ff55+|r" or "|cffff5555-|r"
    ns.Printf(L.GOLD_SESSION, sign .. ns.MoneyString(math.abs(delta)), ns.MoneyString(start), ns.MoneyString(now))
end

function module:IsEnabled()
    return addon:Get("goldTracker")
end

function module:Enable()
    sessionStart = sessionStart or CurrentMoney()
    if not frame then
        frame = CreateFrame("Frame")
        frame:SetScript("OnEvent", function(_, event)
            if event == "PLAYER_ENTERING_WORLD" then
                sessionStart = sessionStart or CurrentMoney()
            end
        end)
    end
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_MONEY")
end

function module:Disable()
    if frame then
        frame:UnregisterAllEvents()
    end
end

addon:RegisterModule("Gold", module)
