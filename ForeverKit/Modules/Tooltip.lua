local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        tooltipVendor = true,
        tooltipItemID = true,
    },
    settings = {
        { type = "header", name = "SECTION_TOOLTIP" },
        { key = "tooltipVendor", name = "TOOLTIP_VENDOR", desc = "TOOLTIP_VENDOR_DESC" },
        { key = "tooltipItemID", name = "TOOLTIP_ITEM_ID", desc = "TOOLTIP_ITEM_ID_DESC" },
    },
}

local hooked = false

local function GetTooltipStackCount(tooltip)
    if not tooltip or not tooltip.GetOwner then
        return 1
    end
    local owner = tooltip:GetOwner()
    if owner and owner.GetBagID and owner.GetID and C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(owner:GetBagID(), owner:GetID())
        local count = info and ns.Reveal(info.stackCount)
        if count and count > 1 then
            return count
        end
    end
    return 1
end

local function AddItemLines(tooltip, data)
    if not tooltip or tooltip.IsForbidden and tooltip:IsForbidden() then
        return
    end

    local itemID = data and data.id
    if not itemID then
        local _, link = tooltip.GetItem and tooltip:GetItem()
        itemID = ns.GetItemID(link)
    end
    if not itemID then
        return
    end

    if addon:Get("tooltipVendor") then
        local info = ns.GetItemInfo(itemID)
        local price = info and tonumber(info.sellPrice) or 0
        if price > 0 then
            tooltip:AddLine(format(L.TOOLTIP_SELLS_FOR, ns.MoneyString(price)), 0.7, 0.7, 0.7)
            local count = GetTooltipStackCount(tooltip)
            if count > 1 then
                tooltip:AddLine(format(L.TOOLTIP_STACK, count, ns.MoneyString(price * count)), 0.55, 0.55, 0.55)
            end
        end
    end

    if addon:Get("tooltipItemID") then
        tooltip:AddLine(format(L.TOOLTIP_ITEM_ID_LABEL, itemID), 0.4, 0.7, 1)
    end
end

function module:IsEnabled()
    return addon:Get("tooltipVendor") or addon:Get("tooltipItemID")
end

function module:Enable()
    if hooked then
        return
    end
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemLines)
        hooked = true
    elseif GameTooltip then
        GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
            AddItemLines(tooltip)
        end)
        hooked = true
    end
end

function module:Disable()
    -- TooltipDataProcessor hooks cannot be removed cleanly; gated by DB flags.
end

addon:RegisterModule("Tooltip", module)
