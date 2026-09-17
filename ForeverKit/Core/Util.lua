local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "0.1.0"

function ns.Print(...)
    print("|cff00ccffForeverKit|r:", ...)
end

function ns.Printf(fmt, ...)
    print("|cff00ccffForeverKit|r: " .. format(fmt, ...))
end

function ns.CopyDefaults(src, dest)
    if type(dest) ~= "table" then
        dest = {}
    end
    for key, value in pairs(src) do
        if dest[key] == nil then
            if type(value) == "table" then
                dest[key] = ns.CopyDefaults(value, {})
            else
                dest[key] = value
            end
        elseif type(value) == "table" and type(dest[key]) == "table" then
            ns.CopyDefaults(value, dest[key])
        end
    end
    return dest
end

function ns.MoneyString(copper)
    copper = tonumber(copper) or 0
    if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then
        return C_CurrencyInfo.GetCoinTextureString(copper)
    end
    if GetCoinTextureString then
        return GetCoinTextureString(copper)
    end
    local gold = floor(copper / 10000)
    local silver = floor((copper % 10000) / 100)
    local c = copper % 100
    return format("%dg %ds %dc", gold, silver, c)
end

function ns.BagIndexRange()
    local last = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
    return 0, last
end

function ns.GetItemInfo(item)
    if not item or not C_Item or not C_Item.GetItemInfo then
        return nil
    end
    local a, b, c, d, e, f, g, h, i, j, sellPrice, classID, subclassID, bindType = C_Item.GetItemInfo(item)
    if a == nil then
        return nil
    end
    if type(a) == "table" then
        return a
    end
    return {
        itemName = a,
        itemLink = b,
        itemQuality = c,
        itemLevel = d,
        itemMinLevel = e,
        itemType = f,
        itemSubType = g,
        itemStackCount = h,
        itemEquipLoc = i,
        itemTexture = j,
        sellPrice = sellPrice,
        classID = classID,
        subclassID = subclassID,
        bindType = bindType,
    }
end

function ns.GetItemID(item)
    if type(item) == "number" then
        return item
    end
    if type(item) == "string" then
        local id = item:match("item:(%d+)")
        return id and tonumber(id) or nil
    end
    return nil
end

function ns.InCombat()
    return InCombatLockdown and InCombatLockdown() or false
end

function ns.HookOrNil(object, method, hookFn)
    if object and type(object[method]) == "function" then
        hooksecurefunc(object, method, hookFn)
        return true
    end
    return false
end
