local ADDON_NAME, ns = ...
local L = ns.L

local function AddCheckbox(category, key, name, desc)
    local defaultValue = ForeverKitDB[key]
    if defaultValue == nil then
        defaultValue = false
    end
    local varType = (Settings.VarType and Settings.VarType.Boolean) or type(true)
    local setting = Settings.RegisterAddOnSetting(
        category,
        ADDON_NAME .. "_" .. key,
        key,
        ForeverKitDB,
        varType,
        name,
        defaultValue
    )
    Settings.CreateCheckbox(category, setting, desc)
    setting:SetValueChangedCallback(function()
        if ns.addon then
            ns.addon:RefreshModules()
        end
    end)
    return setting
end

function ns.InitSettings(addon)
    if addon.settingsReady then
        return
    end
    if not Settings or not Settings.RegisterVerticalLayoutCategory then
        return
    end

    local category, layout = Settings.RegisterVerticalLayoutCategory(L.SETTINGS_TITLE)
    Settings.RegisterAddOnCategory(category)
    addon.settingsCategory = category

    if layout and layout.AddInitializer and CreateSettingsListSectionHeaderInitializer then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.SETTINGS_INTRO))
    end

    for _, key in ipairs(addon.order) do
        local module = addon.modules[key]
        if module and module.settings then
            for _, entry in ipairs(module.settings) do
                if entry.type == "header" then
                    if layout and layout.AddInitializer and CreateSettingsListSectionHeaderInitializer then
                        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L[entry.name]))
                    end
                elseif entry.key then
                    AddCheckbox(category, entry.key, L[entry.name], L[entry.desc])
                end
            end
        end
    end

    addon.settingsReady = true
end
