local ADDON_NAME, ns = ...
local L = ns.L
local addon = ns.addon

local module = {
    defaults = {
        cameraMax = true,
    },
    settings = {
        { type = "header", name = "SECTION_CAMERA" },
        { key = "cameraMax", name = "CAMERA_MAX", desc = "CAMERA_MAX_DESC" },
    },
}

local FACTOR = "2.6"

local function Apply()
    if not addon:Get("cameraMax") then
        return
    end
    if C_CVar and C_CVar.SetCVar then
        pcall(C_CVar.SetCVar, "cameraDistanceMaxZoomFactor", FACTOR)
    elseif SetCVar then
        pcall(SetCVar, "cameraDistanceMaxZoomFactor", FACTOR)
    end
end

function module:IsEnabled()
    return addon:Get("cameraMax")
end

function module:Enable()
    Apply()
end

function module:Disable()
end

addon:RegisterModule("Camera", module)
