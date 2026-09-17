local ADDON_NAME, ns = ...

-- Helpers for Midnight / Forever secret values.
-- Combat-sensitive APIs can return secret numbers/strings that addons must not branch on.

function ns.IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

function ns.CanAccess(value)
    if value == nil then
        return false
    end
    if not ns.IsSecret(value) then
        return true
    end
    return canaccessvalue and canaccessvalue(value) or false
end

function ns.Reveal(value, fallback)
    if ns.CanAccess(value) then
        return value
    end
    return fallback
end

function ns.SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok then
        return nil
    end
    if ns.IsSecret(a) and not ns.CanAccess(a) then
        return nil
    end
    return a, b, c, d, e
end

function ns.AreAurasRestricted()
    if C_Secrets and C_Secrets.ShouldUnitAuraIndexBeSecret then
        local secret = ns.SafeCall(C_Secrets.ShouldUnitAuraIndexBeSecret, "player", 1, "HELPFUL")
        return secret == true
    end
    if C_RestrictedActions and C_RestrictedActions.IsAuraDataRestricted then
        return C_RestrictedActions.IsAuraDataRestricted() and true or false
    end
    return false
end
