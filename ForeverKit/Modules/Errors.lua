local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        errorFilter = true,
    },
    settings = {
        { type = "header", name = "SECTION_ERRORS" },
        { key = "errorFilter", name = "ERROR_FILTER", desc = "ERROR_FILTER_DESC" },
    },
}

local originalAddMessage
local filterSet

local function BuildFilter()
    local keys = {
        "ERR_NO_ATTACK_TARGET",
        "ERR_INVALID_ATTACK_TARGET",
        "ERR_OUT_OF_RAGE",
        "ERR_OUT_OF_ENERGY",
        "ERR_OUT_OF_MANA",
        "ERR_OUT_OF_FOCUS",
        "ERR_OUT_OF_RUNIC_POWER",
        "ERR_ABILITY_COOLDOWN",
        "ERR_SPELL_COOLDOWN",
        "ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS",
        "ERR_NOEMOTEWHILERUNNING",
        "ERR_GENERIC_NO_TARGET",
        "ERR_CLIENT_LOCKED_OUT",
        "SPELL_FAILED_NO_COMBO_POINTS",
        "SPELL_FAILED_MOVING",
        "SPELL_FAILED_UNIT_NOT_INFRONT",
        "SPELL_FAILED_LINE_OF_SIGHT",
        "SPELL_FAILED_BAD_TARGETS",
        "SPELL_FAILED_NOT_BEHIND",
        "SPELL_FAILED_TOO_CLOSE",
        "SPELL_FAILED_OUT_OF_RANGE",
        "ERR_ATTACK_STUNNED",
        "ERR_ATTACK_PACIFIED",
        "ERR_ATTACK_MOUNTED",
        "ERR_NOT_WHILE_SHAPESHIFTED",
        "ERR_CANT_USE_ITEM",
        "ERR_ITEM_COOLDOWN",
        "ERR_NO_ITEMS_WHILE_SHAPESHIFTED",
        "ERR_OUT_OF_RANGE",
        "ERR_BADATTACKFACING",
        "ERR_BADATTACKPOS",
        "ERR_USE_TOO_FAR",
        "ERR_SPELL_OUT_OF_RANGE",
    }
    local set = {}
    for _, globalName in ipairs(keys) do
        local msg = _G[globalName]
        if type(msg) == "string" then
            set[msg] = true
        end
    end
    return set
end

function module:IsEnabled()
    return addon:Get("errorFilter")
end

function module:Enable()
    if not UIErrorsFrame or not UIErrorsFrame.AddMessage then
        return
    end
    if originalAddMessage then
        return
    end
    filterSet = BuildFilter()
    originalAddMessage = UIErrorsFrame.AddMessage
    UIErrorsFrame.AddMessage = function(self, message, ...)
        if addon:Get("errorFilter") and type(message) == "string" and filterSet[message] then
            return
        end
        return originalAddMessage(self, message, ...)
    end
end

function module:Disable()
    if originalAddMessage and UIErrorsFrame then
        UIErrorsFrame.AddMessage = originalAddMessage
        originalAddMessage = nil
    end
end

addon:RegisterModule("Errors", module)
