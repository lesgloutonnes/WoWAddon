local ADDON_NAME, ns = ...
local L = ns.L

local defaults = {
    enabled = true,
    variant = "auto",
    unitFrames = true,
    actionBars = true,
    minimap = true,
    chat = true,
    tooltips = true,
    castBars = true,
    windows = true,
    gryphons = true,
    crest = true,
    onlyPaladin = false,
    splash = true,
}

local function Checkbox(category, key, name, desc)
    local defaultValue = LumiereUIDB[key]
    if defaultValue == nil then
        defaultValue = defaults[key]
        if defaultValue == nil then
            defaultValue = false
        end
    end
    local varType = (Settings.VarType and Settings.VarType.Boolean) or type(true)
    local setting = Settings.RegisterAddOnSetting(
        category,
        ADDON_NAME .. "_" .. key,
        key,
        LumiereUIDB,
        varType,
        name,
        defaultValue
    )
    Settings.CreateCheckbox(category, setting, desc)
    setting:SetValueChangedCallback(function()
        if ns.addon then
            ns.addon:ScheduleApply(0.05)
        end
    end)
    return setting
end

function ns.InitSettings(addon)
    if addon.settingsReady or not Settings or not Settings.RegisterVerticalLayoutCategory then
        return
    end

    local category, layout = Settings.RegisterVerticalLayoutCategory(L.SETTINGS)
    Settings.RegisterAddOnCategory(category)
    addon.settingsCategory = category

    if layout and layout.AddInitializer and CreateSettingsListSectionHeaderInitializer then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.SETTINGS_INTRO))
    end

    Checkbox(category, "enabled", L.ENABLE, L.ENABLE_DESC)

    local variantDefault = LumiereUIDB.variant or "auto"
    local variantType = (Settings.VarType and Settings.VarType.String) or "string"
    local variantSetting = Settings.RegisterAddOnSetting(
        category,
        ADDON_NAME .. "_variant",
        "variant",
        LumiereUIDB,
        variantType,
        L.VARIANT,
        variantDefault
    )
    local function VariantOptions()
        local container = Settings.CreateControlTextContainer()
        container:Add("auto", L.VARIANT_AUTO)
        container:Add("holy", L.VARIANT_HOLY)
        container:Add("protection", L.VARIANT_PROT)
        container:Add("retribution", L.VARIANT_RET)
        return container:GetData()
    end
    if Settings.CreateDropdown then
        Settings.CreateDropdown(category, variantSetting, VariantOptions, L.VARIANT_DESC)
    end
    variantSetting:SetValueChangedCallback(function()
        addon:ScheduleApply(0.05)
    end)

    Checkbox(category, "unitFrames", L.UNITFRAMES, L.UNITFRAMES_DESC)
    Checkbox(category, "actionBars", L.ACTIONBARS, L.ACTIONBARS_DESC)
    Checkbox(category, "minimap", L.MINIMAP, L.MINIMAP_DESC)
    Checkbox(category, "chat", L.CHAT, L.CHAT_DESC)
    Checkbox(category, "tooltips", L.TOOLTIPS, L.TOOLTIPS_DESC)
    Checkbox(category, "castBars", L.CASTBARS, L.CASTBARS_DESC)
    Checkbox(category, "windows", L.WINDOWS, L.WINDOWS_DESC)
    Checkbox(category, "gryphons", L.GRYPHONS, L.GRYPHONS_DESC)
    Checkbox(category, "crest", L.CREST, L.CREST_DESC)
    Checkbox(category, "onlyPaladin", L.ONLY_PALADIN, L.ONLY_PALADIN_DESC)
    Checkbox(category, "splash", L.SPLASH_OPT, L.SPLASH_OPT_DESC)

    addon.settingsReady = true
end
