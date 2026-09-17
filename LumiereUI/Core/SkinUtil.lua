local ADDON_NAME, ns = ...

ns.serial = 1
ns.touched = {}
ns.overlays = {}

local SKIP_TYPES = {
    FontString = true,
    Cooldown = true,
    PlayerModel = true,
    DressUpModel = true,
    AnimationGroup = true,
    Path = true,
    Alpha = true,
    Scale = true,
    Rotation = true,
    Translation = true,
}

local SKIP_NAME = {
    "Portrait", "portrait", "Aura", "Buff", "Debuff", "NamePlate",
    "Cooldown", "Mask", "Totem", "icon", "Icon",
}

function ns.ShouldSkipFrame(frame)
    if not frame then
        return true
    end
    if frame.IsForbidden and frame:IsForbidden() then
        return true
    end
    if frame.IsPreventingSecretValues and frame:IsPreventingSecretValues() then
        return true
    end
    if frame.HasAnySecretAspect and frame:HasAnySecretAspect() then
        return true
    end
    local objType = frame.GetObjectType and frame:GetObjectType()
    if objType == "AuraContainer" or objType == "Cooldown" then
        return true
    end
    local name = frame.GetName and frame:GetName() or ""
    local debugName = frame.GetDebugName and frame:GetDebugName() or name
    for _, needle in ipairs(SKIP_NAME) do
        if name:find(needle, 1, true) or debugName:find(needle, 1, true) then
            return true
        end
    end
    return false
end

function ns.Tint(tex, color)
    if not tex or not tex.SetVertexColor then
        return
    end
    if tex.IsForbidden and tex:IsForbidden() then
        return
    end
    color = color or ns.Color("chrome")
    if not tex.LumiereOrig then
        local r, g, b, a = 1, 1, 1, 1
        if tex.GetVertexColor then
            r, g, b, a = tex:GetVertexColor()
        end
        tex.LumiereOrig = { r, g, b, a }
    end
    ns.touched[tex] = true
    tex:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
end

function ns.SetAlpha(region, alpha)
    if not region or not region.SetAlpha then
        return
    end
    if region.IsForbidden and region:IsForbidden() then
        return
    end
    if region.LumiereOrigAlpha == nil and region.GetAlpha then
        region.LumiereOrigAlpha = region:GetAlpha()
    end
    ns.touched[region] = true
    region:SetAlpha(alpha)
end

function ns.Restore(region)
    if not region then
        return
    end
    if region.LumiereOrig and region.SetVertexColor then
        local o = region.LumiereOrig
        region:SetVertexColor(o[1], o[2], o[3], o[4] or 1)
    end
    if region.LumiereOrigBar and region.SetStatusBarColor then
        local o = region.LumiereOrigBar
        region:SetStatusBarColor(o[1], o[2], o[3], o[4] or 1)
    end
    if region.LumiereOrigAlpha ~= nil and region.SetAlpha then
        region:SetAlpha(region.LumiereOrigAlpha)
    end
end

function ns.RestoreAll()
    for region in pairs(ns.touched) do
        pcall(ns.Restore, region)
    end
end

function ns.HideLumiereOverlays()
    for i = 1, #ns.overlays do
        local tex = ns.overlays[i]
        if tex and tex.Hide then
            tex:Hide()
        end
    end
end

function ns.TrackOverlay(tex)
    if tex then
        ns.overlays[#ns.overlays + 1] = tex
    end
    return tex
end

function ns.DumpExists(name)
    local frame = _G[name]
    if frame then
        return "oui"
    end
    return "non"
end

function ns.TintNamed(parent, childName, color)
    if parent and parent[childName] then
        ns.Tint(parent[childName], color)
    end
end

function ns.TintNineSlice(frame, color)
    local slice = frame and (frame.NineSlice or frame.NineSliceLayout or frame.Border)
    if not slice then
        return
    end
    color = color or ns.Color("chrome")
    local keys = {
        "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner",
        "TopEdge", "BottomEdge", "LeftEdge", "RightEdge", "Center",
        "TopLeft", "TopRight", "BottomLeft", "BottomRight",
        "Left", "Right", "Top", "Bottom",
    }
    for _, key in ipairs(keys) do
        if slice[key] then
            ns.Tint(slice[key], color)
        end
    end
end

local function LooksLikeArt(tex)
    if not tex or not tex.GetObjectType or tex:GetObjectType() ~= "Texture" then
        return false
    end
    local draw = tex.GetDrawLayer and select(1, tex:GetDrawLayer())
    if draw == "HIGHLIGHT" then
        return false
    end
    local path = ""
    if tex.GetTexture then
        local ok, value = pcall(tex.GetTexture, tex)
        if ok and type(value) == "string" then
            path = value
        end
    end
    if path:find("Icons\\") or path:find("Portrait") or path:find("ClassIcon") then
        return false
    end
    local name = tex.GetName and tex:GetName() or ""
    if name:find("Portrait") or name:find("Icon") then
        return false
    end
    return true
end

function ns.TintFrameArt(frame, color, depth)
    depth = depth or 0
    if depth > 5 or ns.ShouldSkipFrame(frame) then
        return
    end
    color = color or ns.Color("chrome")
    if frame.GetRegions then
        local regions = { frame:GetRegions() }
        for i = 1, #regions do
            local region = regions[i]
            if LooksLikeArt(region) then
                ns.Tint(region, color)
            end
        end
    end
    ns.TintNineSlice(frame, color)
    if depth < 3 and frame.GetChildren then
        local children = { frame:GetChildren() }
        for i = 1, #children do
            local child = children[i]
            local objType = child.GetObjectType and child:GetObjectType()
            if objType and not SKIP_TYPES[objType] and objType ~= "StatusBar" and objType ~= "Button" then
                ns.TintFrameArt(child, color, depth + 1)
            end
        end
    end
end

function ns.ColorBar(bar, key)
    if not bar or not bar.SetStatusBarColor then
        return
    end
    if not bar.LumiereOrigBar and bar.GetStatusBarColor then
        local r, g, b, a = bar:GetStatusBarColor()
        bar.LumiereOrigBar = { r, g, b, a }
    end
    ns.touched[bar] = true
    bar:SetStatusBarColor(ns.Unpack(key or "health"))
end

function ns.EnsureOverlay(parent, key, layer)
    if parent[key] then
        return parent[key]
    end
    local tex = parent:CreateTexture(nil, layer or "OVERLAY")
    parent[key] = tex
    ns.TrackOverlay(tex)
    return tex
end

function ns.ForEachGlobal(prefix, count, fn)
    for i = 1, count do
        local frame = _G[prefix .. i]
        if frame then
            fn(frame, i)
        end
    end
end

function ns.SafeUnitClass(unit)
    if UnitClassBase then
        local token = UnitClassBase(unit)
        if type(token) == "string" then
            return token
        end
    end
    local _, classToken = UnitClass(unit)
    if type(classToken) == "string" then
        return classToken
    end
    return nil
end
