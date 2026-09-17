local ADDON_NAME, ns = ...

ns.MEDIA = "Interface\\AddOns\\LumiereUI\\Media\\"

function ns.Media(file)
    return ns.MEDIA .. file
end

-- Paladin class color (RAID_CLASS_COLORS.PALADIN)
ns.CLASS = { 0.96, 0.55, 0.73 }

ns.PALETTES = {
    holy = {
        chrome = { 1.00, 0.84, 0.32 },
        chromeHi = { 1.00, 0.95, 0.72 },
        accent = { 0.96, 0.55, 0.73 },
        health = { 0.95, 0.78, 0.28 },
        power = { 0.32, 0.52, 1.00 },
        bg = { 0.07, 0.06, 0.03 },
        text = { 1.00, 0.92, 0.70 },
    },
    protection = {
        chrome = { 0.78, 0.84, 0.92 },
        chromeHi = { 0.93, 0.95, 0.99 },
        accent = { 0.35, 0.55, 0.95 },
        health = { 0.42, 0.60, 0.92 },
        power = { 0.28, 0.48, 1.00 },
        bg = { 0.04, 0.05, 0.08 },
        text = { 0.86, 0.90, 1.00 },
    },
    retribution = {
        chrome = { 1.00, 0.78, 0.22 },
        chromeHi = { 1.00, 0.90, 0.55 },
        accent = { 0.78, 0.14, 0.12 },
        health = { 0.82, 0.20, 0.14 },
        power = { 1.00, 0.80, 0.22 },
        bg = { 0.08, 0.03, 0.02 },
        text = { 1.00, 0.86, 0.55 },
    },
}

function ns.SpecKey()
    local variant = LumiereUIDB and LumiereUIDB.variant or "auto"
    if variant == "holy" or variant == "protection" or variant == "retribution" then
        return variant
    end
    local spec
    if C_SpecializationInfo and C_SpecializationInfo.GetSpecialization then
        spec = C_SpecializationInfo.GetSpecialization()
    elseif GetSpecialization then
        spec = GetSpecialization()
    end
    if spec == 2 then
        return "protection"
    end
    if spec == 3 then
        return "retribution"
    end
    return "holy"
end

function ns.Palette()
    return ns.PALETTES[ns.SpecKey()] or ns.PALETTES.holy
end

function ns.Color(key)
    local p = ns.Palette()
    return p[key] or p.chrome
end

function ns.Unpack(key)
    local c = ns.Color(key)
    return c[1], c[2], c[3], c[4] or 1
end

function ns.IsPaladin()
    local class = ns.SafeUnitClass and ns.SafeUnitClass("player")
    if class then
        return class == "PALADIN"
    end
    local _, classToken = UnitClass("player")
    return classToken == "PALADIN"
end

function ns.SkinEnabled()
    if not LumiereUIDB or LumiereUIDB.enabled == false then
        return false
    end
    if LumiereUIDB.onlyPaladin and not ns.IsPaladin() then
        return false
    end
    return true
end
