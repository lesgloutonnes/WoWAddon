local ADDON_NAME, ns = ...
local L = ns.L

local addon = {
    name = ADDON_NAME,
    version = ns.VERSION,
    modules = {},
    order = {},
}
ns.addon = addon
_G.ForeverKit = addon

ForeverKitDB = ForeverKitDB or {}

local defaults = {
    minimapCoordsX = 0,
    minimapCoordsY = -16,
}

function addon:RegisterModule(key, module)
    module.key = key
    self.modules[key] = module
    self.order[#self.order + 1] = key
    if module.defaults then
        for settingKey, value in pairs(module.defaults) do
            defaults[settingKey] = value
        end
    end
end

function addon:DB()
    return ForeverKitDB
end

function addon:Get(key)
    return ForeverKitDB[key]
end

function addon:Set(key, value)
    ForeverKitDB[key] = value
end

function addon:InitDB()
    ForeverKitDB = ns.CopyDefaults(defaults, ForeverKitDB)
    ns.db = ForeverKitDB
end

function addon:EnableModule(key)
    local module = self.modules[key]
    if not module or module.enabled then
        return
    end
    if module.Enable then
        local ok, err = pcall(module.Enable, module, self)
        if not ok then
            ns.Printf("|cffff5555%s|r: %s", key, tostring(err))
            return
        end
    end
    module.enabled = true
end

function addon:DisableModule(key)
    local module = self.modules[key]
    if not module or not module.enabled then
        return
    end
    if module.Disable then
        pcall(module.Disable, module, self)
    end
    module.enabled = false
end

function addon:RefreshModules()
    for _, key in ipairs(self.order) do
        local module = self.modules[key]
        if module then
            local shouldEnable = true
            if module.IsEnabled then
                shouldEnable = module:IsEnabled(self) and true or false
            end
            if shouldEnable then
                self:EnableModule(key)
            else
                self:DisableModule(key)
            end
        end
    end
end

function addon:OpenSettings()
    if Settings and Settings.OpenToCategory then
        if self.settingsCategory and self.settingsCategory.GetID then
            Settings.OpenToCategory(self.settingsCategory:GetID())
            return
        end
        Settings.OpenToCategory(L.SETTINGS_TITLE)
        return
    end
    ns.Print(L.HELP_OPTIONS)
end

function addon:PrintHelp()
    ns.Print(L.HELP_HEADER)
    print("  " .. L.HELP_OPTIONS)
    print("  " .. L.HELP_DEBUG)
    print("  " .. L.HELP_COORDS)
    print("  " .. L.HELP_COPY)
    print("  " .. L.HELP_GOLD)
    print("  " .. L.HELP_RELOAD)
end

SLASH_FOREVERKIT1 = "/fk"
SLASH_FOREVERKIT2 = "/foreverkit"
SlashCmdList.FOREVERKIT = function(msg)
    msg = strtrim(strlower(msg or ""))
    if msg == "" or msg == "help" or msg == "aide" then
        addon:PrintHelp()
    elseif msg == "options" or msg == "config" or msg == "opt" then
        addon:OpenSettings()
    elseif msg == "debug" or msg == "diag" then
        local diagnostics = addon.modules.Diagnostics
        if diagnostics and diagnostics.Run then
            diagnostics:Run()
        end
    elseif msg == "coords" or msg == "gps" then
        local map = addon.modules.Map
        if map and map.PrintCoords then
            map:PrintCoords()
        end
    elseif msg == "copy" then
        local chat = addon.modules.Chat
        if chat and chat.Copy then
            chat:Copy()
        end
    elseif msg == "gold" or msg == "or" then
        local gold = addon.modules.Gold
        if gold and gold.PrintSession then
            gold:PrintSession()
        end
    elseif msg == "reload" or msg == "rl" then
        ReloadUI()
    else
        addon:PrintHelp()
    end
end

function ForeverKit_OnAddonCompartmentClick()
    addon:OpenSettings()
end

function ForeverKit_OnAddonCompartmentEnter(_, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText("ForeverKit", 0, 0.8, 1)
    GameTooltip:AddLine(L.COMPARTMENT_HINT, 1, 1, 1, true)
    GameTooltip:Show()
end

function ForeverKit_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= ADDON_NAME then
            return
        end
        addon:InitDB()
        if ns.InitSettings then
            ns.InitSettings(addon)
        end
    elseif event == "PLAYER_LOGIN" then
        addon:RefreshModules()
        ns.Printf(L.LOADED)
    end
end)
