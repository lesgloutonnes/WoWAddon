local ADDON_NAME, ns = ...
local addon = ns.addon

local skin = { setting = "chat" }

function skin:Apply()
    local n = NUM_CHAT_WINDOWS or 10
    local chrome = ns.Color("chrome")
    local parts = {
        "TopLeftTexture",
        "TopRightTexture",
        "BottomLeftTexture",
        "BottomRightTexture",
        "LeftTexture",
        "RightTexture",
        "TopTexture",
        "BottomTexture",
    }
    for i = 1, n do
        local frame = _G["ChatFrame" .. i]
        local tab = _G["ChatFrame" .. i .. "Tab"]
        local edit = _G["ChatFrame" .. i .. "EditBox"]
        if frame then
            ns.TintNineSlice(frame)
            ns.TintNamed(frame, "Background", ns.Color("bg"))
            for p = 1, #parts do
                ns.Tint(_G["ChatFrame" .. i .. parts[p]], chrome)
            end
        end
        if tab then
            ns.TintFrameArt(tab, ns.Color("chrome"), 1)
            if tab.Text and tab.Text.SetTextColor then
                tab.Text:SetTextColor(ns.Unpack("text"))
            end
        end
        if edit then
            ns.TintNineSlice(edit)
            ns.TintFrameArt(edit, ns.Color("chrome"), 1)
            if edit.SetHeaderTint then
                pcall(edit.SetHeaderTint, edit, ns.Unpack("chrome"))
            end
        end
    end
    if GeneralDockManager then
        ns.TintFrameArt(GeneralDockManager, ns.Color("chrome"), 1)
    end
    if ChatFrameMenuButton then
        ns.TintFrameArt(ChatFrameMenuButton, ns.Color("chrome"), 1)
    end
end

addon:RegisterSkin("Chat", skin)
