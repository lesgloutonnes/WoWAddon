local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        vendorRepair = true,
        vendorGuildRepair = true,
        vendorSellJunk = true,
    },
    settings = {
        { type = "header", name = "SECTION_VENDOR" },
        { key = "vendorRepair", name = "VENDOR_REPAIR", desc = "VENDOR_REPAIR_DESC" },
        { key = "vendorGuildRepair", name = "VENDOR_GUILD_REPAIR", desc = "VENDOR_GUILD_REPAIR_DESC" },
        { key = "vendorSellJunk", name = "VENDOR_SELL_JUNK", desc = "VENDOR_SELL_JUNK_DESC" },
    },
}

local frame

local function QualityIsPoor(quality)
    if quality == nil then
        return false
    end
    if ns.IsSecret(quality) then
        return false
    end
    local poor = Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0
    return quality == poor
end

local function Repair()
    if not addon:Get("vendorRepair") then
        return
    end
    if not CanMerchantRepair or not CanMerchantRepair() then
        return
    end
    local cost = GetRepairAllCost and GetRepairAllCost() or 0
    cost = ns.Reveal(cost, 0)
    if not cost or cost <= 0 then
        return
    end
    local money = GetMoney and GetMoney() or 0
    local guildOK = addon:Get("vendorGuildRepair")
        and CanGuildBankRepair
        and CanGuildBankRepair()
        and GetGuildBankWithdrawMoney
        and (GetGuildBankWithdrawMoney() == -1 or GetGuildBankWithdrawMoney() >= cost)

    if guildOK then
        RepairAllItems(true)
        ns.Printf(L.VENDOR_REPAIRED_GUILD, ns.MoneyString(cost))
        return
    end
    if money >= cost then
        RepairAllItems()
        ns.Printf(L.VENDOR_REPAIRED, ns.MoneyString(cost))
    else
        ns.Printf(L.VENDOR_CANNOT_AFFORD, ns.MoneyString(cost))
    end
end

local function SellJunk()
    if not addon:Get("vendorSellJunk") then
        return
    end
    if not C_Container or not C_Container.GetContainerNumSlots then
        return
    end
    local sold, copper = 0, 0
    local first, last = ns.BagIndexRange()
    for bag = first, last do
        local slots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and not info.isLocked and QualityIsPoor(info.quality) then
                local count = ns.Reveal(info.stackCount, 1) or 1
                local itemID = info.itemID
                local itemInfo = itemID and ns.GetItemInfo(itemID)
                local price = itemInfo and tonumber(itemInfo.sellPrice) or 0
                if C_Container.UseContainerItem then
                    C_Container.UseContainerItem(bag, slot)
                    sold = sold + 1
                    copper = copper + (price * count)
                end
            end
        end
    end
    if sold > 0 then
        ns.Printf(L.VENDOR_SOLD_JUNK, sold, ns.MoneyString(copper))
    end
end

function module:IsEnabled()
    return addon:Get("vendorRepair") or addon:Get("vendorSellJunk")
end

function module:Enable()
    if frame then
        return
    end
    frame = CreateFrame("Frame")
    frame:RegisterEvent("MERCHANT_SHOW")
    frame:SetScript("OnEvent", function()
        Repair()
        SellJunk()
    end)
end

function module:Disable()
    if frame then
        frame:UnregisterAllEvents()
        frame:SetScript("OnEvent", nil)
        frame = nil
    end
end

addon:RegisterModule("Vendor", module)
