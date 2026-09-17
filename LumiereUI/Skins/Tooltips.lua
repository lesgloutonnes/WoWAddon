local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "tooltips" }

local TIPS = {
    "GameTooltip",
    "ItemRefTooltip",
    "ShoppingTooltip1",
    "ShoppingTooltip2",
    "EmbeddedItemTooltip",
    "FriendsTooltip",
}

local function SkinTip(tip)
    if not tip or (tip.IsForbidden and tip:IsForbidden()) then
        return
    end
    ns.TintNineSlice(tip, ns.Color("chrome"))
    if tip.SetBackdropBorderColor then
        pcall(tip.SetBackdropBorderColor, tip, ns.Unpack("chrome"))
    end
    if tip.SetBackdropColor then
        local bg = ns.Color("bg")
        pcall(tip.SetBackdropColor, tip, bg[1], bg[2], bg[3], 0.92)
    end
    ns.TintNamed(tip, "Border", ns.Color("chrome"))
    if tip.NineSlice and tip.NineSlice.Center then
        ns.Tint(tip.NineSlice.Center, ns.Color("bg"))
    end
end

function skin:Apply()
    for i = 1, #TIPS do
        SkinTip(_G[TIPS[i]])
    end
end

local function HookTip(tip)
    if not tip or tip.LumiereHooked then
        return
    end
    tip.LumiereHooked = true
    tip:HookScript("OnShow", function(self)
        if ns.SkinEnabled() and addon:Get("tooltips") then
            SkinTip(self)
        end
    end)
end

for i = 1, #TIPS do
    local tip = _G[TIPS[i]]
    if tip then
        HookTip(tip)
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    for _, dataType in pairs(Enum.TooltipDataType) do
        if type(dataType) == "number" then
            TooltipDataProcessor.AddTooltipPostCall(dataType, function(tooltip)
                if ns.SkinEnabled() and addon:Get("tooltips") then
                    SkinTip(tooltip)
                end
            end)
        end
    end
end

addon:RegisterSkin("Tooltips", skin)
