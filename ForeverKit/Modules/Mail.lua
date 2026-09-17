local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        mailTakeAll = true,
    },
    settings = {
        { type = "header", name = "SECTION_MAIL" },
        { key = "mailTakeAll", name = "MAIL_BUTTON", desc = "MAIL_BUTTON_DESC" },
    },
}

local button
local taking
local ticker

local function InboxBusy()
    if C_Mail and C_Mail.IsCommandPending then
        return C_Mail.IsCommandPending()
    end
    return false
end

local function FinishMail()
    taking = false
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
    ns.Print(L.MAIL_DONE)
end

local function TakeNext()
    if InboxBusy() then
        return
    end
    local num = GetInboxNumItems and GetInboxNumItems() or 0
    if num <= 0 then
        FinishMail()
        return
    end

    for i = num, 1, -1 do
        local _, _, _, _, money, cod, _, hasItem = GetInboxHeaderInfo(i)
        money = ns.Reveal(money, 0) or 0
        cod = ns.Reveal(cod, 0) or 0
        if not (cod and cod > 0) then
            if hasItem then
                if AutoLootMailItem then
                    AutoLootMailItem(i)
                elseif TakeInboxItem then
                    TakeInboxItem(i)
                end
                return
            end
            if money > 0 and TakeInboxMoney then
                TakeInboxMoney(i)
                return
            end
            if DeleteInboxItem then
                DeleteInboxItem(i)
            end
            return
        end
    end

    -- Only COD mails remain; leave them untouched.
    FinishMail()
end

local function StartTakeAll()
    if taking then
        return
    end
    taking = true
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
    if C_Timer and C_Timer.NewTicker then
        ticker = C_Timer.NewTicker(0.35, TakeNext)
    end
    TakeNext()
end

local function EnsureButton()
    if button or not InboxFrame then
        return
    end
    button = CreateFrame("Button", "ForeverKitMailTakeAll", InboxFrame, "UIPanelButtonTemplate")
    button:SetSize(110, 24)
    button:SetPoint("BOTTOMRIGHT", InboxFrame, "BOTTOMRIGHT", -8, 8)
    button:SetText(L.MAIL_TAKE_ALL)
    button:SetScript("OnClick", StartTakeAll)
end

local frame

function module:IsEnabled()
    return addon:Get("mailTakeAll")
end

function module:Enable()
    EnsureButton()
    if button then
        button:Show()
    end
    if not frame then
        frame = CreateFrame("Frame")
        frame:RegisterEvent("MAIL_SHOW")
        frame:SetScript("OnEvent", function()
            if addon:Get("mailTakeAll") then
                EnsureButton()
                if button then
                    button:Show()
                end
            end
        end)
    end
end

function module:Disable()
    if button then
        button:Hide()
    end
    taking = false
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

addon:RegisterModule("Mail", module)
